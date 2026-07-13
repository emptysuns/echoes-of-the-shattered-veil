# Act I Release Implementation Plan

> **For agentic workers:** This plan is executed inline because the user prohibited subagents. Steps use checkbox syntax for tracking.

**Goal:** Ship a playable Godot 4.3 Act I vertical slice, public repository, automated multi-platform release, and GitHub Pages site.

**Architecture:** Build typed content definitions and domain services first, then compositional actors and deterministic dungeon gameplay, then narrative/UI content. Finish with headless tests, export presets, Actions workflows, static site, public GitHub publication, semantic tag, and release/Page readback.

**Tech Stack:** Godot 4.3/GDScript, custom Resources, JSON, Python validation, static HTML/CSS/JS, GitHub Actions, `gh`

---

### Task 1: Repository product baseline
- [ ] Add MIT license, README, contribution guide, changelog, VERSION, roadmap, and data templates.
- [ ] Add deterministic pixel-asset generation and committed assets/license metadata.
- [ ] Add failing release/content acceptance tests before production code.

### Task 2: Typed Resource model and content registry
- [ ] Implement all gameplay and narrative Resource classes with validation methods.
- [ ] Implement ContentRegistry and JSON localization/dialogue loading.
- [ ] Add base `.tres`/JSON content for Act I and validate IDs/references/locales.

### Task 3: Core services and persistence
- [ ] Implement Logger, EventBus, Balance, SaveSystem, GameManager, NarrativeSystem, and supporting requested Autoloads.
- [ ] Register Autoloads in dependency-safe order.
- [ ] Verify Godot 4.3 parse and service initialization.

### Task 4: Components, combat, inventory, AI, and FOV
- [ ] Implement Node2D Actor shell and focused Components.
- [ ] Implement energy-turn combat, equipment, affixes, stacks, statuses, traps, elites, and AI profiles.
- [ ] Implement recursive shadowcasting and explored-map memory.

### Task 5: Dungeon generation and narrative injection
- [ ] Implement seeded BSP rooms/corridors plus cellular edge variation.
- [ ] Guarantee connectivity, stairs, enemies, loot, secret candidate, and one or two StoryBeat placements.
- [ ] Emit placement/trigger facts through EventBus.

### Task 6: Narrative, dialogue, quest, lore, meta, and endings
- [ ] Implement declarative conditions/commands without eval.
- [ ] Implement branching dialogue, lore journal, quest transitions, meta Essence/unlocks, and ending qualification.
- [ ] Add high-quality bilingual Act I data, Maelin branch, visions, Caedmon phases, and all ending definitions.

### Task 7: Playable scene and cross-platform UI
- [ ] Implement Echo Sanctum, dungeon view, HUD, overlays, message log, touch controls, and language switch.
- [ ] Connect run/death/restart loop and three-floor Act I demo.
- [ ] Add main scene, project Autoload/main-scene settings, and gameplay smoke tests.

### Task 8: Testing and documentation closure
- [ ] Add Godot headless unit/integration/content runner and Python release checks.
- [ ] Complete TODO.md and DATA_TEMPLATES.md with real paths/examples.
- [ ] Run deterministic, save, narrative, and gameplay-loop verification.

### Task 9: Export and CI/CD
- [ ] Add five export presets and reproducible artifact naming.
- [ ] Add CI, release, and Pages workflows with tag/version gate and checksums.
- [ ] Locally verify import and available exports with official Godot 4.3 templates.

### Task 10: Promotional GitHub Pages site
- [ ] Generate original pixel panorama locally and define visual tokens.
- [ ] Implement bilingual responsive static site with real repository/release links.
- [ ] Run accessibility, responsive, link, and screenshot QA using Playwright fallback because no Browser plugin is available.

### Task 11: Publish and read back
- [ ] Commit verified implementation and fast-forward merge to main.
- [ ] Create public GitHub repository, push main, enable Actions/Pages, and push v0.1.0.
- [ ] Monitor workflows, fix failures, verify latest Release assets/checksums and live Pages URL through `gh`/HTTP.
