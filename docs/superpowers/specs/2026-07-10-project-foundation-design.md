# Echoes of the Shattered Veil — Project Foundation Design

**Date:** 2026-07-10

**Status:** Approved
**Scope:** Project-wide architecture and narrative foundation, with implementation in independently verifiable phases

## 1. Objective

Build a cross-platform, data-driven, pixel-art narrative roguelike in Godot whose tactical systems and literary narrative reinforce one another. The runtime must support procedural dungeons, permadeath, deterministic turn-based combat, compositional entities, branching dialogue, story-room injection, persistent meta-memory, and at least four endings. Once a reusable behavior primitive exists, adding ordinary monsters, items, effects, affixes, biomes, dialogue trees, lore, quests, story beats, NPC variants, or endings must require content files rather than edits to core systems.

The full project is intentionally decomposed into separately testable increments:

1. Project foundation, architecture, and narrative bible.
2. Typed Resource definitions, JSON schemas, content registry, and validators.
3. EventBus, GameManager, NarrativeSystem, logging, balance, and persistence foundations.
4. Node2D + Component entity composition and basic actors.
5. Procedural dungeon generation, FOV, exploration memory, and narrative-room injection.
6. Combat, inventory, effects, AI, dialogue, quests, lore, UI, and meta-progression.
7. Act I playable vertical slice and initial bilingual content.
8. Export presets, platform verification, CI/CD, semantic tags, and GitHub Releases published through `gh`.

Each increment must leave the project in a valid, testable state and may not replace missing behavior with decorative stubs.

## 2. Approved Baselines

- **Minimum engine:** Godot 4.3.x. Source and project configuration must not use APIs introduced after 4.3. CI will later verify the minimum version and a newer stable version.
- **Localization:** Simplified Chinese and English from the beginning. Runtime logic references stable localization keys, never rendered text.
- **Internal viewport:** 480×270, 16:9.
- **World grid:** 32×32 logical and visual tiles. Actors may use taller visual sprites while retaining one-tile logical occupancy where their data specifies it.
- **Scaling:** Integer scaling, nearest-neighbor filtering, preserved aspect ratio, and letterboxing where the display cannot provide an integer multiple.
- **Turn model:** Strictly discrete energy timeline. Movement, attacks, skills, status ticks, and AI actions declare data-defined energy costs. No world simulation advances while awaiting player input.
- **Data strategy:** Hybrid typed `.tres` + JSON content packs behind one validated `ContentRegistry`.
- **Renderer:** GL Compatibility for a consistent baseline across Windows, macOS, Linux, Web, and Android.

At 480×270 with 32-pixel tiles, the unobstructed camera shows roughly 15×8 tiles. Persistent HUD elements therefore remain compact and edge-aligned; large inventory, dialogue, codex, and hub surfaces use overlays rather than permanently reducing the playfield.

## 3. Data Architecture

### 3.1 Canonical content forms

Typed `.tres` Resources hold inspector-friendly structures and references:

- entity, actor, component loadout, AI profile, and boss phase definitions;
- item, equipment, affix, effect, status, tile-property, and balance definitions;
- biome, floor-generation rule, room template, spawn table, and story-beat structure;
- quest, ending, NPC, lore metadata, and declarative condition/command objects.

JSON content packs hold text-heavy or graph-heavy material:

- Chinese and English localization catalogs;
- dialogue graphs and large lore bodies;
- content-pack manifests, dependency declarations, and override declarations;
- machine-readable schemas used by validation tools.

JSON is parsed into the same immutable runtime definitions exposed for `.tres` content. Consumers do not branch on the source format.

### 3.2 Stable IDs and references

Every content object has a namespaced stable ID such as `base.enemy.veil_hound`, `base.story.act1.caedmon_oath`, or `base.lore.mercy_engine_ledger_03`. Cross-content references use IDs rather than display strings, resource filenames, scene-tree paths, or singleton internals.

The registry loads content in deterministic order:

1. engine-owned base schemas and primitive catalogs;
2. the base content pack;
3. dependency-sorted extension packs;
4. explicit overrides permitted by pack manifests.

Duplicate IDs without a declared override are fatal validation errors. Missing references, dependency cycles, invalid condition graphs, unreachable dialogue nodes, invalid quest transitions, missing translations, and incompatible schema versions fail content validation before a run begins.

