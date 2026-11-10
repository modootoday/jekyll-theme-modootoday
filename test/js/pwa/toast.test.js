// jsdom tests for assets/js/modootoday/pwa/update-toast.js: the update notice shows only for new theme files, after its
// sheet, without taking focus; Escape and Later close it; Reload hands over to the waiting worker. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const { JSDOM } = require("jsdom");
const { load } = require("../support/module.js");

const LINK = '<link rel="manifest" href="/docs/manifest.webmanifest" data-mt-sw="/docs/sw.js" data-mt-scope="/docs/" ' +
  'data-mt-toast-css="/docs/assets/css/modootoday/chrome/toast.css?v=1" data-mt-update="New version" data-mt-reload="Reload" data-mt-later="Later">';
const BOTH = ["mt:/docs/:assets:1", "mt:/docs/:assets:2", "mt:/docs/:pages:1", "mt:/other/:assets:9"];

// A page with Cache Storage names, a waiting worker that records its messages and a page reload counter.
function page(names = BOTH) {
  const w = new JSDOM(`<!doctype html><html><head>${LINK}</head><body><button id="b">x</button></body></html>`, { url: "https://x.test/docs/a/" }).window;
  const posted = [];
  const changes = [];
  w.caches = { keys: async () => names };
  Object.defineProperty(w.navigator, "serviceWorker", { value: { addEventListener: (type, fn, opts) => changes.push([type, fn, opts]) } });
  const reg = { waiting: { postMessage: (m) => posted.push(m) } };
  return { w, doc: w.document, reg, posted, changes };
}

// The sheet link the module adds; jsdom loads no stylesheet, so the test fires its load event.
async function sheetLoads(doc) {
  for (let i = 0; i < 20 && !doc.querySelector("link[rel=stylesheet]"); i++) {
    await new Promise((r) => setTimeout(r, 1));
  }
  const css = doc.querySelector("link[rel=stylesheet]");
  css.dispatchEvent(new doc.defaultView.Event("load"));
  return css;
}

const buttons = (doc) => [...doc.querySelectorAll(".mt-toast button")].map((b) => b.textContent);

test("new theme files: the notice shows after its sheet, as a status, and focus stays", async () => {
  const { doc, reg } = page();
  const m = await load("pwa/update-toast.js");
  doc.getElementById("b").focus();
  const shown = m.update(doc, reg);
  const css = await sheetLoads(doc);
  assert.strictEqual(css.getAttribute("href"), "/docs/assets/css/modootoday/chrome/toast.css?v=1");
  assert.strictEqual(doc.querySelector(".mt-toast").getAttribute("role"), "status");
  await shown;
  assert.strictEqual(doc.querySelector(".mt-toast p").textContent, "New version");
  assert.deepStrictEqual(buttons(doc), ["Reload", "Later"]);
  assert.strictEqual(doc.activeElement.id, "b");
});

test("the same theme files, or no waiting worker, show nothing", async () => {
  const m = await load("pwa/update-toast.js");
  const same = page(["mt:/docs/:assets:1", "mt:/docs/:pages:1", "mt:/other/:assets:9"]);
  await m.update(same.doc, same.reg);
  assert.strictEqual(same.doc.querySelector(".mt-toast"), null);
  const gone = page();
  gone.reg.waiting = null;
  await m.update(gone.doc, gone.reg);
  assert.strictEqual(gone.doc.querySelector(".mt-toast"), null);
});

test("Escape and Later close it; an Escape a component handled does not", async () => {
  const { w, doc, reg } = page();
  const m = await load("pwa/update-toast.js");
  const shown = m.update(doc, reg);
  await sheetLoads(doc);
  await shown;
  const esc = new w.KeyboardEvent("keydown", { key: "Escape", bubbles: true, cancelable: true });
  esc.preventDefault();
  doc.body.dispatchEvent(esc);
  assert.deepStrictEqual(buttons(doc), ["Reload", "Later"]);
  doc.body.dispatchEvent(new w.KeyboardEvent("keydown", { key: "Escape", bubbles: true }));
  assert.deepStrictEqual(buttons(doc), []);
  await m.update(doc, reg);
  doc.querySelectorAll(".mt-toast button")[1].click();
  assert.deepStrictEqual(buttons(doc), []);
  assert.strictEqual(doc.querySelectorAll(".mt-toast").length, 1, "one region per page");
});

test("Reload asks the waiting worker to take over and reloads once when it does", async () => {
  const { doc, reg, posted, changes } = page();
  const m = await load("pwa/update-toast.js");
  const shown = m.update(doc, reg);
  await sheetLoads(doc);
  await shown;
  doc.querySelector(".mt-toast button").click();
  assert.deepStrictEqual(posted, [{ type: "mt:skip" }]);
  assert.strictEqual(changes.length, 1);
  assert.strictEqual(changes[0][0], "controllerchange");
  assert.deepStrictEqual(changes[0][2], { once: true });
});
