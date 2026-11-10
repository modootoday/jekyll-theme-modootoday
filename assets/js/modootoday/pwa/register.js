// Registers the site's service worker after load (modootoday.pwa; the manifest link names it). A first visit is not
// controlled while it loads, so the URLs it fetched are posted to the worker once it is active.
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
  const start = () => {
    sw.register(link.dataset.mtSw, { scope }).then(() => (first ? sw.ready : null)).then((reg) => {
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
