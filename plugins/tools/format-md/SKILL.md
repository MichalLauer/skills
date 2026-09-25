---
name: format-md
description: Formats a markdown file. Use this skill whenever the user asks to format a markdown (.md) file.
compatibility: mdformat CLI tool
metadata:
  last-verified: "2026-09-25"
---
# Rules

- Do not read the target Markdown file(s) before.
- Do not read the target Markdown file(s) after formatting, unless the user explicitly asks for a summary of the changes.

# Purpose

- Formats `.md` files using `mdformat` and its `mdformat-gfm` (tables) extension.
- Optionally extracts line-wrap limits from an `air.toml` or `.air.toml` config file if present in the project root.

```bash
# Invoke the script from the project root directory.
bash <skill_directory>/scripts/mdformat.sh <file1.md> [file2.md ...]
```