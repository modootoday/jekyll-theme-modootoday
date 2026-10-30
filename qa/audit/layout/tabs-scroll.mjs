// Tabs: no tablist, tab, tabpanel or tabs wrapper may show a vertical scrollbar (overflow-y auto/scroll with taller content).
// Checked at 360/768/1280 with every tab focused, so focus rings and wrapped labels are covered.
export const TAB_WIDTHS = [360, 768, 1280];
export async function checkTabsScroll(page, scheme, url, fails) {
  for (const w of TAB_WIDTHS) {
    await page.setViewportSize({ width: w, height: 900 });
    const bad = await page.evaluate(async () => {
      const out = [];
      const scan = () => document.querySelectorAll('[role="tablist"],[role="tab"],[role="tabpanel"],.mt-c-tabs,[data-section="tabs"]').forEach((e) => {
        const oy = getComputedStyle(e).overflowY;
        if ((oy === "auto" || oy === "scroll") && e.scrollHeight > e.clientHeight + 0) out.push(`${e.getAttribute("role") || e.className} ${e.scrollHeight}>${e.clientHeight}`);
      });
      scan();
      for (const t of document.querySelectorAll('[role="tab"]')) { t.focus(); t.click(); scan(); }
      return [...new Set(out)];
    });
    for (const b of bad) fails.push(`tabs vertical scrollbar (${b}) at ${w}px ${scheme} ${url}`);
  }
  await page.setViewportSize({ width: 1024, height: 900 });
}
