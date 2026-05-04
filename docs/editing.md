# 編集操作規約

## 基本方針

- normal mode と copy mode は vi 系に寄せる
- insert mode と command-line mode は Emacs 系に寄せる
- 補完候補 UI が開いているときだけ `Ctrl+j` / `Ctrl+k` で候補を上下移動する
- アプリ間で共有するコピー先は system clipboard を正本にする

## clipboard 方針

- 共通の受け渡し先は system clipboard であり、Emacs kill-ring・Vim register・tmux buffer・zsh kill buffer を直接そろえることは目標にしない
- Vim / Neovim は `clipboard=unnamedplus` を使い、通常の yank / paste を system clipboard と接続する
- tmux は copy mode の `y` を tmux buffer と system clipboard の両方へ流す
- Spacemacs / Emacs は kill-ring を内部状態として持ってよいが、アプリ外との copy / paste は system clipboard を優先する方針にする
- zsh のコマンドライン編集では kill buffer の共有は目指さず、必要な共有は terminal / system clipboard 側に任せる

## 現在のキーバインド方針

- zsh の通常コマンドラインは Emacs 系 keybind を使う
- Vim / Neovim の insert mode は `Ctrl+a/e/f/b/p/n/d/h` を Emacs 風にする
- Vim / Neovim の command-line mode は `Ctrl+a/e/b/f/d` を Emacs 風にする
- Spacemacs の insert state は `Ctrl+a/e/f/b/p/n/d/h` を Emacs 風にする
- Spacemacs の company、Vim / Neovim の補完、zsh の補完候補選択では `Ctrl+j` / `Ctrl+k` を使う

## 次に詰めること

- Spacemacs 側の clipboard 連携を明示設定にするか確認する
- `Ctrl+k/u/w/y` や `Meta+f/b/d` まで共通化するか決める
