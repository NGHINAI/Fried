#!/bin/bash
# Build + launch Fried in the iOS Simulator. Usage: ./run.sh
set -e
cd "$(dirname "$0")"
export PATH="/opt/homebrew/bin:$PATH"

DEVICE="iPhone 17 Pro"
UDID=$(xcrun simctl list devices "$DEVICE" available | grep -Eo '[0-9A-Fa-f-]{36}' | head -1)
if [ -z "$UDID" ]; then echo "No '$DEVICE' simulator found."; exit 1; fi

echo "▸ Generating + building…"
xcodegen generate >/dev/null
xcodebuild -project Fried.xcodeproj -scheme Fried \
  -destination "id=$UDID" -derivedDataPath build build >/dev/null

echo "▸ Booting Simulator…"
open -a Simulator
xcrun simctl boot "$UDID" 2>/dev/null || true
xcrun simctl bootstatus "$UDID" -b >/dev/null

APP="build/Build/Products/Debug-iphonesimulator/Fried.app"
xcrun simctl install "$UDID" "$APP"
xcrun simctl terminate "$UDID" com.fried.app 2>/dev/null || true
xcrun simctl launch "$UDID" com.fried.app >/dev/null
echo "✅ Fried is running in the Simulator. Tap 'Find out' to start."
