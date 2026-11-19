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

insert into public.noo_supervisor_branches (supervisor_id, branch_id)
select p.id, b.id
from (values
  ('winda', '002'),
  ('harir', '005'),('harir', '006'),('harir', '007'),
  ('dodi', '009'),('dodi', '019'),('dodi', '008'),('dodi', '010'),
  ('kahar', '011'),('kahar', '013'),('kahar', '020'),('kahar', '012'),('kahar', '023'),
  ('yudi', '015'),('yudi', '016'),('yudi', '014'),('yudi', '026'),('yudi', '022'),('yudi', '021'),
  ('ziad', '017'),('ziad', '025'),
  ('yuli', '018'),('yuli', '024')
) as x(supervisor_name, workplace_code)
join public.profiles p on lower(coalesce(p.full_name,'')) like '%' || x.supervisor_name || '%' and p.role = 'SUPERVISOR_SALES'
join public.branches b on b.workplace_code = x.workplace_code
on conflict (supervisor_id, branch_id) do update set is_active = true;
