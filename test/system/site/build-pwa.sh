#!/usr/bin/env bash
# Build the PWA fixture (test/fixtures/sites/pwa) six times into $1 (default ROOT/pkg/pwa) for audit/features/pwa/:
# v1, v2 (another time:, so sw.js changes), next (another theme version, so the theme files change) and kill at /a,
# then v1 at /b and at the origin root (a user site beside it).
set -euo pipefail
root="$(cd "$(dirname "$0")/../../.." && pwd)"
out="$(realpath -m "${1:-$root/pkg/pwa}")"
src="$root/test/fixtures/sites/pwa"
cd "$root"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
printf '' > "$tmp/v1.yml"
printf 'time: "2026-01-02T00:00:00+00:00"\n' > "$tmp/v2.yml"
cp "$tmp/v2.yml" "$tmp/next.yml"
printf 'modootoday:\n  pwa: {enabled: kill}\n' > "$tmp/kill.yml"
printf 'baseurl: /b\n' > "$tmp/b.yml"
printf 'baseurl: ""\n' > "$tmp/root.yml"
# next: a copy of the fixture whose own version include shadows the theme's, as a theme update would change it.
cp -R "$src" "$tmp/next-src"
mkdir -p "$tmp/next-src/_includes/modootoday"
printf '{%%- assign mt_version = "99.0.0" -%%}\n' > "$tmp/next-src/_includes/modootoday/version.html"
rm -rf "$out"
for name in v1 v2 next kill b root; do
  dir="$src"; [ "$name" = next ] && dir="$tmp/next-src"
  # A build revision would outrank time: in the worker's build version and make v1 and v2 the same.
  JEKYLL_BUILD_REVISION= bundle exec jekyll build -q -s "$dir" -d "$out/$name" --config "$dir/_config.yml,$tmp/$name.yml"
done
if cmp -s "$out/v1/sw.js" "$out/v2/sw.js"; then
  echo "build-pwa: v1 and v2 render the same sw.js, so the browser would find no update" >&2
  exit 1
fi
if ! grep -q '"assets": "99.0.0"' "$out/next/sw.js"; then
  echo "build-pwa: next does not carry the other theme version, so no update notice would show" >&2
  exit 1
fi
