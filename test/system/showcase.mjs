// Dev-only showcase audit of the starter demo builds (not shipped in the gem).
// Usage: node test/system/showcase.mjs DEMO_DIR [OUT_DIR]   (DEMO_DIR written by bundle exec rake starters:demo[,DEMO_DIR])
import { chromium } from "playwright";
import fs from "node:fs";
import path from "node:path";
import { checkDemos } from "./site/demos.mjs";

const dir = path.resolve(process.argv[2] || "pkg/demo");
const out = path.resolve(process.argv[3] || "qa-out/showcase");
const fails = [];
const browser = await chromium.launch();
let rows;
try {
  rows = await checkDemos(browser, dir, fails);
} finally {
  await browser.close();
}
fs.mkdirSync(out, { recursive: true });
fs.writeFileSync(path.join(out, "showcase.json"), `${JSON.stringify({ rows, fails }, null, 2)}\n`);
for (const f of fails) console.error(`FAIL ${f}`);
console.log(`showcase: ${Object.keys(rows).length} demo build(s), ${fails.length} failure(s)`);
process.exit(fails.length ? 1 : 0);
