#!/usr/bin/env bash
# Revenue Intelligence (Beta) — timeline engagement metrics
# Usage: avoma-revenue-intel.sh OBJECT_TYPE START_DATE [OPTIONS]
#   avoma-revenue-intel.sh opportunity 2026-01-01
#   avoma-revenue-intel.sh account 2026-01-01 --entity-id 12345 --interval week
#   avoma-revenue-intel.sh opportunity 2026-01-01 --details --type meeting
#
# OBJECT_TYPE: opportunity | account | contact | lead
#
# Options:
#   --entity-id ID     CRM entity external ID
#   --end DATE         End date (default: now)
#   --interval DAY     day|week|month (default: day)
#   --details          Get individual records instead of aggregated timeline
#   --type TYPE        For details: meeting|call|email
#   --email EMAIL      Filter by participant email (details only)
#   --host HOST        Filter: rep|customer (details only)
#   --page-size N      For details pagination

source "$(dirname "$0")/avoma-config.sh"

OBJ_TYPE="${1:?Usage: avoma-revenue-intel.sh OBJECT_TYPE START_DATE [OPTIONS]}"
START="${2:?Usage: avoma-revenue-intel.sh OBJECT_TYPE START_DATE}"
shift 2

DETAILS=false
PARAMS="object_type=${OBJ_TYPE}&start_at=$(to_rfc3339 "$START")"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --entity-id) shift; PARAMS+="&crm_entity_id=$1" ;;
    --end)       shift; PARAMS+="&end_at=$(to_rfc3339 "$1" "T23:59:59Z")" ;;
    --interval)  shift; PARAMS+="&date_interval=$1" ;;
    --details)   DETAILS=true ;;
    --type)      shift; PARAMS+="&type=$1" ;;
    --email)     shift; PARAMS+="&email=$1" ;;
    --host)      shift; PARAMS+="&host=$1" ;;
    --page-size) shift; PARAMS+="&page_size=$1" ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

if [ "$DETAILS" = true ]; then
  avoma_curl GET "/revenue_intel/timeline_details/?${PARAMS}"
else
  avoma_curl GET "/revenue_intel/timeline/?${PARAMS}"
fi
