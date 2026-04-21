#!/usr/bin/env zsh
setopt null_glob

# スクリプトがある場所（dotfiles）に移動
cd "$(dirname "$0")/.."
repo_root="$PWD"

typeset -a config_dirs
for dir in configs/*; do
  if [[ -d "$dir" ]]; then
    config_dirs+=("${dir:t}")
  fi
done

typeset -i has_conflicts=0

find_symlink_parent() {
  local path="$1"
  local parent="${path:h}"
  local home_root="${HOME:A}"

  while [[ "$parent" != "$home_root" && "$parent" != "/" ]]; do
    if [[ -L "$parent" ]]; then
      print -r -- "$parent"
      return 0
    fi
    parent="${parent:h}"
  done

  return 1
}

check_package_conflicts() {
  local name="$1"
  local relpath target expected parent_symlink
  local -a conflicts=()

  while IFS= read -r relpath; do
    target="$HOME/$relpath"
    expected="$repo_root/configs/$name/$relpath"
    parent_symlink="$(find_symlink_parent "$target")"

    if [[ -n "$parent_symlink" ]]; then
      conflicts+=("$target (parent symlink: $parent_symlink)")
      continue
    fi

    if [[ -L "$target" ]]; then
      if [[ "${target:A}" == "${expected:A}" ]]; then
        continue
      fi
      conflicts+=("$target")
      continue
    fi

    if [[ -e "$target" ]]; then
      conflicts+=("$target")
    fi
  done < <(find "configs/$name" \( -type f -o -type l \) | sed "s|^configs/$name/||" | sort)

  if (( ${#conflicts[@]} > 0 )); then
    local -a uniq_conflicts
    uniq_conflicts=("${(@u)conflicts}")

    printf 'conflicts detected for %s:
' "$name"
    printf '  %s
' "${uniq_conflicts[@]}"
    printf 'move or back up these paths manually, then rerun ./scripts/set-link.sh

'

    has_conflicts=1
  fi
}

for name in "${config_dirs[@]}"; do
  check_package_conflicts "$name"
done

if (( has_conflicts )); then
  exit 1
fi

for name in "${config_dirs[@]}"; do
  stow --restow --no-folding -d configs -t "$HOME" "$name"
done
