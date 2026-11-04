// Components page: every example card (a section holding a Result label) must share text-align and background.
// Component box styles (e.g. the c: cta frame) belong on the result container, never on the whole card.
export async function checkExampleCards(page, scheme, url, fails) {
  const cards = await page.evaluate(() => [...document.querySelectorAll("section.mt-section")].filter((s) => s.querySelector(":scope > .docs-ex-result"))
    .map((s) => { const c = getComputedStyle(s); return { n: s.dataset.section, k: `${c.textAlign}|${c.backgroundImage}|${c.backgroundColor}` }; }));
  const base = cards[0] && cards[0].k;
  for (const c of cards) if (c.k !== base) fails.push(`example card ${c.n} styled differently (${c.k} vs ${base}) ${scheme} ${url}`);
  if (cards.length < 10) fails.push(`only ${cards.length} example cards found ${scheme} ${url}`);
}

// Card grids (features, link cards): no card narrower than its grid's floor where the section is wider than the floor,
// so a row never ends in one cramped card or leaves a lone narrow column. Floors in rem, by grid.
export const GRID_WIDTHS = [720, 1024, 1440];
export const GRID_FLOORS = { ".mt-c-features > ul": 16, ".mt-c-linkcards > ul": 16 };
export function narrowCards(floors) {
  const rem = parseFloat(getComputedStyle(document.documentElement).fontSize);
  const out = [];
  for (const [sel, floor] of Object.entries(floors)) {
    for (const grid of document.querySelectorAll(sel)) {
      const min = Math.min(grid.clientWidth, floor * rem) - 1;
      const narrow = [...grid.children].filter((c) => c.offsetParent && c.getBoundingClientRect().width < min);
      if (narrow.length) out.push(`${sel} has ${narrow.length} card(s) under ${floor}rem`);
    }
  }
  return [...new Set(out)];
}
export async function checkCardGrid(page, scheme, url, fails) {
  for (const w of GRID_WIDTHS) {
    await page.setViewportSize({ width: w, height: 900 });
    const bad = await page.evaluate(`(${narrowCards})(${JSON.stringify(GRID_FLOORS)})`);
    for (const b of bad) fails.push(`card grid: ${b} at ${w}px ${scheme} ${url}`);
  }
  await page.setViewportSize({ width: 1024, height: 900 });
}
