export async function onRequestGet() {
  return new Response(JSON.stringify({
    ok: true,
    service: "DOMA Cloudflare Pages Functions",
    check: "root-health"
  }), {
    headers: {
      "content-type": "application/json; charset=utf-8",
      "cache-control": "no-store"
    }
  });
}
