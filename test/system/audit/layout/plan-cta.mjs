// Pricing plans: the CTA buttons of plans in one row end on the same line (tolerance 1px), and no row holds a single
// plan beside empty columns (the grid stacks instead). Checked at 600, 720 and 1024px.
export const PLAN_WIDTHS = [600, 720, 1024];
export function planFaults() {
  const out = [];
  for (const grid of document.querySelectorAll(".mt-plans")) {
    const plans = [...grid.children].filter((p) => p.offsetParent);
    const rows = [];
    for (const p of plans) {
      const r = p.getBoundingClientRect();
      const row = rows.find((x) => Math.abs(x.top - r.top) < 1);
      if (row) row.items.push(p); else rows.push({ top: r.top, items: [p] });
    }
    const cols = getComputedStyle(grid).gridTemplateColumns.split(" ").length;
    for (const row of rows) {
      const ends = row.items.map((p) => p.querySelector(".mt-actions > a")).filter(Boolean).map((a) => a.getBoundingClientRect().bottom);
      if (ends.length > 1 && Math.max(...ends) - Math.min(...ends) > 1) out.push(`plan buttons end ${(Math.max(...ends) - Math.min(...ends)).toFixed(1)}px apart`);
      if (cols > 1 && row.items.length === 1) out.push(`a row holds one plan beside ${cols - 1} empty column(s)`);
    }
  }
  return [...new Set(out)];
}
export async function checkPlanCta(page, scheme, url, fails) {
  for (const w of PLAN_WIDTHS) {
    await page.setViewportSize({ width: w, height: 900 });
    const bad = await page.evaluate(`(${planFaults})()`);
    for (const b of bad) fails.push(`pricing: ${b} at ${w}px ${scheme} ${url}`);
  }
  await page.setViewportSize({ width: 1024, height: 900 });
}
