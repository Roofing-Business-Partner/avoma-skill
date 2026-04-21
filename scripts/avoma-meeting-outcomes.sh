#!/usr/bin/env bash
# Manage meeting outcomes
# Usage: avoma-meeting-outcomes.sh                         # List all
#        avoma-meeting-outcomes.sh UUID                    # Get one
#        avoma-meeting-outcomes.sh --create "Label" "Desc" # Create
#        avoma-meeting-outcomes.sh --delete UUID           # Delete

source "$(dirname "$0")/avoma-config.sh"

if [ "${1:-}" = "--create" ]; then
  LABEL="${2:?Usage: avoma-meeting-outcomes.sh --create LABEL [DESCRIPTION]}"
  DESC="${3:-}"
  avoma_curl POST "/meeting_outcome/" -d "{\"label\": \"${LABEL}\", \"description\": \"${DESC}\"}"
elif [ "${1:-}" = "--delete" ]; then
  UUID="${2:?Usage: avoma-meeting-outcomes.sh --delete UUID}"
  avoma_curl DELETE "/meeting_outcome/${UUID}/"
elif [ -n "${1:-}" ]; then
  avoma_curl GET "/meeting_outcome/${1}/"
else
  avoma_curl GET "/meeting_outcome/"
fi
