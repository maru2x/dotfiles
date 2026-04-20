#!/usr/bin/env zsh
setopt null_glob

# スクリプトがある場所（dotfiles）に移動
cd "$(dirname "$0")/.."

# configsディレクトリ直下に保存されているディレクトリ名をすべて抽出する
config_dirs=()
for dir in configs/*; do
  if [ -d "$dir" ]; then
    config_dirs+=("$(basename "$dir")")
  fi
done

# 先程抽出したすべてのディレクトリ名に基づいてstowによるリンクの展開を行う
for name in "${config_dirs[@]}"; do
  conflicts=()
  while IFS= read -r relpath; do
    target="$HOME/$relpath"
    expected="$PWD/configs/$name/$relpath"

    if [ -L "$target" ]; then
      if [ "$(readlink -f "$target")" = "$expected" ]; then
        continue
      fi
    elif [ ! -e "$target" ]; then
      continue
    fi

    conflicts+=("$target")
  done < <(find "configs/$name" \( -type f -o -type l \) | sed "s|^configs/$name/||")

  if [ "${#conflicts[@]}" -gt 0 ]; then
    uniq_conflicts=("${(@u)conflicts}")
    printf 'remove existing files for %s:\n' "$name"
    printf '  %s\n' "${uniq_conflicts[@]}"
    for target in "${uniq_conflicts[@]}"; do
      rm -rf "$target"
    done
  fi

  stow --restow --no-folding -d configs -t "$HOME" "$name"
done
