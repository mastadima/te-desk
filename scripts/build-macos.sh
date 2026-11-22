#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/dist"
APP="$DIST/TE Desk.app"
DMG_STAGE="$ROOT/.build/dmg-stage"
DMG="$DIST/TE-Desk-0.1.0-macOS-universal.dmg"

swift build --package-path "$ROOT" --build-path "$ROOT/.build/arm64" --triple arm64-apple-macosx13.0 -c release
swift build --package-path "$ROOT" --build-path "$ROOT/.build/x86_64" --triple x86_64-apple-macosx13.0 -c release
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" "$DMG_STAGE"
swift "$ROOT/scripts/make-app-icon.swift" "$ROOT/.build/AppIcon.iconset"
/usr/bin/iconutil -c icns "$ROOT/.build/AppIcon.iconset" -o "$APP/Contents/Resources/AppIcon.icns"
/usr/bin/lipo -create "$ROOT/.build/arm64/release/TEDesk" "$ROOT/.build/x86_64/release/TEDesk" -output "$APP/Contents/MacOS/TEDesk"
cp "$ROOT/Info.plist" "$APP/Contents/Info.plist"
/usr/sbin/dot_clean -m "$APP"
/usr/bin/codesign --force --deep --sign - --timestamp=none "$APP"
/usr/bin/codesign --verify --deep --strict "$APP"

ditto "$APP" "$DMG_STAGE/TE Desk.app"
/usr/sbin/dot_clean -m "$DMG_STAGE"
ln -sfn /Applications "$DMG_STAGE/Applications"
/bin/rm -f "$DMG"
/usr/bin/hdiutil create -volname "TE Desk" -srcfolder "$DMG_STAGE" -ov -format UDZO "$DMG"
/bin/rm -f "$DIST/TE-Desk-0.1.0-macOS-arm64.dmg" "$DIST/TE-Desk-0.1.0-macOS-arm64.pkg" "$DIST/TE-Desk-0.1.0-macOS-universal.pkg"

printf '\nBuilt installer:\n%s\n' "$DMG"
