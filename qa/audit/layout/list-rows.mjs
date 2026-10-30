// List rows: items of a flex or grid list (contents, letter index, link rows) laid out on one line must share the
// same top edge (tolerance 0.5px), so a stacked-list rule such as `li + li { margin-top }` cannot nudge one item off.
export const LIST_WIDTHS = [360, 1280];
const TOL = 0.5;
export function listRowFaults(tol = TOL) {
  const out = [];
  for (const list of document.querySelectorAll("ul, ol")) {
    const cs = getComputedStyle(list);
    if (!/flex|grid/.test(cs.display) || cs.flexDirection.startsWith("column")) continue;
    const rs = [...list.children].filter((li) => li.tagName === "LI" && li.offsetParent).map((li) => li.getBoundingClientRect());
    const rows = [];
    for (const r of rs) {
      const row = rows.find((x) => r.top < x.bottom && r.bottom > x.top);
      if (row) row.tops.push(r.top); else rows.push({ top: r.top, bottom: r.bottom, tops: [r.top] });
    }
    for (const row of rows) {
      const d = Math.max(...row.tops) - Math.min(...row.tops);
      if (d > tol) out.push(`${list.parentElement.className || list.parentElement.tagName} > ${list.tagName.toLowerCase()} items off by ${d.toFixed(2)}px`);
    }
  }
  return [...new Set(out)];
}
export async function checkListRows(page, scheme, url, fails) {
  for (const w of LIST_WIDTHS) {
    await page.setViewportSize({ width: w, height: 900 });
    const bad = await page.evaluate(`(${listRowFaults})(${TOL})`);
    for (const b of bad) fails.push(`list row misaligned (${b}) at ${w}px ${scheme} ${url}`);
  }
  await page.setViewportSize({ width: 1024, height: 900 });
}
