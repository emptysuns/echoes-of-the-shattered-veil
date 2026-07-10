# Project Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create the Godot 4.3-compatible project skeleton, pixel-perfect configuration, bilingual base-pack shell, `ARCHITECTURE.md`, and `NARRATIVE_BIBLE.md` for Echoes of the Shattered Veil.

**Architecture:** Treat the approved design specification as the source of truth and encode its non-negotiable decisions in a Python standard-library foundation test. Establish only paths and configuration that are valid in phase one; do not register nonexistent Autoloads or a nonexistent main scene. Verify the result both structurally and with the official Godot 4.3 Linux editor binary.

**Tech Stack:** Godot 4.3 project format, JSON, Markdown, Python 3 `unittest`, Git

---

## File Map

**Create in this phase:**

- `project.godot` — minimum-version, rendering, scaling, localization, and semantic input configuration.
- `.gitattributes` — deterministic LF handling for source and authored data.
- `ARCHITECTURE.md` — authoritative engineering architecture and extension guide.
- `NARRATIVE_BIBLE.md` — authoritative story, character, Act, ending, and bilingual writing guide.
- `content/base/manifest.json` — identity and locale declaration for the built-in content pack.
- `content/base/localization/en.json` — initial English localization catalog and canonical title/Act terms.
- `content/base/localization/zh_CN.json` — initial Simplified Chinese catalog with matching keys.
- `tests/content/test_project_foundation.py` — executable phase-one acceptance contract.
- `.gitkeep` files — preserve approved empty extension points until their owning phase adds real files.

**Modify in this phase:**

- `.gitignore` — retain existing exclusions and add only verified editor/export artifacts if Godot 4.3 produces additional local state.

**Explicitly not created in this phase:**

- Autoload scripts or `[autoload]` entries.
- A startup scene or `run/main_scene` entry.
- Resource classes, combat code, generation code, UI scenes, export presets, workflows, or speculative APIs.
- Root `TODO.md` and `DATA_TEMPLATES.md`; the approved spec reserves these paths for phases where they can reference verified implementation files.

### Task 1: Encode the Foundation Contract as a Failing Test

**Files:**
- Create: `tests/content/test_project_foundation.py`
- Reference: `docs/superpowers/specs/2026-07-10-project-foundation-design.md`

- [ ] **Step 1: Create the test directory**

Run:

```bash
mkdir -p tests/content
```

Expected: `tests/content/` exists and the working tree contains no other phase-one production file.

- [ ] **Step 2: Write the complete foundation contract**

Create `tests/content/test_project_foundation.py` with this structure:

```python
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
    'config/version="0.1.0-dev"',
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
        self.assertEqual("0.1.0", manifest["version"])
        self.assertEqual("zh_CN", manifest["default_locale"])
        self.assertEqual(["zh_CN", "en"], manifest["supported_locales"])

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
        self.assertNotIn("run/main_scene", project)
        self.assertNotIn("[autoload]", project)

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
```

- [ ] **Step 3: Run the contract and verify red state**

Run:

```bash
python3 -m unittest tests.content.test_project_foundation -v
```

Expected: failures identify missing directories, `project.godot`, `ARCHITECTURE.md`, `NARRATIVE_BIBLE.md`, and base-pack JSON. No Python import or syntax error is acceptable.

- [ ] **Step 4: Commit the failing acceptance contract**

```bash
git add tests/content/test_project_foundation.py
git commit -m "test: define project foundation contract"
```

### Task 2: Create the Repository Skeleton and Bilingual Base Pack Shell

**Files:**
- Create: all directories in `REQUIRED_DIRECTORIES`
- Create: `.gitattributes`
- Create: `content/base/manifest.json`
- Create: `content/base/localization/en.json`
- Create: `content/base/localization/zh_CN.json`
- Create: `.gitkeep` in otherwise-empty leaf directories

- [ ] **Step 1: Create the approved directory tree**

Use a single checked shell command containing every path from `REQUIRED_DIRECTORIES`. Example form:

