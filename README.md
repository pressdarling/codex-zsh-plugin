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

Once the plugin is installed, you can use the `codex` command as usual. The plugin will automatically handle completions for you.
You can also manually trigger completions by typing `codex` followed by a space and then pressing `Tab`. The plugin will generate completions based on the current context.

## Troubleshooting

If you encounter issues with the plugin, here are some common troubleshooting steps:

### Common Error Scenarios and Solutions

1.  **`codex` command not found:** If you see an error message like `codex: command not found`, it means the `codex` CLI is not installed or not in your `$PATH`.
    *   **Solution:** Install the `codex` CLI using Homebrew: `brew install codex`. If it's already installed, ensure that your `$PATH` includes the directory where Homebrew installs binaries (usually `/usr/local/bin` or `/opt/homebrew/bin`).

2.  **Completions not working:** If completions are not appearing when you press `Tab` after typing `codex`, there might be an issue with the completion cache.
    *   **Solution:** Manually regenerate the completions by running the following command:
        ```sh
        codex completion zsh >| "$ZSH_CACHE_DIR/completions/_codex"
        ```
        Then, restart your terminal.

3.  **Notifications not appearing:** If you're on macOS and not receiving notifications when completions are updated, there might be an issue with your system's notification settings.
    *   **Solution:** Make sure that your terminal application has permission to display notifications in your macOS System Settings.

### Debug Mode Instructions

To enable debug mode and get detailed logs for all zsh plugins, you can run `zsh -xv` in your terminal. This will print a lot of information, but it can be helpful for identifying the source of the problem.

You can also check the plugin's cache files for any errors:

```sh
# View the completion file
cat "$ZSH_CACHE_DIR/completions/_codex"

# View the hash file
cat "$ZSH_CACHE_DIR/completions/_codex.hash"
```

### Reporting Issues

If you've tried the troubleshooting steps above and are still having issues, please open an issue on the [GitHub repository](https://github.com/pressdarling/codex-zsh-plugin/issues).

When reporting an issue, please include the following information:

*   **A clear and concise description of the problem.**
*   **The output of `codex --version`.**
*   **The output of `zsh --version`.**
*   **The contents of your `~/.zshrc` file (or a link to it).**
*   **Any error messages you're seeing in your terminal.**
*   **Steps to reproduce the issue.**

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
