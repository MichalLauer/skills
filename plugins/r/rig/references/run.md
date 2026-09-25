# Running R, scripts and apps

Full flags: `rig run --help` / `rig rstudio --help`.

## `rig run`

Run R, an R script, an expression, a project, or an app, with a chosen R version.

```
rig run                    # start R
rig run -f <script-file>   # run an R script
rig run -e <expression>    # evaluate an R expression
rig run <pkg>::<script>    # run a script from a package's exec directory
rig run <name>             # run a script the project declares
rig run --list             # list the scripts the project declares
rig run <path-to-app>      # run an R app
rig run --cmd <command>    # run `R CMD <command>`
rig run --activate         # start R with the selected version on PATH
rig run --shell            # start a shell with the selected version on PATH
rig run --rscript ...      # run `Rscript` instead of `R`
rig run -- --vanilla       # pass flags to R/Rscript
```

All of these take `-r/--r-version` to use a specific R version.

**Supported apps**: Plumber APIs, Shiny apps, Quarto/Rmd documents (plain or embedding Shiny), static web sites.

**R arguments**: anything after a literal `--` is passed straight to R/Rscript. Plain `rig run` defaults to
`--no-save --no-restore` (no "Save workspace image?" prompt); override with `rig run -- --save --restore`.

**Projects**: inside a [project](proj.md), `rig run` uses the project's own environment (`.rvenv/bin/R`) instead of the
default R version, running `rig proj lock`/`sync` as needed. `--no-project` ignores the project; `--r-version` picks a
version directly instead.

**Project scripts**: a project can name its own scripts, in `[[bin]]` tables of `rproj.toml`:

```
[[bin]]
name = "report"
path = "scripts/report.R"
description = "Build the report"
```

`rig run report --format pdf` then runs `scripts/report.R` in the project's environment, with `--format pdf` on to the
script (`commandArgs(TRUE)`). A declared name wins over a same-named directory — use `./name` for the directory.
Anything containing a slash or `::`, ending in `.R`/`.r`/`.Rmd`/`.qmd`, or equal to `.`/`..`, is never treated as a
script name. `--list` lists declared scripts (`--json` for machine-readable).

**Activation**: `--activate` puts the selected version's `bin` on `PATH` for the subprocess; `--shell` does the same
but opens a shell instead of R. Inside a project both put `.rvenv/bin` on `PATH` instead, so a nested `R` also picks up
the project's library and repos, not just its version.

**Rscript**: `--rscript` runs `Rscript` instead of `R` (no echoing of input — better for pipelines). Works with
`-e`/`-f`/scripts/apps/`--activate`; not with `--cmd` or `--shell`.

Key flags not covered above: `--app-type` to force app detection, `--dry-run` to print the command without running it,
`--echo`/`--no-echo` and `--startup`/`--no-startup` to control R's own output. Full list: `rig run --help`.

## `rig rstudio`

Start RStudio with a chosen R version: `rig rstudio [version] [project-file]`.

- A `.Rproj` file or a directory containing one → RStudio opens that project.
- A directory without one → RStudio starts with that as the working directory, no active project.
- A regular file → RStudio opens the file, working directory set to its parent.
- If the target contains an `renv.lock` and no version is given, rig reads the preferred R version from it (falls back
  to the latest release with the same major.minor if the exact one isn't installed; errors if none is).
- On arm64 macOS, rig prefers arm64 R unless only an x86_64 build matches exactly.
- Windows needs RStudio Desktop 2021.09.0+351 or later.

`--config-path` prints RStudio's config directory instead of starting it.
