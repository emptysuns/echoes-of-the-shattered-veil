from __future__ import annotations

import json
import re
import struct
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
VERSION_RE = re.compile(r"^\d+\.\d+\.\d+$")

REQUIRED_AUTOLOADS = (
    "Logger",
    "ContentRegistry",
    "EventBus",
    "SaveSystem",
    "Balance",
    "GameManager",
    "DungeonGenerator",
    "CombatSystem",
    "InventorySystem",
    "NarrativeSystem",
    "DialogueManager",
    "QuestSystem",
    "LoreSystem",
    "MetaProgressionSystem",
    "UIManager",
)

REQUIRED_RESOURCE_SCRIPTS = (
    "content_definition.gd",
    "stat_block_resource.gd",
    "effect_definition_resource.gd",
    "status_effect_resource.gd",
    "item_definition_resource.gd",
    "affix_definition_resource.gd",
    "entity_definition_resource.gd",
    "boss_phase_resource.gd",
    "biome_definition_resource.gd",
    "room_template_resource.gd",
    "condition_resource.gd",
    "narrative_command_resource.gd",
    "dialogue_node_resource.gd",
    "dialogue_tree_resource.gd",
    "lore_entry_resource.gd",
    "story_event_resource.gd",
    "quest_step_resource.gd",
    "quest_resource.gd",
    "ending_resource.gd",
    "npc_definition_resource.gd",
)

REQUIRED_RELEASE_FILES = (
    "README.md",
    "LICENSE",
    "CONTRIBUTING.md",
    "CHANGELOG.md",
    "VERSION",
    "TODO.md",
    "DATA_TEMPLATES.md",
    "export_presets.cfg",
    ".github/workflows/ci.yml",
    ".github/workflows/release.yml",
    ".github/workflows/pages.yml",
    "site/index.html",
    "site/styles.css",
    "site/site.js",
)


class ReleaseContractTests(unittest.TestCase):
    def test_version_is_semver_and_matches_project(self) -> None:
        version = (ROOT / "VERSION").read_text(encoding="utf-8").strip()
        self.assertRegex(version, VERSION_RE)
        project = (ROOT / "project.godot").read_text(encoding="utf-8")
        self.assertIn(f'config/version="{version}"', project)

    def test_required_resource_classes_exist(self) -> None:
        base = ROOT / "scripts/core/resources"
        missing = [name for name in REQUIRED_RESOURCE_SCRIPTS if not (base / name).is_file()]
        self.assertEqual([], missing)
        for name in REQUIRED_RESOURCE_SCRIPTS:
            text = (base / name).read_text(encoding="utf-8")
            self.assertIn("class_name ", text, name)
            self.assertIn("func validate()", text, name)

    def test_autoloads_and_main_scene_are_registered(self) -> None:
        project = (ROOT / "project.godot").read_text(encoding="utf-8")
        self.assertIn("[autoload]", project)
        for autoload in REQUIRED_AUTOLOADS:
            self.assertRegex(project, rf'(?m)^{autoload}="\*res://scripts/autoload/.+\.gd"$')
        self.assertIn('run/main_scene="res://scenes/bootstrap/main.tscn"', project)

    def test_act_one_content_is_data_driven(self) -> None:
        tres_files = list((ROOT / "resources").rglob("*.tres"))
        self.assertGreaterEqual(len(tres_files), 24)
        required_ids = {
            "base.entity.player.warden",
            "base.enemy.ash_hound",
            "base.enemy.bell_acolyte",
            "base.boss.caedmon_rook",
            "base.quest.act1.a_name_returned",
            "base.ending.chorus",
        }
        joined = "\n".join(path.read_text(encoding="utf-8") for path in tres_files)
        for content_id in required_ids:
            self.assertIn(content_id, joined)

    def test_bilingual_catalogs_have_identical_nonempty_keys(self) -> None:
        locale_dir = ROOT / "content/base/localization"
        zh = json.loads((locale_dir / "zh_CN.json").read_text(encoding="utf-8"))["entries"]
        en = json.loads((locale_dir / "en.json").read_text(encoding="utf-8"))["entries"]
        self.assertEqual(set(zh), set(en))
        self.assertGreaterEqual(len(en), 60)
        self.assertTrue(all(value.strip() for value in zh.values()))
        self.assertTrue(all(value.strip() for value in en.values()))

    def test_release_and_site_files_exist(self) -> None:
        missing = [path for path in REQUIRED_RELEASE_FILES if not (ROOT / path).is_file()]
        self.assertEqual([], missing)
        license_text = (ROOT / "LICENSE").read_text(encoding="utf-8")
        self.assertIn("MIT License", license_text)
        site = (ROOT / "site/index.html").read_text(encoding="utf-8")
        self.assertIn("Echoes of the Shattered Veil", site)
        self.assertIn("破碎帷幕的回响", site)

    def test_pixel_assets_are_png_and_integer_scaled(self) -> None:
        assets = (
            ROOT / "assets/lore_art/shattered_spire_panorama.png",
            ROOT / "assets/sprites/actors/warden.png",
            ROOT / "assets/sprites/actors/caedmon.png",
            ROOT / "assets/ui/icons/game_icon.png",
        )
        for path in assets:
            raw = path.read_bytes()
            self.assertEqual(b"\x89PNG\r\n\x1a\n", raw[:8], path.as_posix())
            width, height = struct.unpack(">II", raw[16:24])
            self.assertEqual(0, width % 32, path.as_posix())
            self.assertEqual(0, height % 32, path.as_posix())

    def test_no_unresolved_placeholders_in_release_surface(self) -> None:
        pattern = re.compile(r"\b(?:TBD|FIXME|XXX)\b|implement later|lorem ipsum", re.I)
        paths = [ROOT / path for path in REQUIRED_RELEASE_FILES if path.endswith((".md", ".html"))]
        for path in paths:
            if path.exists():
                self.assertIsNone(pattern.search(path.read_text(encoding="utf-8")), path.as_posix())


if __name__ == "__main__":
    unittest.main()
