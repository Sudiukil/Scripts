#!/bin/sh

# Init script for fresh installs

# Deps to install
DEPS="git \
vim \
zsh \
zsh-syntax-highlighting \
curl \
screen \
gnupg \
pinentry-tty \
openssh-client \
pass \
keychain \
psmisc"
SSH_GIT_KEY="$HOME/.ssh/rsa/git"
DOTFILES_REPO="git@github.com:Sudiukil/Dotfiles.git"
DOTFILES_DEST="$HOME/Dotfiles"

# Checks
[ -f "$SSH_GIT_KEY" ] || (echo "Please setup a git SSH key before running this script." && exit 1)
[ -x "$(which apt)" ] || (echo "Not using an Debian-based distro? Why...?" && exit 1)

# Update and install deps
echo "Updating and installing essential dependencies..."
sudo apt update
sudo apt upgrade -y
echo "$DEPS" | xargs sudo apt install -y

# Keychain
eval "$(keychain --eval --agents 'ssh,gpg')"

# Setting up gnupg
echo "Setting up gnupg..."
sudo update-alternatives --set pinentry /usr/bin/pinentry-tty
gpg --full-gen-key
echo "keyid-format SHORT" > "$HOME/.gnupg/gpg.conf"
GPG_KEY=$(gpg -k Sudiukil | grep "^sub" | cut -d '/' -f 2 | cut -d ' ' -f 1)
keychain --agents "gpg" --quiet "$GPG_KEY"

# Setting up pass
echo "Setting up pass..."
pass init "$GPG_KEY"
pass add ssh_git

# Setting up SSH
echo "Setting up SSH..."
SSH_ASKPASS="$HOME/.ssh/askpass.sh"
echo 'read S; echo $S' > "$SSH_ASKPASS"
chmod +x "$SSH_ASKPASS"
pass ssh_git | SSH_ASKPASS=$SSH_ASKPASS ssh-add "$SSH_GIT_KEY"

# Getting and setting up Dotfiles
echo "Setting up Dotfiles..."
git clone "$DOTFILES_REPO" "$DOTFILES_DEST"
cd "$DOTFILES_DEST" || exit 1
./update.sh

# Setting up env and shell
echo "Setup up remaining config..."
. "$HOME/.aliases"
getstarship
chsh -s "$(which zsh)"

exit 0