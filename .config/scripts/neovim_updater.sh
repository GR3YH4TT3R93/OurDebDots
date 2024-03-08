#!/usr/bin/env zsh
RED=$'\e[31m'
GREEN=$'\e[32m'
YELLOW=$'\e[33m'
ENDCOLOR=$'\e[0m'

error_exit() {
  echo -e "${RED}Error: ${ENDCOLOR}$1" >&2
  exit 1
}

install_neovim() {
  echo "${GREEN}Installing Neovim${ENDCOLOR}."
  sleep 2
  curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz
  sudo rm -rf /opt/nvim
  sudo tar -C /opt -xzf nvim-linux64.tar.gz
  rm nvim-linux64.tar.gz
  echo -e "${GREEN}Neovim installed successfully${ENDCOLOR}."
}

install_neovim || error_exit "${YELLOW}Failed to install Neovim${ENDCOLOR}."
