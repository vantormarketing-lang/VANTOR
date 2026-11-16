import assert from "node:assert/strict";
import {
  readBatchSubmissions,
  mergeBatchResults,
  batchResultsComplete
} from "../functions/_shared/judge0-batch.mjs";

const tokens = ["token-a", "token-b", "token-c"];
const accepted = (token, stdout) => ({
  token,
  stdout,
  status: { id: 3, description: "Accepted" }
});

// Judge0 CE's documented GET batch response is an object containing submissions.
const officialPayload = { submissions: [accepted("token-a", "A"), accepted("token-b", "B")] };
assert.deepEqual(readBatchSubmissions(officialPayload), officialPayload.submissions);

// Keep compatibility with providers that return a bare array.
assert.deepEqual(readBatchSubmissions([accepted("token-a", "A")]), [accepted("token-a", "A")]);

// Partial polls are merged by token and kept in the original request order.
let merged = mergeBatchResults(tokens, [null, null, null], [
  accepted("token-b", "B"),
  accepted("token-a", "A")
]);
assert.deepEqual(merged.map(item => item && item.token), ["token-a", "token-b", null]);
assert.equal(batchResultsComplete(merged), false);

// A later poll completes only the missing token without dropping earlier results.
merged = mergeBatchResults(tokens, merged, [accepted("token-c", "C")]);
assert.deepEqual(merged.map(item => item.token), tokens);
assert.equal(batchResultsComplete(merged), true);

// Full responses without tokens can only use positional mapping when all slots exist.
const tokenless = mergeBatchResults(tokens, [null, null, null], [
  { stdout: "A", status: { id: 3 } },
  { stdout: "B", status: { id: 3 } },
  { stdout: "C", status: { id: 3 } }
]);
assert.deepEqual(tokenless.map(item => item.token), tokens);
assert.equal(batchResultsComplete(tokenless), true);

// Queued/running jobs are not treated as finished.
assert.equal(batchResultsComplete([{ token: "x", status: { id: 1 } }]), false);
assert.equal(readBatchSubmissions({ error: "bad response" }), null);

console.log("PASS: Judge0 official batch envelope, legacy array, partial polls, token ordering, and completion states.");
