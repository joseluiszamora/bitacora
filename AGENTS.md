# 🤖 AGENTS.md — Instrucciones para IA

> Documento de referencia para que cualquier agente de IA (GitHub Copilot, Cursor, etc.) comprenda las tecnologías, arquitectura, convenciones de estilo e instrucciones necesarias para trabajar en este proyecto.

---

## 📋 Información General del Proyecto

| Campo              | Valor                               |
| ------------------ | ----------------------------------- |
| **Nombre**         | `bitacora` (BITACORA de Transporte) |
| **Plataforma**     | Flutter (Android & iOS)             |
| **Dart SDK**       | `^3.10.1`                           |
| **Versión actual** | `1.0.0+1`                           |
| **Bundle ID**      | `bo.monval.bitacora`                |
| **Idioma**         | Español (sin i18n)                  |

---

## 🏗️ Arquitectura del Proyecto

### Estructura de carpetas

```
lib/
├── main.dart                        # Punto de entrada
├── core/                            # Lógica de negocio y utilidades compartidas
│   ├── blocs/                       # BLoCs (Business Logic Components)
│   │   ├── auth/                    # Autenticación (login, logout)
│   │   ├── bitacora/                # Registro de eventos de la bitacora (salida de almacen, llegada a destino, parada momentanea, etc.)
│   │   ├── finanzas/                # Registro de eventos financieros (gastos en el viaje)
│   │   ├── notifications/           # Notificaciones Socket.IO
│   │   ├── permission/              # Permisos del dispositivo
│   │   ├── service_locator.dart     # Inyección de dependencias con GetIt
│   │   └── blocs.dart               # Barrel file de todos los BLoCs
│   ├── components/                  # Widgets reutilizables (botones, cards, formularios, snackbars)
│   ├── constants/                   # Colores, configuración, dimensiones, iconos
│   │   ├── app_colors.dart          # Paleta de colores de la app
│   │   ├── app_defaults.dart        # Tamaños, márgenes, radios, tipografía
│   │   ├── app_icons.dart           # Iconos personalizados
│   │   ├── app_images.dart          # Rutas a imágenes
│   │   └── config.dart              # URLs base de la API y claves
│   ├── data/
│   │   ├── api/
│   │   │   ├── api_client.dart      # Cliente Dio con interceptores
│   │   │   └── network_exception.dart
│   │   ├── models/                  # Modelos de datos (User, Bitacora, etc.)
│   │   ├── providers/               # Proveedores de datos (llamadas API + LocalStorage)
│   │   └── repositories/           # Repositorios (capa intermedia entre BLoC y Provider)
│   ├── layouts/                     # Layouts reutilizables (auth, modales, sub-páginas)
│   ├── services/                    # Servicios (navegación, notificaciones)
│   ├── themes/                      # Temas claro y oscuro
│   └── utils/                       # Utilidades (fingerprint, responsive, image manager)
└── views/                           # Pantallas organizadas por feature
    ├── auth/                        # Login, bienvenida
    ├── home/                        # Pantalla principal
    ├── navigation/                  # Barra de navegación inferior
    ├── notification/                # Notificaciones
    ├── profile/                     # Perfil de usuario
    ├── splash/                      # Splash screen
```

### Patrón de Arquitectura

Se utiliza **BLoC Pattern** con la siguiente separación por capas:

```
Vista (Widget) → BLoC (Lógica) → Repository → Provider → API (Dio)
```

- **Widget**: Solo UI. Consume estados del BLoC con `BlocBuilder` / `BlocListener`.
- **BLoC**: Maneja eventos y emite estados. Usa `Equatable` para comparación de estados.
- **Repository**: Orquesta llamadas a uno o más providers.
- **Provider**: Realiza llamadas HTTP (Dio) o acceso a almacenamiento local.
- **Model**: Clases de datos inmutables.

---

## 🧰 Stack Tecnológico

### Dependencias Principales

