// Column alignment and measure: the page meta line and the pager start where the text column (.mt-doc-main) starts, with and
// without the doc sidebar, at 1024 and 1440px (the inline start edge: left in LTR, right in RTL).
export const ALIGN_WIDTHS = [1024, 1440];
export const ALIGN_PAGES = ["guides/configuration/", "components/kitchen-sink/", "layouts/demo/wide/"];
export function columnOffsets() {
  const main = document.querySelector(".mt-doc-main");
  if (!main) {
    return [];
  }
  const rtl = getComputedStyle(main).direction === "rtl";
  const edge = (e) => {
    const r = e.getBoundingClientRect();
    return rtl ? r.right : r.left;
  };
  const start = edge(main);
  return [...document.querySelectorAll(".mt-main > .mt-page-meta, .mt-main > .mt-pagination")]
    .filter((e) => e.offsetParent)
    .map((e) => [e.className.split(" ")[0], Math.round(edge(e) - start)]);
}
export async function checkColumnAlign(page, scheme, url, fails) {
  for (const w of ALIGN_WIDTHS) {
    await page.setViewportSize({ width: w, height: 900 });
    const offs = await page.evaluate(`(${columnOffsets})()`);
    for (const [name, off] of offs) {
      if (Math.abs(off) > 1) {
        fails.push(`column align: .${name} starts ${off}px from the text column at ${w}px ${scheme} ${url}`);
      }
    }
  }
  await page.setViewportSize({ width: 1024, height: 900 });
}

// Measure: on wide layouts running text stops at the measure token (45rem), so no paragraph or plain list item in main is
// wider than that at 1440px (about 90 Latin characters a line).
export const MEASURE_PAGES = ["layouts/detail/project/", "layouts/directory/events/", "layouts/demo/search/", "layouts/docs-extra/api/"];
export function wideText() {
  const rem = parseFloat(getComputedStyle(document.documentElement).fontSize);
  const max = Math.round(parseFloat(getComputedStyle(document.documentElement).getPropertyValue("--mt-measure")) * rem) || 45 * rem;
  return [...document.querySelectorAll(".mt-main :is(p, ul:not([class]) > li, ol:not([class]) > li)")]
    .filter((e) => e.offsetParent && !e.closest("table, .mt-hero, .mt-dir-grid, .mt-plans, footer") && e.getBoundingClientRect().width > max + 1)
    .map((e) => `${e.tagName.toLowerCase()} "${e.textContent.trim().slice(0, 30)}" is ${Math.round(e.getBoundingClientRect().width)}px`);
}
export async function checkMeasure(page, scheme, url, fails) {
  await page.setViewportSize({ width: 1440, height: 900 });
  const bad = await page.evaluate(`(${wideText})()`);
  for (const b of bad.slice(0, 3)) {
    fails.push(`measure: ${b}, wider than the measure at 1440px ${scheme} ${url}`);
  }
  await page.setViewportSize({ width: 1024, height: 900 });
}
