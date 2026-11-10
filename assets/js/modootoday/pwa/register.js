// Registers the site's service worker after load (modootoday.pwa). A first, uncontrolled visit posts the URLs it fetched to
// the worker; a waiting worker gets the notice (pwa/update-toast.js); a window shown after an hour checks for a new sw.js.
const HOUR = 36e5;

export function init(root) {
  const doc = root.ownerDocument || root;
  const win = doc.defaultView;
  const sw = win.navigator.serviceWorker;
  const link = doc.querySelector("link[rel=manifest][data-mt-sw]");
  if (!link || !sw) {
    return;
  }
  const scope = new win.URL(link.dataset.mtScope, win.location.href).href;
  const first = !sw.controller;
  const watch = (reg) => {
    const notify = () => {
      if (reg.waiting && sw.controller) {
        import("./update-toast.js").then((m) => m.update(doc, reg)).catch(() => {});
      }
    };
    reg.addEventListener("updatefound", () => {
      const next = reg.installing;
      next?.addEventListener("statechange", () => {
        if (next.state == "installed") {
          notify();
        }
      });
    });
    notify();
    let checked = Date.now();
    doc.addEventListener("visibilitychange", () => {
      if (doc.visibilityState == "visible" && Date.now() - checked > HOUR) {
        checked = Date.now();
        reg.update().catch(() => {});
      }
    });
  };
  const start = () => {
    sw.register(link.dataset.mtSw, { scope }).then((reg) => {
      watch(reg);
      return first ? sw.ready : null;
    }).then((reg) => {
      const page = win.location.href.split("#")[0];
      const urls = win.performance.getEntriesByType("resource").map((e) => e.name).concat(page);
      if (reg && reg.active) {
        reg.active.postMessage({ type: "mt:warm", urls: urls.filter((u) => u.startsWith(scope)) });
      }
    }).catch(() => {});
  };
  if (doc.readyState == "complete") {
    start();
  } else {
    win.addEventListener("load", start, { once: true });
  }
}

init(document);
