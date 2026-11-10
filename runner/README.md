# DOMA Code Runner

The Programming Academy editor sends code submissions to the same-origin Cloudflare Pages Function at `/api/code-run`. The function verifies the Supabase access token and active Programming Academy subscription, applies strict source/input and execution limits, and forwards requests to a hosted Judge0 CE service (or a private Judge0 instance).

## Hosted Judge0 setup (no VPS required)

Judge0 documents a shared-cloud option through Sulu, including a 20,000-submission trial for new sign-ups. Trial availability and terms are controlled by the provider; do not assume unlimited free usage. See the official Judge0 examples and service details:
- https://github.com/judge0/examples
- https://judge0.com/

After the account owner creates a Judge0 CE service in the provider dashboard, copy the API base URL and API credential from that dashboard. Do not put the credential in frontend code, GitHub files, chat messages, or screenshots.

## Required Cloudflare Pages environment variables

Set these for both Production and Preview as appropriate:

- `SUPABASE_URL`: the existing DOMA Supabase project URL.
- `SUPABASE_ANON_KEY`: the public Supabase publishable/anon key.
- `SUPABASE_SERVICE_ROLE_KEY`: Supabase service-role key. **Secret only**; never add it to frontend files or Git.
- `JUDGE0_URL`: the provider's Judge0 CE API base URL (no `/submissions` suffix).
- `JUDGE0_AUTH_TOKEN`: provider API credential. **Secret only.**
- `JUDGE0_AUTH_HEADER`: optional authentication header name; defaults to `X-Auth-Token`. Use the exact header name shown by the provider.
- `JUDGE0_AUTH_HOST`: optional `X-RapidAPI-Host` value, only if the selected provider explicitly requires it.

The function supports asynchronous Judge0 submissions and polls the returned token because shared-cloud services may not enable `wait=true`. Never expose provider credentials to the browser.

## Safety defaults

The Pages Function:
- requires a valid DOMA Supabase session;
- requires an active Programming Academy subscription or staff role;
- allows only a fixed list of language IDs;
- limits source to 16 KB and stdin to 2 KB;
- requests 2 seconds CPU, 6 seconds wall time, 128 MB memory, 64 MB stack, and 1 MB file/output size;
- disables network access in the submitted program;
- never exposes Judge0 credentials to the browser.

Do not deploy an unauthenticated public code runner. Review the provider's isolation, resource, queue, retention, and network settings before accepting student code. The hosted provider's own limits and terms take precedence over any local limits.
