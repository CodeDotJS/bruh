#!/bin/bash

find_repository_root() {
  local dir="$1"
  while [ "$dir" != "/" ]; do
    if [ -d "$dir/.git" ]; then
      echo "$dir"
      return
    fi
    dir=$(dirname "$dir")
  done
  echo ""
}

CURRENT_DIR=$(pwd)

REPOSITORY_ROOT=$(find_repository_root "$CURRENT_DIR")

if [ -z "$REPOSITORY_ROOT" ]; then
  echo "Oopsie Woopsie! Not a GitHub repository!"
  exit 1
fi

CONFIG_FILE="$REPOSITORY_ROOT/.git/config"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Git config file diddly doo not found!"
  exit 1
fi

REPO_URL=$(grep -oP '(?<=url = ).*' "$CONFIG_FILE")

if [ -z "$REPO_URL" ]; then
  echo "Boo hoo, no repository URL found in config file!"
  exit 1
fi

HTTPS_URL=$(echo "$REPO_URL" | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')

if command -v xdg-open > /dev/null; then
  xdg-open "$HTTPS_URL"
elif command -v open > /dev/null; then
  open "$HTTPS_URL"
else
  echo "Hooman, I cannot detect the web browser to use. Please help!"
  exit 1
fi

echo "⮞ Opening repository - $HTTPS_URL"
