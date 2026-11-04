// section[data-tabs]: h3 + code pairs become APG tabs; all visible without JS.
const select = (tabs, n) => tabs.forEach((t) => {
  const on = t == n;
  t.ariaSelected = on;
  t.tabIndex = on ? 0 : -1;
  t._panel.hidden = !on;
});

const KEYS = { ArrowRight: (i, d) => i + d, ArrowLeft: (i, d) => i - d, Home: () => 0, End: (i, d, n) => n - 1 };

function tabify(doc, sec, g) {
  const heads = [...sec.querySelectorAll(":scope > h3")].filter((h) => h.nextElementSibling?.matches(".highlighter-rouge, pre"));
  if (heads.length < 2) {
    return;
  }
  const list = Object.assign(doc.createElement("div"), { role: "tablist", ariaLabel: sec.dataset.tabsLabel || "Options" });
  const tabs = [];
  heads[0].before(list);
  heads.forEach((h, i) => {
    const panel = h.nextElementSibling;
    const base = `mt-tabs-${g}-${h.id || i}`;
    const b = Object.assign(doc.createElement("button"), { type: "button", role: "tab", id: base + "-tab", textContent: h.textContent, _panel: panel });
    panel.id ||= base + "-panel";
    Object.assign(panel, { role: "tabpanel", tabIndex: 0 }).setAttribute("aria-labelledby", b.id);
    b.setAttribute("aria-controls", panel.id);
    b.onclick = () => select(tabs, b);
    h.hidden = true;
    list.append(b);
    tabs.push(b);
  });
  select(tabs, tabs[0]);
  list.addEventListener("keydown", (e) => {
    const i = tabs.indexOf(doc.activeElement);
    const d = list.closest("[dir]")?.dir == "rtl" ? -1 : 1;
    const L = tabs.length;
    if (i < 0 || !KEYS[e.key]) {
      return;
    }
    e.preventDefault();
    const t = tabs[(KEYS[e.key](i, d, L) + L) % L];
    select(tabs, t);
    t.focus();
  });
}

export function init(root) {
  const doc = root.ownerDocument || root;
  root.querySelectorAll("section[data-tabs]").forEach((sec, g) => tabify(doc, sec, g));
}

init(document);
