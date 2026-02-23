-- ============================================================
-- Migración: states + cities + client_locations
-- Descripción: Tabla de estados, ciudades y ubicaciones de empresas clientes
-- ============================================================

-- 0a. Tabla states (departamentos/estados)
CREATE TABLE IF NOT EXISTS states (
  id           SERIAL PRIMARY KEY,
  name         VARCHAR(150) NOT NULL,
  code         VARCHAR(10),
  country_code VARCHAR(5) NOT NULL DEFAULT 'BO',
  CONSTRAINT unique_state_per_country UNIQUE (name, country_code)
);

CREATE INDEX IF NOT EXISTS idx_states_country_code ON states(country_code);

-- 0b. Tabla cities
CREATE TABLE IF NOT EXISTS cities (
  id        UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name      VARCHAR(150) NOT NULL,
  state_id  INT REFERENCES states(id) ON DELETE SET NULL,
  latitude  DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  CONSTRAINT unique_city_per_state UNIQUE (name, state_id)
);

CREATE INDEX IF NOT EXISTS idx_cities_state ON cities(state_id);

-- 1. Tipo enum para tipo de ubicación
CREATE TYPE client_location_type AS ENUM (
  'WAREHOUSE',
  'DISTRIBUTION_CENTER',
  'OFFICE',
  'PLANT'
);

-- 2. Tipo enum para estado de ubicación
CREATE TYPE client_location_status AS ENUM (
  'ACTIVE',
  'INACTIVE'
);

-- 3. Tabla client_locations
CREATE TABLE client_locations (
  id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  client_company_id UUID NOT NULL REFERENCES client_companies(id) ON DELETE CASCADE,
  name          TEXT NOT NULL,
  type          client_location_type NOT NULL DEFAULT 'WAREHOUSE',
  address       TEXT,
  city_id       UUID REFERENCES cities(id) ON DELETE SET NULL,
  country       TEXT NOT NULL DEFAULT 'Bolivia',
  latitude      DOUBLE PRECISION,
  longitude     DOUBLE PRECISION,
  contact_name  TEXT,
  contact_phone TEXT,
  status        client_location_status NOT NULL DEFAULT 'ACTIVE',
  created_at    TIMESTAMPTZ DEFAULT now()
);

-- 4. Índices
CREATE INDEX idx_client_locations_client_company ON client_locations(client_company_id);
CREATE INDEX idx_client_locations_city           ON client_locations(city_id);
CREATE INDEX idx_client_locations_status         ON client_locations(status);
CREATE INDEX idx_client_locations_type           ON client_locations(type);

-- 5. Habilitar RLS
ALTER TABLE client_locations ENABLE ROW LEVEL SECURITY;

-- 6. Políticas RLS

-- super_admin: acceso total
CREATE POLICY "super_admin_all_client_locations"
  ON client_locations
  FOR ALL
  TO authenticated
  USING (get_my_role() = 'super_admin')
  WITH CHECK (get_my_role() = 'super_admin');

-- admin: acceso a ubicaciones de empresas cliente vinculadas a su compañía
CREATE POLICY "admin_select_client_locations"
  ON client_locations
  FOR SELECT
  TO authenticated
  USING (
    get_my_role() = 'admin'
    AND client_company_id IN (
      SELECT cc.id FROM client_companies cc
      JOIN company_clients ccl ON ccl.client_company_id = cc.id
      WHERE ccl.company_id = get_my_company_id()
    )
  );

CREATE POLICY "admin_insert_client_locations"
  ON client_locations
  FOR INSERT
  TO authenticated
  WITH CHECK (
    get_my_role() = 'admin'
    AND client_company_id IN (
      SELECT cc.id FROM client_companies cc
      JOIN company_clients ccl ON ccl.client_company_id = cc.id
      WHERE ccl.company_id = get_my_company_id()
    )
  );

CREATE POLICY "admin_update_client_locations"
  ON client_locations
  FOR UPDATE
  TO authenticated
  USING (
    get_my_role() = 'admin'
    AND client_company_id IN (
      SELECT cc.id FROM client_companies cc
      JOIN company_clients ccl ON ccl.client_company_id = cc.id
      WHERE ccl.company_id = get_my_company_id()
    )
  )
  WITH CHECK (
    get_my_role() = 'admin'
    AND client_company_id IN (
      SELECT cc.id FROM client_companies cc
      JOIN company_clients ccl ON ccl.client_company_id = cc.id
      WHERE ccl.company_id = get_my_company_id()
    )
  );

CREATE POLICY "admin_delete_client_locations"
  ON client_locations
  FOR DELETE
  TO authenticated
  USING (
    get_my_role() = 'admin'
    AND client_company_id IN (
      SELECT cc.id FROM client_companies cc
      JOIN company_clients ccl ON ccl.client_company_id = cc.id
      WHERE ccl.company_id = get_my_company_id()
    )
  );

-- client_admin: acceso a ubicaciones de su propia empresa cliente
CREATE POLICY "client_admin_select_client_locations"
  ON client_locations
  FOR SELECT
  TO authenticated
  USING (
    get_my_role() = 'client_admin'
    AND client_company_id = get_my_client_company_id()
  );

CREATE POLICY "client_admin_insert_client_locations"
  ON client_locations
  FOR INSERT
  TO authenticated
  WITH CHECK (
    get_my_role() = 'client_admin'
    AND client_company_id = get_my_client_company_id()
  );

CREATE POLICY "client_admin_update_client_locations"
  ON client_locations
  FOR UPDATE
  TO authenticated
  USING (
    get_my_role() = 'client_admin'
    AND client_company_id = get_my_client_company_id()
  )
  WITH CHECK (
    get_my_role() = 'client_admin'
    AND client_company_id = get_my_client_company_id()
  );

CREATE POLICY "client_admin_delete_client_locations"
  ON client_locations
  FOR DELETE
  TO authenticated
  USING (
    get_my_role() = 'client_admin'
    AND client_company_id = get_my_client_company_id()
  );

-- client_user: solo lectura de ubicaciones de su empresa cliente
CREATE POLICY "client_user_select_client_locations"
  ON client_locations
  FOR SELECT
  TO authenticated
  USING (
    get_my_role() = 'client_user'
    AND client_company_id = get_my_client_company_id()
  );

-- supervisor y driver: lectura de ubicaciones vinculadas a su compañía
CREATE POLICY "supervisor_driver_select_client_locations"
  ON client_locations
  FOR SELECT
  TO authenticated
  USING (
    get_my_role() IN ('supervisor', 'driver')
    AND client_company_id IN (
      SELECT cc.id FROM client_companies cc
      JOIN company_clients ccl ON ccl.client_company_id = cc.id
      WHERE ccl.company_id = get_my_company_id()
    )
  );
