// jsdom tests for the mt:themechange event of assets/js/modootoday/theme-toggle.js. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const fs = require("node:fs");
const path = require("node:path");
const { JSDOM } = require("jsdom");

const source = fs.readFileSync(path.join(__dirname, "../../../assets/js/modootoday/theme-toggle.js"), "utf8");

// A page with the toggle and a controllable system setting; events collects every mt:themechange detail.
function page(dark = false) {
  const w = new JSDOM('<!doctype html><html><body><button class="mt-theme-toggle" aria-pressed="false" hidden>Theme</button></body></html>', { runScripts: "outside-only", url: "https://x.test/" }).window;
  const listeners = [];
  const mq = { matches: dark, addEventListener: (type, fn) => listeners.push(fn) };
  w.matchMedia = () => mq;
  const events = [];
  w.document.addEventListener("mt:themechange", (e) => events.push({ ...e.detail }));
  w.eval(source);
  const system = (value) => {
    mq.matches = value;
    listeners.forEach((fn) => fn());
  };
  return { w, events, system, button: w.document.querySelector("button") };
}

test("a click sends one mt:themechange with the new theme and source toggle", () => {
  const { w, events, button } = page();
  button.click();
  assert.deepStrictEqual(events, [{ theme: "dark", source: "toggle" }]);
  assert.strictEqual(w.document.documentElement.dataset.theme, "dark");
  button.click();
  assert.deepStrictEqual(events[1], { theme: "light", source: "toggle" });
  assert.strictEqual(events.length, 2);
});

test("nothing is sent on load", () => {
  const { events, button } = page(true);
  assert.strictEqual(events.length, 0);
  assert.strictEqual(button.getAttribute("aria-pressed"), "true");
});

test("a system change sends source system while no scheme is chosen", () => {
  const { events, system, button } = page();
  system(true);
  assert.deepStrictEqual(events, [{ theme: "dark", source: "system" }]);
  assert.strictEqual(button.getAttribute("aria-pressed"), "true");
});

test("a system change after a click keeps the chosen scheme and sends nothing", () => {
  const { events, system, button } = page();
  button.click();
  system(true);
  system(false);
  assert.strictEqual(events.length, 1);
  assert.strictEqual(button.getAttribute("aria-pressed"), "true");
});

test("without a toggle button nothing runs and no event is sent", () => {
  const w = new JSDOM("<!doctype html><html><body></body></html>", { runScripts: "outside-only" }).window;
  let n = 0;
  w.document.addEventListener("mt:themechange", () => n++);
  w.matchMedia = () => ({ matches: false, addEventListener() {} });
  w.eval(source);
  assert.strictEqual(n, 0);
});
