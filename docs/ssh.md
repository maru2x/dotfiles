# SSH鍵とGit設定の運用ガイド

このリポジトリでは、個人用（SIT）と会社用（Techouse）の環境を、ディレクトリやリポジトリURLに応じて自動で切り替える運用を採用しています。

## 1. 設定ファイルの役割

運用の基盤となる3つの設定ファイルの役割は以下の通りです。

| 設定ファイル                | 役割                                                                                                   |
|:----------------------------|:-------------------------------------------------------------------------------------------------------|
| **`~/.ssh/config`**         | **「ssh鍵自体の全体設定」を担当**。ssh接続でどの鍵をどういう順番で使うのか、など                       |
| **`~/.gitconfig`**          | **「git接続のデフォルト設定と使い分け」を担当**。デフォルトの接続方式や、techouse鍵への切り替え条件など。                                      |
| **`~/.gitconfig-techouse`** | **「会社用の上書き」を担当**。会社リポジトリでのみ使用するメールアドレスや会社用の署名鍵を定義します。 |

## 2. 鍵の構成と対応表

| 秘密鍵ファイル | 対応アカウント（Email） | 用途 |
|:---|:---|:---|
| `~/.ssh/id_ed25519_sit` | `bp21071@shibaura-it.ac.jp` | 個人用（デフォルト） |
| `~/.ssh/id_ed25519_techouse` | `shuji.murase@techouse.jp` | 会社用（Techouseリポジトリ） |

## 3. セットアップ手順

### Step 1: 鍵ファイルの配置と権限設定
鍵ファイルを `~/.ssh/` ディレクトリに配置し、適切な権限を設定します。

```zsh
chmod 600 ~/.ssh/id_ed25519_sit
chmod 600 ~/.ssh/id_ed25519_techouse
```

### Step 2: 鍵をエージェントに登録
パスフレーズの再入力を省略するため、エージェントに鍵を登録します。

#### macOSの場合（キーチェーン連携）
```zsh
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_sit
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_techouse
```

#### Linuxの場合
標準的な `ssh-add` を使用します。
```zsh
ssh-add ~/.ssh/id_ed25519_sit
ssh-add ~/.ssh/id_ed25519_techouse
```
※ Linuxで再起動後も保持したい場合は、`.zshrc` 等に `ssh-add` を記述するか、`gnome-keyring` 等のマネージャーを利用してください。

### Step 3: dotfilesのリンク
```zsh
./scripts/set-link.sh
```

## 4. 正常動作の確認方法

### SSH接続のテスト
```zsh
ssh -T git@github.com
# "Hi shujimurase!" と表示されれば認証成功です
```

### Git設定の自動切り替え確認
```zsh
# 1. 個人用リポジトリ（~/dotfiles など）
git config user.email  # => bp21071@shibaura-it.ac.jp

# 2. 会社用リポジトリ（~/workspace/ 配下）
cd ~/workspace/CHWorkforce
git config user.email  # => shuji.murase@techouse.jp
```

## 5. 困ったときは

### 認証エラー（Permission denied）が出る
SSHエージェントに鍵が読み込まれているか確認してください。
```zsh
ssh-add -l
```

### 会社用設定が反映されない
リポジトリが `~/workspace/` ディレクトリ配下に置かれているか確認してください。
```gitconfig
[includeIf "gitdir:~/workspace/"]
    path = ~/.gitconfig-techouse
```
