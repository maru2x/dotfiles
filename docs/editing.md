# 編集操作規約

## 基本方針

- normal mode と copy mode は vi 系に寄せる
- insert mode と command-line mode は Emacs 系に寄せる
- 補完候補 UI が開いているときだけ `Ctrl+j` / `Ctrl+k` で候補を上下移動する
- アプリ間で共有するコピー先は system clipboard を正本にする

## clipboard 方針

- 共通の受け渡し先は system clipboard であり、Emacs kill-ring・Vim register・tmux buffer・zsh kill buffer を直接そろえることは目標にしない
- Vim / Neovim は `clipboard=unnamedplus` を使い、通常の yank / paste を system clipboard と接続する
- tmux は copy mode の `y` を tmux buffer と system clipboard の両方へ流し、`prefix + p` で system clipboard を現在ペインへ貼り付ける
- Spacemacs / Emacs は kill-ring を内部状態として持ってよいが、copy / paste のアプリ外連携は `clipboard-copy` / `clipboard-paste` を通して system clipboard を優先する
- zsh のコマンドライン編集では kill buffer の共有は目指さず、必要な共有は terminal / system clipboard 側に任せる

## 現在のキーバインド方針

- zsh の通常コマンドラインは Emacs 系 keybind を使う
- Vim / Neovim の insert mode は `Ctrl+a/e/f/b/p/n/d/h` を Emacs 風にする
- Vim / Neovim の command-line mode は `Ctrl+a/e/b/f/d` を Emacs 風にする
- Spacemacs の insert state は `Ctrl+a/e/f/b/p/n/d/h` を Emacs 風にする
- Spacemacs の company、Vim / Neovim の補完、zsh の補完候補選択では `Ctrl+j` / `Ctrl+k` を使う

## 次に詰めること

- Spacemacs 側の `Ctrl+k/u/w/y` や `Meta+f/b/d` をどこまで共通化するか決める
- terminal emulator 側の paste shortcut と tmux / Spacemacs 側の貼り付け経路をどこまで統一するか決める
