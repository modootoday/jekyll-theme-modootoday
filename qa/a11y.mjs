// Dev-only screen-reader audit over EVERY page of one or more built sites (not shipped in the gem).
// Usage: node qa/a11y.mjs OUT_DIR SITE_DIR...   axe WCAG 2.2 AA + structure + reflow + a11y-tree snapshots.
import { chromium } from "playwright";
import AxeBuilder from "@axe-core/playwright";
import fs from "node:fs";
import path from "node:path";
import { serveSite } from "./site/server.mjs";
import { checkStructure } from "./audit/screen-reader/sr-structure.mjs";
import { checkReflow } from "./audit/screen-reader/sr-reflow.mjs";
import { snapshotTree } from "./audit/screen-reader/sr-tree.mjs";

const [out, ...sites] = process.argv.slice(2).map((p) => path.resolve(p));
const TAGS = ["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"];
const pagesOf = (dir) => fs.readdirSync(dir, { recursive: true }).filter((f) => f.endsWith(".html") && !/^(assets|_)/.test(f));
const fails = [];
const browser = await chromium.launch();
for (const site of sites) {
  const { origin, close } = await serveSite(site);
  const page = await (await browser.newContext({ reducedMotion: "reduce" })).newPage();
  for (const f of pagesOf(site)) {
    const url = origin + "/" + f.replace(/index\.html$/, "");
    const r = await page.goto(url, { waitUntil: "load" });
    if (!r || r.status() !== 200) continue;
    const html = await r.text().catch(() => null); // null: a meta-refresh page already navigated away
    if (html == null || /http-equiv="refresh"/i.test(html)) continue; // redirect pages navigate away mid-audit
    const tag = `${path.basename(site)}:${f}`;
    const axe = await new AxeBuilder({ page }).withTags(TAGS).analyze();
    for (const v of axe.violations) fails.push(`${tag} axe ${v.id} ${v.nodes.slice(0, 2).map((n) => n.target.join(" ")).join(" | ")}`);
    for (const p of await checkStructure(page)) fails.push(`${tag} ${p}`);
    for (const p of await checkReflow(page)) fails.push(`${tag} ${p}`);
    await snapshotTree(page, path.join(out, "tree", path.basename(site)), f.replace(/\//g, "_"));
  }
  close();
}
await browser.close();
fs.mkdirSync(out, { recursive: true });
fs.writeFileSync(path.join(out, "a11y.txt"), fails.join("\n") + "\n");
console.log(fails.length ? fails.join("\n") : "a11y: 0 problems");
process.exit(fails.length ? 1 : 0);
