// Size budgets: each core CSS sheet (core, context and section sheets), the core CSS one page links in total,
// all core JS, the optional renderer scripts js/modootoday-<name>.js, and the optional blog/news bundle apart (gzip reported, not budgeted).
import fs from "node:fs";
import path from "node:path";
import zlib from "node:zlib";
import { BUDGET, BLOG_FILES, SHEETS, SECTION_SHEET, SHOWCASE, BUNDLE, BUNDLE_JS } from "./config.mjs";

const sheetBudget = (f) => SHEETS[f] ?? (/^css\/modootoday\/(showcase|structure)\//.test(f) ? SECTION_SHEET : null);

export function checkBudgets(site, fails) {
  const dir = path.join(site, "assets");
  const all = fs.readdirSync(dir, { recursive: true }).map((f) => f.split(path.sep).join("/"));
  const size = (f) => fs.statSync(path.join(dir, f)).size;
  const sizes = {};
  for (const [kind, ext, blog] of [["css", ".css", false], ["js", ".js", false], ["blog-css", ".css", true], ["blog-js", ".js", true]]) {
    const files = all.filter((f) => f.endsWith(ext) && f.includes("modootoday") && !BUNDLE.test(f) && !BUNDLE_JS.test(f) && BLOG_FILES.includes(f) === blog);
    const bytes = files.reduce((n, f) => n + size(f), 0);
    const gzip = files.reduce((n, f) => n + zlib.gzipSync(fs.readFileSync(path.join(dir, f))).length, 0);
    sizes[kind] = { files, bytes, gzip, budget: BUDGET[kind] };
    if (kind !== "css" && bytes > BUDGET[kind]) fails.push(`${kind} ${bytes} B > budget ${BUDGET[kind]} B`);
  }
  for (const f of sizes.css.files) {
    const b = sheetBudget(f);
    if (b == null) fails.push(`css ${f}: no budget in qa/audit/config.mjs`);
    else if (size(f) > b) fails.push(`css ${f} ${size(f)} B > budget ${b} B`);
  }
  let worst = 0;
  for (const h of fs.readdirSync(site, { recursive: true }).filter((f) => f.endsWith(".html"))) {
    const html = fs.readFileSync(path.join(site, h), "utf8");
    const links = [...html.matchAll(/<link rel="stylesheet" href="[^"]*\/assets\/(css\/modootoday[^"]*\.css)"/g)].map((m) => m[1]).filter((f) => !BLOG_FILES.includes(f) && !BUNDLE.test(f));
    const t = links.reduce((n, f) => n + (fs.existsSync(path.join(dir, f)) ? size(f) : 0), 0);
    const cap = SHOWCASE.test(h) ? BUDGET.css_showcase : BUDGET.css;
    if (cap === BUDGET.css) worst = Math.max(worst, t);
    if (t > cap) fails.push(`css linked by ${h}: ${t} B > budget ${cap} B`);
  }
  sizes.css.page_max = worst;
  for (const f of all.filter((x) => BUNDLE.test(x))) {
    const k = `css:${f.match(BUNDLE)[1]}`;
    sizes[k] = { files: [f], bytes: size(f), gzip: zlib.gzipSync(fs.readFileSync(path.join(dir, f))).length, budget: BUDGET.bundle };
    if (size(f) > BUDGET.bundle) fails.push(`${k} ${size(f)} B > budget ${BUDGET.bundle} B`);
  }
  for (const f of all.filter((x) => BUNDLE_JS.test(x))) {
    const k = `js:${f.match(BUNDLE_JS)[1]}`;
    sizes[k] = { files: [f], bytes: size(f), gzip: zlib.gzipSync(fs.readFileSync(path.join(dir, f))).length, budget: BUDGET.bundle_js };
    if (size(f) > BUDGET.bundle_js) fails.push(`${k} ${size(f)} B > budget ${BUDGET.bundle_js} B`);
  }
  return sizes;
}
