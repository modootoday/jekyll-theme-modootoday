// section[data-tabs]: h3 + code pairs become APG tabs; all visible without JS.
(() => {
  document.querySelectorAll("section[data-tabs]").forEach((sec, g) => {
    const heads = [...sec.querySelectorAll(":scope > h3")].filter((h) => h.nextElementSibling?.matches(".highlighter-rouge, pre"));
    if (heads.length < 2) return;
    const list = Object.assign(document.createElement("div"), { role: "tablist", ariaLabel: sec.dataset.tabsLabel || "Options" }), tabs = [];
    heads[0].before(list);
    const select = (n) => tabs.forEach((t) => { const on = t == n; t.ariaSelected = on; t.tabIndex = on ? 0 : -1; t._panel.hidden = !on; });
    heads.forEach((h, i) => {
      const panel = h.nextElementSibling, base = `mt-tabs-${g}-${h.id || i}`;
      const b = Object.assign(document.createElement("button"), { type: "button", role: "tab", id: base + "-tab", textContent: h.textContent, _panel: panel });
      panel.id ||= base + "-panel";
      Object.assign(panel, { role: "tabpanel", tabIndex: 0 }).setAttribute("aria-labelledby", b.id);
      b.setAttribute("aria-controls", panel.id); b.onclick = () => select(b);
      h.hidden = true; list.append(b); tabs.push(b);
    });
    select(tabs[0]);
    list.addEventListener("keydown", (e) => {
      const i = tabs.indexOf(document.activeElement), d = list.closest("[dir]")?.dir == "rtl" ? -1 : 1, L = tabs.length;
      const n = i < 0 ? undefined : { ArrowRight: i + d, ArrowLeft: i - d, Home: 0, End: L - 1 }[e.key];
      if (n === undefined) return;
      e.preventDefault();
      const t = tabs[(n + L) % L]; select(t); t.focus();
    });
  });
})();
