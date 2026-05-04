# ========================================
# fzf 設定
# ========================================
if [[ -o interactive ]] && [[ -t 0 ]] && [[ -t 1 ]] && command -v brew >/dev/null 2>&1; then
    brew_prefix="$(brew --prefix)"

    [ -f "$brew_prefix/opt/fzf/shell/completion.zsh" ] && source "$brew_prefix/opt/fzf/shell/completion.zsh"
    [ -f "$brew_prefix/opt/fzf/shell/key-bindings.zsh" ] && source "$brew_prefix/opt/fzf/shell/key-bindings.zsh"
fi

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
