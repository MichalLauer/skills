# System commands and managing rig itself

`rig system` configures installed R versions; `rig self` manages the `rig` binary itself. Full flags for any
subcommand: `rig system <subcommand> --help` / `rig self <subcommand> --help`.

Most `rig system` subcommands are things `rig add` already runs for you automatically (making links, fixing
permissions, etc.) — see [system-platform.md](system-platform.md) for that rarely-hand-run, platform-specific group
(macOS entitlements/BLAS, Windows registry, Linux certs). Below are the ones you're actually likely to run yourself.

## `rig system dirs`

Prints every directory rig uses: R (and on Windows, Rtools) install root, quick-link directory, Linux fontconfig dir,
download dir, rig's own config/data/cache/log dirs, and the centralized `rig proj` library root if configured. Values
reflect the current mode/config/env overrides; `--user`/`--admin` override the mode for one call. Directories may not
exist yet.

Print a single one as a bare path (for scripting), mutually exclusive with `--json` and each other: `--r`, `--rtools`
(Windows only), `--fonts` (Linux only), `--download`, `--library-root`, `--binary`, `--cache`, `--data`, `--log`. E.g.
`cd "$(rig system dirs --r)"`.

## `rig system fix-aliases`

Re-points the symbolic quick links (`R-release`, `R-oldrel`, `R-devel`, `R-next`, plus `-x86_64` variants on Arm) to
whatever `rig resolve` says each name means *today*. Matters mainly in admin mode, where `devel`/`next` install under a
version-numbered directory that can go stale when that branch moves to a new minor — user mode installs those under a
fixed name, so they're always current already. If the correct version isn't installed, rig drops the stale alias with a
warning rather than installing anything. No admin rights needed in user mode.

## `rig system add-pak [version]...`

Install/update pak for one or more R versions: `--all` for every installed version, specific versions as arguments, or
(with neither) just the default version. `--pak-version stable|devel`.

## `rig system detect-platform`

Prints the OS version/distribution rig detects and uses to choose R builds and repositories (`--json` for
machine-readable).

## `rig system setup-user-lib` (alias `create-lib`) `[version]...`

Configures R to auto-create per-user package libraries on startup, for installed (or given) versions. `rig add` already
runs this.

## `rig system make-links`

(Re)creates the `R-*` quick links (and `R`/`Rscript` if missing) for current R installations. `rig add` already runs
this — you only need it by hand after something outside rig changed the installations.

## `rig system user-mode`

Migrates an admin-mode setup to user mode in one step: sets `mode=user`, reinstalls admin-mode R versions in user mode
(restoring the previous default/aliases; skip with `--no-reinstall`), then removes the system-wide admin-mode installs
(`--keep-install` to skip) and quick links (`--keep-links` to skip). Steps 3–4 touch files outside your home directory,
so they need sudo/an admin account unless both `--keep-*` flags are given, in which case the whole command needs no
elevated privileges at all and nothing outside your home directory is touched.

Admin mode is still rig's default and the better-tested path — there's no need to switch a working setup, and on Linux
especially, user mode's portable builds/manylinux packages are newer and less tested. `rig config set mode=admin` +
reinstalling goes back.

If you use Positron: it caches discovered interpreters, so clear its interpreter cache and restart it afterward, or it
may keep pointing at the removed admin-mode installs.

## `rig self`

Manages the `rig` binary itself, separately from any R version. **Only works if rig was installed via the install
script** (`install.sh`/`install.ps1`) — a `.pkg`/`.deb`/`.rpm`/Homebrew/Chocolatey/Scoop/WinGet install refuses and
tells you which tool to use instead (`apt`, `brew upgrade`, etc.). See [overview.md](overview.md) for which install
method you used.

- **`rig self update`** — replace the running `rig` binary with the latest release (never touches installed R
  versions). `--dry-run` checks without installing; `--pre-release` also considers pre-releases.
- **`rig self uninstall`** — remove the `rig` binary, its shell completions, and the PATH entry the installer added.
  Does **not** remove config, cache, or any installed R — use `rig rm` and `rig cache clean` for that. Without
  `--force` it only previews what would be removed (same as `--dry-run`); pass `--force` to actually do it.
