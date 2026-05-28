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

# fzf - bck-i-search（ターミナルの履歴管理ソフト）
eval "$(fzf --zsh)"

# Ctrl+T / Alt+C のデフォルトバインドを外して Ctrl+X に統一
bindkey -r '^T'
bindkey -r '\ec'

# ファイル中身のlivegrep検索（Ctrl+X s）
_fzf_fif_widget() {
  local result
  result=$(fzf --ansi --disabled \
    --bind 'change:reload:rg --line-number --no-heading --color=always {q} 2>/dev/null || true' \
    --delimiter=: \
    --preview 'bat --color=always {1} --highlight-line {2} 2>/dev/null || cat {1}' \
    --preview-window='right:60%:+{2}-5' \
    --prompt='grep> ')
  [[ -n "$result" ]] && LBUFFER+=$(echo "$result" | awk -F: '{print $1":"$2}')
  zle reset-prompt
}

fif() {
  if [[ -z "$1" ]]; then
    echo "Usage: fif <search_term>"
    return 1
  fi
  rg --line-number --no-heading --color=always "$@" \
    | fzf --ansi --delimiter=: \
          --preview 'bat --color=always {1} --highlight-line {2} 2>/dev/null || cat {1}' \
          --preview-window='right:60%:+{2}-5' \
    | awk -F: '{print $1":"$2}'
}

# git branch をfzfで選択してチェックアウト
_fzf_git_branch_widget() {
  local branch
  branch=$(git branch --all 2>/dev/null \
    | grep -v HEAD \
    | sed 's/^[ *]*//' \
    | sed 's|remotes/origin/||' \
    | sort -u \
    | fzf --preview 'git log --oneline --graph --color=always {1} 2>/dev/null | head -20')
  if [[ -n "$branch" ]]; then
    git checkout "$branch"
    zle reset-prompt
  fi
}

zle -N _fzf_fif_widget
zle -N fzf-file-widget
zle -N fzf-cd-widget
zle -N _fzf_git_branch_widget

# Ctrl+X * バインド
bindkey '^Xf' fzf-file-widget   # ファイル検索
bindkey '^Xd' fzf-cd-widget     # ディレクトリ移動
bindkey '^Xs' _fzf_fif_widget   # ファイル中身検索
bindkey '^Xg' _fzf_git_branch_widget  # git branch

