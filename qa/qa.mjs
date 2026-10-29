// Dev-only visual + accessibility QA for the docs/ site (not shipped in the gem).
// Usage: node qa/qa.mjs SITE_DIR [OUT_DIR]   (SITE_DIR built by qa/build-docs.sh)
import { chromium } from "playwright";
import AxeBuilder from "@axe-core/playwright";
import http from "node:http";
import fs from "node:fs";
import path from "node:path";
import zlib from "node:zlib";

const site = path.resolve(process.argv[2] || "docs/_site");
const out = path.resolve(process.argv[3] || "qa-out");
const BASE = "/jekyll-theme-modootoday";
const WIDTHS = [360, 768, 1024, 1440];
const SCHEMES = ["light", "dark"];
const LANGS = ["", "ko/", "ja/"].filter((l) => fs.existsSync(path.join(site, l, "index.html")));
const PAGES = ["", "install/", "first-page/", "components/", "components/kitchen-sink/", "configuration/", "customize/", "agents/", "changelog/"];
const RTL_PAGES = ["components/kitchen-sink-rtl/"]; // English tree only: dir="rtl" mirroring checks
const BUDGET = { css: 32 * 1024, js: 10 * 1024 }; // as built (Jekyll default Sass output, uncompressed); gzip is reported
const fails = [];

const types = { ".html": "text/html; charset=utf-8", ".css": "text/css", ".js": "text/javascript", ".txt": "text/plain; charset=utf-8", ".md": "text/markdown; charset=utf-8", ".svg": "image/svg+xml", ".png": "image/png" };
const server = http.createServer((req, res) => {
  let u = decodeURIComponent(req.url.split("?")[0]);
  if (!u.startsWith(BASE)) { res.writeHead(404); return res.end(); }
  let f = path.join(site, u.slice(BASE.length));
  if (fs.existsSync(f) && fs.statSync(f).isDirectory()) f = path.join(f, "index.html");
  if (!fs.existsSync(f)) { res.writeHead(404); return res.end("404"); }
  res.writeHead(200, { "content-type": types[path.extname(f)] || "application/octet-stream" });
  fs.createReadStream(f).pipe(res);
});
await new Promise((r) => server.listen(0, r));
const origin = `http://127.0.0.1:${server.address().port}${BASE}/`;

// 1. bundle budgets
const sizes = {};
for (const [kind, ext] of [["css", ".css"], ["js", ".js"]]) {
  const files = fs.readdirSync(path.join(site, "assets"), { recursive: true }).filter((f) => f.endsWith(ext));
  const total = files.reduce((n, f) => n + fs.statSync(path.join(site, "assets", f)).size, 0);
  const gz = files.reduce((n, f) => n + zlib.gzipSync(fs.readFileSync(path.join(site, "assets", f))).length, 0);
  sizes[kind] = { files, bytes: total, gzip: gz, budget: BUDGET[kind] };
  if (total > BUDGET[kind]) fails.push(`${kind} ${total} B > budget ${BUDGET[kind]} B`);
}

// 2. token-level WCAG AA contrast (foreground/background token pairs, light + dark)
// logical name -> candidate token names (v0.2 semantic names first, v0.1 names as fallback)
const T = {
  fg: ["foreground", "fg"], "fg-muted": ["muted-foreground", "fg-muted"], bg: ["background", "bg"], "bg-subtle": ["muted", "bg-subtle"],
  accent: ["primary", "accent"], "accent-fg": ["primary-foreground", "accent-fg"], card: ["card"], "card-fg": ["card-foreground"], border: ["border"],
  ...Object.fromEntries(["note", "tip", "important", "warning", "caution"].map((t) => [t, [t]])),
  ...Object.fromEntries(["available", "partial", "planned"].map((t) => [t, ["status-" + t, t]])),
};
const PAIRS = [
  ["fg", "bg", 4.5], ["fg-muted", "bg", 4.5], ["fg", "bg-subtle", 4.5], ["fg-muted", "bg-subtle", 4.5], ["card-fg", "card", 4.5],
  ["accent", "bg", 4.5], ["accent-fg", "accent", 4.5], ["border", "bg", 1.2],
  ...["note", "tip", "important", "warning", "caution", "available", "partial", "planned"].map((t) => [t, "bg", 4.5]),
  ...["note", "tip", "important", "warning", "caution"].map((t) => [t, "bg-subtle", 3]),
];
const lum = (c) => { const [r, g, b] = c.map((v) => { v /= 255; return v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4; }); return 0.2126 * r + 0.7152 * g + 0.0722 * b; };
const ratio = (a, b) => { const [x, y] = [lum(a), lum(b)].sort((p, q) => q - p); return (x + 0.05) / (y + 0.05); };

