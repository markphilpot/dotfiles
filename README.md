# dotfiles

Personal dotfiles for macOS and for Linux dev containers such as GitHub
Codespaces. Config files are linked into `$HOME` with
[GNU Stow](https://www.gnu.org/software/stow/); on a Mac, packages and apps
are installed from a Brewfile split into profiles.

The repo must live at `~/.dotfiles`. The shell configs refer to that path.

## Set up a new Mac

1. Install [Homebrew](https://brew.sh).
2. Clone the repo:

   ```bash
   git clone git@github.com:markphilpot/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

3. Choose this machine's profiles (see [Brewfile profiles](#brewfile-profiles)):

   ```bash
   mkdir -p ~/.config/dotfiles
   echo "apps dev personal" > ~/.config/dotfiles/profiles
   ```

4. Install packages and apps, then link the config files:

   ```bash
   make brew
   make
   ```

`make brew` adopts apps that are already in `/Applications` instead of
installing a second copy.

## Codespaces and dev containers

Set this repo as your dotfiles repository in the
[Codespaces settings](https://github.com/settings/codespaces). A new codespace
clones it and runs `install.sh`, which installs stow with `apt-get` if it is
missing and then runs `make`.

On Linux the `git-macos` package is skipped, so the commit signing, keychain
and 1Password settings never reach the container and Codespaces keeps control
of git credentials. The shell configs only initialise tools that are
installed, so a missing tool does not break the shell.

## Layout

Each top-level folder is a stow package whose contents mirror `$HOME`.

| Folder | What it holds |
|---|---|
| `bash`, `zsh`, `fish` | Shell configs |
| `git` | Git config and global ignore file, for every platform |
| `git-macos` | `~/.gitconfig.local`: signing and credential settings, macOS only |
| `neovim`, `wezterm`, `ghostty`, `zellij`, `starship`, `espanso` | Tool configs |
| `brew` | Brewfile profiles and the `brew-sync` ignore list (not stowed) |
| `bin` | Scripts on the `PATH` (not stowed) |

Files that already exist in `$HOME` are moved aside to
`<name>.backup-<timestamp>` before linking.

## Brewfile profiles

The root `Brewfile` loads `brew/core.rb` plus the profiles listed in
`~/.config/dotfiles/profiles`. That file is not tracked, so each machine
chooses its own set. Names are separated by spaces or newlines.

| Profile | Contents |
|---|---|
| `core` | Shell environment, git, editors and everyday command-line tools. Always loaded. |
| `apps` | Desktop apps for any Mac used interactively |
| `browsers` | Web browsers |
| `dev` | Development tools, editors and IDEs |
| `ios` | iOS and mobile development |
| `media` | Audio, video, image and document conversion tools |
| `audio` | Audio recording, routing and music production apps |
| `personal` | Productivity, media and everyday apps |
| `mas` | Mac App Store apps |

To add a profile for a single run:

```bash
HOMEBREW_DOTFILES_PROFILES="audio" make brew
```

A new profile is a new `brew/<name>.rb` file.

## Keeping the Brewfile up to date

`brew-sync` compares what is installed on the Mac with every profile:

```bash
brew-sync                                # report what is not recorded
brew-sync add                            # choose a profile for each unrecorded app
brew-sync add zoom --profile apps        # record a cask by name
brew-sync add ripgrep --profile core --formula
brew-sync add --mas --profile mas         # record every unrecorded App Store app
brew-sync ignore "Safari.app"            # stop reporting something
```

It matches apps in `/Applications` to casks by app name. Casks that install
from a `.pkg` cannot be matched that way; record those by name and add the
app to `brew/ignore.txt`.

App Store apps are recorded as `mas` entries by their store ID. Installing
them needs the App Store app signed in to an Apple ID that owns them.

## Make targets

| Target | What it does |
|---|---|
| `make` or `make stow` | Link every package into `$HOME` |
| `make restow` | Remove and re-create the links |
| `make unstow` | Remove the links |
| `make brew` | Install everything in the enabled Brewfile profiles |
| `make apt` | Install stow with `apt-get` (Linux) |
| `make test` | Run the tests for the scripts in `bin/` |
