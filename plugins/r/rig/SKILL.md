---
name: rig
description: Use the rig CLI to manage R versions, Rtools, package libraries, packages, projects, and R execution on macOS, Linux, and Windows.
compatibility: Requires the `rig` CLI.
metadata:
  source: https://rig.r-lib.org/
---

# Introduction

- `rig` is a command-line tool (CLI) for managing R environments on macOS, Linux, and Windows.
- It installs and manages multiple R versions, selects defaults, and manages Rtools on Windows.
- It manages packages, libraries, and project dependencies, and runs R sessions, scripts, and applications.

# `rig` control

## Discover commands

- Start each rig task with `rig --version` and `rig --help`.
- Follow the command hierarchy using `--help` until you have read the help for the specific command you intend to execute.
    - For example: `rig --help`, `rig proj --help`, then `rig proj sync --help`.
- Read the full help, including descriptions, workflows, defaults, platform restrictions, and side effects.
- Reuse help already read during the task unless the rig executable or version changes.

## Use

- Prefer the installed rig's help over remembered syntax or behavior.
- Choose commands appropriate to the current OS, architecture, and shell.
- Before making changes, establish the target R version, library, project, and installation scope based to the task.
- Account for indirect changes described in help, such as automatic installation, synchronization, removal, or migration.
- Use simple commands with only the options needed for the task.
- Verify the result using relevant inspection commands or an appropriate execution check.
