#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd -P)"
BREWFILE_PATH="${BREWFILE_PATH:-$REPO_ROOT/Brewfile}"
SELECT_FIRST=0
QUERY=""

usage() {
  cat <<'EOF'
Usage: add_mas_app.sh [--brewfile PATH] [--select-first] [SEARCH TERMS...]

Search the Mac App Store with `mas`, pick a result in a Gum TUI, and add the
selected app to the Brewfile's MAS section in sorted order. When a new entry is
added, the script also attempts to install the app immediately with `mas`.

Options:
  --brewfile PATH  Target Brewfile. Defaults to the repo Brewfile.
  --select-first   Skip the TUI and use the first search result.
  -h, --help       Show this help text.
EOF
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$1" >&2
    exit 1
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --brewfile)
      [[ $# -ge 2 ]] || {
        printf '%s\n' '--brewfile requires a path' >&2
        exit 1
      }
      BREWFILE_PATH="$2"
      shift 2
      ;;
    --select-first)
      SELECT_FIRST=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      QUERY+="${QUERY:+ }$1"
      shift
      ;;
  esac
done

require_command mas
require_command gum
require_command ruby

if [[ ! -f "$BREWFILE_PATH" ]]; then
  printf 'Brewfile not found at %s\n' "$BREWFILE_PATH" >&2
  exit 1
fi

if [[ -z "$QUERY" ]]; then
  QUERY="$(gum input \
    --header="Search the Mac App Store" \
    --placeholder="Type an app name" \
  )"
fi

if [[ -z "$QUERY" ]]; then
  printf 'No search query provided.\n' >&2
  exit 1
fi

if ! RESULTS="$(mas search "$QUERY" 2>&1)"; then
  printf 'mas search failed:\n%s\n' "$RESULTS" >&2
  exit 1
fi

RESULTS="$(printf '%s\n' "$RESULTS" | sed '/^[[:space:]]*$/d')"

if [[ -z "$RESULTS" ]]; then
  printf 'No Mac App Store results found for "%s".\n' "$QUERY" >&2
  exit 1
fi

if [[ "$SELECT_FIRST" -eq 1 ]]; then
  SELECTED="$(printf '%s\n' "$RESULTS" | head -n 1)"
else
  SELECTED="$(printf '%s\n' "$RESULTS" | gum filter \
    --limit=1 \
    --select-if-one \
    --strict \
    --header="Select a Mac App Store app to add to Brewfile" \
    --placeholder="Filter search results" \
    --value="$QUERY" \
  )"
fi

PARSED_OUTPUT="$(SELECTED="$SELECTED" ruby -e '
  line = ENV.fetch("SELECTED")
  match = line.match(/^\s*(\d+)\s+(.*?)\s+\([^)]+\)\s*$/)
  abort("Unable to parse mas output: #{line.inspect}") unless match
  puts match[1]
  puts match[2]
')"

APP_ID="${PARSED_OUTPUT%%$'\n'*}"
APP_NAME="${PARSED_OUTPUT#*$'\n'}"

UPDATE_RESULT="$(
  BREWFILE_PATH="$BREWFILE_PATH" APP_ID="$APP_ID" APP_NAME="$APP_NAME" \
    ruby "$SCRIPT_DIR/add_mas_app_brewfile.rb"
)"

STATUS="${UPDATE_RESULT%%$'\t'*}"
LINE="${UPDATE_RESULT#*$'\t'}"

case "$STATUS" in
  ADDED)
    printf 'Added %s to %s\n' "$LINE" "$BREWFILE_PATH"

    if mas account >/dev/null 2>&1; then
      printf 'Installing Mac App Store app "%s" (%s)...\n' "$APP_NAME" "$APP_ID"
      mas install "$APP_ID"
    else
      printf 'Added to Brewfile, but skipped install because the App Store is not signed in.\n' >&2
    fi
    ;;
  EXISTS)
    printf 'Already present in %s: %s\n' "$BREWFILE_PATH" "$LINE"
    ;;
  *)
    printf 'Unexpected update result: %s\n' "$UPDATE_RESULT" >&2
    exit 1
    ;;
esac
