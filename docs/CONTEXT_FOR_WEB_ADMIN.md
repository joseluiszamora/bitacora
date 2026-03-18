# 📋 BITACORA — Documento de Contexto para Administrador Web

> **Propósito**: Este documento resume completamente el proyecto móvil "BITACORA de Transporte" (Flutter) para que sirva de referencia al desarrollar el **panel de administración web** que lo complementa. Contiene toda la información sobre el dominio de negocio, base de datos, modelos, roles, permisos, APIs y reglas de negocio.

---

## 1. 🏢 Descripción General del Proyecto

**BITACORA de Transporte** es una aplicación móvil (Android & iOS) desarrollada en **Flutter** que gestiona operaciones de transporte de carga en Bolivia. Conecta **empresas transportistas** con **empresas clientes** (mineras, cementeras, etc.) y permite registrar viajes, asignar vehículos a conductores, crear bitácoras de eventos en tiempo real y gestionar finanzas.

### Actores del Sistema

| Actor                   | Descripción                                                               |
| ----------------------- | ------------------------------------------------------------------------- |
| **Super Administrador** | Control total del sistema. Gestiona todas las empresas y usuarios.        |
| **Administrador**       | Gestiona su empresa transportista: usuarios, vehículos, viajes, finanzas. |
| **Supervisor**          | Supervisa operaciones de la transportista. Lectura + algunas acciones.    |
| **Conductor (Driver)**  | Usa la app móvil para registrar eventos de viaje (bitácora).              |
| **Finanzas**            | Gestión financiera de la transportista.                                   |
| **Admin Cliente**       | Administra su empresa cliente.                                            |
| **Usuario Cliente**     | Lectura de información de su empresa cliente.                             |

### Funcionalidades Principales

1. **Autenticación**: Login/registro con Supabase Auth.
2. **Gestión de Empresas Transportistas** (companies): CRUD completo.
3. **Gestión de Empresas Clientes** (client_companies): CRUD + asociación N:N con transportistas.
4. **Gestión de Usuarios/Perfiles**: CRUD con asignación de roles y pertenencia a empresa.
5. **Gestión de Vehículos**: CRUD de flota vehicular con documentación (SOAT, inspección, seguro, RUAT).
6. **Asignación Vehículo-Conductor**: Relación M:N entre vehículos y conductores.
7. **Gestión de Ubicaciones de Clientes**: Almacenes, plantas, centros de distribución con geolocalización.
8. **Gestión de Viajes** (trips): Crear viajes con origen/destino (ubicaciones de clientes), vehículo asignado, estados de flujo.
9. **Bitácora de Viaje** (trip_logs): Registro cronológico de eventos del viaje con geolocalización y media (fotos/videos).
10. **Mapa de Viaje**: Visualización del recorrido del viaje en mapa.
11. **Módulo Financiero**: Grupos, categorías y registros de ingresos/egresos por empresa.
12. **Geografía**: Departamentos (states) y ciudades (cities) de Bolivia.

---

## 2. 🗄️ Backend: Supabase

El backend es **Supabase** (BaaS sobre PostgreSQL). El administrador web debe conectarse a la **misma instancia de Supabase** que la app móvil.

### Módulos de Supabase utilizados

| Módulo             | Uso                                                               |
| ------------------ | ----------------------------------------------------------------- |
| **Auth**           | Login, registro, sesión, manejo de tokens                         |
| **Database**       | Tablas PostgreSQL con RLS (Row Level Security)                    |
| **Storage**        | Imágenes de avatar de usuarios, fotos de carga, documentos        |
| **Realtime**       | Suscripción en tiempo real a cambios en bitácoras y viajes        |
| **Edge Functions** | Lógica de servidor (notificaciones, reportes)                     |
| **RPC**            | Funciones PostgreSQL llamadas directamente (ej: `get_my_profile`) |

### Variables de Entorno Requeridas

```
SUPABASE_URL=https://xxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOi...
```

---

## 3. 🗃️ Modelo de Datos Completo

### 3.1 Diagrama Entidad-Relación

