#!/usr/bin/env bash
# Construit et installe Snappy.app dans /Applications (usage dev local).
set -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$DIR/package.sh" "$@"

APP="/Applications/Snappy.app"
rm -rf "$APP"
cp -R "$DIR/../dist/Snappy.app" "$APP"

xattr -dr com.apple.quarantine "$APP" 2>/dev/null || true
codesign --force --deep --sign - --identifier com.ndaen.snappy "$APP" 2>/dev/null || true

echo "✅ $APP installé."
echo "   ⚠️  Après un rebuild, re-cocher Snappy dans Réglages Système → Confidentialité → Enregistrement de l'écran (TCC lié au CDHash)."
echo "   Lancer : open \"$APP\""
