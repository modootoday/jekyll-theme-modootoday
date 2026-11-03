// Tests for the module helper assets/js/modootoday/theme/current.js. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const path = require("node:path");
const { pathToFileURL } = require("node:url");
const { JSDOM } = require("jsdom");

const load = (rel) => import(pathToFileURL(path.join(__dirname, "../../../assets/js/modootoday", rel)).href);

// Points the module globals at a fresh jsdom page whose system setting the test controls.
function page(dark = false) {
  const w = new JSDOM("<!doctype html><html><body></body></html>").window;
  const listeners = new Set();
  const mq = { matches: dark, addEventListener: (t, fn) => listeners.add(fn), removeEventListener: (t, fn) => listeners.delete(fn) };
  globalThis.document = w.document;
  globalThis.matchMedia = () => mq;
  const system = (value) => {
    mq.matches = value;
    listeners.forEach((fn) => fn());
  };
  const send = (theme, source) => w.document.dispatchEvent(new w.CustomEvent("mt:themechange", { detail: { theme, source } }));
  return { w, system, send, listeners };
}

test("currentTheme: data-theme wins, else the system setting", async () => {
  const { currentTheme } = await load("theme/current.js");
  const { w } = page(true);
  assert.strictEqual(currentTheme(), "dark");
  w.document.documentElement.dataset.theme = "light";
  assert.strictEqual(currentTheme(), "light");
});

test("onThemeChange: one call per real change, from the toggle event or the system", async () => {
  const { onThemeChange } = await load("theme/current.js");
  const { w, system, send } = page();
  const seen = [];
  onThemeChange((t) => seen.push(t));
  w.document.documentElement.dataset.theme = "dark";
  send("dark", "toggle");
  system(true);
  delete w.document.documentElement.dataset.theme;
  system(false);
  assert.deepStrictEqual(seen, ["dark", "light"]);
});

test("onThemeChange: the returned function stops both listeners", async () => {
  const { onThemeChange } = await load("theme/current.js");
  const { system, send, listeners } = page();
  let n = 0;
  const stop = onThemeChange(() => n++);
  stop();
  system(true);
  send("dark", "system");
  assert.strictEqual(n, 0);
  assert.strictEqual(listeners.size, 0);
});
