#!/usr/bin/env python3
"""Browser QA for the static GitHub Pages surface."""
import asyncio
import os
from pathlib import Path
from playwright.async_api import async_playwright

ROOT = Path(__file__).resolve().parents[2]
URL = "http://127.0.0.1:4173"
OUTPUT_DIR = Path(os.environ.get("QA_OUTPUT_DIR", "/tmp/eotsv-site-qa"))
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

async def audit(page, label: str) -> None:
    errors: list[str] = []
    page.on("console", lambda msg: errors.append(msg.text) if msg.type == "error" else None)
    await page.goto(URL, wait_until="networkidle")
    assert await page.title() == "Echoes of the Shattered Veil · 破碎帷幕的回响"
    assert await page.locator("h1").count() == 1
    assert await page.locator("main section").count() >= 7
    image_state = await page.locator("img").evaluate_all("imgs => imgs.map(i => ({src:i.src, ok:i.complete && i.naturalWidth>0, alt:i.getAttribute('alt')}))")
    assert all(item["ok"] for item in image_state), image_state
    assert all(item["alt"] is not None for item in image_state), image_state
    dimensions = await page.evaluate("({scroll:document.documentElement.scrollWidth, client:document.documentElement.clientWidth})")
    assert dimensions["scroll"] <= dimensions["client"], dimensions
    assert await page.locator('a[href="https://github.com/emptysuns/echoes-of-the-shattered-veil/releases/latest"]').count() >= 2
    await page.locator(".language-toggle").click()
    assert "Every death" in await page.locator("#loop h2").inner_text()
    nav_link = page.locator('a[href="#world"]')
    if await nav_link.is_visible():
        await nav_link.click()
    else:
        await page.locator("#world").scroll_into_view_if_needed()
    assert await page.locator("#world").is_visible()
    await page.screenshot(path=str(OUTPUT_DIR / f"site-{label}.png"), full_page=True)
    assert not errors, errors

async def main() -> None:
    async with async_playwright() as p:
        browser = await p.chromium.launch(executable_path="/usr/bin/chromium", headless=True, args=["--no-sandbox"])
        desktop = await browser.new_page(viewport={"width": 1440, "height": 1000}, device_scale_factor=1)
        await audit(desktop, "desktop")
        mobile = await browser.new_page(viewport={"width": 390, "height": 844}, device_scale_factor=1, is_mobile=True)
        await audit(mobile, "mobile")
        await browser.close()
    print("Site QA passed: desktop/mobile, language toggle, images, links, sections, and overflow.")

if __name__ == "__main__":
    asyncio.run(main())
