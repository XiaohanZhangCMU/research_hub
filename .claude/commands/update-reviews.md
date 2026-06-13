---
description: Absorb new papers from inbox/papers/ into integrated literature-review blog posts, then auto-commit and push.
---

You are running the Literature Review Inbox procedure for this repo. Use the project skill at `.claude/skills/literature-review-blog/SKILL.md` as the governing standard.

Your job: scan `inbox/papers/` for unprocessed papers, absorb each one into one or more `src/content/posts/lit-review-*.mdx` posts as an integrated review article, verify the build, then commit and push.

Be terse. Don't narrate; act. Print only the final summary at the end.

## Non-Negotiable Review Standard

- Do **not** append paper-by-paper summaries as the normal update path.
- Rewrite the review around concepts, algorithms, math, empirical evidence, open problems, and references.
- Merge the new paper's ideas into the existing field narrative.
- Add every processed paper and important cited work to `## References`.
- Make every reference title a Markdown hyperlink to the canonical paper page. Prefer arXiv abstract pages for arXiv papers; otherwise use DOI, OpenReview, ACL Anthology, official proceedings, publisher, conference, or author-hosted paper pages. Search for missing links before finalizing.
- Add enough context and background for readers entering the field: motivating problem, prior baseline families, terminology, assumptions, evaluation conventions, and why the new work changes the field narrative.
- Preserve machine-readable provenance with `paper-file` and `paper-hash` comments in reference entries.
- Use KaTeX for math: `$...$` inline, `$$...$$` display.

## Procedure

### Step 1 — Discover

Run in parallel:
- `ls inbox/papers/ 2>/dev/null` (filter to `*.pdf` and `*.md`, ignore `README.md`, `.gitkeep`, dotfiles)
- `ls src/content/posts/lit-review-*.mdx 2>/dev/null` (existing reviews; may be empty)

For each paper file, compute the 12-char hash:
```bash
shasum -a 256 inbox/papers/<file> | cut -c1-12
```

Build the set of already-processed hashes by grepping all existing review posts:
```bash
grep -ho 'paper-hash: [a-f0-9]\{12\}' src/content/posts/lit-review-*.mdx 2>/dev/null | awk '{print $2}' | sort -u
```

**Unprocessed papers** = papers whose hash is NOT in that set. If empty, print `No new papers to absorb.` and stop with no commit and no push.

### Step 2 — Read and place each paper

- `.md` → read the entire file.
- `.pdf` → extract title/abstract/intro, method sections, algorithms/equations, experiment tables, conclusion, and references.
- Extract: title, authors, year, topic fit, core contribution, math/algorithmic contribution, evaluation claims, limitations, and important cited works.
- Choose the target review by topic fit. Prefer merging into an existing review. Create a new `lit-review-<topic-slug>.mdx` only when no existing review can naturally absorb the paper.
- A paper can land in multiple reviews only when its core contribution genuinely spans multiple topics.

### Step 3 — Rewrite the review

Follow `.claude/skills/literature-review-blog/SKILL.md` and, for substantive rewrites, `.claude/skills/literature-review-blog/references/review-style.md`.

Required post metadata:
```yaml
---
title: "Literature Review: <Topic Name>"
description: "<1-sentence topic description>"
date: <YYYY-MM-DD of first review creation>
updated: <today YYYY-MM-DD>
tags: ["literature-review", <topic-tags...>]
series: "lit-review-<topic-slug>"
draft: false
generated: true
reviewed: false
---
```

Reference entries for processed inbox papers must include:
```mdx
- <Authors>. "[<Title>](<canonical-paper-url>)." <Venue or arXiv>, <Year>.
  {/* paper-file: <filename> paper-hash: <12char-hash> */}
```

For a changed file with an existing `paper-file` marker, update the corresponding reference marker and re-integrate the paper's revised ideas into the body. Do not create duplicates.

### Step 4 — Build verify

```bash
ASTRO_TELEMETRY_DISABLED=1 PATH="/opt/homebrew/bin:$PATH" npm run build
```

If it fails:
1. Revert only your review-post edits.
2. Print the build error and which paper(s) you were processing.
3. Stop. Do not commit. Do not push.

### Step 5 — Auto-commit and push

On build success:
```bash
git add src/content/posts/lit-review-*.mdx
git commit -m "chore(reviews): absorb <comma-separated paper filenames>"
git push
```

If `git push` fails non-fast-forward, run `git pull --rebase` and retry once. If it still fails, abort with the conflict message. Never force-push, never amend, never use `--no-verify`.

### Step 6 — Final summary

Print exactly:
```text
Processed N paper(s):
  - <paper>.pdf → lit-review-<topic>.mdx [created|rewritten]
  - ...
Build: ok
Commit: <short-sha>
Pushed to main. Vercel deploy: ~30s.
```

## Notes

- Today's date: use `date +%Y-%m-%d`.
- PDFs are gitignored; commit only review posts unless the user asks otherwise.
- Build catches broken MDX, not weak synthesis. The skill standard is the content gate.