```
┌─────────────────────┐
│    auth.users        │
│ id          UUID PK  │
│ email       TEXT     │
└────────┬────────────┘
         │ 1:1
┌────────▼────────────────────────────────────────────┐
│                   profiles                           │
│ id                UUID  PK / FK → auth.users(id)     │
│ full_name         TEXT                               │
│ email             TEXT                               │
│ phone             TEXT?                              │
│ avatar_url        TEXT?                              │
│ role              user_role  DEFAULT 'driver'        │
│ company_id        UUID?  FK → companies(id)          │
│ client_company_id UUID?  FK → client_companies(id)   │
│ is_active         BOOL   DEFAULT true                │
│ created_at / updated_at  TIMESTAMPTZ                 │
└──────┬──────────────────────────────┬───────────────┘
       │ N:1                          │ N:1
┌──────▼──────────────┐    ┌──────────▼──────────────┐
│    companies         │    │   client_companies       │
│ (Transportistas)     │    │ (Clientes)               │
│ id     UUID PK       │    │ id            UUID PK    │
│ name   TEXT NN       │    │ name          TEXT NN    │
│ social_reason TEXT?  │    │ nit           TEXT? UQ   │
│ nit    TEXT? UQ      │    │ address       TEXT?      │
│ status TEXT 'active' │    │ contact_email TEXT?      │
│ created_at/updated_at│    │ created_at/updated_at    │
└──────┬──────────────┘    └──────────┬──────────────┘
       │ 1:N                          │ 1:N
       │    ┌─────────────────────┐   │
       └────▶  company_clients    ◀───┘        ┌──────────────────────────┐
            │ (N:N intermedia)    │             │     client_locations     │
            │ id, company_id      │             │ id             UUID PK   │
            │ client_company_id   │             │ client_company_id FK     │
            │ contract_type       │             │ name           TEXT NN   │
            │ status              │             │ type     ENUM (WAREHOUSE,│
            └─────────────────────┘             │   DISTRIBUTION_CENTER,   │
                                                │   OFFICE, PLANT)         │
       ┌────────────────────────┐               │ address, city_id FK      │
       │      vehicles          │               │ latitude, longitude      │
       │ id            UUID PK  │               │ contact_name, phone      │
       │ company_id    FK       │               │ status   ENUM            │
       │ plate_number  TEXT UQ  │               └──────────────────────────┘
       │ brand, model, year     │
       │ color, avatar_url      │                ┌─────────────┐
       │ chasis_code, motor_code│                │   states     │
       │ ruat_number            │                │ id SERIAL PK │
       │ soat/inspection/       │                │ name, code   │
       │   insurance_exp_date   │                │ country_code │
       │ status ENUM            │                └──────┬───────┘
       └───────┬────────────────┘                       │ 1:N
               │ 1:N                             ┌──────▼───────┐
       ┌───────▼──────────────────┐              │   cities     │
       │  vehicle_documents       │              │ id UUID PK   │
       │ id, vehicle_id FK        │              │ name, state_id│
       │ type ENUM (soat,         │              │ lat, lng      │
       │   inspection, insurance, │              └───────────────┘
       │   ruat)                  │
       │ file_url, expiration_date│
       └──────────────────────────┘

       ┌───────────────────────────┐
       │ vehicle_assignments       │
       │ id            UUID PK     │
       │ vehicle_id    FK vehicles │
       │ driver_id     FK profiles │
       │ assigned_by_user_id FK    │
       │ start_date    DATE        │
       │ end_date      DATE?       │
       │ is_active     BOOL        │
       │ UQ(vehicle,driver) activo │
       └───────────────────────────┘

       ┌──────────────────────────────────────────────────┐
       │                    trips                          │
       │ id                    UUID PK                     │
       │ company_id            FK → companies              │
       │ client_company_id     FK → client_companies       │
       │ vehicle_id            FK → vehicles               │
       │ assigned_by_user_id   FK → profiles               │
       │ origin_location_id    FK → client_locations       │
       │ destination_location_id FK → client_locations     │
       │ departure_time        TIMESTAMPTZ?                │
       │ arrival_time          TIMESTAMPTZ?                │
       │ status                ENUM (pending, in_progress, │
       │                        completed, cancelled)      │
       │ price                 NUMERIC(12,2)?              │
       │ created_at / updated_at                           │
       └──────────┬───────────────────────────────────────┘
                  │ 1:N
       ┌──────────▼───────────────────────────────────────┐
       │                  trip_logs                         │
       │ id            UUID PK                              │
       │ trip_id       FK → trips                           │
       │ user_id       FK → profiles (quien registra)       │
       │ driver_id     FK → profiles (conductor del evento) │
       │ event_type    TEXT (14 tipos de evento)             │
       │ description   TEXT?                                │
       │ latitude      DOUBLE?                              │
       │ longitude     DOUBLE?                              │
       │ metadata      JSONB                                │
       │ created_at    TIMESTAMPTZ                          │
       └──────────┬───────────────────────────────────────┘
                  │ 1:N
       ┌──────────▼───────────────────┐
       │     trip_log_media            │
       │ id          UUID PK           │
       │ trip_log_id FK → trip_logs    │
       │ url         TEXT NN           │
       │ type        TEXT (PHOTO,VIDEO)│
       │ caption     TEXT?             │
       │ created_at  TIMESTAMPTZ       │
       └──────────────────────────────┘

       ┌──────────────────────────────┐
       │     finance_groups            │
       │ id          UUID PK           │
       │ company_id  FK → companies    │
       │ name        TEXT NN           │
       │ description TEXT?             │
       │ is_active   BOOL              │
       │ UQ(company_id, name)          │
       └──────────┬───────────────────┘
                  │ 1:N
       ┌──────────▼───────────────────────────────────────┐
       │              finance_records                      │
       │ id                  UUID PK                       │
       │ company_id          FK → companies                │
       │ group_id            FK → finance_groups           │
       │ category_id         FK → finance_categories       │
       │ type                ENUM (INCOME, EXPENSE)        │
       │ amount              NUMERIC(12,2) > 0             │
       │ responsible_user_id FK → profiles?                │
       │ description         TEXT?                         │
       │ record_date         DATE                          │
       │ created_at          TIMESTAMPTZ                   │
       └──────────────────────────────────────────────────┘

       ┌──────────────────────────────┐
       │    finance_categories         │
       │ id          UUID PK           │
       │ company_id  FK → companies    │
       │ name        TEXT NN           │
       │ description TEXT?             │
       │ is_active   BOOL              │
       │ UQ(company_id, name)          │
       └──────────────────────────────┘
```

