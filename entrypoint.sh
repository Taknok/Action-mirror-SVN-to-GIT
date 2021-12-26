#!/bin/bash

SVN_URL="$1"
AC_VERBOSE="$2"
RETRY="$3"

git config --global gc.auto 0
git config --global user.name "github-actions[bot]"
git config --global user.email "4815162342+github-actions[bot]@users.noreply.github.com"

# Check if action already init
(test -f .svn2git/svn-config && SVN_INIT=true) || SVN_INIT=false

# 2 svn2git have to be run, because first convert svn2git config from v1 to v2 
# but do not rebase into master. Once migration is done, rebase into master
# is done

if [ "$SVN_INIT" = false ]
then
  # first run
  set +e
  # fetch and create everything except for master
  if [[ $AC_VERBOSE -eq "true" ]]; then
    svn2git "$SVN_URL"
  else
    svn2git "$SVN_URL" > /dev/null
  fi
  if [[ $? -ne 0 ]]
  then
    echo "svn2git failed..."
    if [[ $RETRY -ge 0 ]]; then
      try=0
      while [[ $try -lt $RETRY ]]; do
        try=$(($try+1))
        echo "Retry $try"
        svn2git --rebase
        result=$?
        if [[ $result -eq 0 ]]; then
          #success
          break
        fi
        echo "svn2git --rebase failed..."
      done
      if [[ ! $result ]]; then
        # No retry succeeded
        exit 1
      fi
    fi
  fi

  set -e
  # rebase into master
  svn2git --rebase
  # Saving the config
  mkdir -p .svn2git
  git config --get-regexp svn-remote.svn > .svn2git/svn-config
  git add .svn2git/
  git commit -m "Save svn config to .svn2git/svn-config"
else
  # already initialized
  # Loading config
  cat .svn2git/svn-config | while read line; do git config $line; done
  # fetch and create everything except for master
  svn2git --rebase
  # rebase into master
  svn2git --rebase
fi

# Optimizing repo
git gc --auto

git push --mirror
