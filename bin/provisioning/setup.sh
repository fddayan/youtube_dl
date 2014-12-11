#!/bin/bash

BARE_REPO_ROOT=~/src/youtube_dl.git
export PROJECT_ROOT=$(pwd)

set -e -u -x

## Install ubuntu packages
sudo apt-get update
sudo apt-get -y install htop build-essential git libpq-dev curl libpcre3-dev
## -----------------------------------------------------------

./install_ffmpeg.sh

## Install rbenv, ruby and basic gems
cd ~
git clone git://github.com/sstephenson/rbenv.git .rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
mkdir -p ~/.rbenv/plugins
cd ~/.rbenv/plugins
git clone git://github.com/sstephenson/ruby-build.git
cd $PROJECT_ROOT
rbenv install 2.1.0
rbenv global 2.1.0

cat > ~/.gemrc <<GEMRC
---
:backtrace: false
:benchmark: false
:bulk_threshold: 1000
:sources:
- http://rubygems.org
:update_sources: true
:verbose: true
gem: --no-ri --no-rdoc
GEMRC

rbenv rehash
## -----------------------------------------------------------


## Install gems
cd $PROJECT_ROOT
rbenv exec gem install bundler
rbenv exec bundle install
rbenv rehash
## -----------------------------------------------------------