### 3.3 Safe data-only behavior language

Narrative and gameplay data may combine a finite catalog of typed primitives. It may not execute arbitrary GDScript, JavaScript, dynamic expressions, or `eval` strings.

Condition graphs support `ALL`, `ANY`, and `NOT`, with typed leaves for story flags, relationships, lore completion, NPC state, quest stage, death count, Act, floor, starting background, inventory tags, run outcomes, and meta unlocks.

Narrative commands include setting a typed flag, adjusting a relationship, revealing lore, advancing a quest, playing a memory vision, queuing a story beat, unlocking meta content, granting or removing a tagged content object, and emitting a categorized message. A command batch is validated in full before application; state is snapshotted and restored if application fails.

Ordinary content additions remain data-only. Adding a genuinely new universal behavior category requires a reviewed engine primitive, its tests, validator support, documentation, and at least two concrete content uses; this prevents one-off content scripts from bypassing architecture boundaries.

## 4. Runtime Architecture

### 4.1 Dependency direction

The project follows these layers:

1. **Content and schemas** define immutable authored facts.
2. **Domain services** own game rules and state transitions.
3. **Runtime scenes and components** hold local entity state and issue domain commands.
4. **Presentation** observes authoritative state and renders world/UI/audio feedback.
5. **Platform adapters** translate file, input, window, and export differences at the edge.

Dependencies point inward. Presentation never owns combat, narrative, quest, inventory, or save truth. Components do not discover systems with arbitrary scene-tree searches. Domain services do not manipulate HUD controls or animation nodes.

### 4.2 Autoload responsibilities

The approved service set is:

- `EventBus`: typed signals for cross-domain facts; no gameplay state.
- `GameManager`: application state machine, run lifecycle, scene transitions, pause, and death orchestration.
- `DungeonGenerator`: deterministic spatial generation and placement constraints; no story progression decisions.
- `CombatSystem`: validates and resolves actions on the energy timeline; no UI or inventory storage.
- `InventorySystem`: ownership, stacks, equipment rules, and item transactions; no rendering.
- `UIManager`: opens and coordinates presentation surfaces; no authoritative domain mutations.
- `NarrativeSystem`: story flags, narrative eligibility, beat scheduling, narrative transactions, and ending evaluation.
- `DialogueManager`: dialogue graph traversal and choice submission through narrative commands.
- `QuestSystem`: validated quest state transitions.
- `LoreSystem`: discoveries, codex state, completion metrics, and localized entry access.
- `MetaProgressionSystem`: Echo Essence, permanent unlocks, memory tiers, backgrounds, variants, and NG+ gates.

Supporting infrastructure includes `ContentRegistry`, `SaveSystem`, `Logger`, `Balance`, and `InputAdapter`. They must remain focused services rather than accumulating unrelated game logic.

Direct service calls are reserved for commands that require an immediate result, such as validating an inventory transaction. Facts that may interest multiple consumers are emitted on `EventBus`. Signal payloads are typed value objects or stable IDs, not mutable scene nodes unless the event is explicitly local to the active scene.

### 4.3 Compositional entities

Actors are Node2D scene roots assembled from focused child components. Representative components include `HealthComponent`, `CombatComponent`, `EnergyTimelineComponent`, `StatusComponent`, `AIComponent`, `InventoryComponent`, `DialogueComponent`, and `NarrativeTriggerComponent`.

An actor definition chooses a scene shell, visual resources, tags, base statistics, component configuration, behavior profile, drops, dialogue ID, and narrative hooks. Components own local state and lifecycle only. Cross-entity rules are resolved by domain systems. New actors are assembled from existing components and data; inheritance is limited to small technical bases where Godot lifecycle behavior is genuinely shared.

## 5. Narrative–Dungeon Collaboration

For every generated floor, `GameManager` requests a floor plan. `NarrativeSystem` evaluates Act, story canon, current run, meta-memory, relationship state, prior beat history, prerequisites, exclusion groups, and cooldowns. It returns a `NarrativeFloorPlan` containing one required story-beat placement and, when eligible content exists, one additional optional or relational placement.

