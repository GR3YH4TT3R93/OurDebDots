#!/usr/bin/env bash
# Install script for OurDebDots
# Set custom variables
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.config/oh-my-zsh/custom}
FILE_PATH="$HOME/GitHub"
RED=$'\e[31m'
GREEN=$'\e[32m'
YELLOW=$'\e[33m'
ENDCOLOR=$'\e[0m'

error_exit() {
  echo -e "${RED}Error: ${ENDCOLOR}$1" >&2
  exit 1
}

# Update & Upgrade
sudo apt update && yes | sudo apt upgrade || error_exit "${YELLOW}Failed to update packages${ENDCOLOR}."
sudo apt update && sudo apt install zsh openssh-client openssh-server -y

# Set up GitHub CLI
install_gh() {
  sudo mkdir -p -m 755 /etc/apt/keyrings && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update \
    && sudo apt install gh -y
  echo -e "${GREEN}GitHub CLI installed successfully${ENDCOLOR}."
}

install_gh || error_exit "${YELLOW}Failed to install GitHub CLI${ENDCOLOR}."

# Set up GitHub auth
gh auth login || error_exit "${YELLOW}Failed to set up GitHub auth${ENDCOLOR}."

# Set Up Git Credentials
echo -e "${YELLOW}Time to set up your Git credentials${ENDCOLOR}."

# Prompt the user for their Git username
read -rp "${GREEN}Enter your Git username${ENDCOLOR}: " username

# Prompt the user for their Git email
read -rp "${GREEN}Enter your Git email${ENDCOLOR}: " email

# Prompt the user for the name associated with the SSH key
read -rp "${GREEN}Enter a name you would like associated with the SSH key for easy recognition on GitHub${ENDCOLOR}: " key_title

# Prompt the user to choose between global and system-wide configuration
read -rp "${GREEN}Would you like to set your Git configuration system-wide? (Yes/No)${ENDCOLOR}: " choice

# Set Up SSH Key
if [[ ! -f '~/.ssh/"$key_title"' ]]; then
  # Generate an Ed25519 SSH key pair
  ssh-keygen -f ~/.ssh/"$key_title" -t ed25519 -C "$email"
  # Check if an SSH key pair already exists
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/"$key_title"
else
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/"$key_title"
fi

# Give Permissions to GH CLI for adding SSH key to GitHub for Signing Commits
echo "${GREEN}Time to give GH CLI permissions to add SSH key to GitHub for Signature Verification${ENDCOLOR}."
gh auth refresh -h github.com -s admin:ssh_signing_key || error_exit "${YELLOW}Failed to give GH CLI permissions to add SSH key to GitHub for Signature Verification${ENDCOLOR}."

echo "${GREEN}Adding SSH key to GitHub${ENDCOLOR}."
# Add SSH key to GitHub using gh cli
gh ssh-key add ~/.ssh/"$key_title".pub --title "$key_title" --type "signing" || error_exit "${YELLOW}Failed to add SSH key to GitHub${ENDCOLOR}."

# Create file containing SSH public key for verifying signers
awk '{ print $3 " " $1 " " $2 }' ~/.ssh/"$key_title".pub >> ~/.ssh/allowed_signers

if [[ "$choice" == [Yy]* ]]; then
  # Set the Git username and email system-wide
  sudo git config --system user.name "$username"
  sudo git config --system user.email "$email"
  sudo git config --system gpg.format ssh
  sudo git config --system user.signingkey ~/.ssh/"$key_title".pub
  sudo git config --system gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
  sudo git config --system diff.submodule log
  sudo git config --system log.showSignature true
  sudo git config --system submodule.recurse true
  sudo git config --system commit.gpgsign true
  sudo git config --system tag.gpgsign true
  sudo git config --system push.autoSetupRemote true
  sudo git config --system fetch.prune true
  sudo git config --system core.editor nvim
  sudo git config --system core.autocrlf input
  sudo git config --system init.defaultBranch main
  sudo git config --system color.status auto
  sudo git config --system color.branch auto
  sudo git config --system color.interactive auto
  sudo git config --system color.diff auto
  sudo git config --system status.short true
  sudo git config --system alias.assume-unchanged 'update-index --assume-unchanged'
  sudo git config --system alias.assume-changed 'update-index --no-assume-unchanged'
  sudo gh auth setup-git
  # Transfer gh helper config to system config
  cat "$HOME/.gitconfig" >> "/etc/gitconfig"
  # Clean up unnecessary file
  rm "$HOME/.gitconfig"
  echo -e "${GREEN}Git credentials configured system-wide${ENDCOLOR}."
else
  # Set the Git username and email globally
  git config --global user.name "$username"
  git config --global user.email "$email"
  git config --global gpg.format ssh
  git config --global user.signingkey ~/.ssh/"$key_title".pub
  git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
  git config --global diff.submodule log
  git config --global submodule.recurse true
  git config --global log.showSignature true
  git config --global commit.gpgsign true
  git config --global tag.gpgsign true
  git config --global push.autoSetupRerun true
  git config --global fetch.prune true
  git config --global core.editor nvim
  git config --global core.autocrlf input
  git config --global init.defaultBranch main
  git config --global color.status auto
  git config --global color.branch auto
  git config --global color.interactive auto
  git config --global color.diff auto
  git config --global status.short true
  git config --global alias.assume-unchanged 'update-index --assume-unchanged'
  git config --global alias.assume-changed 'update-index --no-assume-unchanged'
  gh auth setup-git
  echo -e "${GREEN}Git credentials configured globally${ENDCOLOR}."