```bash
mkdir -p \
  addons \
  assets/audio/{music,ambient,sfx} \
  assets/{fonts,lore_art,portraits,tilesets,licenses} \
  assets/sprites/{actors,effects,items} \
  assets/ui/{icons,themes} \
  content/base/{dialogues,localization,lore,schemas} \
  resources/{affixes,balance,biomes,dungeon,effects,entities,items,meta,tiles} \
  resources/narrative/{dialogues,endings,lore,npcs,quests,story_beats} \
  scenes/{bootstrap,components,dungeon,entities,hub,narrative,ui,world} \
  scripts/{autoload,core,components,combat,dungeon,entities,input,inventory,narrative,save,ui,utilities} \
  tests/{unit,integration,content,fixtures} \
  tools/{content_validation,importers,release} \
  docs/{adr,superpowers/specs,superpowers/plans}
```

Expected: every path listed by the test is a directory.

- [ ] **Step 2: Preserve empty leaf directories**

Create one `.gitkeep` in every leaf directory that contains no authored file. Do not put `.gitkeep` in a directory that already contains a real file.

Run:

```bash
find addons assets content resources scenes scripts tests tools docs/adr \
  -type d -empty -exec touch '{}/.gitkeep' \;
```

Expected: `git status --short` shows the complete skeleton without generated caches.

- [ ] **Step 3: Add deterministic text attributes**

Create `.gitattributes`:

```gitattributes
* text=auto eol=lf
*.gd text eol=lf
*.godot text eol=lf
*.tscn text eol=lf
*.tres text eol=lf
*.json text eol=lf
*.md text eol=lf
*.sh text eol=lf
*.png binary
*.ogg binary
*.wav binary
*.ttf binary
*.otf binary
```

- [ ] **Step 4: Create the base pack manifest**

Create `content/base/manifest.json`:

```json
{
  "schema_version": 1,
  "pack_id": "base",
  "display_name_key": "pack.base.name",
  "version": "0.1.0",
  "game_version": ">=0.1.0 <1.0.0",
  "default_locale": "zh_CN",
  "supported_locales": ["zh_CN", "en"],
  "dependencies": [],
  "overrides": []
}
```

- [ ] **Step 5: Create matching bilingual localization catalogs**

Both catalogs use this shape:

```json
{
  "schema_version": 1,
  "locale": "LOCALE",
  "entries": {
    "game.title": "TITLE",
    "pack.base.name": "BASE_PACK",
    "act.1.name": "ACT_1",
    "act.2.name": "ACT_2",
    "act.3.name": "ACT_3",
    "act.4.name": "ACT_4",
    "ending.mend.name": "MEND",
    "ending.sever.name": "SEVER",
    "ending.crown.name": "CROWN",
    "ending.chorus.name": "CHORUS"
  }
}
```

Use these exact semantic translations:

| Key | `zh_CN` | `en` |
|---|---|---|
| `game.title` | `破碎帷幕的回响` | `Echoes of the Shattered Veil` |
| `pack.base.name` | `基础内容` | `Base Content` |
| `act.1.name` | `灰烬前殿` | `Ashen Narthex` |
| `act.2.name` | `鎏金骨廷` | `Gilded Ossuary` |
| `act.3.name` | `镜渊` | `Mirror Deep` |
| `act.4.name` | `伤冠之巅` | `Wound Crown` |
| `ending.mend.name` | `缝合` | `Mend` |
| `ending.sever.name` | `割断` | `Sever` |
| `ending.crown.name` | `加冕` | `Crown` |
| `ending.chorus.name` | `合唱` | `Chorus` |

- [ ] **Step 6: Run the structure and JSON tests**

Run:

```bash
python3 -m unittest \
  tests.content.test_project_foundation.ProjectFoundationTests.test_required_directory_structure_exists \
  tests.content.test_project_foundation.ProjectFoundationTests.test_base_pack_manifest_and_locales_are_valid \
  -v
```

Expected: both tests pass.

- [ ] **Step 7: Commit the skeleton**

```bash
git add .gitattributes addons assets content resources scenes scripts tests tools docs/adr
git commit -m "chore: scaffold Godot content structure"
```

### Task 3: Configure the Godot 4.3 Pixel-Perfect Baseline

**Files:**
- Create: `project.godot`
- Test: `tests/content/test_project_foundation.py`

- [ ] **Step 1: Write the project header and rendering settings**

Create `project.godot` with `config_version=5` and these exact effective settings:

```ini
[application]
config/name="Echoes of the Shattered Veil"
config/description="A narrative-driven pixel-art roguelike about memory, guilt, and chosen identity."
config/version="0.1.0-dev"
config/features=PackedStringArray("4.3", "GL Compatibility")
boot_splash/show_image=false

[display]
window/size/viewport_width=480
window/size/viewport_height=270
window/size/window_width_override=960
window/size/window_height_override=540
window/stretch/mode="viewport"
window/stretch/aspect="keep"
window/stretch/scale_mode="integer"

[rendering]
renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
textures/canvas_textures/default_texture_filter=0
textures/default_filters/use_nearest_mipmap_filter=false
2d/snap/snap_2d_transforms_to_pixel=true
2d/snap/snap_2d_vertices_to_pixel=false
anti_aliasing/quality/msaa_2d=0
anti_aliasing/quality/screen_space_aa=0
environment/defaults/default_clear_color=Color(0.027, 0.024, 0.043, 1)
```

Use `viewport`, not `canvas_items`: Godot 4.3 documents `viewport` stretch as the recommended pixel-art path. Enable transform snapping only; Godot 4.3 explicitly warns that enabling transform and vertex snapping together can worsen movement.

- [ ] **Step 2: Add semantic input actions**

Add an `[input]` section. Every action has deadzone `0.5`. Use `Object(InputEventKey, "physical_keycode": CODE)` entries for keyboard defaults and joypad events where stated.

| Action | Keyboard physical key | Additional default |
|---|---:|---|
| `move_north` | W / 87 | joy axis 1, value -1.0 |
| `move_north_east` | E / 69 | composed from north + east on stick/touch |
| `move_east` | D / 68 | joy axis 0, value 1.0 |
| `move_south_east` | C / 67 | composed from south + east on stick/touch |
| `move_south` | S / 83 | joy axis 1, value 1.0 |
| `move_south_west` | Z / 90 | composed from south + west on stick/touch |
| `move_west` | A / 65 | joy axis 0, value -1.0 |
| `move_north_west` | Q / 81 | composed from north + west on stick/touch |
| `wait_turn` | V / 86 | joy button 3 |
| `confirm_action` | Space / 32 | joy button 0 |
| `cancel_action` | X / 88 | joy button 1 |
| `open_inventory` | I / 73 | joy button 2 |
| `open_character` | K / 75 | none |
| `open_codex` | L / 76 | none |
| `toggle_map` | M / 77 | none |
| `open_message_history` | H / 72 | none |
| `quick_slot_1` … `quick_slot_4` | 1…4 / 49…52 | none |
| `zoom_in` | = / 61 | none |
| `zoom_out` | - / 45 | none |
| `pause_game` | P / 80 | joy button 6 |

The future `InputAdapter` will combine cardinal stick/touch directions into eight-way movement and will translate on-screen controls into these actions. Domain systems will never inspect platform APIs directly.

- [ ] **Step 3: Run the project configuration contract**

```bash
python3 -m unittest \
  tests.content.test_project_foundation.ProjectFoundationTests.test_project_configuration_encodes_approved_baseline \
  -v
```

Expected: pass, with explicit confirmation that no invalid `run/main_scene` or `[autoload]` section exists.

- [ ] **Step 4: Verify with official Godot 4.3**

If `godot4` or `godot` version 4.3 is unavailable, download the official Linux editor to `/tmp`, outside the repository:

```bash
curl -fL \
  -o /tmp/Godot_v4.3-stable_linux.x86_64.zip \
  https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_linux.x86_64.zip
unzip -o /tmp/Godot_v4.3-stable_linux.x86_64.zip -d /tmp/godot-4.3
/tmp/godot-4.3/Godot_v4.3-stable_linux.x86_64 --version
/tmp/godot-4.3/Godot_v4.3-stable_linux.x86_64 \
  --headless --editor --path "$PWD" --quit
```

Expected: version output begins with `4.3.stable`; editor import exits `0` with no project parse error. Remove generated `.godot/` before inspecting Git status; it must remain ignored.

- [ ] **Step 5: Commit project configuration**

```bash
git add project.godot
git commit -m "chore: configure Godot 4.3 pixel rendering"
```

### Task 4: Write the Engineering Architecture Reference

**Files:**
- Create: `ARCHITECTURE.md`
- Reference: `docs/superpowers/specs/2026-07-10-project-foundation-design.md`
- Test: `tests/content/test_project_foundation.py`

- [ ] **Step 1: Write every required architecture section**