`DungeonGenerator` first creates and validates the spatial graph. It then matches narrative placement constraints against candidate rooms and replaces or decorates suitable rooms with handcrafted `StoryBeatRoom` templates. Constraints may include depth band, minimum room size, entrance count, distance from stairs, adjacency tags, biome tags, isolation, boss proximity, and secret status.

A required beat that cannot match its preferred constraints uses a declared fallback template and anchor-room policy. It is never silently omitted. The generator records the chosen beat IDs and room coordinates in the deterministic floor manifest. Entering or interacting with a trigger emits an event; `NarrativeSystem` atomically applies commands, and dialogue, quest, lore, message log, audio, and UI systems respond independently.

This keeps story selection out of spatial generation while still guaranteeing one or two authored narrative spaces per floor.

## 6. Narrative State and Death Loop

Narrative state has three explicit scopes:

- **Run state:** seed, floor, temporary relationship deltas, run-local NPC outcomes, consumed beats, current inventory, encounters, and choices. It is archived and cleared on permadeath.
- **Echo memory:** death count, Echo Essence, permanent unlocks, known lore, memory tier, remembered conversations, Act variants, starting backgrounds, and NG+ state.
- **Story canon:** typed key decisions, durable NPC fates, quest milestones, truth discoveries, and ending qualifications.

Every story flag declares its ID, type, scope, default value, and optional validation constraints. Content cannot create undeclared flags at runtime.

A death transaction freezes the run result, calculates Essence through `Balance`, archives narratively relevant choices, advances eligible memory milestones, applies unlocks, writes an atomic profile save, clears the resumable run save, and returns to Echo Sanctum. If persistence fails, the old profile and run remain recoverable and the transition does not pretend to have completed.

`ProfileSave` and `RunSave` are versioned separately. Saves use `user://`, explicit migration chains, temporary-write validation, checksum verification, atomic replacement where supported, and a last-known-good backup. The same logical format is used on desktop, Web, and Android.

## 7. Narrative Foundation

### 7.1 Hidden history

The old kingdom of **Avarra / 阿瓦拉** built the **Mercy Engine / 慈悲机枢** to remove traumatic memory. A medical promise became a political instrument: the court extracted grief, guilt, dissent, and inconvenient testimony and confined them beyond the Veil.

The player's predecessor, first Echo Warden **Aster Vale / 阿斯特·维尔**, helped design the Engine and later enabled its expansion. When the crown ordered an entire city connected to it, Aster attempted to release every captive memory at once. Millions of mutually contradictory lives tore reality in **The Shattering / 大撕裂**.

The Shattered Spire is the Engine transformed into a living mnemonic organ. The player is neither an innocent reincarnation nor a perfect continuation of Aster. The Spire repeatedly reconstructs a possible person from incomplete guilt. This makes inherited responsibility real without making destiny absolute: each new choice forms a self Aster never possessed.

### 7.2 Four Acts

1. **Ashen Narthex / 灰烬前殿:** burned sanctuaries, bell chambers, and burial galleries teach Echo reading. The accepted history calls the Shattering a Void invasion. Boss Caedmon Rook recognizes the player and reveals that Aster promised to erase his pain.
2. **Gilded Ossuary / 鎏金骨廷:** palaces, memory-tax vaults, and gilded remains expose the kingdom's extraction regime and Aster's complicity. Primordial Echoes are revealed as suppressed original testimony, not inert repair material.
3. **Mirror Deep / 镜渊:** inverted observatories and a sea of incompatible memories confront the player with echoes from other cycles. The player learns that each resurrection feeds the Spire, yet accumulated choices are producing a genuinely new identity.
4. **Wound Crown / 伤冠之巅:** reality and memory overlap around the old throne embedded in the Spire. The Void is the collective existence of discarded memory, not an inherently evil invader. The finale chooses who may own, refuse, carry, or release memory.

### 7.3 Echo Sanctum cast

- **Maelin / 梅林, the Bellkeeper:** Aster's former assistant. His protective lies ask when care becomes denial of another person's right to know.
- **Ilyra Venn / 伊莱拉·温, Cartographer of Unmade Roads:** a living explorer who forgets more of home each cycle. The player can preserve her autonomy or optimize her into a perfect tool.
- **Vey Ashhand / 灰手维, the Smith:** a person formed from soldiers' shared will to survive. Vey rejects being treated as an upgrade shop and is essential to a consensual solution.
- **Sister Oryn / 奥林修女, the False Archivist:** a former royal propagandist. Her codex annotations evolve through denial, rationalization, shame, and testimony.
- **Moth / 飞蛾:** a new consciousness assembled from memories whose owners were erased. Moth speaks in borrowed fragments but has an independent right to refuse use by either side.

