// Writes OUT/report.json, prints the summary, WARN and FAIL lines, and returns the exit code (warnings do not fail).
import fs from "node:fs";
import path from "node:path";

export function writeReport(out, report, fails, warns) {
  fs.mkdirSync(out, { recursive: true });
  report.fails = fails.sort();
  report.warns = warns.sort();
  report.axe.sort((a, b) => (a.scheme + a.url + a.id).localeCompare(b.scheme + b.url + b.id));
  fs.writeFileSync(path.join(out, "report.json"), JSON.stringify(report, null, 2));
  const modules = Object.keys(report.sizes.modules).length;
  console.log(`shots ${report.shots}, theme files ${modules} (each within its cap), contrast pairs ${report.contrast.length}`);
  const types = Object.entries(report.sizes.types || {});
  const rows = types.map(([t, s]) => `| ${t} | ${s.css} | ${s.js} | ${s.sheets} |`);
  console.log("page types (gzip B, largest page): " + types.map(([t, s]) => `${t} css ${s.css} js ${s.js} sheets ${s.sheets}`).join(", "));
  if (process.env.GITHUB_STEP_SUMMARY) {
    const csp = (report.csp || []).length;
    const md = ["### Page weight (gzip bytes, largest page)", "", "| Type | CSS | JS | Theme sheets |", "|---|---|---|---|", ...rows, "", `${warns.length} warnings; CSP audit: ${csp} pages.`, ""];
    fs.appendFileSync(process.env.GITHUB_STEP_SUMMARY, md.join("\n"));
  }
  warns.forEach((w) => console.log("WARN " + w));
  fails.forEach((f) => console.log("FAIL " + f));
  return fails.length ? 1 : 0;
}
