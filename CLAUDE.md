# CLAUDE.md — Research Hub

This file is read automatically by Claude Code or Codex at session start. It contains everything needed to work on this repo without prior context.

---

## What This Is

A personal research/writing site for Xiaohan Zhang (张小寒), built with Astro 5 (static site). Live at **https://research-hub-six-gamma.vercel.app/**. Source at **https://github.com/XiaohanZhangCMU/research_hub**.

Stack: Astro 5 + Tailwind v4 + MDX + KaTeX + Vercel (auto-deploy on push to `main`).

---

## Local Build Setup

This repo now builds on a normal laptop with the public npm registry.

- Do **not** create a Databricks npm-proxy `.npmrc`.
- `.npmrc` remains gitignored for local overrides only; it should normally be absent.
- Vercel also installs from the public npm registry.

Node is at `/opt/homebrew/bin/node` (not in default PATH). Always prefix commands:
```bash
PATH="/opt/homebrew/bin:$PATH" npm install
ASTRO_TELEMETRY_DISABLED=1 PATH="/opt/homebrew/bin:$PATH" npm run build
```

Why `ASTRO_TELEMETRY_DISABLED=1`: in the Codex sandbox, Astro telemetry may try to write under `~/Library/Preferences/astro`, which is outside the workspace and fails with `EPERM`. Disabling telemetry keeps builds self-contained. The same flag is harmless on the user's machine.

If `npm install` fails in Codex with `ENOTFOUND registry.npmjs.org`, rerun it with network escalation. If npm reports a broken `~/.npm` cache, use a local cache and delete it afterward:
```bash
PATH="/opt/homebrew/bin:$PATH" npm install --cache .npm-cache
rm -rf .npm-cache
```

---

## Deploy Workflow

Every push to `main` auto-deploys to Vercel. The full cycle:

```bash
# make changes to files
ASTRO_TELEMETRY_DISABLED=1 PATH="/opt/homebrew/bin:$PATH" npm run build
git add <files>
git commit -m "..."
git push                                        # triggers Vercel deploy (~30s)
```

No manual deploy step. No wrangler. No deploy command in Vercel — it's a static Pages project.

---

## Project Structure

```
src/
  content/
    config.ts                   # Zod schema for content collections
    posts/                      # MDX blog posts (published)
  components/
    Comments.astro              # Cusdis anonymous comments widget
    TipJar.astro                # Stripe $1/$5 tip buttons
  layouts/
    PostLayout.astro            # Layout for all blog posts (includes KaTeX CSS, TipJar, Comments)
  pages/
    index.astro                 # Homepage with bio + recent posts
    writing.astro               # Blog index
    writing/[...slug].astro     # Dynamic post route
  styles/
    global.css                  # Tailwind v4 + typography plugin

inbox/
  drafts/                       # Drop .md files here for conversion to blog posts

.github/
  workflows/
    ci.yml                      # Builds on every push/PR (GitHub Actions)
```

---

## Adding a Blog Post

### From the inbox (preferred)
1. User drops a `.md` file in `inbox/drafts/`
2. Claude reads it, converts to MDX with proper frontmatter and KaTeX math
3. Saves to `src/content/posts/YYYY-MM-DD-slug.mdx`
4. Runs `npm run build` to verify
5. Commits and pushes

### Frontmatter schema (required fields)
```yaml
---
title: "..."
description: "..."
date: YYYY-MM-DD
tags: ["tag1", "tag2"]
draft: false          # true = hidden from site, false = published
generated: false
reviewed: false
series: "optional-series-slug"
---
```

### Math formatting
- Inline math: `$x^2 + y^2$`
- Display math: `$$\int_0^t f(s)\,ds$$`
- KaTeX CSS loads from CDN in PostLayout — no extra setup needed
- When converting from plain-text drafts, infer LaTeX from context (e.g. `dX = mu dt + sigma dW` → `$dX_t = \mu\,dt + \sigma\,dW_t$`)

