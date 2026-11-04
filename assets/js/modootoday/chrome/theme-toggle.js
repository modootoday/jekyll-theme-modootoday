// Light/dark toggle (stored in localStorage "mt-theme"). Each change is announced on document as mt:themechange,
// detail {theme, source}: "toggle" for a click, "system" for an OS change while no scheme is chosen.
export function init(root) {
  const doc = root.ownerDocument || root;
  const win = doc.defaultView;
  const html = doc.documentElement;
  const button = root.querySelector(".mt-theme-toggle");
  if (!button) {
    return;
  }
  const mq = win.matchMedia ? win.matchMedia("(prefers-color-scheme: dark)") : null;
  const current = () => html.dataset.theme || (mq && mq.matches ? "dark" : "light");
  const sync = () => button.setAttribute("aria-pressed", current() == "dark");
  const announce = (source) => doc.dispatchEvent(new win.CustomEvent("mt:themechange", { detail: { theme: current(), source } }));
  button.hidden = false;
  sync();
  button.addEventListener("click", () => {
    const theme = current() === "dark" ? "light" : "dark";
    html.dataset.theme = theme;
    try {
      win.localStorage.setItem("mt-theme", theme);
    } catch (e) {}
    sync();
    announce("toggle");
  });
  if (mq && mq.addEventListener) {
    mq.addEventListener("change", () => {
      sync();
      if (!html.dataset.theme) {
        announce("system");
      }
    });
  }
}

init(document);
