# =========================================
# Oh My Zsh 設定
# =========================================
if [ -d "$HOME/.oh-my-zsh" ]; then
  export ZSH="$HOME/.oh-my-zsh"

  ZSH_THEME=""  # powerlevel10k はパッケージ配置から直接ロード

  p10k_config_file="$HOME/.zsh/06-p10k-kanagawa-dragon.zsh"
  if [ -r "$p10k_config_file" ]; then
    typeset -g POWERLEVEL9K_CONFIG_FILE="$p10k_config_file"
  fi

  # oh-my-zsh バンドル済みプラグインのみ指定
  plugins=(
    git
    rails
    z
  )

  # Kanagawa Dragon palette for interactive helpers.
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#625956'
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  typeset -gA ZSH_HIGHLIGHT_STYLES
  ZSH_HIGHLIGHT_STYLES[default]='fg=#c5c9c5'
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#c4746e'
  ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#8992a7'
  ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#8ea4a2'
  ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#8ea4a2'
  ZSH_HIGHLIGHT_STYLES[precommand]='fg=#8ea4a2'
  ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#7a8382'
  ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=#8ba4b0'
  ZSH_HIGHLIGHT_STYLES[path]='fg=#8ba4b0'
  ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=#7a8382'
  ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#8ba4b0'
  ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]='fg=#7a8382'
  ZSH_HIGHLIGHT_STYLES[globbing]='fg=#8992a7'
  ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#c4b28a'
  ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#c4b28a'
  ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#c4b28a'
  ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#87a987'
  ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#87a987'
  ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#87a987'
  ZSH_HIGHLIGHT_STYLES[redirection]='fg=#8ea4a2'
  ZSH_HIGHLIGHT_STYLES[comment]='fg=#625956'


  # 追加の補完ディレクトリは compinit より前に登録する
  if [ -d "$HOME/.docker/completions" ]; then
    fpath=("$HOME/.docker/completions" $fpath)
  fi

  source "$ZSH/oh-my-zsh.sh"

  if command -v brew >/dev/null 2>&1; then
    brew_prefix="$(brew --prefix)"
  fi

  p10k_theme_candidates=()
  if [ -n "${brew_prefix:-}" ]; then
    p10k_theme_candidates+=("$brew_prefix/share/powerlevel10k/powerlevel10k.zsh-theme")
  fi
  p10k_theme_candidates+=(
    /home/linuxbrew/.linuxbrew/share/powerlevel10k/powerlevel10k.zsh-theme
    /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
    /usr/local/share/powerlevel10k/powerlevel10k.zsh-theme
    /usr/share/powerlevel10k/powerlevel10k.zsh-theme
    /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
    "$ZSH/custom/themes/powerlevel10k/powerlevel10k.zsh-theme"
  )

  for p10k_theme in "${p10k_theme_candidates[@]}"; do
    if [ -r "$p10k_theme" ]; then
      source "$p10k_theme"
      break
    fi
  done

  # パッケージ管理でインストールしたプラグインを直接ロード
  if [ -n "${brew_prefix:-}" ]; then
    [ -f "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
      source "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    [ -f "$brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
      source "$brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    [ -f "$brew_prefix/share/zsh-you-should-use/you-should-use.plugin.zsh" ] && \
      source "$brew_prefix/share/zsh-you-should-use/you-should-use.plugin.zsh"
  fi

  unset p10k_config_file p10k_theme p10k_theme_candidates brew_prefix
fi
