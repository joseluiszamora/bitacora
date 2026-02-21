# BITACORA — Estructura de Datos

> Última actualización: 20 de febrero de 2026

---

## 📐 Diagrama Entidad-Relación

```
┌─────────────────────┐
│    auth.users        │
│─────────────────────│
│ id          UUID PK  │
│ email       TEXT     │
│ ...                  │
└────────┬────────────┘
         │ 1:1
         │
┌────────▼────────────────────────────────────────────┐
│                   profiles                           │
│─────────────────────────────────────────────────────│
│ id                UUID  PK / FK → auth.users(id)     │
│ full_name         TEXT                               │
│ email             TEXT                               │
│ phone             TEXT?                              │
│ avatar_url        TEXT?                              │
│ role              user_role  DEFAULT 'driver'        │
│ company_id        UUID?  FK → companies(id)          │
│ client_company_id UUID?  FK → client_companies(id)   │
│ is_active         BOOL   DEFAULT true                │
│ created_at        TIMESTAMPTZ                        │
│ updated_at        TIMESTAMPTZ                        │
└──────┬──────────────────────────────┬───────────────┘
       │ N:1                          │ N:1
       │                              │
┌──────▼──────────────┐    ┌──────────▼──────────────┐
│    companies         │    │   client_companies       │
│ (Transportistas)     │    │ (Clientes)               │
│─────────────────────│    │─────────────────────────│
│ id     UUID PK       │    │ id            UUID PK    │
│ name   TEXT NOT NULL  │    │ name          TEXT NN    │
│ social_reason TEXT?   │    │ nit           TEXT? UQ   │
│ nit    TEXT? UNIQUE   │    │ address       TEXT?      │
│ status TEXT 'active'  │    │ contact_email TEXT?      │
│ created_at TSTZ      │    │ created_at    TSTZ       │
│ updated_at TSTZ      │    │ updated_at    TSTZ       │
└──────┬──────────────┘    └──────────┬──────────────┘
       │ 1:N                          │ 1:N
       │                              │
       │    ┌─────────────────────┐   │
       └────▶  company_clients    ◀───┘
            │ (Tabla intermedia)  │
            │─────────────────────│
            │ id               UUID PK                 │
            │ company_id       UUID FK → companies     │
            │ client_company_id UUID FK → client_co..  │
            │ contract_type    TEXT  DEFAULT 'standard' │
            │ status           TEXT  DEFAULT 'active'   │
            │ created_at       TSTZ                     │
            │ updated_at       TSTZ                     │
            │ UNIQUE(company_id, client_company_id)     │
            └─────────────────────┘
```

### Relaciones clave

| Relación                         | Tipo | Descripción                                             |
| -------------------------------- | ---- | ------------------------------------------------------- |
| `auth.users` → `profiles`        | 1:1  | Cada usuario de Auth tiene exactamente un perfil        |
| `profiles` → `companies`         | N:1  | Muchos usuarios pueden pertenecer a una transportista   |
| `profiles` → `client_companies`  | N:1  | Muchos usuarios pueden pertenecer a una empresa cliente |
| `companies` ↔ `client_companies` | N:N  | A través de `company_clients` (tabla intermedia)        |

> **Nota:** Un usuario pertenece a **una** transportista (`company_id`) **o** a **una** empresa cliente (`client_company_id`), nunca a ambas simultáneamente. El campo `role` determina a qué lado pertenece.

---

## 🏷️ Enum: `user_role`

| Valor DB       | Dart                   | Grupo      | Descripción                   |
| -------------- | ---------------------- | ---------- | ----------------------------- |
| `super_admin`  | `UserRole.superAdmin`  | Transporte | Control total del sistema     |
| `admin`        | `UserRole.admin`       | Transporte | Administra su transportista   |
| `supervisor`   | `UserRole.supervisor`  | Transporte | Supervisa operaciones         |
| `driver`       | `UserRole.driver`      | Transporte | Conductor                     |
| `finance`      | `UserRole.finance`     | Transporte | Gestión financiera            |
| `client_admin` | `UserRole.clientAdmin` | Cliente    | Administra su empresa cliente |
| `client_user`  | `UserRole.clientUser`  | Cliente    | Usuario de empresa cliente    |

