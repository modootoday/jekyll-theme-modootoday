// jekyll-theme-modootoday — copy button for code blocks (progressive enhancement).
(function () {
  if (!navigator.clipboard) return;
  var root = document.documentElement;
  var label = root.dataset.mtCopy || "Copy", done = root.dataset.mtCopied || "Copied";
  // Icons match modootoday/brand/icon.html (copy, check): decorative, the button text is the name.
  function icon(d) { return '<svg class="mt-icon" viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false">' + d + "</svg>"; }
  var copy = icon('<rect x="9" y="9" width="12" height="12" rx="2"/><path d="M15 9V5a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v8a2 2 0 0 0 2 2h4"/>'), check = icon('<path d="m5 12 5 5 9-10"/>');
  function show(b, ic, text) { b.innerHTML = ic; b.append(text); }
  var live = document.createElement("span");
  live.className = "mt-sr-only"; live.setAttribute("aria-live", "polite");
  document.body.append(live);
  document.querySelectorAll(".mt-main pre").forEach(function (pre) {
    var box = pre.closest("div.highlighter-rouge") || pre;
    if (box.querySelector(".mt-code-copy")) return;
    box.classList.add("mt-code");
    var b = document.createElement("button");
    b.type = "button"; b.className = "mt-code-copy"; show(b, copy, label);
    b.addEventListener("click", function () {
      navigator.clipboard.writeText(pre.innerText.replace(/\n$/, "")).then(function () {
        show(b, check, done); live.textContent = done;
        setTimeout(function () { show(b, copy, label); }, 1500);
      });
    });
    box.append(b);
  });
})();
