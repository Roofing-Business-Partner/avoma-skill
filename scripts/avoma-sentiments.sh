#!/usr/bin/env bash
# Get meeting sentiments (emotional tone over time)
# Usage: avoma-sentiments.sh MEETING_UUID

source "$(dirname "$0")/avoma-config.sh"

UUID="${1:?Usage: avoma-sentiments.sh MEETING_UUID}"
avoma_curl GET "/meeting_sentiments/?meeting_uuid=${UUID}"
