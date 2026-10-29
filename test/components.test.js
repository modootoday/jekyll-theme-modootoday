// jsdom tests for assets/js/modootoday/{accordion,theme-toggle,code-copy}.js. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const fs = require("node:fs");
const path = require("node:path");
const { JSDOM } = require("jsdom");

const js = (n) => fs.readFileSync(path.join(__dirname, "../assets/js/modootoday", n), "utf8");
function dom(body, opts = {}) {
  const d = new JSDOM(`<!doctype html><html><body>${body}</body></html>`, { runScripts: "outside-only", url: "https://x.test/", ...opts });
  return d;
}

test("accordion: each ### becomes a collapsed disclosure button", () => {
  const w = dom('<section data-c="accordion"><h2>FAQ</h2><h3>Q1</h3><p>A1</p><p>A1b</p><h3>Q2</h3><p>A2</p></section><h3>Out</h3>').window;
  w.eval(js("accordion.js"));
  const b = [...w.document.querySelectorAll(".mt-accordion-trigger")];
  assert.strictEqual(b.length, 2);
  const p = w.document.getElementById(b[0].getAttribute("aria-controls"));
  assert.strictEqual(b[0].getAttribute("aria-expanded"), "false");
  assert.strictEqual(p.hidden, true);
  assert.strictEqual(p.querySelectorAll("p").length, 2);
  assert.strictEqual(b[0].textContent, "Q1");
  assert.strictEqual(b[0].parentElement.tagName, "H3");
  b[0].click();
  assert.strictEqual(b[0].getAttribute("aria-expanded"), "true");
  assert.strictEqual(p.hidden, false);
  assert.strictEqual(w.document.querySelectorAll("h3 > button").length, 2, "h3 outside the section untouched");
});

test("theme toggle: shows, flips data-theme, stores it, aria-pressed follows", () => {
  const w = dom('<button class="mt-theme-toggle" aria-pressed="false" hidden>Dark mode</button>').window;
  w.matchMedia = () => ({ matches: false, addEventListener() {} });
  w.eval(js("theme-toggle.js"));
  const b = w.document.querySelector("button");
  assert.strictEqual(b.hidden, false);
  assert.strictEqual(b.getAttribute("aria-pressed"), "false");
  b.click();
  assert.strictEqual(w.document.documentElement.dataset.theme, "dark");
  assert.strictEqual(w.localStorage.getItem("mt-theme"), "dark");
  assert.strictEqual(b.getAttribute("aria-pressed"), "true");
  b.click();
  assert.strictEqual(w.document.documentElement.dataset.theme, "light");
});

test("code copy: adds one button per block with the label from <html>", () => {
  const w = dom('<main class="mt-main"><div class="highlighter-rouge"><pre>a</pre></div><pre>b</pre></main>').window;
  w.document.documentElement.dataset.mtCopy = "복사";
  Object.defineProperty(w.navigator, "clipboard", { value: { writeText: () => Promise.resolve() } });
  w.eval(js("code-copy.js"));
  const b = w.document.querySelectorAll(".mt-code-copy");
  assert.strictEqual(b.length, 2);
  assert.strictEqual(b[0].textContent, "복사");
  assert.ok(w.document.querySelector("[aria-live]"));
});