| Categoría            | Paquete                                                   | Versión                  |
| -------------------- | --------------------------------------------------------- | ------------------------ |
| **State Management** | `flutter_bloc` / `bloc`                                   | ^9.1.1 / ^9.2.0          |
| **HTTP Client**      | `dio`                                                     | ^5.9.1                   |
| **DI (Inyección)**   | `get_it`                                                  | ^8.3.0                   |
| **Almacenamiento**   | `flutter_secure_storage` / `shared_preferences`           | ^9.2.4 / ^2.5.4          |
| **Formularios**      | `flutter_form_builder` / `formz`                          | ^10.3.0+1 / ^0.8.0       |
| **Mapas**            | `flutter_map` / `latlong2`                                | ^8.2.2 / ^0.9.1          |
| **Imágenes**         | `image_picker` / `image_cropper` / `cached_network_image` | ^1.2.1 / ^9.1.0 / ^3.3.1 |
| **Iconos**           | `font_awesome_flutter`                                    | ^10.12.0                 |
| **Animaciones**      | `lottie`                                                  | ^3.1.2                   |
| **SVG**              | `flutter_svg`                                             | ^2.2.3                   |
| **WebSocket**        | `socket_io_client`                                        | ^3.1.4                   |
| **Permisos**         | `permission_handler`                                      | ^12.0.1                  |
| **JWT**              | `jwt_decoder`                                             | ^2.0.1                   |
| **Geolocalización**  | `geolocator`                                              | ^14.0.2                  |

### Android

| Campo       | Valor         |
| ----------- | ------------- |
| AGP         | 8.9.1         |
| Gradle      | 8.11.1        |
| Kotlin      | 2.1.0         |
| Java Target | 11            |
| NDK         | 27.0.12077973 |

### iOS

| Campo             | Valor |
| ----------------- | ----- |
| Deployment Target | 15.0  |
| CocoaPods         | Sí    |

---

## 🎨 Sistema de Diseño

### Paleta de Colores (`AppColors`)

```dart
Azul principal (fondo/nav, headers): #0A3D62
Azul más claro (acentos tech, hover): #1E5A9E o #234FBA
Dorado principal (botones CTA, iconos éxito, highlights): #D4AF37
Dorado secundario (detalles sutiles): #EFBF04
Gris neutro (textos secundarios, bordes): #475569 o #334155
Fondo principal: #F8FAFC (claro) o #0F172A (modo oscuro)
Blanco / off-white: #FFFFFF o #F1F5F9
Verde éxito (opcional, para "entregado"): #15803D
```

### Cómo usarlo en la app

```dart
Fondo / navegación principal → #0A3D62 (o degradado a #1E5A9E)
Botones primarios (aceptar carga, rastrear) → #D4AF37 con texto #0A3D62 o blanco
Iconos de estado (cargado, en ruta, entregado) → toques de #EFBF04 o #D4AF37
Tarjetas de carga / rutas → fondo blanco/gris claro con borde sutil dorado
Modo oscuro → fondo #0A3D62 o más oscuro, acentos dorados brillan mucho más
```

### Tipografía

| Elemento                | Tipografía                | Peso         | Tamaño aprox (mobile) | Color sugerido              |
| ----------------------- | ------------------------- | ------------ | --------------------- | --------------------------- |
| Títulos / Headers       | Inter o Plus Jakarta Sans | Bold / Black | 24–40px               | Dorado #D4AF37 o #EFBF04    |
| Subtítulos / Cards      | Inter                     | SemiBold     | 18–24px               | Navy #0A3D62 o gris #475569 |
| Texto cuerpo / Detalles | Inter o Figtree           | Regular      | 14–16px               | Gris oscuro #334155         |
| Etiquetas / Botones CTA | Inter Bold                | Bold         | 16px                  | Fondo dorado + texto navy   |
| Números / Datos clave   | Inter o Space Grotesk     | Bold         | 20–28px               | Dorado o navy               |

