#!/usr/bin/env bash
# Manage meeting types (purposes)
# Usage: avoma-meeting-types.sh                         # List all
#        avoma-meeting-types.sh UUID                    # Get one
#        avoma-meeting-types.sh --create "Label" "Desc" # Create
#        avoma-meeting-types.sh --delete UUID           # Delete

source "$(dirname "$0")/avoma-config.sh"

if [ "${1:-}" = "--create" ]; then
  LABEL="${2:?Usage: avoma-meeting-types.sh --create LABEL [DESCRIPTION]}"
  DESC="${3:-}"
  avoma_curl POST "/meeting_type/" -d "{\"label\": \"${LABEL}\", \"description\": \"${DESC}\"}"
elif [ "${1:-}" = "--delete" ]; then
  UUID="${2:?Usage: avoma-meeting-types.sh --delete UUID}"
  avoma_curl DELETE "/meeting_type/${UUID}/"
elif [ -n "${1:-}" ]; then
  avoma_curl GET "/meeting_type/${1}/"
else
  avoma_curl GET "/meeting_type/"
fi
