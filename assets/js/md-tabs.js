// md-components v1 (draft) — jekyll-theme-modootoday. Optional progressive enhancement:
// inside section[data-tabs], consecutive h3 + code block pairs become ARIA tabs (WAI-ARIA APG Tabs).
// Without JS every method stays visible in order.
(function () {
  document.querySelectorAll("section[data-tabs]").forEach(function (sec, g) {
    const heads = [...sec.querySelectorAll(":scope > h3")].filter((h) =>
      h.nextElementSibling && h.nextElementSibling.matches(".highlighter-rouge, pre"));
    if (heads.length < 2) return;
    const list = document.createElement("div");
    list.setAttribute("role", "tablist");
    list.setAttribute("aria-label", sec.dataset.tabsLabel || "Options");
    heads[0].before(list);
    const tabs = [];
    const select = (n) => tabs.forEach((t) => {
      const on = t === n;
      t.setAttribute("aria-selected", String(on)); t.tabIndex = on ? 0 : -1; t._panel.hidden = !on;
    });
    heads.forEach((h, i) => {
      const panel = h.nextElementSibling, base = `md-tabs-${g}-${h.id || i}`;
      const b = document.createElement("button");
      b.type = "button"; b.setAttribute("role", "tab"); b.id = `${base}-tab`; b.textContent = h.textContent;
      if (!panel.id) panel.id = `${base}-panel`;
      panel.setAttribute("role", "tabpanel"); panel.tabIndex = 0;
      panel.setAttribute("aria-labelledby", b.id); b.setAttribute("aria-controls", panel.id);
      b._panel = panel; b.addEventListener("click", () => select(b));
      h.hidden = true; list.append(b); tabs.push(b);
    });
    select(tabs[0]);
    list.addEventListener("keydown", (e) => {
      const i = tabs.indexOf(document.activeElement);
      if (i < 0) return;
      const n = { ArrowRight: i + 1, ArrowLeft: i - 1, Home: 0, End: tabs.length - 1 }[e.key];
      if (n === undefined) return;
      e.preventDefault();
      const t = tabs[(n + tabs.length) % tabs.length]; select(t); t.focus();
    });
  });
})();