### Jerarquía de permisos

```
Grupo Transporte          Grupo Cliente
─────────────────         ─────────────────
super_admin (0)  ──────►  Tiene permiso sobre TODOS
  └─ admin (1)            client_admin (5)
       └─ supervisor (2)    └─ client_user (6)
            └─ driver (3)
            └─ finance (4)
```

- Roles del **mismo grupo** comparan por posición jerárquica (índice del enum).
- Roles de **grupos distintos** no tienen permiso entre sí.
- **`super_admin`** es la excepción: tiene permiso sobre todos los roles.

---

## 📋 Detalle de Tablas

### `profiles`

Extensión de `auth.users` con datos de perfil y asignación organizacional.

| Columna             | Tipo          | Null | Default    | Descripción                                 |
| ------------------- | ------------- | ---- | ---------- | ------------------------------------------- |
| `id`                | `UUID`        | NO   | —          | PK, FK → `auth.users(id)` ON DELETE CASCADE |
| `full_name`         | `TEXT`        | SÍ   | —          | Nombre completo                             |
| `email`             | `TEXT`        | SÍ   | —          | Correo electrónico                          |
| `phone`             | `TEXT`        | SÍ   | —          | Teléfono                                    |
| `avatar_url`        | `TEXT`        | SÍ   | —          | URL del avatar                              |
| `role`              | `user_role`   | NO   | `'driver'` | Rol del usuario                             |
| `company_id`        | `UUID`        | SÍ   | —          | FK → `companies(id)`                        |
| `client_company_id` | `UUID`        | SÍ   | —          | FK → `client_companies(id)`                 |
| `is_active`         | `BOOLEAN`     | NO   | `true`     | Si el usuario está activo                   |
| `created_at`        | `TIMESTAMPTZ` | NO   | `now()`    | Fecha de creación                           |
| `updated_at`        | `TIMESTAMPTZ` | NO   | `now()`    | Última actualización                        |

### `companies`

Empresas transportistas que operan en el sistema.

| Columna         | Tipo          | Null | Default             | Descripción              |
| --------------- | ------------- | ---- | ------------------- | ------------------------ |
| `id`            | `UUID`        | NO   | `gen_random_uuid()` | PK                       |
| `name`          | `TEXT`        | NO   | —                   | Nombre comercial         |
| `social_reason` | `TEXT`        | SÍ   | —                   | Razón social             |
| `nit`           | `TEXT`        | SÍ   | —                   | NIT (UNIQUE)             |
| `status`        | `TEXT`        | NO   | `'active'`          | Estado: active, inactive |
| `created_at`    | `TIMESTAMPTZ` | NO   | `now()`             | Fecha de creación        |
| `updated_at`    | `TIMESTAMPTZ` | NO   | `now()`             | Última actualización     |

### `client_companies`

Empresas que contratan servicios de transporte (clientes).

| Columna         | Tipo          | Null | Default             | Descripción          |
| --------------- | ------------- | ---- | ------------------- | -------------------- |
| `id`            | `UUID`        | NO   | `gen_random_uuid()` | PK                   |
| `name`          | `TEXT`        | NO   | —                   | Nombre de la empresa |
| `nit`           | `TEXT`        | SÍ   | —                   | NIT (UNIQUE)         |
| `address`       | `TEXT`        | SÍ   | —                   | Dirección            |
| `contact_email` | `TEXT`        | SÍ   | —                   | Email de contacto    |
| `created_at`    | `TIMESTAMPTZ` | NO   | `now()`             | Fecha de creación    |
| `updated_at`    | `TIMESTAMPTZ` | NO   | `now()`             | Última actualización |

### `company_clients`

Tabla intermedia: relación N:N entre transportistas y clientes.

