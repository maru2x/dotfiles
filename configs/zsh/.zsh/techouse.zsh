# ========================================
# Techouse プロジェクト設定
# CHWorkforce / CHCentral 関連
# ========================================

# ディレクトリ定義
export CHW_DIR="$HOME/workspace/CHWorkforce"
export CHC_DIR="$HOME/workspace/CHCentral"

# ディレクトリ移動
alias cdc='cd "$CHC_DIR"'
alias cdw='cd "$CHW_DIR"'

# プロジェクト起動・停止
alias wup='echo "$CHW_DIR" ; cd "$CHW_DIR" && docker compose --profile base --profile microservices --profile others down --remove-orphans ; make up-all'
alias cup='cd "$CHC_DIR" && dcdu && cd "$CHW_DIR" && docker compose --profile base --profile microservices --profile others down --remove-orphans ; make up-all'
alias wdn='cd "$CHW_DIR" && make down'
alias cdn='cd "$CHW_DIR" && make down ; cd "$CHC_DIR" && dc down'

# Ruby ビルド用のコンパイラ指定（macOS）
if [[ "$(uname -s)" == "Darwin" ]]; then
    export CC=/usr/bin/clang
fi

# プロンプトの設定
PROMPT="%K{red}%F{black}%n ($(arch)):%~"$'\n'"%# %f%k"

# ========================================
# rbenv (Ruby version management)
# ========================================

if command -v rbenv >/dev/null 2>&1; then
    eval "$(rbenv init - zsh)"
fi

# ========================================
# AWS設定
# ========================================

alias bed='aws sso login --profile bedrock'
alias sshneptune='autossh -M 0 chw-int-neptune'
alias sshw='ssh ssh10.th-svc.net'
alias sshci='aws sso login --profile central-int && cd "$CHC_DIR" && AWS_PROFILE=central-int STAGE=int ./script/tunnel_rds.sh'
alias sshcs='aws sso login --profile central-stg && cd "$CHC_DIR" && AWS_PROFILE=central-stg STAGE=stg ./script/tunnel_rds.sh'


# ========================================
# 機密情報は ~/.secrets.env に移動してください
# ========================================
# 以下のような内容を ~/.secrets.env に記載：
# export BUNDLE_GITHUB__COM=github_pat_..
export PATH=$HOME/.nodebrew/current/bin:$PATH
