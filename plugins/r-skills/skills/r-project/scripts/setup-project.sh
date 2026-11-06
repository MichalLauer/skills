#!/usr/bin/env bash
# Sets up an R project: git, AGENTS.md, air (uv tool) + .air.toml, and a rig project.
# Works in bash on Linux, macOS (bash 3.2+) and Windows (Git Bash).
#
# Run from the PROJECT ROOT:  bash <skill-dir>/scripts/setup-project.sh [options]
#
# The steps are independent: a missing tool only skips its own step, the rest still run.
# The script never installs uv, rig or git. It only installs air (as a uv tool), and only
# when told to with --install-air=yes.
#
# Decisions are given as flags. Without a flag the script asks interactively when it runs
# in a terminal; otherwise (agents, CI, --no-prompt) it changes nothing, lists the decisions
# it needs and exits with code 10 so the caller can ask the user and re-run.
#
# Options:
#   --agents=stop|replace|merge   what to do if AGENTS.md already exists
#   --air=stop|replace            what to do if .air.toml already exists
#   --install-air=yes|no          install air as a global uv tool if it is missing
#   --r-version=VER               R version passed to rig proj (needed offline / without R)
#   --no-prompt                   never ask interactively
#
# Exit codes: 0 all steps done or already in place
#             10 decisions needed (nothing was changed)
#             20 a step was skipped because the user declined installing air
#             30 a step was skipped because a tool is missing (uv, rig 0.11+, git)
#             1  a step failed
#             (when several apply: 1, then 30, then 20)

set -u

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSETS="$SKILL_DIR/assets"

AGENTS_ACTION=""; AIR_ACTION=""; INSTALL_AIR=""; RVER=""
interactive=0
if [ -t 0 ] && [ -t 1 ]; then interactive=1; fi
[ "${SETUP_NO_PROMPT:-}" = "1" ] && interactive=0

for arg in "$@"; do
  case "$arg" in
    --agents=*)      AGENTS_ACTION="${arg#*=}" ;;
    --air=*)         AIR_ACTION="${arg#*=}" ;;
    --install-air=*) INSTALL_AIR="${arg#*=}" ;;
    --r-version=*)   RVER="${arg#*=}" ;;
    --no-prompt)     interactive=0 ;;
    -h|--help)       sed -n '2,29p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) echo "Unknown option: $arg"; exit 1 ;;
  esac
done

check_value() { # check_value NAME VALUE "a/b/c"
  [ -z "$2" ] && return 0
  case "/$3/" in *"/$2/"*) return 0 ;; esac
  echo "Invalid value '$2' for $1 (allowed: $3)"; exit 1
}
check_value --agents "$AGENTS_ACTION" "stop/replace/merge"
check_value --air "$AIR_ACTION" "stop/replace"
check_value --install-air "$INSTALL_AIR" "yes/no"

if [ "$PWD" = "$SKILL_DIR" ]; then
  echo "Run this from the project root, not from the skill directory."; exit 1
fi
for f in AGENTS.md .air.toml; do
  [ -f "$ASSETS/$f" ] || { echo "Missing template: $ASSETS/$f"; exit 1; }
done

# ---------------------------------------------------------------- state checks
have_git=0; have_uv=0; air_tool=0; have_rig=0
command -v git >/dev/null 2>&1 && have_git=1
command -v uv  >/dev/null 2>&1 && have_uv=1
command -v rig >/dev/null 2>&1 && have_rig=1
if [ "$have_uv" -eq 1 ] && uv tool list 2>/dev/null | tr -d '\r' | grep -q '^air-formatter '; then
  air_tool=1
fi

# ---------------------------------------------------------------- decisions
need=""
ask() { # ask VAR "question" "a/b/c" "flag hint"
  local var="$1" q="$2" opts="$3" hint="$4" ans=""
  if [ -n "${!var}" ]; then return 0; fi
  if [ "$interactive" -eq 1 ]; then
    while :; do
      printf '%s (%s): ' "$q" "$opts"
      read -r ans || { ans=""; break; }
      ans="$(printf '%s' "$ans" | tr 'A-Z' 'a-z' | tr -d '\r')"
      case "/$opts/" in *"/$ans/"*) [ -n "$ans" ] && break ;; esac
      echo "Please answer one of: $opts"
    done
    [ -n "$ans" ] && { printf -v "$var" '%s' "$ans"; return 0; }
  fi
  need="${need}  - ${q}"$'\n'"      options: ${opts}   flag: ${hint}"$'\n'
}

[ -e AGENTS.md ] && ask AGENTS_ACTION "AGENTS.md already exists. Stop, replace it with the template, or merge?" "stop/replace/merge" "--agents=<option>"
if [ "$have_uv" -eq 1 ]; then
  if [ "$air_tool" -eq 0 ]; then
    ask INSTALL_AIR "air is not installed as a uv tool. Install it now (uv tool install air-formatter)?" "yes/no" "--install-air=<option>"
  fi
  if [ "$INSTALL_AIR" != "no" ]; then
    [ -e .air.toml ] && ask AIR_ACTION ".air.toml already exists. Stop or replace it with the template?" "stop/replace" "--air=<option>"
  fi
fi

if [ -n "$need" ]; then
  echo "DECISIONS NEEDED (nothing has been changed yet)."
  echo "Ask the user each question, then re-run this script with the matching flags plus --no-prompt:"
  printf '%s' "$need"
  exit 10
fi

