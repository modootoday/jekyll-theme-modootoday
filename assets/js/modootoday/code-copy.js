// jekyll-theme-modootoday — copy buttons: code, page actions.
(() => {
  if (!navigator.clipboard) return;
  const ds = document.documentElement.dataset, label = ds.mtCopy || "Copy", done = ds.mtCopied || "Copied";
  // Icons match modootoday/brand/icon.html (copy, check): decorative, the button text is the name.
  const icon = (d) => '<svg class="mt-icon" viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false">' + d + "</svg>";
  const copy = icon('<rect x="9" y="9" width="12" height="12" rx="2"/><path d="M15 9V5a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v8a2 2 0 0 0 2 2h4"/>'), check = icon('<path d="m5 12 5 5 9-10"/>');
  const show = (b, ic, text) => { b.innerHTML = ic; b.append(text); };
  const live = Object.assign(document.createElement("span"), { className: "mt-sr-only", ariaLive: "polite" });
  document.body.append(live);
  document.querySelectorAll(".mt-main pre").forEach((pre) => {
    const box = pre.closest("div.highlighter-rouge") || pre;
    if (box.querySelector(".mt-code-copy")) return;
    box.classList.add("mt-code");
    const b = Object.assign(document.createElement("button"), { type: "button", className: "mt-code-copy" });
    show(b, copy, label);
    b.onclick = () => navigator.clipboard.writeText(pre.innerText.replace(/\n$/, "")).then(() => {
      show(b, check, done); live.textContent = done;
      setTimeout(() => show(b, copy, label), 1500);
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
