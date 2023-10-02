#!/bin/sh

# Script for synchronizing git repos with remote
# - pulls all local branches
# - deletes all local branches that have been deleted on remote

# Memorize current branch
CURRENT_BRANCH=$(git branch --show-current)

# Stash local changes, temporarily
git stash push -u

# Pull all local branches
# Note: git branches is a custom alias, listing all local branches names
git branches | while read -r branch; do
  git checkout "$branch"
  git pull
done

# Delete all local branches that have been deleted on remote
# Note: git snip is a custom alias, deleting all local branches that have been deleted on remote
git snip

# Return to original branch
git checkout "$CURRENT_BRANCH"

# Re-apply stashed changes
git stash pop

exit 0