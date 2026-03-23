# Dotfiles

This repo manages shell, tmux, editor, and related local configuration.

## Repo Layout

- `config_files/` holds tracked home-directory config files and shell/tmux assets.
- `terminal/` holds importable terminal app exports such as iTerm2 and Terminal.app profiles.
- `nvim/` is the first-party Neovim overlay for this repo; its vendored base config lives under `nvim/vendor/neovim-dotfiles`.
- `vim/` is a small classic Vim runtime kept for remote or minimal machines that do not have Neovim.

## Bootstrap

Run the installer from the repo root with:

```zsh
./install.sh
```

`setup` by itself is not a reliable command name because many systems already
have another executable with that name earlier on `PATH`.

`./install.sh` delegates to the repo's top-level `setup` script and is safe to re-run.
Package installation is managed from `Brewfile` via `brew bundle`, including
Homebrew formulae, casks, Mac App Store apps, and `uv`/`go`/`cargo` tools.
If you want Mac App Store apps installed automatically, sign into the App Store
before running the installer or rerun it afterward.

You can also run only specific setup sections. For example:

```zsh
./install.sh --github --homebrew --nvim
```

For a lean remote-development setup, use:

```zsh
./install.sh --remote-dev
```

From a fresh container, the full bootstrap can be done with one command:

```zsh
git clone https://github.com/zmumbauer/dotfiles.git && cd dotfiles && GITHUB_USERNAME=your-github-user GITHUB_EMAIL=you@example.com ./install.sh --remote-dev
```

Use HTTPS for the first clone because GitHub SSH is configured by the installer.
`./install.sh --remote-dev` initializes the shell and tmux submodules it needs.

If you want the Neovim setup later, initialize the Neovim submodules and then run
the Neovim section:

```zsh
git submodule update --init nvim && git -C nvim submodule update --init --recursive && ./install.sh --nvim
```

That extra step is separate because the Neovim overlay depends on the nested
submodule `nvim/vendor/neovim-dotfiles`.

When no section flags are provided, `./install.sh` runs every section. Use
`./install.sh --help` to see the full list of available section flags.

Config-related sections are individually selectable with flags like `--shell`,
`--git`, `--vim`, `--nvim`, `--tmux`, and `--eza`. `--configs` is a
convenience alias that runs all of those config sections together.
`--remote-dev` installs a minimal Homebrew toolchain (`git`, `gh`, `tmux`,
`zsh`, and `oh-my-posh`) and then runs the matching `github`, `shell`, and
`tmux` setup sections without installing the full `Brewfile`. That package set
lives in `./Brewfile.remote-dev`.

Manual follow-up after `./install.sh`:

- In the Mac App Store, sign in before running `./install.sh` if you want the Brewfile-managed App Store apps installed automatically.
- In iTerm2, set the font to `Source Code Pro for Powerline`.
- In iTerm2, import the settings stored in `terminal/`.
- Install Cactus VPN manually from https://www.cactusvpn.com/.

If you want to force the GitHub setup flow even when the machine already appears
configured, run:

```zsh
FORCE_GITHUB_SETUP=1 ./install.sh
```

## Keeping It Up To Date

Use `update_dotfiles` from an interactive Zsh session to update the repo and all configured submodules:

```zsh
update_dotfiles
```

What it does:

1. Fast-forwards the main dotfiles repo from `origin/main`.
2. Syncs submodule URLs from `.gitmodules`.
3. Initializes any missing submodules.
4. Updates each submodule to the branch configured in `.gitmodules`.

Current submodule branches:

- `nvim` tracks `main`
- `config_files/ohmyzsh` tracks `master`
- `config_files/ohmytmux` tracks `master`

Important behavior:

- `update_dotfiles` is a "float to latest upstream" command for submodules, not a "stay pinned to the exact gitlinks already committed in this repo" command.
- If a submodule advances, the top-level repo will become dirty until you review and commit the updated gitlink.
- If the top-level repo has local changes that block `git pull --ff-only`, the function will stop instead of trying to merge.

To review submodule changes after running `update_dotfiles`:

```zsh
git status
git diff --submodule=log
```

If you want to keep the exact submodule revisions already committed in this repo instead of floating them forward, use:

```zsh
git pull --ff-only origin main
git submodule sync --recursive
git submodule update --init --recursive
```

## Keeping Apps Up To Date

`update_dotfiles` updates the repo and submodules. It does not install or upgrade Homebrew or Mac App Store packages by itself.

Recommended workflow from the repo root:

1. Pull the latest dotfiles, including any `Brewfile` or custom cask changes:

```zsh
update_dotfiles
```

2. See what Homebrew or App Store packages are behind:

```zsh
brew update
brew outdated
brew outdated --cask
mas outdated
```

3. Install anything newly added to `Brewfile` without upgrading existing packages:

```zsh
./install.sh --homebrew
```

`./install.sh --homebrew` uses `brew bundle install --file Brewfile --no-upgrade`, so it is the safe "sync me to the current Brewfile" command.

4. Upgrade Brewfile-managed formulae and casks to the latest available versions:

```zsh
brew bundle install --file Brewfile --upgrade
```

5. If you also want Brewfile-managed Mac App Store apps updated, make sure you are signed into the App Store, then run:

```zsh
mas upgrade
```

Useful checks:

- `brew bundle check --file Brewfile --no-upgrade` verifies that everything declared in `Brewfile` is installed.
- `brew livecheck --cask zmumbauer-cactusvpn zmumbauer-librescore` checks the custom casks in this repo for newer upstream versions.

## Adding Mac App Store Apps

Use the MAS picker to search by name, pick from an interactive list, insert the selected app into the `Brewfile`, and then try to install it immediately with `mas`:

```zsh
add_mas_app
```

You can also pass the initial search text on the command line:

```zsh
add_mas_app SiteSucker
```

The underlying script lives at `./scripts/add_mas_app.sh`. It uses `mas search` for results, `gum filter` for the TUI picker, keeps the `mas` entries in `Brewfile` sorted by app name, and runs `mas install` for newly added apps when the App Store is signed in.
