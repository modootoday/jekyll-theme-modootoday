// jekyll-theme-modootoday — light/dark toggle (stored in localStorage "mt-theme").
(function () {
  var root = document.documentElement, b = document.querySelector(".mt-theme-toggle");
  if (!b) return;
  var mq = window.matchMedia ? window.matchMedia("(prefers-color-scheme: dark)") : null;
  function current() { return root.dataset.theme || (mq && mq.matches ? "dark" : "light"); }
  function sync() { b.setAttribute("aria-pressed", String(current() === "dark")); }
  b.hidden = false;
  sync();
  b.addEventListener("click", function () {
    var t = current() === "dark" ? "light" : "dark";
    root.dataset.theme = t;
    try { localStorage.setItem("mt-theme", t); } catch (e) {}
    sync();
  });
  if (mq && mq.addEventListener) mq.addEventListener("change", sync);
})();
