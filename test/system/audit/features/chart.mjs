// Charts on recipes/charts/ under the strict CSP: each figure.mt-chart draws a canvas named by its caption (role=img) and
// folds its table into a closed details; hover and a legend click add no violation; the theme toggle redraws with the
// other scheme's colours without a reload; reduced motion turns the animation off; forced colours keep the table.
export const CHART_PAGE = "recipes/charts/";

const watch = () => {
  window.mtCspViolations = [];
  document.addEventListener("securitypolicyviolation", (e) => window.mtCspViolations.push(`${e.effectiveDirective} ${e.blockedURI || "inline"}`));
};

const state = () => [...document.querySelectorAll("figure.mt-chart")].map((f) => {
  const canvas = f.querySelector(".mt-chart-canvas canvas");
  const chart = canvas && window.Chart ? window.Chart.getChart(canvas) : null;
  const data = f.querySelector(".mt-chart-data");
  let painted = 0;
  if (canvas && canvas.width) {
    const px = canvas.getContext("2d").getImageData(0, 0, canvas.width, canvas.height).data;
    for (let i = 3; i < px.length; i += 16) painted += px[i] > 0 ? 1 : 0;
  }
  return {
    role: canvas && canvas.getAttribute("role"), name: canvas && canvas.getAttribute("aria-label"),
    caption: (f.querySelector("figcaption") || { textContent: "" }).textContent.trim(), shown: canvas ? canvas.offsetHeight > 0 : false,
    folded: !!data.querySelector(":scope > details:not([open]) table"), table: data.querySelector("table").checkVisibility(), painted,
    colour: chart ? chart.data.datasets[0].borderColor : null, animation: chart ? chart.options.animation : null,
  };
});

async function open(browser, origin, options) {
  const ctx = await browser.newContext(options);
  await ctx.addInitScript(watch);
  const page = await ctx.newPage();
  await page.goto(origin + CHART_PAGE, { waitUntil: "networkidle" });
  // A chart is drawn as it nears the viewport, so each one is brought into view before the page is measured.
  for (const fig of await page.locator("figure.mt-chart").all()) {
    await fig.scrollIntoViewIfNeeded();
  }
  await page.evaluate(() => window.scrollTo(0, 0));
  await page.waitForTimeout(1200);
  return { ctx, page };
}

// origin: a server that sends the strict CSP header (config.mjs CSP). Returns the rows it measured.
export async function checkChart(browser, origin, fails) {
  const rows = {};
  const fail = (m) => fails.push(`chart /${CHART_PAGE}: ${m}`);
  let { ctx, page } = await open(browser, origin, { colorScheme: "light", viewport: { width: 1280, height: 900 } });
  rows.light = await page.evaluate(state);
  if (!rows.light.length) fail("no chart figure");
  rows.light.forEach((r, i) => {
    if (r.role !== "img" || !r.name || (r.caption && r.name !== r.caption)) fail(`figure ${i + 1}: canvas role/name ${r.role} "${r.name}"`);
    if (!r.shown || !r.painted) fail(`figure ${i + 1}: canvas not drawn`);
    if (!r.folded || r.table) fail(`figure ${i + 1}: the table is not folded into a closed details`);
  });
  const canvas = page.locator("figure.mt-chart canvas").first();
  await canvas.scrollIntoViewIfNeeded();
  const box = await canvas.boundingBox();
  await page.mouse.move(box.x + box.width / 2, box.y + box.height / 2);
  await page.mouse.click(box.x + box.width / 2, box.y + 12);
  await page.evaluate(() => { window.mtNoReload = true; });
  await page.locator(".mt-theme-toggle").first().click();
  await page.waitForTimeout(600);
  rows.toggled = await page.evaluate(state);
  if (!(await page.evaluate(() => window.mtNoReload))) fail("the theme toggle reloaded the page");
  rows.toggled.forEach((r, i) => {
    if (!r.painted || r.colour === rows.light[i].colour) fail(`figure ${i + 1}: not redrawn with the other scheme's colours (${r.colour})`);
  });
  rows.violations = await page.evaluate(() => window.mtCspViolations);
  rows.violations.forEach((v) => fail(`CSP violation ${v}`));
  await ctx.close();
  ({ ctx, page } = await open(browser, origin, { reducedMotion: "reduce" }));
  rows.reduced = await page.evaluate(state);
  if (rows.reduced.some((r) => r.animation !== false)) fail("reduced motion: the chart animates");
  await ctx.close();
  ({ ctx, page } = await open(browser, origin, { forcedColors: "active" }));
  rows.forced = await page.evaluate(state);
  if (rows.forced.some((r) => r.shown || r.folded || !r.table)) fail("forced colours: the table is not the chart");
  await ctx.close();
  return rows;
}
