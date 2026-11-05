// jsdom tests for the showcase dismiss module (chrome/showcase.js) and its pre-paint line in chrome/theme-init.js. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const fs = require("node:fs");
const path = require("node:path");
const { JSDOM } = require("jsdom");
const { JS, run } = require("../support/module.js");

const INIT = fs.readFileSync(path.join(JS, "chrome/theme-init.js"), "utf8");
const BAR = '<div class="mt-showcase-region mt-showcase-bar" role="region" aria-label="Theme showcase"><a href="#">Docs</a>' +
  '<button class="mt-showcase-dismiss" type="button" aria-label="Hide for this visit"></button></div><a class="mt-skip" href="#mt-main">Skip</a>';

// Runs theme-init.js as the blocking head script of a page whose <html> and script tag carry the given attributes.
function prepaint({ html = 'data-mt-showcase="bar"', script = "", session = {}, local = {} } = {}) {
  return new JSDOM(`<!doctype html><html ${html}><head><script ${script}>${INIT}</script></head><body></body></html>`, {
    url: "https://x.test/",
    runScripts: "dangerously",
    beforeParse(w) {
      Object.entries(session).forEach(([k, v]) => w.sessionStorage.setItem(k, v));
      Object.entries(local).forEach(([k, v]) => w.localStorage.setItem(k, v));
    },
  }).window.document.documentElement;
}

test("dismiss sets data-mt-showcase off, stores the visit flag and moves focus to the skip link", async () => {
  const w = new JSDOM(`<!doctype html><html data-mt-showcase="bar"><body>${BAR}</body></html>`, { url: "https://x.test/" }).window;
  await run("chrome/showcase.js", w);
  w.document.querySelector(".mt-showcase-dismiss").click();
  assert.strictEqual(w.document.documentElement.dataset.mtShowcase, "off");
  assert.strictEqual(w.sessionStorage.getItem("mt-showcase"), "off");
  assert.strictEqual(w.document.activeElement, w.document.querySelector(".mt-skip"));
});

test("without storage the dismiss still hides the showcase on this page", async () => {
  const w = new JSDOM(`<!doctype html><html data-mt-showcase="pill"><body>${BAR}</body></html>`, { url: "https://x.test/" }).window;
  Object.defineProperty(w, "sessionStorage", { get() { throw new Error("blocked"); } });
  await run("chrome/showcase.js", w);
  w.document.querySelector(".mt-showcase-dismiss").click();
  assert.strictEqual(w.document.documentElement.dataset.mtShowcase, "off");
});

test("theme-init turns a showcase off before paint once the visit flag is stored", () => {
  assert.strictEqual(prepaint({ session: { "mt-showcase": "off" } }).dataset.mtShowcase, "off");
  assert.strictEqual(prepaint().dataset.mtShowcase, "bar");
});

test("theme-init leaves a page without a showcase alone", () => {
  assert.strictEqual(prepaint({ html: "", session: { "mt-showcase": "off" } }).dataset.mtShowcase, undefined);
});

test("theme-init applies the stored scheme unless the tag says the page has no toggle", () => {
  assert.strictEqual(prepaint({ local: { "mt-theme": "dark" } }).dataset.theme, "dark");
  assert.strictEqual(prepaint({ script: "data-mt-no-theme", local: { "mt-theme": "dark" } }).dataset.theme, undefined);
  assert.strictEqual(prepaint({ script: "data-mt-no-theme", local: { "mt-theme": "dark" }, session: { "mt-showcase": "off" } }).dataset.mtShowcase, "off");
});
