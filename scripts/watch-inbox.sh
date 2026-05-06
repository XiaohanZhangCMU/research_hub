#!/usr/bin/env bash
# Watches inbox/papers/ for changes and runs `/update-reviews` non-interactively.
# Debounces bursts (5s) and uses flock single-flight to avoid overlapping Claude sessions.
# Requires: brew install fswatch
#
# Usage:
#   ./scripts/watch-inbox.sh
#   Ctrl-C to stop.

set -euo pipefail

# Make the script self-contained regardless of which shell invokes it.
# Adds the typical install dirs for `claude` and `node`/`npm` so the
# `/update-reviews` build step also works.
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WATCH_DIR="$REPO_ROOT/inbox/papers"
LOCK_FILE="/tmp/research-hub-update-reviews.lock"
LOG_DIR="$REPO_ROOT/logs"
LOG_FILE="$LOG_DIR/watch-inbox.log"
mkdir -p "$LOG_DIR"

if ! command -v fswatch >/dev/null 2>&1; then
  echo "error: fswatch not installed. Run: brew install fswatch" >&2
  exit 1
fi

if ! command -v claude >/dev/null 2>&1; then
  echo "error: claude CLI not found in PATH (looked in: $PATH)" >&2
  echo "       install location detected previously: \$HOME/.local/bin/claude" >&2
  exit 1
fi

if [[ ! -d "$WATCH_DIR" ]]; then
  echo "error: $WATCH_DIR does not exist." >&2
  exit 1
fi

echo "Watching $WATCH_DIR — Ctrl-C to stop."
echo "Logging to $LOG_FILE (tail -f to follow)."

# Wrap stdout/stderr so EVERYTHING the script prints also lands in the log.
exec > >(tee -a "$LOG_FILE") 2>&1

# Force-disable Python's stdout buffering and similar — we want output live.
export PYTHONUNBUFFERED=1

run_update() {
  # flock with -n: skip if another run is already in progress.
  # The trailing `9>` opens fd 9 on the lock file for this subshell.
  (
    flock -n 9 || { echo "[watch] update already running; skipping this trigger."; exit 0; }
    cd "$REPO_ROOT"
    echo ""
    echo "[watch] ===== $(date '+%Y-%m-%d %H:%M:%S') trigger ====="
    if claude -p --verbose "/update-reviews"; then
      echo "[watch] $(date '+%H:%M:%S') run finished"
    else
      echo "[watch] $(date '+%H:%M:%S') /update-reviews exited non-zero" >&2
    fi
  ) 9>"$LOCK_FILE"
}

# Initial scan: absorb anything already sitting in the inbox.
# fswatch only fires on CHANGES, so without this step, files that existed
# before the daemon started would never get processed.
echo "[watch] $(date '+%H:%M:%S') initial scan"
run_update

# fswatch -o emits one line per batch of events.
# --latency 5 debounces bursts (file copies, editor saves) into a single trigger.
# --event flags filter out routine churn we don't care about.
fswatch -o --latency 5 \
  --event Created --event Updated --event Renamed --event Removed \
  "$WATCH_DIR" | while read -r _; do
  run_update
done