# ---------------------------------------------------------------- bookkeeping
st_git=""; st_agents=""; st_air=""; st_airtoml=""; st_rig=""
has_fail=0; has_missing=0; has_stop=0; merge_pending=0; missing_notes=""
add_missing() { has_missing=1; missing_notes="${missing_notes}  - $1"$'\n'; }

# ---------------------------------------------------------------- steps
step_git() {
  echo "== git"
  if [ "$have_git" -eq 0 ]; then
    st_git="SKIPPED - git is not installed"
    add_missing "git is not installed: https://git-scm.com/downloads"
    return
  fi
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    st_git="already inside a git repository (nothing done)"
  elif git init -q; then
    st_git="initialised a new repository"
  else
    st_git="FAILED - git init failed"; has_fail=1
  fi
  echo "$st_git"
}

step_agents() {
  echo "== AGENTS.md"
  if [ ! -e AGENTS.md ]; then
    cp "$ASSETS/AGENTS.md" ./AGENTS.md && st_agents="created from template"
  else
    case "$AGENTS_ACTION" in
      stop)    st_agents="left untouched (user chose stop)" ;;
      replace) cp -f "$ASSETS/AGENTS.md" ./AGENTS.md && st_agents="replaced with template" ;;
      merge)   merge_pending=1; st_agents="left untouched, MERGE PENDING (see below)" ;;
    esac
  fi
  echo "$st_agents"
}

step_air() {
  echo "== air and .air.toml"
  if [ "$have_uv" -eq 0 ]; then
    st_air="SKIPPED - uv is not installed"; st_airtoml="SKIPPED - needs air"
    add_missing "uv is not installed (needed for air): https://docs.astral.sh/uv/getting-started/installation/"
    echo "$st_air"; return
  fi
  if [ "$air_tool" -eq 1 ]; then
    st_air="already installed as a uv tool"
  elif [ "$INSTALL_AIR" = "yes" ]; then
    echo "Installing air: uv tool install air-formatter"
    if uv tool install air-formatter; then
      st_air="installed as a uv tool"
      command -v air >/dev/null 2>&1 || st_air="$st_air (if 'air' is not found, run 'uv tool update-shell' and restart the terminal)"
    else
      st_air="FAILED - uv tool install air-formatter failed"; st_airtoml="SKIPPED - needs air"
      has_fail=1; echo "$st_air"; return
    fi
  else
    st_air="SKIPPED - user declined installing air"; st_airtoml="SKIPPED - needs air"
    has_stop=1; echo "$st_air"; return
  fi
  echo "air: $st_air"
  if [ ! -e .air.toml ]; then
    cp "$ASSETS/.air.toml" ./.air.toml && st_airtoml="created from template"
  else
    case "$AIR_ACTION" in
      stop)    st_airtoml="left untouched (user chose stop)" ;;
      replace) cp -f "$ASSETS/.air.toml" ./.air.toml && st_airtoml="replaced with template" ;;
    esac
  fi
  echo ".air.toml: $st_airtoml"
}

step_rig() {
  echo "== rig project"
  if [ "$have_rig" -eq 0 ]; then
    st_rig="SKIPPED - rig is not installed"
    add_missing "rig is not installed: https://rig.r-lib.org/install.html"
    echo "$st_rig"; return
  fi
  if ! rig proj --help >/dev/null 2>&1; then
    st_rig="SKIPPED - this rig has no 'rig proj' command"
    add_missing "rig is too old, version 0.11.0 or newer is needed: https://rig.r-lib.org/install.html"
    echo "$st_rig"; return
  fi
  if [ -f rproj.toml ]; then
    st_rig="already initialised (rproj.toml exists), nothing done"; echo "$st_rig"; return
  fi
  local rc how
  if [ -f renv.lock ]; then
    how="renv import"; echo "renv.lock found: rig proj renv import"
    rig proj renv import ${RVER:+--r-version "$RVER"}; rc=$?
  else
    how="init"; echo "no renv.lock: rig proj init"
    rig proj init ${RVER:+--r-version "$RVER"}; rc=$?
  fi
  if [ "$rc" -ne 0 ]; then
    st_rig="FAILED - rig proj $how exited with $rc"; has_fail=1
    echo "If rig could not resolve an R version: install R with 'rig add release' (ask the user first)"
    echo "or re-run with --r-version=<version>, for example --r-version=4.4.1."
  else
    st_rig="done (rig proj $how)"
  fi
}

step_git
step_agents
step_air
step_rig

# ---------------------------------------------------------------- summary
echo
echo "SUMMARY"
echo "  git         : $st_git"
echo "  AGENTS.md   : $st_agents"
echo "  air         : $st_air"
echo "  .air.toml   : $st_airtoml"
echo "  rig project : $st_rig"

if [ -n "$missing_notes" ]; then
  echo
  echo "MISSING PREREQUISITES. Tell the user. Never install these yourself:"
  printf '%s' "$missing_notes"
fi
if [ "$merge_pending" -eq 1 ]; then
  echo
  echo "ACTION REQUIRED (agent): merge AGENTS.md."
  echo "  Existing file: $PWD/AGENTS.md"
  echo "  Template:      $ASSETS/AGENTS.md"
  echo "  Read both. Keep all of the user's existing content, add template sections that are"
  echo "  missing, do not duplicate topics already covered, and resolve conflicts in favour of the"
  echo "  user's file unless unsure (then ask). Show the user a summary of the changes."
fi

[ "$has_fail" -eq 1 ] && exit 1
[ "$has_missing" -eq 1 ] && exit 30
[ "$has_stop" -eq 1 ] && exit 20
exit 0