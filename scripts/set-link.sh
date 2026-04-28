#!/usr/bin/env zsh
setopt null_glob

if ! command -v stow >/dev/null 2>&1; then
  echo "GNU Stow が見つかりません。先にインストールしてから make set-link を再実行してください。" >&2
  exit 1
fi

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

check_package_conflicts() {
  local name="$1"
  local relpath target expected
  local current_relpath current_target current_expected
  local -a path_parts
  local -a conflicts=()

  while IFS= read -r relpath; do
    target="$HOME/$relpath"
    expected="$repo_root/configs/$name/$relpath"

    path_parts=("${(@s:/:)relpath}")
    current_relpath=""

    for part in "${path_parts[@]}"; do
      if [[ -n "$current_relpath" ]]; then
        current_relpath+="/"
      fi
      current_relpath+="$part"
      current_target="$HOME/$current_relpath"
      current_expected="$repo_root/configs/$name/$current_relpath"

      if [[ ! -e "$current_target" && ! -L "$current_target" ]]; then
        continue
      fi

      if [[ "$current_relpath" != "$relpath" && -d "$current_target" && ! -L "$current_target" ]]; then
        continue
      fi

      if [[ "${current_target:A}" == "${current_expected:A}" ]]; then
        continue
      fi

      conflicts+=("$target（$expected ではないリンクまたは既存ファイルが指定されています）")
      break
    done
  done < <(find "configs/$name" \( -type f -o -type l \) | sed "s|^configs/$name/||" | sort)

  if (( ${#conflicts[@]} > 0 )); then
    local -a uniq_conflicts
    uniq_conflicts=("${(@u)conflicts}")

    printf '%s で衝突が見つかりました:\n' "$name"
    printf '  %s\n' "${uniq_conflicts[@]}"
    printf '対象パスを手動で退避または整理してから、make set-link を再実行してください。\n\n'

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
