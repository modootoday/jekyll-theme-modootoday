# Security policy

## Supported versions

| Version | Supported |
|---|---|
| latest 1.x minor | yes |
| older | no |

After 1.0, the latest minor of the current major receives fixes.

## Reporting a vulnerability

Please do not open a public issue. Report privately through GitHub: [Report a vulnerability](https://github.com/modootoday/jekyll-theme-modootoday/security/advisories/new) (Security tab → "Report a vulnerability").

Include the affected version, the configuration or Markdown that triggers the problem, and the impact. We aim to acknowledge reports within 7 days and to publish a fix and a GitHub security advisory once a fix is released.

## Scope

- Layouts, includes, Sass, JavaScript under `assets/`, the `jekyll-theme-modootoday` plugin and `modootoday-check`.
- The release pipeline (RubyGems trusted publishing from tags).

Sites built with the theme are out of scope unless the problem comes from the theme itself. For hardening a site's Content Security Policy, see the [CSP guide](https://modootoday.github.io/jekyll-theme-modootoday/recipes/csp/).
