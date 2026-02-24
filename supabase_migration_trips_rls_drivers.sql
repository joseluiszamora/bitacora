-- ============================================================
-- MIGRACIÓN: Actualizar RLS de trips para supervisors y drivers
-- Ejecutar en Supabase SQL Editor.
-- ============================================================

-- Eliminar la política SELECT anterior
DROP POLICY IF EXISTS "trips_select_policy" ON trips;

-- Nueva política SELECT: incluye supervisor y driver
-- - super_admin: ve todos los viajes
-- - admin: ve los viajes de su empresa
-- - supervisor: ve los viajes de su empresa
-- - driver: ve los viajes de vehículos asignados a él
CREATE POLICY "trips_select_policy" ON trips
  FOR SELECT
  USING (
    get_my_role() = 'super_admin'
    OR (
      get_my_role() IN ('admin', 'supervisor')
      AND company_id = get_my_company_id()
    )
    OR (
      get_my_role() = 'driver'
      AND vehicle_id IN (
        SELECT vehicle_id
        FROM vehicle_assignments
        WHERE driver_id = auth.uid()
          AND is_active = true
      )
    )
  );
