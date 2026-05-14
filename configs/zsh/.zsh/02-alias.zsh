# zsh上で使用するエイリアスを定義

# 基本的なエイリアス
alias vim='nvim'
alias vi='nvim'

# rz コマンド：.zshrc をリロード

alias zz='source ~/.zshrc'

alias cdd='cd $DOTFILES_DIR'
alias cda='cd $HOME/adids'
alias x='codex'
alias enw='emacs -nw'


# ========================================
# Docker Compose 用の短縮エイリアス
# ========================================

alias dc='docker compose'
alias dcud='docker compose up -d'
alias dcdu='docker compose down ; docker compose up -d'

