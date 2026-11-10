// The offline page's list of pages this site's worker keeps (layout pages/offline). Titles are read from the cached
// copies with DOMParser and inserted as text, never as markup.
export async function init(root) {
  const doc = root.ownerDocument || root;
  const win = doc.defaultView;
  const box = root.querySelector("[data-mt-offline]");
  const link = doc.querySelector("link[rel=manifest][data-mt-scope]");
  if (!box || !link || !win.caches) {
    return;
  }
  const list = box.querySelector("ul");
  const pages = "mt:" + link.dataset.mtScope + ":pages:";
  const seen = new Set();
  for (const name of await win.caches.keys()) {
    const cache = name.startsWith(pages) ? await win.caches.open(name) : null;
    for (const req of cache ? await cache.keys() : []) {
      const url = new win.URL(req.url);
      if (!/\/$|\.html$/.test(url.pathname) || url.pathname.endsWith("/offline/") || seen.has(url.href)) {
        continue;
      }
      seen.add(url.href);
      const html = await (await cache.match(req)).text();
      const title = new win.DOMParser().parseFromString(html, "text/html").title || url.pathname;
      const a = doc.createElement("a");
      a.href = url.href;
      a.textContent = title;
      list.appendChild(doc.createElement("li")).appendChild(a);
    }
  }
  box.hidden = !list.children.length;
}

init(document);
