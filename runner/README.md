# DOMA Code Runner

The Programming Academy editor sends compiled/interpreted language submissions to the same-origin Cloudflare Pages Function at `/api/code-run`. The function verifies the Supabase access token and active Programming Academy subscription, applies strict source/input and execution limits, and forwards the request to a private Judge0 CE instance.

## Required Cloudflare Pages environment variables

Set these for both Production and Preview as appropriate:

- `SUPABASE_URL`: the existing DOMA Supabase project URL.
- `SUPABASE_ANON_KEY`: the public Supabase publishable/anon key.
- `SUPABASE_SERVICE_ROLE_KEY`: Supabase service-role key. **Secret only**; never add it to frontend files or Git.
- `JUDGE0_URL`: base URL of your private HTTPS Judge0 CE deployment (no `/submissions` suffix).
- `JUDGE0_AUTH_TOKEN`: optional Judge0 authentication token. Store as a secret if enabled.

The repository cannot safely host a compiler runtime inside static Cloudflare Pages. Judge0 CE must run on a separate server/container host. Follow the official self-hosting instructions at https://github.com/judge0/judge0 and expose it only over HTTPS. Keep the Judge0 host private where possible and set an authentication token.

## Safety defaults

The Pages Function:
- requires a valid DOMA Supabase session;
- requires an active Programming Academy subscription or staff role;
- allows only a fixed list of language IDs;
- limits source to 16 KB and stdin to 2 KB;
- requests 2 seconds CPU, 6 seconds wall time, 128 MB memory, 64 MB stack, 1 MB output/file size;
- disables network access in the submitted program;
- never exposes Judge0 credentials to the browser.

Do not deploy an unauthenticated public code runner. Review Judge0's own isolation, resource, queue and network settings before accepting student code.