Create `ARCHITECTURE.md` with the exact headings enforced by `ARCHITECTURE_HEADINGS`. The document must contain at least these concrete decisions:

1. **Architectural Goals and Non-Goals:** data-only ordinary content extension, deterministic runs, strict turn boundaries, bilingual content, 4.3 compatibility; explicitly reject arbitrary content scripts, inheritance-heavy actors, presentation-owned state, and platform branches inside domain rules.
2. **Dependency Rules:** content → domain → runtime components → presentation/platform; immediate-result commands may call a service, multi-consumer facts use typed EventBus signals.
3. **Project Structure:** explain every top-level directory and distinguish `.tres` under `resources/` from JSON packs under `content/`.
4. **Data-Driven Content Pipeline:** namespaced IDs, manifests, schema versions, dependency ordering, explicit overrides, immutable normalized definitions, reference validation, localization parity, safe typed condition graphs and command batches, hot reload limited to editor/debug builds.
5. **Autoload Services:** give a responsibility, prohibited responsibility, primary inputs, and primary outputs for each required singleton plus `ContentRegistry`, `SaveSystem`, `Logger`, `Balance`, and `InputAdapter`.
6. **EventBus Contracts:** naming convention (`past_tense_fact`), typed payload policy, connection lifecycle, no request/response signals, and an initial event catalog covering run, turn, combat, inventory, narrative, dialogue, quest, lore, meta, save, and UI facts.
7. **Entity and Component Model:** Actor Node2D shell, focused child components, local state ownership, component configuration from definitions, scene lifecycle, and examples for player, standard enemy, recurring NPC, and phased boss.
8. **Energy Timeline and Combat Boundary:** integer energy units, readiness threshold, deterministic tie-breaking, action validation, command resolution, status timing, AI scheduling, player-input pause, and replay/debug event receipts.
9. **Dungeon, FOV, and Narrative Room Injection:** BSP room graph, cellular variation, connectivity validation, biome rules, shadowcasting ownership, explored memory, floor manifest, required/optional StoryBeat placement, explicit fallback, and deterministic seed streams.
10. **Narrative Runtime:** the three state scopes, declared typed flags, dialogue graph node kinds, narrative transaction preflight/rollback, quest transition validation, ending evaluation, and no dynamic evaluation.
11. **Persistence and Migration:** separate ProfileSave/RunSave, `user://`, schema versions, migration chain, checksum, temporary write, atomic replace, backup, death transaction, and corruption recovery.
12. **Balance, Logging, and Error Handling:** pure Balance formulas with reloadable resources, structured log fields, severity policy, `push_error` only for actionable engine failures, graceful content-pack quarantine, and fatal base-pack validation.
13. **UI and Cross-Platform Input:** authoritative-state observation, pixel-safe layout, 32-pixel grid implications, overlay surfaces, keyboard/gamepad/touch semantic mapping, safe areas, and no domain platform checks.
14. **Testing Strategy:** standard-library phase-one contract, later GDScript unit/integration/content tests, seeded generation property tests, narrative graph validation, save migration fixtures, screenshot checks, and minimum/newer Godot matrix.
15. **Extension Guide:** step-by-step data-only recipes for a monster, item/affix/effect, biome/room, dialogue, lore entry, quest, StoryBeat, recurring NPC variant, and ending; state when a new primitive needs engine work.
16. **CI, Versioning, and Release Design:** SemVer source of truth, tag/version equality, content validation before exports, five-platform artifact names, checksums, GitHub Release generation, secrets policy, and `gh` publication/readback.

Use tables where responsibilities or extension recipes benefit from comparison. Include Mermaid diagrams for dependency direction, run/death flow, and narrative-room injection, but keep the prose complete if Mermaid is not rendered.

- [ ] **Step 2: Run the architecture contract**

```bash
python3 -m unittest \
  tests.content.test_project_foundation.ProjectFoundationTests.test_architecture_document_is_complete \
  tests.content.test_project_foundation.ProjectFoundationTests.test_documents_have_no_unresolved_placeholders \
  -v
```

Expected: both tests pass for `ARCHITECTURE.md`; the second test may still error because `NARRATIVE_BIBLE.md` is not created until Task 5. Run the first test independently if needed to isolate architecture completion.

- [ ] **Step 3: Check document formatting**

