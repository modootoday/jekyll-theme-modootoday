// First paint: click the header logo (full load of the home page) on a throttled network and record screencast
// frames. The first frame of the new page must match the settled page (no late header items, no scheme flip),
// body background must never change, and CLS must stay under 0.02. Runs for each scheme and a stored "dark" choice,
// cold (HTTP cache off) and warm (theme files cached by the page before, the HTML still slow; adr:modootoday/20261111044513).
// Service workers are blocked: the throttle and the script hold reach only the page's own requests (features/pwa/
// covers the worker). The warm case needs a server that sends theme files with a max-age (server.mjs cache).
import { PNG } from "pngjs";
import pixelmatch from "pixelmatch";
export const FIRST_PAINT_MAX_CLS = 0.02;
export const ANCHOR_MAX_CLS = 0.001; // in-view components must not move at all once painted
export const HEADER_MAX_DIFF = 50; // px of the 64 px header band that may differ from the settled page
// Warm runs get a slower line: at 200 KB/s the home page's 21 KB up to the header end arrive before the first frame.
const NET = { offline: false, latency: 150, uploadThroughput: 100000 };
const DOWN = { cold: 200000, warm: 50000 };
const CACHES = ["cold", "warm"];
const CASES = [["light"], ["dark"], ["light", "dark"]]; // [system scheme, stored mt-theme]
// Short phone viewport: also load the home quick start (tabs, code copy) in view, so a late regroup counts as CLS.
const VIEWPORTS = [{ width: 1280, height: 800 }, { width: 390, height: 700, anchor: "#quick-start" }];

function probe() {
  window.__cls = 0; window.__bg = new Set();
  new PerformanceObserver((l) => { for (const e of l.getEntries()) if (!e.hadRecentInput) window.__cls += e.value; }).observe({ type: "layout-shift", buffered: true });
  const rec = () => { if (document.body) window.__bg.add(getComputedStyle(document.body).backgroundColor); if (performance.now() < 3000) requestAnimationFrame(rec); };
  requestAnimationFrame(rec);
}

// Header band (top 64 px) of the first frame that is no longer the old page vs the last frame; -1 when none changed.
function headerDiff(frames, before) {
  const png = (d) => PNG.sync.read(Buffer.from(d, "base64")), band = (p) => p.data.subarray(0, p.width * 4 * 64);
  const last = png(frames.at(-1)), old = band(png(before).width === last.width ? png(before) : last);
  const first = frames.map(png).find((p) => p.width === last.width && Buffer.compare(band(p), old) !== 0);
  return first ? pixelmatch(band(first), band(last), null, last.width, 64, { threshold: 0.1 }) : -1;
}

async function run(browser, origin, cache, scheme, stored, viewport, fails) {
  const ctx = await browser.newContext({ colorScheme: scheme, viewport: { width: viewport.width, height: viewport.height }, serviceWorkers: "block" });
  const page = await ctx.newPage(), cdp = await ctx.newCDPSession(page);
  const tag = `${cache} ${scheme}${stored ? "+stored " + stored : ""} ${viewport.width}x${viewport.height}`;
  if (stored) await page.addInitScript((t) => { try { localStorage.setItem("mt-theme", t); } catch (e) {} }, stored);
  await page.addInitScript(probe);
  await cdp.send("Network.enable"); await cdp.send("Network.emulateNetworkConditions", { ...NET, downloadThroughput: DOWN[cache] });
  await cdp.send("Network.setCacheDisabled", { cacheDisabled: cache === "cold" });
  await page.goto(origin + "guides/install/", { waitUntil: "load" });
  const frames = [];
  cdp.on("Page.screencastFrame", (f) => { frames.push(f.data); cdp.send("Page.screencastFrameAck", { sessionId: f.sessionId }).catch(() => {}); });
  const before = (await page.screenshot()).toString("base64");
  await cdp.send("Page.startScreencast", { format: "png" });
  await Promise.all([page.waitForURL(origin, { waitUntil: "load" }), page.click(".mt-site-title")]);
  await page.waitForTimeout(1500); await cdp.send("Page.stopScreencast");
  const r = await page.evaluate(() => ({ cls: window.__cls, bg: [...window.__bg], fcp: performance.getEntriesByName("first-contentful-paint")[0]?.startTime ?? -1 }));
  const row = { tag, header: headerDiff(frames, before), cls: +r.cls.toFixed(4), fcp: Math.round(r.fcp) };
  if (r.cls >= FIRST_PAINT_MAX_CLS) fails.push(`first paint: CLS ${r.cls.toFixed(4)} >= ${FIRST_PAINT_MAX_CLS} after logo click (${tag})`);
  if (r.bg.length !== 1) fails.push(`first paint: body background changed ${r.bg.join(" -> ")} (${tag})`);
  if (row.header > HEADER_MAX_DIFF) fails.push(`first paint: header changed after first paint (${row.header} px) after logo click (${tag})`);
  if (viewport.anchor && cache === "cold") {
    // Hold scripts back (theme URLs end in ?v=) so the page paints first, as on a slow phone; any regroup by JS then
    // shows up as CLS. Routing turns the HTTP cache off, so the warm case skips this step.
    await page.route(/\.js(\?|$)/, async (rt) => { await new Promise((t) => setTimeout(t, 800)); await rt.continue(); });
    await page.goto("about:blank"); await page.goto(origin + viewport.anchor, { waitUntil: "load" }); await page.waitForTimeout(1500);
    row.anchorCls = +(await page.evaluate(() => window.__cls)).toFixed(4);
    if (row.anchorCls >= ANCHOR_MAX_CLS) fails.push(`first paint: CLS ${row.anchorCls} >= ${ANCHOR_MAX_CLS} at ${viewport.anchor} (${tag})`);
  }
  await ctx.close();
  return row;
}

// One row per run (header band diff in px, CLS, FCP in ms) for the report.
export async function checkFirstPaint(browser, origin, fails) {
  const rows = [];
  for (const cache of CACHES) for (const viewport of VIEWPORTS) for (const [scheme, stored] of CASES) rows.push(await run(browser, origin, cache, scheme, stored, viewport, fails));
  return rows;
}
