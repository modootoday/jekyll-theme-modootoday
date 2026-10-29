// First paint: click the header logo (full load of the home page) on a throttled network and record screencast
// frames. The first frame of the new page must match the settled page (no late header items, no scheme flip),
// body background must never change, and CLS must stay under 0.02. Runs for each scheme and a stored "dark" choice.
import { PNG } from "pngjs";
import pixelmatch from "pixelmatch";
export const FIRST_PAINT_MAX_CLS = 0.02;
const NET = { offline: false, latency: 150, downloadThroughput: 200000, uploadThroughput: 100000 };
const CASES = [["light"], ["dark"], ["light", "dark"]]; // [system scheme, stored mt-theme]

function probe() {
  window.__cls = 0; window.__bg = new Set();
  new PerformanceObserver((l) => { for (const e of l.getEntries()) if (!e.hadRecentInput) window.__cls += e.value; }).observe({ type: "layout-shift", buffered: true });
  const rec = () => { if (document.body) window.__bg.add(getComputedStyle(document.body).backgroundColor); if (performance.now() < 3000) requestAnimationFrame(rec); };
  requestAnimationFrame(rec);
}

async function run(browser, origin, scheme, stored, fails) {
  const ctx = await browser.newContext({ colorScheme: scheme, viewport: { width: 1280, height: 800 } });
  const page = await ctx.newPage(), cdp = await ctx.newCDPSession(page), tag = `${scheme}${stored ? "+stored " + stored : ""}`;
  if (stored) await page.addInitScript((t) => { try { localStorage.setItem("mt-theme", t); } catch (e) {} }, stored);
  await page.addInitScript(probe);
  await cdp.send("Network.enable"); await cdp.send("Network.emulateNetworkConditions", NET);
  await page.goto(origin + "install/", { waitUntil: "load" });
  const frames = [];
  cdp.on("Page.screencastFrame", (f) => { frames.push(f.data); cdp.send("Page.screencastFrameAck", { sessionId: f.sessionId }).catch(() => {}); });
  const before = (await page.screenshot()).toString("base64");
  await cdp.send("Page.startScreencast", { format: "png" });
  await Promise.all([page.waitForURL(origin, { waitUntil: "load" }), page.click(".mt-site-title")]);
  await page.waitForTimeout(1500); await cdp.send("Page.stopScreencast");
  const r = await page.evaluate(() => ({ cls: window.__cls, bg: [...window.__bg] }));
  if (r.cls >= FIRST_PAINT_MAX_CLS) fails.push(`first paint: CLS ${r.cls.toFixed(4)} >= ${FIRST_PAINT_MAX_CLS} after logo click (${tag})`);
  if (r.bg.length !== 1) fails.push(`first paint: body background changed ${r.bg.join(" -> ")} (${tag})`);
  // header band (top 64 px) of the first frame that is no longer the old page vs the last frame
  const png = (d) => PNG.sync.read(Buffer.from(d, "base64")), band = (p) => p.data.subarray(0, p.width * 4 * 64);
  const last = png(frames.at(-1)), old = band(png(before).width === last.width ? png(before) : last);
  const first = frames.map(png).find((p) => p.width === last.width && Buffer.compare(band(p), old) !== 0);
  if (first) {
    const n = pixelmatch(band(first), band(last), null, last.width, 64, { threshold: 0.1 });
    if (n > 50) fails.push(`first paint: header changed after first paint (${n} px) after logo click (${tag})`);
  }
  await ctx.close();
}

export async function checkFirstPaint(browser, origin, fails) {
  for (const [scheme, stored] of CASES) await run(browser, origin, scheme, stored, fails);
}