| Columna             | Tipo          | Null | Default             | Descripción                                   |
| ------------------- | ------------- | ---- | ------------------- | --------------------------------------------- |
| `id`                | `UUID`        | NO   | `gen_random_uuid()` | PK                                            |
| `company_id`        | `UUID`        | NO   | —                   | FK → `companies(id)` ON DELETE CASCADE        |
| `client_company_id` | `UUID`        | NO   | —                   | FK → `client_companies(id)` ON DELETE CASCADE |
| `contract_type`     | `TEXT`        | SÍ   | `'standard'`        | Tipo: standard, annual, exclusive, per_trip   |
| `status`            | `TEXT`        | NO   | `'active'`          | Estado: active, inactive, suspended           |
| `created_at`        | `TIMESTAMPTZ` | NO   | `now()`             | Fecha de creación                             |
| `updated_at`        | `TIMESTAMPTZ` | NO   | `now()`             | Última actualización                          |

**Constraints:** `UNIQUE(company_id, client_company_id)`, `CHECK status IN ('active','inactive','suspended')`

---

## 🔒 Funciones SECURITY DEFINER (RLS helpers)

Estas funciones evitan la recursión infinita al evaluar políticas RLS que necesitan consultar `profiles`.

| Función                        | Retorna     | Descripción                                 |
| ------------------------------ | ----------- | ------------------------------------------- |
| `get_my_role()`                | `user_role` | Rol del usuario autenticado                 |
| `get_my_company_id()`          | `UUID`      | `company_id` del usuario autenticado        |
| `get_my_client_company_id()`   | `UUID`      | `client_company_id` del usuario autenticado |
| `get_user_email(user_id UUID)` | `TEXT`      | Email de un usuario por su ID               |

---

## 🔐 Políticas RLS — Resumen

### `profiles`

| Política                    | Operación | Quién        | Condición                                        |
| --------------------------- | --------- | ------------ | ------------------------------------------------ |
| Lectura propia              | SELECT    | Todos        | `id = auth.uid()`                                |
| Actualización propia        | UPDATE    | Todos        | `id = auth.uid()`                                |
| Super admin todo            | ALL       | super_admin  | `get_my_role() = 'super_admin'`                  |
| Admin lee su empresa        | SELECT    | admin        | `company_id = get_my_company_id()`               |
| Admin actualiza su empresa  | UPDATE    | admin        | `company_id = get_my_company_id()`               |
| Client admin lee su empresa | SELECT    | client_admin | `client_company_id = get_my_client_company_id()` |
| Client admin actualiza      | UPDATE    | client_admin | `client_company_id = get_my_client_company_id()` |

### `companies`

| Política          | Operación | Quién       | Condición                       |
| ----------------- | --------- | ----------- | ------------------------------- |
| Super admin todo  | ALL       | super_admin | `get_my_role() = 'super_admin'` |
| Admin lee la suya | SELECT    | admin       | `id = get_my_company_id()`      |

### `client_companies`

| Política            | Operación | Quién             | Condición                                                                                      |
| ------------------- | --------- | ----------------- | ---------------------------------------------------------------------------------------------- |
| Super admin todo    | ALL       | super_admin       | `get_my_role() = 'super_admin'`                                                                |
| Lee la propia       | SELECT    | client_admin/user | `id = get_my_client_company_id()`                                                              |
| Admin lee asociadas | SELECT    | admin             | `id IN (SELECT client_company_id FROM company_clients WHERE company_id = get_my_company_id())` |

### `company_clients`

| Política                    | Operación | Quién        | Condición                                        |
| --------------------------- | --------- | ------------ | ------------------------------------------------ |
| Super admin todo            | ALL       | super_admin  | `get_my_role() = 'super_admin'`                  |
| Admin lee su transportista  | SELECT    | admin        | `company_id = get_my_company_id()`               |
| Client admin lee su empresa | SELECT    | client_admin | `client_company_id = get_my_client_company_id()` |

---

## 🗂️ Mapeo Flutter ↔ Supabase

