// Table to chart data, by the rule modootoday-check applies: labels in the first column, series in the header row,
// numbers once "," and "%" are removed; any other cell is a gap.
const text = (cell) => (cell ? cell.textContent.replace(/[,%\s]/g, "") : "");

export function tableData(table) {
  const [head, ...rows] = table.rows;
  const series = [...(head ? head.cells : [])].slice(1).map((c) => ({ name: c.textContent.trim(), values: [] }));
  const labels = rows.map((row) => row.cells[0].textContent.trim());
  for (const row of rows) {
    series.forEach((s, i) => {
      const t = text(row.cells[i + 1]);
      s.values.push(t === "" || !Number.isFinite(+t) ? null : +t);
    });
  }
  return { labels, series };
}
