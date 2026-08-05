-- Soporte de esquema para: garantía global de piezas, vincular filas del
-- registro diario a una factura real, cerrar un día del registro diario,
-- firma digital al recoger el vehículo, y foto de la hoja de papel como
-- respaldo del registro diario.
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

-- Garantía global de piezas (calculadora de garantía)
alter table configuracion_negocio add column if not exists garantia_dias integer not null default 90;

-- Vincular una fila del registro diario a una factura real
alter table registro_diario_items add column if not exists factura_id uuid references facturas(id);

-- Cerrar un día ya guardado del registro diario
alter table registro_diario add column if not exists cerrado boolean not null default false;
alter table registro_diario add column if not exists cerrado_en timestamptz;

-- Firma digital al recoger el vehículo (reusa el bucket fotos-ordenes existente)
alter table ordenes_servicio add column if not exists firma_entrega_url text;
alter table ordenes_servicio add column if not exists firma_entrega_nombre text;
alter table ordenes_servicio add column if not exists firma_entrega_fecha timestamptz;

-- Foto de la hoja de papel como respaldo del registro diario (una foto por día)
insert into storage.buckets (id, name, public)
values ('fotos-registro-diario', 'fotos-registro-diario', true)
on conflict (id) do nothing;

drop policy if exists "lectura_publica_fotos_registro_diario" on storage.objects;
create policy "lectura_publica_fotos_registro_diario" on storage.objects
  for select using (bucket_id = 'fotos-registro-diario');

drop policy if exists "subir_fotos_registro_diario_autenticado" on storage.objects;
create policy "subir_fotos_registro_diario_autenticado" on storage.objects
  for insert with check (bucket_id = 'fotos-registro-diario' and auth.role() = 'authenticated');

drop policy if exists "eliminar_fotos_registro_diario_autenticado" on storage.objects;
create policy "eliminar_fotos_registro_diario_autenticado" on storage.objects
  for delete using (bucket_id = 'fotos-registro-diario' and auth.role() = 'authenticated');

alter table registro_diario add column if not exists foto_hoja_url text;
alter table registro_diario add column if not exists foto_hoja_storage_path text;

notify pgrst, 'reload schema';
