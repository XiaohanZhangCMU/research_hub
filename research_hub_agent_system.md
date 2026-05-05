# Personal Research Hub + Agentic Blog Drafting System

## Project Goal

Build a high-visibility personal research hub for Xiaohan Zhang. The site should present Xiaohan as a research engineer working at the intersection of AI systems, scientific computing, stochastic differential equations, numerical methods, CUDA/performance engineering, LLM training/inference infrastructure, and simulation/RL/world models.

This is not just a chronological blog. It should be a durable research profile with evergreen topic pages, polished essays, paper notes, project pages, full-site search, and an agentic drafting pipeline that turns paper links / ideas into reviewable draft PRs.

The system should optimize for:

1. High-quality technical presentation.
2. Low-friction publishing.
3. Automation for first drafts, paper notes, metadata, tags, and references.
4. Human review before anything is published.
5. Long-term maintainability.

Do **not** build a heavy web app unless necessary. The default architecture should be a static content-first site.

---

## Recommended Stack

Use the following stack unless there is a strong reason not to:

- **Astro** for the static site.
- **MDX** for posts and technical essays.
- **Tailwind CSS** for styling.
- **KaTeX / remark-math / rehype-katex** for math rendering.
- **Pagefind** for static full-site search.
- **GitHub** for source control.
- **GitHub Actions** for CI, build checks, and agent workflows.
- **Vercel or Cloudflare Pages** for deployment.
- **Python scripts** for ingestion/drafting automation.
- **LLM-provider abstraction** so the drafting agent can use Anthropic, OpenAI, or another API depending on available env vars.

The site must be easy to run locally and easy to deploy.

---

## Core Product Concept

The website should have these primary sections:

```text
/
/about
/writing
/notes
/papers
/projects
/series
/search
/tags
/rss.xml
/sitemap.xml
```

### Homepage

The homepage should immediately communicate:

```text
Xiaohan Zhang
Research Engineering Notes on AI Systems, Stochastic Processes, and Scientific Computing
```

It should include:

- Short professional tagline.
- Featured essays.
- Featured project pages.
- Recent notes.
- Links to GitHub, LinkedIn, resume/CV, email.
- Topic clusters, e.g.:
  - LLM Systems
  - CUDA / Performance
  - Stochastic Differential Equations
  - Numerical Methods
  - Diffusion / Generative Models
  - Simulation / RL / World Models

### About Page

Should read like a serious research-engineering profile, not a generic personal page.

Include:

- Short bio.
- Research interests.
- Engineering interests.
- Selected projects.
- Publications / papers if available.
- Contact links.
- Resume link.

### Writing

Long-form polished essays. These should be high-signal pieces intended to be shared publicly.

Example categories:

- AI systems.
- LLM post-training / inference.
- SDEs for ML.
- Numerical methods.
- CUDA/PyTorch performance.
- Research engineering career notes.

### Notes

Shorter technical notes, derivations, implementation notes, or partial thoughts.

### Papers

Paper notes generated from arXiv links or paper URLs. These are semi-automated but still reviewed before publishing.

### Projects

Portfolio-like pages for demos, repos, experiments, visualizations, or technical systems.

### Series

Topic-based landing pages that group content into durable learning paths.

Example series:

- Stochastic Differential Equations for Machine Learning.
- Numerical Methods for Diffusion Models.
- LLM Inference Systems.
- CUDA Kernels for Deep Learning.
- World Models and Robotics Simulation.

---

## Important Principle: Agent Creates Drafts, Human Publishes

The agentic system should **never automatically publish final content**.

Correct workflow:

```text
idea / paper link / outline
  -> agent ingestion
  -> structured draft generation
  -> claim/equation/reference checks
  -> commit to generated branch
  -> open GitHub PR
  -> human edits
  -> merge
  -> publish
```

Do not implement direct-to-main auto-publishing.

Generated drafts should be clearly marked with frontmatter:

```yaml
status: draft
generated: true
reviewed: false
```

Only reviewed content should appear on the public production site unless explicitly configured otherwise.

---

## Repository Structure

Create a repo roughly like this:

