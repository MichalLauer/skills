# Library management

`rig library` (alias `rig lib`) manages package **libraries** (directories), not the packages inside them — see
[pkg.md](pkg.md) for that.

rig supports multiple user package libraries per R version; the usual one is called `main`. Every subcommand operates
on the default R version unless you pass `-r/--r-version`. Libraries are user-level: no admin/sudo needed to add, set
or remove one, and removing an R version keeps the libraries.

Full flags for any of these: `rig library <subcommand> --help`.

- **`rig library add <lib-name>`** — create a new, empty library for the current (or `-r`) R version. Does not change
  the default library.
- **`rig library default [lib-name]`** — print the current default library, or set it (new R sessions of that R version
  then use it).
- **`rig library list`** (alias `ls`) — list the libraries of the current R version; the default is marked.
- **`rig library rm <lib-name>`** — delete a library and everything installed in it. You cannot remove the current
  default or the `main` library — switch away with `rig library default` first.
