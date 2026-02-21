-- =============================================================================
-- MIGRACIÓN: Empresas Cliente + Tabla intermedia + Nuevos roles
-- =============================================================================
-- Ejecutar en el SQL Editor de Supabase en orden.
-- =============================================================================

-- 1. Agregar nuevos valores al enum user_role
-- ─────────────────────────────────────────────
ALTER TYPE public.user_role ADD VALUE IF NOT EXISTS 'client_admin';
ALTER TYPE public.user_role ADD VALUE IF NOT EXISTS 'client_user';

-- 2. Crear tabla client_companies (empresas que contratan viajes)
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.client_companies (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  nit         TEXT UNIQUE,
  address     TEXT,
  contact_email TEXT,
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now()
);

-- Habilitar RLS
ALTER TABLE public.client_companies ENABLE ROW LEVEL SECURITY;

-- 3. Crear tabla intermedia company_clients (transportista ↔ cliente)
-- ────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.company_clients (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id         UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  client_company_id  UUID NOT NULL REFERENCES public.client_companies(id) ON DELETE CASCADE,
  contract_type      TEXT DEFAULT 'standard',
  status             TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
  created_at         TIMESTAMPTZ DEFAULT now(),
  updated_at         TIMESTAMPTZ DEFAULT now(),
  UNIQUE(company_id, client_company_id)
);

-- Habilitar RLS
ALTER TABLE public.company_clients ENABLE ROW LEVEL SECURITY;

-- 4. Agregar client_company_id a la tabla profiles
-- ──────────────────────────────────────────────────
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS client_company_id UUID REFERENCES public.client_companies(id);

-- 5. Función auxiliar: obtener el client_company_id del usuario actual
-- ────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.get_my_client_company_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT client_company_id
  FROM profiles
  WHERE id = auth.uid();
$$;

-- 6. Políticas RLS para client_companies
-- ───────────────────────────────────────
DO $$
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN
    SELECT policyname FROM pg_policies WHERE tablename = 'client_companies' AND schemaname = 'public'
  LOOP
    EXECUTE format('DROP POLICY %I ON public.client_companies', pol.policyname);
  END LOOP;
END $$;

-- super_admin puede ver y gestionar todo
CREATE POLICY "client_companies_super_admin_all"
  ON public.client_companies
  FOR ALL
  USING (get_my_role() = 'super_admin')
  WITH CHECK (get_my_role() = 'super_admin');

-- client_admin y client_user pueden ver su propia empresa cliente
CREATE POLICY "client_companies_own_read"
  ON public.client_companies
  FOR SELECT
  USING (id = get_my_client_company_id());

-- admin puede ver las empresas cliente asociadas a su transportista
CREATE POLICY "client_companies_admin_read"
  ON public.client_companies
  FOR SELECT
  USING (
    get_my_role() = 'admin'
    AND id IN (
      SELECT client_company_id
      FROM company_clients
      WHERE company_id = get_my_company_id()
    )
  );

-- 7. Políticas RLS para company_clients
-- ──────────────────────────────────────
DO $$
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN
    SELECT policyname FROM pg_policies WHERE tablename = 'company_clients' AND schemaname = 'public'
  LOOP
    EXECUTE format('DROP POLICY %I ON public.company_clients', pol.policyname);
  END LOOP;
END $$;

-- super_admin puede ver y gestionar todo
CREATE POLICY "company_clients_super_admin_all"
  ON public.company_clients
  FOR ALL
  USING (get_my_role() = 'super_admin')
  WITH CHECK (get_my_role() = 'super_admin');

-- admin puede ver las relaciones de su transportista
CREATE POLICY "company_clients_admin_read"
  ON public.company_clients
  FOR SELECT
  USING (
    get_my_role() = 'admin'
    AND company_id = get_my_company_id()
  );

-- client_admin puede ver las relaciones de su empresa cliente
CREATE POLICY "company_clients_client_admin_read"
  ON public.company_clients
  FOR SELECT
  USING (
    get_my_role() = 'client_admin'
    AND client_company_id = get_my_client_company_id()
  );

-- 8. Actualizar políticas de profiles para los nuevos roles
-- ──────────────────────────────────────────────────────────
-- (Las políticas existentes ya usan get_my_role() y get_my_company_id(),
--  solo necesitamos agregar una política para client_admin)

-- client_admin puede ver usuarios de su misma empresa cliente
CREATE POLICY "profiles_client_admin_read"
  ON public.profiles
  FOR SELECT
  USING (
    get_my_role() = 'client_admin'
    AND client_company_id = get_my_client_company_id()
  );

-- client_admin puede actualizar usuarios de su misma empresa cliente (excepto a sí mismo)
CREATE POLICY "profiles_client_admin_update"
  ON public.profiles
  FOR UPDATE
  USING (
    get_my_role() = 'client_admin'
    AND client_company_id = get_my_client_company_id()
  )
  WITH CHECK (
    get_my_role() = 'client_admin'
    AND client_company_id = get_my_client_company_id()
  );

-- 9. Índices para performance
-- ───────────────────────────
CREATE INDEX IF NOT EXISTS idx_profiles_client_company_id
  ON public.profiles(client_company_id);

CREATE INDEX IF NOT EXISTS idx_company_clients_company_id
  ON public.company_clients(company_id);

CREATE INDEX IF NOT EXISTS idx_company_clients_client_company_id
  ON public.company_clients(client_company_id);

-- =============================================================================
-- FIN DE LA MIGRACIÓN
-- =============================================================================