const browser = await chromium.launch();
const report = { origin, sizes, contrast: [], axe: [], shots: 0, http: [] };
for (const scheme of SCHEMES) {
  const ctx = await browser.newContext({ colorScheme: scheme });
  const page = await ctx.newPage();
  await page.goto(origin);
  const prefixes = await page.evaluate(() => [...new Set([...document.styleSheets].flatMap((s) => { try { return [...s.cssRules]; } catch { return []; } }).flatMap((r) => [...(r.style || [])]).filter((p) => p.startsWith("--")).map((p) => p.split("-")[2]))]);
  const pre = prefixes.includes("mt") ? "--mt-" : "--md-";
  const rgb = await page.evaluate(({ pre, T }) => Object.fromEntries(Object.entries(T).map(([n, cands]) => {
    let v = "", used = null;
    for (const c of cands) { v = getComputedStyle(document.documentElement).getPropertyValue(pre + c).trim(); if (v) { used = pre + c; break; } }
    if (!v) return [n, null];
    const d = document.createElement("i"); d.style.color = v; document.body.append(d);
    const c = getComputedStyle(d).color.match(/[\d.]+/g).slice(0, 3).map(Number); d.remove(); return [n, { c, used }];
  })), { pre, T });
  for (const [f, b, min] of PAIRS) {
    if (!rgb[f] || !rgb[b]) continue;
    const r = +ratio(rgb[f].c, rgb[b].c).toFixed(2);
    report.contrast.push({ scheme, fg: rgb[f].used, bg: rgb[b].used, ratio: r, min });
    if (r < min) fails.push(`contrast ${scheme} ${rgb[f].used} on ${rgb[b].used} = ${r} < ${min}`);
  }
  // 3. screenshots + axe
  for (const lang of LANGS) for (const p of [...PAGES, ...(lang ? [] : RTL_PAGES)]) {
    const url = origin + lang + p;
    const resp = await page.goto(url, { waitUntil: "networkidle" });
    if (!resp || resp.status() !== 200) { if (lang === "ja/" ) continue; fails.push(`HTTP ${resp && resp.status()} ${url}`); continue; }
    const name = `${(lang || "en/").replace("/", "")}-${(p || "home/").replace(/\//g, "_").replace(/_$/, "")}`;
    for (const w of WIDTHS) {
      await page.setViewportSize({ width: w, height: 900 });
      const dir = path.join(out, "shots", scheme, String(w)); fs.mkdirSync(dir, { recursive: true });
      await page.screenshot({ path: path.join(dir, name + ".png"), fullPage: true });
      report.shots++;
      const overflow = await page.evaluate(() => document.documentElement.scrollWidth - window.innerWidth);
      if (overflow > 1) fails.push(`horizontal overflow ${overflow}px at ${w}px ${scheme} ${url}`);
    }
    await page.setViewportSize({ width: 1024, height: 900 });
    if (RTL_PAGES.includes(p)) {
      // logical properties must mirror: callout accent bar and steps rail on the right, code left-to-right
      const r = await page.evaluate(() => {
        const cs = (s) => { const e = document.querySelector(s); return e && getComputedStyle(e); };
        const c = cs(".mt-callout"), st = cs(".mt-c-steps > ol > li"), pre = cs("pre");
        return { dir: document.documentElement.dir, callout: c && parseFloat(c.borderRightWidth) > parseFloat(c.borderLeftWidth),
          steps: st && parseFloat(st.paddingRight) > parseFloat(st.paddingLeft), pre: pre && pre.direction === "ltr" };
      });
      for (const [k, ok] of Object.entries(r)) if (k === "dir" ? ok !== "rtl" : !ok) fails.push(`rtl ${k} not mirrored ${scheme} ${url}`);
    }
    const axe = await new AxeBuilder({ page }).withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"]).analyze();
    for (const v of axe.violations) {
      report.axe.push({ scheme, url, id: v.id, impact: v.impact, nodes: v.nodes.slice(0, 3).map((n) => n.target.join(" ")) });
      fails.push(`axe ${v.id} (${v.impact}) ${scheme} ${url}`);
    }
  }
  await ctx.close();
}
await browser.close(); server.close();
fs.mkdirSync(out, { recursive: true });
report.fails = fails;
fs.writeFileSync(path.join(out, "report.json"), JSON.stringify(report, null, 2));
console.log(`shots ${report.shots}, css ${sizes.css.bytes} B (gzip ${sizes.css.gzip}), js ${sizes.js.bytes} B (gzip ${sizes.js.gzip}), contrast pairs ${report.contrast.length}`);
fails.forEach((f) => console.log("FAIL " + f));
process.exit(fails.length ? 1 : 0);