fi

echo -e "${GREEN}Time to install Nala Package Manager, Python3-pip, Python3-neovim, pipx, Perl, Ruby, LuaRocks, LuaJIT, Golang, LazyGit, Ranger, RipGrep, fswatch, fd-find, wget, curl, gettext, logo-ls, libuv1, Fuck, Timewarrior, Taskwarrior, Zoxide and btop${ENDCOLOR}."
sleep 5

# Install Nala Package Manager, Z Shell, Neovim, NodeJS, Python-pip, Ruby, wget, Timewarrior, Taskwarrior, htop
sudo apt update && sudo apt install nala -y
sudo nala install python3-pip python3-neovim pipx perl ruby luarocks luajit golang ripgrep fswatch fd-find ranger curl wget gettext libuv1 thefuck timewarrior taskwarrior zoxide btop -y || error_exit "${YELLOW}Failed to install packages${ENDCOLOR}."

# Install Neovim as a function
install_neovim() {
  echo "${GREEN}Installing Neovim${ENDCOLOR}."
  sleep 2
  cd /tmp
  curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz
  sudo rm -rf /opt/nvim
  sudo tar -C /opt -xzf nvim-linux64.tar.gz
  echo -e "${GREEN}Neovim installed successfully${ENDCOLOR}."
}

install_neovim || error_exit "${YELLOW}Failed to install Neovim${ENDCOLOR}."

# gem install neovim || error_exit "${YELLOW}Failed to install neovim gem package${ENDCOLOR}."
# gem update --system || error_exit "${YELLOW}Failed to update gem${ENDCOLOR}."
# cpan App::cpanminus || error_exit "${YELLOW}Failed to install cpanminus${ENDCOLOR}."
# cpanm -n Neovim::Ext || error_exit "${YELLOW}Failed to install neovim perl module${ENDCOLOR}."

# Install LazyGit
install_lazygit() {
  echo "${GREEN}Installing LazyGit${ENDCOLOR}."
  sleep 2
  cd /tmp
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar xf lazygit.tar.gz
  sudo install lazygit /usr/local/bin
  echo -e "${GREEN}LazyGit installed successfully${ENDCOLOR}."
}

install_lazygit || error_exit "${YELLOW}Failed to install LazyGit${ENDCOLOR}."

# Install Logo-ls
install_logo_ls() {
  echo "${GREEN}Installing logo-ls${ENDCOLOR}."
  sleep 2
  cd /tmp
  git clone https://github.com/canta2899/logo-ls.git
  cd logo-ls
  go build -o logo-ls .
  sudo mv logo-ls /usr/bin
  sudo rm -rf ~/go
  echo -e "${GREEN}logo-ls installed successfully${ENDCOLOR}."
}

install_logo_ls || error_exit "${YELLOW}Failed to install logo-ls${ENDCOLOR}."

# Instal Firefox
install_firefox() {
  echo "${GREEN}Installing Firefox${ENDCOLOR}."
  sleep 2
  wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
  gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); if($0 == "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3") print "\nThe key fingerprint matches ("$0").\n"; else print "\nVerification failed: the fingerprint ("$0") does not match the expected one.\n"}' || error_exit "${YELLOW}Failed to import the key fingerprint${ENDCOLOR}."
  echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
  echo '
  Package: *
  Pin: origin packages.mozilla.org
  Pin-Priority: 1000
  ' | sudo tee /etc/apt/preferences.d/mozilla
  sudo nala install --update firefox -y
  echo -e "${GREEN}Firefox installed successfully${ENDCOLOR}."
}

install_firefox || error_exit "${YELLOW}Failed to install Firefox${ENDCOLOR}."

# Install Oh My Zsh
echo "${GREEN}Installing Oh-My-Zsh${ENDCOLOR}."
sleep 2
export ZSH="$HOME/.config/oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/GR3YH4TT3R93/ohmyzsh/master/tools/install.sh)"

# Clean up excess files
rm ".shell.pre-oh-my-zsh"

# Install Powerlevel10k
echo -e "${GREEN}Installing Powerlevel10k${ENDCOLOR}."
sleep 2
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k" || error_exit "${YELLOW}Failed to install Powerlevel10k${ENDCOLOR}."

# Install Oh My Zsh plugins
echo -e "${GREEN}Installing Zsh Plugins${ENDCOLOR}."
sleep 2
# Auto-Suggestions
echo -e "${GREEN}Installing Zsh Auto-Suggestions${ENDCOLOR}."
sleep 1
git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" || error_exit "${YELLOW}Failed to install zsh-autosuggestions${ENDCOLOR}."