### 3.2 Detalle de Tablas

#### `profiles` — Usuarios del sistema

| Columna             | Tipo        | Null | Default    | Descripción                                 |
| ------------------- | ----------- | ---- | ---------- | ------------------------------------------- |
| `id`                | UUID        | NO   | —          | PK, FK → `auth.users(id)` ON DELETE CASCADE |
| `full_name`         | TEXT        | SÍ   | —          | Nombre completo                             |
| `email`             | TEXT        | SÍ   | —          | Correo electrónico                          |
| `phone`             | TEXT        | SÍ   | —          | Teléfono                                    |
| `avatar_url`        | TEXT        | SÍ   | —          | URL del avatar (Supabase Storage)           |
| `role`              | user_role   | NO   | `'driver'` | Rol del usuario                             |
| `company_id`        | UUID        | SÍ   | —          | FK → `companies(id)`                        |
| `client_company_id` | UUID        | SÍ   | —          | FK → `client_companies(id)`                 |
| `is_active`         | BOOLEAN     | NO   | `true`     | Si el usuario está activo                   |
| `created_at`        | TIMESTAMPTZ | NO   | `now()`    | Fecha de creación                           |
| `updated_at`        | TIMESTAMPTZ | NO   | `now()`    | Última actualización (trigger automático)   |

> **Regla clave**: Un usuario pertenece a UNA transportista (`company_id`) **O** a UNA empresa cliente (`client_company_id`), **nunca a ambas**. El campo `role` determina el grupo.

#### `companies` — Empresas Transportistas

| Columna         | Tipo        | Null | Default             | Descripción              |
| --------------- | ----------- | ---- | ------------------- | ------------------------ |
| `id`            | UUID        | NO   | `gen_random_uuid()` | PK                       |
| `name`          | TEXT        | NO   | —                   | Nombre comercial         |
| `social_reason` | TEXT        | SÍ   | —                   | Razón social             |
| `nit`           | TEXT        | SÍ   | —                   | NIT (UNIQUE)             |
| `status`        | TEXT        | NO   | `'active'`          | Estado: active, inactive |
| `created_at`    | TIMESTAMPTZ | NO   | `now()`             | Fecha de creación        |
| `updated_at`    | TIMESTAMPTZ | NO   | `now()`             | Última actualización     |

#### `client_companies` — Empresas Clientes

| Columna         | Tipo        | Null | Default             | Descripción          |
| --------------- | ----------- | ---- | ------------------- | -------------------- |
| `id`            | UUID        | NO   | `gen_random_uuid()` | PK                   |
| `name`          | TEXT        | NO   | —                   | Nombre de la empresa |
| `nit`           | TEXT        | SÍ   | —                   | NIT (UNIQUE)         |
| `address`       | TEXT        | SÍ   | —                   | Dirección            |
| `contact_email` | TEXT        | SÍ   | —                   | Email de contacto    |
| `created_at`    | TIMESTAMPTZ | NO   | `now()`             |                      |
| `updated_at`    | TIMESTAMPTZ | NO   | `now()`             |                      |

#### `company_clients` — Relación N:N Transportista ↔ Cliente

| Columna             | Tipo        | Null | Default             | Descripción                                   |
| ------------------- | ----------- | ---- | ------------------- | --------------------------------------------- |
| `id`                | UUID        | NO   | `gen_random_uuid()` | PK                                            |
| `company_id`        | UUID        | NO   | —                   | FK → `companies(id)` ON DELETE CASCADE        |
| `client_company_id` | UUID        | NO   | —                   | FK → `client_companies(id)` ON DELETE CASCADE |
| `contract_type`     | TEXT        | SÍ   | `'standard'`        | Tipo: standard, annual, exclusive, per_trip   |
| `status`            | TEXT        | NO   | `'active'`          | Estado: active, inactive, suspended           |
| `created_at`        | TIMESTAMPTZ | NO   | `now()`             |                                               |
| `updated_at`        | TIMESTAMPTZ | NO   | `now()`             |                                               |

**Constraints:** `UNIQUE(company_id, client_company_id)`

#### `vehicles` — Flota Vehicular

