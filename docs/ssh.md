# SSH / GitHub 運用ガイド

## 概要

この dotfiles では、GitHub への接続は **SSH 前提** で運用する。

- GitHub の transport 認証は HTTPS ではなく SSH を使う
- Git の鍵選択は `~/.gitconfig` / `~/.gitconfig-techouse` で行う
- `~/.ssh/config` は GitHub を `ssh.github.com:443` にルーティングする
- `ssh-agent` はパスフレーズ入力を減らすための補助として使う
- Git commit の署名にも SSH 鍵を使う

この設計では責務を分けている。

1. Git: この repo でどの鍵を使うかを決める
2. OpenSSH: GitHub にどう接続するかを決める
3. `ssh-agent`: 鍵をメモリに載せて再入力を減らす

## この dotfiles で管理しているファイル

| ファイル | 役割 |
|---------|------|
| `~/.gitconfig` | 個人用のデフォルト Git 設定。個人鍵を使い、SSH 署名も有効化する |
| `~/.gitconfig-techouse` | `techouse-inc` リポジトリ用の Git 設定。会社鍵に切り替える |
| `~/.ssh/config` | GitHub を `ssh.github.com:443` に向ける共通 SSH 設定 |
| `~/.ssh/config.local` | マシン固有の SSH 設定置き場。dotfiles 管理外 |
| `~/.zsh/04-ssh-agent.zsh` | 対話シェルで `ssh-agent` を再利用または起動し、鍵を `ssh-add` する |

## 鍵の構成

| ファイル | 用途 | 対応アカウント |
|---------|------|--------------|
| `~/.ssh/id_ed25519_sit` | 個人用の秘密鍵 | bp21071@shibaura-it.ac.jp |
| `~/.ssh/id_ed25519_techouse` | 会社用の秘密鍵 | shuji.murase@techouse.jp |

- `*.pub` は公開鍵であり、GitHub に登録する
- `user.signingkey` は公開鍵ではなく **秘密鍵** を指す
- 会社用鍵は `techouse-inc` リポジトリを使うときだけ必要

## 階層構造

### 1. Git 層: 鍵を選ぶ

通常の repo では `~/.gitconfig` が有効になり、個人鍵を使う。

```gitconfig
[core]
    sshCommand = ssh -i ~/.ssh/id_ed25519_sit -o IdentitiesOnly=yes

[user]
    email = bp21071@shibaura-it.ac.jp
    signingkey = ~/.ssh/id_ed25519_sit
```

`techouse-inc` を含む remote URL の repo では `includeIf` により `~/.gitconfig-techouse` が追加で読み込まれ、会社鍵に切り替わる。

```gitconfig
[core]
    sshCommand = ssh -i ~/.ssh/id_ed25519_techouse -o IdentitiesOnly=yes

[user]
    email = shuji.murase@techouse.jp
    signingkey = ~/.ssh/id_ed25519_techouse
```

重要なのは、**鍵の選択は `~/.ssh/config` ではなく Git 側でやっている** こと。

### 2. OpenSSH 層: GitHub への経路を決める

`~/.ssh/config` は GitHub への接続先だけを管理する。

```sshconfig
Host github.com
    HostName ssh.github.com
    Port 443
    User git

Include ~/.ssh/config.local
```

このファイルは `configs/ssh/.ssh/config` として dotfiles で管理し、`scripts/set-link.sh` で `~/.ssh/config` にリンクする。

ここでは鍵を固定しない。役割は次の 2 つだけ。

- `github.com` を `ssh.github.com:443` に向ける
- マシン固有設定を `~/.ssh/config.local` に逃がせるようにする

### 3. `ssh-agent` 層: 利便性を担う

`~/.zsh/04-ssh-agent.zsh` は対話シェルでのみ動作する。

- 既存の `ssh-agent` が使えれば再利用する
- 使えなければ新規に起動する
- 個人鍵と会社鍵が存在すれば `ssh-add` する

これは transport や鍵選択の本体ではない。agent が無くても、秘密鍵ファイルがあれば Git 接続や SSH 署名はできる。ただしパスフレーズ入力は増える。

## 実際の動作

### 個人用 repo

- remote が `git@github.com:...` の形である
- `~/.gitconfig` が使われる
- 個人鍵 `id_ed25519_sit` で接続する
- commit 署名にも個人鍵を使う

### `techouse-inc` repo

- remote URL に `techouse-inc` が含まれる
- `~/.gitconfig-techouse` が追加で読み込まれる
- 会社鍵 `id_ed25519_techouse` で接続する
- commit 署名にも会社鍵を使う

### 直接 `ssh github.com` した場合

repo ごとの鍵選択は Git の `core.sshCommand` でやっているため、手で `ssh github.com` を打つ場合は repo 文脈がない。

- 接続先は `ssh.github.com:443` になる
- どの鍵を使うかを明示したい場合は `-i` を付ける

GitHub 向けの手動確認は次のように行う。

```zsh
ssh -i ~/.ssh/id_ed25519_sit -o IdentitiesOnly=yes -T git@github.com
ssh -i ~/.ssh/id_ed25519_techouse -o IdentitiesOnly=yes -T git@github.com
```

