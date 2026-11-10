.DEFAULT_GOAL := stow

apt:
	sudo apt-get update
	sudo apt-get install -y stow

brew:
	brew bundle --file=Brewfile

test:
	/usr/bin/python3 -m unittest discover -s tests

# https://unix.stackexchange.com/a/771880
# List of packages to manage with stow
#PACKAGES ?= $(filter-out .git .github, $(wildcard */))
PACKAGES ?= espanso fish ghostty git neovim starship wezterm zellij zsh bash

# Packages that only apply on macOS (signing, keychain, 1Password)
OS ?= $(shell uname -s)
ifeq ($(OS),Darwin)
PACKAGES += git-macos
endif

# Directory where stow will look for packages. Default is current directory
DIR ?= $$(pwd)

# Default location where stow will create symbolic links
TARGET ?= ${HOME}

IGNORE ?= \.DS_Store

# Stow command to create links
STOW_CMD = stow \
    --dir="${DIR}" \
    --target="${TARGET}" \
    --ignore="${IGNORE}" \
    --ignore="\.DS_Store" \
    --ignore=".*\.template" \
    --no-folding \
    --verbose

# Function to backup existing files for a specific package if they exist.
# Matches the conflict message from both stow 2.3 and stow 2.4.
define backup_if_exists
    ${STOW_CMD} --no ${1} 2>&1 | \
        sed -nE \
            -e 's/.*existing target is neither a link nor a directory: (.*)/\1/p' \
            -e 's/.*over existing target (.*) since neither a link nor a directory.*/\1/p' | \
    while IFS= read -r file; do \
        filepath="${TARGET}/$$file"; \
        backup_suffix="backup-$$(date -u +%Y%m%d%H%M%S)"; \
        echo "Creating backup $$filepath.$$backup_suffix"; \
        mv "$$filepath" "$$filepath.$$backup_suffix"; \
    done
endef

# Default rule to create symbolic links for all packages
all: stow

# Rule to backup existing configurations
backup:
	@echo "Checking for existing files to backup..."
	@$(foreach package,$(PACKAGES), \
        $(call backup_if_exists,$(package));)

# Rule to link configurations using stow
stow: backup
	@echo "Applying stow for packages..."
	@$(foreach package,${PACKAGES}, \
        $(STOW_CMD) ${package};)

# Rule to remove symbolic links
unstow:
	@echo "Removing stow links for packages..."
	@$(foreach package,$(PACKAGES), \
        $(STOW_CMD) -D $(package);)

# Rule to reapply symbolic links
restow: backup unstow stow

# Rule to display help
help:
	@echo ""
	@echo "\033[1mUSAGE\033[0m"
	@echo ""
	@echo "  make [target]"
	@echo ""
	@echo "\033[1mTARGETS\033[0m"
	@echo ""
	@echo "  stow    - Create symlinks for all packages (default)"
	@echo "  restow  - Reapply symlinks for all packages"
	@echo "  unstow  - Remove symlinks for all packages (\033[31mcaution\033[0m)"
	@echo "  brew    - Install everything in the Brewfile"
	@echo "  apt     - Install stow with apt (Linux)"
	@echo "  test    - Run the tests for the scripts in bin/"
	@echo "  help    - Show this help message"
	@echo ""

.PHONY: all backup stow unstow restow help apt brew test