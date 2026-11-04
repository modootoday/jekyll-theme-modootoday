// Stack and dl tables (mt-table--stack, mt-table--dl): explicit roles and column labels, then data-mt-labelled, which
// lets table-stack.css show the table as blocks; display: block drops a table's implicit roles.
(() => {
  const roles = { THEAD: "rowgroup", TBODY: "rowgroup", TFOOT: "rowgroup", TR: "row", TH: "columnheader", TD: "cell" };
  const label = (t) => {
    const heads = t.tHead ? [...t.tHead.rows[0].cells].map((c) => c.textContent.trim()) : [];
    t.setAttribute("role", "table");
    t.querySelectorAll("thead, tbody, tfoot, tr, th, td").forEach((e) => {
      const head = e.tagName == "TH" && e.parentElement.parentElement.tagName != "THEAD";
      e.setAttribute("role", head ? "rowheader" : roles[e.tagName]);
    });
    t.querySelectorAll("tbody td").forEach((c) => {
      if (heads[c.cellIndex]) {
        c.dataset.label = heads[c.cellIndex];
      }
    });
    t.dataset.mtLabelled = "";
  };
  document.querySelectorAll(".mt-main table:is(.mt-table--stack, .mt-table--dl)").forEach(label);
})();
