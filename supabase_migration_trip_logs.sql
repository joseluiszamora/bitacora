-- ============================================================
-- Migración: trip_logs + trip_log_media
-- ============================================================

-- 1. Tabla de logs de viaje
CREATE TABLE IF NOT EXISTS trip_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id UUID NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  driver_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  event_type TEXT NOT NULL DEFAULT 'ASSIGNED',
  description TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Tabla de media asociados a un log
CREATE TABLE IF NOT EXISTS trip_log_media (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_log_id UUID NOT NULL REFERENCES trip_logs(id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'PHOTO',
  caption TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Índices
CREATE INDEX IF NOT EXISTS idx_trip_logs_trip_id ON trip_logs(trip_id);
CREATE INDEX IF NOT EXISTS idx_trip_logs_user_id ON trip_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_trip_logs_driver_id ON trip_logs(driver_id);
CREATE INDEX IF NOT EXISTS idx_trip_logs_event_type ON trip_logs(event_type);
CREATE INDEX IF NOT EXISTS idx_trip_logs_created_at ON trip_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_trip_log_media_trip_log_id ON trip_log_media(trip_log_id);

-- 4. RLS — trip_logs
ALTER TABLE trip_logs ENABLE ROW LEVEL SECURITY;

-- Lectura: admin, supervisor y driver de la misma empresa
CREATE POLICY "trip_logs_select_policy" ON trip_logs
  FOR SELECT USING (
    get_my_role() IN ('super_admin', 'admin', 'supervisor', 'driver')
  );

-- Inserción: admin, supervisor y driver
CREATE POLICY "trip_logs_insert_policy" ON trip_logs
  FOR INSERT WITH CHECK (
    get_my_role() IN ('super_admin', 'admin', 'supervisor', 'driver')
  );

-- Actualización: admin y supervisor
CREATE POLICY "trip_logs_update_policy" ON trip_logs
  FOR UPDATE USING (
    get_my_role() IN ('super_admin', 'admin', 'supervisor')
  );

-- Eliminación: admin y supervisor
CREATE POLICY "trip_logs_delete_policy" ON trip_logs
  FOR DELETE USING (
    get_my_role() IN ('super_admin', 'admin', 'supervisor')
  );

-- 5. RLS — trip_log_media
ALTER TABLE trip_log_media ENABLE ROW LEVEL SECURITY;

CREATE POLICY "trip_log_media_select_policy" ON trip_log_media
  FOR SELECT USING (
    get_my_role() IN ('super_admin', 'admin', 'supervisor', 'driver')
  );

CREATE POLICY "trip_log_media_insert_policy" ON trip_log_media
  FOR INSERT WITH CHECK (
    get_my_role() IN ('super_admin', 'admin', 'supervisor', 'driver')
  );

CREATE POLICY "trip_log_media_delete_policy" ON trip_log_media
  FOR DELETE USING (
    get_my_role() IN ('super_admin', 'admin', 'supervisor')
  );
