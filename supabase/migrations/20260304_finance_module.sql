-- ============================================================================
-- MÓDULO DE FINANZAS — Bitácora
-- Fecha: 2026-03-04
-- Descripción: Tablas, índices, RLS y políticas para el módulo de finanzas.
--              Gestiona grupos, categorías y registros (ingresos/egresos).
--              Accesible solo para super_admin, admin y supervisor.
-- ============================================================================

-- ────────────────────────────────────────────────────────────────────────────
-- 1. TABLA: finance_groups
-- ────────────────────────────────────────────────────────────────────────────
-- Agrupa movimientos financieros bajo un concepto.
-- Ejemplos: "Gastos de enero", "Reparación del vehículo", "Viaje 1-5 feb".

CREATE TABLE IF NOT EXISTS public.finance_groups (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id  UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  description TEXT,
  is_active   BOOLEAN NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- Un grupo con el mismo nombre no puede repetirse dentro de la empresa.
  CONSTRAINT finance_groups_company_name_unique UNIQUE (company_id, name)
);

COMMENT ON TABLE public.finance_groups IS 'Grupos para organizar movimientos financieros por concepto o período.';
COMMENT ON COLUMN public.finance_groups.is_active IS 'Cuando false, el grupo no aparece en los selectores al crear movimientos.';

-- Índices
CREATE INDEX IF NOT EXISTS idx_finance_groups_company
  ON public.finance_groups (company_id);

CREATE INDEX IF NOT EXISTS idx_finance_groups_company_active
  ON public.finance_groups (company_id, is_active)
  WHERE is_active = TRUE;


-- ────────────────────────────────────────────────────────────────────────────
-- 2. TABLA: finance_categories
-- ────────────────────────────────────────────────────────────────────────────
-- Categorías de movimientos financieros.
-- Ejemplos: "Pago por viaje", "Pago de impuestos", "Reparación de motor",
--           "Cambio de llantas", "Abono por deudas".

CREATE TABLE IF NOT EXISTS public.finance_categories (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id  UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  description TEXT,
  is_active   BOOLEAN NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- Una categoría con el mismo nombre no puede repetirse dentro de la empresa.
  CONSTRAINT finance_categories_company_name_unique UNIQUE (company_id, name)
);

COMMENT ON TABLE public.finance_categories IS 'Categorías para clasificar el tipo de ingreso o egreso.';
COMMENT ON COLUMN public.finance_categories.is_active IS 'Cuando false, la categoría no aparece en los selectores al crear movimientos.';

-- Índices
CREATE INDEX IF NOT EXISTS idx_finance_categories_company
  ON public.finance_categories (company_id);

CREATE INDEX IF NOT EXISTS idx_finance_categories_company_active
  ON public.finance_categories (company_id, is_active)
  WHERE is_active = TRUE;


-- ────────────────────────────────────────────────────────────────────────────
-- 3. TIPO ENUM: finance_record_type
-- ────────────────────────────────────────────────────────────────────────────

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'finance_record_type') THEN
    CREATE TYPE public.finance_record_type AS ENUM ('INCOME', 'EXPENSE');
  END IF;
END
$$;

COMMENT ON TYPE public.finance_record_type IS 'Tipo de movimiento financiero: INCOME (ingreso) o EXPENSE (egreso).';


-- ────────────────────────────────────────────────────────────────────────────
-- 4. TABLA: finance_records
-- ────────────────────────────────────────────────────────────────────────────
-- Registros de ingresos y egresos financieros.

