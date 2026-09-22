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

-- One-time seed of the default commitment items. Only runs on a table that
-- has never had a row — deleting items later must not bring them back, so
-- this is not repeated anywhere in the app itself.
insert into public.budget_items (name, description)
select * from (values
  ('Đào tạo nội bộ', 'Chi phí tổ chức các khóa đào tạo nội bộ, train-the-trainer, đào tạo nghiệp vụ cho nhân sự PKT và mạng lưới đại lý.'),
  ('Đào tạo bên ngoài / thuê giảng viên', 'Chi phí thuê chuyên gia, giảng viên bên ngoài, các khóa học mua từ đối tác đào tạo.'),
  ('Văn phòng phẩm & in ấn', 'In ấn tài liệu đào tạo, văn phòng phẩm phục vụ các lớp học và sự kiện.'),
  ('Đi lại & công tác phí', 'Vé máy bay, khách sạn, công tác phí cho đội ngũ đào tạo di chuyển giữa các thị trường.'),
  ('Sự kiện & hội thảo', 'Chi phí tổ chức sự kiện, hội thảo, pilot chương trình, workshop nội bộ.'),
  ('Công cụ & phần mềm', 'Bản quyền LMS, phần mềm hỗ trợ thiết kế và quản lý đào tạo.'),
  ('Khác', 'Các khoản chi phát sinh khác không thuộc các nhóm trên.')
) as seed(name, description)
where not exists (select 1 from public.budget_items);
