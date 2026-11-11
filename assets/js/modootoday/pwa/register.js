// Registers the site's service worker after load (modootoday.pwa). A first, uncontrolled visit posts the URLs it fetched to
// the worker; a waiting worker and a lost network get a notice (pwa/update-toast.js); a window shown after an hour checks
// for a new sw.js. An early install offer is kept for pwa/install.js.
const HOUR = 36e5;

export function init(root) {
  const doc = root.ownerDocument || root;
  const win = doc.defaultView;
  const sw = win.navigator.serviceWorker;
  const link = doc.querySelector("link[rel=manifest][data-mt-sw]");
  if (!link || !sw) {
    return;
  }
  // The browser can offer installing before pwa/install.js runs; keep the offer for it, only where a button waits.
  if (doc.querySelector("button.mt-install")) {
    win.addEventListener("beforeinstallprompt", (e) => {
      e.preventDefault();
      link.mtInstall = e;
    });
  }
  const scope = new win.URL(link.dataset.mtScope, win.location.href).href;
  const first = !sw.controller;
  const toast = () => import("./update-toast.js");
  // The offline page says so itself.
  const offline = () => {
    if (!doc.querySelector("[data-mt-offline]")) {
      toast().then((m) => m.offline(doc)).catch(() => {});
    }
  };
  win.addEventListener("offline", offline);
  if (win.navigator.onLine === false) {
    offline();
  }
  const watch = (reg) => {
    // Only new theme files (a second assets cache) make a worker wait. Loading the notice through the leaving worker
    // while another takes over by itself keeps it busy, and Chromium then never activates the new one.
    const notify = async () => {
      const names = reg.waiting && sw.controller ? await win.caches.keys().catch(() => []) : [];
      if (names.filter((n) => n.startsWith("mt:" + link.dataset.mtScope + ":assets:")).length > 1) {
        toast().then((m) => m.update(doc, reg)).catch(() => {});
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
