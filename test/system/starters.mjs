// Dev-only audit of the starter demo builds (not shipped in the gem): the showcase, then the page, budget and CSP checks
// that moved into the starters with their demo rows (test/system/site/demos.mjs).
// Usage: node test/system/starters.mjs DEMO_DIR [OUT_DIR]   (DEMO_DIR written by bundle exec rake starters:demo[,DEMO_DIR])
import { chromium } from "playwright";
import fs from "node:fs";
import path from "node:path";
import { checkDemos } from "./site/demos.mjs";

const dir = path.resolve(process.argv[2] || "pkg/demo");
const out = path.resolve(process.argv[3] || "qa-out/starters");
const fails = [];
const warns = [];
const browser = await chromium.launch();
let rows;
try {
  rows = await checkDemos(browser, dir, fails, { out, warns });
} finally {
  await browser.close();
}
fs.mkdirSync(out, { recursive: true });
fs.writeFileSync(path.join(out, "starters.json"), `${JSON.stringify({ rows, fails, warns }, null, 2)}\n`);
for (const w of warns) console.warn(`WARN ${w}`);
for (const f of fails) console.error(`FAIL ${f}`);
console.log(`starters: ${Object.keys(rows).length} demo build(s), ${fails.length} failure(s), ${warns.length} warning(s)`);
process.exit(fails.length ? 1 : 0);
