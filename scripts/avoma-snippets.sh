#!/usr/bin/env bash
# Get meeting snippets (highlights)
# Usage: avoma-snippets.sh MEETING_UUID [--ai-only|--user-only] [--page-size N]
#   OR:  avoma-snippets.sh --range FROM_DATE TO_DATE [--ai-only|--user-only]
#
# NEW in Avoma API — snippets are AI-generated or user-created highlights

source "$(dirname "$0")/avoma-config.sh"

PARAMS=""

if [ "${1:-}" = "--range" ]; then
  FROM="${2:?Usage: avoma-snippets.sh --range FROM_DATE TO_DATE}"
  TO="${3:?Usage: avoma-snippets.sh --range FROM_DATE TO_DATE}"
  shift 3
  PARAMS="from_date=$(to_rfc3339 "$FROM")&to_date=$(to_rfc3339 "$TO" "T23:59:59Z")"
else
  UUID="${1:?Usage: avoma-snippets.sh MEETING_UUID}"
  shift
  PARAMS="meeting_uuid=${UUID}"
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ai-only)    PARAMS+="&is_ai_generated=true" ;;
    --user-only)  PARAMS+="&is_ai_generated=false" ;;
    --page-size)  shift; PARAMS+="&page_size=$1" ;;
    --page)       shift; PARAMS+="&page=$1" ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

avoma_curl GET "/snippets/?${PARAMS}"
