#!/bin/bash

if [ "$#" -lt 4 ]; then
    echo "Usage: $0 <USER> <REPO_URL> <BRANCH> <reviewer1@example.com> <reviewer2@example.com> ..."
    exit 1
fi

USER=$1
REPO_URL=$2
BRANCH=$3
shift 3
REVIEWERS=("$@")

REVIEWERS_ARG=""
for r in "${!REVIEWERS[@]}"; do
    if [ $r -eq $((${#REVIEWERS[@]} - 1)) ]; then
        REVIEWERS_ARG+="r=${REVIEWERS[$r]}"
    else
        REVIEWERS_ARG+="r=${REVIEWERS[$r]},"
    fi
done

mv fm-gdb-plugin/bin/gdb_plugin.so extras/gdb_plugin.so
git config --global user.email "$USER@arm.com"
git config --global user.name "$USER"
git add extras/gdb_plugin.so
git commit -am "Auto update of fm-gdb-plugin"
git push $REPO_URL HEAD:refs/for/$BRANCH%$REVIEWERS_ARG
