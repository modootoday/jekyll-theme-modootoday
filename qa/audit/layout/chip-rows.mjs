// Chip rows: sibling badges/chips in one list (archive index, post footer terms, any flex row of .mt-badge)
// must share bounding-box height and vertical centre (tolerance 0.5px). Checked at 360/768/1280.
export const CHIP_WIDTHS = [360, 768, 1280];
const TOL = 0.5;
export async function checkChipRows(page, scheme, url, fails) {
  for (const w of CHIP_WIDTHS) {
    await page.setViewportSize({ width: w, height: 900 });
    const bad = await page.evaluate((tol) => {
      const out = [], groups = new Map();
      for (const b of document.querySelectorAll(".mt-badge")) {
        const host = b.closest("ul,ol,p,div,nav") || b.parentElement;
        if (!groups.has(host)) groups.set(host, []);
        groups.get(host).push(b.getBoundingClientRect());
      }
      for (const [host, rs] of groups) {
        if (rs.length < 2) continue;
        const rows = [];
        for (const r of rs) {
          const c = r.top + r.height / 2;
          const row = rows.find((x) => Math.abs(x.c - c) < r.height / 2 + 2);
          if (row) row.items.push(r); else rows.push({ c, items: [r] });
        }
        const h0 = rs[0].height;
        if (rs.some((r) => Math.abs(r.height - h0) > tol)) out.push(`${host.className || host.tagName} heights differ`);
        for (const row of rows) {
          const cs = row.items.map((r) => r.top + r.height / 2);
          if (Math.max(...cs) - Math.min(...cs) > tol) out.push(`${host.className || host.tagName} centres differ by ${(Math.max(...cs) - Math.min(...cs)).toFixed(2)}px`);
        }
      }
      return [...new Set(out)];
    }, TOL);
    for (const b of bad) fails.push(`chip row misaligned (${b}) at ${w}px ${scheme} ${url}`);
  }
  await page.setViewportSize({ width: 1024, height: 900 });
}
