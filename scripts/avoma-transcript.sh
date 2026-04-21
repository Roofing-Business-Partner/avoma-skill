#!/usr/bin/env bash
# Get transcript for a meeting
# Usage: avoma-transcript.sh MEETING_UUID
#   OR:  avoma-transcript.sh --uuid TRANSCRIPTION_UUID
#   OR:  avoma-transcript.sh --range FROM_DATE TO_DATE [--page N] [--page-size N]

source "$(dirname "$0")/avoma-config.sh"

if [ "${1:-}" = "--uuid" ]; then
  # Get by transcription UUID
  UUID="${2:?Usage: avoma-transcript.sh --uuid TRANSCRIPTION_UUID}"
  avoma_curl GET "/transcriptions/${UUID}/"
elif [ "${1:-}" = "--range" ]; then
  # List transcriptions by date range
  FROM="${2:?Usage: avoma-transcript.sh --range FROM_DATE TO_DATE}"
  TO="${3:?Usage: avoma-transcript.sh --range FROM_DATE TO_DATE}"
  shift 3
  PARAMS="from_date=$(to_rfc3339 "$FROM")&to_date=$(to_rfc3339 "$TO" "T23:59:59Z")"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --page)      shift; PARAMS+="&page=$1" ;;
      --page-size) shift; PARAMS+="&page_size=$1" ;;
      --attendee)  shift; PARAMS+="&attendee_emails=$1" ;;
      *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
    shift
  done
  avoma_curl GET "/transcriptions/?${PARAMS}"
else
  # Get by meeting UUID (most common)
  MEETING_UUID="${1:?Usage: avoma-transcript.sh MEETING_UUID}"
  PARAMS="from_date=2020-01-01T00:00:00Z&to_date=2030-01-01T00:00:00Z&meeting_uuid=${MEETING_UUID}"
  avoma_curl GET "/transcriptions/?${PARAMS}"
fi