| Tabla DB                  | Modelo Dart     | Provider                       | Repository                         | BLoC                                       |
| ------------------------- | --------------- | ------------------------------ | ---------------------------------- | ------------------------------------------ |
| `profiles` + `auth.users` | `User`          | `AuthProvider`, `UserProvider` | `AuthRepository`, `UserRepository` | `AuthenticationBloc`, `UserManagementBloc` |
| `companies`               | `Company`       | `CompanyProvider`              | `CompanyRepository`                | `CompanyBloc`                              |
| `client_companies`        | `ClientCompany` | `ClientCompanyProvider`        | `ClientCompanyRepository`          | `ClientCompanyBloc`                        |
| `company_clients`         | `CompanyClient` | `CompanyClientProvider`        | `CompanyClientRepository`          | — (gestionado desde vistas)                |
| — (enum)                  | `UserRole`      | —                              | —                                  | —                                          |

---

## 🛠️ Scripts SQL para Supabase

Los scripts deben ejecutarse **en orden** en el SQL Editor de Supabase.

### Script 1 — Base de datos inicial (tablas, enum, funciones, trigger, RLS)

```sql
-- =============================================================================
-- SCRIPT 1: ESTRUCTURA BASE — Ejecutar primero
-- =============================================================================

-- ─── 1. Enum de roles ───────────────────────────────────────────────────────
CREATE TYPE public.user_role AS ENUM (
  'super_admin',
  'admin',
  'supervisor',
  'driver',
  'finance',
  'client_admin',
  'client_user'
);

-- ─── 2. Tabla companies (transportistas) ────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.companies (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name          TEXT NOT NULL,
  social_reason TEXT,
  nit           TEXT UNIQUE,
  status        TEXT NOT NULL DEFAULT 'active',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;

-- ─── 3. Tabla client_companies (clientes) ───────────────────────────────────
CREATE TABLE IF NOT EXISTS public.client_companies (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name          TEXT NOT NULL,
  nit           TEXT UNIQUE,
  address       TEXT,
  contact_email TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.client_companies ENABLE ROW LEVEL SECURITY;

-- ─── 4. Tabla profiles ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.profiles (
  id                UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name         TEXT,
  email             TEXT,
  phone             TEXT,
  avatar_url        TEXT,
  role              public.user_role NOT NULL DEFAULT 'driver',
  company_id        UUID REFERENCES public.companies(id),
  client_company_id UUID REFERENCES public.client_companies(id),
  is_active         BOOLEAN NOT NULL DEFAULT true,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- ─── 5. Tabla intermedia company_clients (N:N) ─────────────────────────────
CREATE TABLE IF NOT EXISTS public.company_clients (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id        UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  client_company_id UUID NOT NULL REFERENCES public.client_companies(id) ON DELETE CASCADE,
  contract_type     TEXT DEFAULT 'standard',
  status            TEXT NOT NULL DEFAULT 'active'
                    CHECK (status IN ('active', 'inactive', 'suspended')),
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(company_id, client_company_id)
);

ALTER TABLE public.company_clients ENABLE ROW LEVEL SECURITY;

-- ─── 6. Trigger: crear perfil automáticamente al registrarse ────────────────
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, email, avatar_url)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data ->> 'full_name', NEW.raw_user_meta_data ->> 'name', ''),
    NEW.email,
    NEW.raw_user_meta_data ->> 'avatar_url'
  );
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ─── 7. Trigger: updated_at automático ──────────────────────────────────────
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS profiles_updated_at ON public.profiles;
CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS companies_updated_at ON public.companies;
CREATE TRIGGER companies_updated_at
  BEFORE UPDATE ON public.companies
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS client_companies_updated_at ON public.client_companies;
CREATE TRIGGER client_companies_updated_at
  BEFORE UPDATE ON public.client_companies
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS company_clients_updated_at ON public.company_clients;
CREATE TRIGGER company_clients_updated_at
  BEFORE UPDATE ON public.company_clients
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ─── 8. Índices ─────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_profiles_company_id
  ON public.profiles(company_id);

CREATE INDEX IF NOT EXISTS idx_profiles_client_company_id
  ON public.profiles(client_company_id);

CREATE INDEX IF NOT EXISTS idx_profiles_role
  ON public.profiles(role);

CREATE INDEX IF NOT EXISTS idx_company_clients_company_id
  ON public.company_clients(company_id);

CREATE INDEX IF NOT EXISTS idx_company_clients_client_company_id
  ON public.company_clients(client_company_id);
```

