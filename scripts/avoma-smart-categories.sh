#!/usr/bin/env bash
# Manage smart categories (keyword/prompt tracking)
# Usage: avoma-smart-categories.sh           # List all
#        avoma-smart-categories.sh UUID      # Get one

source "$(dirname "$0")/avoma-config.sh"

if [ -n "${1:-}" ]; then
  avoma_curl GET "/smart_categories/${1}/"
else
  avoma_curl GET "/smart_categories/"
fi
