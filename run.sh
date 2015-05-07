#!/bin/bash

# Ensure our repository is defined
if [[ ! -n $JEKYLL_GIT_REPOSITORY ]] ; then
  echo "\$JEKYLL_GIT_REPOSITORY not defined"
  exit 1
fi

# If we have an existing repository, but not the right one, we need to start from scratch
EXISTING_GIT_REPOSITORY=$(git --git-dir=/site/.git remote -v | grep -m 1 origin | awk -F'[ \t]' '{print $2}')
echo "Desired Repository: $JEKYLL_GIT_REPOSITORY"
echo "Existing Repository: $EXISTING_GIT_REPOSITORY"
if [[ -d /site ]] ; then
  if [[ $JEKYLL_GIT_REPOSITORY != $EXISTING_GIT_REPOSITORY ]] ; then
    rm -rf /site/*
    rm -rf /site/.[!.]?*
  fi
fi

# Check whether this is our first time running, such that we need to clone
if [[ ! -d /site/.git ]] ; then
  git clone $JEKYLL_GIT_REPOSITORY /site
fi

# Change into the site directory
cd /site

# Ensure we have any site updates
# http://grimoire.ca/git/stop-using-git-pull-to-deploy
git fetch --all
git checkout --force origin/master

# Launch our server, making it the process to ensure Docker behaves
# http://www.projectatomic.io/docs/docker-image-author-guidance/
exec jekyll serve --host 0.0.0.0
