# SSH鍵の運用

## 鍵の構成

| ファイル | 用途 | 対応アカウント |
|---------|------|--------------|
| `~/.ssh/id_ed25519_techouse` | 会社用（デフォルト） | shuji.murase@techouse.jp |
| `~/.ssh/id_ed25519_sit` | 個人用 | bp21071@shibaura-it.ac.jp |

## Gitの設定

### 基本方針

- **デフォルトは会社用**：`~/.gitconfig` に会社用設定を記載
- **`~/dotfiles/` 内のみ個人用**：`~/.gitconfig-personal` で上書き（`[includeIf]` を末尾に置くことで正しく上書きが効く）

### `~/.gitconfig`（dotfiles管理）

```gitconfig
# デフォルト設定（会社用）
[core]
    sshCommand = ssh -i ~/.ssh/id_ed25519_techouse -o IdentitiesOnly=yes -F /dev/null

[user]
    name = shujimurase
    email = shuji.murase@techouse.jp
    signingkey = ssh-ed25519 <id_ed25519_techouseの公開鍵>

[gpg]
    format = ssh
[commit]
    gpgsign = true

# dotfilesディレクトリのみ個人用鍵を使用（必ず末尾に置く）
[includeIf "gitdir:~/dotfiles/"]
    path = ~/.gitconfig-personal
```

### `~/.gitconfig-personal`（dotfiles管理外・手動配置）

```gitconfig
[core]
    sshCommand = ssh -i ~/.ssh/id_ed25519_sit -o IdentitiesOnly=yes -F /dev/null

[user]
    name = shujimurase
    email = bp21071@shibaura-it.ac.jp
    signingkey = ssh-ed25519 <id_ed25519_sitの公開鍵>
```

このファイルはdotfilesリポジトリに含めず、各マシンに手動で配置する。

## SSH Agentの設定

macOS Keychainを使用する。`~/.ssh/config` に以下を設定済み：

```
Host *
    AddKeysToAgent yes
    UseKeychain yes
```

**Bitwarden SSH Agentは使用しない**（過去に試みたが廃止）。

## 新しいマシンのセットアップ手順

### 1. 鍵ファイルの配置

```zsh
# 鍵ファイルを ~/.ssh/ に配置（パーミッション設定も忘れずに）
chmod 600 ~/.ssh/id_ed25519_techouse
chmod 600 ~/.ssh/id_ed25519_sit
```

### 2. SSH AgentへKeychainに鍵を登録

```zsh
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_techouse
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_sit

# 登録確認
ssh-add -l
```

以後は再起動後も Keychain から自動ロードされる。

### 3. `~/.gitconfig-personal` の手動作成

```zsh
cat > ~/.gitconfig-personal << 'EOF'
[core]
    sshCommand = ssh -i ~/.ssh/id_ed25519_sit -o IdentitiesOnly=yes -F /dev/null

[user]
    name = shujimurase
    email = bp21071@shibaura-it.ac.jp
    signingkey = ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEV8oI7hSONvKxaKhx5TCPbq1sqc8WLN85Bdga4e9VAm
EOF
```

### 4. 動作確認

```zsh
# 会社GitHubへの接続確認
ssh -T git@github.com

# dotfilesディレクトリ内で個人設定が使われているか確認
cd ~/dotfiles
git config user.email   # => bp21071@shibaura-it.ac.jp になること

# 会社リポジトリで会社設定が使われているか確認
cd ~/work/some-company-repo
git config user.email   # => shuji.murase@techouse.jp になること
```

### 5. GitHubへの署名鍵の登録

コミット署名（`gpgsign = true`）が機能するには、各GitHubアカウントに公開鍵を「Signing key」として登録する必要がある。

- 会社GitHubアカウント → `id_ed25519_techouse.pub` を Signing key として登録
- 個人GitHubアカウント → `id_ed25519_sit.pub` を Signing key として登録

## トラブルシューティング

### コミット署名が失敗する

SSH agentに鍵が登録されていない可能性が高い。

```zsh
ssh-add -l  # "The agent has no identities." が表示されたら未登録
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_techouse
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_sit
```

### dotfilesで個人メールが使われない

`~/.gitconfig-personal` が存在しないか、`~/.gitconfig` の `[includeIf]` が末尾にない。
`[includeIf]` は**必ず `.gitconfig` の末尾**に記述すること（上書きの順序の問題）。

### git pushがPermission deniedになる

`ssh -T git@github.com` で接続確認。エラーが出る場合、対象アカウントに `id_ed25519_techouse.pub` または `id_ed25519_sit.pub` が Authentication key として登録されているか確認する。
