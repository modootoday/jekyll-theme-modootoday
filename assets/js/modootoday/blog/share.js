// jekyll-theme-modootoday — post share button: native share sheet where available, else copy the link.
export function init(root) {
  const doc = root.ownerDocument || root;
  const win = doc.defaultView;
  const nav = win.navigator;
  root.querySelectorAll("[data-mt-share]").forEach((b) => {
    const url = b.dataset.url || win.location.href;
    const status = b.parentNode.querySelector("[role=status]");
    if (!nav.share && !nav.clipboard) {
      return;
    }
    b.hidden = false;
    b.addEventListener("click", () => {
      if (nav.share) {
        nav.share({ title: b.dataset.title, url }).catch(() => {});
        return;
      }
      nav.clipboard.writeText(url).then(() => {
        if (status) {
          status.textContent = b.dataset.copied;
        }
        b.dataset.state = "copied";
        win.setTimeout(() => {
          b.dataset.state = "";
          if (status) {
            status.textContent = "";
          }
        }, 2000);
      });
    });
  });
}

init(document);
