// Overflowing code blocks and table wrappers become labelled focusable regions.
const ATTRS = ["tabindex", "role", "aria-label", "data-mt-scroll"];

export function init(root) {
  const doc = root.ownerDocument || root;
  const win = doc.defaultView;
  const ds = doc.documentElement.dataset;
  const sync = (el) => {
    const over = el.scrollWidth > el.clientWidth + 1;
    const panel = el.closest("[role=tabpanel]");
    if (over && !el.hasAttribute("aria-label")) {
      el.tabIndex = 0;
      el.dataset.mtScroll = "";
      el.setAttribute("role", "region");
      el.setAttribute("aria-label", el.tagName == "PRE" ? ds.mtCode || "Code" : ds.mtTable || "Table");
    } else if (!over && el.hasAttribute("data-mt-scroll")) {
      ATTRS.forEach((a) => el.removeAttribute(a));
    }
    if (panel) {
      panel.tabIndex = over ? -1 : 0;
    }
  };
  const ro = win.ResizeObserver && new win.ResizeObserver((es) => es.forEach((e) => sync(e.target)));
  root.querySelectorAll(".mt-main pre, .mt-main .mt-table").forEach((el) => (ro ? ro.observe(el) : sync(el)));
}

init(document);
