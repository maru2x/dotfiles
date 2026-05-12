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

extract_brewfile_entries() {
  local entry_type="$1"
  local output="$2"

  awk -v entry_type="$entry_type" '
    $0 ~ "^[[:space:]]*" entry_type "[[:space:]]+\"" {
      line = $0
      sub("^[[:space:]]*" entry_type "[[:space:]]+\"", "", line)
      sub("\".*$", "", line)
      print line
    }
  ' "$BREWFILE" | LC_ALL=C sort -u > "$output"
}

print_section() {
  local title="$1"
  local file="$2"

  [ -s "$file" ] || return 0

  printf '%s\n' "$title"
  sed 's/^/  - /' "$file"
  printf '\n'
}

collect_installed_formulae() {
  local cellar formula receipt

  cellar="$("$BREW_BIN" --cellar)"
  : > "$installed_formulae"

  while IFS= read -r formula; do
    receipt="$(LC_ALL=C ls -1 "$cellar/$formula"/*/INSTALL_RECEIPT.json 2>/dev/null | LC_ALL=C sort | tail -1 || true)"

    if [ -z "$receipt" ] || grep -Eq '"installed_on_request":[[:space:]]*true' "$receipt"; then
      printf '%s\n' "$formula" >> "$installed_formulae"
    fi
  done < <("$BREW_BIN" list --formula 2>/dev/null)

  LC_ALL=C sort -u -o "$installed_formulae" "$installed_formulae"
}

cd "$(dirname "$0")/.."
REPO_ROOT="$PWD"
BREWFILE="$REPO_ROOT/Brewfile"

if ! BREW_BIN="$(find_brew)"; then
  cat >&2 <<'EOF'
Homebrew が見つかりませんでした。
brew diff を使うには、先に Homebrew をインストールしてください。
EOF
  exit 1
fi

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/brew-diff.XXXXXX")"
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

managed_formulae="$tmp_dir/managed_formulae"
managed_casks="$tmp_dir/managed_casks"
installed_formulae="$tmp_dir/installed_formulae"
installed_casks="$tmp_dir/installed_casks"
extra_formulae="$tmp_dir/extra_formulae"
extra_casks="$tmp_dir/extra_casks"
missing_formulae="$tmp_dir/missing_formulae"
missing_casks="$tmp_dir/missing_casks"

extract_brewfile_entries brew "$managed_formulae"
extract_brewfile_entries cask "$managed_casks"

collect_installed_formulae

if HOMEBREW_NO_AUTO_UPDATE=1 "$BREW_BIN" list --cask >/dev/null 2>&1; then
  HOMEBREW_NO_AUTO_UPDATE=1 "$BREW_BIN" list --cask | LC_ALL=C sort -u > "$installed_casks"
else
  : > "$installed_casks"
fi

comm -23 "$installed_formulae" "$managed_formulae" > "$extra_formulae"
comm -23 "$installed_casks" "$managed_casks" > "$extra_casks"
comm -23 "$managed_formulae" "$installed_formulae" > "$missing_formulae"
comm -23 "$managed_casks" "$installed_casks" > "$missing_casks"

if [ ! -s "$extra_formulae" ] && [ ! -s "$extra_casks" ] && \
   [ ! -s "$missing_formulae" ] && [ ! -s "$missing_casks" ]; then
  echo "Brewfile と現在の brew 環境に差分はありません。"
  exit 0
fi

cat <<'EOF'
== Brewfile diff ==

formula は Homebrew の INSTALL_RECEIPT.json にある `installed_on_request` を使って、
依存ではなく手元で明示的に持っているものだけを比較しています。
下の `Installed locally but not tracked in Brewfile` が整理候補です。

EOF

print_section "Missing locally but declared in Brewfile:" "$missing_formulae"
print_section "Missing casks locally but declared in Brewfile:" "$missing_casks"
print_section "Installed locally but not tracked in Brewfile:" "$extra_formulae"
print_section "Installed casks locally but not tracked in Brewfile:" "$extra_casks"

exit 0
