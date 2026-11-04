// Menus (details.mt-menu): Esc, arrows, Home/End; one open at a time; a click outside closes them.
const close = (d, focus) => {
  if (!d.open) {
    return;
  }
  d.open = false;
  if (focus) {
    d.querySelector("summary").focus();
  }
};

const step = (k, i, n) => {
  if (k == "ArrowDown") {
    return (i + 1) % n;
  }
  return i <= 0 ? n - 1 : i - 1;
};

export function init(root) {
  const doc = root.ownerDocument || root;
  const menus = [...root.querySelectorAll("details.mt-menu")];
  menus.forEach((d) => {
    d.addEventListener("toggle", () => d.open && menus.forEach((o) => o != d && close(o)));
    d.addEventListener("keydown", (e) => {
      const list = [...d.querySelectorAll("ul a")];
      const i = list.indexOf(doc.activeElement);
      const k = e.key;
      if (k == "Escape" && d.open) {
        e.preventDefault();
        close(d, true);
      } else if (k == "ArrowDown" || k == "ArrowUp") {
        e.preventDefault();
        d.open = true;
        list[step(k, i, list.length)]?.focus();
      } else if ((k == "Home" || k == "End") && i >= 0) {
        e.preventDefault();
        list[k == "Home" ? 0 : list.length - 1].focus();
      }
    });
    d.addEventListener("focusout", (e) => {
      if (d.open && e.relatedTarget && !d.contains(e.relatedTarget)) {
        close(d);
      }
    });
  });
  doc.addEventListener("click", (e) => menus.forEach((d) => d.contains(e.target) || close(d)));
  // A "#" link stays put.
  doc.addEventListener("click", (e) => e.target.closest?.('a[href="#"]') && e.preventDefault());
}

init(document);
