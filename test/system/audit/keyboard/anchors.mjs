// Heading anchors (modootoday.heading_anchors): hidden until the heading is hovered or the link has keyboard focus,
// then shown with a ring; Enter moves to the heading. Component sections keep their headings without a link.
export async function headingAnchors(page, url, fails) {
  await page.goto(url, { waitUntil: "networkidle" });
  const link = page.locator(".mt-section:not([data-c]) h2 > a.mt-anchor").first();
  if (!(await link.count())) {
    fails.push(`keyboard: no heading anchor ${url}`);
    return;
  }
  const inComponents = await page.locator(".mt-section[data-c] a.mt-anchor").count();
  if (inComponents) fails.push(`keyboard: ${inComponents} heading anchors inside component sections ${url}`);
  const hidden = await link.evaluate((a) => getComputedStyle(a).opacity);
  if (hidden !== "0") fails.push(`keyboard: a heading anchor shows before hover or focus (opacity ${hidden}) ${url}`);
  await page.keyboard.press("Tab");
  await link.focus();
  const r = await link.evaluate((a) => {
    const s = getComputedStyle(a);
    const box = a.getBoundingClientRect();
    return { opacity: s.opacity, ring: s.outlineStyle !== "none" && parseFloat(s.outlineWidth) >= 2, w: box.width, h: box.height, id: a.parentElement.id };
  });
  if (r.opacity !== "1") fails.push(`keyboard: a focused heading anchor is not shown (opacity ${r.opacity}) ${url}`);
  if (!r.ring) fails.push(`keyboard: a focused heading anchor has no visible ring ${url}`);
  if (r.w < 24 || r.h < 24) fails.push(`keyboard: a heading anchor target is ${r.w}x${r.h}px, under 24px ${url}`);
  await page.keyboard.press("Enter");
  const hash = await page.evaluate(() => decodeURIComponent(location.hash.slice(1)));
  if (hash !== r.id) fails.push(`keyboard: Enter on a heading anchor went to #${hash}, not #${r.id} ${url}`);
}
