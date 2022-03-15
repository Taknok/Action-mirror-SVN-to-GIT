#!/bin/bash
set -e

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

save_svn_config () {
  mkdir -p .svn2git
  git config --get-regexp svn-remote.svn > .svn2git/svn-config
  cp -r .git/svn .svn2git/
  git add .svn2git/
  git commit -m "Save svn config to .svn2git/svn-config"
}

silent () {
  if [[ "$AC_VERBOSE" == "true" ]]; then
    $@
  else
    $@ > /dev/null
  fi
}

clone() {
  git svn init "$SVN_URL" --no-metadata --stdlayout --prefix='svn/'
}

if [ "$SVN_INIT" = false ]
then
  # first run
  echo "First run, initializing project"
  set +e
  # fetch and create everything except for master
  silent clone

  # Saving the config
  save_svn_config
else
  # already initialized
  echo "Already initialized, loading configuration"
  # Loading config
  cat .svn2git/svn-config | while read line; do git config $line; done
  cp -r .svn2git/svn .git/
  # fetch and create everything except for master
fi

# Optimizing repo
git gc --auto

#git push --mirror
