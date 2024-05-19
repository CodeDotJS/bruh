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

START_DIR="${1:-$(pwd)}"

if [ ! -d "$START_DIR" ]; then
  echo -e "\n\e[31m Oh noes! The specified directory does not exist!\e[0m\n"
  exit 1
fi

REPOSITORY_ROOT=$(find_repository_root "$START_DIR")

if [ -z "$REPOSITORY_ROOT" ]; then
  echo -e "\n\e[31m Oopsie Woopsie! Not a GitHub repository!\e[0m\n"
  exit 1
fi

CONFIG_FILE="$REPOSITORY_ROOT/.git/config"

if [ ! -f "$CONFIG_FILE" ]; then
  echo -e "\n\e[31m Git config file diddly doo not found!\e[0m\n"
  exit 1
fi

REPO_URL=$(grep -oP '(?<=url = ).*' "$CONFIG_FILE")

if [ -z "$REPO_URL" ]; then
  echo -e "\n\e[31m Boo hoo, no repository URL found in config file!\e[0m\n"
  exit 1
fi

HTTPS_URL=$(echo "$REPO_URL" | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')

REPO_NAME=$(echo "$HTTPS_URL" | sed 's/https:\/\/github.com\///')

if command -v xdg-open > /dev/null; then
  xdg-open "$HTTPS_URL"
elif command -v open > /dev/null; then
  open "$HTTPS_URL"
else
  echo -e "\n\e[31m Hooman, I cannot detect the web browser to use. Please help!\e[0m\n"
  exit 1
fi

echo -e "\n\e[34m Opening on GitHub - $REPO_NAME\e[0m\n"
