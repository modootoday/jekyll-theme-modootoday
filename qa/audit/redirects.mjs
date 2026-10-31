// Redirect stubs: every built page with a meta refresh names a target, and a redirect stub's canonical is not empty
// (an empty `url=` or `href=""` means the layout read the wrong front matter key).
import fs from "node:fs";
import path from "node:path";
function* htmlFiles(dir) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const f = path.join(dir, e.name);
    if (e.isDirectory()) yield* htmlFiles(f); else if (e.name.endsWith(".html")) yield f;
  }
}
export function checkRedirects(site, fails) {
  let n = 0;
  for (const f of htmlFiles(site)) {
    const html = fs.readFileSync(f, "utf8");
    const m = html.match(/<meta http-equiv="refresh" content="([^"]*)"/i);
    if (!m) continue;
    n++;
    const rel = path.relative(site, f);
    if (!/url=\S/i.test(m[1])) fails.push(`redirect: empty refresh url in ${rel}`);
    const c = html.match(/<link rel="canonical" href="([^"]*)"/i);
    if (!c || !c[1].trim()) fails.push(`redirect: empty canonical in ${rel}`);
    const a = html.match(/<body>[\s\S]*?<a href="([^"]*)"/i);
    if (a && !a[1].trim()) fails.push(`redirect: empty link in ${rel}`);
  }
  return n;
}
