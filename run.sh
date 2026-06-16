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
# macOS stamps com.apple.provenance xattrs on asset files; codesign refuses to
# sign a bundle containing them. Strip sources, then sign manually post-build.
xattr -cr Sources >/dev/null 2>&1 || true
xcodebuild -project Fried.xcodeproj -scheme Fried \
  -destination "id=$UDID" -derivedDataPath build build CODE_SIGNING_ALLOWED=NO >/dev/null
APP="build/Build/Products/Debug-iphonesimulator/Fried.app"
xattr -cr "$APP" >/dev/null 2>&1 || true
codesign --force --sign - --timestamp=none --generate-entitlement-der "$APP" >/dev/null 2>&1

echo "▸ Booting Simulator…"
open -a Simulator
xcrun simctl boot "$UDID" 2>/dev/null || true
xcrun simctl bootstatus "$UDID" -b >/dev/null

APP="build/Build/Products/Debug-iphonesimulator/Fried.app"
xcrun simctl install "$UDID" "$APP"
xcrun simctl terminate "$UDID" com.nghinai.fried 2>/dev/null || true
xcrun simctl launch "$UDID" com.nghinai.fried >/dev/null
echo "✅ Fried is running in the Simulator. Tap 'Find out' to start."
