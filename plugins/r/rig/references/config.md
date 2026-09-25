# rig configuration and global options

`rig config` manages rig's own JSON configuration file (`rig config config-file-path` prints its location). An
environment variable overrides the config file, which overrides rig's built-in default.

Full flags: `rig config <subcommand> --help`.

- **`rig config config-file-path`** — print the config file's path (may not exist yet).
- **`rig config get <key>`** — print one entry's value.
- **`rig config list`** — list the entry names currently set (only entries you've actually set appear, not every
  possible key).
- **`rig config set <key>=<value>`** — set an entry, creating the file if needed, e.g. `rig config set mode=user`.

## Configuration entries

The value each key holds, its env-var override, and what it's for — this is the part `--help` won't tell you:

- **`mode`** (`RIG_MODE`): `user` or `admin`. Default `admin`.
- **`binary-dir`** (`RIG_BINARY_DIR`): where the quick links (`R-4.5.1`, `R-release`, ...) go. Default `/usr/local/bin`
  (admin) / `~/.local/bin` (user); `C:\Program Files\R\bin` / `%USERPROFILE%\.local\bin` on Windows.
- **`r-install-dir`** (`RIG_R_INSTALL_DIR`): root of the R installations. Default is the platform system location in
  admin mode (`/opt/R`, `/Library/Frameworks/R.framework`, `C:\Program Files\R`), or `~/.local/share/rig/r`
  (`%APPDATA%\rig\data\r`) in user mode. On Windows only user mode is relocatable.
- **`rtools-install-dir`** (`RIG_RTOOLS_INSTALL_DIR`): Windows only. Default `C:\` (admin, so Rtools 4.5 →
  `C:\rtools45`) or `%APPDATA%\rig\data\rtools` (user).
- **`download-dir`** (`RIG_DOWNLOAD_DIR`): where installers download to before installing. Defaults to `rig-<uid>`
  under the system temp dir — the uid is in the name on purpose (admin mode downloads as root, user mode as you); rig
  refuses the default dir if it's a symlink, owned by someone else, or world-writable. A directory you set explicitly
  is created but not checked.
- **`no-cache`** (`RIG_NO_CACHE`): `true` = same as always passing `--no-cache` (nothing read or written to the cache;
  slower, meant for debugging, not a good permanent setting). Default `false`.
- **`concurrent-downloads`** (`RIG_CONCURRENT_DOWNLOADS`): max simultaneous downloads. Default `50`.
- **`concurrent-installs`** (`RIG_CONCURRENT_INSTALLS`): max packages `rig proj sync` installs at once, unless its own
  `--max-concurrent` overrides it. Default: number of CPU cores.
- **`positron-setup`**: user mode only. `false` stops rig from touching Positron's `positron.r.customRootFolders` /
  `positron.r.interpreters.default` settings; any other value (or unset) keeps it on.
- **`userlibrary`**: JSON object mapping R versions to user library paths — rig's own cache for `rig library`; not
  normally hand-edited.

## Global options shared by (almost) every command

- **`--admin`** / **`--user`** — force admin/user mode for this invocation (overrides `RIG_MODE` and config).
- **`--no-cache`** — skip rig's cache for this run (overrides `RIG_NO_CACHE` and config).
- **`--json`** — machine-readable output; not every command supports it (e.g. `rig add`, `rig rm` don't).
- **`-h`/`--help`** — full flag list for that command.
- **`-a`/`--arch <arch>`** — where architecture matters (`add`, `available`, `resolve`, `rtools`, `system dirs`).
- **`--platform <platform>`** — where platform matters (`add`, `available`, `resolve`, package/project commands).
