// What the docs audit covers: widths, colour schemes, pages and size budgets.
import fs from "node:fs";
import path from "node:path";

export const WIDTHS = [360, 768, 1024, 1440];
export const SCHEMES = ["light", "dark"];
export const PAGES = ["", "guides/install/", "guides/first-page/", "components/", "components/kitchen-sink/", "guides/configuration/", "guides/customize/", "guides/agents/", "reference/changelog/", "reference/api/", "tags/", "categories/", "blog/", "news/", "authors/modootoday/", "layouts/demo/minimal/", "layouts/demo/wide/", "layouts/demo/home/", "layouts/demo/error/", "layouts/demo/search/", "layouts/directory/", "layouts/directory/portfolio/", "layouts/directory/team/", "layouts/directory/jobs/", "layouts/directory/events/", "layouts/directory/sponsors/", "layouts/directory/integrations/", "layouts/detail/", "layouts/detail/project/", "layouts/detail/job/", "layouts/detail/event/", "layouts/detail/episode/", "layouts/marketing/", "layouts/marketing/feature/", "layouts/marketing/pricing/", "layouts/marketing/brand/", "layouts/marketing/links/", "layouts/marketing/contact/", "layouts/docs-extra/", "layouts/docs-extra/reference/", "layouts/docs-extra/changelog/", "layouts/docs-extra/roadmap/", "layouts/docs-extra/glossary/", "layouts/docs-extra/hub/", "layouts/docs-extra/course/", "layouts/docs-extra/book/", "layouts/docs-extra/api/", "layouts/documents/", "layouts/documents/legal/", "layouts/documents/resume/", "layouts/blog-news/", "layouts/blog-news/blog/", "layouts/blog-news/post/", "layouts/blog-news/news/", "layouts/blog-news/article/", "layouts/blog-news/archive/", "recipes/docs/", "recipes/brand-tokens/", "layouts/demo/code-github/", "layouts/demo/orbit/", "layouts/demo/filter/", "recipes/math-diagrams/", "recipes/charts/"];
export const RTL_PAGES = ["components/kitchen-sink-rtl/"]; // English tree only: dir="rtl" mirroring checks
export const EN_ONLY = ["guides/2026/10/28/archives/", "layouts/demo/error-rtl/", "recipes/records/", "recipes/records/lantern/"]; // a sample post (post layout + footer term links), URLs differ per language; the records demo is English only
// Page types: the pages whose loaded CSS and JS (gzip) test/system/audit/budgets/types.mjs reports. Each page's limit is the sum of
// the caps of what it loads (asset registry rows, adr:modootoday/20261104053146); GUIDE targets warn, and skip the
// showcase type, whose pages load every component on purpose.
export const PAGE_TYPES = {
  doc: { pages: ["guides/configuration/", "guides/install/", "recipes/csp/", "recipes/math-diagrams/"] },
  landing: { pages: ["", "layouts/demo/home/", "layouts/marketing/"] },
  blog: { pages: ["blog/", "guides/2026/10/28/archives/"] },
  showcase: { pages: ["components/", "components/kitchen-sink/", "layouts/demo/csp/"] },
  // A doc page with a script: visual: its site module and the theme helpers it imports.
  visual: { pages: ["layouts/demo/orbit/"] },
  // Pages with filter: on a list and a table, and the records list (filter_text: true): filter.js and its imports.
  filter: { pages: ["layouts/demo/filter/", "recipes/records/"] },
  // A record page (modootoday-stubs --records, layout: detail).
  record: { pages: ["recipes/records/lantern/"] },
  // A chart page: the site's Chart.js (about 70 KB gzip) counts in its total but not in a theme limit, so no GUIDE target.
  chart: { pages: ["recipes/charts/"] },
};
export const GUIDE = { css: 8 * 1024, js: 6 * 1024, sheets: 6, skip: ["showcase", "chart"] };
// Pages the CSP audit (csp.mjs) opens under a strict Content-Security-Policy header; a feature with a demo page adds it here.
// The kitchen sink stays out: it embeds a third-party frame and aligned table columns (kramdown writes style attributes).
export const CSP_PAGES = ["layouts/demo/csp/", "", "guides/configuration/", "blog/", "layouts/demo/search/", "recipes/brand-tokens/", "layouts/demo/code-github/", "layouts/demo/orbit/", "layouts/demo/filter/", "recipes/records/", "recipes/records/lantern/", "layouts/demo/error/", "recipes/math-diagrams/", "recipes/charts/"];
// Pages whose token palette the contrast check (contrast.mjs) measures in each scheme: the theme default, the brand tokens recipe,
// the GitHub code colours (code_theme: github) and the chart series colours.
export const CONTRAST_PAGES = ["", "recipes/brand-tokens/", "layouts/demo/code-github/", "recipes/charts/"];
export const CSP = "default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:; worker-src 'self'; manifest-src 'self'";
export const JOBS = Math.max(1, +process.env.QA_JOBS || 4); // pages checked concurrently per colour scheme
export const langsOf = (site) => ["", "ko/", "ja/"].filter((l) => fs.existsSync(path.join(site, l, "index.html")));
