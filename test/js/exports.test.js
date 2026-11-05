// Export names of the theme's modules, pinned (adr:modootoday/20261104053147): only the entry URL carries ?v=, so for up to
// ten minutes after a deploy a page can pair a new module with a cached older import. Within a minor release a shared module
// keeps its names, and every feature module exports init(root). Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const { load } = require("./support/module.js");

const SHARED = {
  "dom/config.js": ["parseValue", "readConfig"],
  "text/normalize.js": ["includesAll", "matches", "normalize", "squash", "terms"],
  "theme/current.js": ["currentTheme", "onThemeChange"],
  "data/filter-chips.js": ["cellText", "chips"],
  "data/chart-table.js": ["tableData"],
};
const FEATURES = ["chrome/menu.js", "chrome/theme-toggle.js", "chrome/search-keys.js", "chrome/search.js", "content/code-copy.js", "content/scroll-region.js",
  "structure/tabs.js", "structure/accordion.js", "data/table-stack.js", "data/filter.js", "data/chart.js", "blog/share.js"];

test("shared modules keep their export names", async () => {
  for (const [rel, names] of Object.entries(SHARED)) {
    assert.deepStrictEqual(Object.keys(await load(rel)).sort(), names, rel);
  }
});

test("every feature module exports init(root)", async () => {
  for (const rel of FEATURES) {
    assert.strictEqual(typeof (await load(rel)).init, "function", rel);
  }
});
