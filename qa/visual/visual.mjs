// Dev-only visual regression check for the docs/ site (not shipped in the gem).
// Screenshots a fixed set of pages x widths x colour schemes and compares them with baseline PNGs.
//
//   node qa/visual/visual.mjs SITE_DIR [--baseline DIR] [--out DIR] [--update] [--report]
//                      [--threshold 0.1] [--max-diff 0.001]
//
//   --update     write the screenshots as the new baseline instead of comparing
//   --report     always exit 0 (CI report mode); the result goes to stdout and $GITHUB_STEP_SUMMARY
//   --threshold  per-pixel colour distance tolerated by pixelmatch (0..1, default 0.1)
//   --max-diff   share of differing pixels tolerated per shot (default 0.001 = 0.1 %)
//
// Baselines depend on the platform's fonts and rendering, so compare only shots taken on the
// same machine image (CONTRIBUTING.md, "Visual regression").
import { chromium } from "playwright";
import { PNG } from "pngjs";
import pixelmatch from "pixelmatch";
import fs from "node:fs";
import path from "node:path";
import { serveSite } from "../site/server.mjs";

const args = process.argv.slice(2);
const opt = (name, def) => { const i = args.indexOf(name); return i >= 0 ? args.splice(i, 2)[1] : def; };
const flag = (name) => { const i = args.indexOf(name); return i >= 0 ? (args.splice(i, 1), true) : false; };
const baseline = path.resolve(opt("--baseline", "qa/visual/baseline"));
const out = path.resolve(opt("--out", "qa-out/visual"));
const threshold = Number(opt("--threshold", "0.1"));
const maxDiff = Number(opt("--max-diff", "0.001"));
const update = flag("--update");
const report = flag("--report");
const site = path.resolve(args[0] || "docs/_site");
if (!fs.existsSync(path.join(site, "index.html"))) { console.error(`visual: no index.html in ${site} (build it with qa/site/build-docs.sh)`); process.exit(1); }

// Representative pages: home (hero, CTA, cards), kitchen sink (every component), a long reference page, a translation.
export const PAGES = { home: "", "kitchen-sink": "components/kitchen-sink/", configuration: "configuration/", "ko-home": "ko/" };
export const WIDTHS = [360, 1024, 1440];
export const SCHEMES = ["light", "dark"];

const { origin, close } = await serveSite(site);

// Freeze what changes between runs: animations, transitions, caret, and the "last updated" date.
const FREEZE = `*,*::before,*::after{animation:none!important;transition:none!important;caret-color:transparent!important}
.mt-page-meta time{visibility:hidden!important}`;

fs.mkdirSync(update ? baseline : out, { recursive: true });
const browser = await chromium.launch();
const rows = [];
for (const scheme of SCHEMES) {
  for (const width of WIDTHS) {
    const ctx = await browser.newContext({ colorScheme: scheme, viewport: { width, height: 900 }, deviceScaleFactor: 1, reducedMotion: "reduce", locale: "en-US", timezoneId: "UTC" });
    const page = await ctx.newPage();
    for (const [key, p] of Object.entries(PAGES)) {
      const name = `${key}-${width}-${scheme}`;
      await page.goto(origin + p, { waitUntil: "networkidle" });
      await page.addStyleTag({ content: FREEZE });
      await page.evaluate(() => document.fonts.ready);
      const buf = await page.screenshot({ fullPage: true, animations: "disabled", caret: "hide" });
      if (update) { fs.writeFileSync(path.join(baseline, name + ".png"), buf); rows.push({ name, status: "updated" }); continue; }
      const bp = path.join(baseline, name + ".png");
      if (!fs.existsSync(bp)) { fs.writeFileSync(path.join(out, name + ".actual.png"), buf); rows.push({ name, status: "missing baseline" }); continue; }
      const a = PNG.sync.read(buf), b = PNG.sync.read(fs.readFileSync(bp));
      if (a.width !== b.width || a.height !== b.height) {
        fs.writeFileSync(path.join(out, name + ".actual.png"), buf);
        rows.push({ name, status: `size ${b.width}x${b.height} -> ${a.width}x${a.height}` }); continue;
      }
      const diff = new PNG({ width: a.width, height: a.height });
      const n = pixelmatch(a.data, b.data, diff.data, a.width, a.height, { threshold });
      const share = n / (a.width * a.height);
      if (share > maxDiff) {
        fs.writeFileSync(path.join(out, name + ".actual.png"), buf);
        fs.writeFileSync(path.join(out, name + ".diff.png"), PNG.sync.write(diff));
      }
      rows.push({ name, status: share > maxDiff ? `changed ${(share * 100).toFixed(2)} %` : "ok", share });
    }
    await ctx.close();
  }
}
await browser.close();
close();

const bad = rows.filter((r) => !["ok", "updated"].includes(r.status));
const lines = [`Visual regression: ${rows.length} shots, ${bad.length} differ (threshold ${threshold}, max ${maxDiff * 100} % pixels)`, ...bad.map((r) => `- ${r.name}: ${r.status}`)];
console.log(update ? `visual: wrote ${rows.length} baseline images to ${path.relative(process.cwd(), baseline)}` : lines.join("\n"));
if (process.env.GITHUB_STEP_SUMMARY && !update) fs.appendFileSync(process.env.GITHUB_STEP_SUMMARY, lines.join("\n") + "\n");
if (!update && bad.length && !report) process.exit(1);
