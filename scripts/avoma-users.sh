#!/usr/bin/env bash
# List Avoma users or get a single user
# Usage: avoma-users.sh
#   OR:  avoma-users.sh USER_UUID

source "$(dirname "$0")/avoma-config.sh"

if [ -n "${1:-}" ]; then
  avoma_curl GET "/users/${1}/"
else
  avoma_curl GET "/users/"
fi
