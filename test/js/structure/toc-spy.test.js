// jsdom test for assets/js/modootoday/structure/toc-spy.js with a fake layout: heading tops, scroll position and page
// height are set by the test, and the observer is woken by hand. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const { JSDOM } = require("jsdom");
const { run } = require("../support/module.js");

const ITEMS = [["intro", 2], ["setup", 2], ["setup-linux", 3], ["setup-mac", 3], ["usage", 2], ["faq", 2]];
const list = () => ITEMS.map(([id, lv]) => `<li class="mt-toc-h${lv}"><a href="#${id}">${id}</a></li>`).join("");
const PAGE = `<!doctype html><html><body><header class="mt-header"></header>
<details class="mt-toc-mobile"><summary>On this page</summary><ol>${list()}</ol></details>
<article>${ITEMS.map(([id, lv]) => `<h${lv} id="${id}">${id}</h${lv}>`).join("")}</article>
<aside class="mt-doc-aside"><nav class="mt-toc"><ol>${list()}</ol></nav></aside><footer class="mt-footer"></footer></body></html>`;

// Tops for a scroll position: headings 600px apart from 300px down the page.
const at = (y) => Object.fromEntries(ITEMS.map(([id], i) => [id, 300 + 600 * i - y]));

async function load(hash = "", scrollY = 0) {
  const dom = new JSDOM(PAGE, { url: "https://example.test/guide/" + hash, pretendToBeVisual: true, runScripts: "outside-only" });
  const win = dom.window;
  const d = win.document;
  const layout = { tops: at(scrollY), scrollY, height: 4000, observed: [] };
  win.IntersectionObserver = class {
    constructor(cb, options) {
      layout.wake = cb;
      layout.options = options;
    }
    observe(el) {
      layout.observed.push(el);
    }
  };
  Object.defineProperty(win, "innerHeight", { get: () => 800 });
  Object.defineProperty(win, "scrollY", { get: () => layout.scrollY });
  Object.defineProperty(d.documentElement, "scrollHeight", { get: () => layout.height });
  const rect = (top) => ({ top, bottom: top + 24, left: 0, right: 0, width: 0, height: 24 });
  d.querySelector(".mt-header").getBoundingClientRect = () => rect(40);
  for (const [id] of ITEMS) {
    d.getElementById(id).getBoundingClientRect = () => rect(layout.tops[id] ?? 5000);
  }
  await run("structure/toc-spy.js", win);
  const frame = () => new Promise((done) => win.requestAnimationFrame(() => done()));
  const scroll = async (scrollY, tops) => {
    layout.scrollY = scrollY;
    layout.tops = tops;
    layout.wake([]);
    await frame();
    await frame();
  };
  const marked = (sel) => [...d.querySelectorAll(`${sel} a[aria-current]`)].map((a) => [a.getAttribute("href").slice(1), a.getAttribute("aria-current")]);
  await frame();
  await frame();
  return { win, d, layout, scroll, marked, frame };
}

test("nothing is marked before the first heading reaches the line", async () => {
  const { marked, layout } = await load();
  assert.deepStrictEqual(marked(".mt-toc"), []);
  assert.deepStrictEqual(marked(".mt-toc-mobile"), []);
  assert.strictEqual(layout.options.rootMargin, "-80px 0px 0px 0px");
  assert.strictEqual(layout.observed.length, ITEMS.length + 1);
});

test("the last heading past the line (header bottom plus 1rem) is marked, once per list", async () => {
  const { scroll, marked, d } = await load();
  await scroll(220, at(220));
  assert.deepStrictEqual(marked(".mt-toc"), [["intro", "location"]]);
  await scroll(818, at(818));
  assert.deepStrictEqual(marked(".mt-toc-mobile"), [["intro", "location"]]);
  await scroll(819, at(819));
  assert.deepStrictEqual(marked(".mt-toc-mobile"), [["setup", "location"]]);
  await scroll(900, at(900));
  assert.deepStrictEqual(marked(".mt-toc"), [["setup", "location"]]);
  assert.strictEqual(d.querySelectorAll("[aria-current]").length, 2);
});

test("an h3 marks itself in the mobile list and its h2 in the sticky column", async () => {
  const { scroll, marked } = await load();
  await scroll(2100, at(2100));
  assert.deepStrictEqual(marked(".mt-toc-mobile"), [["setup-mac", "location"]]);
  assert.deepStrictEqual(marked(".mt-toc"), [["setup", "location"]]);
});

test("at the end of the page the last heading in view is marked", async () => {
  const { scroll, marked } = await load();
  await scroll(3100, { ...at(3100), faq: 700 });
  assert.deepStrictEqual(marked(".mt-toc-mobile"), [["usage", "location"]]);
  await scroll(3200, { ...at(3200), faq: 700 });
  assert.deepStrictEqual(marked(".mt-toc-mobile"), [["faq", "location"]]);
});

test("a followed link is marked at once and stays while the page end keeps it below the line", async () => {
  const { scroll, marked, d } = await load();
  d.querySelector('.mt-toc a[href="#usage"]').click();
  assert.deepStrictEqual(marked(".mt-toc-mobile"), [["usage", "location"]]);
  await scroll(3200, { ...at(3200), usage: 300, faq: 500 });
  assert.deepStrictEqual(marked(".mt-toc-mobile"), [["usage", "location"]]);
  await scroll(2000, at(2000));
  assert.deepStrictEqual(marked(".mt-toc-mobile"), [["setup-linux", "location"]]);
});

test("loading with a hash marks that heading before any scroll is read", async () => {
  const { marked } = await load("#usage", 2700);
  assert.deepStrictEqual(marked(".mt-toc"), [["usage", "location"]]);
});

test("without IntersectionObserver the lists stay plain links", async () => {
  const dom = new JSDOM(PAGE, { pretendToBeVisual: true });
  await run("structure/toc-spy.js", dom.window);
  assert.strictEqual(dom.window.document.querySelectorAll("[aria-current]").length, 0);
});
