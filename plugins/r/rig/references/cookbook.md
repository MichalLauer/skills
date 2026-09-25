# Cookbook: common end-to-end tasks

The command families (`add`, `pkg`, `proj`, `system`, ...) are documented separately because they're independent, but
real tasks usually chain a few of them together. This file collects the sequences for tasks that come up often. Each
recipe links to the reference file that documents the commands used, so read that file if you need the full flag list.

## Contents

- Set up R on a new machine (no admin rights)
- Set up R on a shared/admin machine
- Start a new reproducible project
- Migrate an existing renv project to `rig proj`
- Pin an exact R + package set for CI
- Move an existing setup from admin mode to user mode
- Diagnose a slow or failing package install
- Clean up disk space
- Windows: get a working compiler toolchain

## Set up R on a new machine (no admin rights)

```
rig system user-mode      # switch rig itself to user mode (see system.md)
rig add release           # install R into your home directory, no sudo
rig list                  # confirm it installed
```

Everything (R, libraries, quick links) lives under your home directory; `PATH` is patched automatically by the install
script, or by `rig system user-mode`. See [overview.md](overview.md) (Admin mode vs user mode) and
[system.md](system.md).

## Set up R on a shared/admin machine

```
sudo rig add release          # admin mode is the default; needs sudo/an admin account
sudo rig add 4.4.1            # keep an older version around too, for testing
rig default release           # make `R` resolve to the latest release
rig repos setup               # (re)configure CRAN/P3M for every installed version
```

Quick links (`R-4.4`, `R-4.4.1`, ...) let anyone on the machine run a specific version without touching the default.
See [r-versions.md](r-versions.md).

## Start a new reproducible project

```
mkdir myproject && cd myproject
rig proj init              # writes rproj.toml, .gitignore entry for .rvenv
rig proj add dplyr cli      # adds deps, resolves rproj.lock, installs into the project library
rig run                     # starts R configured for the project (runs lock/sync as needed)
```

Commit `rproj.toml` and `rproj.lock`; `.rvenv` is machine-generated and gitignored. See [proj.md](proj.md).

## Migrate an existing renv project to `rig proj`

```
cd existing-renv-project
rig proj renv import        # writes rproj.toml from renv.lock
rig proj lock                # resolve into rproj.lock (rig's own solver, not renv's)
rig proj sync                # install into the project library
rig proj status              # confirm everything is in sync
```

Conversion is not guaranteed to be 100% lossless, especially if `renv.lock` has manual edits or unusual sources; check
`rig proj deps`/`rig proj tree` against what you expect before deleting `renv.lock`. See [proj.md](proj.md) (renv
interop) and [r-versions.md](r-versions.md) (`rig add renv.lock` installs just the R version from a lock file, without
adopting the whole project).

## Pin an exact R + package set for CI

```
rig add $(cat .r-version 2>/dev/null || echo release) --without-pak   # or a pinned x.y.z
rig proj sync --frozen        # install exactly what rproj.lock says, never re-resolve
rig run --rscript -f tests/run.R
```

`--frozen` on `rig proj sync` fails instead of silently re-resolving if `rproj.toml` and `rproj.lock` have drifted
apart — the right behavior for CI. See [proj.md](proj.md) and [run.md](run.md).

## Move an existing setup from admin mode to user mode

```
rig system user-mode           # reinstalls current R versions in user mode, migrates default/aliases
                                # add --keep-install / --keep-links to leave the old admin install alone
rig list                       # confirm the user-mode versions are there and match
```

If you use Positron, clear its interpreter cache and restart it afterwards — it caches discovered interpreters and may
keep pointing at the removed admin-mode installs. See [overview.md](overview.md) and [system.md](system.md).

## Diagnose a slow or failing package install

```
rig repos list                 # what repositories are configured for the default R version
rig repos status               # ping each one, check freshness (--all to include disabled ones)
rig pkg info <pkg>              # does the repository even have this package/version?
rig pkg deps <pkg> --recursive  # is a heavy dependency tree the real cost?
```

All four are read-only. See [r-versions.md](r-versions.md) (`rig repos`) and [pkg.md](pkg.md).

## Clean up disk space

```
rig cache info                 # see what's using space, by category
rig cache clean --category built   # e.g. drop packages rig compiled from source, keep metadata
rig list                       # remove R versions you no longer need with `rig rm <version>`
```

See [r-versions.md](r-versions.md) (`rig cache`, `rig rm`).

## Windows: get a working compiler toolchain

```
rig add release        # installs R
rig add rtools          # installs every Rtools version the installed R versions need
rig rtools list         # confirm
```

`rig add rtools45` (or another specific version) installs just one. See [rtools.md](rtools.md).
