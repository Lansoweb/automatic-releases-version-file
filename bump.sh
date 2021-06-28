#!/bin/bash

set -e

if [[ -z "$GITHUB_EVENT_PATH" ]]; then
    echo "Set the GITHUB_EVENT_PATH env variable."
    exit 1
fi
if [[ -z "$GIT_AUTHOR_NAME" ]]; then
    echo "Set the GIT_AUTHOR_NAME env variable."
    exit 1
fi
if [[ -z "$GIT_AUTHOR_EMAIL" ]]; then
    echo "Set the GIT_AUTHOR_EMAIL env variable."
    exit 1
fi
if [[ -z "$SIGNING_SECRET_KEY" ]]; then
    echo "Set the SIGNING_SECRET_KEY env variable."
    exit 1
fi
if [[ -z "$GITHUB_TOKEN" ]]; then
    echo "Set the GITHUB_TOKEN env variable."
    exit 1
fi
if [[ -z "$VERSION_FILE" ]]; then
    echo "Set the VERSION_FILE env variable."
    exit 1
fi
if [[ -z "$VERSION_CONTENT" ]]; then
    echo "Set the VERSION_CONTENT env variable."
    exit 1
fi

which jq >/dev/null || {
  echo "Installing missing package jq"
  apt update && apt install -y jq
}

version=$(jq --raw-output .milestone.title "$GITHUB_EVENT_PATH")
repository=$(jq --raw-output .repository.full_name "$GITHUB_EVENT_PATH")

if [[ -z "${version}" ]]; then
  echo "Invalid version '${version}'."
  exit 1
fi

echo "Detected tag ${version}"
if ! [[ "${version}" =~ ^(0|[1-9][[:digit:]]*)\.(0|[1-9][[:digit:]]*)\.(0|[1-9][[:digit:]]*)?$ ]]; then
  echo "Invalid version '${version}'."
  exit 1
fi

major="${BASH_REMATCH[1]}"
minor="${BASH_REMATCH[2]}"
branch="${major}.${minor}.x"

echo "${SIGNING_SECRET_KEY}" > /tmp/key
in=$(gpg --import /tmp/key 2>&1 >/dev/null)
if ! [[ "${in}" =~ key[[:space:]]([A-F0-9]+):[[:space:]]secret[[:space:]]key[[:space:]]imported ]]; then
  echo "Could not detect key '${in}'."
  exit 1
fi
key="${BASH_REMATCH[1]}"
rm -f /tmp/key

git config user.email "${GIT_AUTHOR_EMAIL}"
git config user.name "${GIT_AUTHOR_NAME}"

echo "Checking out branch ${branch}"
git remote rm origin >/dev/null
git remote add origin "https://${GITHUB_TOKEN}:x-oauth-basic@github.com/${repository}.git" >/dev/null
git fetch --prune >/dev/null
if ! git checkout -b "$branch" origin/"$branch"; then
  echo "Unable to checkout to branch '${branch}'."
  exit 1
fi

echo -n "${VERSION_CONTENT/||version||/$version}" > "$VERSION_FILE"
git add "$VERSION_FILE" >/dev/null
git commit -m "Bump version file" --gpg-sign="$key" >/dev/null
