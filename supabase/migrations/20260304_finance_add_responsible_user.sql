-- ============================================================
-- Migración: Agregar usuario responsable a movimientos financieros
-- Fecha: 2026-03-04
-- Descripción: Agrega la relación con el usuario responsable
--              de cada movimiento financiero para rendición de cuentas.
-- ============================================================

-- 1. Agregar columna responsible_user_id a finance_records
ALTER TABLE public.finance_records
  ADD COLUMN responsible_user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL;

COMMENT ON COLUMN public.finance_records.responsible_user_id
  IS 'Usuario responsable del movimiento financiero (rendición de cuentas)';

-- 2. Índice para búsquedas por responsable
CREATE INDEX idx_finance_records_responsible_user
  ON public.finance_records (responsible_user_id)
  WHERE responsible_user_id IS NOT NULL;
