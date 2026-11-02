// File budgets: each core CSS sheet (core, context and section sheets), the gzip total of the core scripts,
// the optional blog/news bundle, layout bundles css/modootoday-<name>.css and renderer scripts js/modootoday-<name>.js.
import fs from "node:fs";
import path from "node:path";
import zlib from "node:zlib";
import { BUDGET, BLOG_FILES, SHEETS, SECTION_SHEET, BUNDLE, BUNDLE_JS } from "../config.mjs";

export const gzipSize = (file) => zlib.gzipSync(fs.readFileSync(file)).length;

const KINDS = [
  ["css", ".css", false],
  ["js", ".js", false],
  ["blog-css", ".css", true],
  ["blog-js", ".js", true],
];

const sheetBudget = (f) => {
  if (SHEETS[f] != null) {
    return SHEETS[f];
  }
  return /^css\/modootoday\/(showcase|structure)\//.test(f) ? SECTION_SHEET : null;
};

const isCore = (f, ext, blog) => {
  if (!f.endsWith(ext) || !f.includes("modootoday")) {
    return false;
  }
  if (BUNDLE.test(f) || BUNDLE_JS.test(f)) {
    return false;
  }
  return BLOG_FILES.includes(f) === blog;
};

export function checkFiles(site, fails) {
  const dir = path.join(site, "assets");
  const all = fs.readdirSync(dir, { recursive: true }).map((f) => f.split(path.sep).join("/"));
  const size = (f) => fs.statSync(path.join(dir, f)).size;
  const gzip = (f) => gzipSize(path.join(dir, f));
  const sum = (files, fn) => files.reduce((n, f) => n + fn(f), 0);
  const sizes = {};
  for (const [kind, ext, blog] of KINDS) {
    const files = all.filter((f) => isCore(f, ext, blog));
    const budget = kind === "js" ? BUDGET.js_total : BUDGET[kind];
    sizes[kind] = { files, bytes: sum(files, size), gzip: sum(files, gzip), budget };
  }
  if (sizes.js.gzip > BUDGET.js_total) {
    fails.push(`js ${sizes.js.gzip} B gzip > budget ${BUDGET.js_total} B`);
  }
  for (const kind of ["blog-css", "blog-js"]) {
    if (sizes[kind].bytes > BUDGET[kind]) {
      fails.push(`${kind} ${sizes[kind].bytes} B > budget ${BUDGET[kind]} B`);
    }
  }
  for (const f of sizes.css.files) {
    const b = sheetBudget(f);
    if (b == null) {
      fails.push(`css ${f}: no budget in qa/audit/config.mjs`);
    } else if (size(f) > b) {
      fails.push(`css ${f} ${size(f)} B > budget ${b} B`);
    }
  }
  for (const [re, prefix, budget] of [[BUNDLE, "css", BUDGET.bundle], [BUNDLE_JS, "js", BUDGET.bundle_js]]) {
    for (const f of all.filter((x) => re.test(x))) {
      const k = `${prefix}:${f.match(re)[1]}`;
      sizes[k] = { files: [f], bytes: size(f), gzip: gzip(f), budget };
      if (size(f) > budget) {
        fails.push(`${k} ${size(f)} B > budget ${budget} B`);
      }
    }
  }
  return sizes;
}
