-- ============================================================
-- MIGRACIÓN: Tabla trips (viajes)
-- Ejecutar en Supabase SQL Editor en orden.
-- ============================================================

-- ─── 1. Tipo ENUM para el estado del viaje ──────────────────
DO $$ BEGIN
  CREATE TYPE trip_status AS ENUM (
    'pending',
    'in_progress',
    'completed',
    'cancelled'
  );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ─── 2. Tabla trips ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS trips (
  id            uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  company_id    uuid NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  client_company_id uuid NOT NULL REFERENCES client_companies(id) ON DELETE CASCADE,
  vehicle_id    uuid NOT NULL REFERENCES vehicles(id) ON DELETE RESTRICT,
  assigned_by_user_id uuid REFERENCES profiles(id) ON DELETE SET NULL,
  origin        text NOT NULL,
  destination   text NOT NULL,
  departure_time timestamptz,
  arrival_time   timestamptz,
  status        trip_status NOT NULL DEFAULT 'pending',
  price         numeric(12,2),
  created_at    timestamptz DEFAULT now(),
  updated_at    timestamptz DEFAULT now()
);

-- Índices para mejorar las queries de filtrado
CREATE INDEX IF NOT EXISTS idx_trips_company_id ON trips(company_id);
CREATE INDEX IF NOT EXISTS idx_trips_client_company_id ON trips(client_company_id);
CREATE INDEX IF NOT EXISTS idx_trips_vehicle_id ON trips(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_trips_status ON trips(status);

-- Trigger para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_trips_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_trips_updated_at ON trips;
CREATE TRIGGER trigger_trips_updated_at
  BEFORE UPDATE ON trips
  FOR EACH ROW
  EXECUTE FUNCTION update_trips_updated_at();

-- ─── 3. Habilitar RLS ──────────────────────────────────────
ALTER TABLE trips ENABLE ROW LEVEL SECURITY;

-- ─── 4. Políticas RLS ──────────────────────────────────────
-- Las políticas usan las funciones SECURITY DEFINER existentes:
--   get_my_role()
--   get_my_company_id()

-- SELECT: super_admin ve todos, admin ve los de su empresa
DROP POLICY IF EXISTS "trips_select_policy" ON trips;
CREATE POLICY "trips_select_policy" ON trips
  FOR SELECT
  USING (
    get_my_role() = 'super_admin'
    OR (
      get_my_role() = 'admin'
      AND company_id = get_my_company_id()
    )
  );

-- INSERT: super_admin y admin pueden crear viajes
DROP POLICY IF EXISTS "trips_insert_policy" ON trips;
CREATE POLICY "trips_insert_policy" ON trips
  FOR INSERT
  WITH CHECK (
    get_my_role() = 'super_admin'
    OR (
      get_my_role() = 'admin'
      AND company_id = get_my_company_id()
    )
  );

-- UPDATE: super_admin y admin pueden actualizar viajes
DROP POLICY IF EXISTS "trips_update_policy" ON trips;
CREATE POLICY "trips_update_policy" ON trips
  FOR UPDATE
  USING (
    get_my_role() = 'super_admin'
    OR (
      get_my_role() = 'admin'
      AND company_id = get_my_company_id()
    )
  )
  WITH CHECK (
    get_my_role() = 'super_admin'
    OR (
      get_my_role() = 'admin'
      AND company_id = get_my_company_id()
    )
  );

-- DELETE: super_admin y admin pueden eliminar viajes
DROP POLICY IF EXISTS "trips_delete_policy" ON trips;
CREATE POLICY "trips_delete_policy" ON trips
  FOR DELETE
  USING (
    get_my_role() = 'super_admin'
    OR (
      get_my_role() = 'admin'
      AND company_id = get_my_company_id()
    )
  );
