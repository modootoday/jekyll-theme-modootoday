// Light/dark toggle (stored in localStorage "mt-theme"). Each change is announced on document as mt:themechange,
// detail {theme, source}: "toggle" for a click, "system" for an OS change while no scheme is chosen.
(() => {
  const root = document.documentElement;
  const button = document.querySelector(".mt-theme-toggle");
  if (!button) {
    return;
  }
  const mq = window.matchMedia ? window.matchMedia("(prefers-color-scheme: dark)") : null;
  const current = () => root.dataset.theme || (mq && mq.matches ? "dark" : "light");
  const sync = () => button.setAttribute("aria-pressed", current() == "dark");
  const announce = (source) => document.dispatchEvent(new CustomEvent("mt:themechange", { detail: { theme: current(), source } }));
  button.hidden = false;
  sync();
  button.addEventListener("click", () => {
    const theme = current() === "dark" ? "light" : "dark";
    root.dataset.theme = theme;
    try {
      localStorage.setItem("mt-theme", theme);
    } catch (e) {}
    sync();
    announce("toggle");
  });
  if (mq && mq.addEventListener) {
    mq.addEventListener("change", () => {
      sync();
      if (!root.dataset.theme) {
        announce("system");
      }
    });
  }
})();
