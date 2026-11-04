// Search keys: /, Ctrl/Cmd+K, arrows, Esc. Shows the box; the search itself (search.js) is imported on first use.
export function init(root) {
  const doc = root.ownerDocument || root;
  const box = root.querySelector(".mt-search");
  if (!box) {
    return;
  }
  const input = box.querySelector("input");
  const out = box.querySelector("ul");
  let search;
  const start = () => {
    search ||= import("./search.js").then((m) => m.init(root));
    return search;
  };
  box.hidden = false;
  input.addEventListener("focus", start);
  // The results close when Tab moves focus out of the box and come back with it. A click elsewhere has no
  // relatedTarget and leaves them, so a result link that takes no focus on click (Safari) still follows.
  box.addEventListener("focusout", (e) => {
    out.hidden = !!e.relatedTarget && !box.contains(e.relatedTarget);
  });
  box.addEventListener("focusin", () => {
    out.hidden = false;
  });
  box.addEventListener("keydown", (e) => {
    const links = [...out.querySelectorAll("a")];
    const i = links.indexOf(doc.activeElement);
    const k = e.key;
    if (k == "Escape") {
      e.preventDefault();
      if (i > -1) {
        input.focus();
      } else {
        input.value = "";
        box.mtRender?.("");
      }
    } else if ((k == "ArrowDown" || k == "ArrowUp") && links.length) {
      e.preventDefault();
      const n = k == "ArrowDown" ? Math.min(i + 1, links.length - 1) : i - 1;
      (n < 0 ? input : links[n]).focus();
    }
  });
  doc.addEventListener("keydown", (e) => {
    const t = e.target;
    const typing = t.isContentEditable || /^(INPUT|TEXTAREA|SELECT)$/.test(t.tagName);
    const mod = e.ctrlKey || e.metaKey;
    if ((e.key == "/" && !typing && !mod && !e.altKey) || (mod && e.key.toLowerCase() == "k")) {
      e.preventDefault();
      start();
      input.focus();
      input.select();
    }
  });
}

init(document);
