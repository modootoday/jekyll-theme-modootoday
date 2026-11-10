// Node tests for the service worker strategies (assets/js/modootoday/pwa/worker.js) and the inline kill worker of
// _includes/modootoday/pwa/sw.js, in the fake worker global of support/sw-env.js. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const fs = require("node:fs");
const path = require("node:path");
const { ROOT, env } = require("../support/sw-env.js");

const ASSETS = "mt:/docs/:assets:1.7.0";
const PAGES = "mt:/docs/:pages:1.7.0";
const MEDIA = "mt:/docs/:media";
const OFFLINE = { "/docs/": "/docs/offline/", "/docs/ko/": "/docs/ko/offline/" };
const page = (title, status = 200) => new Response(`<title>${title}</title>`, { status, headers: { "content-type": "text/html" } });
const offlineNet = () => {
  throw new TypeError("Failed to fetch");
};

test("requests the worker leaves alone: not GET, cross-origin, outside the scope, Range, twins and feeds", async () => {
  const w = env();
  const alone = [["/docs/a/", { method: "POST", body: "x" }], ["https://cdn.example/x.js"], ["/other/a/"], ["/docs/ep.mp3", { headers: { range: "bytes=0-" } }],
    ["/docs/a/index.md"], ["/docs/llms.txt"], ["/docs/llms-full.txt"], ["/docs/feed.xml"], ["/docs/sitemap.xml"], ["/docs/manifest.webmanifest"], ["/docs/sw.js"]];
  for (const [url, init] of alone) {
    assert.strictEqual(await w.go(url, init), null, url);
  }
  assert.deepStrictEqual(w.fetched, []);
});

test("navigations to twins, llms.txt, feeds and the sitemap are left alone too", async () => {
  const w = env();
  for (const url of ["/docs/a/index.md", "/docs/llms.txt", "/docs/feed.xml", "/docs/sitemap.xml"]) {
    assert.strictEqual(await w.go(url, { mode: "navigate" }), null, url);
  }
  assert.deepStrictEqual(w.caches.urls(PAGES), []);
});

test("theme files are cache first in the assets cache of the theme version", async () => {
  const w = env({ installed: true });
  const url = "/docs/assets/css/modootoday.css?v=1.7.0";
  assert.strictEqual(await (await w.go(url)).text(), "ok");
  w.state.net = offlineNet;
  assert.strictEqual(await (await w.go(url)).text(), "ok");
  assert.deepStrictEqual(w.fetched, [url]);
  assert.deepStrictEqual(w.caches.urls(ASSETS), [url]);
});

test("navigations are network first: ok pages kept, a 404 not, a network error serves the copy", async () => {
  const w = env({ installed: true, net: (u) => (u == "/docs/gone/" ? page("Gone", 404) : page("A")) });
  assert.strictEqual(await (await w.go("/docs/a/", { mode: "navigate" })).text(), "<title>A</title>");
  assert.strictEqual((await w.go("/docs/gone/", { mode: "navigate" })).status, 404);
  assert.deepStrictEqual(w.caches.urls(PAGES), ["/docs/a/"]);
  w.state.net = offlineNet;
  assert.strictEqual(await (await w.go("/docs/a/", { mode: "navigate" })).text(), "<title>A</title>");
});

test("a navigation preload response is used instead of a second fetch", async () => {
  const w = env();
  const res = await w.go("/docs/a/", { mode: "navigate" }, page("Preloaded"));
  assert.strictEqual(await res.text(), "<title>Preloaded</title>");
  assert.deepStrictEqual(w.fetched, []);
});

test("offline, an unvisited page gets the offline page of its longest language prefix", async () => {
  const w = env({ constants: { offline: OFFLINE, precache: Object.values(OFFLINE) }, net: (u) => page(u) });
  await w.dispatch("install");
  w.state.net = offlineNet;
  assert.strictEqual(await (await w.go("/docs/ko/guide/", { mode: "navigate" })).text(), "<title>/docs/ko/offline/</title>");
  assert.strictEqual(await (await w.go("/docs/kotlin/", { mode: "navigate" })).text(), "<title>/docs/offline/</title>");
});

