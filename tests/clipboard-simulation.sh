#!/usr/bin/env sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT HUP INT TERM

mockbin="$tmpdir/mockbin"
mkdir -p "$mockbin"

cat >"$mockbin/mock-clipboard-command" <<'EOF'
#!/usr/bin/env sh
set -eu

name=${0##*/}
printf '%s %s\n' "$name" "$*" >>"${MOCK_LOG:?}"

case "$name" in
  pbpaste)
    behavior=${MOCK_PBPASTE_BEHAVIOR:-success}
    output=${MOCK_PBPASTE_OUTPUT:-}
    ;;
  pbcopy)
    behavior=${MOCK_PBCOPY_BEHAVIOR:-success}
    output=
    ;;
  powershell.exe)
    case " $* " in
      *" Get-Clipboard "*)
        behavior=${MOCK_POWERSHELL_PASTE_BEHAVIOR:-success}
        output=${MOCK_POWERSHELL_PASTE_OUTPUT:-}
        ;;
      *)
        behavior=${MOCK_POWERSHELL_COPY_BEHAVIOR:-success}
        output=
        ;;
    esac
    ;;
  wl-paste)
    behavior=${MOCK_WL_PASTE_BEHAVIOR:-success}
    output=${MOCK_WL_PASTE_OUTPUT:-}
    ;;
  wl-copy)
    behavior=${MOCK_WL_COPY_BEHAVIOR:-success}
    output=
    ;;
  xclip)
    case " $* " in
      *" -out "*)
        behavior=${MOCK_XCLIP_PASTE_BEHAVIOR:-success}
        output=${MOCK_XCLIP_PASTE_OUTPUT:-}
        ;;
      *)
        behavior=${MOCK_XCLIP_COPY_BEHAVIOR:-success}
        output=
        ;;
    esac
    ;;
  xsel)
    case " $* " in
      *" --output "*)
        behavior=${MOCK_XSEL_PASTE_BEHAVIOR:-success}
        output=${MOCK_XSEL_PASTE_OUTPUT:-}
        ;;
      *)
        behavior=${MOCK_XSEL_COPY_BEHAVIOR:-success}
        output=
        ;;
    esac
    ;;
  tmux)
    case " $* " in
      *" save-buffer "*)
        behavior=${MOCK_TMUX_PASTE_BEHAVIOR:-success}
        output=${MOCK_TMUX_PASTE_OUTPUT:-}
        ;;
      *)
        behavior=${MOCK_TMUX_COPY_BEHAVIOR:-success}
        output=
        ;;
    esac
    ;;
  *)
    behavior=fail
    output=
    ;;
esac

case "$behavior" in
  success)
    case "$name:$*" in
      pbcopy:* | powershell.exe:*"Set-Clipboard"* | wl-copy:* | xclip:*"-in"* | xsel:*"--input"* | tmux:*"load-buffer"*)
        cat >"${MOCK_COPY_CAPTURE:?}"
        ;;
    esac
    printf '%s' "$output"
    ;;
  fail)
    exit 42
    ;;
  hang)
    sleep 10
    ;;
  *)
    printf 'unknown mock behavior: %s\n' "$behavior" >&2
    exit 2
    ;;
esac
EOF
chmod +x "$mockbin/mock-clipboard-command"

for command in pbpaste pbcopy powershell.exe wl-paste wl-copy xclip xsel tmux; do
  ln -s mock-clipboard-command "$mockbin/$command"
done

export PATH="$mockbin:$PATH"
export HOME="$tmpdir/home"
export MOCK_LOG="$tmpdir/mock.log"
export MOCK_COPY_CAPTURE="$tmpdir/copy.capture"
export CLIPBOARD_HISTORY_FILE="$tmpdir/clipboard-history"
mkdir -p "$HOME"

pass_count=0

