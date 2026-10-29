// Bundle size budgets: total CSS and JS bytes under assets/ (gzip reported, not budgeted).
import fs from "node:fs";
import path from "node:path";
import zlib from "node:zlib";
import { BUDGET } from "./config.mjs";

export function checkBudgets(site, fails) {
  const sizes = {};
  for (const [kind, ext] of [["css", ".css"], ["js", ".js"]]) {
    const dir = path.join(site, "assets");
    const files = fs.readdirSync(dir, { recursive: true }).filter((f) => f.endsWith(ext));
    const bytes = files.reduce((n, f) => n + fs.statSync(path.join(dir, f)).size, 0);
    const gzip = files.reduce((n, f) => n + zlib.gzipSync(fs.readFileSync(path.join(dir, f))).length, 0);
    sizes[kind] = { files, bytes, gzip, budget: BUDGET[kind] };
    if (bytes > BUDGET[kind]) fails.push(`${kind} ${bytes} B > budget ${BUDGET[kind]} B`);
  }
  return sizes;
}
