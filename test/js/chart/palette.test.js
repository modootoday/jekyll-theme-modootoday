// The default chart palettes in _sass/modootoday/components/data/_chart.scss: every series has 3:1 or more against the
// page background of its scheme (WCAG 1.4.11), and adjacent series stay apart (CIELAB distance) under the Machado (2009)
// severity-1 simulations of protanopia, deuteranopia and tritanopia. Line charts add dash patterns. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const fs = require("node:fs");
const path = require("node:path");

const SCSS = fs.readFileSync(path.join(__dirname, "../../../_sass/modootoday/components/data/_chart.scss"), "utf8");
const list = (name) => SCSS.match(new RegExp(`\\$${name}: ([^;]+);`))[1].split(",").map((s) => s.trim());
const PALETTES = { light: [list("mt-chart-light"), "#ffffff"], dark: [list("mt-chart-dark"), "#0a0a0a"] };
const CVD = {
  none: [[1, 0, 0], [0, 1, 0], [0, 0, 1]],
  protan: [[0.152286, 1.052583, -0.204868], [0.114503, 0.786281, 0.099216], [-0.003882, -0.048116, 1.051998]],
  deutan: [[0.367322, 0.860646, -0.227968], [0.280085, 0.672501, 0.047413], [-0.01182, 0.04294, 0.968881]],
  tritan: [[1.255528, -0.076749, -0.178779], [-0.078411, 0.930809, 0.147602], [0.004733, 0.691367, 0.3039]],
};
const FLOOR = 15;

const linear = (v) => (v <= 0.04045 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4);
const rgb = (hex) => [1, 3, 5].map((i) => linear(parseInt(hex.slice(i, i + 2), 16) / 255));
const luminance = ([r, g, b]) => 0.2126 * r + 0.7152 * g + 0.0722 * b;
const contrast = (a, b) => {
  const [hi, lo] = [luminance(rgb(a)), luminance(rgb(b))].sort((x, y) => y - x);
  return (hi + 0.05) / (lo + 0.05);
};
const lab = ([r, g, b]) => {
  const f = (t) => (t > 216 / 24389 ? Math.cbrt(t) : ((24389 / 27) * t + 16) / 116);
  const x = f((0.4124 * r + 0.3576 * g + 0.1805 * b) / 0.95047);
  const y = f(0.2126 * r + 0.7152 * g + 0.0722 * b);
  const z = f((0.0193 * r + 0.1192 * g + 0.9505 * b) / 1.08883);
  return [116 * y - 16, 500 * (x - y), 200 * (y - z)];
};
const simulate = (c, m) => m.map((row) => Math.min(1, Math.max(0, row[0] * c[0] + row[1] * c[1] + row[2] * c[2])));

test("eight series colours per scheme, each 3:1 or more on the page background", () => {
  for (const [scheme, [colours, bg]] of Object.entries(PALETTES)) {
    assert.strictEqual(colours.length, 8, scheme);
    for (const c of colours) {
      assert.ok(contrast(c, bg) >= 3, `${scheme} ${c} on ${bg}: ${contrast(c, bg).toFixed(2)}`);
    }
  }
});

test(`adjacent series differ by ${FLOOR} or more (CIELAB) with and without colour-vision deficiency`, () => {
  for (const [scheme, [colours]] of Object.entries(PALETTES)) {
    for (const [kind, m] of Object.entries(CVD)) {
      const seen = colours.map((c) => lab(simulate(rgb(c), m)));
      for (let i = 1; i < seen.length; i++) {
        const d = Math.hypot(...seen[i].map((v, k) => v - seen[i - 1][k]));
        assert.ok(d >= FLOOR, `${scheme} ${kind}: ${colours[i - 1]} vs ${colours[i]} = ${d.toFixed(1)}`);
      }
    }
  }
});
