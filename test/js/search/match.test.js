// jsdom tests for the header search, assets/js/modootoday/search.js: the default match (the whole query as typed) and the
// options data-match="terms", data-compact and data-results, which follow text/normalize.js. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const fs = require("node:fs");
const path = require("node:path");
const { pathToFileURL } = require("node:url");
const { JSDOM } = require("jsdom");

const JS = path.join(__dirname, "../../../assets/js/modootoday");
const source = fs.readFileSync(path.join(JS, "search.js"), "utf8");

const doc = (title, text, lang = "en") => ({ title, url: `/${title.toLowerCase().replace(/\W+/g, "-")}/`, lang, text });
const INDEX = [
  doc("Install", "Add the gem and run the volume check. Keyword tools come later."),
  doc("Keyword volume", "How to read search volume for a keyword."),
  doc("Pricing", "Plans and prices &amp; limits."),
  doc("검색량 조회", "키워드 검색량조회 방법을 알려 드려요.", "ko"),
  doc("도구", "검색량 조회 도구 모음", "ko"),
  doc("Café guide", "Decomposed accents in the text."),
];

// A page with the header box (extra attributes on .mt-search) whose index fetch returns a copy of index.
function page(attrs = "", index = INDEX, lang = "en") {
  const html = `<!doctype html><html lang="${lang}"><body><div class="mt-search" data-index="/search.json" data-lang="en"${attrs} hidden>` +
    `<input type="search"><ul class="mt-search-results"></ul></div></body></html>`;
  const w = new JSDOM(html, { runScripts: "outside-only", url: "https://x.test/" }).window;
  w.fetch = async () => ({ json: async () => JSON.parse(JSON.stringify(index)) });
  w.eval(source);
  const box = w.document.querySelector(".mt-search");
  const input = box.querySelector("input");
  const search = async (q) => {
    input.value = q;
    input.dispatchEvent(new w.Event("input"));
    await new Promise((r) => setTimeout(r, 0));
    return [...box.querySelectorAll(".mt-search-title")].map((e) => e.textContent);
  };
  return { w, box, search };
}

test("default: the whole query as one piece of text, title hits first, the page language first", async () => {
  const { box, search } = page();
  assert.strictEqual(box.hidden, false);
  assert.deepStrictEqual(await search("Volume"), ["Keyword volume", "Install"]);
  assert.deepStrictEqual(await search("volume keyword"), []);
  assert.deepStrictEqual(await search("search volume"), ["Keyword volume"]);
  assert.deepStrictEqual(await search("v"), []);
});

test("default: no compact match, and the snippet shows the text around the query", async () => {
  const { box, search } = page("", INDEX, "ko");
  assert.deepStrictEqual(await search("검색량 조회"), ["검색량 조회", "도구"]);
  assert.deepStrictEqual(await search("검색량조회"), ["검색량 조회"]);
  const snippet = box.querySelector(".mt-search-snippet").textContent;
  assert.strictEqual(snippet, "키워드 검색량조회 방법을 알려 드려요.…");
});

test("default: decoded entities in snippets and at most 8 results", async () => {
  const many = Array.from({ length: 12 }, (_, i) => doc(`Page ${i}`, "common words"));
  const { search } = page("", many);
  assert.strictEqual((await search("common")).length, 8);
  const { box, search: s2 } = page();
  await s2("prices");
  assert.match(box.querySelector(".mt-search-snippet").textContent, /prices & limits/);
});

test("default: the query and the text are compared in NFC", async () => {
  const { search } = page();
  assert.deepStrictEqual(await search("café"), ["Café guide"]);
});

test("data-match=terms: every word, in any order", async () => {
  const { search } = page(' data-match="terms"');
  assert.deepStrictEqual(await search("volume keyword"), ["Keyword volume", "Install"]);
  assert.deepStrictEqual(await search("volume pricing"), []);
});

test("data-compact: also matches with the spaces removed", async () => {
  const { search } = page(" data-compact", INDEX, "ko");
  assert.deepStrictEqual(await search("검색량조회"), ["검색량 조회", "도구"]);
});

test("data-results sets how many results show", async () => {
  const many = Array.from({ length: 12 }, (_, i) => doc(`Page ${i}`, "common words"));
  const { search } = page(' data-results="3"', many);
  assert.strictEqual((await search("common")).length, 3);
});

test("terms and compact find the same entries as text/normalize.js", async () => {
  const { terms, matches } = await import(pathToFileURL(path.join(JS, "text/normalize.js")).href);
  const queries = ["volume keyword", "검색량조회", "검색량 조회 도구", "café guide", "plans limits", "nothing here"];
  for (const q of queries) {
    const { search } = page(' data-match="terms" data-compact data-results="99"', INDEX, "");
    const expected = INDEX.filter((p) => matches(p.title + " " + p.text, terms(q), true)).map((p) => p.title).sort();
    assert.deepStrictEqual((await search(q)).sort(), expected, q);
  }
});
