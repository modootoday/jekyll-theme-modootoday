// The showcase of a starter demo build (modootoday.showcase): robots noindex; the bar 44px tall with the sticky header
// right under it and anchor targets clear of both; its links right after the skip link in Tab order; a dismissal that leaves the next page
// with no showcase and no layout shift; the pill clear of the page's last line; a short viewport lets the bar scroll away.
import { anchorGap } from "../layout/anchor-offset.mjs";

const shifts = () => {
  window.mtShift = 0;
  new PerformanceObserver((l) => l.getEntries().forEach((e) => { if (!e.hadRecentInput) window.mtShift += e.value; })).observe({ type: "layout-shift", buffered: true });
};

const measure = () => {
  const r = document.querySelector(".mt-showcase-region");
  const box = (e) => (e ? e.getBoundingClientRect() : null);
  return {
    style: document.documentElement.dataset.mtShowcase || null, robots: !!document.querySelector('meta[name="robots"][content~="noindex"]'),
    shown: !!r && r.checkVisibility(), region: box(r) && { top: box(r).top, bottom: box(r).bottom, height: box(r).height },
    header: box(document.querySelector(".mt-header")), position: r ? getComputedStyle(r).position : null,
    links: r ? [...r.querySelectorAll("a")].filter((a) => a.checkVisibility()).map((a) => a.textContent) : [], cls: window.mtShift,
  };
};

async function open(browser, url, viewport, init = {}) {
  const ctx = await browser.newContext({ viewport });
  await ctx.addInitScript(shifts);
  const page = await ctx.newPage();
  await page.goto(url, { waitUntil: "networkidle" });
  await page.waitForTimeout(500);
  return { ctx, page, ...init };
}

// pages: two page paths of one demo build (the second is opened after the dismissal). Returns the measured rows.
export async function checkShowcase(browser, origin, pages, fails) {
  const rows = {};
  const fail = (m) => fails.push(`showcase /${pages[0]}: ${m}`);
  const { ctx, page } = await open(browser, origin + pages[0], { width: 1440, height: 900 });
  try {
    const m = await page.evaluate(measure);
    rows.first = m;
    if (!m.robots) fail("no robots noindex");
    if (!m.shown) {
      fail("no visible showcase");
      return rows;
    }
    if (m.cls > 0) fail(`layout shift ${m.cls} on the first page`);
    await page.keyboard.press("Tab");
    rows.firstTab = await page.evaluate(() => document.activeElement.className);
    await page.keyboard.press("Tab");
    rows.secondTab = await page.evaluate(() => !!document.activeElement.closest(".mt-showcase-region"));
    if (rows.firstTab !== "mt-skip" || !rows.secondTab) fail(`Tab order: ${rows.firstTab}, then not the showcase`);
    if (m.style === "bar") {
      if (Math.round(m.region.height) !== 44) fail(`bar height ${m.region.height}px, not 44`);
      await page.evaluate(() => window.scrollTo(0, 600));
      const s = await page.evaluate(measure);
      rows.scrolled = s;
      if (Math.round(s.region.top) !== 0 || Math.abs(s.header.top - s.region.bottom) > 1) fail(`header top ${s.header.top} vs bar bottom ${s.region.bottom} after scrolling`);
      rows.anchorGap = await page.evaluate(`(${anchorGap})()`);
      if (rows.anchorGap !== null && rows.anchorGap < 0) fail(`anchor target ${Math.round(-rows.anchorGap)}px under the header`);
    } else {
      await page.evaluate(() => window.scrollTo(0, document.documentElement.scrollHeight));
      rows.lastGap = await page.evaluate(() => {
        const last = [...document.body.children].filter((e) => !e.closest(".mt-showcase-region") && e.checkVisibility() && e.getBoundingClientRect().height).at(-1);
        return document.querySelector(".mt-showcase-region").getBoundingClientRect().top - last.getBoundingClientRect().bottom;
      });
      if (rows.lastGap < 0) fail(`the pill covers the last ${Math.round(-rows.lastGap)}px of the page`);
    }
    await page.evaluate(() => window.scrollTo(0, 0));
    await page.locator(".mt-showcase-dismiss").click();
    rows.dismissed = await page.evaluate(measure);
    if (rows.dismissed.shown || rows.dismissed.style !== "off") fail("the dismiss button leaves the showcase on");
    await page.goto(origin + pages[1], { waitUntil: "networkidle" });
    await page.waitForTimeout(800);
    rows.next = await page.evaluate(measure);
    if (rows.next.shown) fail(`still shown on /${pages[1]} after the dismissal`);
    if (rows.next.cls > 0) fail(`layout shift ${rows.next.cls} on /${pages[1]} after the dismissal`);
    if (rows.next.header && Math.round(rows.next.header.top) !== 0) fail(`header top ${rows.next.header.top} after the dismissal`);
  } finally {
    await ctx.close();
  }
  const short = await open(browser, origin + pages[0], { width: 720, height: 360 });
  try {
    rows.short = await short.page.evaluate(measure);
    if (rows.short.style === "bar" && rows.short.position !== "static") fail(`bar ${rows.short.position} in a 360px-high viewport`);
  } finally {
    await short.ctx.close();
  }
  return rows;
}
