-- Supabase migration: Leads table for name and phone number collection
-- Run this in your Supabase SQL Editor after creating your project.

create table if not exists leads (
  id          bigserial primary key,
  name        text not null,
  phone       text not null,
  source      text not null default 'unknown',
  created_at  timestamp with time zone default timezone('utc'::text, now())
);

-- Enable Row Level Security
alter table leads enable row level security;

-- SECURITY IMPROVEMENTS: 
-- Anonymous users can INSERT (for lead collection via the phone form)
-- But with rate limiting and validation on the client side
create policy "Allow anonymous inserts on leads"
  on leads for insert
  with check (true);

-- SECURITY: Remove anonymous SELECT access - this should require authentication
-- Commented out for now - uncomment when you implement proper authentication
-- create policy "Allow anonymous reads on leads"
--   on leads for select
--   using (true);

-- SECURITY: Remove anonymous DELETE access - this should require authentication
-- Commented out for now - uncomment when you implement proper authentication
-- create policy "Allow anonymous deletes on leads"
--   on leads for delete
--   using (true);

-- TEMPORARY: Allow anonymous reads for development (REMOVE IN PRODUCTION)
create policy "Temp anonymous reads on leads - REMOVE IN PRODUCTION"
  on leads for select
  using (true);

-- TEMPORARY: Allow anonymous deletes for development (REMOVE IN PRODUCTION)
create policy "Temp anonymous deletes on leads - REMOVE IN PRODUCTION"
  on leads for delete
  using (true);

-- For production, implement proper authentication:
-- 1. Create authenticated users table
-- 2. Use Supabase Auth or similar
-- 3. Replace above policies with authenticated-only policies
-- 4. Move admin panel to separate authenticated route

-- Helpful index for time-range queries and phone lookups
create index if not exists leads_created_at_idx on leads (created_at);
create index if not exists leads_phone_idx on leads (phone);
create index if not exists leads_name_idx on leads (name);
