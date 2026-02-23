-- ============================================================
-- Migración: Trips → origin/destination como FK a client_locations
-- ============================================================
-- Ejecutar DESPUÉS de supabase_migration_client_locations.sql
-- ============================================================

-- 1. Eliminar viajes existentes que usan columnas antiguas de texto.
--    (Si necesitas preservar datos, migra manualmente ANTES de ejecutar esto.)
DELETE FROM trips;

-- 2. Eliminar columnas antiguas de texto
ALTER TABLE trips DROP COLUMN IF EXISTS origin;
ALTER TABLE trips DROP COLUMN IF EXISTS destination;

-- 3. Agregar nuevas columnas FK (NOT NULL)
ALTER TABLE trips
  ADD COLUMN IF NOT EXISTS origin_location_id UUID NOT NULL
    REFERENCES client_locations(id) ON DELETE RESTRICT,
  ADD COLUMN IF NOT EXISTS destination_location_id UUID NOT NULL
    REFERENCES client_locations(id) ON DELETE RESTRICT;

-- 4. Índices para las nuevas columnas FK
CREATE INDEX IF NOT EXISTS idx_trips_origin_location_id
  ON trips(origin_location_id);

CREATE INDEX IF NOT EXISTS idx_trips_destination_location_id
  ON trips(destination_location_id);

-- 5. Las políticas RLS existentes de trips siguen vigentes,
--    ya que las columnas nuevas son FKs simples y no afectan
--    la lógica de permisos company_id-based.
