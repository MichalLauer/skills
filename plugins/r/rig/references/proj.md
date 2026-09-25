# R projects (`rig proj`)

**Experimental** — commands, manifest format and lock format may still change. **P3M only** — ignores repositories
configured in the manifest and via `rig repos`.

A project is a directory with an `rproj.toml` manifest declaring R/package dependencies, resolved to a reproducible
`rproj.lock`. Full flags for any subcommand: `rig proj <subcommand> --help`.

## Workflow

```
rig proj init           # write rproj.toml (+ project boilerplate)
rig proj lock            # resolve deps, write rproj.lock
rig proj sync            # install into the project library (runs lock as needed)
rig proj add dplyr cli   # add deps to rproj.toml (runs lock + sync)
rig run                  # start R for the project (runs lock + sync as needed) — see run.md
```

`rig proj import`/`rig proj renv import` create a project from an existing `DESCRIPTION`/`renv.lock` instead of `init`.
Day to day you mostly need `add`/`remove` and `rig run`; lock/sync happen automatically.

## The `tools` library

Every project automatically gets a package library named `tools` on its library path. Put `devtools`, `usethis`,
`roxygen2` and other dev-only tools there (`rig pkg install -l tools <pkgs>`) so they never end up in `rproj.toml`.

## `rig proj add <package>...`

Adds to `rproj.toml`, updates `rproj.lock`, installs into the project library. Re-adding an already-listed package
updates its version requirement.

```
rig proj add dplyr
rig proj add dplyr@1.1.0
rig proj add 'cli@>= 3.6' 'rlang@>= 1.0, < 2.0'   # quote specs with space/> for the shell
```

No version → added as `"*"` (any); the concrete version picked is recorded in `rproj.lock`, so most deps don't need an
explicit requirement.

**Git/GitHub/GitLab/URL sources** — same pak reference syntax as `rig pkg install` (see [pkg.md](pkg.md) for the full
rules): `r-lib/crayon`, `r-lib/crayon@<ref-or-commit>`, `r-lib/crayon#41` (PR), `r-lib/crayon@*release`,
`gitlab::group/project@main`, `git::https://...`, a bare/`url::` https URL. Name comes from the fetched `DESCRIPTION`;
pinned to an exact commit or sha256, resolved immediately, not to a version range. Needs system `git` on `PATH`;
private-repo auth is whatever `git clone` would use (no rig-specific token).

**Version requirement syntax** (what you write in `rproj.toml`):

| Syntax                                          | Means                                       |
| ----------------------------------------------- | ------------------------------------------- |
| `1.2.3` or `^1.2.3`                             | compatible with 1.2.3 → `>= 1.2.3, < 2.0.0` |
| `~1.2.3`                                        | `>= 1.2.3, < 1.3.0`                         |
| `>= 1.2`, `> 1.2`, `<= 2.0`, `< 2.0`, `= 1.2.3` | single bound                                |
| `>= 1.0, < 2.0`                                 | comma = *and*                               |
| `*`                                             | any version                                 |

`^`/`~` bump the leftmost non-zero / second component and zero what follows (`^0.2.3` → `>= 0.2.3, < 0.3.0`; works with
any number of components: `^1.1.0.9000` → `>= 1.1.0.9000, < 2.0.0.0`). A bare version is written back into the manifest
in explicit `^` form.

Flags: `--dev` adds to `[dependency-groups.dev]` instead of `[dependencies]`. `--no-sync` updates the manifest+lock but
installs nothing. `--no-lock` only touches `rproj.toml` (works offline). If resolution fails, `rproj.toml` is rolled
back — a failed `add` never leaves an unlockable dependency.

## `rig proj remove` (alias `rm`) `<package>...`

Removes from wherever it's listed (`[dependencies]`, `[linking-dependencies]`, any `[dependency-groups.*]`), updates
lock + library. Naming a package that isn't a dependency is an error, and *nothing* is removed if any name doesn't
match — a typo can't silently remove the wrong set. Same `--no-sync`/`--no-lock` flags as `add`; rolls back on a failed
resolve.

## `rig proj deps`

Flat dependency table, read from `rproj.toml` only (no R, no network for the plain listing). `--dev` shows every
group/extra together (all-or-nothing view — unlike `sync`, which selects per-group). `--recursive`/`-r` expands the
whole closure (needs repo metadata): `Depth` = distance from the project, `Needed by` = what pulls it in. Follows the
*latest* version's deps for everything in the tree, so a requirement forcing an older version isn't reflected — use
`rig proj lock` for a properly consistent resolution.

## `rig proj tree`

Same idea as `rig pkg tree` but rooted at the project. `--why <pkg>` (alias `--explain`) inverts it. `--no-base` drops
R/base packages. `[D]`/`[L]`/`[DL]` markers as in `rig pkg tree`.

## `rig proj export` / `rig proj import`

Convert between `rproj.toml` and a `DESCRIPTION` file (two directions of the same mapping):

