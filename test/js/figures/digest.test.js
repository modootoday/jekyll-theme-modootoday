// script/figures/digest.mjs against the cases test/checker/page/figures/freshness_test.rb runs through
// Modootoday::Figures.digest, so the node and Ruby digests stay one rule. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const fs = require("node:fs");
const path = require("node:path");

const ROOT = path.join(__dirname, "../../..");
const CASES = JSON.parse(fs.readFileSync(path.join(ROOT, "test/fixtures/figures/digests.json"), "utf8"));

test("the node digest equals the Ruby digest on every shared case", async () => {
  const { digest } = await import(path.join(ROOT, "script/figures/digest.mjs"));
  assert.ok(CASES.length >= 4);
  for (const c of CASES) {
    assert.strictEqual(digest(c.body), c.digest, JSON.stringify(c.body));
  }
});

test("line endings and final newlines do not change the digest", async () => {
  const { digest } = await import(path.join(ROOT, "script/figures/digest.mjs"));
  assert.strictEqual(digest("a\r\nb\r\n\n"), digest("a\nb"));
  assert.strictEqual(digest("a\rb"), digest("a\nb"));
  assert.notStrictEqual(digest(" a\nb"), digest("a\nb"));
  assert.notStrictEqual(digest("a\n\nb"), digest("a\nb"));
});
