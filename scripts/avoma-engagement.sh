#!/usr/bin/env bash
# Get engagement analytics
# Usage: avoma-engagement.sh FROM_DATE TO_DATE [OPTIONS]
#   avoma-engagement.sh 2026-01-01 2026-04-20
#   avoma-engagement.sh 2026-01-01 2026-04-20 --user USER_UUID
#   avoma-engagement.sh 2026-01-01 2026-04-20 --summary
#   avoma-engagement.sh 2026-01-01 2026-04-20 --user UUID --summary
#
# Options:
#   --user UUID        Get per-participant metrics for a specific user
#   --summary          Get aggregated summary instead of per-user list
#   --page-size N      Results per page
#   --calls-only       Only voice calls
#   --meetings-only    Only video meetings
#   --external-only    Only external meetings

source "$(dirname "$0")/avoma-config.sh"

FROM="${1:?Usage: avoma-engagement.sh FROM_DATE TO_DATE [OPTIONS]}"
TO="${2:?Usage: avoma-engagement.sh FROM_DATE TO_DATE}"
shift 2

USER_UUID=""
SUMMARY=false
PARAMS="from_date=$(to_rfc3339 "$FROM")&to_date=$(to_rfc3339 "$TO" "T23:59:59Z")"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --user)          shift; USER_UUID="$1" ;;
    --summary)       SUMMARY=true ;;
    --page-size)     shift; PARAMS+="&page_size=$1" ;;
    --calls-only)    PARAMS+="&is_call=true" ;;
    --meetings-only) PARAMS+="&is_call=false" ;;
    --external-only) PARAMS+="&is_internal=false" ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

if [ -n "$USER_UUID" ] && [ "$SUMMARY" = true ]; then
  avoma_curl GET "/engagement/${USER_UUID}/summary/?${PARAMS}"
elif [ -n "$USER_UUID" ]; then
  avoma_curl GET "/engagement/${USER_UUID}/?${PARAMS}"
elif [ "$SUMMARY" = true ]; then
  avoma_curl GET "/engagement/summary/?${PARAMS}"
else
  avoma_curl GET "/engagement/?${PARAMS}"
fi
