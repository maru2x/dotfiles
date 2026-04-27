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

## 実行
`Makefile` には以下のコマンドが用意されている。基本的には、 **##実行前準備**を済ませた状態で `make setup` を実行することでうまく行く。
- Brewfileに記載されたソフトウェアの一括インストール => `make install`
- configsに保存された設定ファイルへのリンク生成 => `make set-link`
- 上記2つをいっぺんに -> `make setup`

## 運用
- 新しいソフトを管理したい場合は `Brewfile` に追加
- 新しい設定は `configs/` に保存
- リモートの設定変更を反映する際は基本的に`make setup`で問題ないはず

## bin実行コマンド詳細

