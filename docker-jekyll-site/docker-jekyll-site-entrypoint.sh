#!/bin/bash


# Modeled on:
#
# https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/

set -e

# Ensure our repository is defined
if [[ ! -n $GIT_REPOSITORY_SITE ]] ; then
  echo "\$GIT_REPOSITORY_SITE not defined"
  exit 1
fi

# Ensure our branch is defined
if [[ ! -n $GIT_REPOSITORY_SITE_BRANCH ]] ; then
  GIT_REPOSITORY_SITE_BRANCH="master"
fi

# Pull the repository into our site directory

# If we have an existing repository, but not the right one, we need to start from scratch
GIT_REPOSITORY_EXISTING=$(git --git-dir=/docker-jekyll-site/site/.git remote -v | grep -m 1 origin | awk -F'[ \t]' '{print $2}')
echo "Desired Repository: $GIT_REPOSITORY_SITE"
echo "Existing Repository: $GIT_REPOSITORY_EXISTING"
if [[ -d /docker-jekyll-site/site ]] ; then
  if [[ $GIT_REPOSITORY_SITE != $GIT_REPOSITORY_EXISTING ]] ; then
    rm -rf /docker-jekyll-site/site/*
    rm -rf /docker-jekyll-site/site/.[!.]?*
  fi
fi

# Check whether this is our first time running, such that we need to clone
if [[ ! -d /docker-jekyll-site/site/.git ]] ; then
  git clone $GIT_REPOSITORY_SITE /docker-jekyll-site/site
fi

# The presence of a lock means somebody else did not finish
# We need to clear the lock so our git commands can execute
# Saw this when the host disk filled, hopefully should not need this
# But it allows us to recover without needing to explicitly detect
# this situation and delete the container
if [[ -f /docker-jekyll-site/site/.git/index.lock ]] ; then
  rm -f /docker-jekyll-site/site/.git/index.lock
fi

# Change into the directory
GIT_PULL_PRIOR_DIRECTORY=$(pwd)
cd /docker-jekyll-site/site

# Ensure we have the branch we want, but nothing else
# http://grimoire.ca/git/stop-using-git-pull-to-deploy
git fetch --all
git checkout --force origin/$GIT_REPOSITORY_SITE_BRANCH

# Restore our directory
cd $GIT_PULL_PRIOR_DIRECTORY



# Change into the site directory
cd /docker-jekyll-site/site

# Link in our pre-installed node_modules
ln -s /docker-jekyll-site-temp/node_modules node_modules

# Ensure we have our python dependencies
pip install -r requirements3.txt

# Because sites may not be current, their ruby version may not match our system install
# The Gemfile.lock in our website will tell us what version it's expecting
RUBY_SYSTEM=$(ruby -v | awk '{ if (match($0, /ruby (.*)p/, arr)) print arr[1] }')
RUBY_SITE=$(awk '{ if(match($0, /ruby (.*)p/, arr)) print arr[1] }' /docker-jekyll-site/site/Gemfile.lock)
if [[ "$RUBY_SYSTEM" != "$RUBY_SITE" ]] ; then
  ruby-install --no-reinstall ruby $RUBY_SITE
  source /usr/local/share/chruby/chruby.sh
  chruby ruby-$RUBY_SITE
fi

# Build our site
invoke build_production

if [[ -f /docker-jekyll-site/publish_ssh.yml ]] ; then
  # If we have a remote publish configuration, then we do that

  # Parse our publish files
  dos2unix -n /docker-jekyll-site/publish_ssh.yml /docker-jekyll-site/publish_ssh.cleaned.yml
  PUBLISH_HOST=$(awk '{ if(match($0, /  host: (.*)/, arr)) print arr[1] }' /docker-jekyll-site/publish_ssh.cleaned.yml)
  PUBLISH_STAGING=$(awk '{ if(match($0, /  staging: (.*)/, arr)) print arr[1] }' /docker-jekyll-site/publish_ssh.cleaned.yml)
  PUBLISH_PUBLISH=$(awk '{ if(match($0, /  publish: (.*)/, arr)) print arr[1] }' /docker-jekyll-site/publish_ssh.cleaned.yml)

  dos2unix -n /docker-jekyll-site/publish_ssh_secrets.yml /docker-jekyll-site/publish_ssh_secrets.cleaned.yml
  PUBLISH_USER=$(awk '{ if(match($0, /  user: (.*)/, arr)) print arr[1] }' /docker-jekyll-site/publish_ssh_secrets.cleaned.yml)
  PUBLISH_PASSWORD=$(awk '{ if(match($0, /  password: (.*)/, arr)) print arr[1] }' /docker-jekyll-site/publish_ssh_secrets.cleaned.yml)

  SSH_OPTIONS='-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

  # Ensure our directories exist
  sshpass -p $PUBLISH_PASSWORD ssh $SSH_OPTIONS $PUBLISH_USER@$PUBLISH_HOST mkdir -p $PUBLISH_STAGING
  sshpass -p $PUBLISH_PASSWORD ssh $SSH_OPTIONS $PUBLISH_USER@$PUBLISH_HOST mkdir -p $PUBLISH_PUBLISH
  # Upload the files
  sshpass -p $PUBLISH_PASSWORD rsync -rcv --delete -e "ssh $SSH_OPTIONS" /docker-jekyll-site/site/_site/ $PUBLISH_USER@$PUBLISH_HOST:$PUBLISH_STAGING/
  # Put the files in place
  sshpass -p $PUBLISH_PASSWORD ssh $SSH_OPTIONS $PUBLISH_USER@$PUBLISH_HOST rsync -rcv --delete $PUBLISH_STAGING/ $PUBLISH_PUBLISH/
elif [[ -f /docker-jekyll-site/publish_local.yml ]] ; then
  # If we have a local publish configuration, then we do that

  # Parse our publish files
  dos2unix -n /docker-jekyll-site/publish_local.yml /docker-jekyll-site/publish_local.cleaned.yml
  PUBLISH_PUBLISH=$(awk '{ if(match($0, /  publish: (.*)/, arr)) print arr[1] }' /docker-jekyll-site/publish_local.cleaned.yml)

  # Rsync the files
  rsync -rcv --delete /docker-jekyll-site/site/_site/ /docker-jekyll-site/test_publish_local/$PUBLISH_PUBLISH
else
  # Launch our server, making it the process to ensure Docker behaves
  # http://www.projectatomic.io/docs/docker-image-author-guidance/
  exec invoke serve_production
fi
