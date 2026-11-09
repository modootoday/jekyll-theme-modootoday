// Every component example, one element at a time: each section of the pages below (and each chart, widget, math or
// diagram figure outside a section) is probed for leaked source, an empty box, a missing stylesheet rule, an unstyled
// list form, overflow, broken images and icons and a result that drops part of its source; interactive parts are
// driven once per page, and a JS error or a failed subresource fails the page. Whole-page shots miss these.
import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";
import { probeExamples } from "./components/probe.mjs";
import { interactExamples } from "./components/interact.mjs";

const ALL = ["", "ko/", "ja/"];
// [url path, docs source without .md, languages]: the component pages, the kitchen sinks and the pages with examples.
export const EXAMPLE_PAGES = [
  ["components/", "components/index", ALL], ["components/kitchen-sink/", "components/kitchen-sink", ALL],
  ["components/kitchen-sink-rtl/", "components/kitchen-sink-rtl", [""]], ["recipes/figures/charts/", "recipes/figures/charts", ALL],
  ["recipes/figures/widgets/", "recipes/figures/widgets", ALL], ["recipes/figures/math-diagrams/", "recipes/figures/math-diagrams", ALL],
  ["layouts/demo/filter/", "layouts/demo/filter", [""]], ["layouts/demo/orbit/", "layouts/demo/orbit", [""]],
  ["layouts/demo/csp/", "layouts/demo/csp", [""]],
];
// Views per language: English in both schemes at both ends, the other languages light at the narrow end.
export const VIEWS = { "": [["light", 360], ["light", 1440], ["dark", 360], ["dark", 1440]], "ko/": [["light", 360]], "ja/": [["light", 360]] };

// The section names a page's front matter declares, so a section that did not render is caught too.
export function declaredSections(docs, src, lang) {
  const file = path.join(docs, `${src}${lang ? "." + lang.slice(0, -1) : ""}.md`);
  if (!fs.existsSync(file)) return [];
  const ruby = "fm = File.read(ARGV[0])[/\\A---\\n(.*?)\\n---/m, 1]; s = (YAML.safe_load(fm.to_s) || {})['sections'] || []; puts JSON.generate(s.map { |x| x.is_a?(Hash) ? x['name'] : x })";
  return JSON.parse(execFileSync("ruby", ["-ryaml", "-rjson", "-e", ruby, file]).toString());
}

// One page in one view: rows of {id, c, issues}, page-level errors, interactions, and element shots when asked.
export async function auditPage(browser, url, { theme, width, shots, interact }) {
  const ctx = await browser.newContext({ colorScheme: theme, viewport: { width, height: 900 } });
  await ctx.grantPermissions(["clipboard-read", "clipboard-write"]).catch(() => null);
  const page = await ctx.newPage();
  const errors = [];
  page.on("pageerror", (e) => errors.push(`JS error: ${String(e.message || e).slice(0, 160)}`));
  page.on("console", (m) => m.type() === "error" && errors.push(`console error: ${m.text().slice(0, 160)}`));
  page.on("response", (r) => r.status() >= 400 && errors.push(`HTTP ${r.status()} ${r.url()}`));
  page.on("requestfailed", (r) => !/favicon|youtube|vimeo|google/.test(r.url()) && errors.push(`request failed ${r.url()} ${r.failure()?.errorText || ""}`));
  try {
    await page.goto(url, { waitUntil: "networkidle", timeout: 60000 });
    await page.evaluate(async () => {
      for (const s of document.querySelectorAll("main section[data-section], main figure, main .mt-widget")) {
        s.scrollIntoView({ block: "center" });
        await new Promise((r) => setTimeout(r, 30));
      }
      window.scrollTo(0, 0);
    });
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(800);
    const rows = await page.evaluate(probeExamples);
    // A sticky header would cover the top of a tall example in its element shot.
    if (shots) await page.addStyleTag({ content: "body > header, .mt-header { position: static !important; }" }).catch(() => null);
    // A shot of an example taller than the window resizes it mid-capture, and a chart then redraws from zero.
    const tall = Math.max(...rows.map((r) => r.h), 0);
    if (shots && tall > 800) {
      await page.setViewportSize({ width, height: Math.min(tall + 100, 8000) });
      await page.waitForTimeout(1500);
    }
    for (const r of shots ? rows : []) {
      if (shots.only && !shots.only(r)) continue;
      fs.mkdirSync(shots.dir, { recursive: true });
      const file = `${shots.prefix}${r.id}.png`;
      const shot = page.locator(`[data-mt-audit="${r.i}"]`).screenshot({ path: path.join(shots.dir, file), animations: "disabled", timeout: 20000 });
      await shot.then(() => (r.shot = file), (e) => r.issues.push(`no shot: ${String(e.message).split("\n")[0].slice(0, 80)}`));
    }
    const actions = interact ? await interactExamples(page) : {};
    const sections = await page.evaluate(() => [...document.querySelectorAll("main section[data-section]")].map((s) => s.dataset.section));
    return { rows, errors: [...new Set(errors)], actions, sections };
  } finally {
    await ctx.close();
  }
}

// Docs audit entry: probes every view, keeps shots of failing examples under out/components/, fails on any finding.
export async function checkComponents(browser, origin, site, out, fails) {
  const docs = path.resolve(site, "..");
  let views = 0;
  for (const [p, src, langs] of EXAMPLE_PAGES) {
    for (const lang of langs) {
      const declared = declaredSections(docs, src, lang);
      for (const [theme, width] of VIEWS[lang]) {
        const tag = `/${lang}${p} ${theme} ${width}`;
        const shots = { dir: path.join(out, "components"), prefix: `${(lang + p).replace(/\W+/g, "-")}${theme}-${width}-`, only: (r) => r.issues.length };
        const res = await auditPage(browser, origin + lang + p, { theme, width, shots, interact: theme === "light" && width === 1440 });
        views++;
        res.rows.forEach((r) => r.issues.forEach((m) => fails.push(`component ${r.id} ${tag}: ${m}`)));
        res.errors.forEach((m) => fails.push(`components page ${tag}: ${m}`));
        Object.entries(res.actions).forEach(([k, m]) => m && fails.push(`component interaction ${k} ${tag}: ${m}`));
        declared.filter((n) => !res.sections.includes(n)).forEach((n) => fails.push(`component ${n} ${tag}: declared in sections: but not rendered`));
      }
    }
  }
  return views;
}
