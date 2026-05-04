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


  # 追加の補完ディレクトリは compinit より前に登録する
  if [ -d "$HOME/.docker/completions" ]; then
    fpath=("$HOME/.docker/completions" $fpath)
  fi

  source "$ZSH/oh-my-zsh.sh"

  # brew でインストールしたプラグインを直接ロード
  if command -v brew >/dev/null 2>&1; then
    brew_prefix="$(brew --prefix)"

    [ -f "$brew_prefix/share/powerlevel10k/powerlevel10k.zsh-theme" ] && \
      source "$brew_prefix/share/powerlevel10k/powerlevel10k.zsh-theme"
    [ -f "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
      source "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    [ -f "$brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
      source "$brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    [ -f "$brew_prefix/share/zsh-you-should-use/you-should-use.plugin.zsh" ] && \
      source "$brew_prefix/share/zsh-you-should-use/you-should-use.plugin.zsh"
  fi
fi
