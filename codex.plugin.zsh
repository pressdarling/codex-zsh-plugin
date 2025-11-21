# Autocompletion for the GitHub CLI (codex).
if (( ! $+commands[codex] )); then
  echo "codex command not found. Please install it with 'brew install codex'"
  return
fi

# Ensure the completions directory exists and paths are defined before use
_codex_completion_dir="$ZSH_CACHE_DIR/completions"
_codex_completion_file="$_codex_completion_dir/_codex"
_codex_hash_file="$_codex_completion_dir/_codex.hash"

mkdir -p "$_codex_completion_dir"

_codex_notify() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    osascript -e "display notification \"$1\" with title \"Oh My Zsh\""
  fi
}

_codex_hash_for_codex() {
  local -a hash_cmd
  if command -v shasum >/dev/null 2>&1; then
    hash_cmd=(shasum -a 256)
  elif command -v sha256sum >/dev/null 2>&1; then
    hash_cmd=(sha256sum)
  else
    return 1
  fi

  "${hash_cmd[@]}" "$(command -v codex)" | cut -d' ' -f1
}

_codex_register_completions() {
  if [[ -f "$_codex_completion_file" ]]; then
    autoload -Uz _codex
    _comps[codex]=_codex
  fi
}

codex_update_completions() {
  if ! codex completion zsh >| "$_codex_completion_file"; then
    return 1
  fi

  _codex_notify "Codex completions updated."
}

_codex_async_callback() {
  local _job=$1 _status=$2

  if [[ ${_status:-1} -eq 0 && -f "$_codex_completion_file" ]]; then
    echo "$_codex_current_hash" >| "$_codex_hash_file"
    _codex_register_completions
  fi
}

_codex_current_hash="$(_codex_hash_for_codex)"
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
    (codex_update_completions && echo "$_codex_current_hash" >| "$_codex_hash_file" && _codex_register_completions) &
  fi
fi

# If the completion file exists, load it
