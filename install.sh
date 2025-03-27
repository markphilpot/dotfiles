#!/bin/bash

make apt
make stow

# Override .gitconfig for codespaces
rm ~/.gitconfig.local