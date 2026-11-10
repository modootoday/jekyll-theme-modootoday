// The PWA notice (pwa/register.js): one status line, shown once its sheet loads; it never takes focus or reloads by itself.
const LINK = "link[rel=manifest][data-mt-toast-css]";

export function close(doc) {
  doc.querySelector(".mt-toast")?.replaceChildren();
}

// The region goes in empty, so screen readers announce the text that follows.
function region(doc) {
  let box = doc.querySelector(".mt-toast");
  if (!box) {
    box = doc.createElement("div");
    box.className = "mt-toast";
    box.setAttribute("role", "status");
    doc.body.append(box);
    box.mtSheet = new Promise((done) => {
      const css = doc.createElement("link");
      css.rel = "stylesheet";
      css.href = doc.querySelector(LINK).dataset.mtToastCss;
      css.addEventListener("load", done);
      css.addEventListener("error", done);
      doc.head.append(css);
    });
    doc.addEventListener("keydown", (e) => {
      if (e.key == "Escape" && !e.defaultPrevented) {
        close(doc);
      }
    });
  }
  return box;
}

export async function show(doc, text, buttons) {
  const box = region(doc);
  await box.mtSheet;
  const p = doc.createElement("p");
  p.textContent = text;
  const row = doc.createElement("div");
  row.className = "mt-toast-actions";
  for (const [label, fn] of buttons) {
    const b = row.appendChild(doc.createElement("button"));
    b.type = "button";
    b.textContent = label;
    b.addEventListener("click", fn);
  }
  box.replaceChildren(p, row);
}

// pwa/register.js loads this only when the waiting worker brings new theme files (a second assets cache).
export async function update(doc, reg) {
  const win = doc.defaultView;
  const d = doc.querySelector(LINK).dataset;
  if (!reg.waiting) {
    return;
  }
  const reload = () => {
    win.navigator.serviceWorker.addEventListener("controllerchange", () => win.location.reload(), { once: true });
    if (reg.waiting) {
      reg.waiting.postMessage({ type: "mt:skip" });
    } else {
      win.location.reload();
    }
  };
  await show(doc, d.mtUpdate, [[d.mtReload, reload], [d.mtLater, () => close(doc)]]);
}

// A lost network, as the browser reports it (pwa/register.js). A waiting update keeps its notice.
export async function offline(doc) {
  const d = doc.querySelector(LINK).dataset;
  if (doc.querySelector(".mt-toast button")) {
    return;
  }
  doc.defaultView.addEventListener("online", () => close(doc), { once: true });
  await show(doc, d.mtOfflineNotice, [[d.mtClose, () => close(doc)]]);
}
