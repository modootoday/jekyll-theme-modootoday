// The page's colour scheme for module scripts: data-theme on <html> when a scheme is chosen or fixed, else the system setting.
const QUERY = "(prefers-color-scheme: dark)";

const media = () => (typeof matchMedia === "function" ? matchMedia(QUERY) : null);

export function currentTheme() {
  const chosen = document.documentElement.dataset.theme;
  if (chosen) {
    return chosen;
  }
  const mq = media();
  return mq && mq.matches ? "dark" : "light";
}

// Calls back with the new scheme once per real change. Sites without the toggle get no mt:themechange,
// so the system setting is watched too. Returns a function that stops listening.
export function onThemeChange(callback) {
  let last = currentTheme();
  const handler = () => {
    const theme = currentTheme();
    if (theme === last) {
      return;
    }
    last = theme;
    callback(theme);
  };
  const mq = media();
  document.addEventListener("mt:themechange", handler);
  if (mq && mq.addEventListener) {
    mq.addEventListener("change", handler);
  }
  return () => {
    document.removeEventListener("mt:themechange", handler);
    if (mq && mq.removeEventListener) {
      mq.removeEventListener("change", handler);
    }
  };
}
