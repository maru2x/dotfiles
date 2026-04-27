# ========================================
# p10kは使用しているzshのテーマ
# 最初にp10k(oh my zsh系)を入れないとバグる
# ========================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ========================================
# 機密情報（別ファイルから読み込み）
# ========================================
if [ -f ~/.secrets.env ]; then
  source ~/.secrets.env
fi

# ========================================
# モジュール読み込み
# ========================================
for config_file in ~/.zsh/*.zsh(N); do
  if [[ "$(basename "$config_file")" == "techouse.zsh" ]]; then
    continue
  fi

  source "$config_file"
done

# ========================================
# Techouse 設定の読み込み（明示フラグ）
# ========================================
if [ -f "$HOME/.config/techouse/enabled" ] && [ -f ~/.zsh/techouse.zsh ]; then
  source ~/.zsh/techouse.zsh
fi

# ========================================
# プライベート設定の読み込み（オプション）
# ========================================
# dotfiles-th (Techouse固有設定) が存在する場合のみ読み込む
if [ -d "$HOME/dotfiles-th/.zsh" ]; then
  for config_file in $HOME/dotfiles-th/.zsh/*.zsh(N); do
    source "$config_file"
  done
fi

# ========================================
# zsh起動時に自動でtmuxセッションへ
# ========================================
if [[ -o interactive ]] && [[ -z "$TMUX" ]] && [[ -t 0 ]] && [[ -t 1 ]] && command -v tmux >/dev/null 2>&1; then
  exec tmux new-session -A -s main
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ========================================
# User commands
# ========================================
[[ ":$PATH:" != *":$HOME/dotfiles/bin:"* ]] && export PATH="$HOME/dotfiles/bin:$PATH"

export PATH=/opt/zeek/bin:$PATH
