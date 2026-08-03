#!/bin/bash
# DopeWars Flutter - Local Development Runner
# Usage: ./run_local.sh [device]
# Examples:
#   ./run_local.sh          # Run on Chrome (default)
#   ./run_local.sh chrome   # Run on Chrome
#   ./run_local.sh macos    # Run on macOS desktop

DEVICE="${1:-chrome}"

echo "🎮 Starting DopeWars Flutter on $DEVICE..."
echo ""
echo "Available commands once running:"
echo "  R - Hot restart"
echo "  h - List all commands"
echo "  d - Detach (keep app running, exit Flutter)"
echo "  q - Quit"
echo ""

flutter run -d "$DEVICE"
