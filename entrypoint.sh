#!/bin/bash
set -e

SVN_URL="$1"
AC_VERBOSE="$2"

ls -la /github/workspace

# Check if action already init
(test -f .svn2git/svn-config && SVN_INIT=true) || SVN_INIT=false

if [ "$SVN_INIT" = false ]
then
  svn2git "$SVN_URL" > /dev/null

  # Saving the config
  mkdir -p .svn2git
  git config --get-regexp svn-remote.svn > .svn2git/svn-config
  git add .svn2git/
  git commit -m "Save svn config to .svn2git/svn-config"
else
  # Loading config
  cat .svn2git/svn-config | while read line; do git config $line; done
  svn2git --rebase
fi

# Optimizing repo
git gc --auto

git push