## セットアップ手順

### 1. 秘密鍵を配置する

```zsh
mkdir -p ~/.ssh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519_sit
chmod 600 ~/.ssh/id_ed25519_techouse 2>/dev/null || true
```

個人用だけなら `id_ed25519_sit` があれば足りる。会社用鍵は必要になった時点で追加すればよい。

### 2. dotfiles のリンクを張る

```zsh
cd ~/dotfiles
./scripts/set-link.sh
```

次のファイルが作られることを確認する。

- `~/.gitconfig`
- `~/.gitconfig-techouse`
- `~/.ssh/config`

### 3. 必要なら `~/.ssh/config.local` を作る

`~/.ssh/config.local` は dotfiles 管理外のファイル。例えば次の用途に使う。

- 社内踏み台や個人サーバの host 定義
- マシン固有の `IdentityFile`
- 一時的な override

例:

```sshconfig
Host my-server
    HostName example.com
    User mnl
    IdentityFile ~/.ssh/id_ed25519_personal
```

### 4. 新しい shell を開く

新しい対話シェルを開くと `ssh-agent` の初期化が走り、存在する鍵があれば `ssh-add` される。

```zsh
ssh-add -l
```

## GitHub 側で必要な登録

### Authentication key

GitHub に `push` / `pull` するには、対応する `*.pub` を GitHub に **Authentication key** として登録する。

- 個人アカウント: `id_ed25519_sit.pub`
- 会社アカウント: `id_ed25519_techouse.pub`

### Signing key

GitHub 上で commit を `Verified` 表示にしたい場合は、同じ公開鍵を **Signing key** としても登録する。

- Authentication key と Signing key は別用途
- 前者だけでは `Verified` にはならない

## 使い方

### 新しい repo を clone するとき

GitHub repo は SSH 形式で clone する。

```zsh
git clone git@github.com:maru2x/dotfiles.git
git clone git@github.com:techouse-inc/CHCentral.git
```

HTTPS 形式を前提にした credential helper はこの dotfiles では使わない。

### repo でどの鍵が選ばれているか確認する

```zsh
git config --show-origin --get core.sshCommand
git config --show-origin --get user.email
git config --show-origin --get user.signingkey
```

### 認証を確認する

```zsh
GIT_SSH_COMMAND='ssh -i ~/.ssh/id_ed25519_sit -o IdentitiesOnly=yes'   git ls-remote git@github.com:maru2x/dotfiles.git >/dev/null

GIT_SSH_COMMAND='ssh -i ~/.ssh/id_ed25519_techouse -o IdentitiesOnly=yes'   git ls-remote git@github.com:techouse-inc/CHCentral.git >/dev/null
```

### 署名付き commit を確認する

```zsh
tmpdir="$(mktemp -d)"
git init "$tmpdir"
git -C "$tmpdir"   -c user.name="$(git config user.name)"   -c user.email="$(git config user.email)"   -c gpg.format=ssh   -c user.signingkey="$HOME/.ssh/id_ed25519_sit"   -c commit.gpgsign=true   commit --allow-empty -m "test signed commit"
git -C "$tmpdir" cat-file -p HEAD | sed -n '/^gpgsig /,/^$/p'
rm -rf "$tmpdir"
```

`gpgsig -----BEGIN SSH SIGNATURE-----` が見えれば、ローカルでは SSH 署名できている。

## トラブルシューティング

### `techouse-inc` repo なのに会社鍵にならない

remote URL に `techouse-inc` が含まれているか確認する。

```zsh
git remote -v
git config --show-origin --get-all core.sshCommand
git config --show-origin --get-all user.email
```

`includeIf.hasconfig:remote.*.url` は remote URL で判定するため、remote が未設定だと会社用設定には切り替わらない。

### `git push` / `pull` が Permission denied になる

まず鍵を固定して疎通確認する。

```zsh
ssh -i ~/.ssh/id_ed25519_sit -o IdentitiesOnly=yes -T git@github.com
ssh -i ~/.ssh/id_ed25519_techouse -o IdentitiesOnly=yes -T git@github.com
```

失敗する場合は次を確認する。

- 対応する公開鍵が GitHub に Authentication key として登録されているか
- 秘密鍵ファイルのパーミッションが適切か
- `~/.ssh/config` がリンクされているか

### `git commit` が失敗する

SSH 署名の設定と鍵ファイルを確認する。

```zsh
git config --show-origin --get gpg.format
git config --show-origin --get commit.gpgsign
git config --show-origin --get user.signingkey
ls -l ~/.ssh/id_ed25519_sit ~/.ssh/id_ed25519_sit.pub
```

agent を使いたい場合は次も確認する。

```zsh
ssh-add -l
ssh-add ~/.ssh/id_ed25519_sit
ssh-add ~/.ssh/id_ed25519_techouse 2>/dev/null || true
```

### `Verified` にならない

対応する `*.pub` が GitHub に **Signing key** として登録されているか確認する。Authentication key の登録だけでは足りない。
