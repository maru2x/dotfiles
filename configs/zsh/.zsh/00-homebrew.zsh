# Homebrewに関する設定

# PATHに保存されているパスが一意で有ることを強制する。
typeset -U path PATH

# Homebrew の環境変数を読み込む
# Linuxbrew/macOSのいずれでもPATHが通るようにする
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
elif [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
