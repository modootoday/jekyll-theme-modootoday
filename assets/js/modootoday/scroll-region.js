// Overflowing code blocks and table wrappers become labelled focusable regions; stacked tables get header labels and roles.
(() => {
  const ds = document.documentElement.dataset;
  const attrs = ["tabindex", "role", "aria-label", "data-mt-scroll"];
  const roles = { THEAD: "rowgroup", TBODY: "rowgroup", TFOOT: "rowgroup", TR: "row", TH: "columnheader", TD: "cell" };
  const sync = (el) => {
    const over = el.scrollWidth > el.clientWidth + 1;
    const panel = el.closest("[role=tabpanel]");
    if (over && !el.hasAttribute("aria-label")) {
      el.tabIndex = 0;
      el.dataset.mtScroll = "";
      el.setAttribute("role", "region");
      el.setAttribute("aria-label", el.tagName == "PRE" ? ds.mtCode || "Code" : ds.mtTable || "Table");
    } else if (!over && el.hasAttribute("data-mt-scroll")) {
      attrs.forEach((a) => el.removeAttribute(a));
    }
    if (panel) {
      panel.tabIndex = over ? -1 : 0;
    }
  };
  // A table shown as blocks loses its implicit roles, so they are set before the stack sheet applies.
  const label = (t) => {
    const heads = t.tHead ? [...t.tHead.rows[0].cells].map((c) => c.textContent.trim()) : [];
    t.setAttribute("role", "table");
    t.querySelectorAll("thead, tbody, tfoot, tr, th, td").forEach((e) => {
      const head = e.tagName == "TH" && e.parentElement.parentElement.tagName != "THEAD";
      e.setAttribute("role", head ? "rowheader" : roles[e.tagName]);
    });
    t.querySelectorAll("tbody td").forEach((c) => {
      if (heads[c.cellIndex]) {
        c.dataset.label = heads[c.cellIndex];
      }
    });
    t.dataset.mtLabelled = "";
  };
  document.querySelectorAll(".mt-main table:is(.mt-table--stack, .mt-table--dl)").forEach(label);
  const ro = window.ResizeObserver && new ResizeObserver((es) => es.forEach((e) => sync(e.target)));
  document.querySelectorAll(".mt-main pre, .mt-main .mt-table").forEach((el) => (ro ? ro.observe(el) : sync(el)));
})();
