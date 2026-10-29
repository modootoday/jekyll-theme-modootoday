// jekyll-theme-modootoday — light/dark toggle (stored in localStorage "mt-theme").
(() => {
  let root = document.documentElement, b = document.querySelector(".mt-theme-toggle");
  if (!b) return;
  let mq = window.matchMedia ? window.matchMedia("(prefers-color-scheme: dark)") : null;
  const current = () => root.dataset.theme || (mq && mq.matches ? "dark" : "light");
  const sync = () => b.setAttribute("aria-pressed", current() == "dark");
  b.hidden = false;
  sync();
  b.addEventListener("click", () => {
    let t = current() === "dark" ? "light" : "dark";
    root.dataset.theme = t;
    try { localStorage.setItem("mt-theme", t); } catch (e) {}
    sync();
  });
  if (mq && mq.addEventListener) mq.addEventListener("change", sync);
})();
