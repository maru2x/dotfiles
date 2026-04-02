# Zsh 設定ガイド

## ファイル構成

```
configs/zsh/
  .zshrc                  # エントリポイント（モジュール読み込み・tmux自動起動）
  .zsh/
    00-homebrew.zsh        # Homebrew PATH 設定
    01-ohmyzsh.zsh         # Oh My Zsh・プラグイン・p10k テーマ
    02-techouse.zsh        # Techouse固有設定（rbenv・AWS・プロジェクト）
    03-other.zsh            # エイリアス・環境変数・fzf・ez・compinit
```

## tmux

zsh 起動時に自動で tmux セッション `main` にアタッチします。

```bash
# セッションがなければ新規作成、あれば再接続
exec tmux new-session -A -s main
```

## 設定管理

```bash
ez      # fzf で設定ファイルを選択して編集
rz      # ~/.zshrc をリロード
cdd     # dotfiles ディレクトリへ移動
```

## fzf

| キー | 内容 |
|------|------|
| `Ctrl+T` | ファイル検索（bat プレビュー付き） |
| `Ctrl+R` | コマンド履歴検索 |
| `Alt+C` | ディレクトリ検索して移動 |

## エイリアス一覧

### 汎用

```bash
vim / vi        # nvim
```

### Docker

```bash
dc              # docker compose
dcud            # docker compose up -d
dcdu            # docker compose down && up -d
```

### Techouse プロジェクト

```bash
# ディレクトリ移動
cdw             # CHWorkforce
cdc             # CHCentral

# プロジェクト起動・停止
wup             # CHWorkforce 起動
cup             # CHCentral + CHWorkforce 起動
wdn             # CHWorkforce 停止
cdn             # 両プロジェクト停止

# SSH
sshneptune      # CHWorkforce 内部 Neptune
sshw            # CHWorkforce DB
sshci           # CHCentral int DB（AWS SSO）
sshcs           # CHCentral stg DB（AWS SSO）

# AWS
bed             # aws sso login (bedrock profile)
```