```text
research-hub/
  astro.config.mjs
  package.json
  tsconfig.json
  tailwind.config.mjs
  README.md
  CLAUDE.md
  .env.example

  src/
    content/
      config.ts
      posts/
      notes/
      papers/
      projects/
      series/
    components/
      Layout.astro
      Header.astro
      Footer.astro
      PostCard.astro
      TagList.astro
      SeriesCard.astro
      MathBlock.astro
      CitationList.astro
    layouts/
      BaseLayout.astro
      PostLayout.astro
      PaperNoteLayout.astro
      ProjectLayout.astro
      SeriesLayout.astro
    pages/
      index.astro
      about.astro
      writing.astro
      notes.astro
      papers.astro
      projects.astro
      series.astro
      search.astro
      tags/[tag].astro
      rss.xml.js
    styles/
      global.css

  public/
    resume.pdf
    images/
    pagefind/

  scripts/
    agent/
      __init__.py
      config.py
      llm.py
      prompts.py
      schemas.py
      arxiv_ingest.py
      pdf_extract.py
      draft_paper_note.py
      draft_blog_post.py
      verify_draft.py
      create_pr.py
    new_paper_note.py
    new_blog_draft.py
    new_project_page.py
    process_inbox.py

  inbox/
    ideas.yaml
    papers.yaml

  .github/
    workflows/
      ci.yml
      pagefind.yml
      draft-paper-note.yml
      process-inbox.yml
```

---

## Content Collections

Use Astro content collections with strong frontmatter schemas.

### Post Schema

For long-form essays in `src/content/posts/`:

```ts
{
  title: string;
  description: string;
  date: Date;
  updated?: Date;
  tags: string[];
  series?: string;
  draft?: boolean;
  generated?: boolean;
  reviewed?: boolean;
  canonicalUrl?: string;
  heroImage?: string;
  references?: Array<{
    title: string;
    url: string;
    authors?: string[];
    year?: number;
  }>;
}
```

### Paper Note Schema

For `src/content/papers/`:

```ts
{
  title: string;
  paperTitle: string;
  authors: string[];
  date: Date;
  arxivId?: string;
  paperUrl: string;
  pdfUrl?: string;
  tags: string[];
  summary: string;
  whySaved?: string;
  status: 'inbox' | 'draft' | 'reviewed' | 'published';
  generated?: boolean;
  reviewed?: boolean;
  relatedPapers?: string[];
}
```

### Project Schema

For `src/content/projects/`:

```ts
{
  title: string;
  description: string;
  date: Date;
  tags: string[];
  repoUrl?: string;
  demoUrl?: string;
  status: 'idea' | 'active' | 'complete' | 'archived';
  featured?: boolean;
}
```

### Series Schema

For `src/content/series/`:

```ts
{
  title: string;
  description: string;
  slug: string;
  tags: string[];
  order?: number;
  featured?: boolean;
}
```

---

## MDX Writing Format

Use MDX for all technical content. It should support:

- Markdown.
- LaTeX block math.
- Inline math.
- Code blocks.
- Callouts.
- Figures.
- Tables.
- References.
- Optional embedded React/Astro components.

Example post:

```mdx
---
title: "Euler-Maruyama Is Not Just SGD"
description: "A practical derivation of Euler-Maruyama and its connection to stochastic optimization."
date: 2026-05-04
tags: ["sde", "numerical-methods", "machine-learning"]
series: "sde-for-ml"
draft: true
generated: false
reviewed: false
references:
  - title: "Numerical Solution of Stochastic Differential Equations"
    authors: ["Kloeden", "Platen"]
    year: 1992
    url: "https://example.com"
---

## Motivation

...

## Setup

$$
dX_t = a(X_t, t)dt + b(X_t, t)dW_t
$$

## Algorithm

```python
# minimal reproducible code
```

## Implementation Notes

...
```

---

## Agentic Workflow

### Input Sources

Support at least these input modes:

1. CLI command with arXiv URL.
2. CLI command with paper PDF URL.
3. YAML inbox file.
4. GitHub Actions manual dispatch.
5. Optional later: GitHub Issue form, Telegram bot, Slack bot, or iOS Shortcut.

For MVP, implement CLI and YAML inbox only.

### Example Commands

