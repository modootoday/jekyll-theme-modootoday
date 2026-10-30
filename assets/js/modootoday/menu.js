// Menus: Esc, arrows, Home/End; one open.
(() => {
  const menus = [...document.querySelectorAll("details.mt-menu")];
  const close = (d, focus) => { if (d.open) { d.open = false; if (focus) d.querySelector("summary").focus(); } };
  menus.forEach((d) => {
    d.addEventListener("toggle", () => d.open && menus.forEach((o) => o != d && close(o)));
    d.addEventListener("keydown", (e) => {
      const list = [...d.querySelectorAll("ul a")], i = list.indexOf(document.activeElement), k = e.key, L = list.length;
      if (k == "Escape" && d.open) { e.preventDefault(); close(d, true); }
      else if (k == "ArrowDown" || k == "ArrowUp") {
        e.preventDefault(); d.open = true;
        list[k == "ArrowDown" ? (i + 1) % L : (i <= 0 ? L - 1 : i - 1)]?.focus();
      } else if ((k == "Home" || k == "End") && i >= 0) { e.preventDefault(); list[k == "Home" ? 0 : L - 1].focus(); }
    });
    d.addEventListener("focusout", (e) => { if (d.open && e.relatedTarget && !d.contains(e.relatedTarget)) close(d); });
  });
  document.addEventListener("click", (e) => menus.forEach((d) => d.contains(e.target) || close(d)));
})();
addEventListener("click",e=>e.target.closest?.('a[href="#"]')&&e.preventDefault()); // "#" stays put
