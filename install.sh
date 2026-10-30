#!/usr/bin/env bash
# Installs Finder for the current user (no sudo).
#   ./install.sh               build + install, add to the app grid
#   ./install.sh --set-default also make it the default handler for folders
#   ./install.sh --uninstall   remove and give folders back to Nautilus
set -euo pipefail

APP_ID="dev.thanh.finder_linux"
PREFIX="$HOME/.local/share/finder-linux"
DESKTOP_FILE="$HOME/.local/share/applications/$APP_ID.desktop"
BIN_LINK="$HOME/.local/bin/finder"
cd "$(dirname "$0")"

if [[ "${1:-}" == "--uninstall" ]]; then
  xdg-mime default org.gnome.Nautilus.desktop inode/directory || true
  rm -rf "$PREFIX" "$DESKTOP_FILE" "$BIN_LINK"
  update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
  echo "Uninstalled. Folders open in Nautilus again."
  exit 0
fi

# The commit and Flutter used let the app update itself later
# (Settings ▸ Advanced ▸ Updates).
flutter build linux --release \
  --dart-define=FINDER_COMMIT="$(git rev-parse HEAD 2>/dev/null || true)" \
  --dart-define=FINDER_FLUTTER="$(command -v flutter)"
rm -rf "$PREFIX"
mkdir -p "$PREFIX" "$(dirname "$DESKTOP_FILE")" "$(dirname "$BIN_LINK")"
cp -r build/linux/x64/release/bundle/. "$PREFIX/"
ln -sf "$PREFIX/finder_linux" "$BIN_LINK"

cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=Finder
GenericName=File Manager
Comment=Browse files in a macOS Finder-style window
Exec=$PREFIX/finder_linux %U
Icon=system-file-manager
Terminal=false
Categories=System;FileTools;FileManager;Utility;
MimeType=inode/directory;
StartupWMClass=$APP_ID
Actions=new-window;

[Desktop Action new-window]
Name=New Window
Exec=$PREFIX/finder_linux --new-window
EOF
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

if [[ "${1:-}" == "--set-default" ]]; then
  xdg-mime default "$APP_ID.desktop" inode/directory
  echo "Finder is now the default app for folders ($(xdg-mime query default inode/directory))."
fi
echo "Installed to $PREFIX. Launch it from the app grid or run: finder [path]"
