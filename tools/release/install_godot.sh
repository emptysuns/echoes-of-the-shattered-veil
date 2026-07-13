#!/usr/bin/env bash
set -euo pipefail
VERSION="${GODOT_VERSION:-4.3}"
INSTALL_DIR="${GODOT_INSTALL_DIR:-$HOME/.local/share/godot-ci/$VERSION}"
BIN="$INSTALL_DIR/Godot_v${VERSION}-stable_linux.x86_64"
if [[ ! -x "$BIN" ]]; then
  mkdir -p "$INSTALL_DIR"
  archive="${RUNNER_TEMP:-/tmp}/Godot_v${VERSION}-stable_linux.x86_64.zip"
  curl -fL --retry 3 -o "$archive" "https://github.com/godotengine/godot/releases/download/${VERSION}-stable/Godot_v${VERSION}-stable_linux.x86_64.zip"
  unzip -qo "$archive" -d "$INSTALL_DIR"
  chmod +x "$BIN"
fi
ln -sf "$BIN" "$INSTALL_DIR/godot"
echo "$INSTALL_DIR" >> "${GITHUB_PATH:-/dev/null}"
"$BIN" --version
