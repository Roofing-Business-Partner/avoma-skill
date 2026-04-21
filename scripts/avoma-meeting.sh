#!/usr/bin/env bash
# Get a single Avoma meeting by UUID
# Usage: avoma-meeting.sh MEETING_UUID [--include-crm]

source "$(dirname "$0")/avoma-config.sh"

UUID="${1:?Usage: avoma-meeting.sh MEETING_UUID [--include-crm]}"
PARAMS=""
[ "${2:-}" = "--include-crm" ] && PARAMS="?include_crm_associations=true"

avoma_curl GET "/meetings/${UUID}/${PARAMS}"
