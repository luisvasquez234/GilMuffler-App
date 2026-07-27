-- Agrega un número de cliente (Client ID) secuencial y el VIN del vehículo.
-- Seguro de correr más de una vez.
-- Copia y pega en Supabase: SQL Editor -> New query -> Run.

create sequence if not exists clientes_numero_seq;
alter table clientes add column if not exists numero bigint;
alter table clientes alter column numero set default nextval('clientes_numero_seq');
alter sequence clientes_numero_seq owned by clientes.numero;
update clientes set numero = nextval('clientes_numero_seq') where numero is null;
alter table clientes alter column numero set not null;

alter table vehiculos add column if not exists vin text;

notify pgrst, 'reload schema';
