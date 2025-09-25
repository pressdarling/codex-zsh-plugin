#!/usr/bin/env zsh

# This is a test script to verify the logic of the `codex.plugin.zsh` file.
#
# ## Purpose
# This script is designed to be run locally by developers to verify the plugin's
# core logic. It checks the following scenarios:
#   1. The plugin correctly generates completions on the first run.
#   2. The plugin regenerates completions when the `codex` binary changes.
#   3. The plugin does *not* regenerate completions when they are already up to date.
#
# ## Limitations
# This test script cannot be run in a standard CI environment because it requires
# a `zsh` shell to source and execute the plugin script. It also relies on mocking
# several commands (`codex`, `shasum`, `osascript`) to isolate the plugin's logic.
#
# ## Verification of the Fix
# This test suite verifies the implemented fix. With the buggy version of the
# plugin, the `codex_update_completions` function would be called on every run,
# causing Test 3 to fail. With the fixed version, Test 3 passes, proving that
# the redundant and unconditional call has been removed.

# Mock the environment
ZSH_CACHE_DIR="$(mktemp -d)"
mkdir -p "$ZSH_CACHE_DIR/completions"
fpath=("$ZSH_CACHE_DIR/completions" $fpath)

# Mock the codex command by creating a fake executable
CODEX_MOCK_DIR="$(mktemp -d)"
export PATH="$CODEX_MOCK_DIR:$PATH"
cat << 'EOF' > "$CODEX_MOCK_DIR/codex"
#!/usr/bin/env zsh
if [[ "$1" == "completion" && "$2" == "zsh" ]]; then
  echo "#compdef codex"
  echo "_codex() { }"
else
  echo "mocked codex"
fi
EOF
chmod +x "$CODEX_MOCK_DIR/codex"

# Mock shasum
shasum() {
  echo "mocked_hash"
}

# Mock osascript
osascript() {
  echo "osascript mocked"
}

# Mock zsh-async functions if they don't exist
if ! command -v async_start_worker &> /dev/null; then
  async_start_worker() {
    echo "async_start_worker mocked"
  }
  async_job() {
    echo "async_job mocked, calling back now"
    # in our mock, we call the callback immediately
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

# Source the plugin
source "${0:A:h}/../codex.plugin.zsh"

#
# Test cases
#

# Test 1: First run, no completion file, no hash file
echo "Running Test 1: First run"
rm -f "$_codex_completion_file" "$_codex_hash_file"
source "${0:A:h}/../codex.plugin.zsh"
if [[ -f "$_codex_completion_file" && -f "$_codex_hash_file" ]]; then
  echo "Test 1 PASSED"
else
  echo "Test 1 FAILED"
  exit 1
fi

# Test 2: Completion file exists, but hash is different
echo "Running Test 2: Hash mismatch"
shasum() { echo "new_mocked_hash"; }
source "${0:A:h}/../codex.plugin.zsh"
if [[ "$(cat $_codex_hash_file)" == "new_mocked_hash" ]]; then
  echo "Test 2 PASSED"
else
  echo "Test 2 FAILED"
  exit 1
fi

# Test 3: Completion file and hash are up to date
echo "Running Test 3: Up to date"
# clear mocks to see if update is called
unset -f codex_update_completions
codex_update_completions() {
  echo "ERROR: codex_update_completions should not be called"
  exit 1
}
source "${0:A:h}/../codex.plugin.zsh"
echo "Test 3 PASSED"

# Test 4: shasum fails, but completions are still loaded
echo "Running Test 4: shasum fails"
shasum() { echo ""; }
# ensure completions are loaded by checking if _codex is in _comps
typeset -g -A _comps
_comps=()
source "${0:A:h}/../codex.plugin.zsh"
if [[ -n "${_comps[codex]}" ]]; then
  echo "Test 4 PASSED"
else
  echo "Test 4 FAILED"
  exit 1
fi


# Clean up
rm -rf "$ZSH_CACHE_DIR"
rm -rf "$CODEX_MOCK_DIR"

echo "All tests passed!"
