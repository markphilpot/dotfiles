#!/bin/bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

if ! command -v stow >/dev/null 2>&1; then
    if command -v apt-get >/dev/null 2>&1; then
        make apt
    elif command -v brew >/dev/null 2>&1; then
        brew install stow
    else
        echo "stow is not installed and neither apt-get nor brew is available" >&2
        exit 1
    fi
fi

make stow
