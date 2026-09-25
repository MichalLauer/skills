#!/usr/bin/env bash
# Checks the mdformat formatter, the GFM extension, and its config, then formats.
# Usage: bash scripts/md-format.sh <file.md> [file.md ...]
# Exit codes: 0 (success), 1 (missing tool/extension or format error)

set -u

files=("$@")

# --- config --------------------------------------------------------------
config=""
for candidate in ./.air.toml ./air.toml; do
  if [ -f "$candidate" ]; then
    config="$candidate"
    break
  fi
done

# --- mdformat & extension check ------------------------------------------
if ! command -v mdformat >/dev/null 2>&1; then
  echo "Error: mdformat is not installed."
  echo "Please install it with the tables extension: uv tool install mdformat --with mdformat-gfm"
  exit 1
fi

if ! mdformat --help | grep -qi "gfm"; then
  echo "Error: mdformat is installed, but the GFM (tables) extension is missing."
  echo "Please reinstall: uv tool install --force mdformat --with mdformat-gfm"
  exit 1
fi

if [ -n "$config" ]; then
  echo "Config file: $config"
  has_config=1
else
  echo "Warning: Config file (.air.toml or air.toml) not found. Formatting without wrap limits."
  has_config=0
fi

# --- format --------------------------------------------------------------
if [ "${#files[@]}" -eq 0 ]; then
  echo "No files supplied; nothing to format."
  exit 0
fi

mdformat_cmd=(mdformat)

if [ "$has_config" -eq 1 ]; then
  WRAP_LIMIT=$(grep -Eo '^wrap\s*=\s*[0-9]+' "$config" | grep -Eo '[0-9]+' | head -n 1)
  if [ -n "$WRAP_LIMIT" ]; then
    echo "Formatting with wrap limit: $WRAP_LIMIT"
    mdformat_cmd+=(--wrap "$WRAP_LIMIT")
  fi
fi

mdformat_output=$("${mdformat_cmd[@]}" "${files[@]}" 2>&1)
mdformat_status=$?

if [ -n "$mdformat_output" ]; then
  printf '%s\n' "$mdformat_output"
fi

if [ "$mdformat_status" -ne 0 ]; then
  exit 1
fi

printf 'Formatted files:\n'
for file in "${files[@]}"; do
  printf ' - %s\n' "$file"
done