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
  if (( $+commands[shasum] )); then
    hash_cmd=(shasum -a 256)
  elif (( $+commands[sha256sum] )); then
    hash_cmd=(sha256sum)
  else
    return 1
  fi

  "${hash_cmd[@]}" "$(command -v codex)" | cut -d' ' -f1
}

_codex_register_completions() {
  if [[ -f "$_codex_completion_file" ]]; then
    typeset -g -A _comps
    autoload -Uz _codex
    _comps[codex]=_codex
  fi
}

codex_update_completions() {
  if [[ -f "$_codex_completion_file" ]]; then
    autoload -Uz _codex
    _comps[codex]=_codex
    _codex_notify "Codex completions updated."
    return 0
  else
    return 1
  fi
}

_codex_async_callback() {
  local _job=$1 _status=$2

  if [[ ${_status:-1} -eq 0 && -s "$_codex_completion_file" ]]; then
    local _current_hash="$(_codex_hash_for_codex)"
    if [[ -n "$_current_hash" ]]; then
      echo "$_current_hash" >| "$_codex_hash_file"
      _codex_notify "Codex completions updated."
      _codex_register_completions
    fi
  fi
}

_codex_update_and_save_hash() {
  if codex_update_completions; then
    local new_hash
    new_hash="$(_codex_hash_for_codex)" && [[ -n "$new_hash" ]] && echo "$new_hash" >| "$_codex_hash_file"
  fi
}

_codex_current_hash="$(_codex_hash_for_codex)"
_codex_stored_hash="$(cat "$_codex_hash_file" 2>/dev/null)"

# Check if hash generation succeeded
if [[ -z "$_codex_current_hash" ]]; then
  _codex_notify "Could not generate hash for codex binary. Completions will not be updated."
  # Still load existing completions if available
  if [[ -f "$_codex_completion_file" ]]; then
    autoload -Uz _codex
    _comps[codex]=_codex
  fi
  return
fi

# Check if we need to regenerate completions
if [[ ! -f "$_codex_completion_file" || "$_codex_current_hash" != "$_codex_stored_hash" ]]; then
  # Generate completions asynchronously if possible
  if command -v async_start_worker &> /dev/null; then
    async_start_worker codex_worker -n
    async_job codex_worker codex_update_completions
    async_register_callback codex_worker _codex_async_callback
  else
    # Fall back to background process
    _codex_update_and_save_hash &|
  fi
fi

# Callback for async completion
_codex_async_callback() {
  # The callback receives: worker_name, job_name, return_code, output, execution_time, error_output
  local exit_code=$3

  # Only update hash and reload completions on success (exit code 0)
  if (( exit_code == 0 )); then
    local updated_hash
    updated_hash="$(_codex_hash_for_codex)" || return

    echo "$updated_hash" >| "$_codex_hash_file"
    autoload -Uz _codex
    _comps[codex]=_codex
  fi
}

# If the completion file exists, load it
_codex_register_completions
