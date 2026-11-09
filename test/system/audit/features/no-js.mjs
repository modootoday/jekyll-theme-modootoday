// What readers without JavaScript get, and widgets with it: with JavaScript off, every widget shows its fallback, every
// chart its table and every static diagram its image; with it on (strict CSP), a defined widget hides its fallback and
// its controls take keyboard focus.
export const NO_JS_PAGES = ["recipes/figures/widgets/", "components/kitchen-sink/", "recipes/figures/charts/", "recipes/figures/math-diagrams/"];
export const WIDGET_PAGE = "recipes/figures/widgets/";

const shown = () => ({
  widgets: [...document.querySelectorAll(".mt-widget")].map((w) => w.querySelector(":scope > .mt-widget-fallback")?.checkVisibility() === true),
  charts: [...document.querySelectorAll("figure.mt-chart table")].map((t) => t.checkVisibility()),
  diagrams: [...document.querySelectorAll("figure.mt-diagram img")].filter((i) => i.checkVisibility()).map((i) => i.complete && i.naturalWidth > 0),
});

const defined = () => [...document.querySelectorAll(".mt-widget")].map((w) => ({
  defined: w.matches(":defined"), fallback: w.querySelector(":scope > .mt-widget-fallback").checkVisibility(),
  control: !!w.querySelector("button"),
}));

// origin: a server that sends the strict CSP header (config.mjs CSP). Returns the rows it measured.
export async function checkNoJs(browser, origin, fails) {
  const rows = {};
  let ctx = await browser.newContext({ javaScriptEnabled: false });
  let page = await ctx.newPage();
  for (const p of NO_JS_PAGES) {
    await page.goto(origin + p, { waitUntil: "load" });
    const r = await page.evaluate(shown);
    rows[p] = r;
    const fail = (what) => fails.push(`no-js /${p}: ${what}`);
    r.widgets.forEach((ok, i) => ok || fail(`widget ${i + 1} hides its fallback`));
    r.charts.forEach((ok, i) => ok || fail(`chart ${i + 1} hides its table`));
    r.diagrams.forEach((ok, i) => ok || fail(`diagram image ${i + 1} is not shown`));
  }
  if (!rows[WIDGET_PAGE].widgets.length) fails.push(`no-js /${WIDGET_PAGE}: no widget`);
  await ctx.close();
  ctx = await browser.newContext();
  page = await ctx.newPage();
  await page.goto(origin + WIDGET_PAGE, { waitUntil: "networkidle" });
  rows.defined = await page.evaluate(defined);
  rows.defined.forEach((w, i) => {
    if (!w.defined || w.fallback || !w.control) fails.push(`widget /${WIDGET_PAGE}: widget ${i + 1} ${JSON.stringify(w)}`);
  });
  await page.evaluate(() => {
    const before = document.querySelector(".mt-widget").previousElementSibling;
    before.tabIndex = -1;
    before.focus();
  });
  await page.keyboard.press("Tab");
  rows.focus = await page.evaluate(() => document.activeElement.matches(".mt-widget button:focus-visible"));
  if (!rows.focus) fails.push(`widget /${WIDGET_PAGE}: Tab from the text before it does not reach its control with a visible focus`);
  await ctx.close();
  return rows;
}
