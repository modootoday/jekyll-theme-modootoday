// Per-file caps (adr:modootoday/20261104053146): each registry row's built file against its cap, in gzip bytes.
// A row without a cap, a file over its cap and a built theme file without a row fail; a file near its cap and a cap
// over twice the size warn. Each message prints the cap to use (adr:modootoday/20261109225836).
import fs from "node:fs";
import path from "node:path";
import zlib from "node:zlib";

export const gzipSize = (file) => zlib.gzipSync(fs.readFileSync(file)).length;

// The cap to write on a row: the measured size plus 10%, rounded up to 128 bytes.
export const capFor = (bytes) => Math.ceil((bytes * 1.1) / 128) * 128;

// A file past this share of its cap is about to outgrow it, so its next change needs the new cap.
export const NEAR = 0.95;

const THEME_FILE = /^(css\/modootoday.*\.css|js\/modootoday.*\.js)$/;

export function checkModules(site, rows, fails, warns) {
  const dir = path.join(site, "assets");
  const modules = {};
  for (const r of rows) {
    const file = path.join(dir, r.file);
    if (!fs.existsSync(file)) {
      continue;
    }
    const gzip = gzipSize(file);
    modules[r.file] = { gzip, cap: r.cap };
    if (r.cap == null) {
      fails.push(`${r.file}: no cap; measured ${gzip} B gzip -> cap ${capFor(gzip)} (sixth column of its registry row)`);
    } else if (gzip > r.cap) {
      fails.push(`${r.file}: ${gzip} B gzip > cap ${r.cap} B (raise the cap to ${capFor(gzip)} in the same change, with the reason)`);
    } else if (gzip > NEAR * r.cap) {
      warns.push(`${r.file}: ${gzip} B gzip is within ${Math.round((1 - NEAR) * 100)}% of cap ${r.cap} B; the cap to use when it grows is ${capFor(gzip)}`);
    } else if (r.cap > 2 * gzip) {
      warns.push(`${r.file}: cap ${r.cap} B is over twice the measured ${gzip} B gzip; lower it to ${capFor(gzip)}`);
    }
  }
  const built = fs.readdirSync(dir, { recursive: true }).map((f) => f.split(path.sep).join("/"));
  for (const f of built.filter((x) => THEME_FILE.test(x) && !modules[x])) {
    fails.push(`${f}: a theme file without a row in the asset registry; measured ${gzipSize(path.join(dir, f))} B gzip`);
  }
  return modules;
}
