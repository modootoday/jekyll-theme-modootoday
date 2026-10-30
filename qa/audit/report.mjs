// Writes OUT/report.json, prints the summary and FAIL lines, and returns the exit code.
import fs from "node:fs";
import path from "node:path";

export function writeReport(out, report, fails) {
  fs.mkdirSync(out, { recursive: true });
  report.fails = fails.sort();
  report.axe.sort((a, b) => (a.scheme + a.url + a.id).localeCompare(b.scheme + b.url + b.id));
  fs.writeFileSync(path.join(out, "report.json"), JSON.stringify(report, null, 2));
  const { css, js } = report.sizes;
  const extra = Object.entries(report.sizes).filter(([k]) => k.startsWith("css:") || k === "bundle-js").map(([k, s]) => `, ${k} ${s.bytes} B`).join("");
  console.log(`shots ${report.shots}, css ${css.bytes} B (gzip ${css.gzip}), js ${js.bytes} B (gzip ${js.gzip})${extra}, contrast pairs ${report.contrast.length}`);
  fails.forEach((f) => console.log("FAIL " + f));
  return fails.length ? 1 : 0;
}