---

## Literature Review Inbox

A separate flow from `inbox/drafts/`. Drop **academic papers** (`.pdf` or `.md`) into `inbox/papers/` and agents absorb each into a topic-based literature review post at `src/content/posts/lit-review-<topic>.mdx`.

Use the project skill `.claude/skills/literature-review-blog/SKILL.md` for this work. It is an Agent Skills-format skill, so Claude Code can discover it from `.claude/skills/`; Codex agents should read and follow the same `SKILL.md` when updating literature reviews.

The standard is an integrated review article, not a paper-by-paper summary. Each update should re-evaluate the review's structure, merge the new paper into the field narrative, include mathematical and algorithmic details, and maintain `## References` as the bibliography/knowledge graph.

### State model
**State lives in the review posts themselves**, not in a sidecar file. Every processed paper's reference entry embeds:
```mdx
- <Authors>. "<Title>." <Venue or arXiv>, <Year>.
  {/* paper-file: <filename> paper-hash: <12char-sha256> */}
```
- `paper-file` = stable identifier (matches `inbox/papers/` filename).
- `paper-hash` = first 12 chars of `shasum -a 256`.
- "Unprocessed" = a file in `inbox/papers/` whose hash isn't present in any `lit-review-*.mdx`. Self-healing, survives manual edits.
- Re-saving a paper (different hash, same filename) means re-integrate the revised paper and update the existing reference marker, with no duplicate entries.

### Review post conventions
- File: `src/content/posts/lit-review-<topic-slug>.mdx`
- Frontmatter: `title: "Literature Review: <Topic>"`, `series: "lit-review-<topic-slug>"`, `tags: ["literature-review", ...topic-tags]`, `generated: true`, `reviewed: false`
- Body should be organized around the field, not around papers. Typical sections: `## Overview`, `## Conceptual Map`, `## Mathematical Setup`, `## Algorithms and Design Patterns`, `## Empirical Picture`, `## Open Problems`, `## References`.
- Existing `## Papers` / `### Paper` posts are legacy source notes. When touching one, progressively rewrite it into the integrated structure and move markers into `## References`.

### Three ways to run

1. **On-demand:** `/update-reviews` in any Claude Code session in the repo root. Defined at `.claude/commands/update-reviews.md`.
2. **Local event-driven daemon:** `./scripts/watch-inbox.sh`. Requires `brew install fswatch` once. Debounces 5s, single-flight via `flock`, runs `claude -p "/update-reviews"` on each batch. Foreground process; Ctrl-C to stop.
3. **Cloud cron fallback:** A `schedule` skill routine runs `/update-reviews` every 30 min. Catches anything missed when the local daemon isn't running.

### After processing
Successful runs **auto-commit and push** to `main` → Vercel deploys in ~30s. Build success is the gate: if `npm run build` fails, review edits are reverted and nothing is pushed.

### Recovery
- **Bad summarization went live?** `git revert <sha>` and push. The `reviewed: false` flag on each generated post marks it as "needs human pass" before final.
- **Build keeps failing on a paper?** Move the paper out of `inbox/papers/` temporarily; the procedure ignores anything not in that folder.
- **Local daemon and cron racing?** Second push fails non-fast-forward; the procedure retries once with `git pull --rebase`. If it still fails, abort and re-run manually.

### Notes
- PDFs are gitignored (`inbox/papers/*.pdf`); only the review posts are committed. Markdown papers in `inbox/papers/*.md` are tracked.
- Pre-approved bash patterns in `.claude/settings.local.json` keep the non-interactive `claude -p` runs from stalling on permission prompts.

---

## Key Services

### Comments — Cusdis
- **App ID:** `68a93e19-994e-4d21-b4fe-c338adbd52a2`
- **Dashboard:** https://cusdis.com/dashboard/project/68a93e19-994e-4d21-b4fe-c338adbd52a2
- Configured in `src/components/Comments.astro`
- Anonymous — readers need no account