### Script 2 — Funciones SECURITY DEFINER (helpers para RLS)

```sql
-- =============================================================================
-- SCRIPT 2: FUNCIONES SECURITY DEFINER — Ejecutar después del Script 1
-- =============================================================================
-- Estas funciones se ejecutan con privilegios del creador (superuser)
-- para evitar recursión infinita en las políticas RLS de `profiles`.

-- ─── get_my_role() ──────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS public.user_role
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT role FROM profiles WHERE id = auth.uid();
$$;

-- ─── get_my_company_id() ────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.get_my_company_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT company_id FROM profiles WHERE id = auth.uid();
$$;

-- ─── get_my_client_company_id() ─────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.get_my_client_company_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT client_company_id FROM profiles WHERE id = auth.uid();
$$;

-- ─── get_user_email(user_id) ────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.get_user_email(user_id UUID)
RETURNS TEXT
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT email FROM auth.users WHERE id = user_id;
$$;

-- ─── get_my_profile() (RPC para obtener perfil completo con joins) ──────────
CREATE OR REPLACE FUNCTION public.get_my_profile()
RETURNS JSON
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT row_to_json(t) FROM (
    SELECT
      p.id,
      p.full_name,
      p.email,
      p.phone,
      p.avatar_url,
      p.role,
      p.is_active,
      p.created_at,
      p.updated_at,
      CASE
        WHEN p.company_id IS NOT NULL THEN (
          SELECT row_to_json(c) FROM (
            SELECT id, name, social_reason, nit, status, created_at
            FROM companies WHERE id = p.company_id
          ) c
        )
        ELSE NULL
      END AS company,
      CASE
        WHEN p.client_company_id IS NOT NULL THEN (
          SELECT row_to_json(cc) FROM (
            SELECT id, name, nit, address, contact_email, created_at
            FROM client_companies WHERE id = p.client_company_id
          ) cc
        )
        ELSE NULL
      END AS client_company
    FROM profiles p
    WHERE p.id = auth.uid()
  ) t;
$$;
```

### Script 3 — Políticas RLS

