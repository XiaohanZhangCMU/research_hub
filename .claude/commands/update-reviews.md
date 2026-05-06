---
description: Absorb new papers from inbox/papers/ into topic-based literature review posts, then auto-commit and push.
---

You are running the Literature Review Inbox procedure for this repo. Your job: scan `inbox/papers/` for unprocessed papers, absorb each one into one or more `lit-review-<topic>.mdx` posts in `src/content/posts/`, verify the build, then commit and push.

Be terse. Don't narrate; act. Print only the final summary at the end.

## Conventions (must follow exactly)

- Review post path: `src/content/posts/lit-review-<topic-slug>.mdx`
- Frontmatter:
  ```yaml
  ---
  title: "Literature Review: <Topic Name>"
  description: "<1-sentence topic description>"
  date: <YYYY-MM-DD of first paper added>
  updated: <YYYY-MM-DD of latest paper added>   # add/update on every run
  tags: ["literature-review", <topic-tags...>]
  series: "lit-review-<topic-slug>"
  draft: false
  generated: true
  reviewed: false
  ---
  ```
- Each paper's section in a review:
  ```mdx
  ### <Paper Title>
  <!-- paper-file: <filename> paper-hash: <12char-hash> -->
  **Authors:** <names>
  **Year:** <YYYY>
  **Source:** `inbox/papers/<filename>`

  **Contribution:** <2-3 sentence summary>

  **Key ideas:**
  - <bullet 1>
  - <bullet 2>
  - <bullet 3-5>

  **Connections:** <how it relates to other papers in this review, or "First paper in this review.">
  ```
- Use KaTeX for math: `$...$` inline, `$$...$$` display. CDN loads in PostLayout.

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

**Unprocessed papers** = papers whose hash is NOT in that set. If empty, print `No new papers to absorb.` and stop (no commit, no push).

### Step 2 — For each unprocessed paper

#### 2a. Read the paper
- `.md` → Read entire file.
- `.pdf` → Read pages `1-3` first (abstract, intro, contributions). If you decide a new review is needed (Step 2c), also Read pages around the methods/algorithm and the last 2 pages (conclusion). Use the `pages` parameter — required for PDFs over 10 pages.

Extract: title, authors, year, **core contribution** (1-2 sentences), 3-5 **key ideas**, **topic** (1-3 words like "quantization-aware-training", "agentic-rl", "zeroth-order-optimization").

#### 2b. Discover existing reviews
For each existing `lit-review-*.mdx`, read its frontmatter (title, tags, series). You can do this in one shot with:
```bash
head -n 15 src/content/posts/lit-review-*.mdx
```

#### 2c. Decide placement
- **Merges into existing review(s)** if its core contribution shares the review's primary topic — not just tangentially related. A paper can land in **multiple** reviews when its contribution genuinely spans topics (e.g. an "RL for quantization" paper in both the quantization and RL reviews).
- **Creates a new review** only when no existing review's topic is close enough.
- Be decisive. Don't create near-duplicate reviews ("quantization" vs "model-quantization"). Prefer merging.

#### 2d. Apply

**Creating a new review** (`src/content/posts/lit-review-<topic-slug>.mdx`):
1. Write frontmatter (date and updated both = today, ISO format).
2. Write `# Literature Review: <Topic>`.
3. Write `## Overview` — foundational background from your domain knowledge: brief history of the field, core equations (KaTeX), main algorithm families. ~300-500 words. This is what makes a review post useful even with one paper.
4. Write `## Key Concepts` — vocabulary, common notation. ~100-200 words.
5. Write `## Papers`, then the first `### Paper` subsection per the convention above.

**Merging into an existing review:**
1. Read the file.
2. Search for `<!-- paper-file: <this-paper-filename>` (this exact filename). If found → the paper was processed before but the hash changed; replace the entire `### Paper` section (from its `### ` line down to the next `### ` or end of `## Papers`). If not found → append a new `### Paper` subsection at the end of `## Papers`.
3. Update the `updated:` frontmatter line to today's date.
4. If `## Papers` doesn't exist (shouldn't happen for a `lit-review-*` file but be defensive), append it.

### Step 3 — Build verify (gate)

```bash
PATH="/opt/homebrew/bin:$PATH" npm run build
```
If it fails:
1. Revert: `git checkout -- src/content/posts/lit-review-*.mdx`
2. Print the build error and which paper(s) you were processing.
3. **Stop. Do not commit. Do not push.**

### Step 4 — Auto-commit and push

On build success, in parallel:
- `git add src/content/posts/lit-review-*.mdx`
- (Then sequentially) `git commit -m "$(cat <<'EOF'
chore(reviews): absorb <comma-separated paper filenames>

<one-line summary of which papers landed in which reviews>

Co-authored-by: Isaac
EOF
)"`
- Then `git push`

### Step 5 — Final summary

Print exactly:
```
Processed N paper(s):
  - <paper>.pdf → lit-review-<topic>.mdx [created|updated]
  - ...
Build: ok
Commit: <short-sha>
Pushed to main. Vercel deploy: ~30s.
```

## Notes

- Today's date: use `date +%Y-%m-%d` (UTC is fine for this site).
- If `inbox/papers/` doesn't exist or is empty, print `No new papers to absorb.` and exit 0.
- The build catches broken MDX, not wrong content. Errors that should NOT fail the build (e.g. `lit-review-*.mdx` with `draft: false` is intentional and correct).
- **Never** force-push, never amend, never `--no-verify`.
- If `git push` fails non-fast-forward (cron and local daemon raced), run `git pull --rebase` and retry once. If still failing, abort with the conflict message.
