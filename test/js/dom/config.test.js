// Tests for the module helper assets/js/modootoday/dom/config.js. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const path = require("node:path");
const { pathToFileURL } = require("node:url");
const { JSDOM } = require("jsdom");

const load = () => import(pathToFileURL(path.join(__dirname, "../../../assets/js/modootoday/dom/config.js")).href);

test("readConfig: the defaults give the keys and types; other attributes are ignored", async () => {
  const { readConfig } = await load();
  const el = new JSDOM("").window.document.createElement("div");
  el.dataset.results = "8";
  el.dataset.compact = "";
  el.dataset.match = "terms";
  el.dataset.props = '{"a":1}';
  el.dataset.extra = "ignored";
  const got = readConfig(el, { results: 5, compact: false, match: "all", props: {}, missing: "keep" });
  assert.deepStrictEqual(got, { results: 8, compact: true, match: "terms", props: { a: 1 }, missing: "keep" });
});

test("readConfig: a number or JSON that does not parse keeps the default", async () => {
  const { readConfig } = await load();
  const el = new JSDOM("").window.document.createElement("div");
  el.dataset.speedUp = "fast";
  el.dataset.props = "{bad";
  el.dataset.count = " ";
  assert.deepStrictEqual(readConfig(el, { speedUp: 2, props: {}, count: 3 }), { speedUp: 2, props: {}, count: 3 });
});
