// Settings of a component root from its data-* attributes; module scripts have no currentScript to read them from.
// The defaults name the keys (camelCase, data-speed-up -> speedUp) and give each value's type.
export function readConfig(el, defaults) {
  const out = { ...defaults };
  for (const key of Object.keys(defaults)) {
    const raw = el.dataset[key];
    if (raw === undefined) {
      continue;
    }
    out[key] = parseValue(raw, defaults[key]);
  }
  return out;
}

// A boolean is on when the attribute is present; numbers and JSON fall back to the default when they do not parse.
export function parseValue(raw, fallback) {
  if (typeof fallback === "boolean") {
    return true;
  }
  if (typeof fallback === "number") {
    const n = Number(raw);
    return raw.trim() !== "" && Number.isFinite(n) ? n : fallback;
  }
  if (fallback !== null && typeof fallback === "object") {
    try {
      return JSON.parse(raw);
    } catch (e) {
      return fallback;
    }
  }
  return raw;
}
