// Optional math bundle (site.modootoday.math): KaTeX, loaded before it, renders ```math fences, $$ blocks
// (kramdown prints \[ … \] and \( … \)) and, with inline: true, $…$. The TeX source stays when KaTeX cannot parse it.
(() => {
  const k = window.katex, me = document.currentScript, main = document.querySelector(".mt-main");
  if (!k || !me || !main) return;
  main.querySelectorAll("code.language-math").forEach((code) => {
    const box = code.closest("div.highlighter-rouge") || code.closest("pre") || code, out = document.createElement("div");
    try { k.render(code.textContent, out, { displayMode: true, throwOnError: true }); } catch (e) { return; }
    out.className = "mt-math";
    out.style.overflowX = "auto";
    out.style.overflowY = "hidden";
    box.before(out);
    box.hidden = true;
  });
  if (!window.renderMathInElement) return;
  const d = [{ left: "\\[", right: "\\]", display: true }, { left: "\\(", right: "\\)", display: false }];
  if (me.dataset.mtInline == "true") d.push({ left: "$", right: "$", display: false });
  window.renderMathInElement(main, { delimiters: d, throwOnError: false, ignoredClasses: ["mt-math"] });
})();
