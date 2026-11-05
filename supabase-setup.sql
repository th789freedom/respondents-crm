-- Internal CRM schema for respondents-crm
-- Run this in Supabase SQL Editor while signed in as the project owner.
-- Access is limited to authenticated users. Do not enable public sign-ups.

create table if not exists public.crm_respondents (
  id text primary key,
  surname text not null,
  name text not null,
  phone text not null,
  city text,
  age integer,
  type text not null default 'Обычный респондент',
  notes text,
  created timestamptz not null default now()
);

create unique index if not exists crm_respondents_phone_norm_idx
  on public.crm_respondents (regexp_replace(phone, '\\D', '', 'g'));

create table if not exists public.crm_history (
  id text primary key,
  person_id text not null references public.crm_respondents(id) on delete cascade,
  participation_date date not null,
  format text,
  topic text not null,
  project text,
  notes text,
  created timestamptz not null default now()
);

create index if not exists crm_history_person_date_idx
  on public.crm_history (person_id, participation_date desc);

create table if not exists public.crm_requests (
  id text primary key,
  surname text not null,
  name text not null,
  phone text not null,
  city text,
  age integer,
  created timestamptz not null default now(),
  status text not null default 'Новая'
);

create table if not exists public.crm_projects (
  id text primary key,
  name text not null,
  client text,
  format text,
  project_date date,
  status text,
  created timestamptz not null default now()
);

alter table public.crm_respondents enable row level security;
alter table public.crm_history enable row level security;
alter table public.crm_requests enable row level security;
alter table public.crm_projects enable row level security;

drop policy if exists "Authenticated staff can manage respondents" on public.crm_respondents;
create policy "Authenticated staff can manage respondents"
  on public.crm_respondents for all to authenticated
  using (auth.uid() is not null) with check (auth.uid() is not null);

drop policy if exists "Authenticated staff can manage history" on public.crm_history;
create policy "Authenticated staff can manage history"
  on public.crm_history for all to authenticated
  using (auth.uid() is not null) with check (auth.uid() is not null);

drop policy if exists "Authenticated staff can manage requests" on public.crm_requests;
create policy "Authenticated staff can manage requests"
  on public.crm_requests for all to authenticated
  using (auth.uid() is not null) with check (auth.uid() is not null);

drop policy if exists "Authenticated staff can manage projects" on public.crm_projects;
create policy "Authenticated staff can manage projects"
  on public.crm_projects for all to authenticated
  using (auth.uid() is not null) with check (auth.uid() is not null);

grant select, insert, update, delete on public.crm_respondents to authenticated;
grant select, insert, update, delete on public.crm_history to authenticated;
grant select, insert, update, delete on public.crm_requests to authenticated;
grant select, insert, update, delete on public.crm_projects to authenticated;
