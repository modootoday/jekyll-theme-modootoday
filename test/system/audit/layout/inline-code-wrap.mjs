// Inline code wrap: at 360px a long unbroken inline code in a paragraph, list item, link, heading, callout or quote must
// wrap inside the column (no page-level horizontal scroll), while a fenced block keeps its own scroll. First-column code in a
// table stays whole and the table scrolls instead: table-reflow.mjs checks it on pages with tables.
import { readRegistry } from "../budgets/registry.mjs";

const W = 360;
const LONG = "site.modootoday.a_really_long_configuration_key_without_breaks.and_more_segments_here";
// A page links the code sheet only when its body has code, so a page without any gets it here, as real code would.
const CODE_SHEET = readRegistry().find((r) => r.name === "code").path;

export async function checkInlineCodeWrap(page, scheme, url, fails) {
  await page.setViewportSize({ width: W, height: 900 });
  await page.evaluate((sheet) => {
    const core = document.querySelector('link[rel="stylesheet"][href*="/assets/css/"]');
    if (!core || document.querySelector(`link[href*="${sheet}"]`)) {
      return null;
    }
    const link = Object.assign(document.createElement("link"), { rel: "stylesheet", href: core.href.replace(/\/assets\/css\/[^?]*/, sheet) });
    const loaded = new Promise((done) => {
      link.onload = done;
      link.onerror = done;
    });
    document.head.append(link);
    return loaded;
  }, CODE_SHEET);
  const r = await page.evaluate((long) => {
    // The post body first: a selector list would always match main, which comes first in document order.
    const host = document.querySelector("main .mt-prose") || document.querySelector("main article") || document.querySelector("main");
    const c = `<code>${long}</code>`;
    const box = document.createElement("div");
    box.innerHTML = `<p>${c}</p><ul><li>${c}</li></ul><p><a href="#">${c}</a></p><h2>${c}</h2>` +
      `<div class="mt-callout"><p>${c}</p></div><blockquote><p>${c}</p></blockquote>` +
      `<div class="highlighter-rouge"><pre><code>${long}${long}</code></pre></div>`;
    host.prepend(box);
    const over = document.documentElement.scrollWidth - innerWidth;
    const wide = [...box.querySelectorAll(":not(pre) > code")].filter((e) => e.getBoundingClientRect().right > innerWidth + 1).map((e) => e.parentElement.tagName.toLowerCase());
    const pre = box.querySelector("pre");
    const preScrolls = pre.scrollWidth > pre.clientWidth;
    box.remove();
    return { over, wide, preScrolls };
  }, LONG);
  if (r.over > 1) fails.push(`inline code: horizontal overflow ${r.over}px at ${W}px ${scheme} ${url}`);
  for (const t of r.wide) fails.push(`inline code in <${t}> runs past the viewport at ${W}px ${scheme} ${url}`);
  if (!r.preScrolls) fails.push(`inline code: fenced block no longer scrolls on its own at ${W}px ${scheme} ${url}`);
  await page.setViewportSize({ width: 1024, height: 900 });
}
