#!/bin/bash

# Check if Swift is installed
if ! command -v swift &> /dev/null; then
    echo "Swift is not installed. Please install the Swift toolchain from https://swift.org/download/"
    exit 1
fi

# Build the app
echo "Building OpenRouterCreditApp..."
swift build -c release

# Create app bundle structure
echo "Creating app bundle..."
APP_NAME="OpenRouterCreditApp"
APP_DIR="$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

# Remove existing app bundle if it exists
if [ -d "$APP_DIR" ]; then
    echo "Removing existing app bundle..."
    rm -rf "$APP_DIR"
fi

mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy binary
cp .build/release/OpenRouterCreditApp "$MACOS_DIR/"

# Ensure executable permissions
chmod +x "$MACOS_DIR/OpenRouterCreditApp"

# Create Info.plist with additional required keys
cat > "$CONTENTS_DIR/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>OpenRouterCreditApp</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.OpenRouterCreditApp</string>
    <key>CFBundleName</key>
    <string>OpenRouterCreditApp</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.13</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
</dict>
</plist>
EOF

# Create PkgInfo file
echo "APPL????" > "$CONTENTS_DIR/PkgInfo"

# Copy entitlements if they exist
if [ -f "OpenRouterCreditApp.entitlements" ]; then
    cp OpenRouterCreditApp.entitlements "$CONTENTS_DIR/"
fi

# Copy assets if they exist
if [ -d "Assets.xcassets" ]; then
    cp -R Assets.xcassets "$RESOURCES_DIR/"
fi

echo "App bundle created at $APP_DIR"
echo "You can run the app with: open $APP_DIR"