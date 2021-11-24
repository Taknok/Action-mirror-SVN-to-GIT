#!/bin/bash


SVN_URL="$1"

ls -la /github/workspace

# Check if action already init
(test -f .svn2git/svn-config && SVN_INIT=true) || SVN_INIT=false

if [ "$SVN_INIT" = false ]
then
  GIT_TRACE=2 GIT_CURL_VERBOSE=2 GIT_TRACE_PERFORMANCE=2 GIT_TRACE_PACK_ACCESS=2 GIT_TRACE_PACKET=2 GIT_TRACE_PACKFILE=2 GIT_TRACE_SETUP=2 GIT_TRACE_SHALLOW=2 svn2git "$SVN_URL"

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
