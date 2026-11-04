// jsdom tests for assets/js/modootoday/scroll-region.js: scroll regions on overflowing code and table wrappers. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const fs = require("node:fs");
const path = require("node:path");
const { JSDOM } = require("jsdom");

const SRC = fs.readFileSync(path.join(__dirname, "../../../assets/js/modootoday/scroll-region.js"), "utf8");
const HEAD = "<thead><tr><th>Key</th><th>Type</th><th>Default</th><th>Description</th></tr></thead>";
const BODY = "<tbody><tr><td><code>badges</code></td><td>boolean</td><td>true</td><td>Status badges</td></tr></tbody>";

// jsdom has no layout, so widths are set per element: data-w is scrollWidth, clientWidth is 100.
function run(body) {
  const w = new JSDOM(`<!doctype html><html data-mt-table="표" data-mt-code="코드"><body><main class="mt-main">${body}</main></body></html>`,
    { runScripts: "outside-only" }).window;
  for (const el of w.document.querySelectorAll("[data-w]")) {
    Object.defineProperty(el, "scrollWidth", { value: +el.dataset.w });
    Object.defineProperty(el, "clientWidth", { value: 100 });
  }
  w.eval(SRC);
  return w.document;
}

test("an overflowing table wrapper becomes a labelled focusable region; a fitting one stays plain", () => {
  const d = run(`<div class="mt-table" id="wide" data-w="300"><table>${HEAD}${BODY}</table></div>` +
    `<div class="mt-table" id="fits" data-w="100"><table>${HEAD}${BODY}</table></div>`);
  const wide = d.getElementById("wide");
  assert.deepStrictEqual([wide.tabIndex, wide.getAttribute("role"), wide.getAttribute("aria-label")], [0, "region", "표"]);
  assert.strictEqual(d.getElementById("fits").hasAttribute("role"), false);
  assert.strictEqual(d.querySelector("table").hasAttribute("tabindex"), false, "the table itself is not the region");
});

test("an overflowing code block is labelled with the code string", () => {
  const d = run('<pre data-w="300"><code>x</code></pre>');
  assert.strictEqual(d.querySelector("pre").getAttribute("aria-label"), "코드");
});
