// Median Lighthouse scores per page/form factor from OUT/<name>-<mobile|desktop>.runN.json,
// checked against qa/budget.json. Exit 1 on a miss unless --summary-only.
import fs from "node:fs";
import path from "node:path";
const args = process.argv.slice(2);
const summaryOnly = args.includes("--summary-only");
const dir = args.find((a) => !a.startsWith("--")) || "qa-out/lighthouse";
const budget = JSON.parse(fs.readFileSync(new URL("./budget.json", import.meta.url)));
const cats = ["performance", "accessibility", "best-practices", "seo"];
const groups = {};
for (const f of fs.readdirSync(dir).filter((f) => /\.run\d+\.json$/.test(f))) {
  const name = f.replace(/\.run\d+\.json$/, "");
  try { (groups[name] ||= []).push(JSON.parse(fs.readFileSync(path.join(dir, f))).categories); } catch { (groups[name] ||= []).push(null); }
}
const median = (xs) => { const s = xs.filter((x) => x !== null).sort((a, b) => a - b); return s.length ? s[Math.floor((s.length - 1) / 2)] : null; };
let fail = 0; const lines = ["| page | perf | a11y | bp | seo |", "|---|---|---|---|---|"];
if (!Object.keys(groups).length) { console.error("lighthouse-budget: no runs in " + dir); process.exit(1); }
for (const [name, runs] of Object.entries(groups).sort()) {
  const ff = name.endsWith("-desktop") ? "desktop" : "mobile";
  const row = cats.map((c) => {
    const m = median(runs.map((r) => (r && r[c] && r[c].score !== null ? Math.round(r[c].score * 100) : null)));
    const min = typeof budget[c] === "object" ? budget[c][ff] : budget[c];
    const ok = m !== null && m >= min; if (!ok) fail++;
    return ok ? String(m) : `**${m ?? "-"}** (< ${min})`;
  });
  lines.push(`| ${name} | ${row.join(" | ")} |`);
}
const text = lines.join("\n") + `\n\n${fail ? fail + " score(s) below budget" : "All medians within budget"} (median of ${Math.max(...Object.values(groups).map((g) => g.length))} run(s)).\n`;
console.log(text);
if (process.env.GITHUB_STEP_SUMMARY) fs.appendFileSync(process.env.GITHUB_STEP_SUMMARY, "## Lighthouse\n\n" + text);
process.exit(fail && !summaryOnly ? 1 : 0);
