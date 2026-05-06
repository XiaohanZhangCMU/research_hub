# Papers Inbox

Drop academic papers here (`.pdf` or `.md`) and Claude will absorb each one into a topic-based **literature review** post in `src/content/posts/lit-review-<topic>.mdx`. One paper can land in multiple reviews. New review posts include foundational background (history, equations, general algorithms) when no existing topic fits.

## How it works

- State lives **in the review posts themselves** as HTML comment markers (`<!-- paper-file: ... paper-hash: ... -->`). No external state file.
- "Unprocessed" = a file in this folder whose 12-char sha256 prefix is not present in any `lit-review-*.mdx`.
- Re-saving a paper (different hash, same filename) replaces the existing section — no duplicates.

## Two ways to run

### 1. On-demand (any session)
In a Claude Code session opened in the repo root:
```
/update-reviews
```

### 2. Hands-free local daemon (event-driven)
Install once: `brew install fswatch`

Run:
```bash
./scripts/watch-inbox.sh
```
The script debounces bursts, locks single-flight, and runs `/update-reviews` whenever this folder changes. Ctrl-C to stop.

### 3. Hands-free cloud cron (fallback)
A scheduled Claude Code routine runs `/update-reviews` every 30 min in the cloud. Catches anything missed when the local daemon isn't running. Manage via the `schedule` skill.

## After processing

Successful runs auto-commit and push to `main`, which deploys to Vercel within ~30s. The build is the gate: if `npm run build` fails, edits are reverted and nothing is pushed. Generated posts have `reviewed: false` until you give them a human pass.

## Notes

- PDFs in this folder are **gitignored** (the review post is the canonical artifact). Markdown papers are tracked.
- Filename becomes the stable identifier — pick something descriptive (e.g. `llm-qat.pdf`, not `paper.pdf`).
