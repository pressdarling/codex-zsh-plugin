# codex Oh My Zsh Plugin

This largely vibecoded plugin provides completions for OpenAI's [Codex](https://github.com/openai/codex) CLI tool, with several enhancements for a smooth experience on macOS.

## Features

*   **Asynchronous, Non-Blocking Completion Generation:** Completions are generated in the background, so your shell startup is never delayed. Uses `zsh-async` if available for the best performance.
*   **Smart Caching:** Completions are automatically regenerated only when the `codex` CLI tool is updated, not on every shell start.
*   **Native macOS Notifications:** Receive a system notification when your `codex` completions have been updated.
*   **Helpful Dependency Checks:** If the `codex` CLI is not found, the plugin will provide instructions on how to install it using Homebrew.

## Requirements

*   [Codex CLI](https://github.com/openai/codex)
*   `shasum` (installed by default on macOS)

## Optional Requirements

*   [zsh-async](https://github.com/mafredri/zsh-async): For a fully non-blocking experience. If not installed, the plugin will fall back to a standard background process.

## Installation

### Oh-My-Zsh

If you're using [Oh My Zsh](https://ohmyz.sh/), the easiest way to install this plugin is to use the built-in plugin manager. 

PRs are welcome to add this plugin to the official Oh My Zsh plugins list, but until then, you can install it manually as described below.

To use it, add `codex` to the plugins array in your `~/.zshrc` file:

```sh
plugins=(... codex)
```

Reload Oh My Zsh by running:

```sh
omz reload
```

Or restart zsh:
```sh
# don't use `source ~/.zshrc` unless you love shaving yaks
exec zsh
```

### Manual Installation

If you prefer to install the plugin manually, clone the repository into your custom plugins directory.

If you are using a custom plugins directory (recommended), you can set the `$ZSH_CUSTOM` environment variable in your `~/.zshrc` file:

```sh
export ZSH_CUSTOM=/path/to/your/custom/plugins
```

If you don't have a custom plugins directory set up, you can use the default one provided by Oh My Zsh, which is usually `~/.oh-my-zsh/custom/plugins`. Other common paths include `~/.zsh/custom/plugins` or `/path/to/your/zsh/custom/plugins`. If don't have a `$ZSH_CUSTOM` directory, you can create it first:

```sh
if [ ! -d "$ZSH_CUSTOM" ]; then
  mkdir -p ~/.zsh/custom/plugins
  echo 'export ZSH_CUSTOM=~/.zsh/custom/plugins' >> ~/.zshrc
fi
```

Then, clone the repository into your `$ZSH_CUSTOM/plugins` directory:

```sh
# with HTTPS:
git clone https://github.com/pressdarling/codex-zsh-plugin.git $ZSH_CUSTOM/plugins
```

```sh
# or with SSH:
git clone git@github.com/pressdarling/codex-zsh-plugin.git $ZSH_CUSTOM/plugins
```

```sh
# or with gh CLI:
gh repo clone pressdarling/codex-zsh-plugin $ZSH_CUSTOM/plugins
```

```sh
# or with curl:
curl -L https://raw.githubusercontent.com/pressdarling/codex-zsh-plugin/main/tools/install.sh | bash -s -- --path $ZSH_CUSTOM/plugins
```

Then, restart your terminal or source your `~/.zshrc` file:

```sh
exec zsh
```

### I hate installing things and I don't trust random GitHub repositories

Bro (statistically speaking), I get it. If you don't want to install this plugin, you can still use the `codex` CLI tool directly without any enhancements. Just make sure the `codex` command is in your `$PATH`.

You can even get completions in your own terminal with a simple `codex completion zsh` command, but you won't get the benefits of caching or updates. You can either run this once (faster, but no updates) or set it up
to run automatically on shell startup (slower, but will update when codex does).

Either way, you can use the following command to generate completions and save them to a file:

```shell
# assuming codex is installed and in your $PATH
# if you don't have a $ZSH_CACHE_DIR, you'll need to create it first
eval "$(codex completion zsh)" > $ZSH_CACHE_DIR/_codex
```

Hell, you can even peck at your keyboard manually like some kind of caveman, but I wouldn't recommend it unless yuo relaly lvoe typing acucrately ;)

## Usage

Once the plugin is installed, completions will be available automatically.

### Before

Without this plugin, you would have to manually type out every command and argument:

```sh
codex complete "write a python function to find the nth fibonacci number"
```

### After

With this plugin, you can simply type `codex` and press `<Tab>` to see all available commands.

For example, to complete the same command as above, you could type:

```sh
codex c<Tab> # expands to "codex complete"
```

Then, you can add your prompt:
```sh
codex complete "write a python function to find the nth fibonacci number"
```

The plugin also provides completions for all of `codex`'s flags and arguments, saving you time and preventing typos.

## Examples

Here are some examples of how the completions work in practice.

### Command Completion

Typing `codex ` and pressing `<Tab>` will show you all available commands:

```
$ codex <Tab>
complete    -- Generate completions for a prompt
edit        -- Edit a file with a prompt
help        -- Show help for a command
history     -- Show the history of prompts
login       -- Log in to the Codex service
logout      -- Log out of the Codex service
status      -- Show the status of the Codex service
```

### Flag Completion

The plugin also provides completions for flags. For example, if you type `codex complete --` and press `<Tab>`, you'll see all the available flags for the `complete` command:

```
$ codex complete --<Tab>
--engine         -- The engine to use for the completion
--help           -- Show help for the command
--json           -- Output the completion in JSON format
--max-tokens     -- The maximum number of tokens to generate
--stop           -- The stop sequence for the completion
--temperature    -- The temperature to use for the completion
--user           -- The user to generate the completion for
```

### Argument Completion

Some flags require arguments, and the plugin can help with those too. For example, the `--engine` flag for the `complete` command requires an engine name. If you type `codex complete --engine ` and press `<Tab>`, you'll see a list of available engines:

```
$ codex complete --engine <Tab>
davinci
curie
babbage
ada
```

## Troubleshooting

If you encounter issues with the plugin, here are some common troubleshooting steps:

1.  **Check Dependencies:** Ensure that the `codex` CLI is installed and available in your `$PATH`. You can verify this by running `codex --version`.
2.  **Update the Plugin:** If you have an outdated version of the plugin, run `git pull` in the plugin directory to get the latest changes.
3.  **Check for Errors:** Look for any error messages in your terminal when you try to use the plugin. If you see an error about missing dependencies, follow the instructions provided by the plugin. You can get *extremely* detailed logs for all zsh plugins by running `zsh -xv` in your terminal.
4.  **Completions Not Working:** If completions are not showing up, try clearing the cache and regenerating them:

    ```sh
    rm $ZSH_CACHE_DIR/_codex
    exec zsh
    ```
5.  **"command not found: codex"**: If you see this error, it means the `codex` CLI tool is not in your `$PATH`. Make sure you have installed it correctly and that its location is in your `$PATH`. If you installed it with Homebrew, the default location is usually `/usr/local/bin`, which should be in your `$PATH` already.

## License
This plugin is dual-licensed under the [MIT License](https://opensource.org/license/mit/) and [The Unlicense](https://unlicense.org/). You can choose either license for your use.

## Contributing
We love contributions! If you have ideas for improvements, bug fixes, or new features, please open an issue and/or submit a pull request. It will most likely languish as this is a personal project, but I will address issues and PRs as time allows. 

Alternatively, you can also fork the repository and make changes directly, or straight up copy the code into your own plugin if you prefer not to use this one. It's free ~~real estate~~ software, after all.

## Acknowledgements
This plugin is inspired by every other mf out there who has ever created a zsh plugin, and it addresses the author's need for a more efficient and user-friendly way to use the `codex` CLI tool in zsh. Special thanks to the OpenAI team for creating the Codex CLI and to the zsh community for their contributions to zsh plugins.

## Author

*   **Original Author:** [@pressdarling](https://github.com/pressdarling)
*   **Enhancements:** Gemini
