# Posit Package Manager queries (`rig ppm`)

**Experimental.** Reports on the public PPM instance at `https://packagemanager.posit.co` by default; set
`PACKAGEMANAGER_ADDRESS` to point at your own instance instead (`rig ppm builds` currently ignores this and always
reads the public build index; `rig ppm status` has its own `RIG_PPM_STATUS_URL` override that wins over
`PACKAGEMANAGER_ADDRESS`). `rig ppm url` prints whichever is in effect.

Full flags for any of these: `rig ppm <subcommand> --help`.

- **`rig ppm build-log <package>`** — build log for one CRAN package. `--platform`/`-p` (PPM target name: `macos`,
  `windows`, a Linux codename like `jammy`) + `--arch`/`-a` name the target; `--r-version`/`-r` defaults to your
  default R trimmed to minor (`4.6.1`→`4.6`, all PPM accepts). `--version`/`-v` picks a package version (default
  latest). No way to ask for a specific *historical* build — multiple builds of one version show the log of the last.
- **`rig ppm builds <package>`** — every source/binary artifact PPM has published for a package. Columns: `version`;
  `platform` (`source`, or a build target); `arch`/`r_version` (`*` on source rows); `linkingto` (compiled-against
  versions — the only thing distinguishing otherwise-identical rebuilds, since PPM republishes when a `LinkingTo`
  dependency changes); `url`. `--version` restricts to one version. `--json` adds a `sha256` per row (and per
  `linkingto` entry — hash of the *original* CRAN source tarball, not of what the URL serves).
- **`rig ppm platforms`** — build targets PPM currently serves: `name`, `os`, `platform` (match this against `builds`'
  `platform` column — several `name`s can share one, e.g. CentOS 7 and RHEL 7 both use `centos7`),
  `distribution`/`release` (what PPM *builds on*, not always what it serves — `rhel9` is built on Rocky Linux), `arch`,
  `binaries` (off = source-only). `--all` includes retired targets, flagged `hidden` (still downloadable, hence still
  listed).
- **`rig ppm r-versions`** — minor R versions PPM builds for, newest first.
- **`rig ppm status`** — full status report: R versions, build targets (incl. retired), Bioconductor releases + their
  CRAN snapshot pin, and macOS build flavor per R version/arch (`default` = what a newer R gets; empty = no macOS
  binaries for that combo). Always a live HTTP query, never cached. `--json` for the untrimmed status document.
- **`rig ppm url`** — print just the base URL in effect, for scripting: `curl "$(rig ppm url)/__api__/repos"`.
