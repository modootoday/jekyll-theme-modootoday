// Size budgets, assembled from qa/audit/budgets/: per file and kind (files.mjs), the core CSS each page links
// (pages.mjs) and the gzip bytes one page of each type loads (types.mjs).
import { checkFiles } from "./budgets/files.mjs";
import { checkPages } from "./budgets/pages.mjs";
import { checkTypes } from "./budgets/types.mjs";

export function checkBudgets(site, fails) {
  const sizes = checkFiles(site, fails);
  sizes.css.page_max = checkPages(site, fails);
  sizes.types = checkTypes(site, fails);
  return sizes;
}
