#!/usr/bin/env bash
# Get meeting insights (AI notes, keywords, speakers)
# Usage: avoma-insights.sh MEETING_UUID
# Requires: meeting state must be "completed"

source "$(dirname "$0")/avoma-config.sh"

UUID="${1:?Usage: avoma-insights.sh MEETING_UUID}"
avoma_curl GET "/meetings/${UUID}/insights/"
