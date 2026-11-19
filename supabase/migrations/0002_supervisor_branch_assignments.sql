create table if not exists public.noo_supervisor_branches (
  supervisor_id uuid not null references public.profiles(id) on delete cascade,
  branch_id uuid not null references public.branches(id) on delete cascade,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  primary key (supervisor_id, branch_id)
);
create index if not exists noo_supervisor_branches_branch_idx on public.noo_supervisor_branches(branch_id);
alter table public.noo_supervisor_branches enable row level security;
grant select on public.noo_supervisor_branches to service_role;
