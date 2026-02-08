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

# _codex_hash_for_codex computes the SHA-256 hash of the installed codex executable and writes the hexadecimal digest to stdout.
# It returns a non-zero status if neither `shasum` nor `sha256sum` is available.
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

# _codex_register_completions registers the codex completion function in the global _comps map if the completion file exists.
_codex_register_completions() {
  if [[ -f "$_codex_completion_file" ]]; then
    typeset -g -A _comps
    autoload -Uz _codex
    _comps[codex]=_codex
    return 0
  else
    return 1
  fi
}

# _codex_generate_completions generates the zsh completion script for the `codex` command and writes it to the cache file (`$_codex_completion_file`), overwriting any existing contents.
_codex_generate_completions() {
  codex completion zsh >| "$_codex_completion_file"
}

# _codex_update_sync generates zsh completions for codex, updates the stored codex hash if available, registers the completions and sends a notification.
_codex_update_sync() {
  _codex_generate_completions || return 1

  local new_hash
  new_hash=$(_codex_hash_for_codex)
  if [[ -n "$new_hash" ]]; then
    echo "$new_hash" >| "$_codex_hash_file"
  fi

  _codex_register_completions
  _codex_notify "Codex completions updated."
  return 0
}

# _codex_async_callback is an async worker callback that, on successful job completion, recomputes and writes the codex hash, reloads completions and sends a notification.
_codex_async_callback() {
  # The callback receives: worker_name, job_name, return_code, output, execution_time, error_output
  local worker_name=$1
  local job_name=$2
  local exit_code=$3
  local output=$4
  local execution_time=$5
  local error_output=$6

  # Only update hash and reload completions on success (exit code 0)
  if (( exit_code == 0 )); then
    local updated_hash
    updated_hash="$(_codex_hash_for_codex)"
    [[ -n "$updated_hash" ]] || return

    echo "$updated_hash" >| "$_codex_hash_file"
    _codex_register_completions
    _codex_notify "Codex completions updated."
  fi
}

# Capture current and stored hashes before deciding to regenerate
_codex_current_hash="$(_codex_hash_for_codex)"
_codex_stored_hash="$(cat "$_codex_hash_file" 2>/dev/null)"

# Check if hash generation succeeded
if [[ -z "$_codex_current_hash" ]]; then
  _codex_notify "Could not generate hash for codex binary. Completions will not be managed."
  # Still load existing completions if available
  _codex_register_completions
  return
fi

# Check if we need to regenerate completions
if [[ ! -f "$_codex_completion_file" || "$_codex_current_hash" != "$_codex_stored_hash" ]]; then
  if command -v async_start_worker &> /dev/null; then
    # ... (async logic)
    _codex_register_completions # Load existing completions for now
  else
    _codex_update_sync # This generates and registers
  fi
else
  _codex_register_completions # Load up-to-date completions
fi

# If the completion file exists, load it
_codex_register_completions