### 7.4 Act I story boss

**Caedmon Rook / 凯德蒙·鲁克, “The Bell Without a Tongue / 无舌之钟”** begins by executing the old Warden Protocol. At 60% health a memory vision interrupts the fight and he calls the player Aster. Recovering his military order and his daughter's folded paper bird unlocks the ability to speak her name during combat.

The resolution is not a cosmetic dialogue choice. The player may kill Caedmon and extract his Echo, spare him while leaving his imposed duty intact, or return the painful memory that was taken from him and let him choose. These outcomes alter Maelin's trust, Act II room variants, later NPC survival, and ending eligibility.

### 7.5 Endings

- **Mend / 缝合:** become a permanent anchor and stabilize the world while every memory of the player's name and journey disappears. It frames redemption as self-erasure.
- **Sever / 割断:** destroy the Veil and return all memories without mediation. Freedom is no longer centrally managed, but society must endure truth released without consent or preparation.
- **Crown / 加冕:** control the Spire in the belief that memory can be governed correctly. NG+ reveals Echo Sanctum becoming the player's own compassionate prison.
- **Chorus / 合唱 — True Ending:** replace extraction with a revocable, consensual, distributed covenant for carrying memory. Eligibility requires high lore completion, the survival and autonomous resolution of all five Sanctum NPCs, non-dominating resolutions to key bosses, cross-cycle recovery of Aster's true intent and name, and rejection of the three major opportunities to rewrite another person's mind.

The True Ending requires repeated engagement but not arbitrary grind. Its cross-cycle evidence comes from mutually exclusive, narratively meaningful variants that become available through memory tiers.

## 8. Writing and Localization Rules

Narrative channels have distinct jobs:

- environmental details pose questions and show material consequences;
- lore entries supply situated testimony with a named or inferable perspective;
- memory visions dramatize decisive sensory fragments rather than summarizing history;
- dialogue negotiates trust, agency, and interpretation in the present;
- the message log delivers concise combat facts and poetic narrative observations under separate categories;
- codex annotations expose disagreement between sources instead of presenting an omniscient encyclopedia.

Choices are described by actions, not morality labels. Every major choice carries a comprehensible ethical benefit and cost. No collectible exists solely to raise a percentage; each changes an interpretation, unlocks a tactic, affects a relationship, or contributes evidence for an ending.

Chinese and English share stable semantic intent but may use language-specific rhythm. Chinese prose favors restrained imagery, concrete verbs, and short clauses during danger. English prose favors lucid lyricism without faux-archaic diction. Proper-noun translations are fixed in the project glossary. UI limits are specified per localization key, and CI later reports missing keys and overflow-sensitive strings.

The identity reversal is protected by epistemic staging. Early text may be sincere and wrong. Every revelation records who believes it, what evidence supports it, and which later fact recontextualizes it. The narrative must not rely on empty mysticism, repeated amnesia without new agency, lore dumps detached from play, or a final monologue that introduces evidence the player could not previously discover.

## 9. Phase-One Repository Structure

```text
.
├── project.godot
├── ARCHITECTURE.md
├── NARRATIVE_BIBLE.md
├── TODO.md
├── DATA_TEMPLATES.md
├── addons/
├── assets/
│   ├── audio/{music,ambient,sfx}/
│   ├── fonts/
│   ├── lore_art/
│   ├── portraits/
│   ├── sprites/{actors,effects,items}/
│   ├── tilesets/
│   ├── ui/{icons,themes}/
│   └── licenses/
├── content/base/
│   ├── manifest.json
│   ├── localization/{zh_CN,en}.json
│   ├── dialogues/
│   ├── lore/
│   └── schemas/
├── resources/
│   ├── affixes/
│   ├── balance/
│   ├── biomes/
│   ├── dungeon/
│   ├── effects/
│   ├── entities/
│   ├── items/
│   ├── meta/
│   ├── narrative/{dialogues,endings,lore,npcs,quests,story_beats}/
│   └── tiles/
├── scenes/{bootstrap,components,dungeon,entities,hub,narrative,ui,world}/
├── scripts/{autoload,core,components,combat,dungeon,entities,input,inventory,narrative,save,ui,utilities}/
├── tests/{unit,integration,content,fixtures}/
├── tools/{content_validation,importers,release}/
└── docs/{adr,superpowers/specs,superpowers/plans}/
```

