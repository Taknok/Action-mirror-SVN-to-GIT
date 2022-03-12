#!/bin/bash
set -e

SVN_URL="$1"
AC_VERBOSE="$2"
RETRY="$3"

watch_res() {
  printf "Memory\t\tDisk\t\tCPU\n"
  end=$((SECONDS+3600))
  while [ $SECONDS -lt $end ]; do
    MEMORY=$(free -m | awk 'NR==2{printf "%.2f%%\t\t", $3*100/$2 }')
    DISK=$(df -h | awk '$NF=="/"{printf "%s\t\t", $5}')
    CPU=$(top -bn1 | grep load | awk '{printf "%.2f%%\t\t\n", $(NF-2)}')
    echo "$MEMORY$DISK$CPU"
    sleep 30
  done
}

watch_res &
git config --global gc.auto 0
git config --global user.name "github-actions[bot]"
git config --global user.email "4815162342+github-actions[bot]@users.noreply.github.com"

# Check if action already init
(test -f .svn2git/svn-config && SVN_INIT=true) || SVN_INIT=false

# 2 svn2git have to be run, because first convert svn2git config from v1 to v2 
# but do not rebase into master. Once migration is done, rebase into master
# is done

save_svn_config () {
  [ -d .svn2git/ ] && rm -rf .svn2git/
  mkdir -p .svn2git
  git config --get-regexp svn-remote.svn > .svn2git/svn-config
  cp -r .git/svn .svn2git/
  git add .svn2git/
  git commit -m "Save svn config to .svn2git/svn-config"
}

load_svn_config () {
  cat .svn2git/svn-config | while read line; do git config $line; done
  cp -r .svn2git/svn .git/
}

silent () {
  if [[ "$AC_VERBOSE" == "true" ]]; then
    $@
  else
    $@ > /dev/null
  fi
}

if [ "$SVN_INIT" = false ]
then
  # first run
  echo "First run, initializing project"
  set +e
  # fetch and create everything except for master
  silent svn2git "$SVN_URL"

  # if fail, retry
  if [[ $? -ne 0 ]]
  then
    echo "svn2git failed..."
    if [[ $RETRY -ge 0 ]]; then
      try=0
      while [[ $try -lt $RETRY ]]; do
        try=$(($try+1))
        echo "Retry $try"
        silent svn2git --rebase
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
    else
      exit 1
    fi
  fi

  set -e
  # rebase into master
  silent svn2git --rebase

  # Saving the config
  save_svn_config
else
  # already initialized
  echo "Already initialized, loading configuration"
  # Loading config
  load_svn_config

  # fetch and create everything except for master
  silent svn2git --rebase
  # rebase into master
  silent svn2git --rebase
  # save config
  save_svn_config
fi

# Optimizing repo
git gc --auto

git push --mirror
