# Autocompletion for the GitHub CLI (codex).
if (( ! $+commands[codex] )); then
  echo "codex command not found. Please install it with 'brew install codex'"
  return
fi

# Ensure the _comps associative array is declared for managing completions.
typeset -g -A _comps

# Register the completion handler. This will be effective as soon as the
# completion file is generated.
autoload -Uz _codex
_comps[codex]=_codex

_codex_completion_file="$ZSH_CACHE_DIR/completions/_codex"
_codex_hash_file="$ZSH_CACHE_DIR/completions/_codex.hash"

codex_update_completions() {
  local new_hash="$1"
  local completion_file="$2"
  local hash_file="$3"
  mkdir -p "$(dirname "$completion_file")"
  codex completion zsh >| "$completion_file"
  echo "$new_hash" >| "$hash_file"
  _codex_notify "Codex completions updated."
}

_codex_notify() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    local message="$1"
    # Escape double quotes for AppleScript
    local safe_message="${message//\"/\\\"}"
    osascript -e 'on run argv' -e 'display notification (item 1 of argv) with title "Oh My Zsh"' -e 'end run' -- "$safe_message"
  fi
}

if [[ ! -f "$_codex_completion_file" ]]; then
  # Completions don't exist, generate them now.
  if command -v async_start_worker &> /dev/null; then
    async_start_worker codex
    async_job codex codex_update_completions "nohash" "$_codex_completion_file" "$_codex_hash_file"
  else
    codex_update_completions "nohash" "$_codex_completion_file" "$_codex_hash_file" &|
  fi
else
  # Completions exist, check if they are outdated.
  _codex_current_hash=$({
    local codex_path
    codex_path="$(command -v codex)"
    if [[ -n "$codex_path" ]]; then
      shasum -a 256 "$codex_path" 2>/dev/null | cut -d' ' -f1
    fi
  })
  if [[ -n "$_codex_current_hash" ]]; then
    # shasum succeeded, check for updates.
    _codex_stored_hash="$(cat "$_codex_hash_file" 2>/dev/null)"

    if [[ "$_codex_current_hash" != "$_codex_stored_hash" ]]; then
      if command -v async_start_worker &> /dev/null; then
        async_start_worker codex
        async_job codex codex_update_completions "$_codex_current_hash" "$_codex_completion_file" "$_codex_hash_file"
      else
        codex_update_completions "$_codex_current_hash" "$_codex_completion_file" "$_codex_hash_file" &|
      fi
    fi
  fi
fi