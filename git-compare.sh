#!/bin/sh

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

if [ -z "$1" ]; then
  echo "Usage: $(basename "$0") <upstream-branch>"
  exit 1
fi

UPSTREAM_BRANCH="$1"
DIFF_CURRENT_UPSTREAM=$(git cherry -v "$UPSTREAM_BRANCH")
DIFF_UPSTREAM_CURRENT=$(git cherry -v HEAD "$UPSTREAM_BRANCH" | sed -e 's/+/-/')

echo "${GREEN}$DIFF_CURRENT_UPSTREAM${NC}"
echo "${RED}$DIFF_UPSTREAM_CURRENT${NC}"

exit 0