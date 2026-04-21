#!/usr/bin/env bash
# List Avoma calls or get a single call
# Usage: avoma-calls.sh FROM_DATE TO_DATE [--inbound|--outbound]
#   OR:  avoma-calls.sh --get EXTERNAL_ID

source "$(dirname "$0")/avoma-config.sh"

if [ "${1:-}" = "--get" ]; then
  EXT_ID="${2:?Usage: avoma-calls.sh --get EXTERNAL_ID}"
  avoma_curl GET "/calls/${EXT_ID}/"
else
  FROM="${1:?Usage: avoma-calls.sh FROM_DATE TO_DATE [--inbound|--outbound]}"
  TO="${2:?Usage: avoma-calls.sh FROM_DATE TO_DATE}"
  shift 2
  PARAMS="from_date=$(to_rfc3339 "$FROM")&to_date=$(to_rfc3339 "$TO" "T23:59:59Z")"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --inbound)  PARAMS+="&direction=inbound" ;;
      --outbound) PARAMS+="&direction=outbound" ;;
      *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
    shift
  done
  avoma_curl GET "/calls/?${PARAMS}"
fi
