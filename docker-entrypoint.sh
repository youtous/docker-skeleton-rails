#!/bin/bash

set -e
# Exit on fail

bundle check || bundle install --binstubs="$BUNDLE_BIN" --jobs 20
# Ensure all gems installed. Add binstubs to bin which has been added to PATH in Dockerfile.

# source app conf
. .env

# wait the database has started
if [[ ! -v DB_PORT ]]; then
    >&2 echo "Error: no database port set in .env file, see README.md."
    exit 1
fi

./wait-for-it.sh db:${DB_PORT} -t 30

exec "$@"
# Finally call command issued to the docker service