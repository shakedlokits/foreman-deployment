#!/bin/bash

###############################################################################
############################ Initial Installations ############################
###############################################################################

# install ssh server and foreman dependencies
dnf -y install ruby{,-devel,gems} java-1.8.0-openjdk.x86_64 \
       rubygem-{nokogiri,bundler,unf_ext,rdoc} redhat-rpm-config \
       nodejs git postgresql-devel gcc-c++ make hostname sqlite-devel \
       libxslt-devel.x86_64 libxml2-devel.x86_64


###############################################################################
############################# Setup Foreman Service ###########################
###############################################################################

# create app directories and set eviornament variables
mkdir -p /usr/src/app
cd /usr/src/app

# setup envirnament variables
RAILS_ENV=production
FOREMAN_APIPIE_LANGS=en
REPO_URL=https://github.com/theforeman/foreman.git
REPO_BRANCH=1.12-stable

# get latest foreman repo, configure and install dependencies
git clone ${REPO_URL} -b ${REPO_BRANCH} /usr/src/app
cp $WORKSPACE/foreman-deployment/Gemfile.local.rb bundler.d/Gemfile.local.rb
cp $WORKSPACE/foreman-deployment/settings.yaml config/settings.yaml
cp $WORKSPACE/foreman-deployment/database.yml config/database.yml

# uncomment when testing develop
# [ -e "package.json" ]
# npm install || exit 0

# apply simplecov patch to foreman stable branch
cp $WORKSPACE/foreman-deployment/simplecov-support.patch simplecov-support.patch
git config --global user.email "slokits@redhat.com"
git config --global user.name "Shaked Lokits"
git am < simplecov-support.patch
git clean -f

# force nokogiri to use system libs
bundle config build.nokogiri --use-system-libraries

# install required packages
bundle --without mysql:mysql2:jenkins:openid:libvirt

# propegate foreman database
RAILS_ENV=test rake db:migrate
