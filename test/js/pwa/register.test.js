// jsdom tests for assets/js/modootoday/pwa/register.js: registration after load with the scope from the manifest link,
// and the warm-up message of a first visit. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const { JSDOM } = require("jsdom");
const { run } = require("../support/module.js");

const LINK = '<link rel="manifest" href="/docs/manifest.webmanifest" data-mt-sw="/docs/sw.js" data-mt-scope="/docs/">';
const RESOURCES = ["https://x.test/docs/assets/css/modootoday.css?v=1", "https://x.test/other/a.css", "https://cdn.example/x.js"];

// A page whose navigator has a fake service worker container; registered collects register() calls, posted the messages.
async function page({ head = LINK, controller = null, sw = true } = {}) {
  const w = new JSDOM(`<!doctype html><html><head>${head}</head><body></body></html>`, { url: "https://x.test/docs/a/#top" }).window;
  const registered = [];
  const posted = [];
  const reg = { active: { postMessage: (m) => posted.push(m) } };
  if (sw) {
    Object.defineProperty(w.navigator, "serviceWorker", {
      value: { controller, ready: Promise.resolve(reg), register: async (url, opts) => registered.push([url, opts]) && reg },
    });
  }
  w.performance.getEntriesByType = () => RESOURCES.map((name) => ({ name }));
  await run("pwa/register.js", w);
  if (w.document.readyState != "complete") {
    await new Promise((resolve) => w.addEventListener("load", resolve));
  }
  await new Promise((resolve) => setTimeout(resolve, 10));
  return { registered, posted };
}

test("registers the worker the manifest link names, with the site scope", async () => {
  const { registered } = await page();
  assert.deepStrictEqual(registered, [["/docs/sw.js", { scope: "https://x.test/docs/" }]]);
});

test("a first visit posts the in-scope URLs it loaded, the page among them", async () => {
  const { posted } = await page();
  assert.deepStrictEqual(posted, [{ type: "mt:warm", urls: ["https://x.test/docs/assets/css/modootoday.css?v=1", "https://x.test/docs/a/"] }]);
});

test("a controlled page posts nothing", async () => {
  const { registered, posted } = await page({ controller: {} });
  assert.strictEqual(registered.length, 1);
  assert.deepStrictEqual(posted, []);
});

test("without the link or service worker support nothing runs", async () => {
  assert.deepStrictEqual((await page({ head: '<link rel="manifest" href="/m.webmanifest">' })).registered, []);
  assert.deepStrictEqual((await page({ sw: false })).posted, []);
});
