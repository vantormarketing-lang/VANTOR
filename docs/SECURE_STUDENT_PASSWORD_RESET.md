# Secure student password reset setup

The password-reset endpoints run as Cloudflare Pages Functions and require a server-only Supabase credential.

## Required Cloudflare environment variables

In Cloudflare Dashboard:

1. Open Workers & Pages and select the doma-academy Pages project.
2. Open Settings → Variables and Secrets.
3. Add the following for both Production and Preview environments:
   - SUPABASE_URL — https://dtptxhkcogpoleftguas.supabase.co
   - SUPABASE_SERVICE_ROLE_KEY — the Supabase project's server-side service-role key (or compatible Supabase secret key).
4. Save the settings and redeploy the latest production deployment.

Never put SUPABASE_SERVICE_ROLE_KEY in HTML, JavaScript shipped to browsers, GitHub, or a public environment variable. Do not send the key in chat.

## How the flow works

- Only a signed-in account whose profiles.role is exactly admin can call the admin reset endpoint.
- The endpoint verifies the selected account is a student, generates a cryptographically random 10-character temporary password, updates Supabase Auth, and sets the protected app_metadata.must_change_password flag.
- The temporary password is returned only in the immediate response. It is not written to the database or server logs.
- At the next sign-in, the student is held at the password-change screen until the new password is saved through the server endpoint.
- The login-page Forgot password? action opens a prefilled WhatsApp message. The administrator must verify the student's identity before issuing a temporary password.

## Email recovery and redirect allow-list

- The admin login now includes **Forgot password?**. It sends a Supabase recovery email and opens a secure password-change form when the recovery link returns to `admin.html`.
- Student accounts that have a real email address can use the login-page **Forgot password?** link. The recovery link opens a secure password-change form on the student site.
- In Supabase Dashboard → Authentication → URL Configuration, add the production URLs to the Redirect URLs allow-list:
  - `https://doma-academy.pages.dev/`
  - `https://doma-academy.pages.dev/admin.html`
- Add equivalent preview/custom-domain URLs only if those environments are used. Keep the Site URL set to the primary production site.

## OTP note

Student accounts currently use internal .invalid email aliases with Supabase Email/Password Auth. That means SMS/WhatsApp OTP recovery cannot work until a real SMS/WhatsApp verification provider and a verified delivery flow are configured. The current WhatsApp path deliberately does not claim that an OTP was sent. For phone-only students, the flow opens a WhatsApp request; an administrator must verify the student before using the admin-only temporary-password reset action.
