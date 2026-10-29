// Accordion (APG disclosure) for `c: accordion` sections; plain headings without JS.
(() => {
  let n = 0;
  document.querySelectorAll('[data-c="accordion"] > h3').forEach((h) => {
    const id = "mt-acc-" + ++n, panel = Object.assign(document.createElement("div"), { className: "mt-accordion-panel", id, hidden: true });
    while (h.nextSibling && !/^H[23]$/.test(h.nextSibling.tagName)) panel.append(h.nextSibling);
    h.after(panel);
    const b = Object.assign(document.createElement("button"), { type: "button", className: "mt-accordion-trigger" });
    b.setAttribute("aria-expanded", "false"); b.setAttribute("aria-controls", id);
    b.append(...h.childNodes); h.append(b);
    b.onclick = () => { const open = b.getAttribute("aria-expanded") != "true"; b.setAttribute("aria-expanded", open); panel.hidden = !open; };
  });
})();
