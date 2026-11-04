// Copy buttons: code blocks, page actions.
// Decorative icons from brand/icon.html; the aria-label names the button, the live region says it worked.
const icon = (d) => '<svg class="mt-icon" viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false">' + d + "</svg>";
const COPY = icon('<rect x="9" y="9" width="12" height="12" rx="2"/><path d="M15 9V5a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v8a2 2 0 0 0 2 2h4"/>');
const CHECK = icon('<path d="m5 12 5 5 9-10"/>');

export function init(root) {
  const doc = root.ownerDocument || root;
  const win = doc.defaultView;
  const clipboard = win.navigator.clipboard;
  if (!clipboard) {
    return;
  }
  const ds = doc.documentElement.dataset;
  const label = ds.mtCopy || "Copy";
  const done = ds.mtCopied || "Copied";
  const live = Object.assign(doc.createElement("span"), { className: "mt-sr-only", ariaLive: "polite" });
  live.setAttribute("role", "status");
  doc.body.append(live);
  const reset = (b) => {
    b.innerHTML = COPY;
    live.textContent = "";
  };
  root.querySelectorAll(".mt-main pre").forEach((pre) => {
    // A bare pre gets a box of its own, so the button does not scroll away with the code.
    let box = pre.closest("div.highlighter-rouge, div.mt-code-box");
    if (!box) {
      box = Object.assign(doc.createElement("div"), { className: "mt-code-box" });
      pre.before(box);
      box.append(pre);
    }
    if (box.querySelector(".mt-code-copy")) {
      return;
    }
    box.classList.add("mt-code");
    const b = Object.assign(doc.createElement("button"), { type: "button", className: "mt-code-copy", title: label, innerHTML: COPY });
    b.setAttribute("aria-label", label);
    b.onclick = () => clipboard.writeText(pre.innerText.replace(/\n$/, "")).then(() => {
      b.innerHTML = CHECK;
      live.textContent = done;
      win.setTimeout(() => reset(b), 1500);
    });
    box.append(b);
  });
  root.querySelectorAll("[data-mt-act]").forEach((b) => {
    const d = b.closest("details").dataset;
    b.parentNode.hidden = false;
    const head = b.dataset.mtAct > "b" ? "" : d.mtSource + ": " + d.mtUrl + "\n\n";
    b.onclick = () => win.fetch(d.mtTwin)
      .then((r) => r.text())
      .then((m) => clipboard.writeText(head + m))
      .then(() => {
        b.textContent = done;
        live.textContent = done;
      });
  });
}

init(document);
