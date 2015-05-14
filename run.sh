#!/bin/bash

# Ensure our repository is defined
if [[ ! -n $GIT_REPOSITORY_SITE ]] ; then
  echo "\$GIT_REPOSITORY_SITE not defined"
  exit 1
fi

# If we have an existing repository, but not the right one, we need to start from scratch
GIT_REPOSITORY_EXISTING=$(git --git-dir=/site/.git remote -v | grep -m 1 origin | awk -F'[ \t]' '{print $2}')
echo "Desired Repository: $GIT_REPOSITORY_SITE"
echo "Existing Repository: $GIT_REPOSITORY_EXISTING"
if [[ -d /site ]] ; then
  if [[ $GIT_REPOSITORY_SITE != $GIT_REPOSITORY_EXISTING ]] ; then
    rm -rf /site/*
    rm -rf /site/.[!.]?*
  fi
fi

# Check whether this is our first time running, such that we need to clone
if [[ ! -d /site/.git ]] ; then
  git clone $GIT_REPOSITORY_SITE /site
fi

# The presence of a lock means somebody else did not finish
# Probably because the container got stopped
# We need to clear the lock so our git commands can execute
if [[ -f /site/.git/index.lock ]] ; then
  rm -f /site/.git/index.lock
fi

# Change into the site directory
cd /site

# Ensure we have any site updates
# http://grimoire.ca/git/stop-using-git-pull-to-deploy
git fetch --all
git checkout --force origin/master

# Build our site
jekyll build

# If we have a publish configuration, then we do that, otherwise we serve ourselves
if [[ -f /publish.yml ]] ; then
  # Parse our file
  dos2unix -n /publish.yml /publishcleaned.yml
  PUBLISH_USER=$(awk '{ if(match($0, /  user: (.*)/, arr)) print arr[1] }' /publishcleaned.yml)
  PUBLISH_PASSWORD=$(awk '{ if(match($0, /  password: (.*)/, arr)) print arr[1] }' /publishcleaned.yml)
  PUBLISH_HOST=$(awk '{ if(match($0, /  host: (.*)/, arr)) print arr[1] }' /publishcleaned.yml)
  PUBLISH_STAGING=$(awk '{ if(match($0, /  staging: (.*)/, arr)) print arr[1] }' /publishcleaned.yml)
  PUBLISH_PUBLISH=$(awk '{ if(match($0, /  publish: (.*)/, arr)) print arr[1] }' /publishcleaned.yml)

  SSH_OPTIONS='-o LogLevel=quiet -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

  # Ensure our directories exist
  sshpass -p $PUBLISH_PASSWORD ssh $SSH_OPTIONS $PUBLISH_USER@$PUBLISH_HOST mkdir -p $PUBLISH_STAGING
  sshpass -p $PUBLISH_PASSWORD ssh $SSH_OPTIONS $PUBLISH_USER@$PUBLISH_HOST mkdir -p $PUBLISH_PUBLISH
  # Upload the files
  sshpass -p $PUBLISH_PASSWORD rsync -rcv --delete -e "ssh $SSH_OPTIONS" /site/_site/* $PUBLISH_USER@$PUBLISH_HOST:$PUBLISH_STAGING
  # Put the files in place
  sshpass -p $PUBLISH_PASSWORD ssh $SSH_OPTIONS $PUBLISH_USER@$PUBLISH_HOST rsync -rcv --delete $PUBLISH_STAGING/* $PUBLISH_PUBLISH
else
  # Launch our server, making it the process to ensure Docker behaves
  # http://www.projectatomic.io/docs/docker-image-author-guidance/
  exec jekyll serve --host 0.0.0.0
fi

