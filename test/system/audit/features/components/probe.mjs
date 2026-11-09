// In-page probe, run with page.evaluate: one row per component example (a section[data-section], or a chart, widget,
// math or diagram figure outside one), tagged data-mt-audit so the caller can shoot it, with what is wrong with it.
export function probeExamples() {
  const LEAK = [[/\{%|%\}|\{\{|\}\}/, "Liquid"], [/\{:[\s.#\w]/, "kramdown IAL"], [/\*\*/, "literal **"], [/<\/?(div|span|p|br|details|summary|section)\b|markdown="?1/, "raw HTML"], [/\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]/i, "alert marker"], [/^\s*c:\s+\w/, "c: fence"]];
  const SKIP = "pre, code, script, style, template, textarea, kbd, .docs-ex-code";
  const MARKED = { timeline: ":scope > h3, :scope > ol > li", steps: ":scope > h3, :scope > ol > li" };
  const vw = document.documentElement.clientWidth;
  const css = [];
  const walk = (rules) => {
    for (const r of rules) {
      if (r.selectorText) css.push(r.selectorText);
      if (r.cssRules) walk(r.cssRules);
    }
  };
  for (const s of document.styleSheets) {
    try { walk(s.cssRules); } catch { /* a cross-origin sheet cannot be read */ }
  }
  const styled = (sel) => css.some((t) => t.includes(sel));
  const shown = (el) => {
    const r = el.getBoundingClientRect();
    return r.width > 1 && r.height > 1 && el.checkVisibility({ visibilityProperty: true });
  };
  const pseudo = (el) => {
    const b = getComputedStyle(el, "::before");
    return b.content !== "none" && b.content !== "normal" && (parseFloat(b.width) > 0 || b.content.length > 2);
  };
  const scroller = (el) => /auto|scroll/.test(getComputedStyle(el).overflowX);
  const units = [...document.querySelectorAll("main section[data-section]")];
  for (const f of document.querySelectorAll("main figure.mt-chart, main .mt-widget, main figure.mt-math, main .mt-diagram")) {
    if (!f.closest("section[data-section]")) units.push(f);
  }
  return units.map((u, i) => {
    const id = u.dataset.section || `${u.className.split(" ").filter((k) => k.startsWith("mt-")).pop() || u.tagName.toLowerCase()}-${i}`;
    u.dataset.mtAudit = `${i}`;
    const issues = [];
    const label = u.querySelector(":scope > .docs-ex-result");
    let nodes = [...u.children].filter((e) => e.tagName !== "H2");
    if (label) {
      nodes = [];
      for (let n = label.nextElementSibling; n; n = n.nextElementSibling) nodes.push(n);
    }
    if (!u.matches("section")) nodes = [u];
    const all = nodes.flatMap((n) => [n, ...n.querySelectorAll("*")]);
    for (const n of nodes) {
      const tw = document.createTreeWalker(n, NodeFilter.SHOW_TEXT);
      for (let t; (t = tw.nextNode()); ) {
        if (t.parentElement.closest(SKIP)) continue;
        for (const [re, what] of LEAK) if (re.test(t.textContent)) issues.push(`leaked ${what}: "${t.textContent.trim().slice(0, 60)}"`);
      }
    }
    const box = u.getBoundingClientRect();
    const visible = all.filter(shown);
    const tops = visible.map((e) => e.getBoundingClientRect());
    const h = tops.length ? Math.max(...tops.map((r) => r.bottom)) - Math.min(...tops.map((r) => r.top)) : 0;
    if (!nodes.length || !visible.length || h < 8) issues.push(`empty result (${nodes.length} nodes, ${visible.length} shown, ${Math.round(h)}px)`);
    const c = u.dataset.c;
    const own = new Set([u, ...all].flatMap((e) => [...e.classList]).filter((k) => k.startsWith("mt-") && k !== "mt-section"));
    if (c && ![...own].some((k) => styled(`.${k}`))) issues.push(`no stylesheet rule for any of ${[...own].join(" ") || "its classes"}`);
    for (const list of c ? nodes.filter((n) => /^(OL|UL)$/.test(n.tagName)) : []) {
      const li = list.querySelector(":scope > li");
      const tag = list.tagName.toLowerCase();
      if (li && getComputedStyle(li).listStyleType !== "none" && !pseudo(li) && !styled(`.mt-c-${c} > ${tag}`)) issues.push(`the ${tag} form of c: ${c} is unstyled (browser default list)`);
    }
    if (MARKED[c]) {
      const bare = [...u.querySelectorAll(MARKED[c])].filter((e) => !pseudo(e));
      if (bare.length) issues.push(`${bare.length} ${c} item(s) without a marker (${bare[0].tagName.toLowerCase()})`);
    }
    const edge = u.matches(".mt-bleed, .mt-c-split") ? { left: 0, right: vw } : box;
    for (const e of visible) {
      const cs = getComputedStyle(e);
      if (e.closest(".mt-lightbox, .mt-sr-only") || cs.position === "fixed" || cs.transform !== "none") continue;
      let inScroll = false;
      for (let p = e.parentElement; p && p !== u.parentElement; p = p.parentElement) if (scroller(p)) inScroll = true;
      if (inScroll) continue;
      const r = e.getBoundingClientRect();
      const what = `${e.tagName.toLowerCase()}${e.classList[0] ? "." + e.classList[0] : ""}`;
      if (r.right > edge.right + 1 || r.left < edge.left - 1) issues.push(`overflow: ${what} ${Math.round(r.left)}..${Math.round(r.right)} outside ${Math.round(edge.left)}..${Math.round(edge.right)}`);
      if (/hidden|clip/.test(cs.overflowX) && cs.textOverflow !== "ellipsis" && e.clientWidth > 0 && e.scrollWidth > e.clientWidth + 2) issues.push(`clipped: ${what} ${e.scrollWidth}>${e.clientWidth}`);
    }
    for (const img of all.filter((e) => e.tagName === "IMG")) {
      if (img.complete && img.naturalWidth === 0) issues.push(`broken image ${img.getAttribute("src")}`);
      else if (!img.complete && shown(img)) issues.push(`image not loaded ${img.getAttribute("src")}`);
    }
    for (const svg of all.filter((e) => e.tagName === "svg" && e.parentElement && shown(e.parentElement))) {
      const use = svg.querySelector("use");
      const ref = use && (use.getAttribute("href") || use.getAttribute("xlink:href"));
      if (!shown(svg) && !svg.closest(".mt-sr-only, [hidden]")) issues.push(`icon not drawn (${svg.getAttribute("class") || "svg"})`);
      if (ref && ref.startsWith("#") && !document.getElementById(ref.slice(1))) issues.push(`icon ${ref} missing`);
    }
    const src = u.querySelector(".docs-ex-code .docs-ex-source + div pre");
    if (src) issues.push(...compareSource(src.textContent, nodes));
    if (src && !src.textContent.trim()) issues.push("the example source is empty");
    for (const part of u.querySelectorAll(":scope .docs-ex-code, :scope .docs-ex-result")) if (!shown(part)) issues.push(`${part.className.split(" ")[0]} is hidden (inside ${part.parentElement.closest("[class]").className.split(" ")[0]})`);
    return { id, i, c: c || null, w: Math.round(box.width), h: Math.round(box.height), issues: [...new Set(issues)] };
  });

  // A result must show at least as many of each counted block as its source writes at the top level.
  function compareSource(md, nodes) {
    const q = (sel) => nodes.flatMap((n) => (n.matches(sel) ? [n] : [...n.querySelectorAll(sel)]));
    const n = (re) => md.split("\n").filter((l) => re.test(l)).length;
    const pairs = [[n(/^\d+\.\s/), q("ol > li").length, "ordered list items"], [n(/^###\s/), q("h3").length, "### headings"], [n(/^>\s*\[!/), q(".mt-callout").length, "alerts"], [n(/^\|[\s:|-]*-[\s:|-]*$/), q("table").length, "tables"], [n(/!\[[^\]]*\]\(/), q("img").length, "images"]];
    return pairs.filter(([want, got]) => want && got < want).map(([want, got, what]) => `source has ${want} ${what}, result shows ${got}`);
  }
}
