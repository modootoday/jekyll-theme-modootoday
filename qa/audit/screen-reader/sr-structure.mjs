// Screen-reader structure on one loaded page: lang/dir, title, landmarks, skip link, heading order,
// accessible names, decorative SVG, tables, images, link text, live regions. Returns problem strings.
export async function checkStructure(page) {
  return page.evaluate(() => {
    const out = [], $$ = (s) => [...document.querySelectorAll(s)];
    const vis = (e) => e.getClientRects().length > 0 && getComputedStyle(e).visibility !== "hidden";
    const html = document.documentElement;
    if (!html.lang) out.push("html lang missing");
    if (/^(ar|fa|he|ur)\b(?!-Latn)/.test(html.lang) && html.dir !== "rtl") out.push(`lang ${html.lang} without dir=rtl`);
    if (!document.title.trim()) out.push("empty <title>");
    if ($$("main").length !== 1) out.push(`main landmarks: ${$$("main").length}`);
    const headerless = $$("main.mt-shell-minimal, main.mt-mk-links").length > 0; // minimal, error and links layouts omit the site header by design
    for (const n of headerless ? [] : ["header"]) if (!$$(`body > ${n}, body > * > ${n}`).length && !$$(`[role=${n === "header" ? "banner" : "contentinfo"}]`).length) out.push(`no ${n} landmark`);
    const navs = $$("nav,[role=navigation]");
    if (navs.length > 1) for (const n of navs) if (!n.getAttribute("aria-label") && !n.getAttribute("aria-labelledby")) out.push("unlabelled nav among several");
    const skip = document.querySelector("body a[href^='#']");
    const tgt = skip && document.getElementById(decodeURIComponent(skip.getAttribute("href").slice(1)));
    if (!skip || !tgt || !(tgt.closest("main") || tgt.tagName === "MAIN")) out.push("no working skip link to main");
    const hs = $$("h1,h2,h3,h4,h5,h6").filter(vis);
    if ($$("h1").length !== 1) out.push(`h1 count ${$$("h1").length}`);
    let prev = 0;
    for (const h of $$("main h1, main h2, main h3, main h4, main h5, main h6")) {
      const l = +h.tagName[1];
      if (prev && l > prev + 1) out.push(`heading skip h${prev}->h${l} "${h.textContent.trim().slice(0, 40)}"`);
      prev = l;
    }
    void hs;
    const ids = {}; for (const e of $$("[id]")) ids[e.id] = (ids[e.id] || 0) + 1;
    for (const [k, v] of Object.entries(ids)) if (v > 1) out.push(`duplicate id #${k}`);
    for (const s of $$("svg")) if (!s.closest("[aria-hidden=true]") && s.getAttribute("role") !== "img") out.push(`svg not hidden nor role=img in ${s.parentElement.tagName.toLowerCase()}.${s.parentElement.className}`);
    for (const t of $$("main table")) {
      if (!t.querySelector("th")) out.push("table without th");
    }
    for (const i of $$("img")) if (!i.hasAttribute("alt")) out.push(`img no alt ${i.getAttribute("src")}`);
    for (const a of $$("a[href]")) {
      const t = (a.getAttribute("aria-label") || a.innerText || "").trim().toLowerCase();
      if (/^(click here|here|more|read more|여기|더 보기|こちら)$/.test(t)) out.push(`vague link text "${t}"`);
    }
    for (const b of $$("button,[role=button],[role=tab],[role=switch]")) {
      if (!vis(b)) continue;
      const n = (b.getAttribute("aria-label") || b.getAttribute("aria-labelledby") && "x" || b.textContent || b.title || "").trim();
      if (!n) out.push(`unnamed control ${b.outerHTML.slice(0, 80)}`);
    }
    const search = document.querySelector("input[type=search]");
    if (search && !$$("[aria-live],[role=status],[role=log]").length) out.push("search present but no live region");
    if ($$(".mt-copy, [data-copy], button.copy").length && !$$("[aria-live],[role=status]").length) out.push("copy button without live region");
    return [...new Set(out)];
  });
}
