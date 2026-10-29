// Phones and tablets (iPhone SE / 14 / iPad-sized, portrait and landscape, touch): viewport-fit=cover, simulated
// safe-area insets through the --mt-safe-* hooks, no horizontal overflow, 16px inputs (no iOS zoom), 44px targets.
// Also screenshots with reduced motion and forced colors. Chromium with device emulation (WebKit when QA_WEBKIT=1).
import fs from "node:fs";
import path from "node:path";
import { devices, webkit } from "playwright";

export const VIEWS = [
  ["360", { ...devices["Galaxy S9+"], viewport: { width: 360, height: 740 } }],
  ["390", devices["iPhone 14"]], ["390-landscape", devices["iPhone 14 landscape"]],
  ["768", devices["iPad Mini"]], ["768-landscape", devices["iPad Mini landscape"]],
];
const MOBILE_PAGES = ["", "components/kitchen-sink/", "components/kitchen-sink-rtl/", "ko/install/"];
const INSETS = { top: 47, right: 44, bottom: 34, left: 44 };
const insetCss = `:root{--mt-safe-top:${INSETS.top}px;--mt-safe-right:${INSETS.right}px;--mt-safe-bottom:${INSETS.bottom}px;--mt-safe-left:${INSETS.left}px}`;

async function measure(page) {
  return page.evaluate(() => {
    const q = (s) => document.querySelector(s), cs = (s) => q(s) && getComputedStyle(q(s));
    const inner = q(".mt-header-inner"), first = inner && inner.firstElementChild, input = q(".mt-search input");
    const small = [...document.querySelectorAll(".mt-header a, .mt-header summary, .mt-header button, .mt-header input, [role='tab'], .mt-code-copy")]
      .filter((e) => e.offsetParent && e.getBoundingClientRect().height < 43.5).map((e) => e.tagName + "." + e.className);
    return {
      meta: (q('meta[name="viewport"]') || {}).content || "",
      overflow: document.documentElement.scrollWidth - innerWidth,
      headerTop: parseFloat(cs(".mt-header").paddingTop), footerBottom: cs(".mt-footer") ? parseFloat(cs(".mt-footer").paddingBottom) : null,
      firstLeft: first ? Math.min(first.getBoundingClientRect().left, innerWidth - first.getBoundingClientRect().right) : 99,
      inputFont: input && !input.closest("[hidden]") ? parseFloat(getComputedStyle(input).fontSize) : 16,
      small: [...new Set(small)].slice(0, 5),
    };
  });
}

export async function checkMobile(browser, origin, out, fails) {
  const rows = [];
  const engine = process.env.QA_WEBKIT ? await webkit.launch() : browser;
  for (const scheme of ["light", "dark"]) for (const [name, dev] of VIEWS) {
    const { defaultBrowserType, ...opts } = dev;
    const ctx = await engine.newContext({ ...opts, colorScheme: scheme });
    const page = await ctx.newPage();
    const dir = path.join(out, "mobile", scheme, name); fs.mkdirSync(dir, { recursive: true });
    for (const p of MOBILE_PAGES) {
      const url = origin + p;
      await page.goto(url, { waitUntil: "networkidle" });
      const base = await measure(page);
      if (!/viewport-fit=cover/.test(base.meta)) fails.push(`mobile: viewport meta lacks viewport-fit=cover ${url}`);
      if (base.overflow > 1) fails.push(`mobile: horizontal overflow ${base.overflow}px ${name} ${scheme} ${url}`);
      if (base.inputFont < 16) fails.push(`mobile: search input ${base.inputFont}px < 16px (iOS zooms) ${name} ${url}`);
      if (base.small.length) fails.push(`mobile: touch targets under 44px (${base.small.join(", ")}) ${name} ${url}`);
      await page.addStyleTag({ content: insetCss });
      const s = await measure(page);
      if (s.headerTop < INSETS.top) fails.push(`mobile: header ignores the top safe-area inset (${s.headerTop}px) ${name} ${url}`);
      if (s.footerBottom !== null && s.footerBottom < INSETS.bottom) fails.push(`mobile: footer ignores the bottom inset ${name} ${url}`);
      if (s.firstLeft < INSETS.left) fails.push(`mobile: header content inside the side inset (${s.firstLeft}px) ${name} ${url}`);
      if (s.overflow > 1) fails.push(`mobile: overflow ${s.overflow}px with safe-area insets ${name} ${url}`);
      const shot = (p || "home/").replace(/\//g, "_").replace(/_$/, "");
      await page.screenshot({ path: path.join(dir, shot + "-safe.png"), fullPage: false });
      rows.push({ name, scheme, url });
    }
    await ctx.close();
  }
  if (engine !== browser) await engine.close();
  await systemSettings(browser, origin, out, fails);
  return rows;
}

// prefers-reduced-motion: no transitions; forced-colors: focus ring uses the system Highlight colour.
async function systemSettings(browser, origin, out, fails) {
  const ctx = await browser.newContext({ viewport: { width: 390, height: 844 }, hasTouch: true, isMobile: true });
  const page = await ctx.newPage();
  const dir = path.join(out, "mobile", "settings"); fs.mkdirSync(dir, { recursive: true });
  await page.emulateMedia({ reducedMotion: "reduce" });
  await page.goto(origin + "components/kitchen-sink/", { waitUntil: "networkidle" });
  const moving = await page.evaluate(() => [...document.querySelectorAll("a, button, summary")].filter((e) => parseFloat(getComputedStyle(e).transitionDuration) > 0).length);
  if (moving) fails.push(`mobile: ${moving} elements still transition with prefers-reduced-motion`);
  await page.screenshot({ path: path.join(dir, "reduced-motion.png") });
  await page.emulateMedia({ reducedMotion: "no-preference", forcedColors: "active" });
  await page.goto(origin + "components/kitchen-sink/", { waitUntil: "networkidle" });
  await page.keyboard.press("Tab");
  const ok = await page.evaluate(() => getComputedStyle(document.activeElement).outlineStyle !== "none");
  if (!ok) fails.push("mobile: focus ring disappears in forced-colors mode");
  await page.screenshot({ path: path.join(dir, "forced-colors.png") });
  await ctx.close();
}
