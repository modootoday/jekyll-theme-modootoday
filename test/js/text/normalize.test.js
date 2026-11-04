// Tests for assets/js/modootoday/text/normalize.js, the matching of the header search and the list filter. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const path = require("node:path");
const { pathToFileURL } = require("node:url");

const load = () => import(pathToFileURL(path.join(__dirname, "../../../assets/js/modootoday/text/normalize.js")).href);

test("normalize: NFC and lower case, so decomposed Hangul and accents match their composed form", async () => {
  const { normalize } = await load();
  assert.strictEqual(normalize("가 Café"), "가 café");
  assert.strictEqual(normalize("ABC"), "abc");
});

test("terms: the query split on whitespace, empty words dropped", async () => {
  const { terms } = await load();
  assert.deepStrictEqual(terms("  Search   Volume "), ["search", "volume"]);
  assert.deepStrictEqual(terms("   "), []);
});

test("matches: every word must appear, in any order (AND)", async () => {
  const { terms, matches } = await load();
  assert.strictEqual(matches("Keyword search volume tool", terms("volume keyword"), false), true);
  assert.strictEqual(matches("Keyword search volume tool", terms("volume price"), false), false);
  assert.strictEqual(matches("anything", [], false), true);
});

test("matches: compact also compares without spaces, for Korean spacing that varies", async () => {
  const { terms, matches } = await load();
  assert.strictEqual(matches("검색량 조회 도구", terms("검색량조회"), false), false);
  assert.strictEqual(matches("검색량 조회 도구", terms("검색량조회"), true), true);
  assert.strictEqual(matches("검색량조회 도구", terms("검색량 조회"), false), true);
  assert.strictEqual(matches("검색량 조회", terms("가격"), true), false);
});

test("squash and includesAll: the compact form and the AND of every word", async () => {
  const { squash, includesAll } = await load();
  assert.strictEqual(squash("검색량 조회\t도구"), "검색량조회도구");
  assert.strictEqual(includesAll("keyword search volume", ["volume", "keyword"]), true);
  assert.strictEqual(includesAll("keyword search volume", ["volume", "price"]), false);
});

test("matches: the haystack is normalized too", async () => {
  const { terms, matches } = await load();
  assert.strictEqual(matches("각 PRICE", terms("각 price"), false), true);
});
