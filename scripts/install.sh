#!/usr/bin/env zsh
set -euo pipefail

find_brew() {
  if command -v brew >/dev/null 2>&1; then
    command -v brew
    return 0
  fi

  local candidates=(
    /home/linuxbrew/.linuxbrew/bin/brew
    /opt/homebrew/bin/brew
    /usr/local/bin/brew
  )
  local candidate
  for candidate in "${candidates[@]}"; do
    if [ -x "$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  done

  return 1
}

find_preferred_zsh() {
  local candidates=(
    /bin/zsh
    /usr/bin/zsh
    /home/linuxbrew/.linuxbrew/bin/zsh
    /opt/homebrew/bin/zsh
    /usr/local/bin/zsh
  )
  local candidate
  for candidate in "${candidates[@]}"; do
    if [ -x "$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  done

  command -v zsh 2>/dev/null || return 1
}

current_login_shell() {
  local user_name="${USER:-$(id -un)}"
  local shell_path

  if [ -n "${SHELL:-}" ]; then
    echo "$SHELL"
    return 0
  fi

  if command -v getent >/dev/null 2>&1; then
    shell_path="$(getent passwd "$user_name" 2>/dev/null | cut -d: -f7 || true)"
    if [ -n "$shell_path" ]; then
      echo "$shell_path"
      return 0
    fi
  fi

  if command -v dscl >/dev/null 2>&1; then
    shell_path="$(dscl . -read "/Users/$user_name" UserShell 2>/dev/null | awk '{print $2}' || true)"
    if [ -n "$shell_path" ]; then
      echo "$shell_path"
      return 0
    fi
  fi

  shell_path="$(command -v passwd 2>/dev/null || true)"
  if [ -n "$shell_path" ] && [ -r /etc/passwd ]; then
    awk -F: -v user="$user_name" '$1 == user { print $7; exit }' /etc/passwd
    return 0
  fi

  return 1
}

is_listed_shell() {
  local shell_path="$1"

  [ -r /etc/shells ] || return 0
  grep -Fx -- "$shell_path" /etc/shells >/dev/null 2>&1
}

ensure_login_shell_is_zsh() {
  local zsh_path current_shell

  if ! zsh_path="$(find_preferred_zsh)"; then
    echo "警告: zsh が見つからないため、ログインシェル確認をスキップします。" >&2
    return 0
  fi

  if ! current_shell="$(current_login_shell)"; then
    echo "警告: 現在のログインシェルを判定できないため、変更確認をスキップします。" >&2
    return 0
  fi

  if [ "$current_shell" = "$zsh_path" ]; then
    echo "ログインシェルは既に $zsh_path です。"
    return 0
  fi

  if ! is_listed_shell "$zsh_path"; then
    cat >&2 <<EOF
警告: $zsh_path は /etc/shells に含まれていないため、自動で既定シェルを変更しません。
対話端末で /etc/shells を確認したうえで、必要なら次を実行してください:
  chsh -s $zsh_path
EOF
    return 0
  fi

  if [ -t 0 ] && [ -t 1 ] && command -v chsh >/dev/null 2>&1; then
    echo "ログインシェルを $zsh_path に変更します..."
    if chsh -s "$zsh_path"; then
      echo "ログインシェルを $zsh_path に変更しました。新しいシェルは次回ログインから有効です。"
      return 0
    fi
    echo "警告: chsh に失敗しました。現在のログインシェルは $current_shell のままです。" >&2
    return 0
  fi

  cat >&2 <<EOF
警告: 現在のログインシェルは $current_shell です。
既定シェルを zsh にするには、対話端末で次を実行してください:
  chsh -s $zsh_path
EOF
}

# Move to the dotfiles directory.
cd "$(dirname "$0")/.."

# Install software listed in Brewfile.
if ! BREW_BIN="$(find_brew)"; then
  cat >&2 <<'EOF'
Homebrew が見つかりませんでした。
OS に応じた方法で Homebrew を手動インストールしてから、make install を再実行してください。
macOS: https://brew.sh/
Linux: https://docs.brew.sh/Homebrew-on-Linux
EOF
  exit 1
fi

"$BREW_BIN" bundle --file Brewfile --verbose

# Install Oh My Zsh if missing.
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Oh My Zsh をインストールします..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ensure_login_shell_is_zsh
