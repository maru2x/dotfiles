# SSH鍵の運用

## 鍵の構成

| ファイル | 用途 | 対応アカウント |
|---------|------|--------------|
| `~/.ssh/id_ed25519_sit` | 個人用の秘密鍵（デフォルト） | bp21071@shibaura-it.ac.jp |
| `~/.ssh/id_ed25519_techouse` | 会社用の秘密鍵（`techouse-inc` リポジトリ用） | shuji.murase@techouse.jp |

対応する `*.pub` は GitHub に登録する公開鍵であり、ローカルで署名するための実体ではない。

## Gitの設定

### 基本方針

- **デフォルトは個人用**: `~/.gitconfig` に個人用設定を記載する。
- **`techouse-inc` のリポジトリのみ会社用**: remote URL に `techouse-inc` が含まれるリポジトリだけ `~/.gitconfig-techouse` を読み込む。
- 条件付き include は `includeIf.hasconfig:remote.*.url` を使う。判定対象は `origin` に限らず、そのリポジトリに設定されている全 remote URL。
- `git commit` は SSH 署名を使うが、`user.signingkey` は公開鍵ではなく秘密鍵を指す。したがって、ローカルの `git commit` 自体に `ssh-agent` は必須ではない。
- 会社用鍵は `techouse-inc` リポジトリを扱うときだけ必要であり、個人用リポジトリや `dotfiles` の利用には必須ではない。

### `~/.gitconfig`（dotfiles管理）

```gitconfig
# デフォルト設定（個人用）
[core]
    sshCommand = ssh -i ~/.ssh/id_ed25519_sit -o IdentitiesOnly=yes

[user]
    name = shujimurase
    email = bp21071@shibaura-it.ac.jp
    signingkey = ~/.ssh/id_ed25519_sit

[gpg]
    format = ssh
[commit]
    gpgsign = true

# techouse-inc のリポジトリのみ会社用設定を使用（必ず末尾に置く）
[includeIf "hasconfig:remote.*.url:git@github.com:techouse-inc/**"]
    path = ~/.gitconfig-techouse
[includeIf "hasconfig:remote.*.url:ssh://git@github.com/techouse-inc/**"]
    path = ~/.gitconfig-techouse
[includeIf "hasconfig:remote.*.url:https://github.com/techouse-inc/**"]
    path = ~/.gitconfig-techouse
```

### `~/.gitconfig-techouse`（dotfiles管理）

```gitconfig
[core]
    sshCommand = ssh -i ~/.ssh/id_ed25519_techouse

[user]
    name = shujimurase
    email = shuji.murase@techouse.jp
    signingkey = ~/.ssh/id_ed25519_techouse
```

このファイルは `configs/git/.gitconfig-techouse` として dotfiles で管理し、`scripts/set-link.sh` で `~/.gitconfig-techouse` にリンクする。

### `~/.ssh/config`（dotfiles管理）

```sshconfig
# Common SSH routing managed by dotfiles.
# Put machine-specific overrides in ~/.ssh/config.local.
Host github.com
    HostName ssh.github.com
    Port 443
    User git

Include ~/.ssh/config.local
```

このファイルは `configs/ssh/.ssh/config` として dotfiles で管理し、`scripts/set-link.sh` で `~/.ssh/config` にリンクする。マシン固有の SSH 設定は `~/.ssh/config.local` に分離する。

## ローカル署名・GitHub認証・Verified の違い

### ローカルで `git commit` を成功させる条件

- 対応する秘密鍵ファイルが手元にあること。
- `~/.gitconfig` / `~/.gitconfig-techouse` がリンクされていること。
- `ssh-agent` は必須ではない。agent がない場合は、秘密鍵のパスフレーズ入力がその都度必要になることがある。

### GitHub に `push` / `pull` する条件

- 対象 GitHub アカウントに対応する `*.pub` を **Authentication key** として登録してあること。
- `core.sshCommand` が選んだ秘密鍵と `~/.ssh/config` の接続先設定で GitHub に接続できること。

### GitHub 上で `Verified` を出す条件

- 対応する `*.pub` を GitHub に **Signing key** としても登録してあること。
- これは GitHub 上の表示要件であり、ローカルで `git commit` を成功させるための必須条件ではない。

## SSH / SSH Agent の考え方

- Git の接続先は `~/.ssh/config` で管理する。dotfiles では `github.com` を `ssh.github.com:443` に向ける。
- Git の鍵選択は `core.sshCommand` で明示する。個人用/会社用の切り替えは `~/.gitconfig` / `~/.gitconfig-techouse` 側で行う。
- `configs/ssh/.ssh/config` は `Include ~/.ssh/config.local` を含むため、マシン固有の SSH 設定は `~/.ssh/config.local` に分離できる。
- `configs/zsh/.zsh/04-ssh-agent.zsh` は対話シェルでのみ動作し、既存の `ssh-agent` を再利用し、なければ起動し、存在する鍵を `ssh-add` する。
- `ssh-agent` の役割は「秘密鍵のパスフレーズ入力を減らす」「GitHub 認証を楽にする」であり、ローカルの `git commit` 成立条件そのものではない。
- Bitwarden SSH Agent は使わない。

