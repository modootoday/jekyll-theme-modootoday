// Stack and dl tables (mt-table--stack, mt-table--dl): explicit roles and column labels, then data-mt-labelled, which
// lets table-stack.css show the table as blocks; display: block drops a table's implicit roles.
// Below 40rem a plain table that does not fit (it scrolls, or a 4+ column cell is over 6 lines) stacks the same way.
const ROLES = { THEAD: "rowgroup", TBODY: "rowgroup", TFOOT: "rowgroup", TR: "row", TH: "columnheader", TD: "cell" };
const PHONE = "(max-width: 39.99rem)";
const MAX_LINES = 6;

const label = (t) => {
  const heads = t.tHead ? [...t.tHead.rows[0].cells].map((c) => c.textContent.trim()) : [];
  t.setAttribute("role", "table");
  t.querySelectorAll("thead, tbody, tfoot, tr, th, td").forEach((e) => {
    const head = e.tagName == "TH" && e.parentElement.parentElement.tagName != "THEAD";
    e.setAttribute("role", head ? "rowheader" : ROLES[e.tagName]);
  });
  t.querySelectorAll("tbody td").forEach((c) => {
    if (heads[c.cellIndex]) {
      c.dataset.label = heads[c.cellIndex];
    }
  });
  t.dataset.mtLabelled = "";
};

// Counted as the docs QA counts them, so a table the audit would fail stacks instead.
const lines = (win, c) => Math.round(c.getBoundingClientRect().height / (parseFloat(win.getComputedStyle(c).lineHeight) || 20));

const crowded = (win, t) => {
  const box = t.parentElement;
  if (t.tHead.querySelector("th:nth-child(4)")) {
    return [...t.querySelectorAll("tbody td")].some((c) => lines(win, c) > MAX_LINES);
  }
  return box.scrollWidth > box.clientWidth + 1;
};

const stackCrowded = (win, root) => {
  root.querySelectorAll(".mt-main .mt-table > table:not([data-mt-labelled], [class*='mt-table--'])").forEach((t) => {
    if (t.tHead && crowded(win, t)) {
      t.classList.add("mt-table--stack");
      label(t);
    }
  });
};

export function init(root) {
  root.querySelectorAll(".mt-main table:is(.mt-table--stack, .mt-table--dl)").forEach(label);
  const win = (root.ownerDocument || root).defaultView;
  const phone = win && win.matchMedia ? win.matchMedia(PHONE) : null;
  if (!phone) {
    return;
  }
  if (phone.matches) {
    stackCrowded(win, root);
  }
  phone.addEventListener("change", (e) => {
    if (e.matches) {
      stackCrowded(win, root);
    }
  });
}

init(document);
