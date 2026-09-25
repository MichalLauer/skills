# R version management

Full flags for any command below: `rig <command> --help`.

## Symbolic R version names

Accepted wherever a version string is expected:

- `devel` — latest development version.
- `next` — the next version (patched, alpha, beta, rc, etc.).
- `release` — latest release.
- `x.y.z` — exact version.
- `x.y` — latest release within a minor branch.
- `oldrel` / `oldrel/n` — latest release `n` minor branches back (`oldrel` = `oldrel/1`).
- `<url>` (`rig add` only) — a build from that URL.
- `renv.lock` or a path to one (`rig add` only) — the R version recorded in that lock file.

## `rig add` (alias `rig install`)

Download and install an R version. Keeps existing installs, **except** on macOS in admin mode, where installing a patch
overwrites any other patch of the same minor (in user mode there's no such limit — multiple patches coexist).

- Already installed → **no-op** (other than repointing an alias like `release`), unless `--reinstall`. `devel`/`next`
  are always reinstalled (rebuilt daily under the same name).
- macOS/Windows use CRAN builds; Linux uses Posit's R-builds. On Linux, admin mode picks a distro-specific build by
  default (portable via `--platform linux-portable`, or a specific one like `--platform linux-manylinux-2.34`; falls
  back to portable automatically if no distro build exists); user mode always installs a portable build for your libc
  (glibc/musl).
- Portable Linux builds bundle fontconfig but no fonts — rig writes a `fonts.conf` and downloads fallback fonts (see
  `rig system dirs --fonts`) unless `--without-fonts`; `FONTCONFIG_FILE` overrides everything;
  `RIG_FONTS_URL`/`RIG_FONTS_SHA256` point at a mirror.
- `rig add rtools` / `rig add rtools45` also installs Rtools (equivalent to `rig rtools add`, see
  [rtools.md](rtools.md)).
- User mode: never needs sudo. Admin mode: usually needs `sudo`/an admin account.

Repository setup at install time: `--with-repos`/`--without-repos` (comma-separated names; if `--with-repos` is given
alone, only those are enabled) control what `rig repos setup` would otherwise do by default.
`--without-cran-mirror`/`--without-p3m` (alias `--without-rspm`) are deprecated shortcuts for
`--without-repos=cran`/`p3m`. `--without-pak`, `--without-sysreqs` (Linux), `--without-translations` (Windows) skip
those extras. `--with-desktop-icon` (Windows) adds a desktop icon. `--pak-version stable|devel` picks the pak build.

```
rig add devel                    # latest dev snapshot
rig add release                  # latest release
rig add 4.6.1                    # specific version
rig add 4.6                      # latest release in a minor branch
rig add renv.lock                # the R version an renv.lock file needs
rig add -a arm64 release         # arm64 build (default on arm64 machines)
rig add rtools                   # all needed Rtools versions (Windows)
```

## `rig available`

List versions available to install. By default: nothing older than R 3.0.0, and only the latest release per minor
version (`--all` for everything). `--list-distros` lists supported Linux distros instead; `--list-rtools-versions`
lists Rtools versions (`--all` includes very old ones).

## `rig list` (alias `rig ls`)

List installed R versions. Does **not** check whether they still work. `--plain` prints just the version names, one per
line.

## `rig default` (alias `rig switch`)

No argument → print the current default (the one `R` starts, via the `R` quick link). With a version → set it, by
repointing the `current` symlink in the R install directory. You don't need to change the default just to run another
version — use the `R-<ver>` quick links, or `rig run -r <version>`. Admin mode needs `sudo` unless you're in the
`admin` group.

## `rig rm` (aliases `rig del`, `rig remove`, `rig delete`)

Remove one or more installed R versions; keeps user package libraries. No admin rights needed in user mode.

## `rig resolve`

Look up the version number and installer URL for a symbolic name (`release`, `devel`, `x.y`, ...) without installing
anything. Prints `<version> <url>`, or `NA` for the URL if no installer exists for this platform.

## `rig cache`

rig caches downloads (R build indexes, package DESCRIPTIONs/files, source builds) in an OS-specific dir
(`rig system dirs --cache`). The global `--no-cache` flag skips the cache for one run; it doesn't affect what `cache`
itself reports/deletes.

- **`rig cache info`** — size by category (`--json` for machine-readable).
- **`rig cache clean [--category <cat>]`** — delete cached files; no `--category` wipes everything. Categories:
  `built`, `packages`, `metadata`, `p3m`, `git-mirrors`, `url-pkgs`.

## `rig repos`

Manages the CRAN mirror / P3M repositories rig configures per R version (set at install time via `rig add`'s
`--with-repos`/`--without-repos`, or afterward here). For querying what packages a repository *offers*, see
[pkg.md](pkg.md).

- **`rig repos available [name]`** — repositories rig knows how to set up. No argument: one row per repo (name,
  default-set membership, title). With a name (case-insensitive, e.g. `P3M`): its URLs per platform/arch/R-version.
- **`rig repos list`** — repos configured for the default (or `-r`) R version. `--all` includes non-default ones;
  `--raw` skips resolving `%` variables in URLs.
- **`rig repos setup`** — (re)configure repos for installed R versions (`-r` to restrict to one), same
  `--with-repos`/`--without-repos` semantics as `rig add`.
- **`rig repos status`** — health-check the configured repos: `ping` (index fetch latency — a `HEAD`, not a full
  download), `status` (`ok` / `source only` / an HTTP code / `timeout` / `cannot connect`), `types` (what the R
  installation *declares* — `source`/`win`/`mac`, not a measurement of what's actually there; a trailing `*` on a Linux
  repo means it's serving prebuilt Linux binaries as "source" packages), `updated` (index freshness), `url`. Checked in
  parallel, so it takes about as long as the slowest one; an unreachable repo shows up in its row rather than failing
  the whole command. `--all` includes non-default repos, `--raw` skips URL variable resolution.
