#!/usr/bin/env bash
# List scorecard templates or get a specific one
# Usage: avoma-scorecards.sh
#   OR:  avoma-scorecards.sh SCORECARD_UUID

source "$(dirname "$0")/avoma-config.sh"

if [ -n "${1:-}" ]; then
  avoma_curl GET "/scorecards/${1}/"
else
  avoma_curl GET "/scorecards/"
fi
