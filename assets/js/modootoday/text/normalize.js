// Text matching shared by the header search and the list filter: NFC and lower case, every word of the query (AND).
// Korean spacing varies ("A B" vs "AB"), so compact mode also compares with whitespace removed.
export function normalize(text) {
  return text.normalize("NFC").toLowerCase();
}

export function terms(query) {
  return normalize(query).split(/\s+/).filter(Boolean);
}

export function squash(text) {
  return text.replace(/\s+/g, "");
}

export function includesAll(haystack, words) {
  return words.every((w) => haystack.includes(w));
}

export function matches(haystack, words, compact) {
  const hay = normalize(haystack);
  if (includesAll(hay, words)) {
    return true;
  }
  if (!compact) {
    return false;
  }
  return includesAll(squash(hay), words);
}
