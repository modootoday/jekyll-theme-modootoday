// Registry parts after scripts run (static parts are checked in the built HTML by modootoday-check).
import path from "node:path";
import { execFileSync } from "node:child_process";

const registry = () => JSON.parse(execFileSync("ruby", ["-ryaml", "-rjson", "-e", "puts JSON.generate(YAML.safe_load(File.read(ARGV[0])) || {})", path.resolve("docs/_data/components.yml")]).toString());

export async function checkParts(browser, origin, langs, fails) {
  const comps = registry();
  const ctx = await browser.newContext();
  const page = await ctx.newPage();
  const rows = [];
  for (const l of langs) {
    const url = `${origin}${l}components/kitchen-sink/`;
    await page.goto(url, { waitUntil: "networkidle" });
    for (const [c, spec] of Object.entries(comps)) {
      for (const sel of (spec && spec.parts) || []) {
        const n = await page.evaluate(({ c, sel }) => [...document.querySelectorAll(`section[data-c="${c}"]`)].filter((s) => s.matches(sel) || s.querySelector(sel)).length, { c, sel });
        rows.push({ url, c, sel, sections: n });
        if (!n) fails.push(`part ${c} '${sel}' not found after scripts ran on ${url}`);
      }
    }
  }
  await ctx.close();
  return rows;
}