```sql
-- =============================================================================
-- SCRIPT 3: POLÍTICAS RLS — Ejecutar después del Script 2
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- PROFILES
-- ─────────────────────────────────────────────────────────────────────────────

-- Limpiar políticas existentes
DO $$
DECLARE pol RECORD;
BEGIN
  FOR pol IN
    SELECT policyname FROM pg_policies
    WHERE tablename = 'profiles' AND schemaname = 'public'
  LOOP
    EXECUTE format('DROP POLICY %I ON public.profiles', pol.policyname);
  END LOOP;
END $$;

-- Cada usuario puede ver su propio perfil
CREATE POLICY "profiles_own_read"
  ON public.profiles FOR SELECT
  USING (id = auth.uid());

-- Cada usuario puede actualizar su propio perfil
CREATE POLICY "profiles_own_update"
  ON public.profiles FOR UPDATE
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- super_admin puede ver y gestionar todos los perfiles
CREATE POLICY "profiles_super_admin_all"
  ON public.profiles FOR ALL
  USING (get_my_role() = 'super_admin')
  WITH CHECK (get_my_role() = 'super_admin');

-- admin puede ver usuarios de su misma empresa transportista
CREATE POLICY "profiles_admin_read"
  ON public.profiles FOR SELECT
  USING (
    get_my_role() = 'admin'
    AND company_id = get_my_company_id()
  );

-- admin puede actualizar usuarios de su misma empresa transportista
CREATE POLICY "profiles_admin_update"
  ON public.profiles FOR UPDATE
  USING (
    get_my_role() = 'admin'
    AND company_id = get_my_company_id()
  )
  WITH CHECK (
    get_my_role() = 'admin'
    AND company_id = get_my_company_id()
  );

-- client_admin puede ver usuarios de su misma empresa cliente
CREATE POLICY "profiles_client_admin_read"
  ON public.profiles FOR SELECT
  USING (
    get_my_role() = 'client_admin'
    AND client_company_id = get_my_client_company_id()
  );

-- client_admin puede actualizar usuarios de su misma empresa cliente
CREATE POLICY "profiles_client_admin_update"
  ON public.profiles FOR UPDATE
  USING (
    get_my_role() = 'client_admin'
    AND client_company_id = get_my_client_company_id()
  )
  WITH CHECK (
    get_my_role() = 'client_admin'
    AND client_company_id = get_my_client_company_id()
  );

-- ─────────────────────────────────────────────────────────────────────────────
-- COMPANIES
-- ─────────────────────────────────────────────────────────────────────────────

DO $$
DECLARE pol RECORD;
BEGIN
  FOR pol IN
    SELECT policyname FROM pg_policies
    WHERE tablename = 'companies' AND schemaname = 'public'
  LOOP
    EXECUTE format('DROP POLICY %I ON public.companies', pol.policyname);
  END LOOP;
END $$;

-- super_admin puede ver y gestionar todas las compañías
CREATE POLICY "companies_super_admin_all"
  ON public.companies FOR ALL
  USING (get_my_role() = 'super_admin')
  WITH CHECK (get_my_role() = 'super_admin');

-- admin puede ver su propia compañía
CREATE POLICY "companies_admin_read"
  ON public.companies FOR SELECT
  USING (
    get_my_role() = 'admin'
    AND id = get_my_company_id()
  );

-- Los demás roles de transporte pueden ver su compañía
CREATE POLICY "companies_transport_read"
  ON public.companies FOR SELECT
  USING (id = get_my_company_id());

-- ─────────────────────────────────────────────────────────────────────────────
-- CLIENT_COMPANIES
-- ─────────────────────────────────────────────────────────────────────────────

DO $$
DECLARE pol RECORD;
BEGIN
  FOR pol IN
    SELECT policyname FROM pg_policies
    WHERE tablename = 'client_companies' AND schemaname = 'public'
  LOOP
    EXECUTE format('DROP POLICY %I ON public.client_companies', pol.policyname);
  END LOOP;
END $$;

-- super_admin puede ver y gestionar todas las empresas cliente
CREATE POLICY "client_companies_super_admin_all"
  ON public.client_companies FOR ALL
  USING (get_my_role() = 'super_admin')
  WITH CHECK (get_my_role() = 'super_admin');

-- client_admin y client_user pueden ver su propia empresa
CREATE POLICY "client_companies_own_read"
  ON public.client_companies FOR SELECT
  USING (id = get_my_client_company_id());

-- admin puede ver empresas cliente asociadas a su transportista
CREATE POLICY "client_companies_admin_read"
  ON public.client_companies FOR SELECT
  USING (
    get_my_role() = 'admin'
    AND id IN (
      SELECT client_company_id
      FROM company_clients
      WHERE company_id = get_my_company_id()
    )
  );

-- ─────────────────────────────────────────────────────────────────────────────
-- COMPANY_CLIENTS
-- ─────────────────────────────────────────────────────────────────────────────

DO $$
DECLARE pol RECORD;
BEGIN
  FOR pol IN
    SELECT policyname FROM pg_policies
    WHERE tablename = 'company_clients' AND schemaname = 'public'
  LOOP
    EXECUTE format('DROP POLICY %I ON public.company_clients', pol.policyname);
  END LOOP;
END $$;

-- super_admin puede ver y gestionar todas las relaciones
CREATE POLICY "company_clients_super_admin_all"
  ON public.company_clients FOR ALL
  USING (get_my_role() = 'super_admin')
  WITH CHECK (get_my_role() = 'super_admin');

-- admin puede ver las relaciones de su transportista
CREATE POLICY "company_clients_admin_read"
  ON public.company_clients FOR SELECT
  USING (
    get_my_role() = 'admin'
    AND company_id = get_my_company_id()
  );

-- client_admin puede ver las relaciones de su empresa cliente
CREATE POLICY "company_clients_client_admin_read"
  ON public.company_clients FOR SELECT
  USING (
    get_my_role() = 'client_admin'
    AND client_company_id = get_my_client_company_id()
  );
```

