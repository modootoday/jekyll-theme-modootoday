// jsdom test for assets/js/modootoday/structure/tabs.js (ARIA tabs). Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const fs = require("node:fs");
const path = require("node:path");
const { JSDOM } = require("jsdom");
const { run } = require("./support/module.js");

async function load(rtl) {
  let html = fs.readFileSync(path.join(__dirname, "../fixtures/tabs.html"), "utf8");
  if (rtl) html = html.replace(/<html\b/i, '<html dir="rtl"');
  const dom = new JSDOM(html, { runScripts: "outside-only" });
  await run("structure/tabs.js", dom.window);
  const d = dom.window.document;
  const groups = [...d.querySelectorAll("[role=tablist]")].map((l) => [...l.querySelectorAll("[role=tab]")]);
  const key = (el, k) => el.dispatchEvent(new dom.window.KeyboardEvent("keydown", { key: k, bubbles: true }));
  const panel = (t) => d.getElementById(t.getAttribute("aria-controls"));
  return { d, groups, key, panel };
}

test("builds one tablist per eligible group with a label", async () => {
  const { d, groups } = await load();
  assert.strictEqual(groups.length, 2);
  assert.deepStrictEqual(groups.map((g) => g.length), [3, 2]);
  assert.strictEqual(d.querySelector("[role=tablist]").getAttribute("aria-label"), "Install method");
  assert.strictEqual(d.querySelectorAll("[role=tablist]")[1].getAttribute("aria-label"), "Options");
});

test("initial state: first tab selected, others hidden, panels focusable", async () => {
  const { groups, panel } = await load();
  const [a, b] = groups[0];
  assert.strictEqual(a.getAttribute("aria-selected"), "true");
  assert.strictEqual(a.tabIndex, 0);
  assert.strictEqual(b.tabIndex, -1);
  assert.ok(!panel(a).hidden && panel(b).hidden);
  for (const t of groups.flat()) {
    assert.strictEqual(panel(t).getAttribute("role"), "tabpanel");
    assert.strictEqual(panel(t).getAttribute("tabindex"), "0");
    assert.strictEqual(panel(t).getAttribute("aria-labelledby"), t.id);
  }
});

test("ids are unique across groups", async () => {
  const { d } = await load();
  const ids = [...d.querySelectorAll("[id]")].map((e) => e.id);
  assert.strictEqual(new Set(ids).size, ids.length);
});

test("click, arrows (wrapping), Home and End", async () => {
  const { d, groups, key, panel } = await load();
  const g = groups[0];
  g[1].click();
  assert.ok(panel(g[0]).hidden && !panel(g[1]).hidden);
  g[2].focus(); key(g[2], "ArrowRight");
  assert.strictEqual(d.activeElement, g[0]);
  key(g[0], "ArrowLeft");
  assert.strictEqual(d.activeElement, g[2]);
  key(g[2], "Home");
  assert.strictEqual(d.activeElement, g[0]);
  assert.strictEqual(g[0].getAttribute("aria-selected"), "true");
  key(g[0], "End");
  assert.strictEqual(d.activeElement, g[2]);
  assert.ok(!panel(g[2]).hidden);
  // other group untouched
  assert.strictEqual(groups[1][0].getAttribute("aria-selected"), "true");
});

test("headings are hidden; single-pair sections are left alone", async () => {
  const { d } = await load();
  assert.ok([...d.querySelectorAll("section[data-tabs] > h3")].slice(0, 5).every((h) => h.hidden));
  assert.strictEqual(d.querySelectorAll("section")[2].querySelector("h3").hidden, false);
});

test("RTL: ArrowLeft moves to the next tab (visual order)", async () => {
  const { d, groups, key } = await load(true);
  const g = groups[0];
  g[0].focus(); key(g[0], "ArrowLeft");
  assert.strictEqual(d.activeElement, g[1]);
  key(g[1], "ArrowRight");
  assert.strictEqual(d.activeElement, g[0]);
});
