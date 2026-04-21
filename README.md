## Overview
- spacemacsを中心とした開発環境の設定ファイル群
- Debian, macでは動作確認済み

## Prerequisites
- Homebrew（`scripts/install.sh` 実行前に必要）
- GNU Stow（`scripts/set-link.sh` 実行前に必要）
- emacs / spacemacs / zsh / docker / docker-compose は別途インストール前提
  - windows版でemacsを入れる方法：
    - wslで `sudo apt update && sudo apt install emacs-gtk`を実行
    - 基本的にGUI版を想定している
  - spacemacsを入れる方法
    ```
        git clone https://github.com/syl20bnr/spacemacs $HOME/.emacs.d
    ```
    - `emacs.d`がすでに存在している場合は `rm` で削除
## Setup
- Brewfileに記載されたソフトウェアの一括インストール => `make install`
- configsに保存された設定ファイルへのリンク生成 => `make set-link`
- 上記2つをいっぺんに -> `make setup`

## Add or Update
- 新しいソフトを管理したい場合は `Brewfile` に追加
- 新しい設定は `configs/` に保存
- リモートの設定変更を反映する際は基本的に`make setup`で問題ないはず

## Structure
- `Brewfile`: brew管理したいソフトウェアの一覧
- `configs/`: stowでリンクする設定
- `scripts/`: installとset-linkの実行スクリプト
- `Makefile`: `install`/`set-link`/`setup`
- `docs/`: 運用ドキュメント

## Troubleshooting
- `brew bundle` が遅い場合は `make install` 実行時のログを確認
- `make set-link` は既存ファイルや親symlinkを自動削除しない。衝突が出たら手動で退避・整理してから再実行する
