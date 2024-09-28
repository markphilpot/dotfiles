.PHONY=all delete

STOW_TARGETS:=espanso fish git neovim starship wezterm zellij zsh

all: brew
	stow --verbose --target=$$HOME --restow $(STOW_TARGETS)

delete: brew
	stow --verbose --target=$$HOME --delete $(STOW_TARGETS)

brew: Brewfile.lock.json

Brewfile.lock.json: Brewfile
	brew bundle