#!/bin/sh
# Called by gluetun's VPN_PORT_FORWARDING_UP_COMMAND with the forwarded port as $1.
# Bakes the port into Transmission's settings.json before Transmission starts
# (Transmission depends_on gluetun being healthy, so this runs first — no RPC/CSRF needed).
# NOTE: if the VPN reconnects with a new port while Transmission is already running,
# run `docker compose restart transmission` once to pick it up.
set -eu

PORT="$1"
CONFIG=/transmission-config/settings.json

if [ -f "$CONFIG" ]; then
  sed -i -E "s/\"peer-port\": [0-9]+/\"peer-port\": ${PORT}/" "$CONFIG"
  echo "Set peer-port to ${PORT} in ${CONFIG}"
else
  echo "settings.json not found yet (first boot), skipping" >&2
fi
