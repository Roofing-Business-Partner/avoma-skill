#!/usr/bin/env bash
# List scorecard evaluations
# Usage: avoma-scorecard-evals.sh [OPTIONS]
#   --from FROM_DATE    Filter by start date
#   --to TO_DATE        Filter by end date
#   --meeting UUID      Filter by meeting UUID
#   --scorecard UUID    Filter by scorecard template UUID
#   --user EMAIL        Filter by user email (who was scored)
#   --page-size N       Results per page (default 10, max 100)

source "$(dirname "$0")/avoma-config.sh"

PARAMS=""
SEP="?"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --from)       shift; PARAMS+="${SEP}from_date=$(to_rfc3339 "$1")"; SEP="&" ;;
    --to)         shift; PARAMS+="${SEP}to_date=$(to_rfc3339 "$1" "T23:59:59Z")"; SEP="&" ;;
    --meeting)    shift; PARAMS+="${SEP}meeting_uuid=$1"; SEP="&" ;;
    --scorecard)  shift; PARAMS+="${SEP}scorecard_uuids=$1"; SEP="&" ;;
    --user)       shift; PARAMS+="${SEP}user_emails=$1"; SEP="&" ;;
    --page-size)  shift; PARAMS+="${SEP}page_size=$1"; SEP="&" ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

avoma_curl GET "/scorecard_evaluations/${PARAMS}"
