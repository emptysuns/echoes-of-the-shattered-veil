#!/usr/bin/env python3
"""Generate original deterministic nearest-neighbor pixel assets for the project."""
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
COLORS = {
    "ink": "#090812",
    "deep": "#121126",
    "violet": "#27234a",
    "blue": "#4b6f8f",
    "cyan": "#83b6b3",
    "ash": "#d8d2c4",
    "bone": "#f0e7cf",
    "amber": "#d59a42",
    "ember": "#a94f3d",
    "blood": "#6f2638",
    "gold": "#bea45d",
}


def save_scaled(image: Image.Image, path: Path, scale: int = 1) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if scale > 1:
        image = image.resize((image.width * scale, image.height * scale), Image.Resampling.NEAREST)
    image.save(path, optimize=True)


def actor(path: Path, cloak: str, accent: str, helm: str, weapon: bool = True) -> None:
    im = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    d.rectangle((12, 5, 19, 7), fill=helm)
    d.rectangle((10, 8, 21, 14), fill=helm)
    d.rectangle((12, 10, 13, 11), fill=COLORS["cyan"])
    d.rectangle((18, 10, 19, 11), fill=COLORS["cyan"])
    d.polygon([(9, 15), (22, 15), (25, 28), (6, 28)], fill=cloak)
    d.rectangle((13, 16, 18, 25), fill=COLORS["deep"])
    d.rectangle((14, 18, 17, 20), fill=accent)
    d.rectangle((7, 28, 13, 30), fill=COLORS["ink"])
    d.rectangle((18, 28, 24, 30), fill=COLORS["ink"])
    if weapon:
        d.rectangle((24, 12, 25, 26), fill=COLORS["ash"])
        d.rectangle((22, 15, 27, 16), fill=accent)
    save_scaled(im, path)


def portrait(path: Path, base: str, accent: str, motif: str) -> None:
    im = Image.new("RGB", (64, 64), COLORS["ink"])
    d = ImageDraw.Draw(im)
    d.rectangle((2, 2, 61, 61), outline=COLORS["violet"], width=2)
    d.polygon([(17, 14), (46, 14), (52, 33), (43, 54), (20, 54), (11, 33)], fill=base)
    d.rectangle((19, 18, 44, 37), fill=COLORS["ash"])
    d.rectangle((23, 25, 27, 28), fill=COLORS["ink"])
    d.rectangle((36, 25, 40, 28), fill=COLORS["ink"])
    d.rectangle((27, 39, 37, 41), fill=accent)
    if motif == "bell":
        d.arc((23, 42, 40, 58), 190, 350, fill=COLORS["gold"], width=2)
    elif motif == "map":
        d.line((8, 50, 20, 43, 31, 51, 48, 43, 57, 49), fill=COLORS["cyan"], width=2)
    elif motif == "forge":
        d.rectangle((8, 47, 15, 57), fill=COLORS["amber"])
    elif motif == "ink":
        d.line((9, 53, 54, 44), fill=COLORS["blue"], width=2)
    elif motif == "moth":
        d.polygon([(9, 48), (20, 42), (18, 54)], fill=COLORS["ash"])
        d.polygon([(55, 48), (44, 42), (46, 54)], fill=COLORS["ash"])
    save_scaled(im, path, 2)


