#!/bin/bash

# Pull upstream changes
echo -e "\033[0;32m====>\033[0m Pull origin..."
git pull

echo -e "\033[0;32m====>\033[0m Initial check..."

# Get current release name
CURRENT_RELEASE=$(git tag --sort=committerdate | tail -1)

# Get lastest release name
RELEASE=$(curl --silent "https://api.github.com/repos/minio/minio/releases/latest" | jq -r ".tag_name")

# Exit script if already up to date
if [ $RELEASE = $CURRENT_RELEASE ]; then
  echo -e "\033[0;32m=>\033[0m Already up to date..."
  exit 0
fi

# Download original Dockerfile and check for change
curl -s -q https://raw.githubusercontent.com/minio/minio/${RELEASE}/Dockerfile.release -o original_dockerfile
if ! sha256sum -c --quiet original_dockerfile.sha256sum; then
  echo -e "\033[0;31m===>\033[0m Checksum of the original dockerfile changed"
  echo -e "\033[0;31m=>\033[0m Require manual intervention !"
  exit 1
fi

# Extract date from release name
RELEASE_DATE=$(date -d $(echo $RELEASE | cut -f2 -d '.' | cut -f1 -d 'T') +%d/%m/%Y)

# Replace "ARG" line in dockerfile with the new release
sed -i "s#ARG MINIO_VERSION.*#ARG MINIO_VERSION=\"${RELEASE}\"#" Dockerfile

# Replace README link to minio release
MINIO_BADGE="[![Minio](https://img.shields.io/badge/Minio-${RELEASE_DATE}-blue.svg)](https://github.com/minio/minio/releases/tag/${RELEASE})"
sed -i "s#\[\!\[Minio\].*#${MINIO_BADGE}#" README.md

# Push changes
git add Dockerfile README.md
git commit -m "Update to minio version ${RELEASE}"
git push origin master

# Create tag
git tag "${RELEASE}"
git push --tags
