#!/usr/bin/env bash

RED=$'\e[31m'
GREEN=$'\e[32m'
YELLOW=$'\e[33m'
ENDCOLOR=$'\e[0m'

error_exit() {
  echo -e "${RED}Error: ${ENDCOLOR}$1" >&2
  exit 1
}

# Install NodeJS via NVM
echo "${GREEN}Installing NodeJS via NVM${ENDCOLOR}"
sleep 1
nvm install node

# Install PNPM and Neovim Node Packages
echo "${GREEN}Installing PNPM and Neovim Node Packages${ENDCOLOR}"
sleep 1
npm install -g pnpm neovim

# Clean up
echo "${GREEN}Cleaning up${ENDCOLOR}"
rm -rf ~/.config/scripts/after.sh
sed -i '/if \[ -f ~\/\.config\/scripts\/after\.sh \]; then/,/fi/{/fi/{N;d;};d;}' ~/.zshrc
git --git-dir="$HOME/GitHub/dotfiles" --work-tree="$HOME" assume-unchanged ~/.config/scripts/after.sh || error_exit "${YELLOW}Failed to ignore after.sh${ENDCOLOR}."
echo "${GREEN}Installation Successful! Enjoy Your New System!${ENDCOLOR}"
