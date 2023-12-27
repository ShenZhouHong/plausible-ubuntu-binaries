#!/usr/bin/env bash
set -eEu -o pipefail

if ! command -v "docker" &> /dev/null
    then
        printf '%s\n' "Error: docker is not available. Please install docker before running this script."
        exit 1
fi

# Note: we are using the Dockerfile from the repository root directory, and NOT the Plausible src/ directory
docker build --file=Dockerfile --output=./build/ --target=release src/