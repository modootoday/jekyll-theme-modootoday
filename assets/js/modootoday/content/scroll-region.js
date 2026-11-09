// Overflowing code blocks, table wrappers and figure scrollers become focusable regions, each named uniquely (axe
// landmark-unique): the label with a code title, caption or language, else the nearest heading; a figure keeps the name
// the page gave it. Regions that share a name at the moment are numbered.
const ATTRS = ["tabindex", "role", "aria-label", "data-mt-scroll"];
const fill = (s, v) => s.replace(/\[(\w+)\]/g, (m, k) => v[k] ?? m);
const text = (el) => (el ? el.textContent.replace(/\s+/g, " ").trim() : "");
const stem = (s) => s.toLowerCase().replace(/s$/, "");

function detail(el) {
  const title = el.closest(".mt-code")?.querySelector(".mt-code-title");
  const lang = el.closest("[class*='language-']")?.className.match(/language-(\S+)/)?.[1];
  return text(title?.lastChild) || text(el.querySelector("caption") || el.closest("figure")?.querySelector("figcaption")) || (lang != "plaintext" && lang);
}

export function names(root, ds) {
  const out = new Map();
  let heading = "";
  for (const el of root.querySelectorAll(".mt-main h2, .mt-main h3, .mt-main h4, .mt-main pre, .mt-main .mt-table, .mt-main .mt-figure-scroll")) {
    if (el.tagName[0] == "H") {
      heading = text(el);
      continue;
    }
    const label = el.tagName == "PRE" ? ds.mtCode || "Code" : ds.mtTable || "Table";
    let name = detail(el) || heading;
    // A heading that only repeats the label ("Tables" over a table) adds nothing to the name.
    if (stem(name || "") == stem(label)) {
      name = "";
    }
    out.set(el, el.getAttribute("aria-label") || (name ? fill(ds.mtRegionNamed || "[label], [name]", { label, name }) : label));
  }
  return out;
}

// The names of the live regions, numbered in page order among those that share one.
export function numbered(named, live, ds) {
  const out = new Map();
  const seen = Object.create(null);
  const count = Object.create(null);
  named.forEach((name, el) => live.has(el) && (count[name] = (count[name] || 0) + 1));
  named.forEach((name, el) => {
    if (live.has(el)) {
      seen[name] = (seen[name] || 0) + 1;
      out.set(el, count[name] > 1 ? fill(ds.mtRegionNth || "[name] [n]", { name, n: seen[name] }) : name);
    }
  });
  return out;
}

export function init(root) {
  const doc = root.ownerDocument || root;
  const win = doc.defaultView;
  const ds = doc.documentElement.dataset;
  const named = names(root, ds);
  // A figure scroller arrives as a region, so readers without this script can still scroll it from the keyboard.
  const live = new Set([...named.keys()].filter((el) => el.hasAttribute("role")));
  const sync = (el) => {
    const over = el.scrollWidth > el.clientWidth + 1;
    const panel = el.closest("[role=tabpanel]");
    if (panel) {
      panel.tabIndex = over ? -1 : 0;
    }
    if (over && !live.has(el)) {
      live.add(el);
      el.tabIndex = 0;
      el.dataset.mtScroll = "";
      el.setAttribute("role", "region");
    } else if (!over && live.has(el)) {
      live.delete(el);
      ATTRS.forEach((a) => el.removeAttribute(a));
    }
  };
  const label = () => numbered(named, live, ds).forEach((name, el) => el.setAttribute("aria-label", name));
  const ro = win.ResizeObserver && new win.ResizeObserver((es) => {
    es.forEach((e) => sync(e.target));
    label();
  });
  named.forEach((name, el) => (ro ? ro.observe(el) : sync(el)));
  if (!ro) {
    label();
  }
}

init(document);
