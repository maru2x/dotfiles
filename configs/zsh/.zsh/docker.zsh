# ========================================
# Docker Compose 用の短縮エイリアス
# ========================================
alias dc='docker compose'
alias dcud='docker compose up -d'
alias dcdu='docker compose down ; docker compose up -d'

# Docker CLI の補完スクリプトを読み込む
if [ -d "$HOME/.docker/completions" ]; then
  fpath=($HOME/.docker/completions $fpath)
fi