reset_state() {
  : >"$MOCK_LOG"
  : >"$MOCK_COPY_CAPTURE"
  rm -f "$CLIPBOARD_HISTORY_FILE"
  unset DISPLAY WAYLAND_DISPLAY XDG_RUNTIME_DIR TMUX
  unset DOTFILES_CLIPBOARD_BACKEND DOTFILES_CLIPBOARD_DEBUG
  unset MOCK_WL_PASTE_BEHAVIOR MOCK_WL_PASTE_OUTPUT MOCK_WL_COPY_BEHAVIOR
  unset MOCK_PBPASTE_BEHAVIOR MOCK_PBPASTE_OUTPUT MOCK_PBCOPY_BEHAVIOR
  unset MOCK_POWERSHELL_PASTE_BEHAVIOR MOCK_POWERSHELL_PASTE_OUTPUT MOCK_POWERSHELL_COPY_BEHAVIOR
  unset MOCK_XCLIP_PASTE_BEHAVIOR MOCK_XCLIP_PASTE_OUTPUT MOCK_XCLIP_COPY_BEHAVIOR
  unset MOCK_XSEL_PASTE_BEHAVIOR MOCK_XSEL_PASTE_OUTPUT MOCK_XSEL_COPY_BEHAVIOR
  unset MOCK_TMUX_PASTE_BEHAVIOR MOCK_TMUX_PASTE_OUTPUT MOCK_TMUX_COPY_BEHAVIOR
  export MOCK_PBPASTE_BEHAVIOR=fail
  export MOCK_PBCOPY_BEHAVIOR=fail
  export MOCK_POWERSHELL_PASTE_BEHAVIOR=fail
  export MOCK_POWERSHELL_COPY_BEHAVIOR=fail
  export DOTFILES_CLIPBOARD_TIMEOUT=0.1
}

pass() {
  pass_count=$((pass_count + 1))
  printf 'ok %d - %s\n' "$pass_count" "$1"
}

fail() {
  printf 'not ok - %s\n' "$1" >&2
  exit 1
}

assert_eq() {
  expected="$1"
  actual="$2"
  message="$3"
  [ "$actual" = "$expected" ] || fail "$message: expected '$expected', got '$actual'"
}

assert_contains() {
  pattern="$1"
  file="$2"
  message="$3"
  grep -F "$pattern" "$file" >/dev/null || fail "$message: missing '$pattern'"
}

assert_not_contains() {
  pattern="$1"
  file="$2"
  message="$3"
  if grep -F "$pattern" "$file" >/dev/null; then
    fail "$message: unexpectedly found '$pattern'"
  fi
}

reset_state
WAYLAND_DISPLAY=wayland-0
XDG_RUNTIME_DIR="$tmpdir/runtime"
export WAYLAND_DISPLAY XDG_RUNTIME_DIR
MOCK_WL_PASTE_OUTPUT=wayland-text
export MOCK_WL_PASTE_OUTPUT
output=$("$repo_root/bin/clipboard-paste")
assert_eq "wayland-text" "$output" "Wayland paste output"
assert_contains "wl-paste --no-newline" "$MOCK_LOG" "Wayland backend was used"
pass "auto selects a working Wayland paste backend"

reset_state
MOCK_PBPASTE_BEHAVIOR=success
MOCK_PBPASTE_OUTPUT=macos-text
export MOCK_PBPASTE_BEHAVIOR MOCK_PBPASTE_OUTPUT
output=$(DOTFILES_CLIPBOARD_BACKEND=macos "$repo_root/bin/clipboard-paste")
assert_eq "macos-text" "$output" "macOS paste output"
assert_contains "pbpaste " "$MOCK_LOG" "macOS backend was used"
pass "the macOS backend uses pbpaste"

reset_state
WSL_INTEROP=/run/WSL/test
DISPLAY=:1
export WSL_INTEROP DISPLAY
MOCK_POWERSHELL_PASTE_OUTPUT=wsl-text
MOCK_POWERSHELL_PASTE_BEHAVIOR=success
export MOCK_POWERSHELL_PASTE_OUTPUT MOCK_POWERSHELL_PASTE_BEHAVIOR
output=$("$repo_root/bin/clipboard-paste")
assert_eq "wsl-text" "$output" "WSL paste output"
assert_contains "powershell.exe -NoProfile" "$MOCK_LOG" "WSL backend was used"
assert_not_contains "xclip" "$MOCK_LOG" "WSL must be preferred over X11"
pass "auto prefers the WSL backend over X11"

reset_state
WAYLAND_DISPLAY=wayland-0
XDG_RUNTIME_DIR="$tmpdir/runtime"
DISPLAY=:1
export WAYLAND_DISPLAY XDG_RUNTIME_DIR DISPLAY
MOCK_WL_PASTE_BEHAVIOR=hang
MOCK_XCLIP_PASTE_OUTPUT=x11-fallback
DOTFILES_CLIPBOARD_DEBUG=1
export MOCK_WL_PASTE_BEHAVIOR MOCK_XCLIP_PASTE_OUTPUT DOTFILES_CLIPBOARD_DEBUG
output=$("$repo_root/bin/clipboard-paste" 2>"$tmpdir/debug.log")
assert_eq "x11-fallback" "$output" "Timeout fallback output"
assert_contains "paste backend wayland timed out" "$tmpdir/debug.log" "Timeout was reported"
assert_contains "xclip -out" "$MOCK_LOG" "X11 fallback was used"
pass "a hanging Wayland paste times out and falls back to X11"

