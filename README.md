# Dotfiles

This repo manages shell, tmux, editor, and related local configuration.

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

Manual follow-up after `./install.sh`:

- In the Mac App Store, sign in before running `./install.sh` if you want the Brewfile-managed App Store apps installed automatically.
- In iTerm2, set the font to `Source Code Pro for Powerline`.
- In iTerm2, import the settings stored in this project.
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
./install.sh
```

`./install.sh` uses `brew bundle install --file Brewfile --no-upgrade`, so it is the safe "sync me to the current Brewfile" command.

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
