// Accordion (APG disclosure) for c: accordion sections; plain headings without JS.
export function init(root) {
  const doc = root.ownerDocument || root;
  let n = 0;
  root.querySelectorAll('[data-c="accordion"] > h3').forEach((h) => {
    const id = "mt-acc-" + ++n;
    const panel = Object.assign(doc.createElement("div"), { className: "mt-accordion-panel", id, hidden: true });
    while (h.nextSibling && !/^H[23]$/.test(h.nextSibling.tagName)) {
      panel.append(h.nextSibling);
    }
    h.after(panel);
    const b = Object.assign(doc.createElement("button"), { type: "button", className: "mt-accordion-trigger" });
    b.setAttribute("aria-expanded", "false");
    b.setAttribute("aria-controls", id);
    b.append(...h.childNodes);
    h.append(b);
    b.onclick = () => {
      const open = b.getAttribute("aria-expanded") != "true";
      b.setAttribute("aria-expanded", open);
      panel.hidden = !open;
    };
  });
}

init(document);
