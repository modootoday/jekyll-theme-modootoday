// Scrolling code blocks and tables are focusable labelled regions at 360px.
export async function scrollRegions(page, url, fails) {
  await page.setViewportSize({ width: 360, height: 800 });
  await page.goto(url, { waitUntil: "networkidle" });
  const bad = await page.evaluate(() => [...document.querySelectorAll(".mt-main pre, .mt-main table")]
    .filter((e) => e.scrollWidth > e.clientWidth + 1 && !(e.tabIndex === 0 && e.getAttribute("aria-label"))).length);
  if (bad) fails.push(`keyboard: ${bad} scrolling code blocks/tables are not focusable labelled regions at 360px ${url}`);
  await page.setViewportSize({ width: 1024, height: 900 });
}