### Dimensiones y Espaciado (`AppDefaults`)

```dart
radius       = 15.0    // Border radius estándar
padding      = 15.0    // Padding general
margin       = 15.0    // Margen general
marginSmall  = 5.0
marginMedium = 20.0
marginBig    = 30.0
```

### Tema

- La app soporta **tema claro y oscuro** (`AppTheme.lightTheme`, `AppTheme.darkTheme`).

---

## 🌐 Idioma

- Todo el contenido visible al usuario (textos, mensajes de error, labels, placeholders) se escribe **directamente en español**.
- **No** se utiliza internacionalización (i18n), archivos ARB ni `AppLocalizations`.
- Los strings se pueden colocar directamente en los widgets o extraer a constantes en archivos dedicados si se repiten.

---

## 📐 Convenciones de Código

### Estructura de un Feature (por ejemplo: `bitacora`)

```
views/bitacora/
├── bitacora_page.dart              # Página principal (entry point)
├── screens/                       # Sub-pantallas
│   ├── new_bitacora.dart
│   ├── bitacora_form_new.dart
│   ├── bitacora_list.dart
│   └── bitacora_form_edit.dart
├── components/                    # Widgets específicos del feature
│   ├── bitacora_element.dart
└── blocs/                         # BLoCs específicos del feature
    └── bitacora/
        ├── bitacora_bloc.dart
        ├── bitacora_event.dart
        └── bitacora_state.dart
    └── bitacora_form/
        ├── bitacora_form_bloc.dart
        ├── bitacora_form_event.dart
        └── bitacora_form_state.dart
```

### Convenciones de Nombrado

| Elemento          | Convención             | Ejemplo                  |
| ----------------- | ---------------------- | ------------------------ |
| Archivos          | `snake_case.dart`      | `user_profile_page.dart` |
| Clases            | `PascalCase`           | `UserProfilePage`        |
| Variables/Métodos | `camelCase`            | `onLoginHandler`         |
| Constantes        | `camelCase` (estático) | `AppColors.primary`      |
| BLoC Events       | `PascalCase`           | `LoginSubmitted`         |
| BLoC States       | `PascalCase`           | `AuthenticationState`    |
| Privados          | Prefijo `_`            | `_buildSectionTitle()`   |

### Reglas de Estilo

1. **Widgets privados como métodos**: Los widgets auxiliares dentro de una página se crean como métodos privados (`_buildXxx()`), no como clases separadas, a menos que sean reutilizables.
2. **Composición sobre herencia**: Preferir composición de widgets.
3. **`const` siempre que sea posible**: Usar `const` en constructores y widgets estáticos.
4. **Parámetros nombrados**: Preferir `required` named parameters en constructores de widgets.
5. **Trailing commas**: Usar trailing commas para facilitar el formato de Dart.
6. **Separación por `SizedBox`**: Usar `SizedBox(height: X)` para espaciado vertical entre widgets.

---

## 🔌 Capa de Datos

### Cliente HTTP (Dio)

- Base URL configurada en `Config.baseMTVirtual`.
- Interceptores en `AppInterceptors`:
  - Adjunta `Authorization: Bearer <token>` automáticamente si el header `requiresToken` está presente.
  - Maneja errores de conexión y redirige a logout si el token expira.
- Timeouts: `connectTimeout: 10s`, `receiveTimeout: 10s`.

### Almacenamiento Local

- `flutter_secure_storage`: Para datos sensibles (token JWT, contraseña).
- `shared_preferences`: Para preferencias del usuario (tema).
- Acceso centralizado via `LocalStorage` en `lib/core/data/providers/local_storage.dart`.

---

## 🧭 Navegación

