#!/usr/bin/env bash
# Avoma API shared config — sourced by all avoma-* scripts
# Usage: source "$(dirname "$0")/avoma-config.sh"

set -euo pipefail

AVOMA_BASE_URL="https://api.avoma.com/v1"

# Load API key from .env
if [ -z "${AVOMA_API_KEY:-}" ]; then
  for env_file in ~/.openclaw/.env ~/.openclaw/workspace/.env; do
    if [ -f "$env_file" ]; then
      AVOMA_API_KEY=$(grep "^AVOMA_API_KEY=" "$env_file" | head -1 | cut -d= -f2-)
      [ -n "$AVOMA_API_KEY" ] && break
    fi
  done
fi

if [ -z "${AVOMA_API_KEY:-}" ]; then
  echo "ERROR: AVOMA_API_KEY not found in environment or .env files" >&2
  exit 1
fi

# Common curl wrapper with auth, rate-limit awareness, and error handling
avoma_curl() {
  local method="${1:-GET}"
  local endpoint="$2"
  shift 2
  local url="${AVOMA_BASE_URL}${endpoint}"
  
  local response
  local http_code
  
  # Use -w to capture HTTP status code
  response=$(curl -s -w "\n%{http_code}" \
    -X "$method" \
    -H "Authorization: Bearer ${AVOMA_API_KEY}" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    "$@" \
    "$url")
  
  http_code=$(echo "$response" | tail -1)
  local body=$(echo "$response" | sed '$d')
  
  case "$http_code" in
    200|201|202|204) echo "$body" ;;
    429)
      echo "ERROR: Rate limited (429). Wait 60s before retrying. Max 60 req/min." >&2
      echo "$body" >&2
      return 1
      ;;
    401)
      echo "ERROR: Unauthorized (401). Check AVOMA_API_KEY." >&2
      return 1
      ;;
    404)
      echo "ERROR: Not found (404)." >&2
      echo "$body" >&2
      return 1
      ;;
    *)
      echo "ERROR: HTTP $http_code" >&2
      echo "$body" >&2
      return 1
      ;;
  esac
}

# Helper: format ISO date from YYYY-MM-DD to RFC3339
to_rfc3339() {
  local date_str="$1"
  local time_suffix="${2:-T00:00:00Z}"
  # If already has T, pass through
  if [[ "$date_str" == *T* ]]; then
    echo "$date_str"
  else
    echo "${date_str}${time_suffix}"
  fi
}
