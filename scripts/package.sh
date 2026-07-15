#!/usr/bin/env bash
# Construit Snappy.app dans ./dist (n'installe rien).
# Usage : bash package.sh [version]   (défaut : 0.1.0)
set -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${1:-0.1.0}"
DIST="$DIR/dist"
APP="$DIST/Snappy.app"

echo "▸ build release…"
swift build -c release --package-path "$DIR"

echo "▸ assemblage du bundle (v$VERSION)…"
rm -rf "$DIST"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$DIR/.build/release/Snappy" "$APP/Contents/MacOS/Snappy"
if [ -f "$DIR/Logo/Snappy.icns" ]; then
  cp "$DIR/Logo/Snappy.icns" "$APP/Contents/Resources/AppIcon.icns"
fi

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>Snappy</string>
  <key>CFBundleDisplayName</key><string>Snappy</string>
  <key>CFBundleIdentifier</key><string>com.ndaen.snappy</string>
  <key>CFBundleExecutable</key><string>Snappy</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundleIconName</key><string>AppIcon</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>$VERSION</string>
  <key>CFBundleVersion</key><string>$VERSION</string>
  <key>LSMinimumSystemVersion</key><string>14.0</string>
  <key>LSUIElement</key><true/>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

# signature ad-hoc à identifiant stable (pattern Cubby)
codesign --force --deep --sign - --identifier com.ndaen.snappy "$APP" 2>/dev/null || true

echo "✅ dist/ :"
ls -1 "$DIST"
