-- ============================================================
-- MIGRACIÓN: VEHICLES & VEHICLE_DOCUMENTS
-- Ejecutar en Supabase SQL Editor
-- ============================================================

-- 1. Crear enum de estado de vehículo
DO $$ BEGIN
  CREATE TYPE vehicle_status AS ENUM ('active', 'maintenance', 'inactive');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- 2. Crear enum de tipo de documento de vehículo
DO $$ BEGIN
  CREATE TYPE vehicle_document_type AS ENUM ('soat', 'inspection', 'insurance', 'ruat');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- 3. Tabla vehicles
CREATE TABLE IF NOT EXISTS vehicles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  plate_number TEXT NOT NULL,
  brand TEXT,
  model TEXT,
  year INTEGER,
  color TEXT,
  avatar_url TEXT,
  chasis_code TEXT,
  motor_code TEXT,
  ruat_number TEXT,
  soat_expiration_date DATE,
  inspection_expiration_date DATE,
  insurance_expiration_date DATE,
  status vehicle_status NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT now(),

  -- Restricciones
  CONSTRAINT vehicles_plate_number_unique UNIQUE (plate_number)
);

-- 4. Tabla vehicle_documents
CREATE TABLE IF NOT EXISTS vehicle_documents (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
  type vehicle_document_type NOT NULL,
  file_url TEXT,
  expiration_date DATE,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 5. Índices
CREATE INDEX IF NOT EXISTS idx_vehicles_company_id ON vehicles(company_id);
CREATE INDEX IF NOT EXISTS idx_vehicles_plate_number ON vehicles(plate_number);
CREATE INDEX IF NOT EXISTS idx_vehicles_status ON vehicles(status);
CREATE INDEX IF NOT EXISTS idx_vehicle_documents_vehicle_id ON vehicle_documents(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_vehicle_documents_type ON vehicle_documents(type);

-- 6. Habilitar RLS
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicle_documents ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- RLS POLICIES PARA vehicles
-- ============================================================

-- super_admin: puede ver todos los vehículos
CREATE POLICY vehicles_select_super_admin ON vehicles
  FOR SELECT
  TO authenticated
  USING (
    (SELECT get_my_role()) = 'super_admin'
  );

-- admin: puede ver vehículos de su empresa
CREATE POLICY vehicles_select_admin ON vehicles
  FOR SELECT
  TO authenticated
  USING (
    (SELECT get_my_role()) = 'admin'
    AND company_id = (SELECT get_my_company_id())
  );

-- super_admin: puede insertar vehículos
CREATE POLICY vehicles_insert_super_admin ON vehicles
  FOR INSERT
  TO authenticated
  WITH CHECK (
    (SELECT get_my_role()) = 'super_admin'
  );

-- admin: puede insertar vehículos en su empresa
CREATE POLICY vehicles_insert_admin ON vehicles
  FOR INSERT
  TO authenticated
  WITH CHECK (
    (SELECT get_my_role()) = 'admin'
    AND company_id = (SELECT get_my_company_id())
  );

-- super_admin: puede actualizar cualquier vehículo
CREATE POLICY vehicles_update_super_admin ON vehicles
  FOR UPDATE
  TO authenticated
  USING (
    (SELECT get_my_role()) = 'super_admin'
  )
  WITH CHECK (
    (SELECT get_my_role()) = 'super_admin'
  );

-- admin: puede actualizar vehículos de su empresa
CREATE POLICY vehicles_update_admin ON vehicles
  FOR UPDATE
  TO authenticated
  USING (
    (SELECT get_my_role()) = 'admin'
    AND company_id = (SELECT get_my_company_id())
  )
  WITH CHECK (
    (SELECT get_my_role()) = 'admin'
    AND company_id = (SELECT get_my_company_id())
  );

-- super_admin: puede eliminar cualquier vehículo
CREATE POLICY vehicles_delete_super_admin ON vehicles
  FOR DELETE
  TO authenticated
  USING (
    (SELECT get_my_role()) = 'super_admin'
  );

-- admin: puede eliminar vehículos de su empresa
CREATE POLICY vehicles_delete_admin ON vehicles
  FOR DELETE
  TO authenticated
  USING (
    (SELECT get_my_role()) = 'admin'
    AND company_id = (SELECT get_my_company_id())
  );

-- ============================================================
-- RLS POLICIES PARA vehicle_documents
-- ============================================================

-- super_admin: puede ver todos los documentos
CREATE POLICY vehicle_documents_select_super_admin ON vehicle_documents
  FOR SELECT
  TO authenticated
  USING (
    (SELECT get_my_role()) = 'super_admin'
  );

-- admin: puede ver documentos de vehículos de su empresa
CREATE POLICY vehicle_documents_select_admin ON vehicle_documents
  FOR SELECT
  TO authenticated
  USING (
    (SELECT get_my_role()) = 'admin'
    AND vehicle_id IN (
      SELECT id FROM vehicles WHERE company_id = (SELECT get_my_company_id())
    )
  );

-- super_admin: puede insertar documentos
CREATE POLICY vehicle_documents_insert_super_admin ON vehicle_documents
  FOR INSERT
  TO authenticated
  WITH CHECK (
    (SELECT get_my_role()) = 'super_admin'
  );

-- admin: puede insertar documentos en vehículos de su empresa
CREATE POLICY vehicle_documents_insert_admin ON vehicle_documents
  FOR INSERT
  TO authenticated
  WITH CHECK (
    (SELECT get_my_role()) = 'admin'
    AND vehicle_id IN (
      SELECT id FROM vehicles WHERE company_id = (SELECT get_my_company_id())
    )
  );

-- super_admin: puede actualizar documentos
CREATE POLICY vehicle_documents_update_super_admin ON vehicle_documents
  FOR UPDATE
  TO authenticated
  USING (
    (SELECT get_my_role()) = 'super_admin'
  )
  WITH CHECK (
    (SELECT get_my_role()) = 'super_admin'
  );

-- admin: puede actualizar documentos de vehículos de su empresa
CREATE POLICY vehicle_documents_update_admin ON vehicle_documents
  FOR UPDATE
  TO authenticated
  USING (
    (SELECT get_my_role()) = 'admin'
    AND vehicle_id IN (
      SELECT id FROM vehicles WHERE company_id = (SELECT get_my_company_id())
    )
  )
  WITH CHECK (
    (SELECT get_my_role()) = 'admin'
    AND vehicle_id IN (
      SELECT id FROM vehicles WHERE company_id = (SELECT get_my_company_id())
    )
  );

-- super_admin: puede eliminar documentos
CREATE POLICY vehicle_documents_delete_super_admin ON vehicle_documents
  FOR DELETE
  TO authenticated
  USING (
    (SELECT get_my_role()) = 'super_admin'
  );

-- admin: puede eliminar documentos de vehículos de su empresa
CREATE POLICY vehicle_documents_delete_admin ON vehicle_documents
  FOR DELETE
  TO authenticated
  USING (
    (SELECT get_my_role()) = 'admin'
    AND vehicle_id IN (
      SELECT id FROM vehicles WHERE company_id = (SELECT get_my_company_id())
    )
  );
