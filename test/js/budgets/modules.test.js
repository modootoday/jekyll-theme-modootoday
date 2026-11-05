// Tests for the size budgets of test/system/audit/budgets/: registry rows, per-file caps and derived page-type limits. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const zlib = require("node:zlib");
const crypto = require("node:crypto");
const { pathToFileURL } = require("node:url");

const QA = path.join(__dirname, "../../system/audit/budgets");
const load = (f) => import(pathToFileURL(path.join(QA, f)).href);

// A built site with the given assets (path -> text) and pages (path -> html).
function site(assets, pages = {}) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "mt-budgets-"));
  for (const [f, text] of Object.entries({ ...Object.fromEntries(Object.entries(assets).map(([k, v]) => [`assets/${k}`, v])), ...pages })) {
    fs.mkdirSync(path.dirname(path.join(dir, f)), { recursive: true });
    fs.writeFileSync(path.join(dir, f), text);
  }
  return dir;
}

const text = (n) => Array.from({ length: n }, (_, i) => `.a${i}{color:red}`).join("");
const gz = (s) => zlib.gzipSync(Buffer.from(s)).length;
const registry = (rows, fixed = "") => `{%- capture _mta_rows -%}\n${rows}\n{%- endcapture -%}\n{%- capture _mta_fixed -%}\n${fixed}\n{%- endcapture -%}\n`;

test("parseRegistry reads both lists, several triggers and the deps", async () => {
  const { parseRegistry } = await load("registry.mjs");
  const rows = parseRegistry(registry('lists|css|/assets/css/modootoday/content/lists.css|a^ b|lists|640\nf|module|/assets/js/modootoday/f.js|x||512|/assets/js/a.js /assets/js/b.js',
    "core|sheet|/assets/css/modootoday.css|||6528"));
  assert.deepStrictEqual(rows.map((r) => [r.name, r.file, r.triggers, r.cap, r.deps.length, r.fixed]), [
    ["lists", "css/modootoday/content/lists.css", ["a", " b"], 640, 0, false],
    ["f", "js/modootoday/f.js", ["x"], 512, 2, false],
    ["core", "css/modootoday.css", [], 6528, 0, true],
  ]);
});

test("capFor: measured plus 10%, rounded up to 128 bytes", async () => {
  const { capFor } = await load("modules.mjs");
  assert.deepStrictEqual([capFor(100), capFor(116), capFor(117), capFor(4146)], [128, 128, 256, 4608]);
});

test("a row without a cap fails with the measured size and the cap to use", async () => {
  const { parseRegistry } = await load("registry.mjs");
  const { checkModules, capFor } = await load("modules.mjs");
  const css = text(50);
  const dir = site({ "css/modootoday.css": css });
  const fails = [];
  checkModules(dir, parseRegistry(registry("", "core|sheet|/assets/css/modootoday.css||")), fails, []);
  assert.deepStrictEqual(fails, [`css/modootoday.css: no cap; measured ${gz(css)} B gzip -> cap ${capFor(gz(css))} (sixth column of its registry row)`]);
});

test("over the cap fails that file only; a loose cap warns; a theme file without a row fails", async () => {
  const { parseRegistry } = await load("registry.mjs");
  const { checkModules } = await load("modules.mjs");
  const dir = site({ "css/modootoday/big.css": text(400), "css/modootoday/small.css": ".a{color:red}", "js/modootoday/stray.js": "x()", "css/site.css": "a{}" });
  const fails = [];
  const warns = [];
  checkModules(dir, parseRegistry(registry("big|css|/assets/css/modootoday/big.css|||128\nsmall|css|/assets/css/modootoday/small.css|||1024")), fails, warns);
  assert.strictEqual(fails.length, 2);
  assert.match(fails[0], /^css\/modootoday\/big\.css: \d+ B gzip > cap 128 B/);
  assert.match(fails[1], /^js\/modootoday\/stray\.js: a theme file without a row/);
  assert.match(warns[0], /^css\/modootoday\/small\.css: cap 1024 B is over twice/);
});

test("page types: the theme limit is the sum of the caps a page loads; guide targets warn, components excepted", async () => {
  const { parseRegistry } = await load("registry.mjs");
  const { checkModules } = await load("modules.mjs");
  const { checkTypes } = await load("types.mjs");
  const head = '<link rel="stylesheet" href="/assets/css/modootoday.css?v=1"><link rel="stylesheet" href="/assets/css/site.css">' +
    '<script type="module" src="/assets/js/modootoday/m.js"></script>';
  const dir = site({ "css/modootoday.css": crypto.randomBytes(9000).toString("base64"), "css/site.css": "a{}", "js/modootoday/m.js": 'import "./d.js";', "js/modootoday/d.js": "x()" },
    { "a/index.html": head, "s/index.html": head });
  const modules = checkModules(dir, parseRegistry(registry("m|module|/assets/js/modootoday/m.js|||128|/assets/js/modootoday/d.js",
    "core|sheet|/assets/css/modootoday.css|||16384\nd|import|/assets/js/modootoday/d.js|||128")), [], []);
  const fails = [];
  const warns = [];
  const types = checkTypes(dir, modules, fails, warns, { doc: { pages: ["a/"] }, components: { pages: ["s/"] } });
  assert.deepStrictEqual(fails, []);
  assert.deepStrictEqual(types.doc.pages[0].limit, { css: 16384, js: 256 });
  assert.strictEqual(types.doc.sheets, 1);
  assert.deepStrictEqual(warns.map((w) => w.split(":")[0]), ["page type doc"]);
});