## 新しいマシンのセットアップ手順

### 1. 鍵ファイルの配置

```zsh
# 秘密鍵を ~/.ssh/ に配置（パーミッション設定も忘れずに）
chmod 600 ~/.ssh/id_ed25519_sit
chmod 600 ~/.ssh/id_ed25519_techouse 2>/dev/null || true
```

個人用のセットアップだけなら `id_ed25519_sit` があれば足りる。`id_ed25519_techouse` は会社用リポジトリを扱うときだけ必要。

既存の `~/.ssh/config` に手元固有の設定がある場合は、`make set-link` の前に `~/.ssh/config.local` へ移しておく。dotfiles で管理する `~/.ssh/config` は `~/.ssh/config.local` を `Include` する。

### 2. dotfiles の Git 設定をリンク

```zsh
cd ~/dotfiles
./scripts/set-link.sh
```

`~/.gitconfig` と `~/.gitconfig-techouse` と `~/.ssh/config` が作られることを確認する。その後、新しい shell を開く。

### 3. ローカルの `git commit` を確認する

```zsh
tmpdir="$(mktemp -d)"
git init "$tmpdir"
git -C "$tmpdir"   -c user.name="$(git config user.name)"   -c user.email="$(git config user.email)"   -c gpg.format=ssh   -c user.signingkey="$HOME/.ssh/id_ed25519_sit"   -c commit.gpgsign=true   commit --allow-empty -m "test signed commit"
git -C "$tmpdir" cat-file -p HEAD | sed -n '/^gpgsig /,/^$/p'
rm -rf "$tmpdir"
```

この確認は GitHub 側の設定なしでも実行できる。ここで `gpgsig -----BEGIN SSH SIGNATURE-----` が出れば、コミットに SSH 署名が入っている。失敗する場合はローカルの鍵か Git 設定に問題がある。

### 4. GitHub の Authentication key を登録する

- 個人 GitHub アカウントには `id_ed25519_sit.pub` を Authentication key として登録する。
- 会社用リポジトリを使う場合は、会社 GitHub アカウントに `id_ed25519_techouse.pub` を Authentication key として登録する。

### 5. GitHub 認証を確認する

```zsh
GIT_SSH_COMMAND='ssh -i ~/.ssh/id_ed25519_sit -o IdentitiesOnly=yes'   git ls-remote git@github.com:maru2x/dotfiles.git >/dev/null

GIT_SSH_COMMAND='ssh -i ~/.ssh/id_ed25519_techouse -o IdentitiesOnly=yes'   git ls-remote git@github.com:techouse-inc/CHCentral.git >/dev/null
```

後者は会社用鍵を持っている場合だけ確認すればよい。

### 6. GitHub の Signing key を登録する

GitHub 上で `Verified` を出したい場合は、各アカウントに対応する公開鍵を **Signing key** としても登録する。

- 個人 GitHub アカウント → `id_ed25519_sit.pub`
- 会社 GitHub アカウント → `id_ed25519_techouse.pub`

## トラブルシューティング

### `git commit` が失敗する

まずローカル設定と秘密鍵の有無を確認する。

```zsh
git config --show-origin --get gpg.format
git config --show-origin --get commit.gpgsign
git config --show-origin --get user.signingkey
ls -l ~/.ssh/id_ed25519_sit ~/.ssh/id_ed25519_sit.pub
```

パスフレーズ入力を毎回避けたい場合や、GUI 経由で起動した shell で `ssh-agent` が無効な場合は、新しい shell を開いてから次を確認する。

```zsh
ssh-add -l
ssh-add ~/.ssh/id_ed25519_sit
ssh-add ~/.ssh/id_ed25519_techouse 2>/dev/null || true
```

### `techouse-inc` リポジトリで会社メールが使われない

remote URL が `techouse-inc` を含む形になっているか確認する。`includeIf.hasconfig:remote.*.url` は remote URL を条件にしているため、remote が未設定のリポジトリでは会社用設定に切り替わらない。

```zsh
git remote -v
git config --show-origin --get-all user.email
git config --show-origin --get-all core.sshCommand
```

### `git push` が Permission denied になる

どの鍵で接続しているかを固定して確認する。

```zsh
GIT_SSH_COMMAND='ssh -i ~/.ssh/id_ed25519_sit -o IdentitiesOnly=yes'   git ls-remote git@github.com:maru2x/dotfiles.git

GIT_SSH_COMMAND='ssh -i ~/.ssh/id_ed25519_techouse -o IdentitiesOnly=yes'   git ls-remote git@github.com:techouse-inc/CHCentral.git
```

これが失敗するなら、対象 GitHub アカウントに対応する `*.pub` が Authentication key として登録されているか確認する。

### GitHub で `Verified` にならない

公開鍵が Signing key として登録されているか確認する。Authentication key と Signing key は別用途なので、前者だけでは `Verified` にはならない。
