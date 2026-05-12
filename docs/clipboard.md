# Clipboard System

## 目的

この dotfiles では、clipboard の正本を system clipboard に置く。
ただし各アプリケーションの内部状態は無理に統一しない。

- Emacs は kill-ring を持つ
- Vim / Neovim は register を持つ
- tmux は buffer を持つ
- zsh は kill buffer を持つ

これらを 1 つの内部状態に寄せるのではなく、アプリ外との受け渡しだけを安定させる。

## 設計方針

- GUI Emacs は native clipboard を優先する
- terminal Emacs は helper script 経由で system clipboard と接続する
- tmux は copy mode の copy を system clipboard に流し、paste は bracketed paste で流す
- shell helper が OS / display server 差分を吸収する
- backend 判定が怪しい環境では override できるようにする
- 壊れたときに診断できるようにする

## 関連ファイル

- `bin/clipboard-backend.sh`
- `bin/clipboard-copy`
- `bin/clipboard-paste`
- `bin/clipboard-doctor`
- `bin/tmux-paste`
- `configs/spacemacs/.spacemacs`
- `configs/tmux/.tmux.conf`

## レイヤ構成

### 1. backend 解決層

`bin/clipboard-backend.sh` が backend 選択と fallback を担当する。

- 実行環境を見て候補を並べる
- backend が使えるかを判定する
- 失敗したら次の backend へ進む
- debug ログと override を受け付ける

### 2. copy / paste helper 層

- `bin/clipboard-copy`: stdin を system clipboard に送る
- `bin/clipboard-paste`: system clipboard から stdout に出す

この 2 つはアプリから使う入口で、個別の backend ロジックは極力持たない。

### 3. アプリ統合層

- Emacs: native clipboard と helper を dispatch
- tmux: copy mode と `prefix + p` で helper を利用
- Vim / Neovim: `clipboard=unnamedplus` 側で system clipboard と接続

## 環境ごとの動作

### GUI Emacs

- まず Emacs native clipboard を使う
- native clipboard で失敗した場合だけ helper に fallback する

狙い:
OS の GUI 統合を壊さず、native 側が不調でも helper 側へ逃げられるようにする

### `emacs -nw`

- native GUI clipboard には依存しない
- `clipboard-copy` / `clipboard-paste` を使う

狙い:
display server や terminal emulator 差分を Emacs 本体に持ち込まない

### `tmux` 上の zsh

- copy mode の `y` は tmux buffer と system clipboard の両方へ流れる
- `prefix + p` は `bin/tmux-paste` を通り、clipboard 内容を bracketed paste で現在 pane に流す

狙い:
shell や terminal app に対して paste の意味を保ったまま貼る

### 素の zsh

- zsh 自身の kill buffer 共有は目標にしない
- 必要な共有は terminal 側 paste か system clipboard 側に任せる

## backend 選択

デフォルトの候補順は `auto` で次の通り。

- `macos`
- `wsl`
- `wayland`
- `xclip`
- `xsel`
- `windows`

実際には各 backend が現在の環境で利用可能かを見て採用する。

### backend 名

- `auto`
- `macos`
- `wsl`
- `wayland`
- `x11`
- `xclip`
- `xsel`
- `windows`
- `none`

`x11` は `xclip -> xsel` の順で試す別名。

## 設定用環境変数

### `DOTFILES_CLIPBOARD_BACKEND`

backend 解決を上書きする。

例:

```sh
DOTFILES_CLIPBOARD_BACKEND=wayland
DOTFILES_CLIPBOARD_BACKEND=x11
DOTFILES_CLIPBOARD_BACKEND=none
```

用途:

- heuristic が誤判定する環境の固定
- 問題の切り分け
- 一時的な workaround

### `DOTFILES_CLIPBOARD_DEBUG`

`1` を入れると、helper がどの backend を試したか stderr に出す。

例:

```sh
DOTFILES_CLIPBOARD_DEBUG=1 bin/clipboard-paste
```

## 診断

まず `bin/clipboard-doctor` を実行する。

```sh
bin/clipboard-doctor
```

このコマンドで次を確認できる。

- 現在の `DISPLAY` / `WAYLAND_DISPLAY` / `WSL_INTEROP`
- 関連コマンドの存在
- 現在の解決結果
- override が不正かどうか

追加で helper 単体を直接試す。

```sh
printf 'hello' | bin/clipboard-copy
bin/clipboard-paste
```

## 典型的な壊れ方

### Wayland 変数はあるが backend が使えない

症状:
`wl-copy` / `wl-paste` は見つかるが実行に失敗する

対処:

- `DOTFILES_CLIPBOARD_DEBUG=1` で fallback を確認する
- 必要なら `DOTFILES_CLIPBOARD_BACKEND=x11` で固定する

### GUI Emacs の native clipboard だけ壊れる

症状:
GUI Emacs の copy / paste が不安定

対処:

- helper 単体が動くか確認する
- native clipboard が失敗すれば helper に fallback する前提なので、helper も生きている必要がある

### WSL / WSLg で Linux 側 backend と Windows 側 backend が競合する

症状:
`DISPLAY` があるため X11 系も見えるが、実際には Windows clipboard を使いたい

対処:

- 既定では `wsl` を先に試す
- 必要なら `DOTFILES_CLIPBOARD_BACKEND=wsl` で固定する

### SSH / remote 環境で local clipboard へ届かない

症状:
helper は動くが期待した local machine の clipboard には届かない

対処:

- これは clipboard provider ではなく接続モデルの問題
- `doctor` で見えている `DISPLAY` / `WAYLAND_DISPLAY` / `WSL_INTEROP` を確認する

## 現時点の割り切り

- text clipboard の安定性を優先する
- rich text や image clipboard は扱わない
- zsh kill buffer と Emacs kill-ring の直接同期はやらない
- `wl-paste --no-newline` を使うため、末尾改行は clipboard からそのままは戻さない

## 運用メモ

- 環境を跨いで挙動が変わったら、まず `bin/clipboard-doctor`
- backend 推定が怪しければ `DOTFILES_CLIPBOARD_BACKEND` で固定
- fallback の流れを見たいなら `DOTFILES_CLIPBOARD_DEBUG=1`
- tmux paste の違和感は `bin/tmux-paste` と bracketed paste を疑う
