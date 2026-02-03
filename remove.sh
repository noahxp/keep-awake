#!/bin/bash
# Remove KeepAwake and all associated config files and caches
set -euo pipefail

BUNDLE_ID="com.keepawake.app"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "清除 KeepAwake 相關配置..."

# 1. Terminate any running KeepAwake process
if pgrep -f "KeepAwake" >/dev/null 2>&1; then
    pkill -f "KeepAwake" && echo "  已終止 KeepAwake 程序" || true
fi

# 2. Remove the LaunchAgent plist created by SMAppService
LAUNCH_AGENT="$HOME/Library/LaunchAgents/${BUNDLE_ID}.plist"
if [[ -f "$LAUNCH_AGENT" ]]; then
    launchctl remove "${BUNDLE_ID}" 2>/dev/null || true
    rm -f "$LAUNCH_AGENT"
    echo "  已移除 LaunchAgent: $LAUNCH_AGENT"
fi

# 3. Remove .app bundle installed to /Applications via DMG
if [[ -d "/Applications/KeepAwake.app" ]]; then
    rm -rf "/Applications/KeepAwake.app"
    echo "  已移除 /Applications/KeepAwake.app"
fi

# 4. Remove .app bundle assembled during dev build
BIN_PATH=$(cd "$SCRIPT_DIR" && swift build --show-bin-path 2>/dev/null) || BIN_PATH=""
if [[ -n "$BIN_PATH" && -d "$BIN_PATH/KeepAwake.app" ]]; then
    rm -rf "$BIN_PATH/KeepAwake.app"
    echo "  已移除 dev .app bundle: $BIN_PATH/KeepAwake.app"
fi

# 5. Remove cached Preferences plist (auto-created by SwiftUI/system)
PREFS="$HOME/Library/Preferences/${BUNDLE_ID}.plist"
if [[ -f "$PREFS" ]]; then
    # defaults delete clears the in-memory cache before deleting the file
    defaults delete "${BUNDLE_ID}" 2>/dev/null || true
    rm -f "$PREFS"
    echo "  已移除 Preferences: $PREFS"
fi

# 6. Remove Application Support directory
APP_SUPPORT="$HOME/Library/Application Support/${BUNDLE_ID}"
if [[ -d "$APP_SUPPORT" ]]; then
    rm -rf "$APP_SUPPORT"
    echo "  已移除 Application Support: $APP_SUPPORT"
fi

# 7. Remove Caches directory
CACHES="$HOME/Library/Caches/${BUNDLE_ID}"
if [[ -d "$CACHES" ]]; then
    rm -rf "$CACHES"
    echo "  已移除 Caches: $CACHES"
fi

echo "清除完成"
