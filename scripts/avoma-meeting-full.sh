#!/usr/bin/env bash
# Pull all data for a single meeting in one shot — transcript, notes, insights, snippets.
# Usage: avoma-meeting-full.sh MEETING_UUID [OUTPUT_DIR]
#   avoma-meeting-full.sh abc123-def456-...
#   avoma-meeting-full.sh abc123-def456-... ./output/client-name/
#
# Saves each endpoint result as a separate JSON file to OUTPUT_DIR.
# Transcript is also saved as a readable .txt file alongside the JSON.
#
# Why: Pulling everything at once and saving to disk means zero token burn
# on subsequent reads — just cat the file instead of re-calling the API.
#
# Files written:
#   meeting.json        — meeting metadata
#   notes.json          — AI-generated notes (markdown format)
#   transcription.json  — raw transcription API response
#   transcript.txt      — readable "[0s] Speaker: text" format
#   insights.json       — smart categories, keywords, talk time
#   snippets.json       — AI and user-created highlights

source "$(dirname "$0")/avoma-config.sh"

MEETING_UUID="${1:?Usage: avoma-meeting-full.sh MEETING_UUID [OUTPUT_DIR]}"
OUTPUT_DIR="${2:-/tmp/avoma-${MEETING_UUID:0:8}}"

mkdir -p "$OUTPUT_DIR"
echo "🚀 Pulling all data for: $MEETING_UUID" >&2
echo "   Output: $OUTPUT_DIR" >&2
echo "" >&2

# 1. Meeting details
echo "[1/6] Meeting details..." >&2
avoma_curl GET "/meetings/${MEETING_UUID}/" > "${OUTPUT_DIR}/meeting.json"
SUBJECT=$(jq -r '.subject // "(no subject)"' "${OUTPUT_DIR}/meeting.json" 2>/dev/null || echo "?")
START=$(jq -r '.start_at // "?"' "${OUTPUT_DIR}/meeting.json" 2>/dev/null || echo "?")
echo "      ✅ $SUBJECT ($START)" >&2

# 2. AI Notes
echo "[2/6] AI notes..." >&2
NOTES_PARAMS="from_date=2020-01-01T00:00:00Z&to_date=2030-01-01T00:00:00Z&meeting_uuid=${MEETING_UUID}&output_format=markdown"
avoma_curl GET "/notes/?${NOTES_PARAMS}" > "${OUTPUT_DIR}/notes.json"
NOTES_COUNT=$(jq '.count // 0' "${OUTPUT_DIR}/notes.json" 2>/dev/null || echo "?")
echo "      ✅ ${NOTES_COUNT} note set(s)" >&2

# 3. Transcription
echo "[3/6] Transcription..." >&2
TRANS_PARAMS="from_date=2020-01-01T00:00:00Z&to_date=2030-01-01T00:00:00Z&meeting_uuid=${MEETING_UUID}"
avoma_curl GET "/transcriptions/?${TRANS_PARAMS}" > "${OUTPUT_DIR}/transcription.json"
TRANS_UUID=$(jq -r '.results[0].uuid // empty' "${OUTPUT_DIR}/transcription.json" 2>/dev/null)

if [ -n "$TRANS_UUID" ]; then
  # Overwrite with full single-transcription response (includes transcript array)
  avoma_curl GET "/transcriptions/${TRANS_UUID}/" > "${OUTPUT_DIR}/transcription.json"
  # Write readable .txt
  jq -r '
    .transcript // [] |
    map("[\(.start_time | floor)s] \(.speaker_email // .speaker_name // "Speaker"): \(.transcript // .text // "")") |
    join("\n")
  ' "${OUTPUT_DIR}/transcription.json" > "${OUTPUT_DIR}/transcript.txt" 2>/dev/null || true
  LINE_COUNT=$(wc -l < "${OUTPUT_DIR}/transcript.txt" | tr -d ' ')
  echo "      ✅ ${LINE_COUNT} transcript lines → transcript.txt" >&2
else
  echo "      ⚠️  No transcription available yet" >&2
  echo "[]" > "${OUTPUT_DIR}/transcription.json"
  touch "${OUTPUT_DIR}/transcript.txt"
fi

# 4. Insights
echo "[4/6] Insights..." >&2
if avoma_curl GET "/meetings/${MEETING_UUID}/insights/" > "${OUTPUT_DIR}/insights.json" 2>/dev/null; then
  echo "      ✅ Saved" >&2
else
  echo "      ⚠️  Insights not available (may not be processed yet)" >&2
  echo "{}" > "${OUTPUT_DIR}/insights.json"
fi

# 5. Snippets
echo "[5/6] Snippets..." >&2
avoma_curl GET "/snippets/?meeting_uuid=${MEETING_UUID}&page_size=100" > "${OUTPUT_DIR}/snippets.json"
SNIPPET_COUNT=$(jq '.count // 0' "${OUTPUT_DIR}/snippets.json" 2>/dev/null || echo "?")
echo "      ✅ ${SNIPPET_COUNT} snippet(s)" >&2

# 6. Sentiments
echo "[6/6] Sentiments..." >&2
if avoma_curl GET "/meeting_sentiments/?meeting_uuid=${MEETING_UUID}" > "${OUTPUT_DIR}/sentiments.json" 2>/dev/null; then
  echo "      ✅ Saved" >&2
else
  echo "      ⚠️  Sentiments not available" >&2
  echo "{}" > "${OUTPUT_DIR}/sentiments.json"
fi

echo "" >&2
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
echo "✅ Done: $OUTPUT_DIR" >&2
echo "   meeting.json       meeting metadata" >&2
echo "   notes.json         AI notes (markdown)" >&2
echo "   transcription.json raw transcript data" >&2
echo "   transcript.txt     readable speaker log" >&2
echo "   insights.json      smart categories + talk time" >&2
echo "   snippets.json      highlights (${SNIPPET_COUNT})" >&2
echo "   sentiments.json    emotional tone timeline" >&2

# Emit the output directory path to stdout so callers can capture it
echo "$OUTPUT_DIR"
