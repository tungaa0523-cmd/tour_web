# EBA TOUR website and management platform

Cloudflare Pages + Pages Functions + D1. The package includes a multilingual public landing page, a dynamic tours page, inquiry and booking-request APIs, staff sign-in, role-based admin access, tour CRUD, booking/inquiry status management, availability dates, gallery, reviews, and email notifications through Resend.

## Important scope notes
- Booking requests are **not paid reservations**. Staff must contact the customer and confirm availability/price. No card or passport data is collected.
- Payment processing is not included; integrate a suitable licensed payment provider only after the company chooses one.
- Availability is a staff-managed calendar, not a real-time inventory lock/payment checkout.
- Images use externally hosted image URLs for now. Cloudflare R2 upload UI is not included.
- Before public launch, configure Turnstile/rate limiting and publish a privacy notice.

## Cloudflare Pages configuration
- Framework preset: None
- Build command: blank
- Build output directory: `.`
- Root directory: `/`
- Pages Functions folder: `functions/`
- D1 binding: variable `DB` → database `ebatourdb`

The `wrangler.toml` contains the existing D1 database ID from this deployment. If using a different D1 database, update the ID.

## Initialize D1 once
Cloudflare dashboard → D1 → `ebatourdb` → Console. Run the SQL in `migrations/0001_initial.sql` once. This creates staff, sessions, tours, bookings, availability, inquiries, reviews, and gallery tables. Do not run it repeatedly if you later add non-idempotent migrations; this initial file uses `IF NOT EXISTS` for tables/indexes.

## Secrets and email
Pages project → Settings → Variables and Secrets → add encrypted runtime secrets:
- `BOOTSTRAP_SECRET`: a long random one-time setup secret (at least 32 random characters)
- `RESEND_API_KEY`: API key from Resend

Add non-secret runtime variables:
- `NOTIFY_EMAIL`: company email that receives enquiries/bookings
- `EMAIL_FROM`: verified sender, e.g. `EBA TOUR <bookings@eba-tour.com>` after verifying the domain with Resend

First admin setup:
1. Deploy the site and open `/admin.html`.
2. Use the first-administrator form with `BOOTSTRAP_SECRET`, name, email and a password of at least 12 characters.
3. After it succeeds, remove `BOOTSTRAP_SECRET` from Cloudflare immediately and redeploy if requested.
4. Sign in. Passwords are PBKDF2-SHA256 hashed; sessions are opaque, hashed in D1, HttpOnly/Secure/SameSite cookies with seven-day expiry.

## Roles
- `super_admin`: all admin features and staff management.
- `manager`: manage tours, bookings, availability, inquiries, reviews and gallery.
- `staff`: view and update booking/inquiry statuses; no delete or staff management.

## Test checklist
1. `/api/health` returns `ok` and `database: true`.
2. `/admin.html` first-admin bootstrap, then sign in.
3. Add a tour in Tours and set status to `published`; view it at `/tours.html`.
4. Submit a public enquiry from `/`; verify it appears under Inquiries.
5. Submit a booking request from `/api/bookings` using a published tour ID; verify it appears under Bookings.
6. Add availability dates and test `/api/availability`.
7. Add a gallery image URL and a review; publish them to make public API results visible.
8. Verify both company and customer emails after configuring Resend.

Never put API keys, passwords, bootstrap secrets, or customer exports in GitHub. Use test records until all checks pass.

## Photo credits and reuse licences
The public site uses real photographs of Mongolia hosted by Wikimedia Commons. Credits and licence links are displayed in the site footer. The current set is:
- Rider in Mongolia, 2012 — Al Jazeera English, CC BY-SA 2.0: https://commons.wikimedia.org/wiki/File:Rider_in_Mongolia,_2012.jpg
- Mongolian nomads — Yaan, CC BY-SA 3.0: https://commons.wikimedia.org/wiki/File:Mongolian_nomads.jpg
- Mongolian Camel in Gobi desert — Dalaikhishig, CC BY-SA 4.0: https://commons.wikimedia.org/wiki/File:Mongolian_Camel_in_Gobi_desert.jpg
- Turtle Rock Mongolia — Vidor, public domain: https://commons.wikimedia.org/wiki/File:Turtle_Rock_Mongolia.jpg
- Lake Khuvsgul — Lyallla, CC BY-SA 4.0: https://commons.wikimedia.org/wiki/File:Lake_Khuvsgul.jpg
- Downtown Ulaanbaatar — Worldeditor209, CC BY-SA 4.0: https://commons.wikimedia.org/wiki/File:Downtown_Ulaanbaatar.jpg

Images are loaded from Wikimedia Commons using Special:FilePath. If the company later supplies its own licensed photographs, replace these URLs and update the credits.


## Search visibility
Korean is the default public language, with English and Japanese available in the language selector. `robots.txt` and `sitemap.xml` are included. After `eba-tour.com` is live, verify the domain in Google Search Console and submit `/sitemap.xml`. Search placement depends on Google's indexing, relevance, authority, competition and ongoing content; no site can guarantee a first-place result.

## Security
Pages Functions apply baseline browser security headers, same-origin checks for write requests, D1-backed rate limits for login/bootstrap/public enquiries, password hashing (PBKDF2-SHA256, 100,000 iterations), hashed session tokens and Secure/HttpOnly/SameSite=Strict cookies. Remove `BOOTSTRAP_SECRET` after initial admin creation and keep all production secrets in Cloudflare Pages environment variables only.
