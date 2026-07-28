-- Estimates (presupuestos): documentos separados de la factura que el
-- cliente puede aprobar/rechazar desde un link público, antes de
-- convertirse en una factura real.
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

create table if not exists estimados (
  id uuid primary key default gen_random_uuid(),
  numero bigserial not null,
  cliente_id uuid not null references clientes(id) on delete restrict,
  fecha date not null default current_date,
  estado text not null default 'pendiente'
    check (estado in ('pendiente','aprobado','rechazado','convertido')),
  subtotal numeric(10,2) not null default 0,
  impuesto numeric(10,2) not null default 0,
  total numeric(10,2) not null default 0,
  notas text,
  factura_id uuid references facturas(id),
  created_at timestamptz not null default now()
);

create table if not exists estimado_items (
  id uuid primary key default gen_random_uuid(),
  estimado_id uuid not null references estimados(id) on delete cascade,
  descripcion text not null,
  cantidad numeric(10,2) not null default 1,
  precio_unitario numeric(10,2) not null default 0,
  subtotal numeric(10,2) not null default 0,
  orden int not null default 0
);

alter table estimados enable row level security;
drop policy if exists "acceso_compartido_estimados" on estimados;
create policy "acceso_compartido_estimados" on estimados for all using (true) with check (true);

alter table estimado_items enable row level security;
drop policy if exists "acceso_compartido_estimado_items" on estimado_items;
create policy "acceso_compartido_estimado_items" on estimado_items for all using (true) with check (true);

create index if not exists idx_estimado_items_estimado_id on estimado_items (estimado_id);

notify pgrst, 'reload schema';
