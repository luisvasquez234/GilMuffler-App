-- v63: segundo precio por pieza para clientes dealer (lotes de carros / otros
-- talleres). Vacío = esa pieza no tiene precio especial de dealer.

alter table piezas add column if not exists precio_dealer numeric(10,2);

notify pgrst, 'reload schema';