| Columna                      | Tipo           | Null | Default             | Descripción                    |
| ---------------------------- | -------------- | ---- | ------------------- | ------------------------------ |
| `id`                         | UUID           | NO   | `gen_random_uuid()` | PK                             |
| `company_id`                 | UUID           | NO   | —                   | FK → `companies(id)` CASCADE   |
| `plate_number`               | TEXT           | NO   | —                   | Placa (UNIQUE)                 |
| `brand`                      | TEXT           | SÍ   | —                   | Marca                          |
| `model`                      | TEXT           | SÍ   | —                   | Modelo                         |
| `year`                       | INTEGER        | SÍ   | —                   | Año                            |
| `color`                      | TEXT           | SÍ   | —                   | Color                          |
| `avatar_url`                 | TEXT           | SÍ   | —                   | Foto del vehículo              |
| `chasis_code`                | TEXT           | SÍ   | —                   | Código de chasis               |
| `motor_code`                 | TEXT           | SÍ   | —                   | Código de motor                |
| `ruat_number`                | TEXT           | SÍ   | —                   | Número RUAT                    |
| `soat_expiration_date`       | DATE           | SÍ   | —                   | Vencimiento SOAT               |
| `inspection_expiration_date` | DATE           | SÍ   | —                   | Vencimiento inspección técnica |
| `insurance_expiration_date`  | DATE           | SÍ   | —                   | Vencimiento seguro             |
| `status`                     | vehicle_status | NO   | `'active'`          | active, maintenance, inactive  |
| `created_at`                 | TIMESTAMPTZ    | NO   | `now()`             |                                |

#### `vehicle_documents` — Documentos de Vehículos

| Columna           | Tipo                  | Null | Default             | Descripción                        |
| ----------------- | --------------------- | ---- | ------------------- | ---------------------------------- |
| `id`              | UUID                  | NO   | `gen_random_uuid()` | PK                                 |
| `vehicle_id`      | UUID                  | NO   | —                   | FK → `vehicles(id)` CASCADE        |
| `type`            | vehicle_document_type | NO   | —                   | soat, inspection, insurance, ruat  |
| `file_url`        | TEXT                  | SÍ   | —                   | URL del archivo (Supabase Storage) |
| `expiration_date` | DATE                  | SÍ   | —                   | Fecha de vencimiento               |
| `created_at`      | TIMESTAMPTZ           | NO   | `now()`             |                                    |

#### `vehicle_assignments` — Asignación Vehículo ↔ Conductor

| Columna               | Tipo    | Null | Default         | Descripción                   |
| --------------------- | ------- | ---- | --------------- | ----------------------------- |
| `id`                  | UUID    | NO   | gen_random_uuid | PK                            |
| `vehicle_id`          | UUID    | NO   | —               | FK → `vehicles(id)` CASCADE   |
| `driver_id`           | UUID    | NO   | —               | FK → `profiles(id)` CASCADE   |
| `assigned_by_user_id` | UUID    | SÍ   | —               | FK → `profiles(id)` SET NULL  |
| `start_date`          | DATE    | NO   | CURRENT_DATE    | Inicio de la asignación       |
| `end_date`            | DATE    | SÍ   | —               | Fin de la asignación          |
| `is_active`           | BOOLEAN | NO   | `true`          | Si la asignación está vigente |
| `created_at`          | TSTZ    | NO   | `now()`         |                               |

**Constraint:** `UNIQUE(vehicle_id, driver_id) WHERE is_active = true` — Solo una asignación activa por par conductor-vehículo.

#### `client_locations` — Ubicaciones de Empresas Clientes

| Columna             | Tipo                   | Null | Default         | Descripción                                   |
| ------------------- | ---------------------- | ---- | --------------- | --------------------------------------------- |
| `id`                | UUID                   | NO   | gen_random_uuid | PK                                            |
| `client_company_id` | UUID                   | NO   | —               | FK → `client_companies(id)` CASCADE           |
| `name`              | TEXT                   | NO   | —               | Nombre de la ubicación                        |
| `type`              | client_location_type   | NO   | `'WAREHOUSE'`   | WAREHOUSE, DISTRIBUTION_CENTER, OFFICE, PLANT |
| `address`           | TEXT                   | SÍ   | —               | Dirección                                     |
| `city_id`           | UUID                   | SÍ   | —               | FK → `cities(id)`                             |
| `country`           | TEXT                   | NO   | `'Bolivia'`     | País                                          |
| `latitude`          | DOUBLE                 | SÍ   | —               | Latitud GPS                                   |
| `longitude`         | DOUBLE                 | SÍ   | —               | Longitud GPS                                  |
| `contact_name`      | TEXT                   | SÍ   | —               | Nombre de contacto                            |
| `contact_phone`     | TEXT                   | SÍ   | —               | Teléfono de contacto                          |
| `status`            | client_location_status | NO   | `'ACTIVE'`      | ACTIVE, INACTIVE                              |
| `created_at`        | TIMESTAMPTZ            | NO   | `now()`         |                                               |

#### `trips` — Viajes

| Columna                   | Tipo          | Null | Default     | Descripción                                |
| ------------------------- | ------------- | ---- | ----------- | ------------------------------------------ |
| `id`                      | UUID          | NO   | gen_random  | PK                                         |
| `company_id`              | UUID          | NO   | —           | FK → `companies(id)` CASCADE               |
| `client_company_id`       | UUID          | NO   | —           | FK → `client_companies(id)` CASCADE        |
| `vehicle_id`              | UUID          | NO   | —           | FK → `vehicles(id)` RESTRICT               |
| `assigned_by_user_id`     | UUID          | SÍ   | —           | FK → `profiles(id)` SET NULL               |
| `origin_location_id`      | UUID          | NO   | —           | FK → `client_locations(id)` RESTRICT       |
| `destination_location_id` | UUID          | NO   | —           | FK → `client_locations(id)` RESTRICT       |
| `departure_time`          | TIMESTAMPTZ   | SÍ   | —           | Hora de salida                             |
| `arrival_time`            | TIMESTAMPTZ   | SÍ   | —           | Hora de llegada                            |
| `status`                  | trip_status   | NO   | `'pending'` | pending, in_progress, completed, cancelled |
| `price`                   | NUMERIC(12,2) | SÍ   | —           | Precio del viaje (Bs.)                     |
| `created_at`              | TIMESTAMPTZ   | NO   | `now()`     |                                            |
| `updated_at`              | TIMESTAMPTZ   | NO   | `now()`     |                                            |

