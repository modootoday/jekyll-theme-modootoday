// Size budgets, assembled from qa/audit/budgets/: each theme file against the cap on its registry row (modules.mjs)
// and, per page type, what one page loads against the sum of those caps (types.mjs).
import { readRegistry } from "./budgets/registry.mjs";
import { checkModules } from "./budgets/modules.mjs";
import { checkTypes } from "./budgets/types.mjs";

export function checkBudgets(site, fails, warns) {
  const modules = checkModules(site, readRegistry(), fails, warns);
  return { modules, types: checkTypes(site, modules, fails, warns) };
}
