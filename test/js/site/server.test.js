// Tests for test/system/site/server.mjs: sites by base path on one origin, swapped while serving, the manifest type, the
// CSP header on HTML only, the cache header on everything else, and the offline switch that fails every request at the
// socket. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const http = require("node:http");
const { pathToFileURL } = require("node:url");

const load = () => import(pathToFileURL(path.join(__dirname, "../../system/site/server.mjs")).href);

function site(files) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "mt-server-"));
  for (const [name, text] of Object.entries(files)) {
    fs.mkdirSync(path.dirname(path.join(dir, name)), { recursive: true });
    fs.writeFileSync(path.join(dir, name), text);
  }
  return dir;
}

// A keep-alive agent, so the offline switch has an open socket to cut as well as new ones.
const agent = new http.Agent({ keepAlive: true });
const get = (url) => new Promise((resolve, reject) => {
  http.get(url, { agent }, (res) => {
    let body = "";
    res.on("data", (c) => (body += c));
    res.on("end", () => resolve({ status: res.statusCode, type: res.headers["content-type"], csp: res.headers["content-security-policy"], cache: res.headers["cache-control"], body }));
  }).on("error", reject);
});

test("the longest base path that holds a URL serves it; the root holds the rest", async () => {
  const { siteFor } = await load();
  const sites = { "": "R", "/a": "A", "/ab": "AB" };
  assert.deepStrictEqual(siteFor(sites, "/a/x/"), { base: "/a", dir: "A" });
  assert.deepStrictEqual(siteFor(sites, "/a"), { base: "/a", dir: "A" });
  assert.deepStrictEqual(siteFor(sites, "/ab/"), { base: "/ab", dir: "AB" });
  assert.deepStrictEqual(siteFor(sites, "/abc/"), { base: "", dir: "R" });
  assert.strictEqual(siteFor({ "/a": "A" }, "/b/"), null);
});

test("sites share one origin, swap while serving and go offline at the socket", async () => {
  const { serveSites } = await load();
  const v1 = site({ "index.html": "v1", "manifest.webmanifest": "{}", "sw.js": "//" });
  const v2 = site({ "index.html": "v2" });
  const root = site({ "index.html": "root" });
  const srv = await serveSites({ "/a": v1, "": root }, { csp: "default-src 'self'" });
  try {
    assert.strictEqual(srv.url("/a"), `${srv.root}/a/`);
    const page = await get(srv.url("/a"));
    assert.deepStrictEqual([page.body, page.csp], ["v1", "default-src 'self'"]);
    assert.strictEqual((await get(`${srv.root}/`)).body, "root");
    const manifest = await get(`${srv.url("/a")}manifest.webmanifest`);
    assert.deepStrictEqual([manifest.type, manifest.csp], ["application/manifest+json", undefined]);
    assert.strictEqual((await get(`${srv.url("/a")}sw.js`)).type, "text/javascript");
    assert.strictEqual((await get(`${srv.root}/a/missing/`)).status, 404);
    srv.set("/a", v2);
    assert.strictEqual((await get(srv.url("/a"))).body, "v2");
    srv.offline(true);
    await assert.rejects(get(srv.url("/a")), /socket hang up|ECONNRESET/);
    await assert.rejects(get(`${srv.root}/`), /socket hang up|ECONNRESET/);
    srv.offline(false);
    assert.strictEqual((await get(srv.url("/a"))).body, "v2");
  } finally {
    srv.close();
    agent.destroy();
  }
});

test("serveSite keeps its single-site form at the Pages baseurl", async () => {
  const { serveSite, BASE } = await load();
  const { origin, close } = await serveSite(site({ "index.html": "docs" }));
  try {
    assert.ok(origin.endsWith(`${BASE}/`));
    assert.strictEqual((await get(origin)).body, "docs");
    assert.strictEqual((await get(origin.replace(BASE, "/other"))).status, 404);
  } finally {
    close();
  }
});

test("the cache option sets Cache-Control on every file but HTML", async () => {
  const { serveSite } = await load();
  const { origin, close } = await serveSite(site({ "index.html": "docs", "assets/a.css": "a{}" }), { cache: "max-age=600" });
  try {
    assert.strictEqual((await get(origin)).cache, undefined);
    assert.strictEqual((await get(`${origin}assets/a.css?v=1`)).cache, "max-age=600");
  } finally {
    close();
  }
});
