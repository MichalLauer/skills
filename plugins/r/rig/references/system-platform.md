# Platform-specific `rig system` commands

These are all narrow, platform-locked commands. Most are things **`rig add` already runs automatically** during a
normal install — you'd only reach for one by hand to redo it after something outside rig changed the R installation, or
to opt into a non-default behavior (BLAS, core dumps, debugger entitlements). All take the standard
`--admin`/`--user`/`--no-cache`/`-h` flags; full list: `rig system <subcommand> --help`.

## macOS only

- **`allow-core-dumps [version]...`** — entitlements + writable `/cores`, so R can dump core on crash. Also run
  `ulimit -c unlimited` in the same shell first. `--all` for every version.
- **`allow-debugger [version]...`** — adds the `get-task-allow` entitlement so `lldb`/`gdb` can attach (`R -d lldb`).
  Needed for R 3.6+ installers only (earlier ones aren't signed). See also `allow-debugger-rstudio` for R running
  inside RStudio.
- **`allow-debugger-rstudio`** — same, for RStudio's `rsession` (and `rsession-arm64` on Arm) binary.
- **`blas set <reference|accelerate> [version]...`** — switch R's BLAS/LAPACK between the shipped `reference`
  implementation and Apple's faster `accelerate` (vecLib); skips (with a warning) any version that doesn't ship the
  requested library. **`blas status [version]...`** — report which one each version is using
  (`reference`/`accelerate`/`unknown`).
- **`fix-permissions [version]...`** — restrict the system library to admin-write, so packages land in a user library
  instead. Pairs with `setup-user-lib` (see [system.md](system.md)).
- **`forget`** — tell macOS to forget the current R installs; needed to run multiple versions side by side. `rig add`
  runs this before/after installing.
- **`make-orthogonal [version]...`** — make installed versions runnable simultaneously (a no-op on Windows/Linux, where
  this is automatic, and in user mode, which is always orthogonal).
- **`no-openmp [version]...`** — strip `-fopenmp` so R builds with Apple's compilers instead of CRAN's; only relevant
  for R ≤ 3.6.x.

All of the above need `sudo`/an admin account in admin mode, do nothing in user mode (except `blas`, which works in
both), and do nothing on Windows/Linux.

## Windows only

- **`clean-registry`** — remove registry entries for R/Rtools versions that are no longer installed.
- **`fix-r-alias [--undo]`** — PowerShell ships a built-in `r` alias for `Invoke-History` that shadows the `R` command;
  this patches your PowerShell profile(s) (`pwsh` and `powershell`, idempotently) so `R` starts R instead. `--undo`
  removes the patch. Restart PowerShell for either to take effect.
- **`update-rtools40`** — update Rtools40's MSYS2 packages to the latest builds.

## Linux only

- **`update-certs`** — download a current CA bundle and point R at it, for systems with a missing/stale certificate
  store.
