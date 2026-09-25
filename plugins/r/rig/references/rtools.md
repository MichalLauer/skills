# Rtools version management (Windows only)

Rtools is the build toolchain (compilers, `make`, etc.) Windows needs to build R packages from source; each R version
needs a matching Rtools version. On non-Windows platforms `rig rtools` does nothing and is hidden.

`rig add rtools` / `rig add rtools45` are equivalent shortcuts for `rig rtools add` (see
[r-versions.md](r-versions.md)).

Full flags for any of these: `rig rtools <subcommand> --help`.

- **`rig rtools add [version]`** (alias `install`) — install Rtools. Version is a name optionally prefixed `rtools`,
  e.g. `43` or `rtools43`; default `all` installs every version the currently-installed R versions need. In user mode
  this goes into `%APPDATA%\rig\data\rtools` with no admin rights needed (rig points each R version at it via
  `RTOOLS<ver>_HOME`); in admin mode it needs an administrator account.
- **`rig rtools list`** (alias `ls`) — list installed Rtools versions (only ones registered in the Windows Registry).
- **`rig rtools rm [version]...`** (aliases `del`, `remove`, `delete`) — remove Rtools versions by name (same
  `43`/`rtools43` syntax). No version given = no-op. Needs an administrator account in admin mode.
