# Changelog

All notable changes follow semantic versioning.

## 0.1.2 — Start Screen Input Fix

### Fixed

- Restored mouse and touch interaction by making full-viewport UI layout roots ignore pointer hit testing while preserving interactive child controls.
- Added an integration regression test that performs a real mouse click on the Start button.

### Changed

- English is now the default locale; Simplified Chinese remains fully supported.
- Expanded the README into complete English-first bilingual documentation.

## 0.1.1 — Act I: Ashen Narthex

### Fixed

- Removed incompatible Android SDK overrides from the built-in-template export preset.
- Preserved clean cross-platform release packaging and tag/version validation.

### Added

- Playable Echo Sanctum and three-floor Act I procedural run.
- Energy-timeline combat, compositional actors, FOV, inventory, effects, and AI.
- Data-driven bilingual narrative content, Lore Codex, quest, StoryBeats, and Caedmon encounter.
- Persistent Echo Essence and death-reactive Sanctum dialogue.
- Windows, macOS, Linux, Web, and Android export presets.
- Automated CI, semantic-tag Release publishing, and GitHub Pages promotional site.
