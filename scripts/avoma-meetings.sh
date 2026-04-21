#!/usr/bin/env bash
# List Avoma meetings for a date range
# Usage: avoma-meetings.sh FROM_DATE TO_DATE [OPTIONS]
#   avoma-meetings.sh 2026-04-01 2026-04-20
#   avoma-meetings.sh 2026-04-01 2026-04-20 --calls-only
#   avoma-meetings.sh 2026-04-01 2026-04-20 --external-only --page-size 50
#
# Options:
#   --calls-only       Only voice calls (is_call=true)
#   --meetings-only    Only video meetings (is_call=false)
#   --internal-only    Only internal meetings
#   --external-only    Only external meetings
#   --page-size N      Results per page (default 10, max 100)
#   --attendee EMAIL   Filter by attendee email
#   --crm-account ID   Filter by CRM account ID
#   --crm-opp ID       Filter by CRM opportunity ID
#   --include-crm      Include CRM associations in response
#   --min-duration N   Minimum recording duration in seconds

source "$(dirname "$0")/avoma-config.sh"

FROM_DATE="${1:?Usage: avoma-meetings.sh FROM_DATE TO_DATE [OPTIONS]}"
TO_DATE="${2:?Usage: avoma-meetings.sh FROM_DATE TO_DATE [OPTIONS]}"
shift 2

# Build query params
PARAMS="from_date=$(to_rfc3339 "$FROM_DATE")&to_date=$(to_rfc3339 "$TO_DATE" "T23:59:59Z")"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --calls-only)      PARAMS+="&is_call=true" ;;
    --meetings-only)   PARAMS+="&is_call=false" ;;
    --internal-only)   PARAMS+="&is_internal=true" ;;
    --external-only)   PARAMS+="&is_internal=false" ;;
    --page-size)       shift; PARAMS+="&page_size=$1" ;;
    --attendee)        shift; PARAMS+="&attendee_emails=$1" ;;
    --crm-account)     shift; PARAMS+="&crm_account_ids=$1" ;;
    --crm-opp)         shift; PARAMS+="&crm_opportunity_ids=$1" ;;
    --include-crm)     PARAMS+="&include_crm_associations=true" ;;
    --min-duration)    shift; PARAMS+="&recording_duration__gte=$1" ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

avoma_curl GET "/meetings/?${PARAMS}"