```bash
git diff --check -- ARCHITECTURE.md
rg -n 'TBD|FIXME|XXX|implement later|fill in details' ARCHITECTURE.md || true
```

Expected: no whitespace errors and no placeholder match.

- [ ] **Step 4: Commit architecture documentation**

```bash
git add ARCHITECTURE.md
git commit -m "docs: add architecture reference"
```

### Task 5: Write the Complete Narrative Bible Initial Draft

**Files:**
- Create: `NARRATIVE_BIBLE.md`
- Reference: `docs/superpowers/specs/2026-07-10-project-foundation-design.md`
- Test: `tests/content/test_project_foundation.py`

- [ ] **Step 1: Write the creative foundation and chronology**

Use the exact headings enforced by `NARRATIVE_HEADINGS`. Establish:

- the north star: death advances understanding rather than merely resetting progress;
- memory authenticity, free will versus inherited pattern, redemption without self-erasure, consent, and power's corruption;
- a bilingual glossary for Veil, Shattering, Echo Warden, Primordial Echo, Phantom Echo, Mercy Engine, Shattered Spire, Echo Sanctum, Echo Essence, all four Acts, and all endings;
- two timelines: the official story taught in Sanctum and the true history from medical memory extraction through royal coercion, Aster's release attempt, the Shattering, Spire emergence, and player reconstruction;
- epistemic tags for each narrative claim: speaker/source, belief state, corroboration, contradiction, reveal tier, and recontextualization target.

- [ ] **Step 2: Write the protagonist, world intelligence, and four-Act arcs**

For each Act, specify all of the following rather than a one-paragraph synopsis:

- emotional question and false belief challenged;
- biome color/value direction and environmental motifs;
- floor-by-floor reveal ladder;
- handcrafted StoryBeat room categories;
- lore source perspectives and environmental evidence;
- recurring Phantom Echo encounters;
- faction/enemy narrative purpose;
- boss identity, conflict, and non-combat or non-dominating resolution data;
- Act-ending choice and flags it influences;
- death-count-independent meta variants unlocked by discoveries;
- transition into the next Act.

The four Acts remain, in order: `Ashen Narthex / 灰烬前殿`, `Gilded Ossuary / 鎏金骨廷`, `Mirror Deep / 镜渊`, and `Wound Crown / 伤冠之巅`.

- [ ] **Step 3: Write the five complete Echo Sanctum arcs**

For Maelin, Ilyra Venn, Vey Ashhand, Sister Oryn, and Moth, include:

- surface role, concealed history, desire, fear, contradiction, voice, and recurring visual motif;
- relationship thresholds and what behavior earns or loses trust;
- at least four dialogue-state milestones across the meta loop;
- a failure state, survival condition, autonomous resolution, and impact on at least two endings;
- how the character changes a gameplay system so the arc is not detached from play.

Make Moth an independent person with refusal rights, never a magical key or morality meter. Make Vey a character whose consent matters, never merely a permanent-upgrade vendor.

- [ ] **Step 4: Fully specify Caedmon Rook and Act I narrative content**

Document Caedmon's history with Aster, his daughter, why his memory was extracted, his three combat phases, the 60% vision interrupt, the military order and folded-paper-bird clues, the condition for speaking his daughter's name, and the consequences of extraction, suspended mercy, or restored memory.

The Act I demo scope must enumerate:

- one hub dialogue tree with meaningful branches and relationship/flag effects;
- one Caedmon combat dialogue graph;
- at least six lore/environmental entries from conflicting perspectives;
- two memory visions;
- at least three reusable StoryBeat rooms and one boss room;
- death-return dialogue variants for the five hub NPCs;
- one Act I quest with divergent resolution states;
- the story flags, relationship changes, and meta unlocks produced by each choice.

- [ ] **Step 5: Define death-loop cadence and ending conditions**

Specify a reveal cadence based on memory tiers and discoveries, not raw grind. Early deaths teach mechanics and contradiction; middle cycles expose institutional complicity; later variants expose the constructed identity and allow the player to act differently.

Include a conditions matrix for:

- `Mend / 缝合`: accessible after reaching the core and accepting anchorship; variants reflect NPC trust and remembered identity.
- `Sever / 割断`: requires the severance route and evidence that centralized memory custody is coercive; variants reflect preparation and survivor support.
- `Crown / 加冕`: requires accepting control of the Spire; NG+ converts Sanctum into an increasingly optimized prison.
- `Chorus / 合唱`: requires high lore completion, survival and autonomous resolutions for all five recurring NPCs, non-dominating key boss resolutions, recovery of Aster's intent/name across meaningful variants, and rejection of all three major mind-rewrite opportunities.

