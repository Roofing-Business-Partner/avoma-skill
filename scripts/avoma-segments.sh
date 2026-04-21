#!/usr/bin/env bash
# Get meeting segments (intro, demo, pricing, next_steps, etc.)
# Usage: avoma-segments.sh MEETING_UUID

source "$(dirname "$0")/avoma-config.sh"

UUID="${1:?Usage: avoma-segments.sh MEETING_UUID}"
avoma_curl GET "/meeting_segments/?uuid=${UUID}"
