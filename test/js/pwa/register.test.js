// jsdom tests for assets/js/modootoday/pwa/register.js: registration after load with the scope from the manifest link,
// and the warm-up message of a first visit. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const { JSDOM } = require("jsdom");
const { run } = require("../support/module.js");

const LINK = '<link rel="manifest" href="/docs/manifest.webmanifest" data-mt-sw="/docs/sw.js" data-mt-scope="/docs/">';
const RESOURCES = ["https://x.test/docs/assets/css/modootoday.css?v=1", "https://x.test/other/a.css", "https://cdn.example/x.js"];

// A page whose navigator has a fake service worker container; registered collects register() calls, posted the messages,
// updates the registration's update() calls; reg.on holds its listeners.
async function page({ head = LINK, controller = null, sw = true, waiting = null, names = ["mt:/docs/:assets:1", "mt:/docs/:assets:2"], body = "" } = {}) {
  const w = new JSDOM(`<!doctype html><html><head>${head}</head><body>${body}</body></html>`, { url: "https://x.test/docs/a/#top", pretendToBeVisual: true }).window;
  w.caches = { keys: async () => names };
  const query = w.document.querySelector.bind(w.document);
  w.mtQueries = [];
  w.document.querySelector = (s) => w.mtQueries.push(s) && query(s);
  const registered = [];
  const posted = [];
  const updates = [];
  const reg = { active: { postMessage: (m) => posted.push(m) }, waiting, on: {}, update: async () => updates.push(1) };
  reg.addEventListener = (type, fn) => {
    reg.on[type] = fn;
  };
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
  return { w, reg, registered, posted, updates };
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

// The toast module reads Cache Storage: two assets versions mean new theme files.
const TOAST = LINK.replace(">", ' data-mt-toast-css="/t.css" data-mt-update="New" data-mt-reload="Reload" data-mt-later="Later">');
const until = async (fn) => {
  for (let i = 0; i < 50 && !fn(); i++) {
    await new Promise((r) => setTimeout(r, 2));
  }
  return fn();
};

test("a controlled page with a worker waiting on new theme files loads the notice", async () => {
  const { w } = await page({ head: TOAST, controller: {}, waiting: { postMessage() {} } });
  assert.ok(await until(() => w.document.querySelector(".mt-toast")), "the notice region");
});

test("a worker waiting with the same theme files takes over by itself, so the notice module is not loaded", async () => {
  const { w } = await page({ head: TOAST, controller: {}, waiting: { postMessage() {} }, names: ["mt:/docs/:assets:1", "mt:/docs/:pages:1", "mt:/other/:assets:2"] });
  await new Promise((r) => setTimeout(r, 20));
  assert.deepStrictEqual(w.mtQueries.filter((s) => s.includes("data-mt-toast-css")), []);
});

test("a worker that finishes installing later is noticed too; a first visit is not", async () => {
  const later = await page({ head: TOAST, controller: {} });
  const next = { state: "installing", addEventListener: (type, fn) => (next.fire = fn) };
  later.reg.installing = next;
  later.reg.on.updatefound();
  later.reg.waiting = next;
  next.state = "installed";
  next.fire();
  assert.ok(await until(() => later.w.document.querySelector(".mt-toast")));
  const first = await page({ head: TOAST, waiting: { postMessage() {} } });
  await new Promise((r) => setTimeout(r, 20));
  assert.strictEqual(first.w.document.querySelector(".mt-toast"), null);
});

test("a window shown again checks for a new worker at most once an hour", async () => {
  const { w, updates } = await page({ controller: {} });
  const show = () => w.document.dispatchEvent(new w.Event("visibilitychange"));
  show();
  assert.strictEqual(updates.length, 0, "not within the hour");
  const now = Date.now;
  Date.now = () => now() + 36e5 + 1;
  try {
    show();
    show();
  } finally {
    Date.now = now;
  }
  assert.strictEqual(updates.length, 1);
});

test("a lost network loads the offline notice, except on the offline page", async () => {
  const { w } = await page({ head: TOAST, controller: {} });
  w.dispatchEvent(new w.Event("offline"));
  assert.ok(await until(() => w.document.querySelector(".mt-toast")));
  const off = await page({ head: TOAST, controller: {} });
  off.w.document.body.innerHTML = "<section data-mt-offline hidden></section>";
  off.w.dispatchEvent(new off.w.Event("offline"));
  await new Promise((r) => setTimeout(r, 20));
  assert.strictEqual(off.w.document.querySelector(".mt-toast"), null);
});

test("an install offer is kept on the manifest link only on a page with an Install button", async () => {
  const { w } = await page({ body: '<button class="mt-install" hidden>Install</button>' });
  const e = new w.Event("beforeinstallprompt", { cancelable: true });
  w.dispatchEvent(e);
  assert.strictEqual(w.document.querySelector("link").mtInstall, e);
  assert.strictEqual(e.defaultPrevented, true);
  const plain = await page();
  const f = new plain.w.Event("beforeinstallprompt", { cancelable: true });
  plain.w.dispatchEvent(f);
  assert.strictEqual(plain.w.document.querySelector("link").mtInstall, undefined);
  assert.strictEqual(f.defaultPrevented, false, "the browser keeps its own install UI elsewhere");
});
