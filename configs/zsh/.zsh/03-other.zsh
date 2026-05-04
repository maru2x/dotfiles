# ========================================
# その他
# ========================================

# 環境変数
export DOTFILES_DIR="$HOME/dotfiles"
export EDITOR='nvim'

# pyenv の初期化
if [ -d "$HOME/.pyenv" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

# User commands
[[ ":$PATH:" != *":$HOME/dotfiles/bin:"* ]] && export PATH="$HOME/dotfiles/bin:$PATH"

# Zeekのパス
export PATH=/opt/zeek/bin:$PATH

# コマンドラインは Emacs キーバインドを明示する
bindkey -e

# 補完候補の選択中だけ C-j/C-k で上下移動する
zmodload -i zsh/complist
bindkey -M menuselect '^J' down-line-or-history
bindkey -M menuselect '^K' up-line-or-history
