#!/bin/bash

set -euo pipefail

if [[ "${DEBUG:-0}" == "1" ]]; then set -x; fi
log() { echo "$(date -Iseconds) [startup] $*"; }

RESOLUTION="${RESOLUTION:-1920x1080}"
DEPTH="${DEPTH:-24}"

dump_debug() {
  log "Dumping diagnostics..."
  log "User: $(id)"
  log "/dev/dri contents:"; ls -l /dev/dri || true
  log "GPU render node perms:"; stat -c '%A %U:%G %n' /dev/dri/* 2>/dev/null || true
  log "X server log (last 100 lines):"; tail -n 100 /tmp/xorg.log 2>/dev/null || true
  if [[ -n "${DISPLAY:-}" ]]; then
    log "glxinfo -B:"; glxinfo -B 2>/dev/null || true
    log "xrandr outputs:"; xrandr 2>/dev/null || true
  fi
  log "Listening ports:"; netstat -tuln 2>/dev/null || true
  log "Process tree:"; ps -eo pid,ppid,cmd --forest || true
}

cleanup() { log "Cleaning up..."; pkill -TERM -P $$ || true; if [[ -n "${X_PID:-}" ]] && kill -0 "$X_PID" 2>/dev/null; then log "Stopping X server $X_PID"; kill -TERM "$X_PID" || true; fi; exit 0; }
err_trap() { local ec=$?; log "Error: ${BASH_COMMAND} (exit $ec)"; dump_debug || true; exit $ec; }
trap cleanup SIGINT SIGTERM
trap err_trap ERR

rm -f /run/dbus/pid
mkdir -p /run/dbus
dbus-daemon --system --nofork &
sleep 2
avahi-daemon --no-drop-root --daemonize

start_xorg() { log "Starting Xorg on :0"; Xorg :0 -nolisten tcp > /tmp/xorg.log 2>&1 & X_PID=$!; }
start_xvfb() { log "Starting Xvfb fallback on :0 (${RESOLUTION}x${DEPTH})"; Xvfb :0 -screen 0 ${RESOLUTION}x${DEPTH} -nolisten tcp > /tmp/xorg.log 2>&1 & X_PID=$!; }
wait_for_x() { local t=0; until DISPLAY=:0 xset q >/dev/null 2>&1; do t=$((t+1)); [[ $t -ge 15 ]] && return 1; log "Waiting for X... ($t)"; sleep 1; done; }

USE_XVFB=0
start_xorg; sleep 2
if ! wait_for_x; then
  log "Xorg did not become ready; falling back to Xvfb"; kill -TERM "$X_PID" 2>/dev/null || true; sleep 1
  start_xvfb; USE_XVFB=1
  if ! wait_for_x; then log "Fatal: Xvfb also failed to start"; tail -n 100 /tmp/xorg.log || true; exit 1; fi
fi

tail -n 50 /tmp/xorg.log || true
export DISPLAY=:0

if [[ "$USE_XVFB" -eq 0 ]]; then
  xrandr_output=$(xrandr | awk '/ connected/{print $1; exit}')
  if [[ -n "${xrandr_output:-}" ]]; then
    log "Setting ${RESOLUTION} on $xrandr_output"; xrandr --output "$xrandr_output" --mode "$RESOLUTION" || true
  else
    log "No connected display found for xrandr; skipping."
  fi
fi

openbox &

if [[ -n "${VNC_PASSWORD:-}" ]]; then
  mkdir -p ~/.vnc; x11vnc -storepasswd "$VNC_PASSWORD" ~/.vnc/passwd >/dev/null 2>&1; VNC_AUTH=( -rfbauth ~/.vnc/passwd )
else
  VNC_AUTH=( -nopw )
fi

x11vnc -display :0 "${VNC_AUTH[@]}" -forever -shared -rfbport 5900 &
sleep 2
websockify --web=/usr/share/novnc/ 6081 localhost:5900 &
log "noVNC available at http://<host>:6081/vnc.html"

if [[ "$USE_XVFB" -eq 1 ]]; then
  xmessage -center -timeout 20 "OBS is running with Xvfb fallback (no GPU acceleration). Performance may be degraded." &
  log "WARNING: Running under Xvfb fallback (no GPU)."
fi

log "Starting OBS..."
obs &
OBS_PID=$!
sleep 2
kill -0 "$OBS_PID" 2>/dev/null || { log "OBS failed to start"; dump_debug || true; exit 1; }
log "OBS started with PID $OBS_PID"
wait "$OBS_PID"

