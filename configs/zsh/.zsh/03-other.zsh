# ========================================
# その他
# ========================================

# 基本的なエイリアス
alias vim='nvim'
alias vi='nvim'

# 環境変数
export DOTFILES_DIR="$HOME/dotfiles"
export EDITOR='nvim'

# rz コマンド：.zshrc をリロード
alias rz='source ~/.zshrc'

alias cdd='cd $DOTFILES_DIR'
alias cda='cd $HOME/adids'
alias x='codex'
alias enw='emacs -nw'

export FZF_DEFAULT_OPTS='
  --height 60%
  --reverse
  --border
  --inline-info
  --color=fg:#d0d0d0,bg:#121212,hl:#5f87af
  --color=fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff
  --color=info:#afaf87,prompt:#d7005f,pointer:#af5fff
  --color=marker:#87ff00,spinner:#af5fff,header:#87afaf
'

export FZF_CTRL_T_OPTS="
  --preview 'bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || cat {}'
  --preview-window=right:60%:wrap
"

# ez コマンド：fzf で設定ファイルを選択して編集
function ez() {
  local files=(
    ~/.zshrc
    ~/.zsh/*.zsh(N)
  )

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

# 補完機能の有効化
autoload -Uz compinit
compinit
