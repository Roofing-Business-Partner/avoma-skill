# Avoma API — Meeting Intelligence Skill

Interact with Avoma's meeting intelligence platform via REST API v1. Use when working with meeting transcripts, AI notes, call recordings, scorecards, engagement analytics, revenue intelligence, or any Avoma-related data pulls.

## Auth
- Bearer token: `AVOMA_API_KEY` in `~/.openclaw/.env`
- All scripts source `avoma-config.sh` which handles auth automatically
- Rate limit: **60 requests per minute** — stagger batch calls with 2s delays

## Quick Reference

### Core Meeting Operations
| Script | Purpose | Usage |
|--------|---------|-------|
| `avoma-meetings.sh` | List meetings by date range | `FROM TO [--calls-only\|--external-only\|--page-size N]` |
| `avoma-meeting.sh` | Get single meeting | `MEETING_UUID [--include-crm]` |
| `avoma-transcript.sh` | Get transcript | `MEETING_UUID` or `--range FROM TO` |
| `avoma-notes.sh` | Get AI notes | `MEETING_UUID [--format markdown\|json\|html]` |
| `avoma-insights.sh` | Get insights (AI notes, keywords, speakers) | `MEETING_UUID` |
| `avoma-snippets.sh` | Get meeting highlights (NEW) | `MEETING_UUID [--ai-only]` or `--range FROM TO` |
| `avoma-recordings.sh` | Get audio/video download URLs | `MEETING_UUID` |
| `avoma-sentiments.sh` | Get emotional tone over time | `MEETING_UUID` |
| `avoma-segments.sh` | Get meeting segments (intro/demo/pricing/etc) | `MEETING_UUID` |

### Calls
| Script | Purpose | Usage |
|--------|---------|-------|
| `avoma-calls.sh` | List calls or get by external ID | `FROM TO [--inbound\|--outbound]` or `--get EXT_ID` |

### Scorecards & Engagement
| Script | Purpose | Usage |
|--------|---------|-------|
| `avoma-scorecards.sh` | List scorecard templates | `[SCORECARD_UUID]` |
| `avoma-scorecard-evals.sh` | List evaluations | `[--from DATE --to DATE --meeting UUID --user EMAIL]` |
| `avoma-engagement.sh` | Engagement analytics | `FROM TO [--user UUID] [--summary]` |

### Revenue Intelligence (Beta)
| Script | Purpose | Usage |
|--------|---------|-------|
| `avoma-revenue-intel.sh` | Timeline engagement metrics | `OBJECT_TYPE START [--entity-id ID --interval week]` |

### Workflow Helpers
| Script | Purpose | Usage |
|--------|---------|-------|
| `avoma-recent.sh` | List recent meetings with UUIDs | `[DAYS_BACK] [--calls-only\|--external-only]` |
| `avoma-meeting-full.sh` | Pull all data for one meeting | `MEETING_UUID [OUTPUT_DIR]` |

### Configuration & Metadata
| Script | Purpose | Usage |
|--------|---------|-------|
| `avoma-users.sh` | List org users | `[USER_UUID]` |
| `avoma-meeting-types.sh` | Manage meeting types/purposes | `[UUID\|--create LABEL\|--delete UUID]` |
| `avoma-meeting-outcomes.sh` | Manage meeting outcomes | `[UUID\|--create LABEL\|--delete UUID]` |
| `avoma-smart-categories.sh` | List smart categories (keyword tracking) | `[UUID]` |
| `avoma-templates.sh` | List note templates | `[UUID]` |

## Common Patterns

### Pull all data for a meeting at once (recommended)
```bash
SCRIPTS=~/.openclaw/workspace/skills/avoma/scripts
# Step 1: find the UUID
bash $SCRIPTS/avoma-recent.sh 14
# Step 2: pull everything
bash $SCRIPTS/avoma-meeting-full.sh <UUID> ./output/meeting-name/
# Step 3: read locally — no more API calls
cat ./output/meeting-name/transcript.txt
jq '.' ./output/meeting-name/notes.json
```

### Get all meetings from last 7 days with transcripts
```bash
SCRIPTS=~/.openclaw/workspace/skills/avoma/scripts
bash $SCRIPTS/avoma-meetings.sh 2026-04-14 2026-04-20 --page-size 50 | jq '.results[] | select(.transcript_ready==true) | {uuid, subject, start_at}'
```

### Get transcript for a specific meeting
```bash
bash $SCRIPTS/avoma-transcript.sh <MEETING_UUID> | jq '.[] .transcript[] | "\(.speaker_id): \(.transcript)"'
```

### Get AI notes in markdown
```bash
bash $SCRIPTS/avoma-notes.sh <MEETING_UUID> --format markdown
```

### List all meetings with a specific attendee
```bash
bash $SCRIPTS/avoma-meetings.sh 2026-01-01 2026-04-20 --attendee john@example.com --page-size 100
```

### Get scorecard evaluations for a rep
```bash
bash $SCRIPTS/avoma-scorecard-evals.sh --user adam@roofingbusinesspartner.com --from 2026-04-01 --to 2026-04-20
```

### Revenue intel: opportunity engagement over time
```bash
bash $SCRIPTS/avoma-revenue-intel.sh opportunity 2026-01-01 --entity-id 56272392021 --interval week
```

## Date Format
- All dates are **UTC** in RFC3339 format
- Scripts accept `YYYY-MM-DD` (auto-converted) or full `YYYY-MM-DDTHH:MM:SSZ`
- `from_date` defaults to `T00:00:00Z`, `to_date` defaults to `T23:59:59Z`

## Pagination
- Most list endpoints return `{count, next, previous, results}`
- Default page size varies (10-20), max is 100
- Follow `next` URL for more pages, or use `--page-size 100`

## Key Entities
- **Meeting**: Foundation entity. Has UUID, subject, attendees, state (scheduled/in_progress/completed/cancelled)
- **Transcription**: Generated after recording processed. Has speaker IDs, timestamps, text
- **AI Notes**: Generated after transcription. Available in json/html/markdown
- **Insights**: AI notes + keyword occurrences + speaker stats
- **Snippets**: Highlights (AI-generated or user-created) with timestamps — NEW endpoint
- **Scorecards**: Templates with questions + evaluations with scores
- **Engagement**: Analytics on conversation listening, sharing, commenting
- **Revenue Intel**: Beta — CRM-linked timeline of meetings/calls/emails per deal/account

## Meeting States
- `scheduled` → `in_progress` → `completed` (transcript/notes available)
- `cancelled` — deleted from calendar
- Check `transcript_ready`, `notes_ready`, `audio_ready`, `video_ready` flags

## Webhooks (Reference)
Avoma can POST to your endpoint on these events:
- `AINOTE` — notes generated for a meeting/call
- `MEETING_BOOKED_VIA_SCHEDULER` — meeting booked via Avoma scheduling page
- `MEETING_BOOKED_VIA_SCHEDULER_RESCHEDULED`
- `MEETING_BOOKED_VIA_SCHEDULER_CANCELED`

## Error Handling
- Scripts print errors to stderr and return non-zero exit codes
- 429 = rate limited (wait 60s)
- 401 = bad API key
- 404 = entity not found or meeting not yet completed

## File Locations
- Scripts: `~/.openclaw/workspace/skills/avoma/scripts/`
- OpenAPI spec: `~/.openclaw/workspace/skills/avoma/references/openapi-v1.yml`
- API key: `AVOMA_API_KEY` in `~/.openclaw/.env`
