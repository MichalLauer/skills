---
name: r-project
description: Set up an R project with git, the standard AGENTS.md, .air.toml, air and a rig project. Use when starting or standardising an R project.
compatibility: "R (>= 4.1), rig (>= 0.11.0), uv, air-formatter, git"
---
# R project setup

1. From the project root (do not cd elsewhere), run: `bash <skill-dir>/scripts/setup-project.sh --no-prompt`
2. Exit code 10: nothing was changed. The script lists questions. Ask the user each one, then re-run with `--no-prompt` plus the flags it names.
3. Exit codes 0, 20, 30, 1: the steps are independent and all ran as far as they could. Report the SUMMARY block to the user.
4. Exit code 30: a tool is missing. Tell the user which one and give the link from the output.
5. Exit code 20: the user declined installing air, so air and .air.toml were skipped.
6. Exit code 1: a step failed. Report the error. Do not retry with other commands.
7. If the output contains "ACTION REQUIRED ... merge AGENTS.md", read both files and merge them as described.

# Rules

- Never answer for the user.
- Never install anything on your own, including uv, rig, git and R.