/// Roles de usuario del sistema BITACORA.
///
/// Los valores coinciden exactamente con el enum `user_role`
/// definido en la base de datos de Supabase.
enum UserRole {
  superAdmin('super_admin'),
  admin('admin'),
  supervisor('supervisor'),
  driver('driver'),
  finance('finance'),
  clientAdmin('client_admin'),
  clientUser('client_user');

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
      UserRole.clientAdmin => 'Admin Cliente',
      UserRole.clientUser => 'Usuario Cliente',
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
      UserRole.clientAdmin => 'Admin Cliente',
      UserRole.clientUser => 'Cliente',
    };
  }

  /// Verifica si este rol tiene permisos iguales o superiores al [requiredRole].
  ///
  /// Jerarquía transportista: superAdmin > admin > supervisor > finance > driver.
  /// Jerarquía cliente: clientAdmin > clientUser.
  /// Los roles de cliente no tienen permisos sobre roles de transportista y viceversa.
  bool hasPermission(UserRole requiredRole) {
    // Ambos en el mismo grupo → comparar por índice
    if (isTransportRole && requiredRole.isTransportRole) {
      return index <= requiredRole.index;
    }
    if (isClientRole && requiredRole.isClientRole) {
      return index <= requiredRole.index;
    }
    // super_admin tiene permisos sobre todos
    if (this == UserRole.superAdmin) return true;
    return false;
  }

  /// `true` si es un rol del lado transportista.
  bool get isTransportRole => index <= UserRole.finance.index;

  /// `true` si es un rol del lado cliente.
  bool get isClientRole =>
      this == UserRole.clientAdmin || this == UserRole.clientUser;
}
