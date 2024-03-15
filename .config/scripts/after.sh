#!/usr/bin/env zsh

# Install NodeJS via NVM
echo "Installing NodeJS via NVM"
sleep 1
nvm install node

# Install PNPM and Neovim Node Packages
echo "Installing PNPM and Neovim Node Packages"
sleep 1
npm install -g pnpm neovim

# Clean up
echo "Cleaning up"
rm -rf ~/.config/scripts/after.sh
sed -i '/if \[ -f ~\/\.config\/scripts\/after\.sh \]; then/,/fi/d' ~/.zshrc