CREATE TABLE IF NOT EXISTS public.finance_records (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id  UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  group_id    UUID NOT NULL REFERENCES public.finance_groups(id) ON DELETE RESTRICT,
  category_id UUID NOT NULL REFERENCES public.finance_categories(id) ON DELETE RESTRICT,
  type        public.finance_record_type NOT NULL DEFAULT 'EXPENSE',
  amount      NUMERIC(12,2) NOT NULL CHECK (amount > 0),
  description TEXT,
  record_date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.finance_records IS 'Movimientos financieros (ingresos y egresos) asociados a un grupo y categoría.';
COMMENT ON COLUMN public.finance_records.group_id IS 'FK a finance_groups. RESTRICT evita eliminar grupos con registros.';
COMMENT ON COLUMN public.finance_records.category_id IS 'FK a finance_categories. RESTRICT evita eliminar categorías con registros.';
COMMENT ON COLUMN public.finance_records.amount IS 'Monto en moneda local (Bs.). Siempre positivo, el tipo indica si es ingreso o egreso.';
COMMENT ON COLUMN public.finance_records.record_date IS 'Fecha del movimiento (puede ser distinta de created_at).';

-- Índices
CREATE INDEX IF NOT EXISTS idx_finance_records_company
  ON public.finance_records (company_id);

CREATE INDEX IF NOT EXISTS idx_finance_records_company_date
  ON public.finance_records (company_id, record_date DESC);

CREATE INDEX IF NOT EXISTS idx_finance_records_group
  ON public.finance_records (group_id);

CREATE INDEX IF NOT EXISTS idx_finance_records_category
  ON public.finance_records (category_id);

CREATE INDEX IF NOT EXISTS idx_finance_records_type
  ON public.finance_records (company_id, type);


-- ============================================================================
-- 5. ROW LEVEL SECURITY (RLS)
-- ============================================================================
-- Solo super_admin, admin y supervisor de la misma empresa pueden
-- ver y gestionar los datos financieros.
-- Usa las funciones SECURITY DEFINER existentes:
--   get_my_role()        → rol del usuario autenticado
--   get_my_company_id()  → company_id del usuario autenticado
-- ============================================================================

-- ─── finance_groups ─────────────────────────────────────────────────────────

ALTER TABLE public.finance_groups ENABLE ROW LEVEL SECURITY;

-- SELECT: super_admin, admin, supervisor de la misma empresa
CREATE POLICY finance_groups_select ON public.finance_groups
  FOR SELECT
  USING (
    company_id = get_my_company_id()
    AND get_my_role() IN ('super_admin', 'admin', 'supervisor')
  );

-- INSERT: super_admin, admin, supervisor de la misma empresa
CREATE POLICY finance_groups_insert ON public.finance_groups
  FOR INSERT
  WITH CHECK (
    company_id = get_my_company_id()
    AND get_my_role() IN ('super_admin', 'admin', 'supervisor')
  );

-- UPDATE: super_admin, admin, supervisor de la misma empresa
CREATE POLICY finance_groups_update ON public.finance_groups
  FOR UPDATE
  USING (
    company_id = get_my_company_id()
    AND get_my_role() IN ('super_admin', 'admin', 'supervisor')
  )
  WITH CHECK (
    company_id = get_my_company_id()
    AND get_my_role() IN ('super_admin', 'admin', 'supervisor')
  );

-- DELETE: solo super_admin y admin
CREATE POLICY finance_groups_delete ON public.finance_groups
  FOR DELETE
  USING (
    company_id = get_my_company_id()
    AND get_my_role() IN ('super_admin', 'admin')
  );


-- ─── finance_categories ─────────────────────────────────────────────────────

ALTER TABLE public.finance_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY finance_categories_select ON public.finance_categories
  FOR SELECT
  USING (
    company_id = get_my_company_id()
    AND get_my_role() IN ('super_admin', 'admin', 'supervisor')
  );

CREATE POLICY finance_categories_insert ON public.finance_categories
  FOR INSERT
  WITH CHECK (
    company_id = get_my_company_id()
    AND get_my_role() IN ('super_admin', 'admin', 'supervisor')
  );

CREATE POLICY finance_categories_update ON public.finance_categories
  FOR UPDATE
  USING (
    company_id = get_my_company_id()
    AND get_my_role() IN ('super_admin', 'admin', 'supervisor')
  )
  WITH CHECK (
    company_id = get_my_company_id()
    AND get_my_role() IN ('super_admin', 'admin', 'supervisor')
  );

CREATE POLICY finance_categories_delete ON public.finance_categories
  FOR DELETE
  USING (
    company_id = get_my_company_id()
    AND get_my_role() IN ('super_admin', 'admin')
  );


-- ─── finance_records ────────────────────────────────────────────────────────

ALTER TABLE public.finance_records ENABLE ROW LEVEL SECURITY;

CREATE POLICY finance_records_select ON public.finance_records
  FOR SELECT
  USING (
    company_id = get_my_company_id()
    AND get_my_role() IN ('super_admin', 'admin', 'supervisor')
  );

CREATE POLICY finance_records_insert ON public.finance_records
  FOR INSERT
  WITH CHECK (
    company_id = get_my_company_id()
    AND get_my_role() IN ('super_admin', 'admin', 'supervisor')
  );

CREATE POLICY finance_records_update ON public.finance_records
  FOR UPDATE
  USING (
    company_id = get_my_company_id()
    AND get_my_role() IN ('super_admin', 'admin', 'supervisor')
  )
  WITH CHECK (
    company_id = get_my_company_id()
    AND get_my_role() IN ('super_admin', 'admin', 'supervisor')
  );

CREATE POLICY finance_records_delete ON public.finance_records
  FOR DELETE
  USING (
    company_id = get_my_company_id()
    AND get_my_role() IN ('super_admin', 'admin')
  );


-- ============================================================================
-- 6. GRANTS — Acceso para el rol anon y authenticated
-- ============================================================================

GRANT SELECT, INSERT, UPDATE, DELETE
  ON public.finance_groups      TO authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE
  ON public.finance_categories  TO authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE
  ON public.finance_records     TO authenticated;


-- ============================================================================
-- 7. VISTA RESUMIDA (opcional) — Resumen financiero por grupo
-- ============================================================================
-- Vista útil para consultas rápidas de totales por grupo.

CREATE OR REPLACE VIEW public.finance_group_summary AS
SELECT
  fr.company_id,
  fr.group_id,
  fg.name                                                AS group_name,
  fg.is_active                                           AS group_active,
  COUNT(*)                                               AS total_records,
  COUNT(*) FILTER (WHERE fr.type = 'INCOME')             AS income_count,
  COUNT(*) FILTER (WHERE fr.type = 'EXPENSE')            AS expense_count,
  COALESCE(SUM(fr.amount) FILTER (WHERE fr.type = 'INCOME'), 0)  AS total_income,
  COALESCE(SUM(fr.amount) FILTER (WHERE fr.type = 'EXPENSE'), 0) AS total_expense,
  COALESCE(SUM(fr.amount) FILTER (WHERE fr.type = 'INCOME'), 0)
    - COALESCE(SUM(fr.amount) FILTER (WHERE fr.type = 'EXPENSE'), 0) AS balance,
  MIN(fr.record_date)                                    AS first_record_date,
  MAX(fr.record_date)                                    AS last_record_date
FROM public.finance_records fr
JOIN public.finance_groups fg ON fg.id = fr.group_id
GROUP BY fr.company_id, fr.group_id, fg.name, fg.is_active;

COMMENT ON VIEW public.finance_group_summary IS 'Resumen financiero por grupo: totales de ingresos, egresos y balance.';

GRANT SELECT ON public.finance_group_summary TO authenticated;


-- ============================================================================
-- FIN DEL SCRIPT — Módulo de Finanzas
-- ============================================================================
