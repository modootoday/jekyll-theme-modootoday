// Text matching shared by the list filter: NFC and lower case, every word of the query (AND).
// Korean spacing varies ("A B" vs "AB"), so compact mode also compares with whitespace removed.
export function normalize(text) {
  return text.normalize("NFC").toLowerCase();
}

export function terms(query) {
  return normalize(query).split(/\s+/).filter(Boolean);
}

export function matches(haystack, words, compact) {
  const hay = normalize(haystack);
  if (words.every((w) => hay.includes(w))) {
    return true;
  }
  if (!compact) {
    return false;
  }
  const flat = hay.replace(/\s+/g, "");
  return words.every((w) => flat.includes(w));
}
