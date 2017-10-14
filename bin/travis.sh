#!/usr/bin/env bash

# Exit on error
set -e
set -o pipefail

# Install mkdocs and required extensions
pip install mkdocs
pip install pymdown-extensions

# Install node
curl -sS https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update
sudo apt-get install yarn

# Install gulp
yarn add gulp-cli -g
yarn add gulp -D

# Install php
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update
apt-get install -y php7.0 php7.0-cli

exit 0;
