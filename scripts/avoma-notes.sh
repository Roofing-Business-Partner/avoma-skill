#!/usr/bin/env bash
# Get AI notes for meetings
# Usage: avoma-notes.sh MEETING_UUID [--format json|html|markdown]
#   OR:  avoma-notes.sh --range FROM_DATE TO_DATE [--format FORMAT] [--page-size N]
#
# Default format: markdown (most useful for agents)

source "$(dirname "$0")/avoma-config.sh"

FORMAT="markdown"

if [ "${1:-}" = "--range" ]; then
  FROM="${2:?Usage: avoma-notes.sh --range FROM_DATE TO_DATE}"
  TO="${3:?Usage: avoma-notes.sh --range FROM_DATE TO_DATE}"
  shift 3
  PARAMS="from_date=$(to_rfc3339 "$FROM")&to_date=$(to_rfc3339 "$TO" "T23:59:59Z")"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --format)    shift; FORMAT="$1" ;;
      --page-size) shift; PARAMS+="&page_size=$1" ;;
      --category)  shift; PARAMS+="&custom_category=$1" ;;
      *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
    shift
  done
  PARAMS+="&output_format=${FORMAT}"
  avoma_curl GET "/notes/?${PARAMS}"
else
  MEETING_UUID="${1:?Usage: avoma-notes.sh MEETING_UUID [--format FORMAT]}"
  shift
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --format) shift; FORMAT="$1" ;;
      *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
    shift
  done
  # Use wide date range + meeting_uuid filter
  PARAMS="from_date=2020-01-01T00:00:00Z&to_date=2030-01-01T00:00:00Z&meeting_uuid=${MEETING_UUID}&output_format=${FORMAT}"
  avoma_curl GET "/notes/?${PARAMS}"
fi
