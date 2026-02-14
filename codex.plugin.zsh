# Autocompletion for the OpenAI Codex CLI.
if (( ! $+commands[codex] )); then
  echo "codex command not found. Please install it with 'brew install codex'"
  return
fi

_codex_completion_file="$ZSH_CACHE_DIR/completions/_codex"
_codex_hash_file="$ZSH_CACHE_DIR/completions/_codex.hash"

_codex_notify() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    osascript -e "display notification \"$1\" with title \"Oh My Zsh\""
  fi
}

_codex_update_completions_job() {
  codex completion zsh >| "$_codex_completion_file"
}

_codex_update_completions_callback() {
  local return_code=$2
  if [[ $return_code -eq 0 ]]; then
    echo "$_codex_current_hash" >| "$_codex_hash_file"
    _codex_notify "Codex completions updated."
  else
    _codex_notify "Error updating Codex completions."
  fi
}

_codex_current_hash="$(command -v codex | xargs shasum -a 256 | cut -d' ' -f1)"
_codex_stored_hash="$(cat "$_codex_hash_file" 2>/dev/null)"

if [[ ! -f "$_codex_completion_file" || "$_codex_current_hash" != "$_codex_stored_hash" ]]; then
  if command -v async_start_worker &> /dev/null; then
    async_start_worker codex -n
    async_register_callback codex _codex_update_completions_callback
    async_job codex _codex_update_completions_job
  else
    # Fallback for when zsh-async is not available
    {
      _codex_update_completions_job &&
        echo "$_codex_current_hash" >| "$_codex_hash_file" &&
        _codex_notify "Codex completions updated."
    } &|
  fi
fi

# If the completion file doesn't exist yet, we need to autoload it and
# bind it to `codex`. Otherwise, compinit will have already done that.
if [[ ! -f "$_codex_completion_file" ]]; then
  typeset -g -A _comps
  autoload -Uz _codex
  _comps[codex]=_codex
fi
