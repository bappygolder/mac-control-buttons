#!/bin/bash
set -e
APP_NAME="MacControlCenter"
BUILD_DIR="build"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"

# Clean
rm -rf "${BUILD_DIR}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# Generate Icon
echo "Generating App Icon..."
swift make_icon.swift
iconutil -c icns MyIcon.iconset -o "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"
rm -rf MyIcon.iconset

# Compile Swift code
export MACOSX_DEPLOYMENT_TARGET=11.0
swiftc -o "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}" Sources/${APP_NAME}/*.swift -framework SwiftUI -framework AppKit

# Create Info.plist (LSUIElement = YES means no dock icon, menu bar only)
cat <<EOF > "${APP_BUNDLE}/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.${APP_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleName</key>
    <string>Mac Control Center</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>2.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>LSUIElement</key>
    <false/>
</dict>
</plist>
EOF

# Sign the app to avoid "damaged or incomplete" error
echo "Signing App Bundle..."
codesign --force --deep -s - "${APP_BUNDLE}"

if [[ "$1" == "--install" ]]; then
    echo "Installing to /Applications..."
    rm -rf "/Applications/MacControlCenter.app"
    cp -r "${APP_BUNDLE}" /Applications/
    echo "Installed successfully! You can find Mac Control Center in your Launchpad."
else
    echo "Build complete. Run with: open \"${APP_BUNDLE}\""
    echo "To install to your computer, run: ./build.sh --install"
fi
