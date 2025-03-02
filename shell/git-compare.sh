#!/bin/sh

# Script for comparing git branches (two-ways)

RED='\033[0;31m' # Red
GREEN='\033[0;32m' # Green
NC='\033[0m' # No Color
BOLD='\033[1m' # Bold

print_usage() {
  printf "Usage: %s <upstream-branch>\n" "$(basename "$0")"
}

print_commits() {
  echo "$1" | while read -r i; do
    [ "$(echo "$i" | cut -c 1)" = "+" ] && printf "${GREEN}%s${NC}\n" "$i" && continue
    printf "${RED}%s${NC}\n" "$i"
  done
}

# Print usage and exit if no branch is provided
[ -z "$1" ] && print_usage && exit 1

CURRENT_BRANCH="$(git branch --show-current)"
UPSTREAM_BRANCH="$1"

# Check if branch exists
if ! git show-ref --verify --quiet "refs/heads/$UPSTREAM_BRANCH"; then
  if ! git show-ref --verify --quiet "refs/remotes/$UPSTREAM_BRANCH"; then
    printf "ERROR: Branch %s does not exist locally nor remotely.\n" "$UPSTREAM_BRANCH"
    exit 1
  fi
fi

printf "${BOLD}Commits on %s, not on %s:${NC}\n" "$CURRENT_BRANCH" "$UPSTREAM_BRANCH"
print_commits "$(git cherry -v "$UPSTREAM_BRANCH")"

printf "\n\n${BOLD}Commits on %s, not on %s:${NC}\n" "$UPSTREAM_BRANCH" "$CURRENT_BRANCH"
print_commits "$(git cherry -v HEAD "$UPSTREAM_BRANCH")"

exit 0