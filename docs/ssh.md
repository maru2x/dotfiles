# SSH鍵とGit設定の運用ガイド

このリポジトリでは、個人用（SIT）と会社用（Techouse）の環境を、リポジトリのURLに応じて自動で切り替える運用を採用しています。

## 1. 設定ファイルの役割

運用の基盤となる3つの設定ファイルの役割は以下の通りです。

| 設定ファイル | 役割 |
|:---|:---|
| **`~/.ssh/config`** | **「ssh通信（鍵の選択）」を担当**。GitHub接続時に、エイリアスホスト等を見て適切な鍵を提示します。 |
| **`~/.gitconfig`** | **「条件判定とURL置換」を担当**。Techouse用のURLを検知して通信経路を書き換え、会社用設定を読み込みます。 |
| **`~/.gitconfig-techouse`** | **「会社用情報の上書き」を担当**。会社用メールアドレスや署名用の公開鍵を定義します。 |

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
パスフレーズ入力を省略するため、エージェントに登録します。

#### macOSの場合（キーチェーン連携）
```zsh
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_sit
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_techouse
```

#### Linuxの場合
```zsh
ssh-add ~/.ssh/id_ed25519_sit
ssh-add ~/.ssh/id_ed25519_techouse
```

### Step 3: dotfilesのリンク
```zsh
./scripts/set-link.sh
```

## 4. 自動切り替えの仕組み

この運用では、`git push/pull` 時のURLをトリガーに設定を自動変更します。

1.  **URL置換**: `git@github.com:techouse-inc/` への接続を検知すると、内部的に `git@github.com-techouse:techouse-inc/` へ書き換えます。
2.  **SSH鍵の強制**: `github.com-techouse` というホスト名に対し、SSH Configが会社用の鍵を強制的に割り当てます。
3.  **設定の読込**: 書き換わった後のURLを条件に、会社用の `user.email` 等をインクルードします。

## 5. 正常動作の確認方法

### SSH接続のテスト
```zsh
# 個人用
ssh -T git@github.com
# 会社用
ssh -T git@github.com-techouse
```

### Git設定の自動切り替え確認
リポジトリのURLに応じて `user.email` が変わることを確認してください。
```zsh
# 会社用リポジトリ内（URLに techouse-inc が含まれる場合）
git config --show-origin user.email
# => file:/Users/xxx/.gitconfig-techouse   shuji.murase@techouse.jp
```

## 6. 困ったときは

### 認証エラー（Permission denied）が出る
SSHエージェントに鍵が読み込まれているか確認してください。
```zsh
ssh-add -l
```

### 会社用設定が反映されない
メインの `.gitconfig` に以下の置換と判定ルールが正しく記述されているか確認してください。
```gitconfig
[url "git@github.com-techouse:techouse-inc/"]
    insteadOf = git@github.com:techouse-inc/

[includeIf "hasconfig:remote.*.url:git@github.com-techouse:techouse-inc/**"]
    path = ~/.gitconfig-techouse
```