### Tips — Stripe
- **$1:** https://buy.stripe.com/cNi14p9jZ05k0oZ1tc5c400
- **$5:** https://buy.stripe.com/eVqcN7eEj6tIfjT4Fo5c401
- Configured in `src/components/TipJar.astro`
- Readers pay with credit card, no Stripe account needed

---

## Common Tasks

### Verify build
```bash
ASTRO_TELEMETRY_DISABLED=1 PATH="/opt/homebrew/bin:$PATH" npm run build
```

### Local dev server
```bash
ASTRO_TELEMETRY_DISABLED=1 PATH="/opt/homebrew/bin:$PATH" npm run dev
# opens at localhost:4321
```

### Install new packages
```bash
PATH="/opt/homebrew/bin:$PATH" npm install <package>
# uses the default public npm registry unless the user has a local override
```

### Add a downloaded paper to a literature review
1. Inspect the PDF and compute its stable marker:
```bash
python3 -c "from pypdf import PdfReader; r=PdfReader('/path/to/paper.pdf'); print(len(r.pages)); print((r.pages[0].extract_text() or '')[:4000])"
shasum -a 256 /path/to/paper.pdf
```
2. Copy the PDF into `inbox/papers/<filename>.pdf`. PDFs are gitignored, but the source path in the post should still point there.
3. Pick the best existing `src/content/posts/lit-review-*.mdx` topic, or create a new topic if none fits.
4. Read `.claude/skills/literature-review-blog/SKILL.md`; for substantive rewrites, also read `.claude/skills/literature-review-blog/references/review-style.md`.
5. Rewrite the target review around concepts, algorithms, math, evidence, and open problems. Merge the paper's ideas into the body instead of appending a paper summary.
6. Add the processed paper to `## References` with:
```mdx
- <Authors>. "<Title>." <Venue or arXiv>, <Year>.
  {/* paper-file: <filename>.pdf paper-hash: <first-12-sha256> */}
```
7. Add important papers cited by the new paper to `## References` too; unprocessed cited works do not get `paper-file` markers.
8. Update the post's `updated:` date and run the build command above.

### Check if a change is live
```bash
curl -s "https://research-hub-six-gamma.vercel.app/" | grep -o '<title>[^<]*</title>'
# or check specific content in a post page
```

### KaTeX not rendering (math shows raw LaTeX)
KaTeX CSS loads from CDN in `PostLayout.astro`. If math appears broken:
1. Check `<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.21/dist/katex.min.css">` is in the `<head>` of `PostLayout.astro`
2. Do NOT import `katex/dist/katex.min.css` via npm — Vite doesn't bundle the font paths correctly

### Comment form looks unstyled
Tailwind's preflight CSS resets all form elements globally. The fix is `<style is:global>` in `Comments.astro` that restores borders/padding. If Cusdis updates its widget structure, update those selectors.

### Width / layout
- Homepage: `max-w-3xl mx-auto` in `src/pages/index.astro`
- Blog posts: `max-w-3xl mx-auto` in `src/layouts/PostLayout.astro`
- Writing index: `max-w-3xl mx-auto` in `src/pages/writing.astro`
- To widen everything: change `max-w-3xl` → `max-w-4xl` or `max-w-5xl`

---

## Known Quirks

1. **`package-lock.json` is gitignored** — Vercel runs a fresh `npm install` against the public registry on each deploy.
2. **`.npmrc` is gitignored** — local override only. Do not commit it, and do not recreate the old Databricks proxy config on this laptop.
3. **`npm run build` includes `astro build` only** — Pagefind is not yet wired into the build script (planned for later when search is needed).
4. **Astro may rewrite `.astro/*` generated files during build/dev.** Keep the commit focused on source/content files unless a generated file change is intentional.
5. **Vercel project type is Pages (static), not Workers** — if you ever need to recreate the Vercel project, choose "Pages → Connect to Git", NOT "Workers". Workers requires a deploy command and breaks.
