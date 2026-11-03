// Header end: the trailing controls (language menu, theme toggle) sit at the inline end of the header row on a site
// without search (and with no language menu either), in LTR and RTL; a gap there means only .mt-search pushed them.
export const HEADER_WIDTHS = [1440, 390];
export function headerEndGap(strip) {
  const h = document.querySelector(".mt-header-inner");
  for (const s of strip) h.querySelector(s)?.remove();
  const cs = getComputedStyle(h), r = h.getBoundingClientRect(), rtl = cs.direction === "rtl";
  const last = [...h.children].filter((e) => e.offsetParent && e.matches(".mt-search, .mt-lang, .mt-theme-toggle")).at(-1);
  if (!last) return 0;
  const q = last.getBoundingClientRect();
  return rtl ? q.left - (r.left + parseFloat(cs.paddingLeft)) : r.right - parseFloat(cs.paddingRight) - q.right;
}
export async function checkHeaderEnd(page, scheme, url, fails) {
  for (const w of HEADER_WIDTHS) for (const strip of [[".mt-search"], [".mt-search", "details.mt-lang"]]) {
    await page.setViewportSize({ width: w, height: 900 });
    await page.goto(url);
    const gap = await page.evaluate(`(${headerEndGap})(${JSON.stringify(strip)})`);
    if (Math.abs(gap) > 1) fails.push(`header end: controls ${Math.round(gap)}px from the inline end without ${strip.join(" and ")} at ${w}px ${scheme} ${url}`);
  }
  await page.setViewportSize({ width: 1024, height: 900 });
  await page.goto(url);
}
// Header height: one row of --mt-header-height (plus the top safe area and the 1px rule) at every width and layout.
export const HEIGHT_WIDTHS = [360, 768, 1024, 1440];
export function headerHeightOff() {
  const h = document.querySelector(".mt-header");
  if (!h) return 0;
  const cs = getComputedStyle(h);
  const row = parseFloat(getComputedStyle(document.documentElement).fontSize) * 4;
  const want = row + parseFloat(cs.paddingTop) + parseFloat(cs.borderBottomWidth);
  return h.getBoundingClientRect().height - want;
}
export async function checkHeaderHeight(page, scheme, url, fails) {
  for (const w of HEIGHT_WIDTHS) {
    await page.setViewportSize({ width: w, height: 900 });
    const off = await page.evaluate(`(${headerHeightOff})()`);
    if (Math.abs(off) > 1) fails.push(`header height: ${Math.round(off)}px off one 4rem row at ${w}px ${scheme} ${url}`);
  }
  await page.setViewportSize({ width: 1024, height: 900 });
}
