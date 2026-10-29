#!/usr/bin/env bash
# Build docs/ with the theme from this checkout (instead of remote_theme@main) into $1 (default docs/_site).
set -euo pipefail
cd "$(dirname "$0")/../.."
out="${1:-docs/_site}"
tmp="$(mktemp -d)"
sed -e 's/^remote_theme:.*/theme: jekyll-theme-modootoday/' -e 's/^plugins: \[jekyll-remote-theme, */plugins: [/' docs/_config.yml > "$tmp/_config.yml"
bundle exec jekyll build -q -s docs -d "$out" --config "$tmp/_config.yml"
