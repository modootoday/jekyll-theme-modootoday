// Table reflow at phone widths: every body table sits in div.mt-table; 2-3 column tables keep their column floors (5rem,
// the last 9rem) and show the last column up to 9rem before any scrolling; first-column code never breaks; 4+ column tables
// keep a sticky first column and no cell over 6 lines; a scrolling wrapper is a labelled region; a stacked table fits.
export const REFLOW_WIDTHS = [320, 360, 390];
export const REFLOW_PAGES = ["guides/configuration/", "components/", "components/kitchen-sink/", "components/kitchen-sink-rtl/", "layouts/detail/", "layouts/blog-news/", "reference/api/"];

export function tableProblems() {
  const rem = parseFloat(getComputedStyle(document.documentElement).fontSize);
  const out = [];
  const lines = (e) => Math.round(e.getBoundingClientRect().height / parseFloat(getComputedStyle(e).lineHeight || "20"));
  [...document.querySelectorAll(".mt-main table")].forEach((t, i) => {
    const w = t.parentElement;
    const name = `table ${i + 1}`;
    if (!w.matches(".mt-table")) {
      out.push(`${name} has no .mt-table wrapper`);
      return;
    }
    if (w.scrollWidth > w.clientWidth + 1 && !(w.tabIndex === 0 && w.getAttribute("role") === "region" && w.getAttribute("aria-label"))) {
      out.push(`${name} scrolls but is not a focusable labelled region`);
    }
    if (t.hasAttribute("data-mt-labelled") && getComputedStyle(t).display === "block") {
      if (t.matches(".mt-table--stack") && [...t.querySelectorAll("tbody td")].some((c) => !c.dataset.label)) {
        out.push(`${name} is stacked with an unlabelled cell`);
      }
      if (t.getAttribute("role") !== "table") {
        out.push(`${name} is stacked without role=table`);
      }
      if (w.scrollWidth > w.clientWidth + 1) {
        out.push(`${name} is stacked but still scrolls sideways`);
      }
      return;
    }
    for (const code of t.querySelectorAll("td:first-child code")) {
      if (code.getClientRects().length > 1) {
        out.push(`${name} breaks first-column code "${code.textContent.slice(0, 24)}"`);
      }
    }
    const wide = !!t.querySelector("th:nth-child(4)");
    const last = t.querySelector("tr > :last-child");
    if (!wide && last) {
      const [c, b] = [last.getBoundingClientRect(), w.getBoundingClientRect()];
      const shown = Math.max(0, Math.min(c.right, b.right) - Math.max(c.left, b.left));
      if (shown < Math.min(c.width, 9 * rem) - 1) {
        out.push(`${name} shows ${Math.round(shown)}px of its last column before scrolling`);
      }
    }
    for (const row of t.tBodies[0] ? t.tBodies[0].rows : []) {
      [...row.cells].forEach((c, k) => {
        const width = c.getBoundingClientRect().width;
        const floor = k === row.cells.length - 1 ? 9 : 5;
        if (!wide && k > 0 && c.tagName === "TD" && width < floor * rem - 1) {
          out.push(`${name} column ${k + 1} is ${Math.round(width)}px, under its ${floor}rem floor`);
        }
        if (wide && lines(c) > 6) {
          out.push(`${name} column ${k + 1} has a ${lines(c)}-line cell`);
        }
      });
    }
    if (wide && getComputedStyle(t.querySelector("th")).position !== "sticky") {
      out.push(`${name} has 4+ columns but no sticky first column`);
    }
  });
  return [...new Set(out)];
}

export async function checkTableReflow(page, scheme, url, fails) {
  for (const w of REFLOW_WIDTHS) {
    await page.setViewportSize({ width: w, height: 900 });
    // scroll-region.js labels wrappers from a ResizeObserver callback.
    await page.waitForTimeout(100);
    const bad = await page.evaluate(`(${tableProblems})()`);
    for (const b of bad) {
      fails.push(`table reflow: ${b} at ${w}px ${scheme} ${url}`);
    }
  }
  await page.setViewportSize({ width: 1024, height: 900 });
}
