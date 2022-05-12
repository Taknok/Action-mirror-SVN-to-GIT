#!/bin/bash
set -e

SVN_URL="$1"
AC_VERBOSE="$2"
RETRY="$3"

git config --global gc.auto 0
git config --global user.name "github-actions[bot]"
git config --global user.email "4815162342+github-actions[bot]@users.noreply.github.com"

git svn init "$SVN_URL" --stdlayout --prefix='svn/'
git svn fetch > /dev/null 2>&1
git tag | xargs git tag -d
svn2git --rebase -m -v

# Optimizing repo
git gc --auto

git push --all
git push --tags
