#!/bin/sh

# Script for synchronizing git repos with remote
# - deletes all local branches that have been deleted on remote
# - pulls all local branches

# Delete all local branches that have been deleted on remote
# Note: git snip (custom alias) deletes all local branches that do not exist on remote
git fetch -p
git snip

# Memorize current branch
CURRENT_BRANCH=$(git branch --show-current)

# Stash local changes, if any
change_count=$(git status --porcelain | wc -l)
if [ "$change_count" -gt 0 ]; then
  git stash push -um "[git-sync] Stashing changes before sync"
fi

# Set branches list, depending on whether -a was passed
if [ "$1" = "-a" ]; then
  # Sync all branches
  # Note: git branches is a custom alias, listing all local and remote branches names
  branches=$(git branches)
else
  # Sync only already existing local branches
  branches=$(git branch -l | tr -s ' ' | cut -d ' ' -f 2)
fi

# Pull each branch
echo "$branches" | while read -r branch; do
  git checkout "$branch"
  git pull
done

# Return to original branch
git checkout "$CURRENT_BRANCH"

# Re-apply stashed changes, if any
if [ "$change_count" -gt 0 ]; then
  git stash pop
fi

exit 0