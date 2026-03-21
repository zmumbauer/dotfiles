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
