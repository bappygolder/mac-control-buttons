#!/bin/bash
set -euo pipefail

APP_NAME="MacControlCenter"
BUILD_DIR="build"
FINAL_APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"
TEMP_BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/${APP_NAME}.XXXXXX")"
APP_BUNDLE="${TEMP_BUILD_DIR}/${APP_NAME}.app"
MODULE_CACHE_DIR="${TEMP_BUILD_DIR}/module-cache"
APP_ICON_SOURCE="Resources/AppIcon.icns"

cleanup() {
    rm -rf "${TEMP_BUILD_DIR}"
    rm -rf MyIcon.iconset
}

require_command() {
    local command_name="$1"

    if ! command -v "${command_name}" >/dev/null 2>&1; then
        echo "Missing required command: ${command_name}"
        exit 1
    fi
}

select_swift_toolchain() {
    local command_name="$1"

    if ! "${command_name}" --version >/dev/null 2>&1; then
        if arch -x86_64 "${command_name}" --version >/dev/null 2>&1; then
            echo "Native '${command_name}' is unavailable, using Rosetta x86_64 fallback." >&2
            printf 'arch -x86_64 %s' "${command_name}"
            return 0
        fi

        echo "Swift toolchain check failed while running '${command_name} --version'."
        echo "Current developer path: $(xcode-select -p 2>/dev/null || echo unavailable)"
        echo "This usually means Command Line Tools are installed for the wrong architecture."
        echo "Reinstall Command Line Tools or point 'xcode-select' at a working Xcode app, then rerun ./build.sh."
        exit 1
    fi

    printf '%s' "${command_name}"
}

trap cleanup EXIT

require_command iconutil
require_command codesign
SWIFT_CMD="$(select_swift_toolchain swift)"
SWIFTC_CMD="$(select_swift_toolchain swiftc)"

mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"
mkdir -p "${MODULE_CACHE_DIR}"

# Generate Icon
if [[ -f "${APP_ICON_SOURCE}" ]]; then
    echo "Using bundled app icon..."
    cp "${APP_ICON_SOURCE}" "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"
else
    echo "Generating App Icon..."
    eval "${SWIFT_CMD} -module-cache-path \"${MODULE_CACHE_DIR}\" make_icon.swift"
    iconutil -c icns MyIcon.iconset -o "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"
    rm -rf MyIcon.iconset
fi

# Compile Swift code
export MACOSX_DEPLOYMENT_TARGET=11.0
eval "${SWIFTC_CMD} -module-cache-path \"${MODULE_CACHE_DIR}\" -o \"${APP_BUNDLE}/Contents/MacOS/${APP_NAME}\" Sources/${APP_NAME}/*.swift -framework SwiftUI -framework AppKit -framework UserNotifications"

# Create Info.plist. LSUIElement=false keeps the app in the Dock while it also shows a menu bar item.
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

rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"
mv "${APP_BUNDLE}" "${FINAL_APP_BUNDLE}"

if [[ "${1:-}" == "--install" ]]; then
    echo "Installing to /Applications..."
    rm -rf "/Applications/MacControlCenter.app"
    cp -R "${FINAL_APP_BUNDLE}" /Applications/
    echo "Installed successfully! You can find Mac Control Center in your Launchpad."
else
    echo "Build complete. Run with: open \"${FINAL_APP_BUNDLE}\""
    echo "To install to your computer, run: ./build.sh --install"
fi
