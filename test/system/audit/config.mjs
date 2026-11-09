// What the docs audit covers: widths, colour schemes, pages and size budgets.
import fs from "node:fs";
import path from "node:path";

export const WIDTHS = [360, 768, 1024, 1440];
export const SCHEMES = ["light", "dark"];
export const PAGES = ["", "guides/install/", "guides/first-page/", "components/", "components/kitchen-sink/", "guides/configuration/", "guides/customize/", "guides/agents/", "reference/changelog/", "reference/api/", "tags/", "categories/", "blog/", "news/", "authors/modootoday/", "layouts/demo/minimal/", "layouts/demo/wide/", "layouts/demo/error/", "layouts/demo/search/", "layouts/directory/", "layouts/directory/portfolio/", "layouts/directory/team/", "layouts/directory/jobs/", "layouts/directory/events/", "layouts/directory/sponsors/", "layouts/directory/integrations/", "layouts/detail/", "layouts/detail/project/", "layouts/detail/job/", "layouts/detail/event/", "layouts/detail/episode/", "layouts/marketing/", "layouts/marketing/feature/", "layouts/marketing/pricing/", "layouts/marketing/brand/", "layouts/marketing/links/", "layouts/marketing/contact/", "layouts/docs-extra/", "layouts/docs-extra/reference/", "layouts/docs-extra/changelog/", "layouts/docs-extra/roadmap/", "layouts/docs-extra/glossary/", "layouts/docs-extra/hub/", "layouts/docs-extra/course/", "layouts/docs-extra/book/", "layouts/docs-extra/api/", "layouts/documents/", "layouts/documents/legal/", "layouts/documents/resume/", "layouts/blog-news/", "layouts/blog-news/blog/", "layouts/blog-news/post/", "layouts/blog-news/news/", "layouts/blog-news/article/", "layouts/blog-news/archive/", "recipes/docs/", "recipes/brand-tokens/", "layouts/demo/code-github/", "layouts/demo/orbit/", "layouts/demo/filter/", "recipes/figures/math-diagrams/", "recipes/figures/charts/", "recipes/figures/widgets/"];
export const RTL_PAGES = ["components/kitchen-sink-rtl/"]; // English tree only: dir="rtl" mirroring checks
export const EN_ONLY = ["guides/2026/10/28/archives/", "layouts/demo/error-rtl/"]; // a sample post (post layout + footer term links), URLs differ per language
// Page types: the pages whose loaded CSS and JS (gzip) test/system/audit/budgets/types.mjs reports. Each page's limit is the sum of
// the caps of what it loads (asset registry rows, adr:modootoday/20261104053146); GUIDE targets warn, and skip the
// components type, whose pages load every component on purpose.
export const PAGE_TYPES = {
  doc: { pages: ["guides/configuration/", "guides/install/", "recipes/csp/", "recipes/figures/math-diagrams/"] },
  landing: { pages: ["", "layouts/marketing/"] },
  blog: { pages: ["blog/", "guides/2026/10/28/archives/"] },
  components: { pages: ["components/", "components/kitchen-sink/", "layouts/demo/csp/"] },
  // A doc page with a script: visual: its site module and the theme helpers it imports.
  visual: { pages: ["layouts/demo/orbit/"] },
  // Pages with filter: on a list and a table: filter.js and its imports. The records list and a record page are typed in the docs starter's build (STARTERS).
  filter: { pages: ["layouts/demo/filter/"] },
  // A chart page: the site's Chart.js (about 70 KB gzip) counts in its total but not in a theme limit, so no GUIDE target.
  chart: { pages: ["recipes/figures/charts/"] },
};
export const GUIDE = { css: 8 * 1024, js: 6 * 1024, sheets: 6, skip: ["components", "chart"] };
// Pages the CSP audit (csp.mjs) opens under a strict Content-Security-Policy header; a feature with a demo page adds it here.
// The kitchen sink stays out: it embeds a third-party frame and aligned table columns (kramdown writes style attributes).
export const CSP_PAGES = ["layouts/demo/csp/", "", "guides/configuration/", "blog/", "layouts/demo/search/", "recipes/brand-tokens/", "layouts/demo/code-github/", "layouts/demo/orbit/", "layouts/demo/filter/", "layouts/demo/error/", "recipes/figures/math-diagrams/", "recipes/figures/charts/", "recipes/figures/widgets/"];
// Pages whose token palette the contrast check (contrast.mjs) measures in each scheme: the theme default, the brand tokens recipe,
// the GitHub code colours (code_theme: github) and the chart series colours.
export const CONTRAST_PAGES = ["", "recipes/brand-tokens/", "layouts/demo/code-github/", "recipes/figures/charts/"];
export const CSP = "default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:; worker-src 'self'; manifest-src 'self'";
// The checks that moved with their rows into the starter demo builds (adr:modootoday/20261104171141). Every page named
// here is one of that starter's qa: pages in example/starters.yml (test/project/docs_moves_test.rb), which the starter
// audit (test/system/starters.mjs) opens: csp under the strict header, page types for the budgets, header and anchor offsets,
// the measure of the text column and inline code wrapping.
export const STARTERS = {
  docs: { csp: true, types: { filter: ["plugins/"], record: ["plugins/lantern/"] } },
  blog: { header: [""], code: ["notes/2026/10/20/hello-blog/"], types: { blog: [""] } },
  landing: { header: ["pricing/"], anchor: ["privacy/"], measure: ["privacy/"], types: { landing: [""] } },
};
export const JOBS = Math.max(1, +process.env.QA_JOBS || 4); // pages checked concurrently per colour scheme
export const langsOf = (site) => ["", "ko/", "ja/"].filter((l) => fs.existsSync(path.join(site, l, "index.html")));
