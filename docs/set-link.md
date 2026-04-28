# `make set-link` の挙動

## 概要

`make set-link` は、`dotfiles` で管理している設定ファイルを `$HOME` 配下にリンクするためのコマンドです。

ただし、リンクを張ろうとした先に既存ファイルや既存リンクがあると、そのまま上書きしてしまう危険があります。
そのため `make set-link` は、リンク先に「期待通りのもの」があるかどうかを先に確認し、期待通りでなければ一度失敗してエラーを表示します。

## 基本的な考え方

考え方は単純です。

1. `dotfiles/configs/` 配下にある各設定ファイルについて、対応する `$HOME` 側の配置先を決める
2. その配置先に何もなければ、そのままリンクを張る
3. 何かあれば、それが `dotfiles` が置きたいファイルそのものかどうかを確認する
4. `dotfiles` が置きたいファイルそのものでなければ、衝突として止める

たとえば `dotfiles/configs/zsh/.zsh/01-ohmyzsh.zsh` を管理している場合、対応する配置先は `~/.zsh/01-ohmyzsh.zsh` です。

## 対応する配置先

`make set-link` は `dotfiles/configs/<package>/...` を `$HOME/...` に対応づけて扱います。

例:

- `dotfiles/configs/zsh/.zsh/01-ohmyzsh.zsh` → `~/.zsh/01-ohmyzsh.zsh`
- `dotfiles/configs/nvim/.config/nvim/init.vim` → `~/.config/nvim/init.vim`
- `dotfiles/configs/ssh/.ssh/config` → `~/.ssh/config`

## 衝突判定

各配置先について、`make set-link` は「その場所に既存物があるか」を確認します。

- 何もなければ、そのまま進む
- 既存物があり、その解決先が `dotfiles` 側の対応ファイルと一致すれば、そのまま進む
- それ以外は衝突として止める

ここでいう「解決先が一致する」とは、直接 symlink が張られている場合だけでなく、親ディレクトリの symlink をたどった結果として同じファイルに着地する場合も含みます。

つまり `make set-link` が見たいのは、「見た目が symlink かどうか」ではなく、「最終的に `dotfiles` が管理している正しいファイルに着地するかどうか」です。

## 具体例

### 問題ない例

`~/.zsh` が `dotfiles/configs/zsh/.zsh` を向いていて、`~/.zsh/01-ohmyzsh.zsh` が最終的に `dotfiles/configs/zsh/.zsh/01-ohmyzsh.zsh` に着地する場合は、そのまま通ります。

これは `~/.zsh/01-ohmyzsh.zsh` 自体が直接 symlink でなくても問題ありません。

### 衝突になる例

- `~/.config/nvim` が別の `dotfiles` や別ディレクトリを向いている
- `~/.zshrc` に普通の既存ファイルがある
- 壊れた symlink が残っている

このような場合は、`dotfiles` が管理しているファイルを安全に張れないため、`make set-link` は失敗します。

## エラー時の対処

`make set-link` が衝突で止まった場合は、表示されたパスを手動で整理してから再実行してください。

たとえば次のような対応があります。

- 既存ファイルを退避する
- 古い symlink を削除する
- 別の `dotfiles` を向いているリンクを今の `dotfiles` に合わせて整理する

整理後に、もう一度 `make set-link` を実行します。

## 補足

- `make set-link` は `GNU Stow` を使ってリンクを張ります
- `make set-link` は既存ファイルや既存 symlink を自動削除しません
- 衝突を自動解決しないのは、既存設定の上書き事故を避けるためです
