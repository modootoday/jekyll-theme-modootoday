// Focus flows: a visible ring on every Tab stop, the skip link, and a TOC ring that stays inside its column.
const ring = () => {
  const e = document.activeElement; if (!e || e === document.body) return null;
  const s = getComputedStyle(e), r = e.getBoundingClientRect();
  const visible = (s.outlineStyle !== "none" && parseFloat(s.outlineWidth) >= 2) || (s.boxShadow !== "none" && s.boxShadow !== "");
  return { tag: e.tagName + (e.className ? "." + String(e.className).split(" ")[0] : ""), visible, inView: r.width > 0 && r.height > 0 };
};

export async function tabWalk(page, url, fails, max = 80) {
  await page.goto(url, { waitUntil: "networkidle" });
  await page.keyboard.press("Tab");
  const first = await page.evaluate(() => document.activeElement.className);
  if (first !== "mt-skip") fails.push(`keyboard: first Tab stop is .${first}, not the skip link, ${url}`);
  const seen = new Set();
  for (let i = 0; i < max; i++) {
    const r = await page.evaluate(ring);
    if (!r) break;
    // Focus inside an embed frame belongs to the framed document (its own focus styles); the parent cannot style it.
    if (!r.visible && !seen.has(r.tag) && !r.tag.startsWith("IFRAME")) { seen.add(r.tag); fails.push(`keyboard: no visible focus ring on ${r.tag} ${url}`); }
    await page.keyboard.press("Tab");
  }
}

export async function skipLink(page, url, fails) {
  await page.goto(url, { waitUntil: "networkidle" });
  await page.keyboard.press("Tab");
  const shown = await page.evaluate(() => document.activeElement.getBoundingClientRect().left >= 0);
  await page.keyboard.press("Enter");
  const id = await page.evaluate(() => document.activeElement.id);
  if (!shown) fails.push(`keyboard: skip link not on screen when focused ${url}`);
  if (id !== "mt-main") fails.push(`keyboard: skip link does not move focus to main (${id}) ${url}`);
}

// The sticky TOC scrolls, so a focus ring drawn outside a link would be clipped by the column.
export async function tocRing(page, url, fails) {
  await page.setViewportSize({ width: 1440, height: 900 });
  await page.goto(url, { waitUntil: "networkidle" });
  const link = page.locator(".mt-doc-aside .mt-toc a").first();
  if (!(await link.count())) {
    fails.push(`keyboard: no TOC column at 1440px ${url}`);
    await page.setViewportSize({ width: 1024, height: 900 });
    return;
  }
  await page.keyboard.press("Tab");
  await link.focus();
  const out = await link.evaluate((a) => {
    const s = getComputedStyle(a);
    const grow = parseFloat(s.outlineWidth) + parseFloat(s.outlineOffset);
    const r = a.getBoundingClientRect();
    const c = a.closest(".mt-toc").getBoundingClientRect();
    return Math.max(c.left - (r.left - grow), r.right + grow - c.right);
  });
  if (out > 0.5) fails.push(`keyboard: the TOC focus ring reaches ${out}px outside the column ${url}`);
  await page.setViewportSize({ width: 1024, height: 900 });
}
