export function readBatchSubmissions(payload) {
  if (Array.isArray(payload)) return payload;
  if (payload && typeof payload === "object") {
    if (Array.isArray(payload.submissions)) return payload.submissions;
    if (Array.isArray(payload.data)) return payload.data;
  }
  return null;
}

export function mergeBatchResults(tokens, previous, incoming) {
  const received = Array.isArray(incoming) ? incoming : readBatchSubmissions(incoming);
  const byToken = new Map();

  if (Array.isArray(previous)) {
    for (const item of previous) {
      if (item && typeof item.token === "string") byToken.set(item.token, item);
    }
  }

  if (!Array.isArray(received)) {
    return tokens.map(token => byToken.get(token) || null);
  }

  for (const item of received) {
    if (item && typeof item.token === "string" && tokens.includes(item.token)) {
      byToken.set(item.token, item);
    }
  }

  // A full tokenless array can safely be associated by its documented request order.
  if (received.length === tokens.length) {
    received.forEach((item, index) => {
      if (item && typeof item === "object" && typeof item.token !== "string") {
        byToken.set(tokens[index], { ...item, token: tokens[index] });
      }
    });
  }

  return tokens.map(token => byToken.get(token) || null);
}

export function batchResultsComplete(results) {
  return Array.isArray(results) && results.length > 0 && results.every(item => {
    if (!item || typeof item !== "object") return false;
    const statusId = Number(item.status && item.status.id != null ? item.status.id : item.status_id);
    return Number.isFinite(statusId) && statusId > 2;
  });
}
