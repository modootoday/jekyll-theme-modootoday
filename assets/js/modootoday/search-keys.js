// Search keys: /, Ctrl/Cmd+K, arrows, Esc.
(() => {
  const box = document.querySelector(".mt-search"); if (!box) return;
  const input = box.querySelector("input"), out = box.querySelector("ul");
  box.addEventListener("keydown", (e) => {
    const links = [...out.querySelectorAll("a")], i = links.indexOf(document.activeElement), k = e.key;
    if (k == "Escape") { e.preventDefault(); if (i > -1) input.focus(); else box.mtRender(input.value = ""); }
    else if ((k == "ArrowDown" || k == "ArrowUp") && links.length) {
      e.preventDefault();
      const n = k == "ArrowDown" ? Math.min(i + 1, links.length - 1) : i - 1;
      (n < 0 ? input : links[n]).focus();
    }
  });
  document.addEventListener("keydown", (e) => {
    const t = e.target, typing = t.isContentEditable || /^(INPUT|TEXTAREA|SELECT)$/.test(t.tagName), mod = e.ctrlKey || e.metaKey;
    if ((e.key == "/" && !typing && !mod && !e.altKey) || (mod && e.key.toLowerCase() == "k")) { e.preventDefault(); input.focus(); input.select(); }
  });
})();
