from __future__ import annotations

import json
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

REQUIRED_DIRECTORIES = (
    "addons",
    "assets/audio/music",
    "assets/audio/ambient",
    "assets/audio/sfx",
    "assets/fonts",
    "assets/lore_art",
    "assets/portraits",
    "assets/sprites/actors",
    "assets/sprites/effects",
    "assets/sprites/items",
    "assets/tilesets",
    "assets/ui/icons",
    "assets/ui/themes",
    "assets/licenses",
    "content/base/dialogues",
    "content/base/localization",
    "content/base/lore",
    "content/base/schemas",
    "resources/affixes",
    "resources/balance",
    "resources/biomes",
    "resources/dungeon",
    "resources/effects",
    "resources/entities",
    "resources/items",
    "resources/meta",
    "resources/narrative/dialogues",
    "resources/narrative/endings",
    "resources/narrative/lore",
    "resources/narrative/npcs",
    "resources/narrative/quests",
    "resources/narrative/story_beats",
    "resources/tiles",
    "scenes/bootstrap",
    "scenes/components",
    "scenes/dungeon",
    "scenes/entities",
    "scenes/hub",
    "scenes/narrative",
    "scenes/ui",
    "scenes/world",
    "scripts/autoload",
    "scripts/core",
    "scripts/components",
    "scripts/combat",
    "scripts/dungeon",
    "scripts/entities",
    "scripts/input",
    "scripts/inventory",
    "scripts/narrative",
    "scripts/save",
    "scripts/ui",
    "scripts/utilities",
    "tests/unit",
    "tests/integration",
    "tests/content",
    "tests/fixtures",
    "tools/content_validation",
    "tools/importers",
    "tools/release",
    "docs/adr",
    "docs/superpowers/specs",
    "docs/superpowers/plans",
)

PROJECT_FRAGMENTS = (
    'config/features=PackedStringArray("4.3", "GL Compatibility")',
    "window/size/viewport_width=480",
    "window/size/viewport_height=270",
    "window/size/window_width_override=960",
    "window/size/window_height_override=540",
    'window/stretch/mode="viewport"',
    'window/stretch/aspect="keep"',
    'window/stretch/scale_mode="integer"',
    'renderer/rendering_method="gl_compatibility"',
    'renderer/rendering_method.mobile="gl_compatibility"',
    "textures/canvas_textures/default_texture_filter=0",
    "2d/snap/snap_2d_transforms_to_pixel=true",
    "2d/snap/snap_2d_vertices_to_pixel=false",
    "anti_aliasing/quality/msaa_2d=0",
    "anti_aliasing/quality/screen_space_aa=0",
)

INPUT_ACTIONS = (
    "move_north",
    "move_north_east",
    "move_east",
    "move_south_east",
    "move_south",
    "move_south_west",
    "move_west",
    "move_north_west",
    "wait_turn",
    "confirm_action",
    "cancel_action",
    "open_inventory",
    "open_character",
    "open_codex",
    "toggle_map",
    "open_message_history",
    "quick_slot_1",
    "quick_slot_2",
    "quick_slot_3",
    "quick_slot_4",
    "zoom_in",
    "zoom_out",
    "pause_game",
)

ARCHITECTURE_HEADINGS = (
    "# Architecture",
    "## Architectural Goals and Non-Goals",
    "## Dependency Rules",
    "## Project Structure",
    "## Data-Driven Content Pipeline",
    "## Autoload Services",
    "## EventBus Contracts",
    "## Entity and Component Model",
    "## Energy Timeline and Combat Boundary",
    "## Dungeon, FOV, and Narrative Room Injection",
    "## Narrative Runtime",
    "## Persistence and Migration",
    "## Balance, Logging, and Error Handling",
    "## UI and Cross-Platform Input",
    "## Testing Strategy",
    "## Extension Guide",
    "## CI, Versioning, and Release Design",
)

NARRATIVE_HEADINGS = (
    "# Narrative Bible",
    "## Creative North Star",
    "## Themes",
    "## Bilingual Canonical Glossary",
    "## Public History and True Chronology",
    "## Narrative Epistemology",
    "## The Warden and Aster Vale",
    "## The Shattered Spire and the Void",
    "## Four-Act Structure",
    "## Echo Sanctum Cast",
    "## Act I Story Boss: Caedmon Rook",
    "## Death-Loop Revelation Cadence",
    "## Narrative Delivery Channels",
    "## Choice and Relationship Design",
    "## Ending Conditions",
    "## Bilingual Writing Style",
    "## Continuity and Reveal Rules",
    "## Act I Playable Demo Narrative Scope",
)


