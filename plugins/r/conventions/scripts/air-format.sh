#!/usr/bin/env bash
# Checks the air formatter and its config, then formats the given files.
#
# Usage: bash assets/air-format.sh [--no-config] <file.R> [file.R ...]
#
# Run it from the project root: the config is only looked for there, never in
# parent or sub directories. Both .air.toml and air.toml are accepted.
#
# Exit codes:
#   0  formatted (or nothing to format)
#   1  air is not installed
#   2  air is installed but there is no .air.toml or air.toml: a decision is needed

set -u

no_config=0
files=()
for arg in "$@"; do
  if [ "$arg" = "--no-config" ]; then
    no_config=1
  else
    files+=("$arg")
  fi
done

# --- air -----------------------------------------------------------------
if command -v air >/dev/null 2>&1; then
  version=$(air --version 2>/dev/null | head -n 1 | sed -E 's/^[^0-9]*//')
  if [ -n "$version" ]; then
    echo "Air version: $version"
  else
    echo "Air version: NOT PRESENT"
  fi
else
  version=""
  echo "Air version: NOT PRESENT"
fi

if [ -z "$version" ]; then
  echo "Config file: NOT PRESENT"
  cat <<'EOF'

air is not installed, so nothing can be formatted. Stop here.
Tell the user and suggest installing it with one of:
  - https://github.com/posit-dev/air
  - uv tool install air-formatter
Never run those commands yourself.
EOF
  exit 1
fi

# --- config --------------------------------------------------------------
# air recognises both the dotted and undotted names at the project root.
config=""
for candidate in ./.air.toml ./air.toml; do
  if [ -f "$candidate" ]; then
    config="$candidate"
    break
  fi
done

if [ -n "$config" ]; then
  echo "Config file: $config"
  has_config=1
else
  echo "Config file: NOT PRESENT"
  has_config=0
fi

if [ "$has_config" -eq 0 ] && [ "$no_config" -eq 0 ]; then
  cat <<'EOF'

air is installed but the project root has no .air.toml or air.toml. Ask the user to pick one:
  1) Copy the default config (assets/.air.toml) into the project root, then format
  2) Only format, without a config
  3) Stop

Then act on the choice:
  1) copy assets/.air.toml to ./.air.toml and re-run this script on the files
  2) re-run this script on the files with --no-config
  3) do nothing
EOF
  exit 2
fi

# --- format --------------------------------------------------------------
if [ "${#files[@]}" -eq 0 ]; then
  echo "No files supplied; nothing to format."
  exit 0
fi

if [ "$has_config" -eq 0 ]; then
  echo "Formatting without a config."
fi

air format "${files[@]}"
