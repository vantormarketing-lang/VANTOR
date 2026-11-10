# DOMA Cloudflare Pages smoke test

This folder is an isolated deployment fixture. It is not the production DOMA website.

## What it checks

- Static asset delivery from `public/index.html`.
- Pages Functions routing through `functions/api/health.js` at `/api/health`.

## Deploy to a separate staging project

From this folder, create/use a separate Cloudflare Pages project named `doma-academy-staging` and run:

```sh
npx wrangler pages deploy public --project-name doma-academy-staging
```

The `functions` directory must remain beside `public` in this folder. Do not run `wrangler deploy` here; that command targets Workers, not Pages.

After deployment, open the staging `pages.dev` URL. The page should display **PASS** after requesting `/api/health`.

This test does not change the production project, its custom domains, or the `main` branch.
