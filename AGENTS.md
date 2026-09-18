# AGENTS.md

## Project

Single-file static landing page (`natural-ulcer-cure-book-ad.html`) for
*The Natural Ulcer Cure* by Denzel Odiwuor — a clinical herbalist.

## Quick start (local dev)

```bash
npm run dev
```

This starts a lightweight Node.js HTTP server on `http://localhost:3000`
that:

1. Serves `natural-ulcer-cure-book-ad.html`
2. Injects a `localStorage`-backed `window.storage` mock so the **admin
   dashboard** records and displays WhatsApp click data during development

### Useful URLs

| Route | Description |
|-------|-------------|
| `http://localhost:3000/` | Main landing page |
| `http://localhost:3000/#admin` | Admin dashboard (passcode: `gemsofinsight2026`) |

## Admin dashboard

The admin view is built into the HTML (hash-route `#admin`). It is hidden
by default and password-gated with the passcode defined in `CONFIG.adminPasscode`.

Once unlocked, it shows:

- **Total** / **today** / **last 7 days** WhatsApp click counts
- A **recent activity** log table (date, time, source)
- **Refresh** and **Reset all data** buttons

Click tracking in local dev uses the injected `window.storage` mock backed by
`localStorage`. No backend or Supabase required.

## Configuration

Edit the `CONFIG` object at the top of the `<script>` block in
`natural-ulcer-cure-book-ad.html`:

```js
const CONFIG = {
  whatsappNumber: "254111646402",        // WhatsApp Business number, international format (no +)
  whatsappMessage: "Hi, I'd like to order The Natural Ulcer Cure book.",
  adminPasscode: "gemsofinsight2026",    // client-side placeholder — NOT real security
  supabaseUrl:  "YOUR_SUPABASE_PROJECT_URL",
  supabaseAnonKey: "YOUR_SUPABASE_ANON_KEY"
};
```

## Database setup (Supabase)

For production click tracking, create a free [Supabase](https://supabase.com)
project and run the migration:

1. Go to https://app.supabase.com/ → **New project** (free tier is sufficient)
2. Once the project is provisioned, open **SQL Editor**
3. Run the SQL from `supabase/migrations/20240101000000_create_wa_clicks.sql`

This creates a `wa_clicks` table with columns:
- `id` (auto-incrementing primary key)
- `source` (text — which button was clicked: `nav`, `hero`, `buy`, etc.)
- `created_at` (timestamp, auto-set to UTC)

Row Level Security (RLS) is enabled with policies allowing anonymous
INSERT, SELECT, and DELETE. See the migration file for details and security notes.

4. Copy **Project URL** and **anon public key** from Settings → API into your `.env`:

```bash
cp .env.example .env
# Edit .env with your real SUPABASE_URL and SUPABASE_ANON_KEY
```

## Deployment

### Option A: Static hosting (Vercel / Netlify / GitHub Pages)

1. Build the production HTML with real Supabase credentials injected:

   ```bash
   npm run build
   ```

   This reads `.env` and writes `dist/natural-ulcer-cure-book-ad.html` with
   the Supabase URL/anon key replaced. No `window.storage` mock is injected —
   click tracking uses Supabase directly.

2. Deploy the `dist/` folder to your static host:

   - **Vercel:** `vercel --dir dist`
   - **Netlify:** drag-drop `dist/` in the dashboard, or `netlify deploy --dir=dist`
   - **GitHub Pages:** copy `dist/natural-ulcer-cure-book-ad.html` to your
     `gh-pages` branch

### Option B: Self-hosted Node.js server

```bash
npm start
```

Serves the page on `http://localhost:3000` with Supabase credentials read
from `.env`. Useful when you control your own server.

## Local vs Production tracking

| Mode | Storage | How clicks are logged |
|------|---------|-----------------------|
| Local dev (`npm run dev`) | `localStorage` via injected mock | `window.storage.get/set` |
| Production (`npm run build`) | Supabase Postgres | `fetch` to Supabase REST API |
| Claude preview | `window.storage` (provided by Claude) | `window.storage.get/set` |

In all modes, WhatsApp buttons open `https://wa.me/254111646402` and the
click is recorded before the window opens.
