# Avoma Skill

Reusable bash scripts for the [Avoma](https://avoma.com) meeting intelligence API. Built for AI agents (OpenClaw, Claude Code, Codex) but works from any terminal.

**What it does:** Pull meeting transcripts, AI notes, call recordings, scorecard evaluations, engagement analytics, and revenue intelligence from Avoma — without rewriting curl commands or burning tokens figuring out the API every time.

## Quick Start

### 1. Get your Avoma API key

Follow [Avoma's API Integration guide](https://help.avoma.com/api-integration-for-avoma) to generate your Client Key.

### 2. Set it in your environment

```bash
# Add to your .env or export directly
export AVOMA_API_KEY="your-client-key-here"
```

The scripts also check `~/.openclaw/.env` and `~/.openclaw/workspace/.env` automatically.

### 3. Run a script

```bash
# List meetings from the last 7 days
bash scripts/avoma-meetings.sh 2026-04-14 2026-04-20

# Get AI notes for a specific meeting
bash scripts/avoma-notes.sh <MEETING_UUID> --format markdown

# Get a transcript
bash scripts/avoma-transcript.sh <MEETING_UUID>

# Engagement analytics for Q1
bash scripts/avoma-engagement.sh 2026-01-01 2026-03-31 --summary
```

## Scripts

### Core Meeting Operations
| Script | What it does |
|--------|-------------|
| `avoma-meetings.sh` | List meetings by date range with filters (calls-only, external-only, by attendee, by CRM account) |
| `avoma-meeting.sh` | Get a single meeting by UUID |
| `avoma-transcript.sh` | Get transcript for a meeting, by UUID, or list by date range |
| `avoma-notes.sh` | Get AI-generated notes (markdown, json, or html) |
| `avoma-insights.sh` | Get meeting insights (AI notes + keywords + speaker stats) |
| `avoma-snippets.sh` | Get meeting highlights — AI-generated or user-created |
| `avoma-recordings.sh` | Get signed audio/video download URLs (valid 5 days) |
| `avoma-sentiments.sh` | Get emotional tone analysis over the meeting timeline |
| `avoma-segments.sh` | Get meeting segments (intro, demo, pricing, next steps, etc.) |

### Calls
| Script | What it does |
|--------|-------------|
| `avoma-calls.sh` | List calls by date range (inbound/outbound filter), or get by external ID |

### Scorecards & Engagement
| Script | What it does |
|--------|-------------|
| `avoma-scorecards.sh` | List scorecard templates |
| `avoma-scorecard-evals.sh` | List scorecard evaluations (filter by date, meeting, user, scorecard) |
| `avoma-engagement.sh` | Engagement analytics — who's listening, sharing, commenting on meetings |

### Revenue Intelligence (Beta)
| Script | What it does |
|--------|-------------|
| `avoma-revenue-intel.sh` | CRM-linked timeline of meetings/calls/emails per deal or account |

### Configuration & Metadata
| Script | What it does |
|--------|-------------|
| `avoma-users.sh` | List org users |
| `avoma-meeting-types.sh` | List/create/delete meeting types (purposes) |
| `avoma-meeting-outcomes.sh` | List/create/delete meeting outcomes |
| `avoma-smart-categories.sh` | List smart categories (keyword/prompt tracking) |
| `avoma-templates.sh` | List note templates |

## How It Works

All scripts source `scripts/avoma-config.sh` which handles:
- **Auth**: Reads `AVOMA_API_KEY` from environment or `.env` files
- **Rate limits**: 60 requests/minute — errors print clearly on 429
- **Error handling**: HTTP status detection with clear error messages
- **Date formatting**: Accepts `YYYY-MM-DD` (auto-converts to RFC3339 UTC)

## Common Patterns

```bash
SCRIPTS=./scripts

# All external meetings this month with transcripts ready
bash $SCRIPTS/avoma-meetings.sh 2026-04-01 2026-04-30 --external-only --page-size 100 \
  | jq '.results[] | select(.transcript_ready==true) | {uuid, subject, start_at}'

# Scorecard evaluations for a specific rep
bash $SCRIPTS/avoma-scorecard-evals.sh --user rep@company.com --from 2026-04-01 --to 2026-04-30

# Revenue engagement timeline for a deal
bash $SCRIPTS/avoma-revenue-intel.sh opportunity 2026-01-01 --entity-id 56272392021 --interval week

# All snippets (highlights) from a meeting
bash $SCRIPTS/avoma-snippets.sh <MEETING_UUID> --ai-only
```

## For OpenClaw Users

Drop the `skills/avoma/` directory into your workspace `skills/` folder. OpenClaw will pick up the `SKILL.md` automatically and reference it when you ask about Avoma.

## API Reference

Full OpenAPI v1 spec is in `references/openapi-v1.yml` for when you need to check field names, query params, or response shapes.

**Rate limit:** 60 requests per minute. Scripts will tell you when you hit it.

**Dates:** All UTC, RFC3339 format. Scripts accept `YYYY-MM-DD` for convenience.

**Pagination:** Most list endpoints return `{count, next, previous, results}`. Use `--page-size 100` for max page size.

## Contributing

PRs welcome. If you add a script, follow the pattern:
1. Source `avoma-config.sh` at the top
2. Use `avoma_curl METHOD /endpoint/` for all API calls
3. Add a usage comment block
4. Add it to the table in SKILL.md and this README

## License

Internal RBP tool. Team members: get your own API key from Avoma, don't share keys.
