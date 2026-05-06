#!/usr/bin/env bash
# Watches inbox/papers/ for changes and runs `/update-reviews` non-interactively.
# Debounces bursts (5s) and uses flock single-flight to avoid overlapping Claude sessions.
# Requires: brew install fswatch
#
# Usage:
#   ./scripts/watch-inbox.sh
#   Ctrl-C to stop.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WATCH_DIR="$REPO_ROOT/inbox/papers"
LOCK_FILE="/tmp/research-hub-update-reviews.lock"

if ! command -v fswatch >/dev/null 2>&1; then
  echo "error: fswatch not installed. Run: brew install fswatch" >&2
  exit 1
fi

if ! command -v claude >/dev/null 2>&1; then
  echo "error: claude CLI not found in PATH." >&2
  exit 1
fi

if [[ ! -d "$WATCH_DIR" ]]; then
  echo "error: $WATCH_DIR does not exist." >&2
  exit 1
fi

echo "Watching $WATCH_DIR — Ctrl-C to stop."

run_update() {
  # flock with -n: skip if another run is already in progress.
  # The trailing `9>` opens fd 9 on the lock file for this subshell.
  (
    flock -n 9 || { echo "[watch] update already running; skipping this trigger."; exit 0; }
    cd "$REPO_ROOT"
    echo "[watch] $(date +%H:%M:%S) running /update-reviews"
    if claude -p "/update-reviews"; then
      echo "[watch] $(date +%H:%M:%S) done"
    else
      echo "[watch] $(date +%H:%M:%S) /update-reviews exited non-zero" >&2
    fi
  ) 9>"$LOCK_FILE"
}

# fswatch -o emits one line per batch of events.
# --latency 5 debounces bursts (file copies, editor saves) into a single trigger.
# --event flags filter out routine churn we don't care about.
fswatch -o --latency 5 \
  --event Created --event Updated --event Renamed --event Removed \
  "$WATCH_DIR" | while read -r _; do
  run_update
done
