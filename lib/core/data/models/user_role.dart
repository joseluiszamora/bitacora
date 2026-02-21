/// Roles de usuario del sistema BITACORA.
///
/// Los valores coinciden exactamente con el enum `user_role`
/// definido en la base de datos de Supabase.
enum UserRole {
  superAdmin('super_admin'),
  admin('admin'),
  supervisor('supervisor'),
  driver('driver'),
  finance('finance');

  const UserRole(this.value);

  /// Valor tal como está almacenado en la base de datos.
  final String value;

  /// Crea un [UserRole] desde el string guardado en la DB.
  /// Si el valor es desconocido, retorna [UserRole.driver] por defecto.
  static UserRole fromValue(String? value) {
    if (value == null) return UserRole.driver;
    return UserRole.values.firstWhere(
      (r) => r.value == value,
      orElse: () => UserRole.driver,
    );
  }

  /// Etiqueta legible en español para la UI.
  String get label {
    return switch (this) {
      UserRole.superAdmin => 'Super Administrador',
      UserRole.admin => 'Administrador',
      UserRole.supervisor => 'Supervisor',
      UserRole.driver => 'Conductor',
      UserRole.finance => 'Finanzas',
    };
  }

  /// Etiqueta corta para badges/chips.
  String get shortLabel {
    return switch (this) {
      UserRole.superAdmin => 'Super Admin',
      UserRole.admin => 'Admin',
      UserRole.supervisor => 'Supervisor',
      UserRole.driver => 'Conductor',
      UserRole.finance => 'Finanzas',
    };
  }

  /// Verifica si este rol tiene permisos iguales o superiores al [requiredRole].
  ///
  /// Jerarquía: superAdmin > admin > supervisor > finance > driver.
  bool hasPermission(UserRole requiredRole) {
    return index <= requiredRole.index;
  }
}
