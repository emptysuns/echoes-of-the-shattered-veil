#!/usr/bin/env bash
set -euo pipefail
GODOT_BIN="${GODOT_BIN:-godot}"
"$GODOT_BIN" --headless --editor --path . --quit
"$GODOT_BIN" --headless --path . --script res://tools/content_validation/validate_content.gd
for scene in test_components test_dungeon test_narrative test_game_loop test_start_screen test_runner; do
  "$GODOT_BIN" --headless --path . "res://tests/integration/${scene}.tscn"
done
python3 -m unittest discover -s tests -v
