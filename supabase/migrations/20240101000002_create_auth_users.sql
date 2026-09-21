-- Supabase migration: Auth users table for secure admin access
-- Run this in your Supabase SQL Editor after creating your project.

-- Create authenticated users table for admin access
create table if not exists auth_users (
  id uuid primary key default gen_random_uuid(),
  email text unique not null,
  password_hash text not null,
  role text default 'admin',
  created_at timestamp with time zone default timezone('utc'::text, now()),
  last_login timestamp with time zone
);

-- Enable Row Level Security
alter table auth_users enable row level security;

-- Only service role can manage auth_users (secure)
create policy "Service role can manage auth_users"
  on auth_users for all
  using (auth.role() = 'service_role');

-- SECURITY: Production RLS policies for leads table
-- These should replace the temporary policies in the previous migration

-- Remove temporary policies (for production use)
-- drop policy if exists "Temp anonymous reads on leads - REMOVE IN PRODUCTION" on leads;
-- drop policy if exists "Temp anonymous deletes on leads - REMOVE IN PRODUCTION" on leads;

-- Production policies (uncomment when ready for production):
-- create policy "Authenticated users can read leads"
--   on leads for select
--   using (auth.uid() in (select id from auth_users where role = 'admin'));

-- create policy "Authenticated users can delete leads"
--   on leads for delete
--   using (auth.uid() in (select id from auth_users where role = 'admin'));

-- Keep anonymous inserts for lead collection (with client-side rate limiting)
create policy "Allow anonymous inserts on leads with validation"
  on leads for insert
  with check (
    length(name) >= 2 and length(name) <= 50 and
    length(phone) >= 10 and length(phone) <= 15 and
    phone ~ '^\+?[0-9]+$'
  );

-- Create admin user (change password in production!)
-- Default: admin@example.com / change_me_password_123
-- IMPORTANT: Change this password immediately after first login
insert into auth_users (email, password_hash, role)
values (
  'admin@example.com',
  crypt('change_me_password_123', gen_salt('bf')),
  'admin'
)
on conflict (email) do nothing;

-- Note: For production deployment:
-- 1. Change the default admin password immediately
-- 2. Use proper password hashing library in your backend
-- 3. Implement JWT token-based authentication
-- 4. Move admin panel to separate route with authentication middleware
-- 5. Use HTTPS only
-- 6. Implement server-side validation instead of client-side
