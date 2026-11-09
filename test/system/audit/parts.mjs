// Registry parts after scripts run (static parts are checked in the built HTML by modootoday-check), and the copy
// button code-copy.js adds to every code block, tab panels included (the script loads only on pages with a <pre>).
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
    const copy = await page.evaluate(() => {
      const boxes = [...document.querySelectorAll(".mt-main pre")].map((pre) => pre.closest("div.highlighter-rouge, div.mt-code-box") || pre);
      const missing = boxes.filter((b) => !b.querySelector(".mt-code-copy")).length;
      const inTabs = document.querySelectorAll('section[data-c="tabs"] [role=tabpanel] .mt-code-copy').length;
      return { boxes: boxes.length, missing, inTabs };
    });
    rows.push({ url, c: "code-copy", sel: ".mt-code-copy", sections: copy.boxes - copy.missing });
    if (!copy.boxes || copy.missing || !copy.inTabs) fails.push(`part code-copy '.mt-code-copy': ${copy.missing} of ${copy.boxes} code blocks without a copy button (${copy.inTabs} in tab panels) on ${url}`);
  }
  await ctx.close();
  return rows;
}
