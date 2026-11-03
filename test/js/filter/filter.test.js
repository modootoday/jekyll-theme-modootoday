// jsdom tests for assets/js/modootoday/filter/filter.js (with chips.js): lists, tables, facet chips and keys. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const path = require("node:path");
const { pathToFileURL } = require("node:url");
const { JSDOM } = require("jsdom");

const CONTROLS = '<div class="mt-filter" hidden><input type="search" aria-label="Filter"><output aria-live="polite" data-count="[n] shown"></output></div>';
const LIST = "<ul><li>검색량 조회</li><li>Keyword volume</li><li>Pricing plans</li></ul>";
const TABLE = "<table><thead><tr><th>Tool</th><th>Kind</th></tr></thead><tbody><tr><td>Rank</td><td>Free</td></tr>" +
  "<tr><td>Volume</td><td>Paid</td></tr><tr><td>Trend</td><td>Free</td></tr></tbody></table>";

// The module runs its entry on import, so it is loaded once against an empty page; each test calls initFilter itself.
let mod;
async function page(body) {
  const w = new JSDOM(`<!doctype html><html><body>${body}</body></html>`).window;
  if (!mod) {
    globalThis.document = new JSDOM("<!doctype html><html><body></body></html>").window.document;
    mod = await import(pathToFileURL(path.join(__dirname, "../../../assets/js/modootoday/filter/filter.js")).href);
  }
  globalThis.document = w.document;
  const root = w.document.querySelector("[data-mt-filter]");
  mod.initFilter(root);
  const box = root.querySelector(".mt-filter");
  const input = box.querySelector("input");
  const type = (q) => {
    input.value = q;
    input.dispatchEvent(new w.Event("input"));
  };
  const shown = () => [...root.querySelectorAll("li, tbody tr")].filter((r) => !r.hidden).map((r) => r.textContent);
  return { w, root, box, input, type, shown, count: () => box.querySelector("output").textContent };
}

test("list: the controls move before the list and show, with the count", async () => {
  const { root, box, count } = await page(`<section data-mt-filter><h2>Tools</h2>${LIST}${CONTROLS}</section>`);
  assert.strictEqual(box.hidden, false);
  assert.strictEqual(box.nextElementSibling, root.querySelector("ul"));
  assert.strictEqual(count(), "3 shown");
});

test("list: every word, in any order, ignoring case and Korean spacing", async () => {
  const { type, shown, count } = await page(`<section data-mt-filter>${LIST}${CONTROLS}</section>`);
  type("VOLUME keyword");
  assert.deepStrictEqual(shown(), ["Keyword volume"]);
  assert.strictEqual(count(), "1 shown");
  type("검색량조회");
  assert.deepStrictEqual(shown(), ["검색량 조회"]);
  type("");
  assert.strictEqual(shown().length, 3);
});

test("table: rows of the body are filtered, the header stays", async () => {
  const { root, type, shown } = await page(`<div class="mt-prose" data-mt-filter>${TABLE}${CONTROLS}</div>`);
  type("free");
  assert.deepStrictEqual(shown(), ["RankFree", "TrendFree"]);
  assert.strictEqual(root.querySelector("thead tr").hidden, false);
});

test("facet: one chip per value of the column, named by its header; one value at a time", async () => {
  const { box, type, shown, count } = await page(`<section data-mt-filter data-facet="2">${TABLE}${CONTROLS}</section>`);
  const group = box.querySelector(".mt-filter-chips");
  assert.strictEqual(group.getAttribute("role"), "group");
  assert.strictEqual(group.getAttribute("aria-label"), "Kind");
  const [free, paid] = group.querySelectorAll("button");
  assert.deepStrictEqual([free.textContent, paid.textContent, free.type], ["Free", "Paid", "button"]);
  paid.click();
  assert.deepStrictEqual(shown(), ["VolumePaid"]);
  assert.deepStrictEqual([free.getAttribute("aria-pressed"), paid.getAttribute("aria-pressed")], ["false", "true"]);
  free.click();
  assert.deepStrictEqual(shown(), ["RankFree", "TrendFree"]);
  type("trend");
  assert.deepStrictEqual(shown(), ["TrendFree"]);
  assert.strictEqual(count(), "1 shown");
  type("");
  free.click();
  assert.strictEqual(free.getAttribute("aria-pressed"), "false");
  assert.strictEqual(shown().length, 3);
});

test("keyboard: Escape in the field clears it and shows everything again", async () => {
  const { w, input, type, shown } = await page(`<section data-mt-filter>${LIST}${CONTROLS}</section>`);
  type("pricing");
  const esc = new w.KeyboardEvent("keydown", { key: "Escape", cancelable: true });
  input.dispatchEvent(esc);
  assert.strictEqual(esc.defaultPrevented, true);
  assert.strictEqual(input.value, "");
  assert.strictEqual(shown().length, 3);
  const again = new w.KeyboardEvent("keydown", { key: "Escape", cancelable: true });
  input.dispatchEvent(again);
  assert.strictEqual(again.defaultPrevented, false);
});

test("only the first direct list is filtered; without one the controls stay hidden", async () => {
  const nested = await page(`<section data-mt-filter>${LIST}<ul><li>Other</li></ul>${CONTROLS}</section>`);
  nested.type("zzz");
  assert.deepStrictEqual(nested.shown(), ["Other"]);
  const none = await page(`<section data-mt-filter><p>No list.</p>${CONTROLS}</section>`);
  assert.strictEqual(none.box.hidden, true);
});
