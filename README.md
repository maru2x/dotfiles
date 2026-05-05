## 概要
このdotfilesで管理しているソフトウェアは大きく二つに分類できる。
- Spacemacsの設定ファイル
- その他CLIアプリケーション群の設定ファイル

このdotfilesを展開することで、以下のようなワークフローが可能となる。

- evil-mode、かつinsert-mode時にemacsライクなキーバインドで編集可能なspacemacsが利用可能
- ddtermなどのターミナルエミュレータを起動すると自動でtmuxセッションが開かれる
- tmux上ではzshが自動で起動し、zshには個人用の設定が組み込まれている
- dotfiles管理下にあるCLIアプリケーションがtmux/zsh上で利用可能

## プロジェクト構成
主なプログラムは以下のような構成になっている。
- `configs/`: dotfilesで管理する設定ファイル本体
- `templates/`: 各種生成コマンドで使うテンプレート群
- `bin/`: 個人的に作成した実行ファイル群。詳細は **bin実行コマンド詳細** を確認
- `scripts/`: `Makefile`で利用するシェルコマンド群
- `docs/`: 運用ドキュメント
- `Makefile`: `install`/`set-link`/`setup`など、`configs/`の内容を実際にマシンに展開する実行コマンド
- `Brewfile`: brew管理したいソフトウェアの一覧。詳細は[installed-software.md](docs/installed-software.md)

`Makefile` の `setup` コマンドを実行することで、 **dotfiles** で管理するソフトウェアがインストールされ、それらの設定ファイルがマシン上に配置される．

## 実行前準備
以下のソフトウェアはマシンのOSによってインストール方法が異なっていたり、容量食いだったりするため、`make install` の管理外としている。
そのため、手動でインストールする必要がある。
参考になるWebサイトのURLを添付しておく。

| `make install`管理外ソフトウェア | 参考サイト                            |
| homebrew                         | https://brew.sh/ja/                   |
| emacs / spacemacs                | https://github.com/syl20bnr/spacemacs |
| docker                           | どこにでもある                        |


- `chsh -s <zshへのパス>` が必要になる場合がある
- 現在のログインシェルを判定できない場合や非対話環境などで `chsh` を実行できない場合は、警告を表示して処理を継続する

また、一部のソフトウェアはインストールだけでは動作しない場合があり、権限などの設定を適切に行う必要がある。
この設定については、[installed-software.md](docs/installed-software.md)で詳しく説明している。

## dotfilesを展開する方法
`Makefile` には以下のコマンドが用意されている。基本的には、 **##実行前準備**を済ませた状態で `make setup` を実行することでうまく行く。
- Brewfileに記載されたソフトウェアの一括インストール => `make install`
- configsに保存された設定ファイルへのリンク生成 => `make set-link`
- 上記2つをいっぺんに -> `make setup`

## 運用
- 新しいソフトを管理したい場合は `Brewfile` に追加
- 新しい設定は `configs/` に保存
- リモートの設定変更を反映する際は基本的に`make setup`で問題ないはず
- `make set-link` は既存ファイルやsymlinkを自動削除しない
- `make set-link` の衝突判定や対処方針の詳細は複雑なので、 `docs/set-link.md` を参照

## bin実行コマンド詳細

### `texinit`

`texinit` は、空ディレクトリに対して Tex を実行するための一通りの環境をビルドするショートカット。
texのソースファイルや、pdfファイルの仮生成、`.latexmkrc`の生成などを行ってくれる。
生成テンプレート本体は `templates/texinit/` に分離して管理している。
実行可能なコマンドは以下の２つ。
- `texinit` ... ltjsarticle + LuaLaTeX 形式の Texソースを作成 -> pdfファイルの仮生成までやってくれる．授業レポートなどに便利
- `texinit --mylab` ... 研究室で使用する形式の Texソースを作成

## 開発タスク

- tmux, zsh関連のコピーリング同期
- magit + sqlite3 のバグ治す