| `rproj.toml`                                            | `DESCRIPTION`                                                    |
| ------------------------------------------------------- | ---------------------------------------------------------------- |
| `[project].name/version/title/description/license/type` | `Package:`/`Version:`/`Title:`/`Description:`/`License:`/`Type:` |
| `[project].authors`                                     | `Authors@R` (or `Maintainer:` on import if `Authors@R` absent)   |
| `[project.urls].homepage`/`source`                      | `URL:`                                                           |
| `[project.urls].bugreports`                             | `BugReports:`                                                    |
| `[dependencies]`                                        | `Depends`/`Imports`                                              |
| `[linking-dependencies]`                                | `LinkingTo`                                                      |
| `[dependency-groups.dev]`                               | `Suggests`                                                       |
| `[dependency-groups.enhances]`                          | `Enhances`                                                       |
| `[dependency-groups.<name>]`                            | `Config/Needs/<name>`                                            |

Gotchas:

- **export**: `DESCRIPTION` supports only a single version bound per package; a two-sided `rproj.toml` range keeps just
  the lower bound, with a warning naming what was affected. Writes to the current directory unless `--output`; refuses
  to overwrite unless `--force`.
- **import**: `Authors@R` is parsed per `person()` call (name/`email`/`role`/`ORCID`-`ROR` comment) — best-effort, not
  a full R parser; unusual calls are skipped with a warning. A non-package-name `Config/Needs/<name>` entry (e.g.
  `tidyverse/tidytemplate`) is kept verbatim as `ref = "..."`, round-tripped unchanged by `export` — but only
  `dev`/`enhances` groups are actually solved/installed, so a `Config/Needs/*` group is carried but inert for now.
  Fails if `rproj.toml` exists; `--dependencies` merges deps only (old behavior) into an existing one instead. A full
  import creates the same files as `rig proj init`; `--r-version` sets the project's R (doesn't have to be installed —
  the manifest's actual R requirement always comes from `DESCRIPTION`).

## `rig proj init`

Writes a minimal `rproj.toml` ( `[project]` name from the current directory + version, `[dependencies]` with just an R
requirement) plus the same boilerplate as a full import: `.Renviron`, `.rvenvlib/rvenv`, and a `.gitignore` block for
`.rvenv` (merged into an existing `.gitignore`, never refused even without `--force`). `.rvenv` itself (incl. the
project library) is created later by `sync`, is machine-specific, and can be deleted/rebuilt any time. Note
`R --vanilla` ignores `.Renviron`, so it skips the project library. `--r-version` sets the project's R (needn't be
installed); `--force` overwrites the other files.

## `rig proj lock`

Resolves `rproj.toml` with rig's built-in solver → `rproj.lock`. Never runs R.

- **Optional deps**: every `[dependency-groups.*]` and `[optional-dependencies.*]` is solved *together* with hard deps
  in one solve, so a shared package gets one consistent version everywhere in `rproj.lock`, and every group/extra
  installs without a fresh solve. A group can `include-groups = [...]` others; a cycle is rejected. (`sync` is where a
  subset is actually *installed* — see below.)
- **R version**: without `-r`, solves for the default R version if the manifest's `R` requirement allows it, else the
  newest installed version that does, else the current release. Doesn't need to be installed — `lock` never runs R;
  `sync` installs whichever version the lock names.
- **Binary preference**: newest suitable version always wins; a binary of it is used if one exists.
  `--prefer-binary[=N]` (default 3) lets an *older* version with a binary win when the newest one doesn't have one yet.
- **Platforms**: default solves for this machine + macOS arm64 + Windows x86_64 + generic glibc Linux x86_64.
  `--platform` replaces that set (comma-separated, or a single distro like `ubuntu-24.04`, or `source`);
  `--add-platform` (repeatable) adds to it instead. Combined with `-r`/`--r-version` (also comma-separable) as a cross
  product — one lock target per combination. An unmatched distro/platform name falls back to a generic manylinux build
  for that arch; no binaries at all falls back to source.
- **Caching**: repo metadata + binary indices refresh once a day; `--no-cache` ignores that, `rig cache clean` clears
  it.
- **Sticky by default**: a `rig proj lock` that already satisfies `rproj.toml` reuses the existing `rproj.lock` as-is —
  including keeping an older-but-still-valid pin, and (for git/GitHub) reusing a previously-resolved commit rather than
  re-checking the remote. `--upgrade`/`-U` forces a full re-resolve: re-solves ordinary deps to the latest satisfying
  version, and re-checks every git/GitHub ref (moving branch/PR/`release=true` pins forward if they moved). An exact
  `rev`/`tag` pin has nothing to move. A `url::` dependency has nothing to move either — every lock re-downloads it
  (cached) and records its sha256; set `hash` on it to pin and verify the expected sha256.
- Records, per package, whether it's source or binary and its download URL, cached per *build* (a repo can publish
  several binaries of one version for one platform/R combo — they cache side by side).

