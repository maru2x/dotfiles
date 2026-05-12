#!/usr/bin/env sh

ime_has_command() {
  command -v "$1" >/dev/null 2>&1
}

ime_command_path() {
  command -v "$1" 2>/dev/null || true
}

ime_debug() {
  if [ "${DOTFILES_IME_DEBUG:-0}" = "1" ]; then
    printf 'ime: %s\n' "$*" >&2
  fi
}

ime_backend_candidates() {
  requested="${DOTFILES_IME_BACKEND:-auto}"

  case "$requested" in
    "" | auto)
      printf '%s\n' "fcitx5 ibus macism im-select"
      ;;
    fcitx5 | ibus | macism | im-select)
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

ime_backend_override_valid() {
  case "${DOTFILES_IME_BACKEND:-auto}" in
    "" | auto | fcitx5 | ibus | macism | im-select | none)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

ime_backend_supported() {
  backend="$1"

  case "$backend" in
    fcitx5)
      ime_has_command fcitx5-remote
      ;;
    ibus)
      ime_has_command ibus
      ;;
    macism)
      ime_has_command macism
      ;;
    im-select)
      ime_has_command im-select
      ;;
    *)
      return 1
      ;;
  esac
}

ime_first_supported_backend() {
  candidate_list="$(ime_backend_candidates)" || return $?

  for backend in $candidate_list; do
    if ime_backend_supported "$backend"; then
      printf '%s\n' "$backend"
      return 0
    fi
  done

  return 1
}

ime_default_ibus_engine() {
  printf '%s\n' "${DOTFILES_IME_IBUS_ENGINE:-xkb:us::eng}"
}

ime_default_macos_source() {
  printf '%s\n' "${DOTFILES_IME_MACOS_SOURCE:-com.apple.keylayout.ABC}"
}

ime_turn_off_with_backend() {
  backend="$1"

  case "$backend" in
    fcitx5)
      fcitx5-remote -c >/dev/null 2>&1
      ;;
    ibus)
      ibus engine "$(ime_default_ibus_engine)" >/dev/null 2>&1
      ;;
    macism)
      macism "$(ime_default_macos_source)" >/dev/null 2>&1
      ;;
    im-select)
      im-select "$(ime_default_macos_source)" >/dev/null 2>&1
      ;;
    *)
      return 1
      ;;
  esac
}

ime_try_turn_off() {
  candidate_list="$(ime_backend_candidates)" || return $?

  for backend in $candidate_list; do
    if ! ime_backend_supported "$backend"; then
      ime_debug "backend $backend unsupported in current environment"
      continue
    fi

    ime_debug "trying backend $backend"
    if ime_turn_off_with_backend "$backend"; then
      ime_debug "backend $backend succeeded"
      return 0
    fi
    ime_debug "backend $backend failed"
  done

  return 1
}
