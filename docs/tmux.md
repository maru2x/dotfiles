# tmux 設定ガイド

## 基本方針

- prefix は `Ctrl-Space`
- copy mode は vi 系
- pane 移動は `h/j/k/l`
- system clipboard は helper script 経由で扱う
- window を閉じたら番号は前から自動で詰める
- window 名はカレントディレクトリ名で自動命名

## キーバインド一覧

### ペイン操作

| キー | 動作 |
|---|---|
| `Prefix + /` | 縦分割 |
| `Prefix + -` | 横分割 |
| `Prefix + h/j/k/l` | ペイン移動 |
| `Prefix + J` | 他ウィンドウのペインを現在ウィンドウに取り込む |
| `Prefix + s` | 現在ペインを別ウィンドウへ送る |
| `Prefix + r` | 設定再読み込み |

### クリップボード

| キー | 動作 |
|---|---|
| `Prefix + p` | システムクリップボードから現在ペインにペースト |
| `Prefix + P` | クリップボード履歴をfzfで選択してペースト |

### バッファ管理（Spacemacs SPC b * 相当）

| キー | 動作 |
|---|---|
| `Prefix + x` | 現在のペインをbgへ退避（外枠は新シェルで維持） |
| `Prefix + b` | bgのペイン一覧をfzfで表示 → 選択して現在位置にswap |
| `Prefix + X` | ペインを完全に削除（確認あり） |

bgウィンドウはセッション内の非表示バッファ領域。ユーザーが直接操作することはない。

### コピーモード

| キー | 動作 |
|---|---|
| `Prefix + C-Space` | コピーモード開始 |
| `Prefix + C-y` | コピーモード開始 + 上スクロール |
| `v` | ビジュアル選択 |
| `V` | 行選択 |
| `C-v` | 矩形選択 |
| `y` | ヤンク（OSクリップボード + tmux buffer） |
| `i` / `Esc` | コピーモード終了 |

## バッファ管理の仕組み

### bgウィンドウ

各セッションに `bg` という名前のウィンドウが自動作成される。`automatic-rename` は無効にして名前を固定し、常に末尾のウィンドウ番号へ移動する。

- セッション作成時: `set-hook session-created` から `tmux-ensure-bg-last` を実行して自動作成
- ウィンドウのリンク・リンク解除・選択変更後: `tmux-ensure-bg-last` で `bg` を末尾へ移動し、`bg` が選択された場合は通常ウィンドウへ戻る

### フォーマット展開の制約

`display-popup -E "cmd #{pane_id}"` はtmuxフォーマットを展開しない。このため以下の2段構えで値を渡している。

```
run-shell（#{} 展開が確実）
  → fzf-buffer-popup（tmux set-option に保存）
    → display-popup → fzf-buffer（tmux show-option で読む）
```

### prefix+x の動作

```
join-pane で現在ペインを bg ウィンドウへ物理移動
単一ペインの場合は先に split-window で後継ペインを作成
```

### prefix+b の動作

```
bg ウィンドウのペイン一覧を fzf で表示
選択されたペインと現在ペインを swap-pane -d で交換
```

## 関連スクリプト

| スクリプト | 役割 |
|---|---|
| `bin/fzf-buffer-popup` | prefix+b のラッパー。run-shell → display-popup への値の橋渡し |
| `bin/fzf-buffer` | bgペイン一覧をfzfで表示してswap |
| `bin/tmux-kill-buffer` | 現在ペインをjoin-paneでbgへ退避 |
| `bin/tmux-ensure-bg-last` | bgウィンドウを末尾のウィンドウ番号へ移動 |
| `bin/tmux-paste` | システムクリップボードをbracket pasteで貼り付け |

## window 番号の詰め直し

`set -g renumber-windows on` により、window を削除すると空き番号は残さず前から詰めて振り直される。

## pane の join / send

- `Prefix + J`: 他 window の pane を現在 window に取り込む
- `Prefix + s`: 現在 pane を別 window へ送る

どちらも最初に `display-panes` を出すので、pane ID を見ながら入力できる。

入力例: `%1` / `%2` / `:.1` / `:2.0`
