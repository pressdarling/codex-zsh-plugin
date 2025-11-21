#!/usr/bin/env zsh

#
# Test suite for the codex.plugin.zsh plugin.
#
# This script is designed to be run locally by developers to verify the plugin's
# core logic. It covers the following scenarios:
#
#   1.  **Initial Completion Generation:** Verifies that the plugin correctly
#       generates the completion file on the first run when no completion file
#       or hash file exists.
#
#   2.  **Completion Regeneration on Hash Mismatch:** Verifies that the plugin
#       regenerates the completion file when the hash of the `codex` binary
#       changes.
#
#   3.  **No Regeneration When Up-to-Date:** Verifies that the plugin does *not*
#       regenerate completions when they are already up-to-date.
#
#   4.  **Graceful Handling of `shasum` Failure:** Verifies that the plugin
#       still loads existing completions even if the `shasum` command fails,
#       ensuring that users without `shasum` do not lose functionality.
#
# To run the tests, execute this script with `zsh`:
#
#   zsh tests/test_plugin_logic.sh
#

# --- Test Setup ---

# Mock the environment to avoid interfering with the user's system.
ZSH_CACHE_DIR="$(mktemp -d)"
mkdir -p "$ZSH_CACHE_DIR/completions"

# Add the mock completions directory to the `fpath` so that `autoload` can find
# the completion files.
fpath=("$ZSH_CACHE_DIR/completions" $fpath)

# Mock the `codex` command by creating a fake executable in a temporary directory
# and adding it to the PATH.
CODEX_MOCK_DIR="$(mktemp -d)"
export PATH="$CODEX_MOCK_DIR:$PATH"
cat << 'EOF' > "$CODEX_MOCK_DIR/codex"
#!/bin/sh
if [ "$1" = "completion" ] && [ "$2" = "zsh" ]; then
  echo "#compdef codex"
  echo "_codex() { :; }"
else
  echo "mocked codex"
fi
EOF
chmod +x "$CODEX_MOCK_DIR/codex"

# Mock `shasum` to return a predictable hash.
shasum() {
  echo "mocked_hash"
}

# Mock `osascript` to prevent it from actually displaying notifications.
osascript() {
  echo "osascript mocked"
}

# Mock `zsh-async` functions if they don't exist.
if ! command -v async_start_worker &> /dev/null; then
  async_start_worker() {
    : # no-op
  }
  async_job() {
    # In our mock, we call the callback immediately to simulate the async job
    # completing.
    case "$2" in
      codex_update_completions)
        shift 2 # shift away worker name and callback name
        codex_update_completions "$@"
        ;;
      *)
        echo "ERROR: async_job called with unexpected callback: $2"
        return 1
        ;;
    esac
  }
fi

# --- Test Cases ---

# Test 1: Verifies that completions are generated on the first run.
echo "Running Test 1: Initial Completion Generation"
unset -f _codex &>/dev/null
typeset -g -A _comps; _comps=()
_codex_completion_file="$ZSH_CACHE_DIR/completions/_codex"
_codex_hash_file="$ZSH_CACHE_DIR/completions/_codex.hash"
rm -f "$_codex_completion_file" "$_codex_hash_file"

source "${0:A:h}/../codex.plugin.zsh"

if [[ -f "$_codex_completion_file" ]]; then
  echo "  - PASSED: Completion file was created."
else
  echo "  - FAILED: Completion file was not created."
  exit 1
fi
if [[ "$(cat "$_codex_hash_file")" == "nohash" ]]; then
    echo "  - PASSED: Hash file was created with 'nohash'."
else
    echo "  - FAILED: Hash file was not created with 'nohash'."
    exit 1
fi

# Test 2: Verifies that completions are regenerated when the hash mismatches.
echo "Running Test 2: Completion Regeneration on Hash Mismatch"
typeset -g -A _comps; _comps=()
shasum() { echo "new_mocked_hash"; }

source "${0:A:h}/../codex.plugin.zsh"

if [[ "$(cat $_codex_hash_file)" == "new_mocked_hash" ]]; then
  echo "  - PASSED: Hash file was updated with the new hash."
else
  echo "  - FAILED: Hash file was not updated with the new hash."
  exit 1
fi

# Test 3: Verifies that completions are not regenerated when they are up-to-date.
echo "Running Test 3: No Regeneration When Up-to-Date"
typeset -g -A _comps; _comps=()
_codex_run_update() {
  echo "ERROR: _codex_run_update should not be called"
  exit 1
}

source "${0:A:h}/../codex.plugin.zsh"
echo "  - PASSED: _codex_run_update was not called."

# Test 4: Verifies that existing completions are loaded even if `shasum` fails.
echo "Running Test 4: Graceful Handling of shasum Failure"
unset -f _codex &>/dev/null
typeset -g -A _comps; _comps=()

# Create a dummy completion file to simulate it existing from a previous run.
cat << EOF >| "$_codex_completion_file"
#compdef codex
_codex() { :; }
EOF

# Mock `shasum` to fail by returning an empty string.
shasum() { echo ""; }

source "${0:A:h}/../codex.plugin.zsh"

if [[ -n "${_comps[codex]}" ]]; then
  echo "  - PASSED: Completions were loaded even though shasum failed."
else
  echo "  - FAILED: Completions were not loaded."
  exit 1
fi

# --- Cleanup ---
rm -rf "$ZSH_CACHE_DIR"
rm -rf "$CODEX_MOCK_DIR"

echo "\nAll tests passed!"
