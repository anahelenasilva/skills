---
name: notion-to-markdown
description: Use when the user wants to download, export, or save a Notion page as a local markdown file. Triggers on "download notion page", "export notion to markdown", "save notion page as md".
---

# Notion to Markdown

Export a Notion page to a local `.md` file.

## Steps

1. **Get the page** — ask the user for a Notion page URL or ID if not provided.
2. **Fetch content** — use `mcp__notion__notion-fetch` with the page URL/ID. The tool returns content in Notion-flavored Markdown.
3. **Clean up the markup** — strip Notion-specific extensions that don't render in standard markdown:
   - Remove `{color="..."}` attributes
   - Convert `<data-source>`, `<page>`, `<database>` tags to standard markdown links
   - Remove `<mention>` tags, keeping the display text
   - Convert `<toggle>` / `<details>` blocks if needed
   - Keep standard markdown (headings, lists, code blocks, tables) as-is
4. **Write the file** — save to the path the user specifies. If no path given, use the page title (slugified) with `.md` extension and save it on /Users/ana.dasilva/Downloads/notion-downloads.
5. **Report** — tell the user the file path and a one-line summary of what was exported.

## Notes

- If the page has subpages, ask the user whether to export them recursively or just the top-level page.
- For large pages, `notion-fetch` returns paginated content — fetch all sections.
- The Notion MCP resource `notion://docs/enhanced-markdown-spec` documents the exact Notion markdown extensions if you need to handle edge cases.
