#!/bin/sh

# Generate JSON config for Project Manager (VSCode extension)

PROJECTS_DIR="/home/quentin/Projets"

find $PROJECTS_DIR -maxdepth 1 | while read -r i;
do
  echo "{ \"name\": \"$(basename "$i")\", \"rootPath\": \"vscode-remote://wsl+Ubuntu$i\", \"paths\": [], \"tags\": [], \"enabled\": true },"
done

exit 0