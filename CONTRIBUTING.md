# Contributing

Thank you for helping build Echoes of the Shattered Veil. Contributions should preserve Godot 4.3 compatibility, deterministic rules, bilingual content parity, and the data/code boundary described in `ARCHITECTURE.md`.

## Workflow

1. Fork and create a focused branch.
2. Add or update tests before implementation when behavior changes.
3. Keep ordinary content in `.tres` or JSON; do not add per-content scripts.
4. Add every localization key to both `zh_CN` and `en` catalogs.
5. Run the full verification commands from `README.md`.
6. Open a pull request explaining gameplay, narrative, save-format, and platform impact.

## Content standards

- IDs use `<pack>.<domain>.<semantic_name>` and remain stable after release.
- Dialogue choices describe actions rather than morality labels.
- Lore identifies a source and changes an interpretation, relationship, condition, or tactic.
- Pixel assets use integer dimensions, nearest-neighbor scaling, and no smoothing.
- New engine primitives need at least two real content use cases and validator coverage.

## Commit style

Use concise conventional prefixes such as `feat:`, `fix:`, `data:`, `docs:`, `test:`, and `chore:`. Never commit export templates, signing keys, `.godot/`, editor caches, or generated build directories.
