// Page types (qa/audit/config.mjs PAGE_TYPES): what one page of each type loads, in gzip bytes. The limit of the theme's
// part is derived, the sum of the caps of the theme files the page loads; the GUIDE targets (whole page) only warn.
import fs from "node:fs";
import path from "node:path";
import { PAGE_TYPES, GUIDE } from "../config.mjs";
import { gzipSize } from "./modules.mjs";
import { pageAssets } from "./pages.mjs";

const gzipOf = (site, files) => files.reduce((n, f) => {
  const file = path.join(site, "assets", f);
  return n + (fs.existsSync(file) ? gzipSize(file) : 0);
}, 0);

const capOf = (modules, files) => files.reduce((n, f) => n + (modules[f]?.cap ?? 0), 0);

// The theme's own files; a site's sheets and modules count towards the page total but have no cap.
const THEME = /^(css|js)\/modootoday/;

const guide = (type, row, warns) => {
  if (GUIDE.skip.includes(type)) {
    return;
  }
  const page = row.page || "/";
  for (const kind of ["css", "js"]) {
    if (row[kind] > GUIDE[kind]) {
      warns.push(`page type ${type}: ${kind} of ${page} ${row[kind]} B gzip > guide target ${GUIDE[kind]} B`);
    }
  }
  if (row.sheets > GUIDE.sheets) {
    warns.push(`page type ${type}: ${page} links ${row.sheets} theme sheets > guide target ${GUIDE.sheets}`);
  }
};

export function checkTypes(site, modules, fails, warns, pageTypes = PAGE_TYPES) {
  const types = {};
  for (const [type, spec] of Object.entries(pageTypes)) {
    const pages = [];
    for (const p of spec.pages) {
      const file = path.join(site, p, "index.html");
      if (!fs.existsSync(file)) {
        fails.push(`page type ${type}: ${p || "/"} not built`);
        continue;
      }
      const { css, js } = pageAssets(site, fs.readFileSync(file, "utf8"));
      const sheets = css.filter((f) => f.startsWith("css/modootoday")).length;
      const own = { css: css.filter((f) => THEME.test(f)), js: js.filter((f) => THEME.test(f)) };
      const row = { page: p, css: gzipOf(site, css), js: gzipOf(site, js), sheets, files: [...css, ...js] };
      row.theme = { css: gzipOf(site, own.css), js: gzipOf(site, own.js) };
      row.limit = { css: capOf(modules, own.css), js: capOf(modules, own.js) };
      pages.push(row);
      for (const kind of ["css", "js"]) {
        if (row.theme[kind] > row.limit[kind]) {
          fails.push(`page type ${type}: theme ${kind} of ${p || "/"} ${row.theme[kind]} B gzip > ${row.limit[kind]} B, the caps of what it loads`);
        }
      }
      guide(type, row, warns);
    }
    const max = (kind) => Math.max(0, ...pages.map((r) => r[kind]));
    types[type] = { css: max("css"), js: max("js"), sheets: max("sheets"), pages };
  }
  return types;
}