**Workspaces**: an `rproj.toml` with a `[workspace]` table is a monorepo root; `members` (path patterns) lists the
member projects, `exclude` drops matches from `members`, the root is always a member of itself. `lock` from the root or
any member resolves *everyone* in one solve (one shared `rproj.lock` + library at the root); a member depending on a
sibling resolves against that sibling's own deps; members are directories, not packages, so they aren't recorded in the
lock. The R version solved for must satisfy every member's requirement, not just the root's. `[workspace.dependencies]`
lets a member inherit a shared version requirement by name (`cli = { workspace = true }`) instead of repeating it; an
entry no member inherits has no effect; `attach` stays per-member even when the requirement is inherited.

## `rig proj renv export` / `rig proj renv import`

- **export**: solves `rproj.toml` for **one** `(R version, platform)` target (unlike `lock`, `renv.lock` has no
  multi-target concept) and writes `renv.lock`. Same R-version/platform defaulting as `lock`.
- **import**: reads `renv.lock` → `rproj.toml`, one `^`-pinned dependency per locked package, `R` requirement from the
  lockfile. `renv.lock` carries no project metadata, so the manifest is named after the current directory. Run
  `rig proj lock` afterward to actually produce `rproj.lock`. Fails if `rproj.toml` exists; `--dependencies` merges
  deps into an existing manifest instead (an already-listed package's requirement is overwritten from `renv.lock`).
  `--input` picks a different source file; `--force` to overwrite the boilerplate files a full import creates.

Conversions between `rproj.toml`, `DESCRIPTION` and `renv.lock` are **not guaranteed lossless**, especially after
manual edits to `rproj.toml`.

## `rig proj status`

Read-only (never solves, downloads, or changes anything) — the thing to run after pulling changes, to see if `sync`
needs to run again. Three parts, each shown only if it applies: **Manifest** (name/version, workspace members, dep
counts by group), **Lock file** (version, one row per locked target: R version/platform/package count), **Environment**
(what `.rvenv` was last synced against, and whether it's still current).

## `rig proj sync`

Installs what `rproj.lock` resolved, and (re)writes the rest of `.rvenv`.

- No `rproj.lock` yet → runs `lock` with default options first, unless `--frozen`, which fails instead and touches
  nothing else — every package in `rproj.lock` already carries its own download URL, so `--frozen` needs nothing but
  the lock file (the CI-safe mode).
- **What's installed by default**: `[dependencies]` (`main`) + the `dev` group, nothing else. `--no-dev` drops `dev`
  too. `--group <name>` (repeatable/comma-separated) adds a specific named group; `--all-groups` adds every group.
  `--extra <name>`/`--all-extras` do the same for optional-dependency extras (none installed by default). Naming a
  group always wins over `--no-dev`: `--no-dev --group dev` still installs `dev`.
- **Removal**: by default sync also removes any library package that's in `rproj.lock` but not currently selected (e.g.
  dropped from the manifest, or its group left out) — never removes something just because *this run's* group/extra
  selection differs from last time. `--inexact` disables this cleanup.
- `--dry-run` prints the plan without touching anything. `--max-concurrent` caps parallel installs (default:
  `concurrent-installs` config / CPU core count).
- **Centralizing libraries**: default project library is `.rvenv/lib`. Set `RIG_PROJ_LIBRARY_ROOT` (or
  `proj-library-root` config) to centralize every project's library under one root instead
  (`rig system dirs --library-root` reports it); `.rvenv/lib` becomes a symlink into it. `--library` always wins
  outright for a one-off or shared location.
- **R version**: the lock records the exact R version its solve is valid for, and sync installs *that* version if
  missing (a same-minor patch is not good enough, on purpose) — `--no-install-r` fails instead (useful in CI). Never
  rewrites the lock to a different, already-installed R version; run `lock` to relock for a different one.
- **Multiple targets in one lock**: if `rproj.lock` has several, sync picks the one matching this machine's OS (inert
  entries for other OSes let one lock file serve a Linux deploy target from a macOS laptop); among several matches
  (e.g. several locked R versions) it defaults to the highest, or use `--r-version`/`--platform` to pick. Fails if
  nothing matches.
- **What's written under `.rvenv`** (all machine-specific, gitignored, rebuilt every sync): `bin/R`+`bin/Rscript`
  wrappers; shell activation scripts (`activate`, `.csh`/`.fish`/`.bat`/`.ps1`); `rvenv.cfg` (R version/platform/arch
  it was built for — rig warns if these mismatch on sync); `etc/repositories` (sets `R_REPOSITORIES` for the project).
  After sync, `.synced` (inside the project library) records which lock file was installed from, so every R session can
  warn if the library has drifted from `rproj.lock` since.
- **Workspaces**: one shared `rproj.lock`+library at the root — sync from any member syncs the whole workspace,
  installing the union of every member's deps.

## Full flags reference

Every subcommand above also takes the shared `--admin`/`--user`/`--no-cache`/`--json`/`-h` flags described in
[config.md](config.md); run `rig proj <subcommand> --help` for the exact list on your installed version.
