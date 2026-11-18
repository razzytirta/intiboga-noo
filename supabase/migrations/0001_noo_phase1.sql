create extension if not exists pgcrypto;

create type public.noo_role as enum ('SUPERVISOR_SALES','SALES_MANAGER','GENERAL_MANAGER','IT','ADMIN');
create type public.noo_batch_status as enum ('DRAFT','SUBMITTED','IN_REVIEW','PARTIALLY_APPROVED','COMPLETED','CANCELLED');
create type public.noo_outlet_status as enum ('DRAFT','SUBMITTED','SM_REVIEW','SM_REVISION','SM_REJECTED','GM_REVIEW','GM_REVISION','GM_REJECTED','WAITING_IT','PROCESSING','BOSNET_SUCCESS','BOSNET_FAILED','COMPLETED');
create type public.noo_decision as enum ('APPROVED','REVISION','REJECTED');

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null unique,
  full_name text,
  role public.noo_role not null default 'SUPERVISOR_SALES',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.branches (
  id uuid primary key default gen_random_uuid(),
  workplace_code text not null unique check (workplace_code ~ '^[0-9]{3}$'),
  branch_name text not null unique,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.salesmen (
  id uuid primary key default gen_random_uuid(),
  employee_code text not null unique,
  salesman_name text not null,
  bosnet_sales_code text not null unique,
  branch_id uuid not null references public.branches(id),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.approval_mappings (
  id uuid primary key default gen_random_uuid(),
  approver_id uuid not null references public.profiles(id),
  branch_id uuid references public.branches(id),
  role public.noo_role not null check (role in ('SALES_MANAGER','GENERAL_MANAGER')),
  is_active boolean not null default true,
  unique (approver_id, branch_id, role)
);

create table if not exists public.noo_batches (
  id uuid primary key default gen_random_uuid(),
  batch_number text not null unique,
  supervisor_id uuid not null references public.profiles(id),
  branch_id uuid not null references public.branches(id),
  salesman_id uuid not null references public.salesmen(id),
  submitted_at timestamptz,
  status public.noo_batch_status not null default 'DRAFT',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.noo_outlets (
  id uuid primary key default gen_random_uuid(),
  batch_id uuid not null references public.noo_batches(id) on delete cascade,
  outlet_version integer not null default 1,
  status public.noo_outlet_status not null default 'DRAFT',
  customer_name text not null, owner_name text not null, contact_person text not null,
  nik text not null check (nik ~ '^[0-9]{16}$'), phone text not null, telephone text,
  address text not null, province text not null, city text not null, district text not null,
  village text not null, postal_code text, country text not null default 'INDONESIA',
  outlet_type text not null, payment text not null, top text not null, avg_sales numeric(14,2) not null default 0,
  requested_credit_limit numeric(14,2) not null default 0,
  sales_manager_credit_limit numeric(14,2), approved_credit_limit numeric(14,2),
  route text, notes text,
  latitude numeric(10,7) not null, longitude numeric(10,7) not null,
  gps_accuracy numeric(8,2) not null check (gps_accuracy >= 0), gps_captured_at timestamptz not null,
  gps_captured_by uuid not null references public.profiles(id),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  unique (batch_id, id)
);

create table if not exists public.noo_attachments (
  id uuid primary key default gen_random_uuid(), outlet_id uuid not null references public.noo_outlets(id) on delete cascade,
  attachment_type text not null check (attachment_type in ('KTP','STORE_FRONT','STORE_ADDITIONAL')),
  storage_path text not null unique, uploaded_by uuid not null references public.profiles(id),
  uploaded_at timestamptz not null default now()
);

create table if not exists public.noo_approvals (
  id uuid primary key default gen_random_uuid(), outlet_id uuid not null references public.noo_outlets(id) on delete cascade,
  reviewer_id uuid not null references public.profiles(id), reviewer_role public.noo_role not null,
  decision public.noo_decision not null, notes text, data_version integer not null,
  reviewed_at timestamptz not null default now(),
  check (reviewer_role in ('SALES_MANAGER','GENERAL_MANAGER')),
  check (decision = 'APPROVED' or nullif(trim(notes),'') is not null)
);

create table if not exists public.noo_revision_logs (
  id uuid primary key default gen_random_uuid(), outlet_id uuid not null references public.noo_outlets(id),
  changed_by uuid not null references public.profiles(id), old_data jsonb not null, new_data jsonb not null,
  created_at timestamptz not null default now()
);

create table if not exists public.noo_outlet_revision_logs (
  id uuid primary key default gen_random_uuid(), outlet_id uuid not null references public.noo_outlets(id),
  changed_by uuid not null references public.profiles(id), old_data jsonb not null, new_data jsonb not null,
  created_at timestamptz not null default now()
);

create table if not exists public.noo_bosnet_data (
  id uuid primary key default gen_random_uuid(), outlet_id uuid not null unique references public.noo_outlets(id),
  customer_number text unique check (customer_number ~ '^C[0-9]{7,}$'),
  bosnet_status text not null default 'WAITING_IT' check (bosnet_status in ('WAITING_IT','PROCESSING','BOSNET_SUCCESS','BOSNET_FAILED','COMPLETED')),
  it_notes text, processed_by uuid references public.profiles(id), processed_at timestamptz,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create table if not exists public.branch_customer_counters (
  id uuid primary key default gen_random_uuid(), branch_id uuid not null unique references public.branches(id),
  last_customer_code text check (last_customer_code is null or last_customer_code ~ '^C[0-9]{6,}$'),
  last_updated_by uuid references public.profiles(id), last_updated_at timestamptz, created_at timestamptz not null default now()
);

create table if not exists public.branch_customer_counter_logs (
  id uuid primary key default gen_random_uuid(), branch_id uuid not null references public.branches(id),
  old_customer_code text, new_customer_code text not null, changed_by uuid not null references public.profiles(id),
  change_reason text not null, created_at timestamptz not null default now()
);

create table if not exists public.noo_activity_logs (
  id uuid primary key default gen_random_uuid(), user_id uuid references public.profiles(id), action text not null,
  entity_type text not null, entity_id uuid, old_value jsonb, new_value jsonb, created_at timestamptz not null default now()
);

create table if not exists public.noo_export_logs (
  id uuid primary key default gen_random_uuid(), exported_by uuid not null references public.profiles(id),
  branch_id uuid references public.branches(id), outlet_count integer not null, format text not null,
  header_hash text, created_at timestamptz not null default now()
);

insert into public.branches (workplace_code, branch_name) values
('002','BANJARMASIN'),('004','BANJARBARU'),('009','RANTAU'),('019','KANDANGAN'),('008','BARABAI'),('010','AMUNTAI'),('011','TANJUNG'),('013','AMPAH'),('020','BUNTOK'),('012','MUARA TEWEH'),('023','PURUK CAHU'),('005','PELAIHARI'),('006','SUNGAI DANAU'),('007','BATULICIN'),('015','KAPUAS'),('016','PULANG PISAU'),('014','PALANGKA RAYA'),('026','TIMPAH'),('025','SEBABI'),('021','KERENG PANGI'),('022','KUALA KURUN'),('018','PANGKALAN BUN'),('024','LAMANDAU'),('017','SAMPIT')
on conflict (workplace_code) do update set branch_name = excluded.branch_name;

create index if not exists noo_outlets_status_idx on public.noo_outlets(status);
create index if not exists noo_batches_branch_idx on public.noo_batches(branch_id, created_at desc);
create index if not exists noo_activity_entity_idx on public.noo_activity_logs(entity_type, entity_id, created_at desc);

insert into storage.buckets (id, name, public) values ('noo-private','noo-private',false) on conflict (id) do nothing;

alter table public.profiles enable row level security;
alter table public.branches enable row level security;
alter table public.salesmen enable row level security;
alter table public.approval_mappings enable row level security;
alter table public.noo_batches enable row level security;
alter table public.noo_outlets enable row level security;
alter table public.noo_attachments enable row level security;
alter table public.noo_approvals enable row level security;
alter table public.noo_activity_logs enable row level security;
alter table public.noo_outlet_revision_logs enable row level security;

create or replace function public.noo_is_admin() returns boolean language sql stable security definer set search_path=public as $$ select exists(select 1 from profiles where id=auth.uid() and role='ADMIN' and is_active) $$;
create or replace function public.noo_has_role(r public.noo_role) returns boolean language sql stable security definer set search_path=public as $$ select exists(select 1 from profiles where id=auth.uid() and role=r and is_active) $$;

create policy "noo profiles self or admin" on public.profiles for select using (id=auth.uid() or public.noo_is_admin());
create policy "noo master authenticated read" on public.branches for select using (auth.uid() is not null);
create policy "noo salesmen authenticated read" on public.salesmen for select using (auth.uid() is not null);
create policy "noo admin manages branches" on public.branches for all using (public.noo_is_admin()) with check (public.noo_is_admin());
create policy "noo admin manages salesmen" on public.salesmen for all using (public.noo_is_admin() or public.noo_has_role('SALES_MANAGER')) with check (public.noo_is_admin() or public.noo_has_role('SALES_MANAGER'));
create policy "noo batch scoped read" on public.noo_batches for select using (public.noo_is_admin() or supervisor_id=auth.uid() or public.noo_has_role('IT') or exists(select 1 from approval_mappings am where am.approver_id=auth.uid() and am.branch_id=noo_batches.branch_id and am.is_active));
create policy "noo supervisor creates batch" on public.noo_batches for insert with check (supervisor_id=auth.uid() and public.noo_has_role('SUPERVISOR_SALES'));
create policy "noo outlet scoped read" on public.noo_outlets for select using (public.noo_is_admin() or public.noo_has_role('IT') or exists(select 1 from noo_batches b where b.id=batch_id and (b.supervisor_id=auth.uid() or exists(select 1 from approval_mappings am where am.approver_id=auth.uid() and am.branch_id=b.branch_id and am.is_active))));
create policy "noo private storage access" on storage.objects for select using (bucket_id='noo-private' and auth.uid() is not null);
create policy "noo private storage upload" on storage.objects for insert with check (bucket_id='noo-private' and auth.uid() is not null);

create policy "noo approval scoped read" on public.noo_approvals for select using (public.noo_is_admin() or reviewer_id=auth.uid() or public.noo_has_role('SUPERVISOR_SALES'));
create policy "noo audit admin read" on public.noo_activity_logs for select using (public.noo_is_admin());
create policy "noo revision scoped read" on public.noo_outlet_revision_logs for select using (public.noo_is_admin() or public.noo_has_role('SUPERVISOR_SALES'));
create policy "noo counters IT admin read" on public.branch_customer_counters for select using (public.noo_is_admin() or public.noo_has_role('IT'));
create policy "noo counter logs IT admin read" on public.branch_customer_counter_logs for select using (public.noo_is_admin() or public.noo_has_role('IT'));
create policy "noo bosnet IT admin access" on public.noo_bosnet_data for all using (public.noo_is_admin() or public.noo_has_role('IT')) with check (public.noo_is_admin() or public.noo_has_role('IT'));

create or replace function public.noo_record_approval(p_outlet_id uuid, p_decision public.noo_decision, p_notes text, p_credit_limit numeric, p_data_version integer)
returns public.noo_approvals language plpgsql security definer set search_path=public as $$
declare v_role public.noo_role; v_outlet public.noo_outlets; v_approval public.noo_approvals;
begin
  select role into v_role from profiles where id=auth.uid() and is_active;
  if v_role not in ('SALES_MANAGER','GENERAL_MANAGER') then raise exception 'Tidak berwenang melakukan approval'; end if;
  if p_decision <> 'APPROVED' and nullif(trim(p_notes),'') is null then raise exception 'Catatan wajib'; end if;
  select * into v_outlet from noo_outlets where id=p_outlet_id for update;
  if not found then raise exception 'Outlet tidak ditemukan'; end if;
  if v_role='GENERAL_MANAGER' and p_credit_limit is not null and p_credit_limit > v_outlet.requested_credit_limit then raise exception 'Limit GM tidak boleh melebihi pengajuan'; end if;
  insert into noo_approvals(outlet_id,reviewer_id,reviewer_role,decision,notes,data_version) values(p_outlet_id,auth.uid(),v_role,p_decision,p_notes,p_data_version) returning * into v_approval;
  update noo_outlets set status=case when v_role='SALES_MANAGER' and p_decision='APPROVED' then 'GM_REVIEW'::noo_outlet_status when v_role='SALES_MANAGER' and p_decision='REVISION' then 'SM_REVISION'::noo_outlet_status when v_role='SALES_MANAGER' then 'SM_REJECTED'::noo_outlet_status when p_decision='APPROVED' then 'WAITING_IT'::noo_outlet_status when p_decision='REVISION' then 'GM_REVISION'::noo_outlet_status else 'GM_REJECTED'::noo_outlet_status end, sales_manager_credit_limit=case when v_role='SALES_MANAGER' then coalesce(p_credit_limit,sales_manager_credit_limit) else sales_manager_credit_limit end, approved_credit_limit=case when v_role='GENERAL_MANAGER' and p_decision='APPROVED' then coalesce(p_credit_limit,requested_credit_limit) else approved_credit_limit end, updated_at=now() where id=p_outlet_id;
  insert into noo_activity_logs(user_id,action,entity_type,entity_id,new_value) values(auth.uid(),'APPROVAL','noo_outlets',p_outlet_id,jsonb_build_object('decision',p_decision,'notes',p_notes,'data_version',p_data_version));
  return v_approval;
end; $$;

revoke all on function public.noo_record_approval(uuid, public.noo_decision, text, numeric, integer) from public;
grant execute on function public.noo_record_approval(uuid, public.noo_decision, text, numeric, integer) to authenticated;

