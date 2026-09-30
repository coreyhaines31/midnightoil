#!/bin/bash
# Builds, signs, notarizes, and publishes a release.
#
#   Scripts/release.sh 1.0.0
#
# Needs, one time:
#   - a "Developer ID Application" certificate in the login keychain
#   - notarytool credentials:  xcrun notarytool store-credentials midnightoil-notary
#   - the Sparkle EdDSA private key in the keychain (generate_keys)
#   - gh authenticated with push access to coreyhaines31/midnightoil
set -euo pipefail

VERSION="${1:?usage: Scripts/release.sh <version>}"
TEAM_ID="${TEAM_ID:-KPQU8X839X}"
NOTARY_PROFILE="${NOTARY_PROFILE:-midnightoil-notary}"
REPO="coreyhaines31/midnightoil"
APP_NAME="Midnight Oil"

cd "$(dirname "$0")/.."
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
BUILD=build/release
[ -d "$BUILD" ] && rm -r "$BUILD"
mkdir -p "$BUILD"
BUILD_NUMBER=$(git rev-list --count HEAD)

quiet() { grep -E "error:|warning: |\*\* " || true; }

echo "▶ Generating project"
xcodegen generate -q

echo "▶ Archiving $APP_NAME $VERSION ($BUILD_NUMBER)"
xcodebuild -project MidnightOil.xcodeproj -scheme MidnightOil -configuration Release \
  -archivePath "$BUILD/MidnightOil.xcarchive" \
  -allowProvisioningUpdates \
  MARKETING_VERSION="$VERSION" CURRENT_PROJECT_VERSION="$BUILD_NUMBER" \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  archive | quiet

echo "▶ Exporting with Developer ID"
cat > "$BUILD/export.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>method</key><string>developer-id</string>
  <key>teamID</key><string>$TEAM_ID</string>
  <key>signingStyle</key><string>automatic</string>
</dict></plist>
PLIST
xcodebuild -exportArchive -archivePath "$BUILD/MidnightOil.xcarchive" \
  -exportOptionsPlist "$BUILD/export.plist" -exportPath "$BUILD/export" \
  -allowProvisioningUpdates | quiet
APP="$BUILD/export/$APP_NAME.app"
codesign --verify --deep --strict --verbose=1 "$APP"

echo "▶ Notarizing the app"
ditto -c -k --keepParent "$APP" "$BUILD/app.zip"
xcrun notarytool submit "$BUILD/app.zip" --keychain-profile "$NOTARY_PROFILE" --wait
xcrun stapler staple "$APP"

echo "▶ Building the DMG"
DMG="$BUILD/MidnightOil-$VERSION.dmg"
STAGE="$BUILD/dmg"
mkdir -p "$STAGE" && cp -R "$APP" "$STAGE/" && ln -s /Applications "$STAGE/Applications"
hdiutil create -volname "$APP_NAME" -srcfolder "$STAGE" -ov -format UDZO -quiet "$DMG"
codesign --sign "Developer ID Application" --timestamp "$DMG"
xcrun notarytool submit "$DMG" --keychain-profile "$NOTARY_PROFILE" --wait
xcrun stapler staple "$DMG"
spctl --assess --type open --context context:primary-signature -v "$DMG"

echo "▶ Signing the update and writing the appcast"
SPARKLE_BIN=$(find build/DerivedData/SourcePackages/artifacts -type d -path "*Sparkle/bin" | head -1)
if [ -z "$SPARKLE_BIN" ]; then
  xcodebuild -project MidnightOil.xcodeproj -scheme MidnightOil -derivedDataPath build/DerivedData \
    -resolvePackageDependencies -quiet
  SPARKLE_BIN=$(find build/DerivedData/SourcePackages/artifacts -type d -path "*Sparkle/bin" | head -1)
fi
mkdir -p "$BUILD/appcast" && cp "$DMG" "$BUILD/appcast/"
"$SPARKLE_BIN/generate_appcast" \
  --download-url-prefix "https://github.com/$REPO/releases/download/v$VERSION/" \
  --link "https://midnightoil.app" \
  "$BUILD/appcast"

echo "▶ Publishing GitHub release v$VERSION"
gh release create "v$VERSION" "$DMG" "$BUILD/appcast/appcast.xml" \
  --repo "$REPO" --title "$APP_NAME $VERSION" --generate-notes
echo "✓ Released $APP_NAME $VERSION"