> **Nota importante**: El viaje se asigna al **vehículo**, no al conductor. El conductor se determina a través de la tabla `vehicle_assignments`.

#### `trip_logs` — Bitácora de Eventos del Viaje

| Columna       | Tipo        | Null | Default      | Descripción                      |
| ------------- | ----------- | ---- | ------------ | -------------------------------- |
| `id`          | UUID        | NO   | gen_random   | PK                               |
| `trip_id`     | UUID        | NO   | —            | FK → `trips(id)` CASCADE         |
| `user_id`     | UUID        | SÍ   | —            | FK → `profiles(id)` SET NULL     |
| `driver_id`   | UUID        | SÍ   | —            | FK → `profiles(id)` SET NULL     |
| `event_type`  | TEXT        | NO   | `'ASSIGNED'` | Tipo de evento (ver tabla abajo) |
| `description` | TEXT        | SÍ   | —            | Descripción/notas del evento     |
| `latitude`    | DOUBLE      | SÍ   | —            | Latitud GPS del evento           |
| `longitude`   | DOUBLE      | SÍ   | —            | Longitud GPS del evento          |
| `metadata`    | JSONB       | SÍ   | `'{}'`       | Datos adicionales flexibles      |
| `created_at`  | TIMESTAMPTZ | NO   | `now()`      |                                  |

##### Tipos de Evento de trip_logs (`event_type`)

| Valor                    | Etiqueta (ES)       | Icono | Descripción                   |
| ------------------------ | ------------------- | ----- | ----------------------------- |
| `ASSIGNED`               | Asignado            | 📋    | Viaje asignado al conductor   |
| `STARTED`                | Iniciado            | 🚀    | Conductor inicia el viaje     |
| `ARRIVED_AT_ORIGIN`      | Llegó al Origen     | 📍    | Llega al punto de carga       |
| `LOADING_STARTED`        | Carga Iniciada      | 📦    | Inicio de carga de mercadería |
| `LOADING_COMPLETED`      | Carga Completada    | ✅    | Carga terminada               |
| `DEPARTED`               | En Camino           | 🚛    | Sale del origen               |
| `ARRIVED_AT_STOP`        | Llegó a Parada      | 🛑    | Parada intermedia             |
| `INCIDENT`               | Incidente           | ⚠️    | Incidente en ruta             |
| `DELAY`                  | Retraso             | ⏱️    | Retraso reportado             |
| `ARRIVED_AT_DESTINATION` | Llegó al Destino    | 🏁    | Llega al destino final        |
| `UNLOADING_STARTED`      | Descarga Iniciada   | 📦    | Inicio de descarga            |
| `UNLOADING_COMPLETED`    | Descarga Completada | ✅    | Descarga terminada            |
| `COMPLETED`              | Completado          | 🎉    | Viaje completado exitosamente |
| `CANCELLED`              | Cancelado           | ❌    | Viaje cancelado               |

#### `trip_log_media` — Media de la Bitácora

| Columna       | Tipo | Null | Default    | Descripción                  |
| ------------- | ---- | ---- | ---------- | ---------------------------- |
| `id`          | UUID | NO   | gen_random | PK                           |
| `trip_log_id` | UUID | NO   | —          | FK → `trip_logs(id)` CASCADE |
| `url`         | TEXT | NO   | —          | URL del archivo (Storage)    |
| `type`        | TEXT | NO   | `'PHOTO'`  | PHOTO o VIDEO                |
| `caption`     | TEXT | SÍ   | —          | Descripción                  |
| `created_at`  | TSTZ | NO   | `now()`    |                              |

#### `finance_groups` — Grupos Financieros

| Columna       | Tipo    | Null | Default    | Descripción                  |
| ------------- | ------- | ---- | ---------- | ---------------------------- |
| `id`          | UUID    | NO   | gen_random | PK                           |
| `company_id`  | UUID    | NO   | —          | FK → `companies(id)` CASCADE |
| `name`        | TEXT    | NO   | —          | Nombre del grupo             |
| `description` | TEXT    | SÍ   | —          | Descripción                  |
| `is_active`   | BOOLEAN | NO   | `true`     | Si está activo en selectores |
| `created_at`  | TSTZ    | NO   | `now()`    |                              |

**Constraint:** `UNIQUE(company_id, name)`

#### `finance_categories` — Categorías Financieras

