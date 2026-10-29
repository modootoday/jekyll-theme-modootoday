// jekyll-theme-modootoday — copy button for code blocks (progressive enhancement).
(function () {
  if (!navigator.clipboard) return;
  var root = document.documentElement;
  var label = root.dataset.mtCopy || "Copy", done = root.dataset.mtCopied || "Copied";
  var live = document.createElement("span");
  live.className = "mt-sr-only"; live.setAttribute("aria-live", "polite");
  document.body.append(live);
  document.querySelectorAll(".mt-main pre").forEach(function (pre) {
    var box = pre.closest("div.highlighter-rouge") || pre;
    if (box.querySelector(".mt-code-copy")) return;
    box.classList.add("mt-code");
    var b = document.createElement("button");
    b.type = "button"; b.className = "mt-code-copy"; b.textContent = label;
    b.addEventListener("click", function () {
      navigator.clipboard.writeText(pre.innerText.replace(/\n$/, "")).then(function () {
        b.textContent = done; live.textContent = done;
        setTimeout(function () { b.textContent = label; }, 1500);
      });
    });
    box.append(b);
  });
})();
