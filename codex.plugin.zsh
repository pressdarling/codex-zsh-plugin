# Autocompletion for the GitHub CLI (codex).
if (( ! $+commands[codex] )); then
  echo "codex command not found. Please install it with 'brew install codex'"
  return
fi

_codex_completion_file="$ZSH_CACHE_DIR/completions/_codex"
_codex_hash_file="$ZSH_CACHE_DIR/completions/_codex.hash"

codex_update_completions() {
  local new_hash="$1"
  codex completion zsh >| "$_codex_completion_file"
  echo "$new_hash" >| "$_codex_hash_file"
  _codex_notify "Codex completions updated."
}

_codex_notify() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    osascript -e 'on run argv' -e 'display notification (item 1 of argv) with title "Oh My Zsh"' -e 'end run' -- "$1"
  fi
}

_codex_current_hash="$(shasum -a 256 "$(command -v codex)" 2>/dev/null | cut -d' ' -f1)"
if [[ -z "$_codex_current_hash" ]]; then
  # shasum failed, can't check for updates.
  return
fi
_codex_stored_hash="$(cat "$_codex_hash_file" 2>/dev/null)"

if [[ ! -f "$_codex_completion_file" || "$_codex_current_hash" != "$_codex_stored_hash" ]]; then
  if command -v async_start_worker &> /dev/null; then
    async_start_worker codex
    async_job codex codex_update_completions "$_codex_current_hash"
  else
    codex_update_completions "$_codex_current_hash" &|
  fi
fi

# If the completion file doesn't exist yet, we need to autoload it and
# bind it to `codex`. Otherwise, compinit will have already done that.
if [[ ! -f "$_codex_completion_file" ]]; then
  typeset -g -A _comps
  autoload -Uz _codex
  _comps[codex]=_codex
fi
