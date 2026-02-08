# Autocompletion for the OpenAI Codex CLI.
if (( ! $+commands[codex] )); then
  echo "codex command not found. Please install it with 'brew install codex'"
  return
fi

_CODEX_PLUGIN_DIR="${0:A:h}"

_codex_notify() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    osascript -e "display notification \"$1\" with title \"Codex Plugin\""
  fi
}

codex_update_completions() {
  mkdir -p "${_codex_completion_file:h}"
  codex completion zsh >| "$_codex_completion_file"
  _codex_notify "Codex completions updated."
}

codex_upgrade_plugin() {
  local plugin_dir="$_CODEX_PLUGIN_DIR"

  if [[ ! -d "$plugin_dir/.git" ]]; then
    echo "Codex plugin was not installed via git. Cannot auto-update."
    return 1
  fi

  # Check for local changes
  if [[ -n "$(cd "$plugin_dir" && git status --porcelain)" ]]; then
    echo "Error: You have uncommitted changes in $plugin_dir."
    echo "Please commit, stash, or discard them before updating."
    return 1
  fi

  echo "Updating codex plugin..."
  if (cd "$plugin_dir" && git pull --ff-only); then
    _codex_notify "Codex plugin updated successfully."
    echo "Plugin updated. Please restart your shell or run 'exec zsh'."
  else
    echo "Error: Failed to update codex plugin."
    echo "You can try to update manually in $plugin_dir"
    return 1
  fi
}

codex_rollback_plugin() {
  local plugin_dir="$_CODEX_PLUGIN_DIR"

  if [[ ! -d "$plugin_dir/.git" ]]; then
    echo "Codex plugin was not installed via git. Cannot rollback."
    return 1
  fi

  echo "Rolling back codex plugin..."
  if (cd "$plugin_dir" && git reset --hard HEAD@{1}); then
     _codex_notify "Codex plugin rolled back."
     echo "Plugin rolled back to previous state. Please restart your shell."
  else
    echo "Error: Failed to rollback."
    return 1
  fi
}

_codex_check_for_updates() {
  (
    local plugin_dir="${1}"
    cd "$plugin_dir"
    if [[ ! -d .git ]]; then
      return
    fi
    git fetch origin &>/dev/null
    local local_hash=$(git rev-parse HEAD)
    local remote_hash=$(git rev-parse @{u} 2>/dev/null)
    if [[ -n "$remote_hash" && "$local_hash" != "$remote_hash" ]]; then
       _codex_notify "A new version of the Codex plugin is available. Run 'codex_upgrade_plugin' to update."
    fi
  ) &!
}

_codex_periodic_update_check() {
  local last_check_file="${ZSH_CACHE_DIR:-$HOME/.cache/zsh}/completions/last_update_check"
  mkdir -p "${last_check_file:h}"

  local current_time=$(date +%s)
  local last_check=0
  [[ -f "$last_check_file" ]] && last_check=$(cat "$last_check_file")

  # Check every 7 days (604800 seconds)
  if (( current_time - last_check > 604800 )); then
    echo "$current_time" >| "$last_check_file"
    _codex_check_for_updates "$_CODEX_PLUGIN_DIR"
  fi
}

_codex_completion_file="${ZSH_CACHE_DIR:-$HOME/.cache/zsh}/completions/_codex"
_codex_hash_file="${ZSH_CACHE_DIR:-$HOME/.cache/zsh}/completions/_codex.hash"

_codex_current_hash="$(command -v codex | xargs shasum -a 256 | cut -d' ' -f1)"
_codex_stored_hash="$(cat "$_codex_hash_file" 2>/dev/null)"

if [[ ! -f "$_codex_completion_file" || "$_codex_current_hash" != "$_codex_stored_hash" ]]; then
  if command -v async_start_worker &> /dev/null; then
    async_start_worker codex -n
    async_job codex codex_update_completions
  else
    codex_update_completions &|
  fi
  echo "$_codex_current_hash" >| "$_codex_hash_file"
fi

# If the completion file doesn't exist yet, we need to autoload it and
# bind it to `codex`. Otherwise, compinit will have already done that.
if [[ ! -f "$_codex_completion_file" ]]; then
  typeset -g -A _comps
  autoload -Uz _codex
  _comps[codex]=_codex
fi

_codex_periodic_update_check
