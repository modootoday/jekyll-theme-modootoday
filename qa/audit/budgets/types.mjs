// Page-type budgets: the gzip bytes of the CSS and JS one page of each type actually loads (qa/audit/config.mjs PAGE_TYPES).
import fs from "node:fs";
import path from "node:path";
import { PAGE_TYPES } from "../config.mjs";
import { gzipSize } from "./files.mjs";
import { pageAssets } from "./pages.mjs";

const gzipOf = (site, files) => files.reduce((n, f) => {
  const file = path.join(site, "assets", f);
  return n + (fs.existsSync(file) ? gzipSize(file) : 0);
}, 0);

export function checkTypes(site, fails) {
  const types = {};
  for (const [type, spec] of Object.entries(PAGE_TYPES)) {
    const pages = [];
    for (const p of spec.pages) {
      const file = path.join(site, p, "index.html");
      if (!fs.existsSync(file)) {
        fails.push(`page type ${type}: ${p || "/"} not built`);
        continue;
      }
      const { css, js } = pageAssets(site, fs.readFileSync(file, "utf8"));
      const row = { page: p, css: gzipOf(site, css), js: gzipOf(site, js), files: [...css, ...js] };
      pages.push(row);
      for (const kind of ["css", "js"]) {
        if (row[kind] > spec[kind]) {
          fails.push(`page type ${type}: ${kind} of ${p || "/"} ${row[kind]} B gzip > budget ${spec[kind]} B`);
        }
      }
    }
    const max = (kind) => Math.max(0, ...pages.map((r) => r[kind]));
    types[type] = { css: max("css"), js: max("js"), budget: { css: spec.css, js: spec.js }, pages };
  }
  return types;
}
