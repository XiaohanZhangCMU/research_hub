# CLAUDE.md — Research Hub

This file is read automatically by Claude Code at session start. It contains everything needed to work on this repo without prior context.

---

## What This Is

A personal research/writing site for Xiaohan Zhang (张小寒), built with Astro 5 (static site). Live at **https://research-hub-six-gamma.vercel.app/**. Source at **https://github.com/XiaohanZhangCMU/research_hub**.

Stack: Astro 5 + Tailwind v4 + MDX + KaTeX + Vercel (auto-deploy on push to `main`).

---

## Critical: npm Registry

**Direct access to `registry.npmjs.org` is blocked on the Databricks network.**

Always use the Databricks npm proxy for installs:
- The local `.npmrc` (gitignored) is set to `registry=https://npm-proxy.dev.databricks.com/`
- **Never commit `.npmrc`** — it is in `.gitignore` intentionally
- Vercel builds use the public npm registry automatically (no `.npmrc` in the repo)
- If `.npmrc` is missing locally, recreate it: `echo 'registry=https://npm-proxy.dev.databricks.com/' > .npmrc`

Node is at `/opt/homebrew/bin/node` (not in default PATH). Always prefix commands:
```bash
PATH="/opt/homebrew/bin:$PATH" npm install
PATH="/opt/homebrew/bin:$PATH" npm run build
```

The Databricks proxy IS reachable from Claude Code's Bash tool sandbox, so Claude can run npm commands directly without the user needing to do it manually.

---

## Deploy Workflow

Every push to `main` auto-deploys to Vercel. The full cycle:

```bash
# make changes to files
PATH="/opt/homebrew/bin:$PATH" npm run build   # verify build passes locally
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
PATH="/opt/homebrew/bin:$PATH" npm run build
```

### Local dev server
```bash
PATH="/opt/homebrew/bin:$PATH" npm run dev
# opens at localhost:4321
```

### Install new packages
```bash
PATH="/opt/homebrew/bin:$PATH" npm install <package>
# uses Databricks proxy via local .npmrc
```

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

1. **`package-lock.json` is gitignored** — it was generated with Databricks proxy URLs which break Vercel builds. Vercel runs a fresh `npm install` against the public registry on each deploy.
2. **`.npmrc` is gitignored** — local file only, keeps the Databricks proxy setting. Never commit it.
3. **`npm run build` includes `astro build` only** — Pagefind is not yet wired into the build script (planned for later when search is needed).
4. **`git push` triggers two Databricks hooks** — a pre-commit secret scanner and a pre-push scanner. Both are fast and harmless.
5. **Vercel project type is Pages (static), not Workers** — if you ever need to recreate the Vercel project, choose "Pages → Connect to Git", NOT "Workers". Workers requires a deploy command and breaks.
