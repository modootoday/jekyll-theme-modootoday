// Overflowing code/tables become labelled focusable regions.
(() => {
  const ds = document.documentElement.dataset, A = ["tabindex", "role", "aria-label", "data-mt-scroll"];
  const sync = (el) => {
    const over = el.scrollWidth > el.clientWidth + 1, pre = el.tagName == "PRE", tp = el.closest("[role=tabpanel]");
    if (over && !el.hasAttribute("aria-label")) {
      el.tabIndex = 0; el.dataset.mtScroll = ""; el.role = "region";
      el.ariaLabel = pre ? ds.mtCode || "Code" : ds.mtTable || "Table";
    } else if (!over && el.hasAttribute("data-mt-scroll")) A.forEach((a) => el.removeAttribute(a));
    if (tp) tp.tabIndex = over ? -1 : 0;
  };
  const ro = window.ResizeObserver && new ResizeObserver((es) => es.forEach((e) => sync(e.target)));
  document.querySelectorAll(".mt-main pre, .mt-main table").forEach((el) => ro ? ro.observe(el) : sync(el));
})();
