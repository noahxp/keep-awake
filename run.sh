#!/bin/bash
# Development launch script: build → assemble .app bundle → open
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# 1. Build
swift build "$@"

# 2. Assemble a minimal .app bundle
BIN_PATH=$(swift build --show-bin-path)
APP_DIR="$BIN_PATH/KeepAwake.app"
CONTENTS="$APP_DIR/Contents"
MACOS="$CONTENTS/MacOS"

mkdir -p "$MACOS"

# Copy the binary
cp "$BIN_PATH/KeepAwake" "$MACOS/KeepAwake"

# Write Info.plist
cat > "$CONTENTS/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>KeepAwake</string>
    <key>CFBundleIdentifier</key>
    <string>com.keepawake.app</string>
    <key>CFBundleName</key>
    <string>KeepAwake</string>
    <key>LSBackgroundOnly</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

# 3. Launch
echo "啟動 $APP_DIR"
open "$APP_DIR"