| Columna       | Tipo    | Null | Default    | Descripción                  |
| ------------- | ------- | ---- | ---------- | ---------------------------- |
| `id`          | UUID    | NO   | gen_random | PK                           |
| `company_id`  | UUID    | NO   | —          | FK → `companies(id)` CASCADE |
| `name`        | TEXT    | NO   | —          | Nombre de la categoría       |
| `description` | TEXT    | SÍ   | —          | Descripción                  |
| `is_active`   | BOOLEAN | NO   | `true`     | Si está activa en selectores |
| `created_at`  | TSTZ    | NO   | `now()`    |                              |

**Constraint:** `UNIQUE(company_id, name)`

#### `finance_records` — Registros/Movimientos Financieros

| Columna               | Tipo                | Null | Default      | Descripción                            |
| --------------------- | ------------------- | ---- | ------------ | -------------------------------------- |
| `id`                  | UUID                | NO   | gen_random   | PK                                     |
| `company_id`          | UUID                | NO   | —            | FK → `companies(id)` CASCADE           |
| `group_id`            | UUID                | NO   | —            | FK → `finance_groups(id)` RESTRICT     |
| `category_id`         | UUID                | NO   | —            | FK → `finance_categories(id)` RESTRICT |
| `type`                | finance_record_type | NO   | `'EXPENSE'`  | INCOME o EXPENSE                       |
| `amount`              | NUMERIC(12,2)       | NO   | —            | Monto en Bs. (siempre > 0)             |
| `responsible_user_id` | UUID                | SÍ   | —            | FK → `profiles(id)` SET NULL           |
| `description`         | TEXT                | SÍ   | —            | Descripción del movimiento             |
| `record_date`         | DATE                | NO   | CURRENT_DATE | Fecha del movimiento                   |
| `created_at`          | TIMESTAMPTZ         | NO   | `now()`      |                                        |

> **Moneda**: Todos los montos en Bolivianos (Bs.).

#### `states` — Departamentos/Estados

| Columna        | Tipo         | Null | Default | Descripción      |
| -------------- | ------------ | ---- | ------- | ---------------- |
| `id`           | SERIAL       | NO   | auto    | PK               |
| `name`         | VARCHAR(150) | NO   | —       | Nombre del depto |
| `code`         | VARCHAR(10)  | SÍ   | —       | Código abreviado |
| `country_code` | VARCHAR(5)   | NO   | `'BO'`  | Código de país   |

#### `cities` — Ciudades

| Columna     | Tipo         | Null | Default    | Descripción         |
| ----------- | ------------ | ---- | ---------- | ------------------- |
| `id`        | UUID         | NO   | gen_random | PK                  |
| `name`      | VARCHAR(150) | NO   | —          | Nombre de la ciudad |
| `state_id`  | INT          | SÍ   | —          | FK → `states(id)`   |
| `latitude`  | DOUBLE       | SÍ   | —          | Latitud             |
| `longitude` | DOUBLE       | SÍ   | —          | Longitud            |

---

## 4. 🔐 Enums de la Base de Datos

### `user_role`

```sql
'super_admin', 'admin', 'supervisor', 'driver', 'finance', 'client_admin', 'client_user'
```

### `vehicle_status`

```sql
'active', 'maintenance', 'inactive'
```

### `vehicle_document_type`

```sql
'soat', 'inspection', 'insurance', 'ruat'
```

### `trip_status`

```sql
'pending', 'in_progress', 'completed', 'cancelled'
```

### `client_location_type`

```sql
'WAREHOUSE', 'DISTRIBUTION_CENTER', 'OFFICE', 'PLANT'
```

### `client_location_status`

```sql
'ACTIVE', 'INACTIVE'
```

### `finance_record_type`

```sql
'INCOME', 'EXPENSE'
```

---

## 5. 🔒 Sistema de Roles y Permisos

### Jerarquía

```
Grupo Transporte              Grupo Cliente
─────────────────             ─────────────────
super_admin (nivel 0)  ───►   Permiso sobre TODOS
  └─ admin (nivel 1)          client_admin (nivel 5)
       └─ supervisor (nivel 2)  └─ client_user (nivel 6)
            └─ driver (nivel 3)
            └─ finance (nivel 4)
```

### Reglas de permisos

- Roles del **mismo grupo** comparan por posición jerárquica (menor índice = mayor permiso).
- Roles de **grupos distintos** NO tienen permiso cruzado.
- **`super_admin`** es la excepción: tiene permiso sobre TODOS los roles.
- Un usuario pertenece a UNA empresa transportista **O** a UNA empresa cliente, nunca a ambas.

### Matriz de Permisos por Módulo

