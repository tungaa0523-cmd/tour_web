# EBA TOUR — Cloudflare Pages deployment

## Repository layout
Upload the contents of this folder to the root of the private `ebatour9/eba-tour` GitHub repository. Do not upload only the ZIP. Confirm `functions/`, `migrations/`, `index.html`, `admin.html`, `tours.html`, `schema.sql`, and `wrangler.toml` are visible at repository root.

## Pages build settings
Use Cloudflare Pages (not a Worker-only project):
- Framework preset: None
- Build command: blank
- Build output directory: `.`
- Root directory: `/`

## Bind D1
Pages → Settings → Bindings → D1 database:
- Variable name: `DB`
- Database: `ebatourdb`

## Create tables
D1 → ebatourdb → Console. Paste the full content of `migrations/0001_initial.sql` and execute it once. Confirm `/tables` lists `staff`, `sessions`, `tours`, `bookings`, `availability`, `reviews`, `gallery`, `inquiries`.

## Add secrets / variables
Pages → Settings → Variables and Secrets (runtime):
- Secret `BOOTSTRAP_SECRET`: random 32+ character value
- Secret `RESEND_API_KEY`: optional until email is configured
- Variable `NOTIFY_EMAIL`: company inbox
- Variable `EMAIL_FROM`: verified Resend sender address

Deploy after adding settings. Open `/admin.html`, create the first admin using the bootstrap secret, then delete `BOOTSTRAP_SECRET` immediately. Do not put secrets in GitHub or share them in chat.

## Domain
Only after `.pages.dev` tests pass, add `eba-tour.com` in Pages → Custom domains and follow Cloudflare's displayed DNS instructions at Green Soft. Do not guess DNS records.

## Payment limitation
This version does not take payments or store payment-card details. Customer submissions create booking requests that staff must review and confirm manually.


## SEO and security notes (2026-11)
- The public website defaults to Korean; visitors can switch to English or Japanese.
- `robots.txt` and `sitemap.xml` are included. Submit `https://eba-tour.com/sitemap.xml` in Google Search Console after the domain is live. Verify domain ownership there; Google ranking cannot be guaranteed.
- Pages Functions add security headers, same-origin checks, hashed D1 rate limits, and a stricter session cookie. Rate-limit storage is created automatically in D1 on first use.
- Keep `BOOTSTRAP_SECRET` removed after the first administrator has been created. Never commit secrets, API keys, or passwords to GitHub.
- The admin page is excluded from search indexing and is not linked from public navigation.