class ProjectFoundationTests(unittest.TestCase):
    def test_required_directory_structure_exists(self) -> None:
        missing = [path for path in REQUIRED_DIRECTORIES if not (ROOT / path).is_dir()]
        self.assertEqual([], missing, f"Missing directories: {missing}")

    def test_base_pack_manifest_and_locales_are_valid(self) -> None:
        manifest = json.loads((ROOT / "content/base/manifest.json").read_text(encoding="utf-8"))
        self.assertEqual("base", manifest["pack_id"])
        self.assertEqual(1, manifest["schema_version"])
        self.assertEqual((ROOT / "VERSION").read_text(encoding="utf-8").strip(), manifest["version"])
        self.assertEqual("en", manifest["default_locale"])
        self.assertEqual(["en", "zh_CN"], manifest["supported_locales"])

        catalogs = {}
        for locale in manifest["supported_locales"]:
            catalog = json.loads(
                (ROOT / f"content/base/localization/{locale}.json").read_text(encoding="utf-8")
            )
            self.assertEqual(1, catalog["schema_version"])
            self.assertEqual(locale, catalog["locale"])
            catalogs[locale] = catalog["entries"]

        self.assertEqual(set(catalogs["zh_CN"]), set(catalogs["en"]))
        self.assertGreaterEqual(len(catalogs["en"]), 9)
        self.assertTrue(all(value.strip() for entries in catalogs.values() for value in entries.values()))

    def test_project_configuration_encodes_approved_baseline(self) -> None:
        project_path = ROOT / "project.godot"
        self.assertTrue(project_path.is_file(), "project.godot is missing")
        project = project_path.read_text(encoding="utf-8")
        for fragment in PROJECT_FRAGMENTS:
            self.assertIn(fragment, project)
        for action in INPUT_ACTIONS:
            self.assertRegex(project, rf"(?m)^{re.escape(action)}=\{{$")
        self.assertIn('run/main_scene="res://scenes/bootstrap/main.tscn"', project)
        self.assertIn("[autoload]", project)

    def test_architecture_document_is_complete(self) -> None:
        path = ROOT / "ARCHITECTURE.md"
        self.assertTrue(path.is_file(), "ARCHITECTURE.md is missing")
        text = path.read_text(encoding="utf-8")
        for heading in ARCHITECTURE_HEADINGS:
            self.assertIn(heading, text)
        for service in (
            "EventBus",
            "GameManager",
            "DungeonGenerator",
            "CombatSystem",
            "InventorySystem",
            "UIManager",
            "NarrativeSystem",
            "DialogueManager",
            "QuestSystem",
            "LoreSystem",
            "MetaProgressionSystem",
        ):
            self.assertIn(f"`{service}`", text)
        self.assertGreater(len(text), 14_000)

    def test_narrative_bible_is_complete_and_consistent(self) -> None:
        path = ROOT / "NARRATIVE_BIBLE.md"
        self.assertTrue(path.is_file(), "NARRATIVE_BIBLE.md is missing")
        text = path.read_text(encoding="utf-8")
        for heading in NARRATIVE_HEADINGS:
            self.assertIn(heading, text)
        for required_term in (
            "Avarra / 阿瓦拉",
            "Mercy Engine / 慈悲机枢",
            "Aster Vale / 阿斯特·维尔",
            "Ashen Narthex / 灰烬前殿",
            "Gilded Ossuary / 鎏金骨廷",
            "Mirror Deep / 镜渊",
            "Wound Crown / 伤冠之巅",
            "Mend / 缝合",
            "Sever / 割断",
            "Crown / 加冕",
            "Chorus / 合唱",
        ):
            self.assertIn(required_term, text)
        self.assertGreater(len(text), 18_000)

    def test_documents_have_no_unresolved_placeholders(self) -> None:
        pattern = re.compile(r"\b(?:TBD|FIXME|XXX)\b|implement later|fill in details", re.IGNORECASE)
        for relative_path in ("ARCHITECTURE.md", "NARRATIVE_BIBLE.md"):
            text = (ROOT / relative_path).read_text(encoding="utf-8")
            self.assertIsNone(pattern.search(text), relative_path)


if __name__ == "__main__":
    unittest.main()
