// jsdom tests for assets/js/modootoday/chrome/search-keys.js: it shows the box at once and imports chrome/search.js only on
// first use (focus, / or Ctrl+K), so a visit that never searches loads no search code. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const { JSDOM } = require("jsdom");
const { run } = require("../support/module.js");

const INDEX = [{ title: "Install", url: "/install/", lang: "en", text: "Add the gem." }];

async function page() {
  const html = '<!doctype html><html lang="en"><body><p id="p">x</p><a id="after" href="#">after</a><div class="mt-search" data-index="/search.json" hidden>' +
    '<input type="search"><ul class="mt-search-results"></ul></div></body></html>';
  const w = new JSDOM(html, { url: "https://x.test/" }).window;
  let fetched = 0;
  w.fetch = async () => {
    fetched++;
    return { json: async () => JSON.parse(JSON.stringify(INDEX)) };
  };
  await run("chrome/search-keys.js", w);
  const box = w.document.querySelector(".mt-search");
  const input = box.querySelector("input");
  const settle = () => new Promise((r) => setTimeout(r, 20));
  return { w, box, input, settle, fetched: () => fetched };
}

test("the box shows at once; search.js and the index wait for the first focus", async () => {
  const { box, input, settle, fetched } = await page();
  assert.strictEqual(box.hidden, false);
  assert.strictEqual(box.mtRender, undefined);
  assert.strictEqual(fetched(), 0);
  input.dispatchEvent(new input.ownerDocument.defaultView.FocusEvent("focus"));
  await settle();
  assert.strictEqual(typeof box.mtRender, "function");
  assert.strictEqual(fetched(), 1);
  input.value = "install";
  input.dispatchEvent(new input.ownerDocument.defaultView.Event("input"));
  await settle();
  assert.deepStrictEqual([...box.querySelectorAll(".mt-search-title")].map((e) => e.textContent), ["Install"]);
});

test("/ outside a field focuses the box and starts the search; Esc clears it", async () => {
  const { w, box, input, settle } = await page();
  w.document.getElementById("p").dispatchEvent(new w.KeyboardEvent("keydown", { key: "/", bubbles: true }));
  await settle();
  assert.strictEqual(w.document.activeElement, input);
  assert.strictEqual(typeof box.mtRender, "function");
  input.value = "install";
  input.dispatchEvent(new w.Event("input"));
  await settle();
  input.dispatchEvent(new w.KeyboardEvent("keydown", { key: "Escape", bubbles: true }));
  assert.strictEqual(input.value, "");
  assert.strictEqual(box.querySelectorAll("li").length, 0);
});

test("Tab out of the box closes the results, and focus back in shows them again", async () => {
  const { w, box, input } = await page();
  const out = box.querySelector("ul");
  const after = w.document.getElementById("after");
  input.dispatchEvent(new w.FocusEvent("focusout", { bubbles: true, relatedTarget: after }));
  assert.strictEqual(out.hidden, true);
  input.dispatchEvent(new w.FocusEvent("focusin", { bubbles: true }));
  assert.strictEqual(out.hidden, false);
  input.dispatchEvent(new w.FocusEvent("focusout", { bubbles: true, relatedTarget: null }));
  assert.strictEqual(out.hidden, false, "a click elsewhere leaves the list for a link that takes no focus");
});
