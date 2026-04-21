# Zsh 設定ガイド

## ファイル構成

```
configs/zsh/
  .zshrc                  # エントリポイント（モジュール読み込み・tmux自動起動）
  .zsh/
    00-homebrew.zsh        # Homebrew PATH 設定 / pyenv 初期化
    01-ohmyzsh.zsh         # Oh My Zsh・プラグイン・p10k テーマ
    techouse.zsh           # Techouse固有設定（明示フラグ時のみ読み込み）
    03-other.zsh            # エイリアス・環境変数・fzf・ez・compinit
    04-ssh-agent.zsh       # ssh-agent の再利用・起動・鍵投入
```

## pyenv

`~/.pyenv` が存在する場合は `00-homebrew.zsh` で `pyenv` を初期化する。

```bash
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
```

`zsh` をメインで使う前提で、`pyenv install 3.11.11` と `pyenv local 3.11.11` を実行すれば、そのディレクトリでは `python` が 3.11 系を向く。

## tmux

zsh 起動時に自動で tmux セッション `main` にアタッチします。

```bash
# セッションがなければ新規作成、あれば再接続
exec tmux new-session -A -s main
```

## Techouse 設定

`configs/zsh/.zsh/techouse.zsh` は常時ロードではなく、次の 2 条件が揃ったときだけ読み込みます。

```bash
[ -f "$HOME/.config/techouse/enabled" ] && [ -f ~/.zsh/techouse.zsh ]
```

会社用設定を有効にしたい端末だけで次を実行します。

```bash
mkdir -p ~/.config/techouse
touch ~/.config/techouse/enabled
```

無効化したい場合はフラグファイルを削除します。

```bash
rm -f ~/.config/techouse/enabled
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
