# Bug Report: Redundant, Blocking Call in `codex.plugin.zsh`

## Bug Identification

*   **File:** `codex.plugin.zsh`
*   **Location:** The bug is caused by two separate blocks of code.
    1.  Lines 15-18: A synchronous call to `codex_update_completions`.
    2.  Lines 43-48: An unconditional asynchronous/background call to `codex_update_completions`.

## Description of the Bug

The `codex.plugin.zsh` script is designed to asynchronously update `codex` CLI completions to avoid slowing down shell startup. However, the original code had two major issues that defeated this purpose:

1.  **Synchronous, Blocking Call:** When the script detects that completions need to be updated (either because they don't exist or the `codex` binary has changed), it *immediately* calls the `codex_update_completions` function. This call is synchronous and blocks the shell from continuing until the completions are generated, which can be slow. This negates the primary benefit of the asynchronous features.

2.  **Redundant and Unconditional Call:** At the end of the script, there is another call to `codex_update_completions`, either using `zsh-async` or a background job (`&|`). This call is made on *every* shell startup, regardless of whether the completions actually need to be updated. This is inefficient and redundant.

The combination of these two issues results in a poor user experience, with a slow shell startup when completions need updating, and unnecessary processes being spawned on every shell start.

## Proposed and Implemented Fix

The fix involved refactoring the script to address both issues:

1.  **Eliminate Synchronous Call:** The initial, synchronous call to `codex_update_completions` was removed.
2.  **Consolidate Update Logic:** The logic for updating completions is now consolidated into a single `if` block. The update is triggered only if:
    - The completion file does not exist, **or**
    - The hash of the codex binary can be computed (i.e., shasum succeeds) **and** the current hash does not match the stored hash.
    Otherwise, no update is performed. This ensures the update logic gracefully handles cases where shasum is unavailable or fails.
3.  **Ensure Asynchronous Execution:** The update is now triggered only when necessary, and it is always run asynchronously (using `zsh-async` if available, or a background process otherwise).
4.  **Code Cleanup:** The functions were moved to the top of the file for better readability, and the logic for storing the new hash was moved into the `codex_update_completions` function to ensure it's only written when an update actually occurs.

This fix ensures that the plugin behaves as advertised in the `README.md`, providing a non-blocking experience for the user.
