# ========================================
# clipboard integration for zle
# ========================================

if [[ -o interactive && -o zle ]]; then
  typeset -g DOTFILES_CLIPBOARD_COPY_COMMAND="${DOTFILES_DIR:-$HOME/dotfiles}/bin/clipboard-copy"
  typeset -g DOTFILES_CLIPBOARD_PASTE_COMMAND="${DOTFILES_DIR:-$HOME/dotfiles}/bin/clipboard-paste"

  dotfiles_copy_cutbuffer_to_system_clipboard() {
    [[ -n "${CUTBUFFER:-}" ]] || return 0
    [[ -x "$DOTFILES_CLIPBOARD_COPY_COMMAND" ]] || return 0
    print -rn -- "$CUTBUFFER" | "$DOTFILES_CLIPBOARD_COPY_COMMAND" >/dev/null 2>&1 || return 0
  }

  dotfiles_load_system_clipboard_to_cutbuffer() {
    [[ -x "$DOTFILES_CLIPBOARD_PASTE_COMMAND" ]] || return 1

    local clipboard_text
    clipboard_text="$("$DOTFILES_CLIPBOARD_PASTE_COMMAND" 2>/dev/null)" || return 1
    CUTBUFFER="$clipboard_text"
  }

  dotfiles_zle_kill_line() {
    zle .kill-line
    dotfiles_copy_cutbuffer_to_system_clipboard
  }

  dotfiles_zle_kill_whole_line() {
    zle .kill-whole-line
    dotfiles_copy_cutbuffer_to_system_clipboard
  }

  dotfiles_zle_backward_kill_word() {
    zle .backward-kill-word
    dotfiles_copy_cutbuffer_to_system_clipboard
  }

  dotfiles_zle_kill_word() {
    zle .kill-word
    dotfiles_copy_cutbuffer_to_system_clipboard
  }

  dotfiles_zle_copy_region_as_kill() {
    zle .copy-region-as-kill
    dotfiles_copy_cutbuffer_to_system_clipboard
  }

  dotfiles_zle_yank_system_clipboard() {
    if dotfiles_load_system_clipboard_to_cutbuffer; then
      zle .yank
    else
      zle -M "system clipboard is unavailable"
    fi
  }

  zle -N dotfiles_zle_kill_line
  zle -N dotfiles_zle_kill_whole_line
  zle -N dotfiles_zle_backward_kill_word
  zle -N dotfiles_zle_kill_word
  zle -N dotfiles_zle_copy_region_as_kill
  zle -N dotfiles_zle_yank_system_clipboard

  bindkey '^K' dotfiles_zle_kill_line
  bindkey '^U' dotfiles_zle_kill_whole_line
  bindkey '^W' dotfiles_zle_backward_kill_word
  bindkey '\ed' dotfiles_zle_kill_word
  bindkey '\ew' dotfiles_zle_copy_region_as_kill
  bindkey '^Y' dotfiles_zle_yank_system_clipboard
fi
