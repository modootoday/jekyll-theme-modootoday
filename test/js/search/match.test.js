// jsdom tests for the header search, assets/js/modootoday/chrome/search.js: the default match (the whole query as typed) and
// the options data-match="terms", data-compact and data-results; the matching itself is text/normalize.js. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const { JSDOM } = require("jsdom");
const { run } = require("../support/module.js");


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
async function page(attrs = "", index = INDEX, lang = "en") {
  const html = `<!doctype html><html lang="${lang}"><body><div class="mt-search" data-index="/search.json" data-lang="en"${attrs} hidden>` +
    `<input type="search"><ul class="mt-search-results"></ul></div></body></html>`;
  const w = new JSDOM(html, { runScripts: "outside-only", url: "https://x.test/" }).window;
  w.fetch = async () => ({ json: async () => JSON.parse(JSON.stringify(index)) });
  await run("chrome/search.js", w);
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
  const { box, search } = await page();
  assert.strictEqual(box.hidden, false);
  assert.deepStrictEqual(await search("Volume"), ["Keyword volume", "Install"]);
  assert.deepStrictEqual(await search("volume keyword"), []);
  assert.deepStrictEqual(await search("search volume"), ["Keyword volume"]);
  assert.deepStrictEqual(await search("v"), []);
});

test("default: no compact match, and the snippet shows the text around the query", async () => {
  const { box, search } = await page("", INDEX, "ko");
  assert.deepStrictEqual(await search("검색량 조회"), ["검색량 조회", "도구"]);
  assert.deepStrictEqual(await search("검색량조회"), ["검색량 조회"]);
  const snippet = box.querySelector(".mt-search-snippet").textContent;
  assert.strictEqual(snippet, "키워드 검색량조회 방법을 알려 드려요.…");
});

test("default: decoded entities in snippets and at most 8 results", async () => {
  const many = Array.from({ length: 12 }, (_, i) => doc(`Page ${i}`, "common words"));
  const { search } = await page("", many);
  assert.strictEqual((await search("common")).length, 8);
  const { box, search: s2 } = await page();
  await s2("prices");
  assert.match(box.querySelector(".mt-search-snippet").textContent, /prices & limits/);
});

test("default: the query and the text are compared in NFC", async () => {
  const { search } = await page();
  assert.deepStrictEqual(await search("café"), ["Café guide"]);
});

test("data-match=terms: every word, in any order", async () => {
  const { search } = await page(' data-match="terms"');
  assert.deepStrictEqual(await search("volume keyword"), ["Keyword volume", "Install"]);
  assert.deepStrictEqual(await search("volume pricing"), []);
});

test("data-compact: also matches with the spaces removed", async () => {
  const { search } = await page(" data-compact", INDEX, "ko");
  assert.deepStrictEqual(await search("검색량조회"), ["검색량 조회", "도구"]);
});

test("data-results sets how many results show", async () => {
  const many = Array.from({ length: 12 }, (_, i) => doc(`Page ${i}`, "common words"));
  const { search } = await page(' data-results="3"', many);
  assert.strictEqual((await search("common")).length, 3);
});
