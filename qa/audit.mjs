// Dev-only visual + accessibility audit of the docs/ site (not shipped in the gem).
// Usage: node qa/audit.mjs SITE_DIR [OUT_DIR]   (SITE_DIR built by qa/site/build-docs.sh)
// Assembles the checks in qa/audit/: budgets, contrast, pages (shots, overflow, RTL, axe), parts, first paint, report.
import { chromium } from "playwright";
import path from "node:path";
import { serveSite } from "./site/server.mjs";
import { SCHEMES, PAGES, RTL_PAGES, EN_ONLY, JOBS, langsOf } from "./audit/config.mjs";
import { checkBudgets } from "./audit/budgets.mjs";
import { checkContrast } from "./audit/contrast.mjs";
import { checkPage } from "./audit/pages.mjs";
import { checkParts } from "./audit/parts.mjs";
import { checkFirstPaint } from "./audit/first-paint.mjs";
import { writeReport } from "./audit/report.mjs";

const site = path.resolve(process.argv[2] || "docs/_site");
const out = path.resolve(process.argv[3] || "qa-out");
const langs = langsOf(site);
const fails = [];
const { origin, close } = await serveSite(site);
const report = { origin, sizes: checkBudgets(site, fails), contrast: [], axe: [], shots: 0, http: [] };

const browser = await chromium.launch();
const ctxs = [], tasks = [];
for (const scheme of SCHEMES) {
  const ctx = await browser.newContext({ colorScheme: scheme });
  ctxs.push(ctx);
  const page = await ctx.newPage();
  await page.goto(origin);
  await checkContrast(page, scheme, report.contrast, fails);
  await page.close();
  for (const lang of langs) for (const p of [...PAGES, ...(lang ? [] : [...RTL_PAGES, ...EN_ONLY])]) tasks.push({ ctx, scheme, lang, p });
}
// a pool of JOBS pages per scheme drains one shared queue
const env = { origin, out, report, fails };
await Promise.all(ctxs.flatMap((ctx) => Array.from({ length: JOBS }, async () => {
  const page = await ctx.newPage();
  for (let t; (t = tasks.find((x) => x.ctx === ctx && !x.taken)); ) { t.taken = true; await checkPage(page, env, t); }
  await page.close();
})));
for (const ctx of ctxs) await ctx.close();
report.parts = await checkParts(browser, origin, langs, fails);
await checkFirstPaint(browser, origin, fails);
await browser.close(); close();
process.exit(writeReport(out, report, fails));
