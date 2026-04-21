#!/usr/bin/env bash
# List or get note templates
# Usage: avoma-templates.sh           # List all
#        avoma-templates.sh UUID      # Get one

source "$(dirname "$0")/avoma-config.sh"

if [ -n "${1:-}" ]; then
  avoma_curl GET "/template/${1}/"
else
  avoma_curl GET "/template/"
fi
