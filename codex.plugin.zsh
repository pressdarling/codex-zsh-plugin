# Autocompletion for the GitHub CLI (codex).
if (( ! $+commands[codex] )); then
  echo "codex command not found. Please install it with 'brew install codex'"
  return
fi

# Define helper functions first
_codex_notify() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    osascript -e "display notification \"$1\" with title \"Oh My Zsh\""
  fi
}

codex_update_completions() {
  codex completion zsh >| "$_codex_completion_file"
  _codex_notify "Codex completions updated."
}

# Ensure the completions directory exists
mkdir -p "$ZSH_CACHE_DIR/completions"

_codex_completion_file="$ZSH_CACHE_DIR/completions/_codex"
_codex_hash_file="$ZSH_CACHE_DIR/completions/_codex.hash"

_codex_current_hash="$(command -v codex | xargs shasum -a 256 | cut -d' ' -f1)"
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
    codex_update_completions &|
  fi
  echo "$_codex_current_hash" >| "$_codex_hash_file"
fi

# Callback for async completion
_codex_async_callback() {
  # Reload completions after async update
  autoload -Uz _codex
}

# If the completion file exists, load it
if [[ -f "$_codex_completion_file" ]]; then
  source "$_codex_completion_file"
fi
