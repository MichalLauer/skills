# rig — overview and modes

For install instructions, see [install.md](install.md).

## What rig is

Run and manage multiple versions of R side by side on macOS, Windows and Linux. A standalone tool with no system
requirements, for both system admins and individual users. It installs as many R versions as you like, switches the
default for the terminal/RStudio/Positron, and can run several versions at once via quick links. It also configures
package repositories (CRAN mirror + Posit Public Package Manager) and can manage packages, projects and Rtools.

Documented here: rig **0.10.0** (see `metadata` in [SKILL.md](../SKILL.md)). Changelog:
https://rig.r-lib.org/news.html.

## Quick start

```
rig add release      # install the latest R release
rig list              # list installed R versions
rig default 4.5.1     # set the default R version
```

## Admin mode vs user mode

The single most important concept in rig. Resolved from, in order: the `--user`/`--admin` flag on the command line,
then `RIG_MODE`, then the `mode` config key, defaulting to **admin**.

```
rig add release --user           # just this command
export RIG_MODE=user             # this shell session
rig config set mode=user         # persistently
```

|                                            | User mode                                                             | Admin mode (default)                                                                 |
| ------------------------------------------ | --------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| Privileges needed                          | none, ever                                                            | `sudo`/administrator for most writes                                                 |
| R install root                             | your home directory                                                   | platform default (`/opt/R`, `/Library/Frameworks/R.framework`, `C:\Program Files\R`) |
| Shared between users                       | no                                                                    | yes                                                                                  |
| Maturity                                   | newer, less tested (esp. Linux)                                       | oldest, best-tested, current default                                                 |
| Multiple macOS patch versions of one minor | yes                                                                   | **no** — installing one removes the other                                            |
| Linux distro support                       | all glibc(≥2.34)/musl(≥1.2), via portable builds + manylinux packages | selected native distro builds                                                        |

Pick admin mode if you have an admin account and no strong reason not to — it's the best-trodden path. Pick user mode
if you don't have (or don't want to use) elevated privileges. `rig system dirs` prints the directories actually in
effect for the current mode.

**Switching an existing setup to user mode**: `rig system user-mode` (see [system.md](system.md)) does it in one step,
including migrating already-installed R versions and cleaning up the admin-mode install. **Mixing modes** (both
`/usr/local/bin/R` and `~/.local/bin/R` existing) is possible but not recommended — whichever comes first on `PATH`
wins, and it's easy to get this wrong.

**Custom directories**: quick-link directory via `RIG_BINARY_DIR`/`binary-dir` config (both modes); R install root via
`RIG_R_INSTALL_DIR`/`r-install-dir` config (user mode only — admin mode's location is fixed by the platform installer).
See [config.md](config.md).

## Key concepts used across commands

- **Symbolic R version names** (`release`, `devel`, `next`, `oldrel`/`oldrel/n`, exact `x.y.z`/`x.y`) — see
  [r-versions.md](r-versions.md).
- **Quick links** — rig creates `R`, `Rscript`, and per-version `R-<ver>` links in the binary directory, so any
  installed version can be run directly without changing the default.
- **Experimental command families** — `rig pkg`, `rig ppm`, `rig proj` may still change, and `rig pkg`/`rig proj`
  currently talk to P3M only, ignoring configured repositories.

## Beyond this reference

The live docs also include step-by-step tutorials, a Docker guide, the macOS menu bar app guide, and an FAQ (including
installing R without admin permissions) — outside the scope of this skill; see https://rig.r-lib.org/.
