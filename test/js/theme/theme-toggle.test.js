// jsdom tests for the mt:themechange event of assets/js/modootoday/chrome/theme-toggle.js. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const { JSDOM } = require("jsdom");
const { run } = require("../support/module.js");


// A page with the toggle and a controllable system setting; events collects every mt:themechange detail.
async function page(dark = false) {
  const w = new JSDOM('<!doctype html><html><body><button class="mt-theme-toggle" aria-pressed="false" hidden>Theme</button></body></html>', { runScripts: "outside-only", url: "https://x.test/" }).window;
  const listeners = [];
  const mq = { matches: dark, addEventListener: (type, fn) => listeners.push(fn) };
  w.matchMedia = () => mq;
  const events = [];
  w.document.addEventListener("mt:themechange", (e) => events.push({ ...e.detail }));
  await run("chrome/theme-toggle.js", w);
  const system = (value) => {
    mq.matches = value;
    listeners.forEach((fn) => fn());
  };
  return { w, events, system, button: w.document.querySelector("button") };
}

test("a click sends one mt:themechange with the new theme and source toggle", async () => {
  const { w, events, button } = await page();
  button.click();
  assert.deepStrictEqual(events, [{ theme: "dark", source: "toggle" }]);
  assert.strictEqual(w.document.documentElement.dataset.theme, "dark");
  button.click();
  assert.deepStrictEqual(events[1], { theme: "light", source: "toggle" });
  assert.strictEqual(events.length, 2);
});

test("nothing is sent on load", async () => {
  const { events, button } = await page(true);
  assert.strictEqual(events.length, 0);
  assert.strictEqual(button.getAttribute("aria-pressed"), "true");
});

test("a system change sends source system while no scheme is chosen", async () => {
  const { events, system, button } = await page();
  system(true);
  assert.deepStrictEqual(events, [{ theme: "dark", source: "system" }]);
  assert.strictEqual(button.getAttribute("aria-pressed"), "true");
});

test("a system change after a click keeps the chosen scheme and sends nothing", async () => {
  const { events, system, button } = await page();
  button.click();
  system(true);
  system(false);
  assert.strictEqual(events.length, 1);
  assert.strictEqual(button.getAttribute("aria-pressed"), "true");
});

test("without a toggle button nothing runs and no event is sent", async () => {
  const w = new JSDOM("<!doctype html><html><body></body></html>", { runScripts: "outside-only" }).window;
  let n = 0;
  w.document.addEventListener("mt:themechange", () => n++);
  w.matchMedia = () => ({ matches: false, addEventListener() {} });
  await run("chrome/theme-toggle.js", w);
  assert.strictEqual(n, 0);
});