| Módulo                  | super_admin  | admin             | supervisor       | driver        | finance | client_admin      | client_user |
| ----------------------- | ------------ | ----------------- | ---------------- | ------------- | ------- | ----------------- | ----------- |
| **Companies**           | CRUD         | R (propia)        | R (propia)       | R (propia)    | —       | —                 | —           |
| **Client Companies**    | CRUD         | R (asociadas)     | —                | —             | —       | R (propia)        | R (propia)  |
| **Company Clients**     | CRUD         | R (su empresa)    | —                | —             | —       | R (su empresa)    | —           |
| **Profiles/Users**      | CRUD (todos) | CRUD (su empresa) | —                | R (propio)    | —       | CRUD (su empresa) | R (propio)  |
| **Vehicles**            | CRUD         | CRUD (su empresa) | R (su empresa)   | —             | —       | —                 | —           |
| **Vehicle Documents**   | CRUD         | CRUD (su empresa) | R                | —             | —       | —                 | —           |
| **Vehicle Assignments** | CRUD         | CRUD (su empresa) | R (su empresa)   | R (propias)   | —       | —                 | —           |
| **Trips**               | CRUD         | CRUD (su empresa) | R (su empresa)   | R (asignados) | —       | —                 | —           |
| **Trip Logs**           | CRUD         | CRUD              | CRUD             | CR (propios)  | —       | —                 | —           |
| **Trip Log Media**      | CRUD         | CRD               | CRD              | CR            | —       | —                 | —           |
| **Client Locations**    | CRUD         | CR (asociadas)    | —                | —             | —       | CR (propia)       | R (propia)  |
| **Finance Groups**      | CRUD         | CRUD (su empresa) | CRU (su empresa) | —             | —       | —                 | —           |
| **Finance Categories**  | CRUD         | CRUD (su empresa) | CRU (su empresa) | —             | —       | —                 | —           |
| **Finance Records**     | CRUD         | CRUD (su empresa) | CRU (su empresa) | —             | —       | —                 | —           |

---

## 6. 🔧 Funciones PostgreSQL (RPC / SECURITY DEFINER)

Estas funciones ya existen en la BD y son usadas por las políticas RLS:

| Función                        | Retorna     | Descripción                                          |
| ------------------------------ | ----------- | ---------------------------------------------------- |
| `get_my_role()`                | `user_role` | Rol del usuario autenticado                          |
| `get_my_company_id()`          | `UUID`      | `company_id` del usuario autenticado                 |
| `get_my_client_company_id()`   | `UUID`      | `client_company_id` del usuario autenticado          |
| `get_user_email(user_id UUID)` | `TEXT`      | Email de un usuario por su ID                        |
| `get_my_profile()`             | `JSON`      | Perfil completo con joins a company y client_company |
| `handle_new_user()`            | TRIGGER     | Crea perfil automáticamente al registrarse           |
| `set_updated_at()`             | TRIGGER     | Actualiza `updated_at` automáticamente               |

---

## 7. 🎨 Sistema de Diseño

### Paleta de Colores

| Color             | Hex       | Uso                                     |
| ----------------- | --------- | --------------------------------------- |
| Azul principal    | `#0A3D62` | Fondos principales, navegación, headers |
| Azul claro        | `#1E5A9E` | Acentos, hover, degradados              |
| Dorado principal  | `#D4AF37` | Botones CTA, iconos, highlights         |
| Dorado secundario | `#EFBF04` | Detalles sutiles                        |
| Gris neutro       | `#475569` | Textos secundarios, bordes              |
| Gris oscuro       | `#334155` | Textos de cuerpo                        |
| Fondo claro       | `#F8FAFC` | Fondo modo claro                        |
| Fondo oscuro      | `#0F172A` | Fondo modo oscuro                       |
| Blanco/off-white  | `#F1F5F9` | Fondos de tarjetas                      |
| Verde éxito       | `#15803D` | Estado "entregado", confirmaciones      |

### Tipografía

- **Títulos**: Inter Bold/Black, 24-40px, Dorado o Navy.
- **Subtítulos**: Inter SemiBold, 18-24px, Navy o Gris.
- **Cuerpo**: Inter Regular, 14-16px, Gris oscuro.
- **Botones CTA**: Inter Bold, 16px, Fondo dorado + texto navy.

### Espaciado

- Border radius: `15px`
- Padding/margin estándar: `15px`
- Margin small: `5px`, medium: `20px`, big: `30px`

### Tema

- Soporta **modo claro y oscuro**.

---

## 8. 🌐 Idioma

- Todo el contenido visible al usuario se escribe **directamente en español**.
- **NO** se utiliza internacionalización (i18n/ARB).
- Contexto geográfico: **Bolivia**.
- Moneda: **Bolivianos (Bs.)**.

---

## 9. 📱 Pantallas de la App Móvil (Referencia)

Estas son las vistas que la app móvil tiene. El administrador web debería cubrir las funciones de **gestión/administración** de estas vistas:

