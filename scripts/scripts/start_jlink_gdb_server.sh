#!/usr/bin/env bash
set -euo pipefail

# Small helper to flash an .s37 image with JLinkExe then start the JLink GDB Server.
# Usage: ./start_jlink_gdb_server.sh /abs/path/to/image.s37 [device] [gdbport]
# Defaults: device=EFR32FG23, gdbport=2331

IMAGE_PATH=${1:-../build/final.hex}
DEVICE=${2:-EFR32FG23B010F512IM48}
GDBPORT=${3:-2331}

if [[ -z "$IMAGE_PATH" ]]; then
  echo "Usage: $0 /abs/path/to/image.s37 [device] [gdbport]"
  exit 2
fi

if [[ ! -f "$IMAGE_PATH" ]]; then
  echo "Image not found: $IMAGE_PATH"
  exit 2
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
JLINK_CMD="$ROOT_DIR/scripts/jlink_load.jlink"

# Prepare a temporary commander script with substituted path
TMP_JSCRIPT=$(mktemp)
sed "s|__S37_PATH__|$IMAGE_PATH|g" "$JLINK_CMD" > "$TMP_JSCRIPT"

echo "Flashing $IMAGE_PATH to device $DEVICE using JLinkExe..."
if ! command -v JLinkExe >/dev/null 2>&1; then
  echo "JLinkExe not found in PATH. Please install Segger J-Link tools and ensure JLinkExe is available." >&2
  rm -f "$TMP_JSCRIPT"
  exit 3
fi

JLinkExe -device "$DEVICE" -if SWD -speed 4000 -CommanderScript "$TMP_JSCRIPT"
rm -f "$TMP_JSCRIPT"

echo "Starting JLinkGDBServer on port $GDBPORT..."
if ! command -v JLinkGDBServer >/dev/null 2>&1; then
  echo "JLinkGDBServer not found in PATH. Install Segger J-Link and ensure JLinkGDBServer is available." >&2
  exit 4
fi

echo "Run: arm-none-eabi-gdb /path/to/your.elf and then 'target remote :$GDBPORT'"

exec JLinkGDBServer -device "$DEVICE" -if SWD -speed 4000 -port "$GDBPORT"
