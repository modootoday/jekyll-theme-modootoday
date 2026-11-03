// Copy buttons: code, page actions.
(() => {
  if (!navigator.clipboard) return;
  const ds = document.documentElement.dataset, label = ds.mtCopy || "Copy", done = ds.mtCopied || "Copied";
  // Decorative icons from brand/icon.html; the aria-label names the button, the live region says it worked.
  const icon = (d) => '<svg class="mt-icon" viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false">' + d + "</svg>";
  const copy = icon('<rect x="9" y="9" width="12" height="12" rx="2"/><path d="M15 9V5a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v8a2 2 0 0 0 2 2h4"/>'), check = icon('<path d="m5 12 5 5 9-10"/>');
  const live = Object.assign(document.createElement("span"), { className: "mt-sr-only", ariaLive: "polite" });
  live.setAttribute("role", "status");
  document.body.append(live);
  const reset = (b) => {
    b.innerHTML = copy;
    live.textContent = "";
  };
  document.querySelectorAll(".mt-main pre").forEach((pre) => {
    const box = pre.closest("div.highlighter-rouge") || pre;
    if (box.querySelector(".mt-code-copy")) return;
    box.classList.add("mt-code");
    const b = Object.assign(document.createElement("button"), { type: "button", className: "mt-code-copy", title: label, innerHTML: copy });
    b.setAttribute("aria-label", label);
    b.onclick = () => navigator.clipboard.writeText(pre.innerText.replace(/\n$/, "")).then(() => {
      b.innerHTML = check;
      live.textContent = done;
      setTimeout(() => reset(b), 1500);
    });
    box.append(b);
  });
  document.querySelectorAll("[data-mt-act]").forEach((b) => {
    const d = b.closest("details").dataset; b.parentNode.hidden = 0;
    b.onclick = () => fetch(d.mtTwin).then((r) => r.text())
      .then((m) => navigator.clipboard.writeText((b.dataset.mtAct > "b" ? "" : d.mtSource + ": " + d.mtUrl + "\n\n") + m))
      .then(() => { b.textContent = live.textContent = done; });
  });
})();
