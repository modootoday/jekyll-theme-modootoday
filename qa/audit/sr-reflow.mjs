// WCAG 1.4.10 reflow (320 CSS px), 1.4.4 200% text, 1.4.12 text spacing: no horizontal overflow outside
// code/table scrollers and no clipped text. Returns problem strings for the loaded page.
const SPACING = "*{line-height:1.5!important;letter-spacing:.12em!important;word-spacing:.16em!important}p{margin-bottom:2em!important}";
async function overflow(page) {
  return page.evaluate(() => document.documentElement.scrollWidth - window.innerWidth);
}
export async function checkReflow(page) {
  const out = [];
  await page.setViewportSize({ width: 320, height: 256 });
  if ((await overflow(page)) > 1) out.push("1.4.10 overflow at 320px");
  await page.setViewportSize({ width: 640, height: 900 });
  await page.evaluate(() => { document.documentElement.style.fontSize = "200%"; });
  if ((await overflow(page)) > 1) out.push("1.4.4 overflow at 200% text (640px)");
  await page.evaluate(() => { document.documentElement.style.fontSize = ""; });
  await page.setViewportSize({ width: 360, height: 900 });
  const tag = await page.addStyleTag({ content: SPACING });
  if ((await overflow(page)) > 1) out.push("1.4.12 overflow with text spacing at 360px");
  const clipped = await page.evaluate(() => [...document.querySelectorAll("button,a,.mt-badge,label")].filter((e) => {
    const s = getComputedStyle(e); return s.overflow === "hidden" && e.scrollHeight > e.clientHeight + 1 && e.clientHeight > 0;
  }).length);
  if (clipped) out.push(`1.4.12 ${clipped} clipped controls with text spacing`);
  await tag.evaluate((n) => n.remove());
  await page.setViewportSize({ width: 1024, height: 900 });
  return out;
}