reset_state
DISPLAY=:1
export DISPLAY
MOCK_XCLIP_PASTE_BEHAVIOR=fail
MOCK_XSEL_PASTE_OUTPUT=xsel-fallback
export MOCK_XCLIP_PASTE_BEHAVIOR MOCK_XSEL_PASTE_OUTPUT
output=$("$repo_root/bin/clipboard-paste")
assert_eq "xsel-fallback" "$output" "xsel fallback output"
assert_contains "xclip -out" "$MOCK_LOG" "xclip was attempted"
assert_contains "xsel --clipboard --output" "$MOCK_LOG" "xsel fallback was used"
pass "a failed xclip paste falls back to xsel"

reset_state
WAYLAND_DISPLAY=wayland-0
XDG_RUNTIME_DIR="$tmpdir/runtime"
DISPLAY=:1
export WAYLAND_DISPLAY XDG_RUNTIME_DIR DISPLAY
MOCK_WL_PASTE_OUTPUT=
MOCK_XCLIP_PASTE_OUTPUT=should-not-run
export MOCK_WL_PASTE_OUTPUT MOCK_XCLIP_PASTE_OUTPUT
output=$("$repo_root/bin/clipboard-paste")
assert_eq "" "$output" "Empty clipboard output"
assert_not_contains "xclip" "$MOCK_LOG" "Empty successful paste must stop fallback"
pass "an empty clipboard is treated as a successful paste"

reset_state
WAYLAND_DISPLAY=wayland-0
XDG_RUNTIME_DIR="$tmpdir/runtime"
DISPLAY=:1
export WAYLAND_DISPLAY XDG_RUNTIME_DIR DISPLAY
MOCK_WL_COPY_BEHAVIOR=hang
export MOCK_WL_COPY_BEHAVIOR
printf 'copy-text' | "$repo_root/bin/clipboard-copy"
assert_eq "copy-text" "$(cat "$MOCK_COPY_CAPTURE")" "Copy fallback content"
assert_contains "wl-copy " "$MOCK_LOG" "Wayland copy was attempted"
assert_contains "xclip -in" "$MOCK_LOG" "X11 copy fallback was used"
pass "a hanging Wayland copy times out and falls back to X11"

reset_state
WAYLAND_DISPLAY=wayland-0
XDG_RUNTIME_DIR="$tmpdir/runtime"
export WAYLAND_DISPLAY XDG_RUNTIME_DIR
printf 'history-text' | "$repo_root/bin/clipboard-copy"
assert_eq "history-text" "$(cat "$MOCK_COPY_CAPTURE")" "Successful copy content"
assert_eq "history-text" "$(cat "$CLIPBOARD_HISTORY_FILE")" "Successful copy history"
pass "a successful copy updates the clipboard history"

reset_state
TMUX=/tmp/tmux-test
export TMUX
MOCK_TMUX_PASTE_OUTPUT=tmux-text
export MOCK_TMUX_PASTE_OUTPUT
output=$("$repo_root/bin/clipboard-paste")
assert_eq "tmux-text" "$output" "tmux paste output"
assert_contains "tmux save-buffer -" "$MOCK_LOG" "tmux backend was used"
pass "tmux is used when no system clipboard backend is available"

reset_state
DOTFILES_CLIPBOARD_BACKEND=wayland
WAYLAND_DISPLAY=wayland-0
XDG_RUNTIME_DIR="$tmpdir/runtime"
export DOTFILES_CLIPBOARD_BACKEND WAYLAND_DISPLAY XDG_RUNTIME_DIR
MOCK_WL_PASTE_BEHAVIOR=hang
export MOCK_WL_PASTE_BEHAVIOR
if "$repo_root/bin/clipboard-paste" >"$tmpdir/output" 2>"$tmpdir/error"; then
  fail "Explicit hanging backend should fail after timeout"
fi
assert_not_contains "xclip" "$MOCK_LOG" "Explicit backend must not fall back"
pass "an explicit backend fails boundedly without trying other backends"

reset_state
DOTFILES_CLIPBOARD_BACKEND=invalid
export DOTFILES_CLIPBOARD_BACKEND
if "$repo_root/bin/clipboard-paste" >"$tmpdir/output" 2>"$tmpdir/error"; then
  fail "Invalid backend override should fail"
fi
assert_contains "Invalid DOTFILES_CLIPBOARD_BACKEND" "$tmpdir/error" "Invalid override error"
pass "an invalid backend override is rejected"

printf '1..%d\n' "$pass_count"
