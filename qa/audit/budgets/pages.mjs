// What one built page loads: its local stylesheets, scripts and module preloads, plus the modules those scripts import.
import fs from "node:fs";
import path from "node:path";

const TAG = /<(?:link|script)\b[^>]*>/g;
const IMPORT = /(?:^|[;\s})])(?:import|export)\s*(?:[\w$*{}\s,]+from\s*)?["'](\.{1,2}\/[^"']+)["']/g;

// A site URL such as /base/assets/js/x.js?v=1 becomes js/x.js (relative to assets/); other URLs give null.
const assetPath = (url) => {
  if (!url || !url.startsWith("/") || url.startsWith("//")) {
    return null;
  }
  const m = url.match(/\/assets\/([^?#]+)/);
  return m ? m[1] : null;
};

const attr = (tag, name) => {
  const m = tag.match(new RegExp(`\\s${name}="([^"]*)"`));
  return m ? m[1] : null;
};

// Follows static relative imports from each script (the module graph), breadth first.
const withImports = (site, scripts) => {
  const seen = new Set(scripts);
  const queue = [...scripts];
  while (queue.length) {
    const f = queue.shift();
    const file = path.join(site, "assets", f);
    if (!fs.existsSync(file)) {
      continue;
    }
    for (const m of fs.readFileSync(file, "utf8").matchAll(IMPORT)) {
      const dep = path.posix.join(path.posix.dirname(f), m[1]);
      if (!seen.has(dep)) {
        seen.add(dep);
        queue.push(dep);
      }
    }
  }
  return [...seen];
};

export function pageAssets(site, html) {
  const css = new Set();
  const js = new Set();
  for (const [tag] of html.matchAll(TAG)) {
    const isLink = tag.startsWith("<link");
    const f = assetPath(attr(tag, isLink ? "href" : "src"));
    if (!f) {
      continue;
    }
    if (!isLink) {
      js.add(f);
    } else if (/\srel="?stylesheet/.test(tag)) {
      css.add(f);
    } else if (/\srel="?modulepreload/.test(tag)) {
      js.add(f);
    }
  }
  return { css: [...css], js: withImports(site, [...js]) };
}
