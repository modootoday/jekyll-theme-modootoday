// Overflowing code blocks and table wrappers become focusable regions, each named uniquely (axe landmark-unique): the
// label with a code title, caption or language, else the nearest heading, numbered while names repeat.
const ATTRS = ["tabindex", "role", "aria-label", "data-mt-scroll"];
const fill = (s, v) => s.replace(/\[(\w+)\]/g, (m, k) => v[k] ?? m);
const text = (el) => (el ? el.textContent.replace(/\s+/g, " ").trim() : "");

function detail(el) {
  const title = el.closest(".mt-code")?.querySelector(".mt-code-title");
  const lang = el.closest("[class*='language-']")?.className.match(/language-(\S+)/)?.[1];
  return text(title?.lastChild) || text(el.querySelector("caption") || el.closest("figure")?.querySelector("figcaption")) || (lang != "plaintext" && lang);
}

export function names(root, ds) {
  const out = new Map();
  const count = Object.create(null);
  let heading = "";
  for (const el of root.querySelectorAll(".mt-main h2, .mt-main h3, .mt-main h4, .mt-main pre, .mt-main .mt-table")) {
    if (el.tagName[0] == "H") {
      heading = text(el);
      continue;
    }
    const label = el.tagName == "PRE" ? ds.mtCode || "Code" : ds.mtTable || "Table";
    const name = detail(el) || heading;
    const full = name ? fill(ds.mtRegionNamed || "[label], [name]", { label, name }) : label;
    out.set(el, full);
    count[full] = (count[full] || 0) + 1;
  }
  const seen = Object.create(null);
  out.forEach((name, el) => {
    if (count[name] > 1) {
      seen[name] = (seen[name] || 0) + 1;
      out.set(el, fill(ds.mtRegionNth || "[name] [n]", { name, n: seen[name] }));
    }
  });
  return out;
}

export function init(root) {
  const doc = root.ownerDocument || root;
  const win = doc.defaultView;
  const named = names(root, doc.documentElement.dataset);
  const sync = (el) => {
    const over = el.scrollWidth > el.clientWidth + 1;
    const panel = el.closest("[role=tabpanel]");
    if (over && !el.hasAttribute("aria-label")) {
      el.tabIndex = 0;
      el.dataset.mtScroll = "";
      el.setAttribute("role", "region");
      el.setAttribute("aria-label", named.get(el));
    } else if (!over && el.hasAttribute("data-mt-scroll")) {
      ATTRS.forEach((a) => el.removeAttribute(a));
    }
    if (panel) {
      panel.tabIndex = over ? -1 : 0;
    }
  };
  const ro = win.ResizeObserver && new win.ResizeObserver((es) => es.forEach((e) => sync(e.target)));
  named.forEach((name, el) => (ro ? ro.observe(el) : sync(el)));
}

init(document);
