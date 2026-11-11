// c: install sections. The Install button shows only while the browser offers installing (beforeinstallprompt; an offer
// that came before this module ran is kept on the manifest link by pwa/register.js) and prompts only on a click. Inside
// the installed app the sections hide. Nothing is stored and the user agent is never read.
const APP = "(display-mode: standalone), (display-mode: minimal-ui)";

export function init(root) {
  const doc = root.ownerDocument || root;
  const win = doc.defaultView;
  const buttons = [...root.querySelectorAll("button.mt-install")];
  if (!buttons.length) {
    return;
  }
  if (win.navigator.standalone === true || win.matchMedia?.(APP).matches) {
    for (const b of buttons) {
      b.closest(".mt-c-install")?.setAttribute("hidden", "");
    }
    return;
  }
  let offer = null;
  const show = (e) => {
    offer = e;
    for (const b of buttons) {
      b.hidden = !e;
    }
  };
  win.addEventListener("beforeinstallprompt", (e) => {
    e.preventDefault();
    show(e);
  });
  win.addEventListener("appinstalled", () => show(null));
  for (const b of buttons) {
    b.addEventListener("click", async () => {
      const e = offer;
      if (!e) {
        return;
      }
      offer = null;
      try {
        await e.prompt();
        await e.userChoice;
      } catch {
        // A prompt the browser refuses (already shown) leaves the page as it is.
      }
      const focused = doc.activeElement == b;
      show(null);
      // The button is gone; its hint keeps the reader's place.
      const hint = b.parentElement.querySelector(".mt-install-hint");
      if (focused && hint) {
        hint.tabIndex = -1;
        hint.focus();
      }
    });
  }
  const early = doc.querySelector("link[rel=manifest]")?.mtInstall;
  if (early) {
    show(early);
  }
}

init(document);
