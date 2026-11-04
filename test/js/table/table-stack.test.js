// jsdom tests for assets/js/modootoday/table-stack.js: roles and column labels of stack and dl tables. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const fs = require("node:fs");
const path = require("node:path");
const { JSDOM } = require("jsdom");

const SRC = fs.readFileSync(path.join(__dirname, "../../../assets/js/modootoday/table-stack.js"), "utf8");
const HEAD = "<thead><tr><th>Key</th><th>Type</th><th>Default</th><th>Description</th></tr></thead>";
const BODY = "<tbody><tr><td><code>badges</code></td><td>boolean</td><td>true</td><td>Status badges</td></tr></tbody>";

function run(body) {
  const w = new JSDOM(`<!doctype html><html><body><main class="mt-main">${body}</main></body></html>`, { runScripts: "outside-only" }).window;
  w.eval(SRC);
  return w.document;
}

test("stack and dl tables get explicit roles, header labels on body cells, and the labelled flag", () => {
  const d = run(`<div class="mt-table"><table class="mt-table--stack">${HEAD}${BODY}</table></div>` +
    '<div class="mt-table"><table class="mt-table--dl"><tbody><tr><th scope="row">Key</th><td>Value</td></tr></tbody></table></div>');
  const [stack, dl] = d.querySelectorAll("table");
  assert.strictEqual(stack.getAttribute("role"), "table");
  assert.strictEqual(stack.hasAttribute("data-mt-labelled"), true);
  assert.deepStrictEqual([...stack.querySelectorAll("tbody td")].map((c) => c.dataset.label), ["Key", "Type", "Default", "Description"]);
  assert.deepStrictEqual([...stack.querySelectorAll("thead, tr, th")].map((e) => e.getAttribute("role")),
    ["rowgroup", "row", "columnheader", "columnheader", "columnheader", "columnheader", "row"]);
  assert.strictEqual(stack.querySelector("td").getAttribute("role"), "cell");
  assert.strictEqual(dl.querySelector("th").getAttribute("role"), "rowheader");
  assert.strictEqual(dl.querySelector("td").hasAttribute("data-label"), false, "no header row, no labels");
});

test("a plain table gets no roles or labels", () => {
  const d = run(`<div class="mt-table"><table>${HEAD}${BODY}</table></div>`);
  assert.strictEqual(d.querySelector("table").hasAttribute("role"), false);
  assert.strictEqual(d.querySelector("td").hasAttribute("data-label"), false);
});
