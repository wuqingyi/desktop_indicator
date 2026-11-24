#!/usr/bin/env bash
# Install the Virtual Desktop Indicator Plasmoid into the current user's
# Plasma session and add it to the first panel.
set -euo pipefail

PKG_ID="org.workbuddy.vdeskicons"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/package"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
DEST="$DATA_DIR/plasma/plasmoids/$PKG_ID"
PANEL_RC="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"

command -v kpackagetool6 >/dev/null || { echo "kpackagetool6 not found" >&2; exit 1; }
[ -f "$SRC/metadata.json" ] || { echo "package source missing: $SRC" >&2; exit 1; }

echo "==> Installing $PKG_ID"
if kpackagetool6 --type=Plasma/Applet --list 2>/dev/null | grep -qx "$PKG_ID"; then
    kpackagetool6 --type=Plasma/Applet --remove "$PKG_ID" >/dev/null
fi
mkdir -p "$DATA_DIR/plasma/plasmoids"
rm -rf "$DEST"
cp -r "$SRC" "$DEST"
echo "    installed to $DEST"

if busctl --user list --no-pager 2>/dev/null | grep -q 'org.kde.plasmashell'; then
    if [ -f "$PANEL_RC" ] && grep -q "plugin=$PKG_ID" "$PANEL_RC"; then
        echo "==> Already present in panel, skipping add"
    else
        echo "==> Adding to panel"
        busctl --user call org.kde.plasmashell /PlasmaShell \
            org.kde.PlasmaShell evaluateScript s \
            "var p = panels()[0]; if (p) { p.addWidget('$PKG_ID'); print('added $PKG_ID'); }"
    fi
else
    echo "==> plasmashell not running; open a Plasma session and add the widget manually"
fi

echo "==> Done"
