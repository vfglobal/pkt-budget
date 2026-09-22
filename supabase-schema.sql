-- PKT Budget Control — schema for Supabase.
-- Run this once in the Supabase SQL editor (Project → SQL Editor → New query).
--
-- Only two people use this app, both are added manually as Supabase Auth
-- users (Authentication → Users → Add user) — there is no sign-up form in
-- the app itself. Every table below is readable and writable by any
-- signed-in user; that is deliberate for a 2-person shared workspace, but
-- means anyone who gets a login can edit everything.

create extension if not exists pgcrypto;

create table if not exists public.budget_items (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  description text not null default '',
  created_at  timestamptz not null default now()
);

create table if not exists public.budget_allocations (
  id       uuid primary key default gen_random_uuid(),
  item_id  uuid not null references public.budget_items(id) on delete cascade,
  year     int not null,
  monthly  jsonb not null default '[0,0,0,0,0,0,0,0,0,0,0,0]'::jsonb,
  unique (item_id, year)
);

create table if not exists public.budget_expenses (
  id          uuid primary key default gen_random_uuid(),
  date        date not null,
  item        text not null,
  description text not null default '',
  amount      numeric not null default 0,
  pr          text not null default '',
  po          text not null default '',
  checklist   jsonb not null default '{"deNghi":false,"pheDuyet":false,"hoaDon":false}'::jsonb,
  created_at  timestamptz not null default now()
);

alter table public.budget_items enable row level security;
alter table public.budget_allocations enable row level security;
alter table public.budget_expenses enable row level security;

create policy "signed-in users can read items" on public.budget_items
  for select using (auth.role() = 'authenticated');
create policy "signed-in users can write items" on public.budget_items
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create policy "signed-in users can read allocations" on public.budget_allocations
  for select using (auth.role() = 'authenticated');
create policy "signed-in users can write allocations" on public.budget_allocations
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create policy "signed-in users can read expenses" on public.budget_expenses
  for select using (auth.role() = 'authenticated');
create policy "signed-in users can write expenses" on public.budget_expenses
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
