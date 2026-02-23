-- ============================================================
-- MIGRACIÓN: Eliminar driver_id de la tabla trips
-- El viaje solo se asigna al vehículo, no al conductor.
-- Ejecutar en Supabase SQL Editor.
-- ============================================================

-- 1. Eliminar la política SELECT que referencia driver_id (ANTES de eliminar la columna)
DROP POLICY IF EXISTS "trips_select_policy" ON trips;

-- 2. Eliminar el índice de driver_id
DROP INDEX IF EXISTS idx_trips_driver_id;

-- 3. Eliminar la columna driver_id
ALTER TABLE trips DROP COLUMN IF EXISTS driver_id;

-- 4. Recrear la política SELECT sin la condición del driver
CREATE POLICY "trips_select_policy" ON trips
  FOR SELECT
  USING (
    get_my_role() = 'super_admin'
    OR (
      get_my_role() = 'admin'
      AND company_id = get_my_company_id()
    )
  );
