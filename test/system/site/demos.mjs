// The starter demo builds of rake starters:demo: DIR/<name>/ built at its Pages base path, described by DIR/<name>.json
// ({name, base, qa}). Each runs audit/features/showcase.mjs on its first two qa: pages.
import fs from "node:fs";
import path from "node:path";
import { serveSite } from "./server.mjs";
import { checkShowcase } from "../audit/features/showcase.mjs";

export function readDemos(dir) {
  return fs.readdirSync(dir).filter((f) => f.endsWith(".json")).sort()
    .map((f) => ({ ...JSON.parse(fs.readFileSync(path.join(dir, f), "utf8")), site: path.join(dir, f.slice(0, -5)) }));
}

// serve(demo) returns { origin, close } with origin ending in the demo's base path and "/".
export async function checkDemos(browser, dir, fails, serve = (d) => serveSite(d.site, { base: d.base })) {
  const rows = {};
  for (const demo of readDemos(dir)) {
    const { origin, close } = await serve(demo);
    try {
      rows[demo.name] = await checkShowcase(browser, origin, demo.qa.slice(0, 2), fails);
    } finally {
      close();
    }
  }
  return rows;
}
