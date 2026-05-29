#!/usr/bin/env sh

clipboard_has_command() {
  command -v "$1" >/dev/null 2>&1
}

clipboard_command_path() {
  command -v "$1" 2>/dev/null || true
}

clipboard_has_tmux() {
  [ -n "${TMUX:-}" ] && command -v tmux >/dev/null 2>&1
}

clipboard_has_wayland() {
  [ -n "${WAYLAND_DISPLAY:-}" ] && [ -n "${XDG_RUNTIME_DIR:-}" ]
}

clipboard_has_x11() {
  [ -n "${DISPLAY:-}" ]
}

clipboard_running_in_wsl() {
  [ -n "${WSL_INTEROP:-}" ] || [ -n "${WSL_DISTRO_NAME:-}" ]
}

clipboard_debug() {
  if [ "${DOTFILES_CLIPBOARD_DEBUG:-0}" = "1" ]; then
    printf 'clipboard: %s\n' "$*" >&2
  fi
}

clipboard_backend_candidates() {
  mode="$1"
  requested="${DOTFILES_CLIPBOARD_BACKEND:-auto}"

  case "$requested" in
    "" | auto)
      printf '%s\n' "macos wsl wayland xclip xsel windows tmux"
      ;;
    x11)
      printf '%s\n' "xclip xsel"
      ;;
    macos | wayland | xclip | xsel | wsl | windows | tmux)
      printf '%s\n' "$requested"
      ;;
    none)
      printf '%s\n' ""
      ;;
    *)
      return 2
      ;;
  esac
}

clipboard_backend_override_valid() {
  case "${DOTFILES_CLIPBOARD_BACKEND:-auto}" in
    "" | auto | macos | wsl | wayland | x11 | xclip | xsel | windows | tmux | none)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

clipboard_backend_supported() {
  backend="$1"
  mode="$2"

  case "$backend:$mode" in
    macos:copy)
      clipboard_has_command pbcopy
      ;;
    macos:paste)
      clipboard_has_command pbpaste
      ;;
    wsl:copy)
      clipboard_running_in_wsl && clipboard_has_command powershell.exe
      ;;
    wsl:paste)
      clipboard_running_in_wsl && clipboard_has_command powershell.exe
      ;;
    wayland:copy)
      clipboard_has_wayland && clipboard_has_command wl-copy
      ;;
    wayland:paste)
      clipboard_has_wayland && clipboard_has_command wl-paste
      ;;
    xclip:copy | xclip:paste)
      clipboard_has_x11 && clipboard_has_command xclip
      ;;
    xsel:copy | xsel:paste)
      clipboard_has_x11 && clipboard_has_command xsel
      ;;
    windows:copy)
      clipboard_has_command powershell.exe
      ;;
    windows:paste)
      clipboard_has_command powershell.exe
      ;;
    tmux:copy | tmux:paste)
      clipboard_has_tmux
      ;;
    *)
      return 1
      ;;
  esac
}

clipboard_first_supported_backend() {
  mode="$1"
  candidate_list="$(clipboard_backend_candidates "$mode")" || return $?

  for backend in $candidate_list; do
    if clipboard_backend_supported "$backend" "$mode"; then
      printf '%s\n' "$backend"
      return 0
    fi
  done

  return 1
}

clipboard_copy_with_backend() {
  backend="$1"
  file="$2"

  case "$backend" in
    macos)
      pbcopy <"$file"
      ;;
    wsl | windows)
      powershell.exe -NoProfile -Command '[Console]::InputEncoding = [System.Text.UTF8Encoding]::new($false); $text = [Console]::In.ReadToEnd(); Set-Clipboard -Value $text' <"$file"
      ;;
    wayland)
      wl-copy <"$file"
      ;;
    xclip)
      xclip -in -selection clipboard -target UTF8_STRING <"$file"
      ;;
    xsel)
      xsel --clipboard --input <"$file"
      ;;
    tmux)
      tmux load-buffer "$file"
      ;;
    *)
      return 1
      ;;
  esac
}

clipboard_paste_with_backend() {
  backend="$1"

  case "$backend" in
    macos)
      pbpaste
      ;;
    wsl | windows)
      powershell.exe -NoProfile -Command '[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false); $OutputEncoding = [Console]::OutputEncoding; Get-Clipboard -Raw'
      ;;
    wayland)
      # --no-newline: wl-paste が末尾に付加する余分な改行を除去する
      # 副作用: コピー元が \n で終わっていた場合もその改行が消える
      wl-paste --no-newline
      ;;
    xclip)
      xclip -out -selection clipboard -target UTF8_STRING
      ;;
    xsel)
      xsel --clipboard --output
      ;;
    tmux)
      tmux save-buffer -
      ;;
    *)
      return 1
      ;;
  esac
}

clipboard_try_copy_from_file() {
  candidate_list="$(clipboard_backend_candidates copy)" || return $?
  file="$1"

  for backend in $candidate_list; do
    if ! clipboard_backend_supported "$backend" copy; then
      clipboard_debug "copy backend $backend unsupported in current environment"
      continue
    fi

    clipboard_debug "trying copy backend $backend"
    if clipboard_copy_with_backend "$backend" "$file"; then
      clipboard_debug "copy backend $backend succeeded"
      return 0
    fi
    clipboard_debug "copy backend $backend failed"
  done

  return 1
}

CLIPBOARD_HISTORY_FILE="${CLIPBOARD_HISTORY_FILE:-${HOME}/.clipboard_history}"
CLIPBOARD_HISTORY_MAX="${CLIPBOARD_HISTORY_MAX:-1000}"

clipboard_history_append() {
  file="$1"

  # Multi-line content を1行に圧縮（改行を \n にエスケープ）
  entry=$(awk '{if(NR>1) printf "\\n"; printf "%s", $0}' <"$file")

  # 空・空白のみはスキップ
  case "$entry" in
    "" | *[![:space:]]*) : ;;
    *) return 0 ;;
  esac
  [ -z "$entry" ] && return 0

  hist_dir=$(dirname "$CLIPBOARD_HISTORY_FILE")
  [ -d "$hist_dir" ] || mkdir -p "$hist_dir"

  # 先頭に追加しつつ重複除去・件数制限
  tmpfile="${TMPDIR:-/tmp}/clipboard-hist.$$"
  {
    printf '%s\n' "$entry"
    [ -f "$CLIPBOARD_HISTORY_FILE" ] && grep -vxF "$entry" "$CLIPBOARD_HISTORY_FILE" || true
  } | head -n "$CLIPBOARD_HISTORY_MAX" >"$tmpfile"
  mv "$tmpfile" "$CLIPBOARD_HISTORY_FILE"
}

clipboard_try_paste() {
  candidate_list="$(clipboard_backend_candidates paste)" || return $?

  for backend in $candidate_list; do
    if ! clipboard_backend_supported "$backend" paste; then
      clipboard_debug "paste backend $backend unsupported in current environment"
      continue
    fi

    clipboard_debug "trying paste backend $backend"
    if clipboard_paste_with_backend "$backend"; then
      clipboard_debug "paste backend $backend succeeded"
      return 0
    fi
    clipboard_debug "paste backend $backend failed"
  done

  return 1
}