test("a 5xx serves the kept copy, and the 5xx itself when there is none", async () => {
  const w = env({ installed: true, net: () => page("A") });
  await w.go("/docs/a/", { mode: "navigate" });
  w.state.net = () => page("Bad gateway", 502);
  assert.strictEqual(await (await w.go("/docs/a/", { mode: "navigate" })).text(), "<title>A</title>");
  assert.strictEqual((await w.go("/docs/b/", { mode: "navigate" })).status, 502);
});

test("site files are network first; search.json and media are stale while revalidate", async () => {
  let n = 0;
  const w = env({ installed: true, net: () => new Response(`v${++n}`) });
  assert.strictEqual(await (await w.go("/docs/assets/site.css?v=1.7.0")).text(), "v1");
  assert.strictEqual(await (await w.go("/docs/assets/site.css?v=1.7.0")).text(), "v2");
  assert.strictEqual(await (await w.go("/docs/search.json")).text(), "v3");
  assert.strictEqual(await (await w.go("/docs/search.json")).text(), "v3", "the kept copy first");
  assert.strictEqual(await (await w.go("/docs/search.json")).text(), "v4", "then the refreshed one");
  await w.go("/docs/img/a.png");
  assert.deepStrictEqual(w.caches.urls(MEDIA), ["/docs/img/a.png"]);
  assert.deepStrictEqual(w.caches.urls(PAGES).sort(), ["/docs/assets/site.css?v=1.7.0", "/docs/search.json"]);
});

test("a worker whose caches a kill or a newer worker deleted answers but never recreates them", async () => {
  const w = env({ installed: true, net: (u) => page(u) });
  await w.caches.delete(ASSETS);
  assert.strictEqual(await (await w.go("/docs/assets/js/modootoday/pwa/update-toast.js")).text(), "<title>/docs/assets/js/modootoday/pwa/update-toast.js</title>");
  await w.go("/docs/a/", { mode: "navigate" });
  assert.deepStrictEqual(await w.caches.keys(), []);
});

test("the pages cache keeps the 50 most recently used, never a precached page; media keeps 60", async () => {
  const w = env({ constants: { precache: ["/docs/offline/"] }, net: (u) => page(u) });
  await w.dispatch("install");
  for (let i = 0; i < 55; i++) {
    await w.go(`/docs/p${i}/`, { mode: "navigate" });
  }
  await w.go("/docs/p5/", { mode: "navigate" });
  await w.go("/docs/p55/", { mode: "navigate" });
  const kept = w.caches.urls(PAGES);
  assert.strictEqual(kept.length, 51);
  assert.ok(kept.includes("/docs/offline/"));
  assert.ok(kept.includes("/docs/p5/") && !kept.includes("/docs/p4/") && !kept.includes("/docs/p6/"));
  for (let i = 0; i < 62; i++) {
    await w.go(`/docs/i${i}.webp`);
  }
  assert.strictEqual(w.caches.urls(MEDIA).length, 60);
});

test("install precaches by kind; only a missing offline page fails it", async () => {
  const precache = ["/docs/offline/", "/docs/assets/css/modootoday.css?v=1.7.0", "/docs/", "/docs/missing/"];
  const w = env({ constants: { precache }, net: (u) => (u == "/docs/missing/" ? page("x", 404) : page(u)) });
  await w.dispatch("install");
  assert.deepStrictEqual(w.caches.urls(ASSETS), ["/docs/assets/css/modootoday.css?v=1.7.0"]);
  assert.deepStrictEqual(w.caches.urls(PAGES).sort(), ["/docs/", "/docs/offline/"]);
  const broken = env({ constants: { precache }, net: (u) => (u == "/docs/offline/" ? page("x", 500) : page(u)) });
  await assert.rejects(broken.dispatch("install"));
});

