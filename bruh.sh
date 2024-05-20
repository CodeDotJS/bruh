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

set_username() {
  local username="$1"
  echo "$username" > ~/.bruh
}

get_username() {
  if [ -f ~/.bruh ]; then
    cat ~/.bruh
  else
    echo ""
  fi
}

open_url() {
  local url="$1"
  local repo_name="$2"
  if command -v xdg-open > /dev/null; then
    xdg-open "$url"
  elif command -v open > /dev/null; then
    open "$url"
  else
    echo -e "\n\e[31m Hooman, I cannot detect the web browser to use. Please help!\e[0m\n"
    exit 1
  fi
  echo -e "\n\e[34m Opening on GitHub - $repo_name\e[0m\n"
}

# Parse arguments
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --set-username)
      if [ -n "$2" ]; then
        set_username "$2"
        echo -e "\n\e[34m Username set to $2\e[0m\n"
        exit 0
      else
        echo -e "\n\e[31m Error: --set-username requires a username argument\e[0m\n"
        exit 1
      fi
      ;;
    -o)
      USERNAME=$(get_username)
      if [ -z "$USERNAME" ]; then
        echo -e "\n\e[31m Error: Username not set. Use --set-username <username> to set it.\e[0m\n"
        exit 1
      fi
      if [ -n "$2" ]; then
        REPOSITORY="$2"
        GITHUB_URL="https://github.com/$USERNAME/$REPOSITORY"
        REPO_NAME="$USERNAME/$REPOSITORY"
        shift
      else
        GITHUB_URL="https://github.com/$USERNAME"
        REPO_NAME="$USERNAME"
      fi
      open_url "$GITHUB_URL" "$REPO_NAME"
      exit 0
      ;;
    *)
      START_DIR="$1"
      ;;
  esac
  shift
done

START_DIR="${START_DIR:-$(pwd)}"

if [ ! -d "$START_DIR" ]; then
  echo -e "\n\e[31m Oh noes! The specified directory does not exist!\e[0m\n"
  exit 1
fi
FULL_PATH=$(realpath "$START_DIR")

REPOSITORY_ROOT=$(find_repository_root "$FULL_PATH")

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

open_url "$HTTPS_URL" "$REPO_NAME"
