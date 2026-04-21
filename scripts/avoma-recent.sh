#!/usr/bin/env bash
# List recent meetings with UUIDs — quick morning check or pre-pull lookup.
# Usage: avoma-recent.sh [DAYS_BACK] [OPTIONS]
#   avoma-recent.sh             # last 14 days (default)
#   avoma-recent.sh 30          # last 30 days
#   avoma-recent.sh 7 --calls-only
#   avoma-recent.sh 14 --external-only
#
# Options:
#   --calls-only       Only voice calls
#   --meetings-only    Only video meetings
#   --external-only    Only external (non-internal) meetings
#   --page-size N      Max results (default 50)
#
# Output: tab-separated uuid, start_at, state, subject
# Pipe to jq for JSON, or read directly for quick UUID lookup.
#
# Designed to be the first step before avoma-meeting-full.sh — get a UUID,
# then pull everything for that meeting without re-calling the API per field.

source "$(dirname "$0")/avoma-config.sh"

DAYS_BACK="${1:-14}"
shift 2>/dev/null || true

PAGE_SIZE=50
EXTRA_PARAMS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --calls-only)    EXTRA_PARAMS+="&is_call=true" ;;
    --meetings-only) EXTRA_PARAMS+="&is_call=false" ;;
    --external-only) EXTRA_PARAMS+="&is_internal=false" ;;
    --page-size)     shift; PAGE_SIZE="$1" ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

# Compute from/to using POSIX-compatible date math (macOS + Linux)
if date -v-1d "+%Y-%m-%d" &>/dev/null 2>&1; then
  FROM=$(date -u -v-${DAYS_BACK}d "+%Y-%m-%dT%H:%M:%SZ")
else
  FROM=$(date -u -d "${DAYS_BACK} days ago" "+%Y-%m-%dT%H:%M:%SZ")
fi
TO=$(date -u "+%Y-%m-%dT%H:%M:%SZ")

PARAMS="from_date=${FROM}&to_date=${TO}&page_size=${PAGE_SIZE}${EXTRA_PARAMS}"
result=$(avoma_curl GET "/meetings/?${PARAMS}")

# Print human-readable to stderr, JSON to stdout (so callers can pipe)
TOTAL=$(echo "$result" | jq '.count // 0')
echo "📅 Last ${DAYS_BACK} days — ${TOTAL} meeting(s)" >&2
echo "" >&2
echo "$result" | jq -r '
  .results[] |
  [.uuid, (.start_at // "?"), (.state // "?"), (.subject // "(no subject)")] |
  @tsv
' | while IFS=$'\t' read -r uuid start state subject; do
  echo "  $subject" >&2
  echo "    UUID:  $uuid" >&2
  echo "    When:  $start" >&2
  echo "    State: $state" >&2
  echo "" >&2
done

# Raw JSON to stdout for piping
echo "$result"
