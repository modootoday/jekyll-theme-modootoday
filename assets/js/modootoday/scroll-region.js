// Overflowing code blocks and table wrappers become labelled focusable regions.
(() => {
  const ds = document.documentElement.dataset;
  const attrs = ["tabindex", "role", "aria-label", "data-mt-scroll"];
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
  const ro = window.ResizeObserver && new ResizeObserver((es) => es.forEach((e) => sync(e.target)));
  document.querySelectorAll(".mt-main pre, .mt-main .mt-table").forEach((el) => (ro ? ro.observe(el) : sync(el)));
})();
