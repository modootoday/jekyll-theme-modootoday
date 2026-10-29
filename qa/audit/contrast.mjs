// Token-level WCAG AA contrast: foreground/background token pairs, read from the live page per colour scheme.
// logical name -> candidate token names (v0.2 semantic names first, v0.1 names as fallback)
const T = {
  fg: ["foreground", "fg"], "fg-muted": ["muted-foreground", "fg-muted"], bg: ["background", "bg"], "bg-subtle": ["muted", "bg-subtle"],
  accent: ["primary", "accent"], "accent-fg": ["primary-foreground", "accent-fg"], card: ["card"], "card-fg": ["card-foreground"], border: ["border"],
  ...Object.fromEntries(["note", "tip", "important", "warning", "caution"].map((t) => [t, [t]])),
  ...Object.fromEntries(["available", "partial", "planned"].map((t) => [t, ["status-" + t, t]])),
};
const PAIRS = [
  ["fg", "bg", 4.5], ["fg-muted", "bg", 4.5], ["fg", "bg-subtle", 4.5], ["fg-muted", "bg-subtle", 4.5], ["card-fg", "card", 4.5],
  ["accent", "bg", 4.5], ["accent-fg", "accent", 4.5], ["border", "bg", 1.2],
  ...["note", "tip", "important", "warning", "caution", "available", "partial", "planned"].map((t) => [t, "bg", 4.5]),
  ...["note", "tip", "important", "warning", "caution"].map((t) => [t, "bg-subtle", 3]),
];
const lum = (c) => { const [r, g, b] = c.map((v) => { v /= 255; return v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4; }); return 0.2126 * r + 0.7152 * g + 0.0722 * b; };
const ratio = (a, b) => { const [x, y] = [lum(a), lum(b)].sort((p, q) => q - p); return (x + 0.05) / (y + 0.05); };

// page: already on the site's home page in the given scheme. Appends to rows and fails.
export async function checkContrast(page, scheme, rows, fails) {
  const pre = "--mt-";
  const rgb = await page.evaluate(({ pre, T }) => Object.fromEntries(Object.entries(T).map(([n, cands]) => {
    let v = "", used = null;
    for (const c of cands) { v = getComputedStyle(document.documentElement).getPropertyValue(pre + c).trim(); if (v) { used = pre + c; break; } }
    if (!v) return [n, null];
    const d = document.createElement("i"); d.style.color = v; document.body.append(d);
    const c = getComputedStyle(d).color.match(/[\d.]+/g).slice(0, 3).map(Number); d.remove(); return [n, { c, used }];
  })), { pre, T });
  for (const [f, b, min] of PAIRS) {
    if (!rgb[f] || !rgb[b]) continue;
    const r = +ratio(rgb[f].c, rgb[b].c).toFixed(2);
    rows.push({ scheme, fg: rgb[f].used, bg: rgb[b].used, ratio: r, min });
    if (r < min) fails.push(`contrast ${scheme} ${rgb[f].used} on ${rgb[b].used} = ${r} < ${min}`);
  }
}
