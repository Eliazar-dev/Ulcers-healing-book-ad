-- Supabase migration: WhatsApp click tracking table
-- Run this in your Supabase SQL Editor after creating your project.

create table if not exists wa_clicks (
  id          bigserial primary key,
  source      text not null default 'unknown',
  created_at  timestamp with time zone default timezone('utc'::text, now())
);

-- Enable Row Level Security
alter table wa_clicks enable row level security;

-- Anonymous users can INSERT (for click tracking via the wa_buttons)
create policy "Allow anonymous inserts on wa_clicks"
  on wa_clicks for insert
  with check (true);

-- Anonymous users can SELECT (for the admin dashboard to read click data)
create policy "Allow anonymous reads on wa_clicks"
  on wa_clicks for select
  using (true);

-- Anonymous users can DELETE (for the "Reset all data" button in admin)
create policy "Allow anonymous deletes on wa_clicks"
  on wa_clicks for delete
  using (true);

-- Optional: restrict DELETE to a specific condition later
-- if you add real authentication (e.g., Supabase Auth with email/password).
-- For now, the admin dashboard uses a client-side passcode only.

-- Helpful index for time-range queries (today / last 7 days filters)
create index if not exists wa_clicks_created_at_idx on wa_clicks (created_at);
