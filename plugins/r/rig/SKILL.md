---
name: rig
description: Install and manage multiple R and Rtools versions side by side with the rig command-line tool, run R scripts and apps with a chosen R version, and manage package libraries, packages, repositories, PPM and reproducible R projects. Use when the user mentions rig, installing or switching R versions, Rtools, `rig add`, `rig list`, `rig run`, `rig pkg`, `rig proj`, `rig library`, `rig repos`, R package libraries, `rproj.toml`, or migrating a project from renv.
compatibility: Requires the `rig` CLI (a standalone binary for macOS, Windows and Linux). Some commands are platform-specific (Rtools on Windows, BLAS/debugging on macOS). Read-only commands work without R installed.
metadata:
  source: https://rig.r-lib.org/
  rig-version-documented: "0.10.0"
  last-verified: "2026-09-25"
---

# rig — the R Installation Manager

rig runs and manages multiple versions of R side by side on macOS, Windows and Linux. It is a standalone binary with 
no system requirements, used both by system admins and individual users.

This skill is an LLM-friendly, condensed version of the rig documentation: it keeps the *why* and the gotchas that 
`rig <command> --help` won't tell you, and points to `--help` for exact flag lists instead of reproducing them 
(see "Staying current" below). Read only the reference files a task needs.

## The 80% case — no file needed

```
rig add release              # install the latest R release
rig add 4.4.1                # install a specific version
rig list                     # what's installed
rig available                # what could be installed
rig default 4.5.1            # set/show the default version
rig rm 4.4.1                 # remove a version
rig run                      # start R (default version)
rig run -e '1+1'             # evaluate an expression
rig run -f script.R          # run a script
rig pkg install cli glue     # install packages into the default library
rig pkg list                 # what's installed in a library
```

For anything not on this list, or for exact flags/edge cases, open the matching reference file below — or just run 
`rig <command> --help`.

## Reference files

| Task                                                                                                                                      | Read                                                           |
|-------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------|
| Concepts: what rig is, admin vs user mode, symbolic version names, quick links                                                            | [references/overview.md](references/overview.md)               |
| Installing rig itself (per OS/package manager)                                                                                            | [references/install.md](references/install.md)                 |
| rig's own config file, config keys, env vars, global flags (`--user`, `--admin`, `--no-cache`, `--json`)                                  | [references/config.md](references/config.md)                   |
| R version management: `add`, `available`, `cache`, `default`, `list`, `repos`, `resolve`, `rm`                                            | [references/r-versions.md](references/r-versions.md)           |
| Rtools version management (Windows): `rig rtools add/list/rm`                                                                             | [references/rtools.md](references/rtools.md)                   |
| Running R code, scripts and apps, and starting RStudio: `rig run`, `rig rstudio`                                                          | [references/run.md](references/run.md)                         |
| Package libraries: `rig library add/default/list/rm`                                                                                      | [references/library.md](references/library.md)                 |
| Packages in a library: `rig pkg available/deps/info/install/list/remove/tree`                                                             | [references/pkg.md](references/pkg.md)                         |
| Posit Package Manager queries: `rig ppm build-log/builds/platforms/r-versions/status/url`                                                 | [references/ppm.md](references/ppm.md)                         |
| Reproducible R projects (`rproj.toml`/`rproj.lock`, renv/DESCRIPTION interop): `rig proj init/add/lock/sync/...`                          | [references/proj.md](references/proj.md)                       |
| Common `rig system`/`rig self` commands: `dirs`, `fix-aliases`, `user-mode`, `self update/uninstall`                                      | [references/system.md](references/system.md)                   |
| Rare, platform-locked `rig system` commands (macOS BLAS/debugger/core-dump, Windows registry, Linux certs) — mostly auto-run by `rig add` | [references/system-platform.md](references/system-platform.md) |
| End-to-end recipes crossing command families (new machine setup, renv migration, CI pinning, admin→user migration, package audits)        | [references/cookbook.md](references/cookbook.md)               |

## Orientation

The command families are independent; a cheap way to orient yourself in a session is `rig --help` or 
`rig <command> --help`.

- **R versions** — `rig add` installs, `rig list` shows installed, `rig available` shows installable, `rig default` switches, `rig rm` removes.
- **Rtools** (Windows) — `rig rtools add/list/rm`.
- **Running R** — `rig run` starts R, runs a script/expression/app, or a project, with a chosen version.
- **Libraries and packages** — `rig library` manages library directories; `rig pkg` manages packages inside them.
- **Projects** — `rig proj` manages an `rproj.toml` manifest resolved to `rproj.lock`.
- **Repositories and PPM** — `rig repos` configures CRAN/P3M per R version; `rig ppm` queries Posit Package Manager.
- **rig itself** — `rig self update` / `rig self uninstall`.

## Key concepts

### Admin mode vs user mode.

- Admin mode (default) installs R system-wide and usually needs `sudo`/administrator.
- User mode keeps everything in your home directory and never needs elevated privileges
- Resolved from `--user`/`--admin` flags, then `RIG_MODE`, then the config file, defaulting to admin.

See [references/overview.md](references/overview.md).

### Symbolic R version names.

- `release`, `devel`, `next`, `oldrel`/`oldrel/n` select versions without pinning a number; exact `x.y.z` and minor `x.y` are also accepted.

See [references/r-versions.md](references/r-versions.md).

### Quick links.

-  rig creates `R`, `Rscript` and `R-<ver>` links in the binary directory, so you can run a specific version directly without changing the default.

### Experimental commands.

- `rig pkg`, `rig ppm` and `rig proj` are marked experimental: commands, output and formats may still change.
- `rig pkg`/`rig proj` (and project solving) currently use P3M only and ignore configured repositories.

## Staying current: docs vs. `--help`

These reference files document rig (see `metadata` above) and condense https://rig.r-lib.org/ — they keep the *why*,
 workflow context, and gotchas (macOS patch-version conflicts, admin/user mode differences, git-ref syntax, sticky 
 lock files, etc.) that `--help` won't explain, and deliberately do **not** reproduce full flag/option tables — those 
 are exactly what `--help` already gives you, cheaply and always in sync with the binary actually installed.

- For the **exact, current flag list** of any command, run `rig <command> --help` (or `-h` for the short form). Trust it over anything that looks like a flag listing here.
- Before running a command that **installs, removes, or modifies state** (`add`, `rm`, `pkg install/remove`, `proj sync`, `system user-mode`, `rtools add`, …), check `--help` first if an exact flag matters.
- Read-only commands (`list`, `available`, `repos list`, `config get`, `system dirs`, `pkg info`, `proj status`, …) are safe to run directly; add `--json` if you need structured output.
- If `rig --version` reports something newer than 0.10.0, or a documented flag is rejected, don't guess — check `--help` and, for anything non-obvious, https://rig.r-lib.org/news.html.
