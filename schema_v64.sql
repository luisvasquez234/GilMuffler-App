-- v64: segundo impuesto (el taller tiene dos máquinas de tarjeta que cobran
-- distinto). Vacío = no hay segundo impuesto.

alter table configuracion_negocio add column if not exists tasa_impuesto_2 numeric(5,2);

notify pgrst, 'reload schema';