```bash
python scripts/new_paper_note.py https://arxiv.org/abs/2401.12345
python scripts/new_blog_draft.py --topic "KV cache compression as learned memory"
python scripts/process_inbox.py
```

### Paper Note Agent

Given an arXiv URL or paper URL, generate a draft MDX file.

Steps:

1. Parse input URL.
2. Fetch metadata:
   - title
   - authors
   - abstract
   - arXiv ID if available
   - PDF URL
   - categories
   - publication/update date
3. Download/extract paper text if possible.
4. Generate structured draft using LLM.
5. Generate tags.
6. Generate slug.
7. Write MDX file to `src/content/papers/`.
8. Run verification pass.
9. Optionally create branch and PR.

Output filename convention:

```text
src/content/papers/YYYY-MM-DD-short-slug.mdx
```

### Paper Note Template

Generated paper notes should follow this structure:

```mdx
---
title: "Paper Note: {paper_title}"
paperTitle: "{paper_title}"
authors: [...]
date: YYYY-MM-DD
arxivId: "..."
paperUrl: "..."
pdfUrl: "..."
tags: [...]
summary: "One-paragraph summary"
whySaved: "Why this paper is relevant to Xiaohan's research themes"
status: "draft"
generated: true
reviewed: false
---

## One-Sentence Thesis

...

## Why I Saved This

...

## Problem Setting

...

## Main Idea

...

## Algorithm

...

## Mathematical Formulation

...

## What Seems New

...

## What I Believe

...

## What I Am Skeptical About

...

## Connections

Connect this paper to:

- AI systems
- stochastic processes
- numerical methods
- diffusion models
- LLM training/inference
- CUDA/performance engineering

## Implementation Notes

...

## Follow-Up Questions

...

## References

- ...
```

### Blog Draft Agent

Given a topic, outline, or paper note, generate a long-form essay draft.

The output should be more polished than a paper note.

Template:

```mdx
---
title: "..."
description: "..."
date: YYYY-MM-DD
tags: [...]
series: "optional-series"
draft: true
generated: true
reviewed: false
---

## Motivation

## Intuition

## Formal Setup

## Derivation

## Algorithm

## Minimal Implementation

## Numerical Experiment

## Failure Modes

## Connection to Modern AI Systems

## Takeaways

## References
```

### Verification Agent

Implement `scripts/agent/verify_draft.py`.

It should check:

1. Frontmatter is valid.
2. Required fields exist.
3. Links are present and well-formed.
4. No obvious placeholder text remains.
5. No raw secrets or API keys appear.
6. Math delimiters are balanced.
7. Code blocks are closed.
8. Generated posts remain `draft: true` and `reviewed: false`.
9. References are present for factual claims when possible.
10. Optional: run Python code blocks marked as executable examples.

The verifier should produce a short report:

```text
PASS / FAIL
Warnings:
- ...
Errors:
- ...
```

---

## LLM Provider Abstraction

Create `scripts/agent/llm.py` with a provider-neutral interface.

Pseudo-interface:

```python
from dataclasses import dataclass
from typing import Protocol

@dataclass
class LLMResponse:
    text: str
    model: str
    input_tokens: int | None = None
    output_tokens: int | None = None

class LLMClient(Protocol):
    def complete(self, system: str, user: str, *, temperature: float = 0.2) -> LLMResponse:
        ...
```

Support providers based on env vars:

```text
ANTHROPIC_API_KEY
OPENAI_API_KEY
LLM_PROVIDER=anthropic|openai|mock
LLM_MODEL=...
```

Also implement a `mock` provider for local development that produces deterministic placeholder drafts without calling an API.

Never hard-code API keys.

---

## Prompt Design

Create prompts in `scripts/agent/prompts.py`.

The agent should write in Xiaohan's preferred voice:

- Clear and technical.
- Opinionated but not arrogant.
- Strong on implementation details.
- Mathematical where useful.
- Avoid generic AI-blog filler.
- Prefer concrete algorithms, equations, failure modes, and experiments.
- Do not overclaim.
- Explicitly separate facts from speculation.

### Paper Note System Prompt