# Completions
echo -e "${GREEN}Installing Zsh Completions${ENDCOLOR}."
sleep 1
git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions" || error_exit "${YELLOW}Failed to install zsh-completions${ENDCOLOR}."

# History Substring Search
echo -e "${GREEN}Installing History Substring Search${ENDCOLOR}."
sleep 1
git clone https://github.com/zsh-users/zsh-history-substring-search "$ZSH_CUSTOM/plugins/zsh-history-substring-search" || error_exit "${YELLOW}Failed to install zsh-history-substring-search${ENDCOLOR}."

# Syntax Highlighting
echo -e "${GREEN}Installing Syntax Highlighting${ENDCOLOR}."
git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" || error_exit "${YELLOW}Failed to install zsh-syntax-highlighting${ENDCOLOR}."

# Git Flow Completions
echo -e "${GREEN}Installing Git Flow Completions${ENDCOLOR}."
sleep 1
git clone https://github.com/bobthecow/git-flow-completion "$ZSH_CUSTOM/plugins/git-flow-completion" || error_exit "${YELLOW}Failed to install git-flow-completion${ENDCOLOR}."

# Zsh Vi Mode
echo -e "${GREEN}Installing Zsh Vi Mode${ENDCOLOR}."
sleep 1
git clone https://github.com/jeffreytse/zsh-vi-mode "$ZSH_CUSTOM/plugins/zsh-vi-mode" || error_exit "${YELLOW}Failed to install zsh-vi-mode${ENDCOLOR}."

# Magic Enter
echo -e "${GREEN}Installing Magic-Enter${ENDCOLOR}."
sleep 1
git clone https://github.com/GR3YH4TT3R93/magic-enter "$ZSH_CUSTOM/plugins/magic-enter" || error_exit "${YELLOW}Failed to install magic-enter${ENDCOLOR}."

# Zsh Nvm
echo -e "${GREEN}Installing Zsh Nvm${ENDCOLOR}."
sleep 1
git clone https://github.com/lukechilds/zsh-nvm "$ZSH_CUSTOM/plugins/zsh-nvm" || error_exit "${YELLOW}Failed to install zsh-nvm${ENDCOLOR}."

# Install Fira Code Nerd Font
install_fira_code() {
  # Define variables
  FIRACODE_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"
  FONT_DIR="/usr/share/fonts/truetype/fira-code"
  # Create the directory for the FiraCode Nerd Fonts
  sudo mkdir -p "$FONT_DIR"
  # Download and extract the FiraCode Nerd Fonts zip file
  echo -e "${YELLOW}Downloading FiraCode Nerd Fonts...${ENDCOLOR}"
  curl -L "$FIRACODE_URL" -o /tmp/FiraCode.zip
  echo -e "${YELLOW}Extracting FiraCode Nerd Fonts...${ENDCOLOR}"
  sudo unzip -q /tmp/FiraCode.zip -d "$FONT_DIR"

  # Refresh the font cache
  echo -e "${YELLOW}Refreshing font cache...${ENDCOLOR}"
  sudo fc-cache -f -v

  # Clean up
  echo -e "${YELLOW}Cleaning up...${ENDCOLOR}"
  rm /tmp/FiraCode.zip

  # Check if the fonts were installed successfully
  if fc-list | grep -q "FiraCode Nerd Font"; then
    echo -e "${GREEN}FiraCode Nerd Fonts installed successfully.${ENDCOLOR}"
  else
    echo -e "${RED}Failed to install FiraCode Nerd Fonts.${ENDCOLOR}"
  fi
}

install_fira_code || error_exit "${YELLOW}Failed to install FiraCode Nerd Fonts${ENDCOLOR}."

# Hide or delete README.md based on whether installed as bare repository or not
# Check if the bare repository exists and is readable
if [ -e "$FILE_PATH/dotfiles" ]; then
  echo "${GREEN}Hiding README.md and Installers in ~/.config/scripts${ENDCOLOR}."
  echo "${GREEN}moving...${ENDCOLOR}"
  mv README.md ~/.config/scripts/README.md || error_exit "${YELLOW}Failed to hide README.md${ENDCOLOR}."
  mv autoinstall.sh ~/.config/scripts/autoinstall.sh || error_exit "${YELLOW}Failed to hide autoinstall.sh${ENDCOLOR}."
  mv install.sh ~/.config/scripts/install.sh || error_exit "${YELLOW}Failed to hide autoinstall.sh${ENDCOLOR}."
  git --git-dir="$HOME/GitHub/dotfiles" --work-tree="$HOME" assume-unchanged README.md autoinstall.sh install.sh || error_exit "${YELLOW}Failed to hide README.md and Installers${ENDCOLOR}."
else
  echo "${YELLOW}Deletinging README.md Installers and .git folder${ENDCOLOR}."
  echo "${GREEN}Removing...${ENDCOLOR}"
  rm -rf README.md autoinstall.sh install.sh .git || error_exit "${YELLOW}Failed to remove README.md Installers and .git folder${ENDCOLOR}."
fi

# Finish Setup
echo -e "${GREEN}Setup Complete! Press Ctrl+D for changes to take effect${ENDCOLOR}."
