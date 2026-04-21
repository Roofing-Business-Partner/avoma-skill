# AGENTS.md — Agent Operating Guide

## Purpose
This repo is a shared toolkit for RBP agents and team members who need to pull data from Avoma. It's designed to save tokens and time — run a script instead of rebuilding API calls from scratch.

## Who Uses This
- **Claudio** (Steward) — meeting intelligence pipeline, daily briefings, engagement tracking
- **Vito** (RoofClaw Sales) — prospect call analysis, onboarding call transcripts
- **Sal** (CRO/SalesAssistant) — pipeline intelligence, deal meeting history
- **Team members** via Claude Code / Codex — ad-hoc meeting data pulls

## How to Contribute
1. Clone the repo
2. Create a branch: `git checkout -b <your-name>/<feature>`
3. Add or modify scripts following the patterns in `CLAUDE.md`
4. Open a PR with a clear description of what changed and why
5. Another agent or team member reviews before merge

## Script Standards
- Every script sources `avoma-config.sh` for auth
- Every script has a usage comment block at the top
- Scripts output JSON — let the caller decide how to format
- No hardcoded keys, no RBP-specific logic (keep it generic)
- Error messages go to stderr, data goes to stdout

## API Key Management
Each user/agent needs their own Avoma API key. Keys are never committed to this repo.

**Where to store it:**
- OpenClaw agents: `AVOMA_API_KEY=xxx` in `~/.openclaw/.env`
- Claude Code / terminal: `export AVOMA_API_KEY=xxx` in your shell profile
- CI/CD: Use secrets management

## Review Checklist (for PRs)
- [ ] Scripts source `avoma-config.sh`
- [ ] Usage comment block is accurate
- [ ] No hardcoded credentials
- [ ] Error handling uses `avoma_curl` wrapper (not raw curl)
- [ ] Tables updated in SKILL.md and README.md
- [ ] Tested against live API (mention which endpoint in PR)
