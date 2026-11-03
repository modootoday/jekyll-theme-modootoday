// CJK clip: on the Korean and Japanese home pages at 360px no heading or paragraph of the hero is wider than its box,
// so a line that cannot break (keep-all on a long word) is never cut off by the hero's overflow clip.
export const CJK_CLIP_WIDTH = 360;
export function clippedHeroText() {
  return [...document.querySelectorAll(".mt-hero :is(h1, p)")]
    .filter((e) => e.scrollWidth > e.clientWidth + 1)
    .map((e) => `${e.tagName.toLowerCase()} ${e.scrollWidth}>${e.clientWidth}`);
}
export async function checkCjkClip(page, scheme, url, fails) {
  await page.setViewportSize({ width: CJK_CLIP_WIDTH, height: 900 });
  const bad = await page.evaluate(`(${clippedHeroText})()`);
  for (const b of bad) fails.push(`cjk clip: hero ${b} at ${CJK_CLIP_WIDTH}px ${scheme} ${url}`);
  await page.setViewportSize({ width: 1024, height: 900 });
}
