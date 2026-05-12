# tmux 設定ガイド

## 基本方針

- prefix は `Ctrl-Space`
- copy mode は vi 系
- pane 移動は `h/j/k/l`
- system clipboard は helper script 経由で扱う
- window を閉じたら番号は前から自動で詰める

## window 番号の詰め直し

`~/.tmux.conf` では次を有効にしている。

```tmux
set -g renumber-windows on
```

このため window を削除すると空き番号は残さず、前から詰めて振り直される。

## pane の join / send

既存 pane を別 window 間で移動したいとき用に、次の binding を追加している。

- `Prefix + J`
  他 window の pane を現在 window に取り込む
- `Prefix + s`
  現在 pane を別 window へ送る

どちらも最初に `display-panes` を出すので、pane ID を見ながら入力できる。

入力例:

- `%1`
- `%2`
- `:.1`
- `:2.0`

## 既存の主要 key

- `Prefix + /` 水平分割
- `Prefix + -` 垂直分割
- `Prefix + h/j/k/l` pane 移動
- `Prefix + v` copy mode
- `Prefix + p` system clipboard から現在 pane へ paste
- `Prefix + r` 設定再読込
