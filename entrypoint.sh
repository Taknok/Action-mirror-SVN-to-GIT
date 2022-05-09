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

git svn init "$SVN_URL" --stdlayout --prefix='svn/'
git svn fetch > /dev/null 2>&1
svn2git --rebase -m -v

# Optimizing repo
git gc --auto

git push --all
git push --tags