- La navegación se gestiona mediante un `NavigationService` en `lib/core/services/`.
- La app usa una **barra de navegación inferior** (`BottomNavigationBar`) definida en `views/navigation/`.
- Para navegar entre pantallas se usa `Navigator` con rutas nombradas o push directo.
- Las rutas principales se definen en `main.dart` o en un archivo dedicado `routes.dart`.

### Convenciones de navegación

1. **No** navegar directamente desde un BLoC; emitir un estado y que el widget reaccione con `BlocListener`.
2. Para modales y bottom sheets, usar los layouts reutilizables de `core/layouts/`.
3. Los argumentos de navegación se pasan como objetos tipados, no como `Map<String, dynamic>`.

---

## 🧪 Testing

### Estructura de tests

```
test/
├── unit/                          # Tests unitarios (BLoCs, Repositories, Models)
│   ├── blocs/
│   ├── models/
│   └── repositories/
├── widget/                        # Tests de widgets individuales
│   ├── components/
│   └── views/
└── helpers/                       # Mocks, fixtures, utilidades de test
    ├── mocks.dart
    └── test_helpers.dart
```

### Convenciones de testing

1. Nombrar archivos de test como `<archivo_original>_test.dart`.
2. Usar `bloc_test` para testear BLoCs con `blocTest()`.
3. Usar `mocktail` para crear mocks de repositories y providers.
4. Cada BLoC debe tener tests para: estado inicial, cada evento, y casos de error.
5. Los tests de widgets deben verificar que los estados del BLoC se reflejan correctamente en la UI.

### Ejemplo de test de BLoC

```dart
blocTest<LoginBloc, LoginState>(
  'emite [LoginLoading, LoginSuccess] cuando las credenciales son válidas',
  build: () {
    when(() => mockAuthRepository.login(any(), any()))
        .thenAnswer((_) async => mockUser);
    return LoginBloc(authRepository: mockAuthRepository);
  },
  act: (bloc) => bloc.add(const LoginSubmitted(email: 'test@test.com', password: '1234')),
  expect: () => [isA<LoginLoading>(), isA<LoginSuccess>()],
);
```

---

## 🔑 Inyección de Dependencias

Se utiliza **GetIt** como Service Locator. Los BLoCs y servicios se registran en `service_locator.dart`:

```dart
void serviceLocatorInit() {
  getIt.registerSingleton(AuthenticationBloc()..add(AuthenticationStatusChecked()));
  getIt.registerSingleton(LoginBloc());
  getIt.registerSingleton(CardBloc());
  // ...etc
}
```

### Cuándo usar cada tipo de registro

| Método                  | Cuándo usarlo                                                                 | Ejemplo                           |
| ----------------------- | ----------------------------------------------------------------------------- | --------------------------------- |
| `registerSingleton`     | BLoCs globales que viven toda la vida de la app (auth, notificaciones, theme) | `AuthenticationBloc`, `ThemeBloc` |
| `registerFactory`       | BLoCs que se crean/destruyen por pantalla o formulario                        | `BitacoraFormBloc`                |
| `registerLazySingleton` | Servicios que se instancian solo cuando se usan por primera vez               | `NavigationService`               |

### Acceso a dependencias

```dart
// Desde cualquier lugar (sin contexto):
getIt<AuthenticationBloc>().add(MiEvento());

// Desde widgets (con contexto):
context.read<MiBloc>().add(MiEvento());
// o
BlocProvider.of<MiBloc>(context).add(MiEvento());
```

> **Nota**: Preferir `context.read<T>()` en widgets. Usar `getIt<T>()` solo en código sin acceso a `BuildContext` (services, repositories).

---

## 📝 Instrucciones para la IA

### Al crear un nuevo feature:

1. Crear la carpeta dentro de `views/<feature>/` con subcarpetas `screens/`, `components/`, y `blocs/` si aplica.
2. Crear el BLoC con sus archivos `_bloc.dart`, `_event.dart`, `_state.dart`.
3. Registrar el BLoC en `service_locator.dart` si es global, o proveerlo localmente con `BlocProvider`.
4. Los textos visibles al usuario se escriben directamente en español, sin archivos de traducción.

