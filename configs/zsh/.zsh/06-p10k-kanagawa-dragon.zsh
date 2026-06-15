# ========================================
# Powerlevel10k: Kanagawa Dragon テーマ
# ========================================
() {
  emulate -L zsh

  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    dir
    vcs
  )
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status
    command_execution_time
    background_jobs
    virtualenv
    pyenv
    context
    time
  )

  typeset -g POWERLEVEL9K_MODE=powerline
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

  # tmux status bar と同じく、背景は端末に任せて色付きテキストで区切る。
  typeset -g POWERLEVEL9K_BACKGROUND=
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR='%F{#393836} │ %f'
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR='%F{#393836} │ %f'
  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=' '
  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL='%F{#393836} │%f '
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=' %F{#393836}│%f '
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL=' '

  # dragonBlue2: current directory
  typeset -g POWERLEVEL9K_DIR_FOREGROUND='#8ba4b0'
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND='#7a8382'
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='#c5c9c5'
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=50

  # dragonGreen / dragonYellow: Git state
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#87a987'
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#c4b28a'
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#c4b28a'
  typeset -g POWERLEVEL9K_VCS_CONFLICTED_FOREGROUND='#c4746e'
  typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND='#7a8382'
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=''

  # Right prompt uses the quieter Dragon accents from tmux.
  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND='#c4746e'
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='#c4b28a'
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND='#8992a7'
  typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND='#87a987'
  typeset -g POWERLEVEL9K_PYENV_FOREGROUND='#87a987'
  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND='#9e9b93'
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND='#c4746e'
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_FOREGROUND='#c4b28a'
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_SUDO_FOREGROUND='#c4746e'
  typeset -g POWERLEVEL9K_TIME_FOREGROUND='#8ea4a2'
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M}'

  typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

  (( ! $+functions[p10k] )) || p10k reload
}
