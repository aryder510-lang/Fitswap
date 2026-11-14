-- FitSwap v2 database schema for Supabase
-- Run this in Supabase Dashboard > SQL Editor.
-- This uses Supabase Auth and row-level security (RLS).

create table if not exists public.seller_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'FitSwap seller' check (char_length(display_name) between 1 and 40),
  town text not null default '' check (char_length(town) <= 50),
  created_at timestamptz not null default now()
);

create table if not exists public.listings (
  id uuid primary key default gen_random_uuid(),
  seller_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (char_length(title) between 3 and 80),
  description text not null check (char_length(description) between 5 and 700),
  price numeric(10,2) not null check (price >= 0 and price <= 100000),
  category text not null check (category in ('Weights','Home gym','Sports','Cardio','Accessories')),
  condition text not null check (condition in ('New','Like new','Good','Well used')),
  town text not null check (char_length(town) between 1 and 50),
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  created_at timestamptz not null default now()
);

create index if not exists listings_public_browse_idx
  on public.listings (status, created_at desc);
create index if not exists listings_seller_idx
  on public.listings (seller_id, created_at desc);

alter table public.seller_profiles enable row level security;
alter table public.listings enable row level security;

-- Public seller display names/towns are visible; never store public email or home address here.
drop policy if exists "Public can read seller profiles" on public.seller_profiles;
create policy "Public can read seller profiles"
  on public.seller_profiles for select using (true);

drop policy if exists "Users can create own seller profile" on public.seller_profiles;
create policy "Users can create own seller profile"
  on public.seller_profiles for insert to authenticated
  with check (auth.uid() = id);

drop policy if exists "Users can update own seller profile" on public.seller_profiles;
create policy "Users can update own seller profile"
  on public.seller_profiles for update to authenticated
  using (auth.uid() = id) with check (auth.uid() = id);

-- Anyone can browse approved listings. Sellers can also see their own pending/rejected listings.
drop policy if exists "Public reads approved listings and owners read own" on public.listings;
create policy "Public reads approved listings and owners read own"
  on public.listings for select
  using (status = 'approved' or auth.uid() = seller_id);

-- Sellers can submit only pending listings. They cannot self-approve.
drop policy if exists "Sellers insert own pending listings" on public.listings;
create policy "Sellers insert own pending listings"
  on public.listings for insert to authenticated
  with check (auth.uid() = seller_id and status = 'pending');

-- No seller update/delete policy is intentionally provided in this starter.
-- Add carefully designed owner-edit policies later; never allow sellers to change status.
-- Admin approval is performed by a trusted administrator in the Supabase dashboard.
-- For a production admin UI, use a server-side role check; never put service_role keys in the browser.

-- Create a seller profile after signup using auth user metadata.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.seller_profiles (id, display_name, town)
  values (
    new.id,
    coalesce(nullif(new.raw_user_meta_data ->> 'display_name',''), 'FitSwap seller'),
    coalesce(new.raw_user_meta_data ->> 'town','')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_fitswap on auth.users;
create trigger on_auth_user_created_fitswap
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Grant the minimum table access needed by the browser client.
grant select on public.seller_profiles to anon, authenticated;
grant insert, update on public.seller_profiles to authenticated;
grant select on public.listings to anon, authenticated;
grant insert on public.listings to authenticated;
