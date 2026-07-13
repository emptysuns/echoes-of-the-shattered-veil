# Act I Vertical Slice and Public Release Design

**Status:** Approved by execution directive
**Release target:** v0.1.0
**Repository target:** `emptysuns/echoes-of-the-shattered-veil` (public)

## Product boundary

Release v0.1.0 is a complete Act I vertical slice rather than an empty framework. A player can enter Echo Sanctum, speak with recurring NPCs, start a seeded run, explore three procedural floors, fight enemies under a discrete energy-turn model, collect items and lore, encounter injected StoryBeat rooms, confront Caedmon, die and preserve Echo Essence, restart with changed Hub dialogue, and inspect inventory, messages, quest, and codex state. Acts II–IV remain fully authored in the Narrative Bible and represented as future content packs, not falsely presented as playable.

## Runtime design

- Godot 4.3 baseline, 480×270, GL Compatibility, 32×32 logical grid.
- All ordinary definitions use typed custom Resources or JSON; runtime systems reference namespaced IDs.
- Requested Autoloads are implemented and registered, with supporting Logger, ContentRegistry, SaveSystem, Balance, and FOVSystem.
- The demo uses a deterministic room-and-corridor generator with cellular edge variation and explicit narrative-room replacement.
- The world view draws crisp pixel geometry from authored palettes and generated PNG sprites; no smoothing or non-integer scaling.
- The main scene is a small orchestrator. Rules remain in domain services and Components.
- Save data is JSON under `user://`, written through temporary files and backups.

## Demo content

- Player Warden, Ash Hound, Bell Acolyte, Ash Sentinel, and Caedmon definitions.
- Melee, ranged, patrol/chase, summoning, and multi-phase Boss behavior primitives.
- Three weapons/consumables, equipment, two affixes, three statuses, traps, elite modifier, secret room, stairs, and lore interactables.
- Six canonical Act I lore entries, two memory visions, three StoryBeat templates, one branching Maelin dialogue graph, one Caedmon combat dialogue graph, one quest, and four Ending definitions.
- Five Sanctum NPCs with relationship/meta-sensitive lines; Act I gives full interaction depth to Maelin and concise evolving exchanges for the other four.

## UI design

A restrained charcoal, ash, cold-blue, and amber pixel interface protects the playfield. HUD shows health, energy, floor, essence, quest cue, and last messages. Inventory/Codex/Dialogue/Hub use modal panels. Keyboard and gamepad work through semantic actions; on-screen touch controls emit the same actions. Text can switch between Simplified Chinese and English.

## Promotional site design

The GitHub Pages site is a fast static bilingual landing page. It uses an original locally generated pixel-art panorama of the Shattered Spire, near-black background, ash-white typography, cold cyan navigation, and sparing amber calls to action. Sections are: hero/download, the death-and-memory loop, tactical pillars, four-Act roadmap, recurring cast, open-source contribution, and release/download footer. It is responsive, accessible, and contains no fake reviews, invented download counts, or inert controls.

## Release architecture

- `VERSION` is the SemVer source of truth and equals `application/config/version`.
- CI validates Python tests, content, GDScript parsing, Godot 4.3 import, and headless gameplay tests.
- Export presets cover Linux, Windows, macOS, Web, and Android.
- A tag workflow rejects version mismatch, exports artifacts with Godot 4.3 templates, generates SHA-256 checksums, and publishes a GitHub Release marked latest.
- A Pages workflow deploys `site/` from main; the site links to the latest release URL.
- Publication finishes only after `gh` readback confirms repository visibility, workflow runs, release assets, and Pages deployment.
