-- ============================================================
-- MIGRACIÓN: vehicle_assignments (relación muchos-a-muchos)
-- Tabla pivote para asignar conductores a vehículos.
-- ============================================================

-- 1. Crear tabla
CREATE TABLE IF NOT EXISTS vehicle_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
  driver_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  assigned_by_user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  start_date DATE NOT NULL DEFAULT CURRENT_DATE,
  end_date DATE,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Índices
CREATE INDEX IF NOT EXISTS idx_va_vehicle_id ON vehicle_assignments(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_va_driver_id ON vehicle_assignments(driver_id);
CREATE INDEX IF NOT EXISTS idx_va_assigned_by ON vehicle_assignments(assigned_by_user_id);
CREATE INDEX IF NOT EXISTS idx_va_is_active ON vehicle_assignments(is_active);
-- Índice único: solo una asignación activa por conductor-vehículo
CREATE UNIQUE INDEX IF NOT EXISTS idx_va_active_unique
  ON vehicle_assignments(vehicle_id, driver_id)
  WHERE is_active = true;

-- 3. Habilitar RLS
ALTER TABLE vehicle_assignments ENABLE ROW LEVEL SECURITY;

-- 4. Políticas RLS
-- super_admin: todo
CREATE POLICY va_superadmin_all ON vehicle_assignments
  FOR ALL
  USING (get_my_role() = 'super_admin')
  WITH CHECK (get_my_role() = 'super_admin');

-- admin: solo asignaciones de vehículos de su compañía
CREATE POLICY va_admin_select ON vehicle_assignments
  FOR SELECT
  USING (
    get_my_role() = 'admin'
    AND vehicle_id IN (
      SELECT id FROM vehicles WHERE company_id = get_my_company_id()
    )
  );

CREATE POLICY va_admin_insert ON vehicle_assignments
  FOR INSERT
  WITH CHECK (
    get_my_role() = 'admin'
    AND vehicle_id IN (
      SELECT id FROM vehicles WHERE company_id = get_my_company_id()
    )
  );

CREATE POLICY va_admin_update ON vehicle_assignments
  FOR UPDATE
  USING (
    get_my_role() = 'admin'
    AND vehicle_id IN (
      SELECT id FROM vehicles WHERE company_id = get_my_company_id()
    )
  )
  WITH CHECK (
    get_my_role() = 'admin'
    AND vehicle_id IN (
      SELECT id FROM vehicles WHERE company_id = get_my_company_id()
    )
  );

CREATE POLICY va_admin_delete ON vehicle_assignments
  FOR DELETE
  USING (
    get_my_role() = 'admin'
    AND vehicle_id IN (
      SELECT id FROM vehicles WHERE company_id = get_my_company_id()
    )
  );

-- supervisor: solo lectura de asignaciones de su compañía
CREATE POLICY va_supervisor_select ON vehicle_assignments
  FOR SELECT
  USING (
    get_my_role() = 'supervisor'
    AND vehicle_id IN (
      SELECT id FROM vehicles WHERE company_id = get_my_company_id()
    )
  );

-- driver: solo puede ver sus propias asignaciones
CREATE POLICY va_driver_select ON vehicle_assignments
  FOR SELECT
  USING (
    get_my_role() = 'driver'
    AND driver_id = auth.uid()
  );

-- 5. Comentarios
COMMENT ON TABLE vehicle_assignments IS 'Asignaciones de conductores a vehículos (muchos a muchos)';
COMMENT ON COLUMN vehicle_assignments.vehicle_id IS 'Vehículo asignado';
COMMENT ON COLUMN vehicle_assignments.driver_id IS 'Conductor asignado';
COMMENT ON COLUMN vehicle_assignments.assigned_by_user_id IS 'Usuario que realizó la asignación';
COMMENT ON COLUMN vehicle_assignments.start_date IS 'Fecha de inicio de la asignación';
COMMENT ON COLUMN vehicle_assignments.end_date IS 'Fecha de finalización (NULL = aún activa)';
COMMENT ON COLUMN vehicle_assignments.is_active IS 'Si la asignación está vigente';
