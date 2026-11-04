// Anchor offset: after a jump to the last h2 of a long page, the heading's top is below the sticky header, at a
// phone and a desktop width (scroll-padding-top is the only offset; headings carry no scroll-margin).
export const ANCHOR_WIDTHS = [360, 1440];
export function anchorGap() {
  const hs = [...document.querySelectorAll(".mt-main h2[id]")];
  const target = hs.at(-1);
  if (!target) {
    return null;
  }
  target.scrollIntoView();
  const header = document.querySelector(".mt-header");
  const bottom = header ? header.getBoundingClientRect().bottom : 0;
  return target.getBoundingClientRect().top - bottom;
}
export async function checkAnchorOffset(page, scheme, url, fails) {
  for (const w of ANCHOR_WIDTHS) {
    await page.setViewportSize({ width: w, height: 900 });
    const gap = await page.evaluate(`(${anchorGap})()`);
    if (gap === null) {
      fails.push(`anchor offset: no h2 with an id at ${w}px ${scheme} ${url}`);
      continue;
    }
    if (gap < 0) {
      fails.push(`anchor offset: last h2 ${Math.round(-gap)}px under the header at ${w}px ${scheme} ${url}`);
    }
  }
  await page.setViewportSize({ width: 1024, height: 900 });
  await page.evaluate(() => window.scrollTo(0, 0));
}
