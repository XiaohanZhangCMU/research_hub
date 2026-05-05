# Drafts Inbox

Drop draft posts here as `.md` files. Tell Claude the file is ready and it will:

1. Read the draft
2. Infer and format any math expressions as KaTeX (`$...$` inline, `$$...$$` display)
3. Convert to MDX with proper frontmatter (title, description, date, tags, slug)
4. Build and push to main → auto-deploys to Vercel

## Tips

- Write math in plain text or LaTeX — both work. Examples Claude will catch:
  - `dX_t = mu dt + sigma dW` → `$dX_t = \mu \, dt + \sigma \, dW_t$`
  - `sum_{i=1}^n x_i` → `$\sum_{i=1}^n x_i$`
  - Display block: start a line with `$$` or just write the equation on its own line
- Add a line at the top with any hints: slug, tags, draft status
- File name becomes the default slug (e.g., `kv-cache-compression.md` → `/writing/kv-cache-compression`)