| Vista                  | Descripción                                       | Web Admin                      |
| ---------------------- | ------------------------------------------------- | ------------------------------ |
| `auth/`                | Login y bienvenida                                | ✅ Login                       |
| `home/`                | Dashboard principal                               | ✅ Dashboard                   |
| `companies/`           | Gestión de empresas transportistas                | ✅ CRUD                        |
| `client_companies/`    | Gestión de empresas clientes                      | ✅ CRUD                        |
| `client_locations/`    | Ubicaciones de empresas clientes                  | ✅ CRUD + Mapa                 |
| `users/`               | Gestión de usuarios (crear, editar, roles)        | ✅ CRUD                        |
| `vehicles/`            | Gestión de flota vehicular + documentos           | ✅ CRUD                        |
| `vehicle_assignments/` | Asignación de conductores a vehículos             | ✅ CRUD                        |
| `trips/`               | Gestión de viajes (crear, asignar, estados)       | ✅ CRUD + Vista detalle        |
| `trip_logs/`           | Bitácora de eventos del viaje                     | ✅ Vista detalle / Timeline    |
| `trip_map/`            | Mapa del recorrido del viaje                      | ✅ Mapa interactivo            |
| `my_trips/`            | Viajes del conductor (vista móvil)                | ❌ Solo móvil                  |
| `finance/`             | Módulo financiero (grupos, categorías, registros) | ✅ CRUD + Reportes             |
| `profile/`             | Perfil del usuario                                | ✅ Perfil                      |
| `settings/`            | Configuraciones (tema)                            | ✅ Ajustes                     |
| `notification/`        | Notificaciones                                    | ✅ Notificaciones              |
| `splash/`              | Pantalla de carga                                 | ❌ No aplica                   |
| `navigation/`          | Barra de navegación inferior                      | ❌ No aplica (web usa sidebar) |

---

## 10. 📊 Funcionalidades Sugeridas para el Admin Web

### Dashboard

- Total de viajes por estado (pending, in_progress, completed, cancelled).
- Viajes activos en mapa en tiempo real.
- Resumen financiero (ingresos vs egresos del mes).
- Vehículos con documentos próximos a vencer.
- Usuarios activos.

### Módulo de Viajes (Trips)

- Tabla con filtros por estado, empresa cliente, vehículo, rango de fechas.
- Detalle de viaje con timeline de eventos (trip_logs).
- Mapa con ruta del viaje (puntos de trip_logs georreferenciados).
- Galería de fotos/videos por evento.

### Módulo Financiero

- Tabla de registros con filtros por grupo, categoría, tipo (ingreso/egreso), rango de fechas.
- Gráficos de ingresos vs egresos.
- CRUD de grupos y categorías.
- Exportación a Excel/PDF.

### Módulo de Vehículos

- Lista de flota con estado y alertas de documentos vencidos/por vencer.
- CRUD de vehículos con carga de documentos.
- Vista de asignaciones conductor-vehículo.

### Módulo de Usuarios

- Lista de usuarios con filtros por rol, empresa, estado.
- Crear/editar usuarios con asignación de rol y empresa.
- Activar/desactivar usuarios.

### Reportes

- Reportes de viajes por período, empresa cliente, vehículo.
- Reportes financieros con totales y promedios.
- Exportación a PDF/Excel.

---

## 11. 🔗 Integración con Supabase (Guía para el Web Admin)

### Autenticación

```javascript
// Ejemplo con @supabase/supabase-js
const { data, error } = await supabase.auth.signInWithPassword({
  email: "admin@empresa.com",
  password: "password123",
});
```

### Consultar perfil del usuario actual

```javascript
const { data } = await supabase.rpc("get_my_profile");
```

### Ejemplo CRUD (viajes con joins)

```javascript
// Listar viajes con relaciones
const { data } = await supabase
  .from("trips")
  .select(
    `
    *,
    company:companies(*),
    client_company:client_companies(*),
    vehicle:vehicles(*),
    assigned_by:profiles!assigned_by_user_id(id, full_name, email),
    origin_location:client_locations!origin_location_id(*, city:cities(*, state:states(*))),
    destination_location:client_locations!destination_location_id(*, city:cities(*, state:states(*)))
  `,
  )
  .order("created_at", { ascending: false });
```

### Realtime (suscripción a cambios)

```javascript
supabase
  .channel("trips-changes")
  .on(
    "postgres_changes",
    { event: "*", schema: "public", table: "trips" },
    (payload) => {
      console.log("Cambio en viajes:", payload);
    },
  )
  .subscribe();
```

### Storage (subir archivos)

```javascript
const { data } = await supabase.storage
  .from("vehicle-documents")
  .upload(`vehicles/${vehicleId}/${file.name}`, file);
```

---

## 12. 📝 Notas Importantes para el Desarrollo Web

1. **Misma instancia de Supabase**: El admin web debe conectarse a la misma base de datos que la app móvil.
2. **RLS activo**: Todas las tablas tienen Row Level Security. Las consultas se filtran automáticamente según el rol del usuario autenticado.
3. **No duplicar lógica de permisos**: Confiar en las políticas RLS de Supabase para filtrar datos. Solo validar en frontend para UX.
4. **Triggers automáticos**: `updated_at` se actualiza automáticamente. Al crear un usuario en Auth, se crea el perfil automáticamente.
5. **Roles del web admin**: El panel web está pensado principalmente para roles `super_admin`, `admin`, `supervisor` y `finance`. Los conductores usan la app móvil.
6. **Idioma**: Todo en español, sin i18n.
7. **Moneda**: Bolivianos (Bs.), formato `NUMERIC(12,2)`.
8. **País**: Bolivia. Los departamentos y ciudades son de Bolivia.
9. **Zona horaria**: Usar `TIMESTAMPTZ` (timestamps con timezone). Bolivia usa UTC-4.

---

> **Documento generado el**: 17 de marzo de 2026
> **Desde el proyecto**: `bitacora` (Flutter Mobile App)
> **Versión del proyecto**: 1.0.0+1
