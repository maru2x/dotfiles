# ========================================
# SSH Agent
# ========================================

if [[ -o interactive ]] && command -v ssh-agent >/dev/null 2>&1 && command -v ssh-add >/dev/null 2>&1; then
  agent_env="$HOME/.ssh/agent.env"

  load_ssh_agent_env() {
    local exit_code

    [[ -r "$agent_env" ]] || return 1

    source "$agent_env" >/dev/null 2>&1
    ssh-add -l >/dev/null 2>&1
    exit_code=$?

    [[ "$exit_code" -eq 0 || "$exit_code" -eq 1 ]]
  }

  start_ssh_agent() {
    mkdir -p "$HOME/.ssh"
    eval "$(ssh-agent -s)" >/dev/null

    umask 077
    {
      printf 'export SSH_AUTH_SOCK=%q\n' "$SSH_AUTH_SOCK"
      printf 'export SSH_AGENT_PID=%q\n' "$SSH_AGENT_PID"
    } > "$agent_env"
    chmod 600 "$agent_env"
  }

  ensure_ssh_key_loaded() {
    local key="$1"
    local pub="${key}.pub"

    [[ -r "$key" && -r "$pub" ]] || return 0

    if ssh-add -L 2>/dev/null | grep -Fqx -- "$(<"$pub")"; then
      return 0
    fi

    if [[ "$(uname -s)" == "Darwin" ]]; then
      ssh-add --apple-use-keychain "$key" >/dev/null </dev/tty 2>/dev/null || \
        ssh-add "$key" >/dev/null </dev/tty
    else
      ssh-add "$key" >/dev/null </dev/tty
    fi
  }

  if ! load_ssh_agent_env; then
    unset SSH_AUTH_SOCK SSH_AGENT_PID
    start_ssh_agent
  fi

  ensure_ssh_key_loaded "$HOME/.ssh/id_ed25519_sit"
  ensure_ssh_key_loaded "$HOME/.ssh/id_ed25519_techouse"
fi
