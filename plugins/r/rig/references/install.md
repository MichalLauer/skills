# Installing rig

Installing **rig itself** (this page) is independent of the mode rig installs **R** in (see
[overview.md](overview.md)): rig defaults to admin mode either way; switch explicitly with `rig system user-mode`.

Whether `rig self update`/`rig self uninstall` work later depends entirely on which method you used below — only the
install-script methods support them; every package-manager method says to use that package manager instead.

## macOS

1. **User install (CLI only), via install script** — downloads into `~/.local`, adds it to `PATH`:
   ```
   curl -LsSf https://r-lib.github.io/rig/install.sh | sh
   rig system user-mode   # optional: also keep R itself in your home dir
   rig add release
   ```
   Update with `rig self update`. (Manually unpacking `rig-macos-<arch>-<version>.tar.gz` from GitHub releases into
   `~/.local` instead skips `self update`/`uninstall`.)
1. **System install (adds the menu bar app)** — download the installer and run it normally. `self update`/`uninstall`
   don't work; download a newer installer instead.
1. **Homebrew** — `brew install r-rig-app` (menu bar + CLI, cask, needs a password) or `brew install r-rig` (CLI only;
   don't install both). x86_64 rig works on Arm Macs (and can install Arm R builds), not the reverse. Update via
   `brew upgrade r-rig-app`, not `self update`.

## Windows

1. **User install (no admin rights), via install script**:
   ```
   irm https://r-lib.github.io/rig/install.ps1 | iex
   ```
   Open a new terminal, then `rig system user-mode` (optional) and `rig add release`. Update with `rig self update`.
   (Manually extracting `rig-windows-<arch>-<version>.zip` into `%USERPROFILE%\.local` instead skips
   `self update`/`uninstall`.)
1. **System install** — download and run the installer; restart the terminal if needed. `self update`/`uninstall` don't
   work.
1. **Scoop** — `scoop bucket add r-bucket https://github.com/cderv/r-bucket.git && scoop install rig`; update with
   `scoop update rig`.
1. **Chocolatey** — `choco install rig`; update with `choco upgrade rig`.
1. **WinGet** (Windows 10+) — `winget install posit.rig`; update with `winget upgrade posit.rig`.

## Linux

Runs on any glibc (≥2.34) or musl (≥1.2) system in user mode via portable builds.

1. **User install, via install script** — `curl -LsSf https://r-lib.github.io/rig/install.sh | sh`, then
   `rig system user-mode` (optional) and `rig add release`. Update with `rig self update`.
1. **Ubuntu/Debian (DEB)** — add the rig repo/key and `apt install r-rig` (note: `rig` is a *different*, unrelated
   Debian/Ubuntu package). Update via `apt`.
1. **RHEL/Fedora/Rocky/AlmaLinux (RPM)** —
   `yum install -y https://github.com/r-lib/rig/releases/download/latest/r-rig-latest-1.$(arch).rpm`. Update via
   `yum`/`dnf`.
1. **OpenSUSE/SLES (RPM)** —
   `zypper install -y --allow-unsigned-rpm https://github.com/r-lib/rig/releases/download/latest/r-rig-latest-1.$(arch).rpm`.
   Update via `zypper`.
1. **Any distro (tarball)** —
   `curl -Ls https://github.com/r-lib/rig/releases/download/latest/rig-linux-$(arch)-latest.tar.gz | sudo tar xz -C /usr/local`.
   No `self update`/`uninstall` for a manually-unpacked tarball.

**Supported native-build distros**: Debian 12/13; Ubuntu 20.04/22.04/24.04/26.04; Fedora 43/44; OpenSUSE 15.6/16.0;
SLES 15 SP6; RHEL 7/8/9/10; AlmaLinux 8/9/10; Rocky Linux 8/9/10. Anything else, or "retired" older releases (CentOS
6–8, older Debian/Fedora/OpenSUSE/SLES/Ubuntu — still work, just not updated with new R builds), falls back to portable
builds. Builds come from Posit's R-builds project (https://github.com/rstudio/r-builds).

## Shell auto-completion

All installers/archives ship completions.

- **macOS/Linux**: system installs put `zsh`/`bash` completions in system locations (`zsh` works immediately; `bash`
  needs the `bash-completion` package loaded from `.bashrc`). User-mode installs put them under the install prefix —
  add `~/.local/share/zsh/site-functions` to `fpath` before `compinit` (zsh), or rely on `bash-completion` picking up
  `~/.local/share/bash-completion/completions` (bash).
- **Windows**: dot-source the shipped PowerShell script from `$PROFILE`, e.g.
  `. "$env:USERPROFILE\.local\share\rig\_rig.ps1"` for a user-mode archive install.