```text
You are helping Xiaohan Zhang maintain a high-signal research engineering website.
Write a technically accurate paper note for a reader with strong CS/math/ML background.
Focus on the core idea, algorithm, mathematical formulation, implementation implications, and limitations.
Avoid hype. Avoid generic summaries. Explicitly mention what is uncertain or unverified.
Do not invent citations, equations, or results.
If a detail is not in the supplied text, mark it as TODO or unknown.
```

### Blog Draft System Prompt

```text
You are drafting a technical essay for Xiaohan Zhang's research hub.
The audience is advanced ML/systems/scientific-computing readers.
The essay should be clear, rigorous, implementation-aware, and original.
Prefer derivations, diagrams-as-text, pseudocode, minimal code examples, and failure analysis.
Do not publish-ready over-polish. Create a strong editable draft.
```

---

## GitHub Actions

### CI Workflow

`.github/workflows/ci.yml`

Should run on PRs and pushes:

```text
npm install
npm run build
npm run check
python scripts/agent/verify_draft.py --all
```

### Manual Paper Draft Workflow

`.github/workflows/draft-paper-note.yml`

Manual inputs:

```yaml
paper_url:
why_saved:
tags:
```

Steps:

1. Checkout repo.
2. Install Node and Python deps.
3. Run `python scripts/new_paper_note.py "$paper_url" --why-saved "$why_saved"`.
4. Create new branch.
5. Commit generated MDX.
6. Open PR with title `Draft paper note: ...`.
7. Add label `generated-draft`.

### Inbox Processor Workflow

Optional scheduled or manual workflow:

```text
python scripts/process_inbox.py
```

It should process items from `inbox/papers.yaml` and `inbox/ideas.yaml`, generate drafts, and open PRs.

---

## Inbox Format

### `inbox/papers.yaml`

```yaml
- url: "https://arxiv.org/abs/2401.12345"
  why_saved: "Relevant to SDE numerical methods and diffusion samplers."
  tags: ["sde", "diffusion", "numerical-methods"]
  status: "new"

- url: "https://arxiv.org/abs/2502.99999"
  why_saved: "Potentially useful for LLM inference systems."
  tags: ["llm-systems", "inference"]
  status: "new"
```

### `inbox/ideas.yaml`

```yaml
- title: "KV Cache Compression as a Learned Memory Hierarchy"
  seed: "Compare neural KV cache compaction with RAG, summarization, and recurrent memory."
  tags: ["llm-systems", "inference", "attention"]
  target: "post"
  status: "new"
```

After processing, update `status` to `drafted` or record generated path.

---

## Design Direction

The site should feel like a serious technical research blog, closer to:

- minimal academic personal site
- research lab notes
- high-quality engineering blog

Avoid:

- flashy marketing landing page
- heavy animations
- generic startup blog aesthetic
- cluttered card grids everywhere

Visual style:

- Clean typography.
- Excellent code block styling.
- Excellent math readability.
- Fast page load.
- Strong table of contents for long posts.
- Mobile readable.
- Light mode first, optional dark mode.

Homepage should have a strong identity but not feel overdesigned.

---

## SEO and Visibility Requirements

Implement:

1. Semantic titles and descriptions.
2. Open Graph metadata.
3. Twitter/X card metadata.
4. RSS feed.
5. Sitemap.
6. Canonical URLs.
7. Tag pages.
8. Series pages.
9. JSON-LD optional if easy.
10. Good heading hierarchy.

Each post page should include:

- Title.
- Date.
- Last updated date if available.
- Tags.
- Series link if applicable.
- Reading time.
- Table of contents.
- Previous/next in series if applicable.

---

## Initial Content to Seed

Create placeholder/draft content for these pages:

### About

Short profile:

```text
Xiaohan Zhang is a research engineer working on AI systems, scientific computing, and high-performance ML infrastructure. His interests include LLM training and inference systems, CUDA/PyTorch optimization, stochastic differential equations, numerical methods, simulation, reinforcement learning, and world models.
```

### Series Pages

Create at least these series stubs:

1. `sde-for-ml`
2. `llm-systems-notes`
3. `cuda-performance-notes`
4. `numerical-methods-for-generative-models`
5. `world-models-and-simulation`

### Starter Posts

Create draft stubs:

1. `A Practical Introduction to SDEs for Machine Learning`
2. `Euler-Maruyama, Milstein, and What ML Engineers Actually Need`
3. `KV Cache Compression as Learned Memory`
4. `Why Long Context Is a Memory Hierarchy Problem`
5. `CUDA Kernel Optimization Notes for PyTorch Users`

These should be drafts, not published.

---

## Package Scripts

`package.json` should include:

```json
{
  "scripts": {
    "dev": "astro dev",
    "build": "astro build && pagefind --site dist",
    "preview": "astro preview",
    "check": "astro check",
    "format": "prettier --write .",
    "lint": "prettier --check ."
  }
}
```

---

## Python Dependencies

Use a minimal dependency setup. Prefer `uv` if available, otherwise `pip`.

Possible dependencies:

```text
requests
pydantic
python-frontmatter
PyYAML
beautifulsoup4
pymupdf
arxiv
python-slugify
rich
```

Optional LLM SDKs:

```text
anthropic
openai
```

Create `requirements.txt` or `pyproject.toml`.

---

## Security Requirements

1. Never commit `.env`.
2. Provide `.env.example` only.
3. Never place API keys in generated content.
4. Verification script should scan for common secret patterns.
5. GitHub Actions should use repository secrets.
6. Do not auto-publish generated content.

Example `.env.example`:

```bash
LLM_PROVIDER=mock
LLM_MODEL=
ANTHROPIC_API_KEY=
OPENAI_API_KEY=
GITHUB_TOKEN=
SITE_URL=https://example.com
```

---

## Acceptance Criteria for MVP

The MVP is complete when:

1. `npm run dev` starts the site locally.
2. `npm run build` succeeds.
3. The homepage, about page, writing index, paper index, project index, series index, and search page exist.
4. MDX math renders correctly.
5. Code blocks render correctly.
6. Tags and series pages work.
7. RSS feed works.
8. Sitemap works.
9. Pagefind search works after build.
10. `python scripts/new_paper_note.py <arxiv-url>` creates a valid draft MDX paper note.
11. Generated notes have `draft: true`, `generated: true`, and `reviewed: false`.
12. `python scripts/agent/verify_draft.py --all` runs and reports useful errors/warnings.
13. A GitHub Actions CI workflow builds the site on PR.
14. A manual GitHub Action can generate a paper-note draft PR from an arXiv URL.
15. Documentation explains how to add posts, paper notes, and projects.

---

## Suggested Implementation Phases

### Phase 1: Static Site MVP

- Astro setup.
- Tailwind setup.
- MDX setup.
- KaTeX math.
- Basic layouts.
- Content collections.
- Index pages.
- RSS/sitemap.
- Pagefind.

### Phase 2: Content Model and Starter Content

- About page.
- Series pages.
- Draft post stubs.
- Project page stubs.
- Tag pages.
- Featured content on homepage.

### Phase 3: Local Drafting Scripts

- arXiv ingestion.
- MDX generation.
- LLM abstraction.
- Mock provider.
- Paper-note generator.
- Blog-draft generator.
- Verifier.

### Phase 4: GitHub Automation

- CI workflow.
- Manual draft-paper-note workflow.
- PR creation.
- Generated-draft labels.

### Phase 5: Capture and Inbox

- YAML inbox processor.
- Optional GitHub Issue form.
- Optional iOS Shortcut endpoint later.

### Phase 6: Advanced Features

- Interactive simulations.
- Plot generation.
- Runnable notebooks.
- Newsletter export.
- Social post generation.
- Citation graph / related papers.

---

## Claude Code Instructions

When implementing this project:

1. Start with Phase 1 and Phase 2 before building the full agent system.
2. Keep the codebase simple and readable.
3. Prefer file-based content over databases.
4. Do not introduce unnecessary server infrastructure.
5. Use TypeScript for Astro code.
6. Use Python for agent scripts.
7. Add comments where they clarify non-obvious decisions.
8. Include a clear README with setup and usage commands.
9. Do not hard-code secrets.
10. Keep generated content in draft mode by default.
11. Make every script idempotent where practical.
12. If a feature is ambiguous, implement the simplest useful version and leave TODO notes.

The final system should feel like a personal research lab notebook that can scale into a serious public technical profile.