### Script 4 — Datos iniciales (seed)

```sql
-- =============================================================================
-- SCRIPT 4: SEED — Datos iniciales de prueba (OPCIONAL)
-- =============================================================================

-- Crear empresas transportistas de ejemplo
INSERT INTO public.companies (name, social_reason, nit, status) VALUES
  ('Transportes Monval', 'Monval SRL', '1234567', 'active'),
  ('Logística Andina', 'Logística Andina SA', '7654321', 'active');

-- Crear empresas cliente de ejemplo
INSERT INTO public.client_companies (name, nit, address, contact_email) VALUES
  ('Minera San Cristóbal', '11223344', 'Potosí, Bolivia', 'contacto@minera-sc.bo'),
  ('Cementos Viacha', '55667788', 'Viacha, La Paz', 'logistica@cementos-v.bo');

-- Vincular transportista con clientes
INSERT INTO public.company_clients (company_id, client_company_id, contract_type, status)
SELECT c.id, cc.id, 'annual', 'active'
FROM companies c, client_companies cc
WHERE c.name = 'Transportes Monval' AND cc.name = 'Minera San Cristóbal';

INSERT INTO public.company_clients (company_id, client_company_id, contract_type, status)
SELECT c.id, cc.id, 'standard', 'active'
FROM companies c, client_companies cc
WHERE c.name = 'Transportes Monval' AND cc.name = 'Cementos Viacha';

-- NOTA: Para asignar roles a usuarios, primero regístralos vía la app
-- y luego actualiza su perfil:
--
--   UPDATE profiles
--   SET role = 'super_admin', company_id = '<UUID de Transportes Monval>'
--   WHERE email = 'tu-email@ejemplo.com';
```

---

## 📁 Estructura de archivos (capa de datos)

```
lib/core/data/
├── models/
│   ├── user_role.dart          # Enum UserRole (7 valores)
│   ├── user.dart               # User (perfil completo)
│   ├── company.dart            # Company (transportista)
│   ├── client_company.dart     # ClientCompany (cliente)
│   └── company_client.dart     # CompanyClient (relación N:N)
├── providers/
│   ├── auth_provider.dart      # Login, signup, logout, RPC
│   ├── user_provider.dart      # CRUD profiles + auth.admin
│   ├── company_provider.dart   # CRUD companies
│   ├── client_company_provider.dart   # CRUD client_companies
│   └── company_client_provider.dart   # CRUD company_clients
└── repositories/
    ├── auth_repository.dart     # Lógica de autenticación
    ├── user_repository.dart     # Lógica de gestión de usuarios
    ├── company_repository.dart  # Lógica de compañías
    ├── client_company_repository.dart  # Lógica de empresas cliente
    └── company_client_repository.dart  # Lógica de relaciones
```

---

## 🔄 Flujo de Arquitectura

```
┌──────────┐    ┌──────────┐    ┌──────────────┐    ┌──────────┐
│  Widget  │───▶│   BLoC   │───▶│  Repository  │───▶│ Provider │───▶ Supabase
│  (View)  │◀───│  (State) │◀───│  (Business)  │◀───│  (Data)  │◀───   DB
└──────────┘    └──────────┘    └──────────────┘    └──────────┘
```

- **Provider**: Llamadas directas a Supabase (CRUD puro).
- **Repository**: Lógica de negocio, transformación de datos, validaciones.
- **BLoC**: Gestión de estado reactivo para la UI.
- **Widget**: Presentación e interacción del usuario.
