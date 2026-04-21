# CLAUDE.md — Instructions for Claude Code / Codex / AI Agents

## What This Repo Is
A collection of bash scripts that wrap the Avoma API v1. Each script handles auth, pagination, rate limits, and error handling so you don't have to rebuild curl commands.

## Setup
The scripts need `AVOMA_API_KEY` set in the environment or in a `.env` file at `~/.openclaw/.env` or `~/.openclaw/workspace/.env`. If you don't have it, ask the user to provide it.

## How to Use the Scripts
```bash
# Always run from repo root or use full path
bash scripts/avoma-meetings.sh 2026-04-01 2026-04-20
bash scripts/avoma-notes.sh <MEETING_UUID> --format markdown
bash scripts/avoma-transcript.sh <MEETING_UUID>
```

All scripts output JSON to stdout. Pipe through `jq` for filtering.

## Architecture
- `scripts/avoma-config.sh` — Shared config, auth, and `avoma_curl()` wrapper. Sourced by every script.
- `scripts/avoma-*.sh` — One script per API domain (meetings, transcripts, notes, etc.)
- `references/openapi-v1.yml` — Full OpenAPI spec for field/param reference
- `SKILL.md` — Detailed reference for OpenClaw skill system

## Key Constraints
- **Rate limit:** 60 requests/minute. If you hit 429, wait 60 seconds.
- **Dates:** Pass `YYYY-MM-DD` — scripts auto-convert to RFC3339 UTC.
- **Pagination:** Default page sizes are small (10-20). Use `--page-size 100` for bulk pulls.
- **Transcripts/Notes:** Only available after meeting state = `completed` and processing finishes.

## When Adding or Modifying Scripts
1. Source `avoma-config.sh` at the top of every script
2. Use `avoma_curl METHOD "/endpoint/"` for all API calls — it handles auth + error codes
3. Add a usage comment block at the top with examples
4. Keep scripts self-contained — no external dependencies beyond `curl`, `jq`, `bash`
5. Update the tables in both `SKILL.md` and `README.md`

## Don't
- Don't hardcode API keys in scripts
- Don't exceed 60 requests/minute — stagger batch operations
- Don't assume meetings have transcripts — check `transcript_ready` or `notes_ready` flags first
- Don't commit `.env` files or API keys
