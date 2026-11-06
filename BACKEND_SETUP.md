# Backend setup — quick guide
See README.md for the full deployment and testing checklist.

1. Connect this repository to a Cloudflare **Pages** project (not Workers-only deployment).
2. Set Framework=None, Build command blank, Build output directory `.`, Root `/`.
3. Add D1 binding `DB` → `ebatourdb` under Pages Settings → Bindings.
4. Run `migrations/0001_initial.sql` once in D1 Console.
5. Add runtime secret `BOOTSTRAP_SECRET`; add `RESEND_API_KEY` when email is ready. Add `NOTIFY_EMAIL` and `EMAIL_FROM` variables.
6. Deploy. Open `/admin.html`, create first administrator, then immediately delete `BOOTSTRAP_SECRET` from project secrets.
7. Sign in and add/publish tours, dates, gallery images and reviews.

Email requires a Resend account and a verified sender domain. Without those secrets, the website and database continue to work but emails are skipped. This system creates booking requests, not payment-confirmed reservations.
