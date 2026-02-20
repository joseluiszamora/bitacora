import 'package:supabase_flutter/supabase_flutter.dart';

/// Helpers de acceso rápido a los módulos de Supabase.
///
/// Uso:
/// ```dart
/// // Base de datos
/// final data = await supabase.from('bitacoras').select();
///
/// // Storage
/// final url = supabase.storage.from('avatars').getPublicUrl('photo.jpg');
///
/// // Auth
/// final user = supabase.auth.currentUser;
///
/// // Realtime
/// supabase.channel('bitacoras').onPostgresChanges(...).subscribe();
/// ```
class SupabaseHelper {
  SupabaseHelper._();

  /// Instancia principal del cliente Supabase.
  static SupabaseClient get client => Supabase.instance.client;

  /// Acceso directo al módulo de Auth.
  static GoTrueClient get auth => client.auth;

  /// Acceso directo al módulo de Storage.
  static SupabaseStorageClient get storage => client.storage;

  /// Acceso rápido a una tabla de la base de datos.
  ///
  /// Ejemplo: `SupabaseHelper.from('bitacoras').select()`
  static SupabaseQueryBuilder from(String table) => client.from(table);

  /// Invocar una función Edge (Supabase Edge Function).
  ///
  /// Ejemplo: `SupabaseHelper.functions.invoke('send-notification')`
  static FunctionsClient get functions => client.functions;

  /// Acceso directo al módulo de Realtime.
  static RealtimeClient get realtime => client.realtime;

  /// Crear un canal de Realtime.
  static RealtimeChannel channel(String name) => client.channel(name);

  /// Obtener el ID del usuario actual (o null).
  static String? get currentUserId => auth.currentUser?.id;

  /// Verificar si hay una sesión activa.
  static bool get isAuthenticated => auth.currentSession != null;
}
