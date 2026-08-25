#!/bin/sh
# Called by gluetun's VPN_PORT_FORWARDING_UP_COMMAND with the forwarded port as $1.
# Pushes it to Transmission's RPC (peer-port), handling the CSRF session-id handshake.
set -eu

PORT="$1"
URL="http://127.0.0.1:9091/transmission/rpc"

SID=$(wget -q -S -O /dev/null --post-data='{}' "$URL" 2>&1 | grep -i 'X-Transmission-Session-Id' | awk '{print $2}' | tr -d '\r\n' || true)

wget -q -O- \
  --header="X-Transmission-Session-Id: ${SID}" \
  --header="Content-Type: application/json" \
  --post-data="{\"method\":\"session-set\",\"arguments\":{\"peer-port\":${PORT}}}" \
  "$URL" >/dev/null

echo "Set Transmission peer-port to ${PORT}"
