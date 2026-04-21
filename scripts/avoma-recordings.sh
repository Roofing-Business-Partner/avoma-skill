#!/usr/bin/env bash
# Get recording URLs (audio + video) for a meeting
# Usage: avoma-recordings.sh MEETING_UUID
#   OR:  avoma-recordings.sh --uuid RECORDING_UUID
# Returns signed download URLs (valid for 5 days)

source "$(dirname "$0")/avoma-config.sh"

if [ "${1:-}" = "--uuid" ]; then
  UUID="${2:?Usage: avoma-recordings.sh --uuid RECORDING_UUID}"
  avoma_curl GET "/recordings/${UUID}/"
else
  MEETING_UUID="${1:?Usage: avoma-recordings.sh MEETING_UUID}"
  avoma_curl GET "/recordings/?meeting_uuid=${MEETING_UUID}"
fi
