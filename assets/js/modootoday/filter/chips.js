// Facet chips: one aria-pressed button per distinct value of a table column, named by its header cell.
// One value at a time; pressing the chosen chip again shows every row.
export const cellText = (row, column) => {
  const cell = row.cells[column - 1];
  return cell ? cell.textContent.trim() : "";
};

export function chips(table, column, rows, onPick) {
  const group = document.createElement("div");
  group.className = "mt-filter-chips";
  group.setAttribute("role", "group");
  const head = table.tHead && table.tHead.rows[0].cells[column - 1];
  if (head) {
    group.setAttribute("aria-label", head.textContent.trim());
  }
  const values = new Set(rows.map((r) => cellText(r, column)).filter(Boolean));
  values.forEach((value) => {
    const button = document.createElement("button");
    button.type = "button";
    button.textContent = value;
    button.setAttribute("aria-pressed", "false");
    button.addEventListener("click", () => {
      const on = button.getAttribute("aria-pressed") != "true";
      group.querySelectorAll("button").forEach((b) => b.setAttribute("aria-pressed", String(b == button && on)));
      onPick(on ? value : null);
    });
    group.append(button);
  });
  return group;
}
