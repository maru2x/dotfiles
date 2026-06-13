# Zsh 設定ガイド

## ファイル構成

```text
configs/zsh/
  .zshrc                   # エントリポイント（secrets / モジュール読込 / tmux 自動起動）
  .zsh/
    00-homebrew.zsh        # Homebrew PATH 設定
    01-ohmyzsh.zsh         # Oh My Zsh・プラグイン・p10k テーマ
    02-alias.zsh           # エイリアス
    03-other.zsh           # 環境変数・pyenv・コマンドライン keybind
    04-ssh-agent.zsh       # ssh-agent の再利用 / 起動 / 鍵の自動ロード
    05-fzf.zsh             # fzf 設定
    06-p10k-kanagawa-dragon.zsh # tmux と揃えた Powerlevel10k 配色
    techouse.zsh           # Techouse 固有設定（明示フラグ時のみ読み込み）
```

## 読み込み順

`~/.zshrc` は次の順で設定を読む。

1. p10k instant prompt
2. `~/.secrets.env`
3. `~/.zsh/*.zsh` を読む。ただし `techouse.zsh` はここでは除外する
4. `~/.config/techouse/enabled` があるときだけ `~/.zsh/techouse.zsh` を読む
5. `~/dotfiles-th/.zsh/*.zsh` があれば追加で読む
6. interactive TTY かつ tmux 外なら tmux 自動起動

日常的な挙動の大半は `~/.zsh/*.zsh` 側で決まる。

## カラーテーマ

Powerlevel10k、zsh-autosuggestions、zsh-syntax-highlighting は tmux と同じ
Kanagawa Dragon パレットを使う。

- ディレクトリ: `dragonBlue2`
- Git clean: `dragonGreen`
- Git modified / untracked: `dragonYellow`
- 時刻・補助情報: `dragonAqua` / Dragon の gray 系

プロンプト設定は `06-p10k-kanagawa-dragon.zsh` で管理するため、ユーザー生成の
`~/.p10k.zsh` は読み込まない。

## PATH / pyenv

Homebrew の PATH は `00-homebrew.zsh` で扱う。

`~/.pyenv` が存在する場合は `03-other.zsh` で `pyenv` を初期化する。

```bash
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
```

`03-other.zsh` ではあわせて `~/.local/go/bin`, `~/go/bin`, `~/dotfiles/bin`, `/opt/zeek/bin` も PATH に加える。

Go はユーザー空間の `~/.local/go` に配置し、`~/go/bin` は `go install` したコマンドの置き場として PATH に加える。

## timezone

`03-other.zsh` では shell 起動時に次を設定する。

```bash
export DOTFILES_TIMEZONE="${DOTFILES_TIMEZONE:-Asia/Tokyo}"
export TZ="$DOTFILES_TIMEZONE"
```

- デフォルトは `Asia/Tokyo`
- 端末から起動した `emacs -nw` や各種 subprocess も同じ timezone を継承する
- 別 timezone を試したいときは `DOTFILES_TIMEZONE` を上書きする

## コマンドライン編集

全体の編集操作規約は [docs/editing.md](./editing.md) を参照する。

- 通常の zsh コマンドラインは `bindkey -e` で Emacs 系に固定する
- 補完候補の選択中だけ `Ctrl+j` / `Ctrl+k` で上下移動する
- 補完は Oh My Zsh の `compinit` を使う
- Docker 補完ディレクトリがあれば、`01-ohmyzsh.zsh` で `compinit` より前に `fpath` へ追加する

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
mkdir -p ~/.config/techouse
touch ~/.config/techouse/enabled
```

無効化したい場合はフラグファイルを削除します。

```bash
rm -f ~/.config/techouse/enabled
```

## 設定管理

```bash
zz      # ~/.zshrc をリロード
cdd     # dotfiles ディレクトリへ移動
cda     # ~/adids へ移動
cdac    # ~/adids/core へ移動
cdat    # ~/adids/testbed へ移動
cdae    # ~/adids/elk へ移動
cdap    # ~/adids/potter へ移動
cds     # ~/sanzu へ移動
cdss    # ~/sanzu/session-console へ移動
cdsr    # ~/sanzu/recon へ移動
cdsp    # ~/sanzu/passkey-lab へ移動
cdsa    # ~/sanzu/auth へ移動
```

## キーバインド一覧

### Emacs 移動・編集（標準）

| キー | 動作 |
|------|------|
| `Ctrl+A` | 行頭へ移動 |
| `Ctrl+E` | 行末へ移動 |
| `Ctrl+F` | 1文字右へ |
| `Ctrl+B` | 1文字左へ |
| `Ctrl+N` | 次の履歴 |
| `Ctrl+P` | 前の履歴 |
| `Ctrl+D` | 文字削除 / EOF |
| `Ctrl+K` | カーソル以降を削除 → システムclipboard |
| `Ctrl+U` | 行全体削除 → システムclipboard |
| `Ctrl+W` | 前の単語削除 → システムclipboard |
| `Ctrl+Y` | システムclipboardからペースト |

### 補完メニュー内

| キー | 動作 |
|------|------|
| `Ctrl+J` | 候補を下へ |
| `Ctrl+K` | 候補を上へ |

### fzf

key-bindings と completion は interactive TTY のときだけ読み込む。
`Ctrl+X` を fzf 拡張のプレフィックスに統一している。

| キー | 対象 | 動作 |
|------|------|------|
| `Ctrl+R` | 履歴 | fzf で検索 |
| `Ctrl+X f` | ファイル | パスをコマンドラインに挿入（bat プレビュー付き） |
| `Ctrl+X d` | ディレクトリ | fzf で選択して cd |
| `Ctrl+X s` | ファイル中身 | livegrep（fzf内でリアルタイム検索） |
| `Ctrl+X g` | git branch | fzf で選択して checkout |
| `<コマンド> **<Tab>` | ファイル/ディレクトリ | fzf 補完 |

`fif <キーワード>` でコマンドラインから中身検索することもできる。

## エイリアス一覧

### 汎用

```bash
vim / vi        # nvim
zz              # ~/.zshrc をリロード
zg              # lazygit
zd              # lazydocker
x               # codex
enw             # emacs -nw
```

### ディレクトリ移動

```bash
cdd             # ~/dotfiles
cda             # ~/adids
cdac            # ~/adids/core
cdat            # ~/adids/testbed
cdae            # ~/adids/elk
cdap            # ~/adids/potter
cds             # ~/sanzu
cdss            # ~/sanzu/session-console
cdsr            # ~/sanzu/recon
cdsp            # ~/sanzu/passkey-lab
cdsa            # ~/sanzu/auth
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
