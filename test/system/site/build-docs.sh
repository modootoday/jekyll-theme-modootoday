#!/usr/bin/env bash
# Build docs/ with the theme from a checkout (instead of remote_theme@main) into $1 (default ROOT/docs/_site).
# ROOT ($2) defaults to this checkout; the visual workflow passes an older checkout to build it with this script.
set -euo pipefail
root="$(cd "${2:-$(dirname "$0")/../../..}" && pwd)"
out="$(realpath -m "${1:-$root/docs/_site}")"
cd "$root"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
sed -e 's/^remote_theme:.*/theme: jekyll-theme-modootoday/' -e 's/^plugins: \[jekyll-remote-theme, */plugins: [/' docs/_config.yml > "$tmp/_config.yml"
bundle exec jekyll build -q -s docs -d "$out" --config "$tmp/_config.yml"
