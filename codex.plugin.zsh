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
_codex_update_sync() {
  _codex_generate_completions || return 1

  local new_hash
  new_hash=$(_codex_hash_for_codex)
  if [[ -n "$new_hash" ]]; then
    echo "$new_hash" >| "$_codex_hash_file"
  fi

  if _codex_register_completions; then
    _codex_notify "Codex completions updated."
    return 0
  else
    _codex_notify "Codex completions generated but registration failed."
    return 1
  fi
}

# _codex_async_callback is an async worker callback that, on successful job completion, recomputes and writes the codex hash, reloads completions and sends a notification.
_codex_async_callback() {
  # zsh-async callback signature: job_name, return_code, stdout, execution_time, stderr, has_next
  local job_name=$1
  local exit_code=$2
  local output=$3
  local execution_time=$4
  local error_output=$5
  local has_next=$6

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
  # If no completion file exists, generate it once without hash management
  if [[ ! -f "$_codex_completion_file" ]]; then
    _codex_notify "Could not generate hash for codex binary. Generating completions without version tracking."
    _codex_generate_completions && _codex_register_completions
  else
    _codex_notify "Could not generate hash for codex binary. Using existing completions without version tracking."
    _codex_register_completions
  fi
  return
# Still load existing completions if available
_codex_register_completions
return
fi

# Check if we need to regenerate completions
if [[ ! -f "$_codex_completion_file" || "$_codex_current_hash" != "$_codex_stored_hash" ]]; then
  if command -v async_start_worker &> /dev/null; then
    async_start_worker codex_worker -n
    async_job codex_worker _codex_generate_completions
    async_register_callback codex_worker _codex_async_callback
    _codex_register_completions # Load existing completions for now
  else
    _codex_update_sync # This generates and registers
  fi
else
  _codex_register_completions # Load up-to-date completions
fi

# If the completion file exists, load it
_codex_register_completions
