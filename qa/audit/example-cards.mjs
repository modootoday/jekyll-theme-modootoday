// Components page: every example card (a section holding a Result label) must share text-align and background.
// Component box styles (e.g. the c: cta frame) belong on the result container, never on the whole card.
export async function checkExampleCards(page, scheme, url, fails) {
  const cards = await page.evaluate(() => [...document.querySelectorAll("section.mt-section")].filter((s) => s.querySelector(":scope > .docs-ex-result"))
    .map((s) => { const c = getComputedStyle(s); return { n: s.dataset.section, k: `${c.textAlign}|${c.backgroundImage}|${c.backgroundColor}` }; }));
  const base = cards[0] && cards[0].k;
  for (const c of cards) if (c.k !== base) fails.push(`example card ${c.n} styled differently (${c.k} vs ${base}) ${scheme} ${url}`);
  if (cards.length < 10) fails.push(`only ${cards.length} example cards found ${scheme} ${url}`);
}
