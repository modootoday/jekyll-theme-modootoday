// Bundle size budgets: CSS and JS bytes under assets/, core and the optional blog/news bundle apart (gzip reported, not budgeted).
import fs from "node:fs";
import path from "node:path";
import zlib from "node:zlib";
import { BUDGET, BLOG_FILES } from "./config.mjs";

export function checkBudgets(site, fails) {
  const sizes = {};
  const dir = path.join(site, "assets");
  const all = fs.readdirSync(dir, { recursive: true }).map((f) => f.split(path.sep).join("/"));
  for (const [kind, ext, blog] of [["css", ".css", false], ["js", ".js", false], ["blog-css", ".css", true], ["blog-js", ".js", true]]) {
    const files = all.filter((f) => f.endsWith(ext) && BLOG_FILES.includes(f) === blog);
    const bytes = files.reduce((n, f) => n + fs.statSync(path.join(dir, f)).size, 0);
    const gzip = files.reduce((n, f) => n + zlib.gzipSync(fs.readFileSync(path.join(dir, f))).length, 0);
    sizes[kind] = { files, bytes, gzip, budget: BUDGET[kind] };
    if (bytes > BUDGET[kind]) fails.push(`${kind} ${bytes} B > budget ${BUDGET[kind]} B`);
  }
  return sizes;
}
