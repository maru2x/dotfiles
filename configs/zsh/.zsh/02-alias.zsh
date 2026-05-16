# zsh上で使用するエイリアスを定義

# 基本的なエイリアス
alias vim='nvim'
alias vi='nvim'

# rz コマンド：.zshrc をリロード
alias zz='source ~/.zshrc'

# 移動ショートカット
alias cdd='cd $DOTFILES_DIR'
alias cda='cd $HOME/adids'
alias cdac='cd $HOME/adids/core'
alias cdat='cd $HOME/adids/testbed'
alias cdae='cd $HOME/adids/elk'
alias cdap='cd $HOME/adids/potter'

# アプリ起動ショートカット
alias x='codex'
alias enw='emacs -nw'
alias zg='lazygit'
alias zd='lazydocker'


# ========================================
# Docker Compose 用の短縮エイリアス
# ========================================

alias dc='docker compose'
alias dcud='docker compose up -d'
alias dcdu='docker compose down ; docker compose up -d'