def panorama(path: Path) -> None:
    im = Image.new("RGB", (240, 136), COLORS["ink"])
    d = ImageDraw.Draw(im)
    for y in range(136):
        if y < 70:
            color = (9 + y // 10, 8 + y // 12, 18 + y // 3)
            d.line((0, y, 239, y), fill=color)
    # fractured moon and veil
    d.ellipse((154, 11, 193, 50), fill=COLORS["ash"])
    d.polygon([(173, 8), (168, 27), (178, 31), (169, 51), (184, 34), (177, 27)], fill=COLORS["violet"])
    for x in (26, 58, 203, 220):
        d.line((x, 15, x - 8, 76), fill=COLORS["blue"], width=1)
    # distant ruined city
    for x, h in [(0, 19), (13, 26), (29, 15), (194, 18), (208, 30), (226, 21)]:
        d.rectangle((x, 92 - h, x + 13, 94), fill=COLORS["deep"])
        d.rectangle((x + 4, 79 - h // 2, x + 5, 81 - h // 2), fill=COLORS["amber"])
    # living spire silhouette
    d.polygon([(120, 7), (113, 30), (116, 43), (104, 63), (109, 78), (94, 101), (146, 101), (131, 77), (136, 61), (124, 42), (127, 29)], fill="#0e0c1c")
    d.polygon([(120, 10), (118, 35), (121, 50), (116, 68), (121, 95)], fill=COLORS["amber"])
    d.line((121, 15, 110, 34, 126, 49, 109, 67, 132, 87), fill=COLORS["violet"], width=2)
    # foreground cliffs and warden
    d.polygon([(0, 103), (40, 96), (77, 109), (116, 101), (161, 107), (201, 97), (239, 104), (239, 135), (0, 135)], fill="#0c0a16")
    d.rectangle((53, 96, 57, 113), fill=COLORS["ash"])
    d.polygon([(55, 87), (49, 99), (61, 99)], fill=COLORS["violet"])
    d.rectangle((58, 94, 59, 108), fill=COLORS["amber"])
    # ash particles
    for i in range(70):
        x = (i * 47 + 13) % 240
        y = (i * 29 + 17) % 110
        d.point((x, y), fill=COLORS["ash"] if i % 5 == 0 else COLORS["blue"])
    save_scaled(im, path, 4)


def tiles(path: Path) -> None:
    im = Image.new("RGB", (256, 256), COLORS["ink"])
    d = ImageDraw.Draw(im)
    for ty in range(8):
        for tx in range(8):
            x, y = tx * 32, ty * 32
            base = COLORS["deep"] if (tx + ty) % 2 else COLORS["violet"]
            d.rectangle((x, y, x + 31, y + 31), fill=base)
            d.line((x, y + 31, x + 31, y + 31), fill=COLORS["ink"])
            d.point((x + 5 + tx * 3 % 20, y + 7 + ty * 5 % 18), fill=COLORS["blue"])
    save_scaled(im, path)


def icon(path: Path) -> None:
    im = Image.new("RGBA", (64, 64), COLORS["ink"])
    d = ImageDraw.Draw(im)
    d.rectangle((3, 3, 60, 60), outline=COLORS["violet"], width=3)
    d.polygon([(32, 7), (24, 27), (27, 35), (18, 54), (46, 54), (37, 35), (40, 26)], fill=COLORS["ash"])
    d.line((32, 10, 31, 52), fill=COLORS["amber"], width=3)
    save_scaled(im, path)


def item(path: Path) -> None:
    im = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    d.polygon([(15, 3), (19, 7), (17, 22), (13, 22), (11, 7)], fill=COLORS["cyan"])
    d.rectangle((10, 22, 20, 24), fill=COLORS["gold"])
    d.rectangle((14, 24, 16, 29), fill=COLORS["ash"])
    save_scaled(im, path)


def main() -> None:
    panorama(ROOT / "assets/lore_art/shattered_spire_panorama.png")
    actor(ROOT / "assets/sprites/actors/warden.png", COLORS["violet"], COLORS["amber"], COLORS["ash"])
    actor(ROOT / "assets/sprites/actors/caedmon.png", COLORS["blood"], COLORS["gold"], COLORS["gold"])
    actor(ROOT / "assets/sprites/actors/ash_hound.png", COLORS["deep"], COLORS["cyan"], COLORS["violet"], False)
    actor(ROOT / "assets/sprites/actors/bell_acolyte.png", COLORS["blue"], COLORS["amber"], COLORS["ash"])
    item(ROOT / "assets/sprites/items/echo_shard.png")
    tiles(ROOT / "assets/tilesets/ashen_narthex.png")
    icon(ROOT / "assets/ui/icons/game_icon.png")
    portrait(ROOT / "assets/portraits/maelin.png", COLORS["violet"], COLORS["gold"], "bell")
    portrait(ROOT / "assets/portraits/ilyra.png", COLORS["blue"], COLORS["cyan"], "map")
    portrait(ROOT / "assets/portraits/vey.png", COLORS["blood"], COLORS["amber"], "forge")
    portrait(ROOT / "assets/portraits/oryn.png", COLORS["deep"], COLORS["blue"], "ink")
    portrait(ROOT / "assets/portraits/moth.png", COLORS["ink"], COLORS["ash"], "moth")


if __name__ == "__main__":
    main()
