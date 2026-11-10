// Tests for the browser-free parts of test/system/audit/features/pwa.mjs and pwa/session.mjs: the fixture builds it
// needs, the constants read from a build's sw.js, and polling through a reload. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const { pathToFileURL } = require("node:url");

const AUDIT = path.join(__dirname, "../../system/audit");
const load = (rel) => import(pathToFileURL(path.join(AUDIT, rel)).href);

test("a missing fixture build fails with the command that makes it, before any browser starts", async () => {
  const { builds, BUILDS } = await load("features/pwa.mjs");
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "mt-pwa-"));
  const fails = [];
  assert.strictEqual(builds(dir, fails), null);
  assert.match(fails[0], /no fixture build v1, v2, next, kill, b, root in .*; run test\/system\/site\/build-pwa\.sh/);
  for (const b of BUILDS) {
    fs.mkdirSync(path.join(dir, b));
    fs.writeFileSync(path.join(dir, b, "index.html"), "");
  }
  assert.deepStrictEqual(Object.keys(builds(dir, [])), ["v1", "v2", "next", "kill", "b", "root"]);
});

test("the constants come from the line the sw.js include renders", async () => {
  const { constants } = await load("features/pwa/session.mjs");
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "mt-pwa-"));
  const c = { scope: "/a/", build: "1.7.0-1767225600", assets: "1.7.0", precache: ["/a/offline/"], offline: { "/a/": "/a/offline/" } };
  fs.writeFileSync(path.join(dir, "sw.js"), `self.MT_PWA = ${JSON.stringify(c)};\nimportScripts("/a/w.js");\n`);
  assert.deepStrictEqual(constants(dir), c);
});

test("until polls through a destroyed context and names what it waited for on timeout", async () => {
  const { until } = await load("features/pwa/session.mjs");
  const answers = [new Error("Execution context was destroyed, most likely because of a navigation"), null, { scope: "/a/" }];
  const page = { evaluate: async () => {
    const a = answers.shift();
    if (a instanceof Error) {
      throw a;
    }
    return a;
  }, waitForTimeout: async () => {} };
  assert.deepStrictEqual(await until(page, "x", () => 0), { scope: "/a/" });
  const never = { evaluate: async () => false, waitForTimeout: (ms) => new Promise((r) => setTimeout(r, ms)) };
  await assert.rejects(until(never, "worker controls the page", () => 0, undefined, 300), /worker controls the page: not reached in 300 ms \(last: false; state: /);
});
