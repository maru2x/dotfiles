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

if [[ -o interactive ]] && [[ -t 0 ]] && [[ -t 1 ]] && command -v fzf >/dev/null 2>&1; then
  # fzf - bck-i-search（Ctrl+R）
  eval "$(fzf --zsh)"

  # Ctrl+T / Alt+C のデフォルトバインドを外して Ctrl+X に統一
  bindkey -r '^T'
  bindkey -r '\ec'

  # ========================================
  # bin/fzf-* スクリプトへの薄いラッパー
  # ========================================

  _fzf_file_widget() {
    local selected
    selected=$(fzf-file) || { zle reset-prompt; return 0; }
    [[ -z "$selected" ]] && zle reset-prompt && return 0
    LBUFFER+="$selected"
    zle reset-prompt
  }

  _fzf_dir_widget() {
    local dir
    dir=$(fzf-dir) || { zle reset-prompt; return 0; }
    [[ -z "$dir" ]] && zle reset-prompt && return 0
    builtin cd "$dir"
    zle reset-prompt
  }

  _fzf_git_branch_widget() {
    local branch
    branch=$(fzf-git-branch) || { zle reset-prompt; return 0; }
    [[ -z "$branch" ]] && zle reset-prompt && return 0
    git checkout "$branch"
    zle reset-prompt
  }

  _fzf_clipboard_history_widget() {
    local selected
    selected=$(fzf-clipboard) || { zle reset-prompt; return 0; }
    [[ -z "$selected" ]] && zle reset-prompt && return 0
    LBUFFER+="$selected"
    zle reset-prompt
  }

  _fzf_clipboard_paste_widget() {
    local content
    content=$(clipboard-paste 2>/dev/null) || { zle reset-prompt; return 0; }
    [[ -z "$content" ]] && zle reset-prompt && return 0
    LBUFFER+="$content"
    zle reset-prompt
  }

  # livegrep検索のみzsh内で維持（インタラクティブなreloadがZLE依存のため）
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
fi

fif() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is not installed"
    return 127
  fi

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

if [[ -o interactive ]] && [[ -t 0 ]] && [[ -t 1 ]] && command -v fzf >/dev/null 2>&1; then
  _keys_widget() {
    zle -I
    keys
    zle reset-prompt
  }

  zle -N _fzf_file_widget
  zle -N _fzf_dir_widget
  zle -N _fzf_git_branch_widget
  zle -N _fzf_clipboard_history_widget
  zle -N _fzf_clipboard_paste_widget
  zle -N _fzf_fif_widget
  zle -N _keys_widget

  # Ctrl+X * バインド（セカンドキーはtmuxのprefix+*と統一）
  bindkey '^Xf' _fzf_file_widget               # ファイル検索
  bindkey '^Xd' _fzf_dir_widget                # ディレクトリ移動
  bindkey '^Xs' _fzf_fif_widget                # ファイル中身検索
  bindkey '^Xg' _fzf_git_branch_widget         # git branch
  bindkey '^XP' _fzf_clipboard_history_widget  # クリップボード履歴
  bindkey '^Xp' _fzf_clipboard_paste_widget    # クリップボードから貼り付け
  bindkey '^Xh' _keys_widget                   # キーバインドヘルプ
fi
