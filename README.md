# FitSwap v2 — Supabase starter

This starter adds shared public listings and seller email/password registration to the FitSwap prototype.

## Included
- `index.html`: responsive front end using Supabase JS v2 from a CDN.
- `schema.sql`: database tables, indexes, row-level security (RLS), and a signup profile trigger.

## Important limitations
- This is a starter, not a launched or audited commercial marketplace.
- No payments, checkout, buyer/seller messaging, image upload, listing edits, or automated admin dashboard.
- New listings are `pending`; a trusted admin must approve them in Supabase.
- The front end uses the public/publishable (or legacy anon) key only. Never expose a `service_role` key.
- Have a parent/guardian or other trusted adult oversee creation and management of hosting, database, domain, payment and business accounts. Check provider age/eligibility terms.
- Before public launch, add moderation/reporting, privacy information, terms, seller rules, account deletion, abuse controls, backups and appropriate legal review.

## Setup
1. A trusted adult should create a Supabase project and review the provider's current age and account terms.
2. In Supabase, open **SQL Editor**, create a query, paste `schema.sql`, and run it.
3. Open **Project Settings → API** (or the current API keys page). Copy the Project URL and the public/publishable anon key.
4. Open `index.html` and replace:
   - `YOUR_SUPABASE_PROJECT_URL`
   - `YOUR_SUPABASE_PUBLISHABLE_OR_ANON_KEY`
5. Do not use a `service_role` or secret key in `index.html`.
6. In Supabase Auth settings, configure the allowed site URL and redirect URLs for your chosen local test address or deployed domain. Keep email confirmation enabled for public testing.
7. For local testing, use a simple local static server (for example, `python -m http.server 8000`) and open `http://localhost:8000`. Do not rely on opening the file directly with `file://`.
8. Create a test seller account. Submit a test listing. It should show in **My seller listings** as pending.
9. To approve a test listing, a trusted administrator can use the Supabase Table Editor on `public.listings` to change its `status` from `pending` to `approved`. The listing should then appear in public browsing.

## Security notes
- RLS is enabled on both tables.
- Public visitors can read approved listings only.
- Authenticated sellers can insert listings only for their own user ID and only with `pending` status.
- Sellers cannot approve listings or update/delete listings in this starter.
- Seller profile fields are intentionally limited to display name and town. Do not add private email, phone, or home address to public tables.
- The SQL grants authenticated users update access to their own profile under RLS; if you later add sensitive profile fields, revisit column-level privileges and policies.
- Test policies with separate seller accounts before any public launch.
