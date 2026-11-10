// jsdom tests for assets/js/modootoday/pwa/offline.js: the offline page lists the pages this scope's worker keeps, with
// titles inserted as text. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const { JSDOM } = require("jsdom");
const { load } = require("../support/module.js");

const BODY = '<section data-mt-offline hidden><h2>Pages</h2><ul></ul></section>';
const LINK = '<link rel="manifest" href="/docs/manifest.webmanifest" data-mt-sw="/docs/sw.js" data-mt-scope="/docs/">';

// caches: cache name => {url: html}.
function fakeCaches(caches) {
  const open = async (name) => ({
    keys: async () => Object.keys(caches[name]).map((url) => ({ url })),
    match: async (req) => new Response(caches[name][req.url]),
  });
  return { keys: async () => Object.keys(caches), open };
}

async function page(caches, head = LINK) {
  const w = new JSDOM(`<!doctype html><html><head>${head}</head><body>${BODY}</body></html>`, { url: "https://x.test/docs/offline/" }).window;
  w.caches = fakeCaches(caches);
  await (await load("pwa/offline.js")).init(w.document);
  return w.document.querySelector("[data-mt-offline]");
}

test("lists the kept pages of this scope with their titles as text", async () => {
  const box = await page({
    "mt:/docs/:pages:1-a": {
      "https://x.test/docs/a/": "<title>Guide &lt;b&gt;</title><p>x</p>",
      "https://x.test/docs/b.html": "<p>no title</p>",
      "https://x.test/docs/offline/": "<title>Offline</title>",
      "https://x.test/docs/ko/offline/": "<title>오프라인</title>",
      "https://x.test/docs/assets/site.css": "body{}",
      "https://x.test/docs/c/": '<title><img src=x onerror="alert(1)"></title>',
    },
    "mt:/docs/:assets:1": { "https://x.test/docs/assets/css/modootoday.css": "" },
    "mt:/other/:pages:1": { "https://x.test/other/": "<title>Other</title>" },
  });
  assert.strictEqual(box.hidden, false);
  const items = [...box.querySelectorAll("li a")].map((a) => [a.getAttribute("href"), a.textContent]);
  assert.deepStrictEqual(items, [["https://x.test/docs/a/", "Guide <b>"], ["https://x.test/docs/b.html", "/docs/b.html"],
    ["https://x.test/docs/c/", '<img src=x onerror="alert(1)">']]);
  assert.strictEqual(box.querySelector("img"), null);
});

test("stays hidden with nothing kept or without the manifest link", async () => {
  assert.strictEqual((await page({ "mt:/docs/:pages:1": {} })).hidden, true);
  assert.strictEqual((await page({ "mt:/docs/:pages:1": { "https://x.test/docs/a/": "<title>A</title>" } }, "")).hidden, true);
});
