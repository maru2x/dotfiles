# Zsh 設定ガイド

## ファイル構成

```text
configs/zsh/
  .zshrc                   # エントリポイント（secrets / モジュール読込 / tmux 自動起動）
  .zsh/
    00-homebrew.zsh        # Homebrew PATH 設定 / pyenv 初期化
    01-ohmyzsh.zsh         # Oh My Zsh・プラグイン・p10k テーマ
    techouse.zsh           # Techouse 固有設定（明示フラグ時のみ読み込み）
    03-other.zsh           # エイリアス・環境変数・fzf・ez・compinit
    04-ssh-agent.zsh       # ssh-agent の再利用 / 起動 / 鍵の自動ロード
```

## 読み込み順

`~/.zshrc` は次の順で設定を読む。

1. p10k instant prompt
2. `~/.secrets.env`
3. `~/.zsh/*.zsh` を読む。ただし `techouse.zsh` はここでは除外する
4. `~/.config/techouse/enabled` があるときだけ `~/.zsh/techouse.zsh` を読む
5. `~/dotfiles-th/.zsh/*.zsh` があれば追加で読む
6. interactive TTY かつ tmux 外なら tmux 自動起動
7. `~/.p10k.zsh`

日常的な挙動の大半は `~/.zsh/*.zsh` 側で決まる。

## pyenv

`~/.pyenv` が存在する場合は `00-homebrew.zsh` で `pyenv` を初期化する。

```bash
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
```

`zsh` をメインで使う前提で、`pyenv install 3.11.11` と `pyenv local 3.11.11` を実行すれば、そのディレクトリでは `python` が 3.11 系を向く。

## SSH / ssh-agent

zsh 側の SSH 責務は **`ssh-agent` の利便性を担うことだけ** で、GitHub への経路や repo ごとの鍵選択はここでは行わない。

- `04-ssh-agent.zsh` は対話シェルでだけ動作する
- `~/.ssh/agent.env` が使えれば再利用し、無ければ `ssh-agent` を起動する
- `~/.ssh/id_ed25519_sit` と `~/.ssh/id_ed25519_techouse` が存在すれば `ssh-add` する
- 現在 agent に載っている鍵は `ssh-add -l` で確認できる

鍵選択と経路の責務分担は次のとおり。

- `~/.gitconfig` / `~/.gitconfig-techouse`: repo ごとの鍵選択
- `~/.ssh/config`: GitHub を `ssh.github.com:443` にルーティング
- `04-ssh-agent.zsh`: パスフレーズ再入力を減らすための補助

SSH 運用全体は [docs/ssh.md](./ssh.md) を参照する。

## tmux

interactive TTY で、tmux 外から zsh を起動した場合は自動で tmux セッション `main` にアタッチする。

```bash
# セッションがなければ新規作成、あれば再接続
exec tmux new-session -A -s main
```

非TTYの `zsh -i -c '...'` では tmux 自動起動を行わない。

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

- key-bindings と completion は interactive TTY のときだけ読み込む

| キー | 内容 |
|------|------|
| `Ctrl+T` | ファイル検索（bat プレビュー付き） |
| `Ctrl+R` | コマンド履歴検索 |
| `Alt+C` | ディレクトリ検索して移動 |

## エイリアス一覧

### 汎用

```bash
vim / vi        # nvim
x               # codex
enw             # emacs -nw
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
