## 概要
- spacemacsを中心とした開発環境の設定ファイル群
- Debian, macでは動作確認済み

## プロジェクト構成
主なプログラムは以下のような構成になっている。
- `configs/`: dotfilesで管理する設定ファイル本体
- `bin/`: 個人的に作成した実行ファイル群。詳細は **bin実行コマンド詳細** を確認
- `scripts/`: `Makefile`で利用するシェルコマンド群
- `docs/`: 運用ドキュメント
- `Makefile`: `install`/`set-link`/`setup`など、`configs/`の内容を実際にマシンに展開する実行コマンド
- `Brewfile`: brew管理したいソフトウェアの一覧
`Makefile` の `setup` コマンドを実行することで、 **dotfiles** で管理するソフトウェアがインストールされ、それらの設定ファイルがマシン上に配置される．

## 実行前準備
以下のソフトウェアはマシンのOSによってインストール方法が異なっていたり、容量食いだったりするため、`make install` の管理外としている。
参考になるWebサイトのURLを添付しておく

| `make install`管理外ソフトウェア | 参考サイト                            |
| homebrew                         | https://brew.sh/ja/                   |
| emacs / spacemacs                | https://github.com/syl20bnr/spacemacs |
| docker                           | どこにでもある                        |

- `scripts/install.sh` は Homebrew を自動インストールしない
- `brew` がPATHに無くても、以下の標準パスは探索する
- `/home/linuxbrew/.linuxbrew/bin/brew`
- `/opt/homebrew/bin/brew`
- `/usr/local/bin/brew`
- `scripts/set-link.sh` 実行前には GNU Stow が必要

## 実行
`Makefile` には以下のコマンドが用意されている。基本的には、 **##実行前準備**を済ませた状態で `make setup` を実行することでうまく行く。
- Brewfileに記載されたソフトウェアの一括インストール => `make install`
- configsに保存された設定ファイルへのリンク生成 => `make set-link`
- 上記2つをいっぺんに -> `make setup`

## 運用
- 新しいソフトを管理したい場合は `Brewfile` に追加
- 新しい設定は `configs/` に保存
- リモートの設定変更を反映する際は基本的に`make setup`で問題ないはず
- `make set-link` は既存ファイルやsymlinkを自動削除しない
- stale symlink も衝突として扱う。たとえば `~/.config/nvim` が古いリンク先を指している場合は、リンク先を確認してから手動で整理する

## bin実行コマンド詳細

### `texinit`

`texinit` は、空ディレクトリに対して Tex を実行するための一通りの環境をビルドするショートカット。
texのソースファイルや、pdfファイルの仮生成、`.latexmkrc`の生成などを行ってくれる。
実行可能なコマンドは以下の２つ。
- `texinit` ... ltjsarticle + LuaLaTeX 形式の Texソースを作成 -> pdfファイルの仮生成までやってくれる．授業レポートなどに便利
- `texinit --mylab` ... 研究室で使用する形式の Texソースを作成

## 開発タスク

- tmux, zsh関連のコピーリング同期
- magit + sqlite3 のバグ治す
- `texinit`が有効でない`.latexmkrc`を生成している．神経のレポートの中身をみて修正を行う
