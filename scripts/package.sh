#!/usr/bin/env bash
# Construit Snappy.app + Snappy-<version>.dmg + Snappy-<version>.zip dans ./dist
# (n'installe rien). Le DMG est l'artefact de première installation ; le ZIP est
# celui que Sparkle télécharge pour mettre à jour une app déjà installée.
# Usage : bash package.sh [version]   (défaut : 0.1.0)
set -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${1:-0.1.0}"
DIST="$DIR/dist"
APP="$DIST/Snappy.app"

# Clé publique EdDSA de l'appcast (partagée avec Cubby). Sa moitié privée vit dans
# le trousseau du mainteneur et dans le secret GitHub SPARKLE_PRIVATE_KEY — jamais
# dans le dépôt.
ED_PUBLIC_KEY="rnK7kylvGybc3oKNi2lO6K0HMmT8PZmb28aUQJcq/co="
FEED_URL="https://raw.githubusercontent.com/ndaen/snappy/main/docs/appcast.xml"

echo "▸ build release…"
swift build -c release --package-path "$DIR"

echo "▸ assemblage du bundle (v$VERSION)…"
rm -rf "$DIST"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" "$APP/Contents/Frameworks"
cp "$DIR/.build/release/Snappy" "$APP/Contents/MacOS/Snappy"
if [ -f "$DIR/Logo/Snappy.icns" ]; then
  cp "$DIR/Logo/Snappy.icns" "$APP/Contents/Resources/AppIcon.icns"
fi

# Sparkle : le chemin de l'artefact SPM change d'une version de toolchain à
# l'autre — on le retrouve, on ne le code pas en dur. `ditto` (et pas `cp -R`)
# préserve liens symboliques, permissions et signature du framework.
echo "▸ Sparkle…"
FW="$(find "$DIR/.build/artifacts" -type d -name 'Sparkle.framework' -path '*macos*' | head -1)"
[ -n "$FW" ] || { echo "✗ Sparkle.framework introuvable — lancer 'swift build' d'abord."; exit 1; }
ditto "$FW" "$APP/Contents/Frameworks/Sparkle.framework"
# le binaire est lié en @rpath : lui apprendre où chercher dans le bundle
install_name_tool -add_rpath "@executable_path/../Frameworks" "$APP/Contents/MacOS/Snappy"

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
  <key>SUFeedURL</key><string>$FEED_URL</string>
  <key>SUPublicEDKey</key><string>$ED_PUBLIC_KEY</string>
  <key>SUEnableAutomaticChecks</key><true/>
</dict>
</plist>
PLIST

# Signature ad-hoc à identifiant stable (pattern Cubby).
# Surtout pas de --deep : il réécrirait la signature Developer ID que Sparkle
# livre déjà sur son framework et ses services XPC. On ne signe que notre app,
# le code imbriqué garde sa propre signature valide.
codesign --force --sign - --identifier com.ndaen.snappy "$APP"

echo "▸ ZIP (canal de mise à jour)…"
ditto -c -k --sequesterRsrc --keepParent "$APP" "$DIST/Snappy-$VERSION.zip"

echo "▸ DMG…"
STAGE="$(mktemp -d)"
ditto "$APP" "$STAGE/Snappy.app"
ln -s /Applications "$STAGE/Applications"
hdiutil create -volname "Snappy" -srcfolder "$STAGE" -ov -format UDZO "$DIST/Snappy-$VERSION.dmg" >/dev/null
rm -rf "$STAGE"

echo "✅ dist/ :"
ls -1 "$DIST"
