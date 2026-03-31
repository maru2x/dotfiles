# ========================================
# fzf ユーティリティ
# ========================================

# ez コマンド：fzf で設定ファイルを選択して編集
function ez() {
  # 編集可能なファイルリストを生成
  local files=(
    ~/.zshrc
    ~/.zsh/*.zsh(N)  # (N) は該当ファイルがなくてもエラーにしない
  )

  # fzf で選択
  local selected=$(printf '%s\n' "${files[@]}" | \
    fzf --height 60% \
        --reverse \
        --prompt="編集するファイル: " \
        --preview 'bat --color=always --style=numbers {} 2>/dev/null || cat -n {}' \
        --preview-window=right:60%:wrap \
        --header='Enter: 編集 | Esc: キャンセル'
  )

  if [ -n "$selected" ]; then
    $EDITOR "$selected"
  fi
}
