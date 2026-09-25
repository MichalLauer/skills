# Package management (`rig pkg`)

**Experimental**, and **P3M only** — currently uses Posit Public Package Manager and ignores your configured
repositories, regardless of what `rig repos` says.

`rig pkg` installs, removes and lists packages in a library, and looks up info/deps/trees from the repositories, all
without starting R. Companions:

- [`rig library`](library.md) manages the library directories themselves, not what's in them.
- [`rig proj`](proj.md) manages a whole project's dependencies via a manifest+lockfile — use it instead of
  `rig pkg install` for reproducible, project-level deps. `rig pkg install` is for one-off packages in a library.

Full flags for any of these: `rig pkg <subcommand> --help`.

## Looking up packages (query the repositories, not a library)

```
rig pkg available                 # every package, latest version, dep count
rig pkg info cli                  # DESCRIPTION of the latest cli
rig pkg info cli --versions       # every version ever published
rig pkg info cli --readme         # the package's README, unrendered/unpaged
rig pkg deps dplyr                # direct deps, with CRAN's current version of each
rig pkg deps dplyr --recursive    # the whole dependency closure
rig pkg tree dplyr                # the same, as a tree
rig pkg tree dplyr --why glue     # inverted: what pulls glue in via dplyr
```

- By default: hard deps only (`Depends`/`Imports`/`LinkingTo`). `--dev` adds `Suggests`/`Enhances`.
- `--version`/`-v` targets one version (including CRAN-archived ones); can't combine with `--versions`.
- `rig pkg available` omits CRAN-archived packages unless `--include-archived`.
- **Tree markers**: `[D]` = Depends (attached, not just loaded), `[L]` = LinkingTo (compiled against), `[DL]` both,
  `Imports` unmarked. A package needed by several others is expanded once; later occurrences show as `(*)`.
  `--why <pkg>` (alias `--explain`) inverts the tree — root is the named package, leaves grow toward what needs it;
  searches the tree only, so a package not in it is an error.
- **Important caveat**: `deps`/`tree` always follow the *latest* version's dependencies for every package in the tree —
  a version requirement that would force an older version (with different deps) isn't reflected. For a resolution
  that's actually consistent across versions, use `rig proj lock` ([proj.md](proj.md)).
- `rig pkg info --readme` on a package with no README prints nothing (`--json`: `null` for both fields) — not an error.

## Installing packages

```
rig pkg install cli glue
```

rig resolves the whole dependency tree before installing anything — a package only goes in if everything it needs can
too, at mutually compatible versions. `--dry-run` runs the resolution and reports it without installing.

**Sources beyond the repositories** — pak's reference syntax, same as `rig proj add`:

```
rig pkg install r-lib/crayon                          # GitHub, bare owner/repo
rig pkg install r-lib/crayon@84be6207                  # @ref: branch, tag or commit
rig pkg install r-lib/crayon#41                         # PR
rig pkg install r-lib/crayon@*release                   # latest GitHub release
rig pkg install gitlab::group/project@main              # GitLab (nested subgroups OK)
rig pkg install 'git::https://gitlab.com/example/pkg.git@main'  # any git host
rig pkg install https://cran.rstudio.com/src/contrib/processx_3.9.0.tar.gz  # url::, or bare https
```

`<owner>/<repo>/<subdir>` points at a subdirectory package; GitLab uses `/-/<subdir>` and has no PR/`@*release`
support; a self-hosted GitLab is `gitlab::<https-url>`. The package name comes from the fetched `DESCRIPTION` (may
differ from the repo name); rig pins to an exact commit (or the archive's sha256 for `url::`), resolved immediately —
not to a version range. Git/GitHub/GitLab sources need the system `git` on `PATH` and authenticate exactly like a plain
`git clone` (credential helper, `.netrc`, SSH agent, or credentials in the URL) — no separate rig token setting.
`url::` is a plain HTTPS download, no auth.

**Other flags worth knowing**:

- `--dev` also installs `Suggests`/`Enhances`; a dev dependency the repositories don't have is an error unless
  `--ignore-unavailable`.
- `--reinstall` installs everything in the resolution even if already up to date — without it, an already-satisfied
  request is a no-op (repeat runs are safe).
- `--platform <p>` targets binaries for another platform (`macos`, `windows`, `ubuntu-24.04`, or a full triple);
  `--platform source` installs source only.
- `--prefer-binary[=N]` (default 3) trades a newer version for an older one that has a binary, when compiling is
  expensive.
- A binary package is unpacked directly (no R started); a source package runs `R CMD INSTALL` with a per-package log
  under `_logs` in the library — rig points you at it on failure.
- rig caches packages it compiles, keyed to platform + minor R version + source package + the exact versions of what it
  links against + your `~/.R/Makevars`; change any of those and it rebuilds. `--no-cache` turns this off for one run.
- rig also reinstalls a package if needed for ABI/`LinkingTo` compatibility with what's currently installed (it may
  over-reinstall if it can't determine this, typically for packages not installed by rig).

## Listing and removing (operate on an installed library, don't start R)

```
rig pkg list                 # packages in a library, with version/built-for/source
rig pkg remove cli glue      # remove from a library
```

`rig pkg remove` refuses to remove a base package (`base`, `stats`, `utils`, ...) unless `--force` — R doesn't work
without them. It does **not** check whether something else installed still needs the package being removed. To remove a
whole library instead, use `rig library rm`, not this.

## Choosing a library (`install`/`list`/`remove` all take these)

Default is the default library of the default R version. `--library`/`-l` takes a library **name** (as
`rig library list` shows) or a path — name is tried first, so prefix a same-named relative path with `./`.
`--r-version`/`-r` targets another R version's library.

```
rig pkg install --library myproject cli
rig pkg list --r-version 4.4.1
```

In admin mode, the site/system libraries belong to the administrator, so installing into or removing from them needs
`sudo` (admin account on Windows); your own user library never does.
