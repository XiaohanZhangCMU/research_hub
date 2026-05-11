---
name: literature-review-blog
description: Create, rewrite, and maintain integrated literature-review blog posts from papers in inbox/papers. Use when absorbing new academic papers, updating src/content/posts/lit-review-*.mdx, reorganizing review posts, adding mathematical or algorithmic detail, or turning paper-by-paper summaries into cohesive research-field surveys with references.
---

# Literature Review Blog

## Standard

Write an actual review article, not a list of paper summaries. Each update must re-evaluate the whole review's structure, merge the new paper's ideas into the field narrative, and leave readers with a current mental model of the topic.

The review should act as a knowledge base:
- Explain the field's problem setting, notation, objective functions, algorithm families, evaluation regimes, and open problems.
- Integrate every processed paper into the relevant conceptual sections.
- Keep paper provenance machine-readable so future agents can detect already-processed papers.
- Add every cited paper to `## References`, including the newly processed paper and important referenced works from that paper.

Read `references/review-style.md` when doing a substantive rewrite or when deciding how to restructure an existing review.

## Workflow

1. Discover unprocessed papers in `inbox/papers/` by hashing each `*.pdf` or `*.md` with `shasum -a 256` and comparing the first 12 hex chars against all `paper-hash:` markers in `src/content/posts/lit-review-*.mdx`.
2. Extract the paper's title, authors, date, abstract, core claims, methods, equations, algorithms, experiments, limitations, and bibliography. For PDFs, read the abstract/introduction, method sections, experiment tables, conclusion, and references.
3. Choose the target review by topic fit. Prefer merging into an existing `lit-review-*.mdx`; create a new review only when no existing review can naturally absorb the paper.
4. Rewrite the target review as a synthesized article. Do not simply append a `### Paper Title` section unless the review is still in a very early placeholder state.
5. Update `updated:` in frontmatter to today's date. Keep `generated: true` and `reviewed: false` unless the user says otherwise.
6. Run `ASTRO_TELEMETRY_DISABLED=1 PATH="/opt/homebrew/bin:$PATH" npm run build` before committing or pushing.

## Required Review Shape

Use the exact headings only when they fit; adapt names to the field, but preserve the roles:

- `## Overview`: what problem the field solves and why it matters.
- `## Conceptual Map`: the main branches of the literature and how they relate.
- `## Mathematical Setup`: notation, objective functions, constraints, estimators, or system models.
- `## Algorithms and Design Patterns`: reusable methods, training loops, inference procedures, systems tricks, pseudocode when useful.
- `## Empirical Picture`: benchmarks, metrics, datasets, evaluation protocols, and what results actually establish.
- `## Open Problems`: unresolved technical questions, failure modes, and promising directions.
- `## References`: bibliography for every processed and cited paper.

Short reviews may combine adjacent sections, but must still contain synthesis, math/algorithmic content, and references.

## Provenance Markers

References carry the processing state. Put the paper marker inside each reference entry for any paper that was processed from `inbox/papers`:

```mdx
- Qitao Tan et al. "ZeroQAT: Your Quantization-aware Training but Efficient." arXiv, 2025.
  {/* paper-file: 2509.00031v1.pdf paper-hash: a89ded00a360 */}
```

Use the same marker when replacing a paper whose filename already exists but whose hash changed. Do not hide processed papers only in prose; future agents must be able to grep `paper-hash:`.

For papers cited but not present in `inbox/papers`, add a normal reference entry without a marker.

## Writing Rules

- Prefer synthesis over chronology. Organize around concepts, algorithms, tradeoffs, and empirical claims.
- Name papers where attribution matters, but do not create one subsection per paper by default.
- Include equations in KaTeX for core mechanisms. Define symbols near first use.
- Include algorithm sketches when a method is procedural. Use compact pseudocode or numbered steps.
- Distinguish established results from claims of a single paper.
- Preserve the blog's existing voice: direct, technical, readable, and useful to someone entering the field.
- Keep the review self-contained enough that a reader can understand progress without opening every PDF.
- Avoid unsupported hype. State limitations, assumptions, and where evidence is thin.

## Updating Existing Paper-List Reviews

When an existing post is organized as `## Papers` with repeated `### <Paper>` summaries:

1. Treat those subsections as source notes, not as the target structure.
2. Extract the concepts, algorithms, results, and citations from each paper section.
3. Replace the paper-list body with integrated review sections.
4. Move all processed-paper markers into `## References`.
5. Keep enough specific attribution in the narrative that readers know which papers introduced which ideas.

Do not delete provenance markers. Do not lose citations while restructuring.