### Estructura base de un BLoC

**`_event.dart`**:

```dart
part of '<feature>_bloc.dart';

sealed class FeatureEvent extends Equatable {
  const FeatureEvent();

  @override
  List<Object?> get props => [];
}

final class FeatureStarted extends FeatureEvent {
  const FeatureStarted();
}
```

**`_state.dart`**:

```dart
part of '<feature>_bloc.dart';

enum FeatureStatus { initial, loading, success, failure }

final class FeatureState extends Equatable {
  const FeatureState({
    this.status = FeatureStatus.initial,
    this.errorMessage,
  });

  final FeatureStatus status;
  final String? errorMessage;

  FeatureState copyWith({
    FeatureStatus? status,
    String? errorMessage,
  }) {
    return FeatureState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
```

**`_bloc.dart`**:

```dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part '<feature>_event.dart';
part '<feature>_state.dart';

class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  FeatureBloc({required this.repository}) : super(const FeatureState()) {
    on<FeatureStarted>(_onStarted);
  }

  final FeatureRepository repository;

  Future<void> _onStarted(FeatureStarted event, Emitter<FeatureState> emit) async {
    emit(state.copyWith(status: FeatureStatus.loading));
    try {
      // lógica de negocio
      emit(state.copyWith(status: FeatureStatus.success));
    } on DioException catch (e) {
      emit(state.copyWith(
        status: FeatureStatus.failure,
        errorMessage: 'Error de conexión. Intenta de nuevo.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FeatureStatus.failure,
        errorMessage: 'Ocurrió un error inesperado.',
      ));
    }
  }
}
```

### Al editar código existente:

1. **Leer el archivo completo** antes de hacer cambios para entender el contexto.
2. Respetar el patrón BLoC existente: no mezclar lógica de negocio en widgets.
3. Usar los colores de `AppColors` y las dimensiones de `AppDefaults`. No usar valores hardcodeados.
4. Mantener consistencia con los estilos de widgets existentes (Cards con borderRadius 16, botones con padding 18, etc.).
5. Si se agregan nuevas dependencias, verificar compatibilidad con las versiones existentes en `pubspec.yaml`.

### Al manejar errores:

1. Siempre capturar `DioException` y `catch` genérico por separado.
2. Usar el patrón `switch (e.type)` para diferenciar tipos de error Dio.
3. Emitir estados de error descriptivos en español para el usuario final.
4. Los mensajes de error deben ser amigables y orientar al usuario sobre qué hacer.

### Al crear widgets:

1. Preferir `StatelessWidget` salvo que se necesite estado local o animaciones.
2. Usar `const` en constructores y widgets estáticos.
3. Pasar callbacks como parámetros (`VoidCallback`, `Function(T)`) para comunicación padre-hijo.
4. Para UI reutilizable, crear componentes en `core/components/`.
5. Para UI específica de un feature, crear en `views/<feature>/components/`.

---

## 🚫 Qué NO hacer

- **No** usar `setState` para lógica de negocio; usar BLoC.
- **No** hacer llamadas HTTP directamente desde widgets; pasar por Repository → Provider.
- **No** hardcodear colores, tamaños ni textos de estilo; usar `AppColors` y `AppDefaults`.
- **No** crear archivos fuera de la estructura de carpetas definida.
- **No** usar `print()` en producción; usar `debugPrint()` solo para debugging.
- **No** usar archivos ARB, `AppLocalizations` ni mecanismos de i18n.
- **No** navegar desde un BLoC; emitir un estado y reaccionar en el widget con `BlocListener`.
- **No** usar `dynamic` cuando se puede tipar; siempre preferir tipos explícitos.
- **No** dejar `catch` vacíos; siempre manejar o loguear el error.
- **No** usar `late` innecesariamente; preferir nullable con `?` o inicialización en constructor.
