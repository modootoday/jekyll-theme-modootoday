// jsdom tests for assets/js/modootoday/data/table-stack.js: roles and column labels of stack and dl tables, and
// tables that stack below 40rem because they do not fit. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const { JSDOM } = require("jsdom");
const { run: load } = require("../support/module.js");

const HEAD = "<thead><tr><th>Key</th><th>Type</th><th>Default</th><th>Description</th></tr></thead>";
const BODY = "<tbody><tr><td><code>badges</code></td><td>boolean</td><td>true</td><td>Status badges</td></tr></tbody>";
const HEAD3 = "<thead><tr><th>Key</th><th>Default</th><th>Effect</th></tr></thead>";
const BODY3 = "<tbody><tr><td><code>navigation.badges</code></td><td>true</td><td>Status badges</td></tr></tbody>";

// jsdom has no layout: data-w is a wrapper's scrollWidth (clientWidth 100), data-h a cell's height (20px lines).
async function run(body, phone) {
  const w = new JSDOM(`<!doctype html><html><body><main class="mt-main">${body}</main></body></html>`, { runScripts: "outside-only" }).window;
  for (const el of w.document.querySelectorAll("[data-w]")) {
    Object.defineProperty(el, "scrollWidth", { value: +el.dataset.w });
    Object.defineProperty(el, "clientWidth", { value: 100 });
  }
  for (const el of w.document.querySelectorAll("[data-h]")) {
    el.getBoundingClientRect = () => ({ height: +el.dataset.h });
  }
  if (phone) {
    w.matchMedia = () => phone;
  }
  await load("data/table-stack.js", w);
  return w.document;
}

const media = (matches) => ({ matches, addEventListener(type, fn) {
  this.fire = () => fn({ matches: true });
} });

test("stack and dl tables get explicit roles, header labels on body cells, and the labelled flag", async () => {
  const d = await run(`<div class="mt-table"><table class="mt-table--stack">${HEAD}${BODY}</table></div>` +
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

test("a plain table gets no roles or labels", async () => {
  const d = await run(`<div class="mt-table" data-w="300"><table>${HEAD3}${BODY3}</table></div>`);
  assert.strictEqual(d.querySelector("table").hasAttribute("role"), false);
  assert.strictEqual(d.querySelector("td").hasAttribute("data-label"), false);
});

test("below 40rem a table that scrolls or has a cell over 6 lines stacks; one that fits stays a table", async () => {
  const d = await run(`<div class="mt-table" data-w="300"><table id="wide">${HEAD3}${BODY3}</table></div>` +
    `<div class="mt-table" data-w="100"><table id="fits">${HEAD3}${BODY3}</table></div>` +
    `<div class="mt-table" data-w="300"><table id="tall">${HEAD}${BODY.replace("<td>Status", '<td data-h="160">Status')}</table></div>` +
    `<div class="mt-table" data-w="300"><table id="short">${HEAD}${BODY.replace("<td>Status", '<td data-h="120">Status')}</table></div>` +
    `<div class="mt-table" data-w="300"><table id="fixed" class="mt-table--fixed">${HEAD3}${BODY3}</table></div>`, media(true));
  const stacked = (id) => d.getElementById(id).matches(".mt-table--stack[data-mt-labelled][role=table]");
  assert.deepStrictEqual(["wide", "fits", "tall", "short", "fixed"].map(stacked), [true, false, true, false, false]);
  assert.deepStrictEqual([...d.querySelectorAll("#wide td")].map((c) => c.dataset.label), ["Key", "Default", "Effect"]);
});

test("a wide window stacks nothing until it narrows below 40rem", async () => {
  const phone = media(false);
  const d = await run(`<div class="mt-table" data-w="300"><table>${HEAD3}${BODY3}</table></div>`, phone);
  assert.strictEqual(d.querySelector("table").hasAttribute("data-mt-labelled"), false);
  phone.fire();
  assert.strictEqual(d.querySelector("table").classList.contains("mt-table--stack"), true);
});
