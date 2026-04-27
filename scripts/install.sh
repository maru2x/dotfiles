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
