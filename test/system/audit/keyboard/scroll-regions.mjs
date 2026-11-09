// Scrolling code blocks and tables are focusable labelled regions at 360px. Content of a closed details is skipped:
// Chromium still measures it, but no resize is reported there until it opens, and the reader cannot reach it.
export async function scrollRegions(page, url, fails) {
  await page.setViewportSize({ width: 360, height: 800 });
  await page.goto(url, { waitUntil: "networkidle" });
  const bad = await page.evaluate(() => [...document.querySelectorAll(".mt-main pre, .mt-main .mt-table")]
    .filter((e) => e.checkVisibility() && e.scrollWidth > e.clientWidth + 1 && !(e.tabIndex === 0 && e.getAttribute("aria-label")))
    .map((e) => (e.textContent.trim().split("\n")[0] || e.className).slice(0, 40)));
  if (bad.length) fails.push(`keyboard: ${bad.length} scrolling code blocks/tables are not focusable labelled regions at 360px ${url} (${bad.join(" | ")})`);
  await page.setViewportSize({ width: 1024, height: 900 });
}