Phase one creates the complete directory skeleton with keep files where Git would otherwise omit a directory. It creates a valid Godot 4.3 project configuration but deliberately does not register missing Autoloads or reference a nonexistent main scene. Those entries are added in the phase that creates and headlessly validates their implementations.

## 10. Project Configuration Intent

`project.godot` will establish:

- application name and 4.3 project feature compatibility;
- 480×270 viewport and a 960×540 default desktop window;
- canvas-item stretching, integer scale mode, preserved aspect ratio, and centered letterboxing;
- nearest-neighbor default canvas texture filtering;
- pixel snapping for 2D transforms and vertices;
- GL Compatibility on desktop and mobile;
- lossless texture import expectations for pixel-art source files;
- shared semantic input actions for eight-direction movement, wait, confirm, cancel, inventory, character, codex, map, message history, quick slots, zoom, and pause.

Import settings that Godot stores per asset are enforced later by import presets and a validation script; a project setting alone cannot guarantee that every future source file is correctly imported.

## 11. Initial Documentation Deliverables

`ARCHITECTURE.md` will be a complete initial reference covering goals and non-goals, dependency rules, service responsibilities, component composition, data loading and validation, stable IDs, event conventions, energy scheduling, dungeon and FOV boundaries, narrative-room injection, save safety, error handling, structured logging, testing strategy, cross-platform constraints, content extension recipes, and the final release pipeline.

`NARRATIVE_BIBLE.md` will be a complete initial creative reference covering terminology, public and true histories, themes, narrative epistemology, four-Act visual and dramatic structures, protagonist and supporting arcs, bosses, ending conditions, meta-progression cadence, story delivery channels, choice design, bilingual terminology, prose standards, continuity rules, and Act I vertical-slice requirements.

`TODO.md` and `DATA_TEMPLATES.md` are reserved paths in phase one and become substantive deliverables in the implementation phases where their roadmap and schemas can reference real verified files rather than speculative APIs.

## 12. Verification and Release Direction

Phase one is accepted when:

- the repository tree matches the approved structure;
- `project.godot` parses under Godot 4.3 without missing-resource errors;
- pixel-perfect and input settings are present and machine-checkable;
- both root documents contain all approved sections and agree on names, state scopes, Act order, and ending conditions;
- no Autoload or main scene points to a file that does not exist;
- Markdown links and repository paths validate;
- the working tree contains no generated Godot cache or visual-companion state.

The final delivery phase will add reproducible export presets for Windows, macOS, Linux, Web, and Android; a CI matrix that validates content, tests GDScript, imports the project, and produces platform artifacts; and a release workflow that triggers only for a semantic version tag matching the project version. It will reject a tag/project-version mismatch, create checksummed artifacts, and publish the matching GitHub Release through authenticated GitHub tooling. Repository creation or remote publication will occur only when the project is verified and GitHub authentication and ownership are confirmed.

## 13. Principal Risks and Mitigations

- **32-pixel grid reduces visible tactical area:** use overlay UI, camera look-ahead, concise threat indicators, and encounter rooms designed for the 15×8 visible envelope.
- **Hybrid authoring can drift:** normalize both formats behind one registry and run the same validators against runtime definitions.
- **Data-driven systems can become untyped scripting languages:** keep a finite typed primitive catalog and prohibit executable expressions.
- **Narrative injection can break generation:** separate selection from placement, validate room constraints, and require explicit fallback templates.
- **Meta-progression can become grind:** gate truth through meaningful variants and decisions, not raw death count alone.
- **Bilingual prose can diverge:** maintain a canonical glossary, semantic notes, per-key review state, and automated coverage checks.
- **Cross-platform pixel output can differ:** use one compatibility renderer, deterministic viewport policy, platform-specific screenshot checks, and no unsupported shader path.
