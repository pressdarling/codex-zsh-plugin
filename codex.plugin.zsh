# Autocompletion for the GitHub CLI (codex).
if (( ! $+commands[codex] )); then
  echo "codex command not found. Please install it with 'brew install codex'"
  return
fi

# Ensure the completions directory exists
mkdir -p "$ZSH_CACHE_DIR/completions"

_codex_completion_file="$ZSH_CACHE_DIR/completions/_codex"
_codex_hash_file="$ZSH_CACHE_DIR/completions/_codex.hash"

# Define helper functions first
_codex_notify() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    osascript -e "display notification \"$1\" with title \"Oh My Zsh\""
  fi
}

_codex_compute_current_hash() {
  local codex_path
  codex_path="$(command -v codex)" || return 1

  if command -v sha256sum &> /dev/null; then
    sha256sum "$codex_path" | cut -d' ' -f1
  elif command -v shasum &> /dev/null; then
    shasum -a 256 "$codex_path" | cut -d' ' -f1
  fi
  return 1
}

codex_update_completions() {
  if codex completion zsh >| "$_codex_completion_file"; then
    _codex_notify "Codex completions updated."
    return 0
  fi
  return 1
}

_codex_current_hash="$(_codex_compute_current_hash)"
_codex_stored_hash="$(cat "$_codex_hash_file" 2>/dev/null)"

# Check if we need to regenerate completions
if [[ ! -f "$_codex_completion_file" || "$_codex_current_hash" != "$_codex_stored_hash" ]]; then
  # Generate completions asynchronously if possible
  if command -v async_start_worker &> /dev/null; then
    async_start_worker codex_worker -n
    async_job codex_worker codex_update_completions
    async_register_callback codex_worker _codex_async_callback
  else
    # Fall back to background process
    if codex_update_completions; then
      echo "$_codex_current_hash" >| "$_codex_hash_file"
    fi
  fi
fi

# Callback for async completion
_codex_async_callback() {
  # The callback receives: worker_name, job_name, exit_code
  local exit_code=$3

  # Only update hash and reload completions on success (exit code 0)
  if (( exit_code == 0 )); then
    echo "$_codex_current_hash" >| "$_codex_hash_file"
    autoload -Uz _codex
    _comps[codex]=_codex
  fi
}

# If the completion file exists, load it
if [[ -f "$_codex_completion_file" ]]; then
  autoload -Uz _codex
  _comps[codex]=_codex
fi
