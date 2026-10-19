#!/bin/sh
# Runs the staged native-approval build without replacing the installed CoS.
# Close the original app after all its live worker turns have finished.
set -eu
APP="/home/rishi/Work/working-projects/cos-core-tool-description-fix/release/linux-unpacked/chat-on-steroids"
if [ ! -x "$APP" ]; then
  echo "The staged Chat On Steroids executable is missing. Build it first." >&2
  exit 1
fi
if pgrep -f "^/home/rishi/.local/opt/Chat On Steroids/chat-on-steroids( |$)" >/dev/null; then
  echo "The installed Chat On Steroids is still running. Wait for workers to finish and quit that app before switching." >&2
  exit 2
fi
exec "$APP"
