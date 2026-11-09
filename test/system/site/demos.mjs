// The starter demo builds of rake starters:demo: DIR/<name>/ built at its Pages base path, described by DIR/<name>.json
// ({name, base, qa}). Each runs audit/features/showcase.mjs on its first two qa: pages, then the docs audit's page checks
// (shots, overflow, axe and the lists of config.mjs STARTERS) on every qa: page in both schemes, the budgets of its page
// types and, for a starter with csp, the CSP audit on every qa: page.
import fs from "node:fs";
import path from "node:path";
import { serveSite } from "./server.mjs";
import { checkShowcase } from "../audit/features/showcase.mjs";
import { checkPage } from "../audit/pages.mjs";
import { checkCsp } from "../audit/csp.mjs";
import { readRegistry } from "../audit/budgets/registry.mjs";
import { checkModules } from "../audit/budgets/modules.mjs";
import { checkTypes } from "../audit/budgets/types.mjs";
import { SCHEMES, STARTERS } from "../audit/config.mjs";

export function readDemos(dir) {
  return fs.readdirSync(dir).filter((f) => f.endsWith(".json")).sort()
    .map((f) => ({ ...JSON.parse(fs.readFileSync(path.join(dir, f), "utf8")), site: path.join(dir, f.slice(0, -5)) }));
}

async function checkPages(browser, origin, demo, env) {
  for (const scheme of SCHEMES) {
    const ctx = await browser.newContext({ colorScheme: scheme });
    const page = await ctx.newPage();
    for (const p of demo.qa) {
      await checkPage(page, env, { scheme, lang: "", p });
    }
    await ctx.close();
  }
}

// serve(demo) returns { origin, close } with origin ending in the demo's base path and "/". out: where the page shots go;
// without it only the showcase audit runs. Returns the measured rows per starter.
export async function checkDemos(browser, dir, fails, { serve = (d) => serveSite(d.site, { base: d.base }), out, warns = [] } = {}) {
  const rows = {};
  for (const demo of readDemos(dir)) {
    const lists = STARTERS[demo.name] || {};
    const { origin, close } = await serve(demo);
    try {
      rows[demo.name] = { showcase: await checkShowcase(browser, origin, demo.qa.slice(0, 2), fails) };
      if (!out) {
        continue;
      }
      const report = { axe: [], shots: 0 };
      await checkPages(browser, origin, demo, { origin, out: path.join(out, demo.name), report, fails, lists });
      const modules = checkModules(demo.site, readRegistry(), fails, warns);
      const pageTypes = Object.fromEntries(Object.entries(lists.types || {}).map(([type, pages]) => [type, { pages }]));
      const types = checkTypes(demo.site, modules, fails, warns, pageTypes);
      const csp = lists.csp ? await checkCsp(browser, demo.site, fails, demo.qa, demo.base) : [];
      rows[demo.name] = { ...rows[demo.name], axe: report.axe, shots: report.shots, types, csp };
    } finally {
      close();
    }
  }
  return rows;
}