test("a new worker with the theme files of the one before takes over at once; new theme files wait", async () => {
  const same = env({ constants: { build: "1.7.0-def5678" } });
  await same.caches.open(ASSETS);
  await same.dispatch("install");
  assert.ok(same.state.skipped);
  const next = env({ constants: { assets: "1.8.0" } });
  await next.caches.open(ASSETS);
  await next.dispatch("install");
  assert.ok(!next.state.skipped);
  assert.ok(await next.caches.has("mt:/docs/:assets:1.8.0"), "its assets cache is there for the notice to find");
});

test("the Reload message makes a waiting worker take over", async () => {
  const w = env();
  await w.dispatch("message", { data: { type: "mt:skip" } });
  assert.ok(w.state.skipped);
  assert.deepStrictEqual(w.fetched, []);
});

test("activate deletes this scope's other versions only, turns on navigation preload and claims", async () => {
  const w = env();
  for (const n of ["mt:/docs/:pages:old", "mt:/docs/:assets:1.6.0", PAGES, MEDIA, "mt:/docs/b/:pages:old", "mt:/other/:assets:1.6.0", "site-cache"]) {
    await w.caches.open(n);
  }
  await w.dispatch("activate");
  assert.deepStrictEqual((await w.caches.keys()).sort(), [MEDIA, PAGES, "mt:/docs/b/:pages:old", "mt:/other/:assets:1.6.0", "site-cache"].sort());
  assert.ok(w.state.preload && w.state.claimed);
});

test("a deploy that keeps the theme files keeps the pages cache; a theme update replaces it", async () => {
  const w = env({ constants: { build: "1.7.0-def5678" } });
  await w.caches.open(PAGES);
  await w.caches.open("mt:/docs/:pages:1.6.0");
  await w.dispatch("activate");
  assert.deepStrictEqual((await w.caches.keys()).sort(), [PAGES]);
});

test("a handler that throws falls through to the network", async () => {
  const w = env();
  w.caches.open = async () => {
    throw new Error("quota");
  };
  assert.strictEqual(await (await w.go("/docs/assets/js/modootoday/chrome/menu.js")).text(), "ok");
  assert.strictEqual(await w.go("/docs/a/", { headers: {} }).then((r) => r.status), 200);
});

test("the warm-up message caches the posted URLs in the scope only", async () => {
  const w = env({ net: (u) => page(u) });
  const urls = ["https://x.test/docs/a/", "https://x.test/docs/assets/css/modootoday.css?v=1.7.0", "https://x.test/other/", "https://cdn.example/x.css", "https://x.test/docs/feed.xml"];
  await w.dispatch("message", { data: { type: "mt:warm", urls } });
  assert.deepStrictEqual(w.fetched.sort(), ["/docs/a/", "/docs/assets/css/modootoday.css?v=1.7.0"]);
  await w.dispatch("message", { data: { type: "other", urls } });
  assert.strictEqual(w.fetched.length, 2);
});

test("the kill worker deletes its scope's caches, unregisters and reloads open pages", async () => {
  const liquid = fs.readFileSync(path.join(ROOT, "_includes/modootoday/pwa/sw.js"), "utf8");
  const script = liquid.split("{% else -%}")[1].split("{% endif -%}")[0].replace(/\{\{[^}]*\}\}/, '"mt:/docs/:"');
  const w = env({ script });
  for (const n of [PAGES, MEDIA, "mt:/docs/b/:pages:x", "mt:/other/:media"]) {
    await w.caches.open(n);
  }
  await w.dispatch("install");
  await w.dispatch("activate");
  assert.ok(w.state.skipped && w.state.unregistered);
  assert.deepStrictEqual((await w.caches.keys()).sort(), ["mt:/docs/b/:pages:x", "mt:/other/:media"]);
  assert.deepStrictEqual(w.navigated, ["https://x.test/docs/a/"]);
  assert.strictEqual(w.listeners.fetch, undefined, "no fetch handler: requests go to the network");
});
