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

# 補完機能の有効化
# ========================================
autoload -Uz compinit
compinit