State exact initial target thresholds in the bible: Chorus requires at least 85% canonical lore, all five autonomy flags, all required survival flags, three anti-domination decision flags, and the complete three-part identity evidence set. Thresholds remain authored balance/narrative data later, not hard-coded engine values.

- [ ] **Step 6: Define bilingual prose and continuity standards**

Provide:

- channel-specific rules for environmental text, lore, visions, dialogue, combat messages, narrative messages, and codex annotations;
- Chinese guidance favoring concrete verbs, controlled imagery, and short danger clauses;
- English guidance favoring lucid lyricism and rejecting faux-archaic diction;
- examples of one weak and one improved line in each language;
- fixed term capitalization and name transliteration;
- text-length and typewriter constraints for 480×270 dialogue UI;
- prohibition of morality-labeled choices, empty mysticism, omniscient lore dumps, repetitive amnesia, and unsupported finale revelations;
- a reveal-continuity table showing what may be stated in each Act and what must remain only foreshadowed.

- [ ] **Step 7: Run narrative and placeholder contracts**

```bash
python3 -m unittest \
  tests.content.test_project_foundation.ProjectFoundationTests.test_narrative_bible_is_complete_and_consistent \
  tests.content.test_project_foundation.ProjectFoundationTests.test_documents_have_no_unresolved_placeholders \
  -v
```

Expected: both tests pass.

- [ ] **Step 8: Check and commit the narrative bible**

```bash
git diff --check -- NARRATIVE_BIBLE.md
rg -n 'TBD|FIXME|XXX|implement later|fill in details' NARRATIVE_BIBLE.md || true
git add NARRATIVE_BIBLE.md
git commit -m "docs: add narrative bible"
```

Expected: clean formatting and a commit containing only the narrative bible.

### Task 6: Verify and Close Phase One

**Files:**
- Test: `tests/content/test_project_foundation.py`
- Verify: all phase-one files

- [ ] **Step 1: Run the full foundation contract**

```bash
python3 -m unittest tests.content.test_project_foundation -v
```

Expected: all six test methods pass.

- [ ] **Step 2: Run Godot 4.3 headless import again**

```bash
/tmp/godot-4.3/Godot_v4.3-stable_linux.x86_64 \
  --headless --editor --path "$PWD" --quit
```

Expected: exit code `0`, no invalid project setting, missing resource, missing Autoload, or missing main-scene error.

- [ ] **Step 3: Validate JSON, Git whitespace, and ignored artifacts**

```bash
python3 -m json.tool content/base/manifest.json >/dev/null
python3 -m json.tool content/base/localization/en.json >/dev/null
python3 -m json.tool content/base/localization/zh_CN.json >/dev/null
git diff --check HEAD
git status --ignored --short | grep -E '^!! \.godot/'
```

Expected: JSON commands exit `0`, `git diff --check` is silent, and `.godot/` is reported as ignored rather than tracked.

- [ ] **Step 4: Review phase-one scope discipline**

Run:

```bash
test ! -e TODO.md
test ! -e DATA_TEMPLATES.md
! grep -q '^\[autoload\]' project.godot
! grep -q '^run/main_scene=' project.godot
find scripts scenes resources -type f ! -name .gitkeep -print
```

Expected: the first four checks succeed and the final `find` prints nothing. This proves phase one did not smuggle in unreviewed implementation stubs.

- [ ] **Step 5: Record final evidence**

Run:

```bash
git log --oneline --decorate -8
git status --short --branch
```

Expected: the foundation test, skeleton, Godot configuration, architecture document, and narrative bible are separate commits; the working tree is clean after any final test-only adjustment commit.

- [ ] **Step 6: Commit only if verification required a test or metadata correction**

If and only if verification exposed a defect in `tests/content/test_project_foundation.py`, `.gitignore`, or `.gitattributes`, make the minimal correction, rerun every command in Tasks 6.1–6.4, then commit:

```bash
git add tests/content/test_project_foundation.py .gitignore .gitattributes
git commit -m "test: finalize foundation verification"
```

Do not create an empty closing commit.
