// Dropdown menus built on <details class="mt-menu"> (nav groups, language switcher). They open without JS;
// this adds Esc (closes, focus back to the button), arrow keys between items, closing on outside click or
// when another menu opens.
(function () {
  var menus = [].slice.call(document.querySelectorAll("details.mt-menu"));
  if (!menus.length) return;
  function close(d, focus) { if (d.open) { d.open = false; if (focus) d.querySelector("summary").focus(); } }
  function items(d) { return [].slice.call(d.querySelectorAll("ul a")); }
  menus.forEach(function (d) {
    d.addEventListener("toggle", function () { if (d.open) menus.forEach(function (o) { if (o !== d) close(o); }); });
    d.addEventListener("keydown", function (e) {
      var list = items(d), i = list.indexOf(document.activeElement);
      if (e.key === "Escape" && d.open) { e.preventDefault(); close(d, true); }
      else if (e.key === "ArrowDown" || e.key === "ArrowUp") {
        e.preventDefault(); d.open = true;
        var n = e.key === "ArrowDown" ? (i + 1) % list.length : (i <= 0 ? list.length - 1 : i - 1);
        if (list[n]) list[n].focus();
      } else if ((e.key === "Home" || e.key === "End") && i >= 0) { e.preventDefault(); list[e.key === "Home" ? 0 : list.length - 1].focus(); }
    });
    d.addEventListener("focusout", function (e) { if (d.open && e.relatedTarget && !d.contains(e.relatedTarget)) close(d); });
  });
  document.addEventListener("click", function (e) { menus.forEach(function (d) { if (!d.contains(e.target)) close(d); }); });
})();
