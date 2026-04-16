# ========================================
# SSH Agent
# ========================================

if [[ -o interactive ]] && command -v ssh-add >/dev/null 2>&1 && [[ -n "${SSH_AUTH_SOCK:-}" ]]; then
  for key in "$HOME/.ssh/id_ed25519_sit" "$HOME/.ssh/id_ed25519_techouse"; do
    pub="${key}.pub"
    [[ -r "$key" && -r "$pub" ]] || continue

    if ! ssh-add -L 2>/dev/null | grep -Fqx -- "$(<"$pub")"; then
      ssh-add "$key" >/dev/null
    fi
  done
fi
