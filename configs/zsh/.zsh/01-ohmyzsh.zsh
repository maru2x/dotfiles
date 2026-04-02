# =========================================
# Oh My Zsh 設定
# =========================================
if [ -d "$HOME/.oh-my-zsh" ]; then
  export ZSH="$HOME/.oh-my-zsh"

  ZSH_THEME=""  # powerlevel10k は brew から直接ロード

  # oh-my-zsh バンドル済みプラグインのみ指定
  plugins=(
    git
    rails
    z
  )

  source $ZSH/oh-my-zsh.sh

  # brew でインストールしたプラグインを直接ロード
  [ -f "$(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme" ] && \
    source "$(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme"
  [ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
    source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [ -f "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
    source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  [ -f "$(brew --prefix)/share/zsh-you-should-use/you-should-use.plugin.zsh" ] && \
    source "$(brew --prefix)/share/zsh-you-should-use/you-should-use.plugin.zsh"
fi

# p10k のプロンプト設定を読み込む（未作成ならスキップ）
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
