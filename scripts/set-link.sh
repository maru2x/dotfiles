#!/usr/bin/env zsh
setopt null_glob

if ! command -v stow >/dev/null 2>&1; then
  echo "GNU Stow が見つかりません。先にインストールしてから ./scripts/set-link.sh を再実行してください。" >&2
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

describe_conflict() {
  local target="$1"
  local expected="$2"
  local parent_symlink="$3"
  local link_target=""
  local path_type=""

  if [[ -n "$parent_symlink" ]]; then
    link_target="$(readlink "$parent_symlink" 2>/dev/null || true)"
    printf '%s（親ディレクトリが symlink: %s -> %s, 配置先想定: %s）' \
      "$target" "$parent_symlink" "${link_target:-不明}" "$expected"
    return 0
  fi

  if [[ -L "$target" ]]; then
    link_target="$(readlink "$target" 2>/dev/null || true)"
    if [[ -e "$target" ]]; then
      printf '%s（symlink -> %s, 配置先想定: %s）' \
        "$target" "${link_target:-不明}" "$expected"
    else
      printf '%s（壊れた symlink -> %s, 配置先想定: %s）' \
        "$target" "${link_target:-不明}" "$expected"
    fi
    return 0
  fi

  if [[ -d "$target" ]]; then
    path_type="ディレクトリ"
  elif [[ -f "$target" ]]; then
    path_type="ファイル"
  else
    path_type="既存パス"
  fi

  printf '%s（%s, 配置先想定: %s）' "$target" "$path_type" "$expected"
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
      conflicts+=("$(describe_conflict "$target" "$expected" "$parent_symlink")")
      continue
    fi

    if [[ -L "$target" ]]; then
      if [[ "${target:A}" == "${expected:A}" ]]; then
        continue
      fi
      conflicts+=("$(describe_conflict "$target" "$expected" "")")
      continue
    fi

    if [[ -e "$target" ]]; then
      conflicts+=("$(describe_conflict "$target" "$expected" "")")
    fi
  done < <(find "configs/$name" \( -type f -o -type l \) | sed "s|^configs/$name/||" | sort)

  if (( ${#conflicts[@]} > 0 )); then
    local -a uniq_conflicts
    uniq_conflicts=("${(@u)conflicts}")

    printf '%s で衝突が見つかりました:\n' "$name"
    printf '  %s\n' "${uniq_conflicts[@]}"
    printf '対象パスを手動で退避または整理してから、./scripts/set-link.sh を再実行してください。\n\n'

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
