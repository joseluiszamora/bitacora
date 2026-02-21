import 'package:flutter_test/flutter_test.dart';

import 'package:bitacora/core/data/models/company.dart';
import 'package:bitacora/core/data/models/user.dart';
import 'package:bitacora/core/data/models/user_role.dart';

void main() {
  group('User Model', () {
    test('User.empty devuelve un usuario vacío', () {
      expect(User.empty.isEmpty, isTrue);
    });

    test('User con datos no está vacío', () {
      const user = User(id: '1', name: 'Test', email: 'test@test.com');
      expect(user.isNotEmpty, isTrue);
    });

    test('User.fromJson parsea correctamente', () {
      final json = {
        'id': '123',
        'name': 'Juan',
        'email': 'juan@test.com',
        'phone': '12345678',
      };
      final user = User.fromJson(json);
      expect(user.id, '123');
      expect(user.name, 'Juan');
      expect(user.email, 'juan@test.com');
      expect(user.phone, '12345678');
    });

    test('User.fromProfile parsea perfil completo con empresa', () {
      final json = {
        'id': 'abc-123',
        'full_name': 'María López',
        'email': 'maria@test.com',
        'phone': '77712345',
        'role': 'admin',
        'avatar_url': 'https://example.com/avatar.png',
        'is_active': true,
        'created_at': '2025-01-01T00:00:00Z',
        'updated_at': '2025-06-01T12:00:00Z',
        'company': {
          'id': 'comp-1',
          'name': 'Transportes Monval',
          'social_reason': 'Monval SRL',
          'nit': '1234567',
          'status': 'active',
        },
      };

      final user = User.fromProfile(json);
      expect(user.id, 'abc-123');
      expect(user.name, 'María López');
      expect(user.email, 'maria@test.com');
      expect(user.role, UserRole.admin);
      expect(user.company.name, 'Transportes Monval');
      expect(user.company.nit, '1234567');
      expect(user.isActive, isTrue);
      expect(user.avatarUrl, 'https://example.com/avatar.png');
    });

    test('User.fromProfile sin empresa retorna Company.empty', () {
      final json = {
        'id': 'abc-123',
        'full_name': 'Pedro',
        'email': 'pedro@test.com',
        'role': 'driver',
      };

      final user = User.fromProfile(json);
      expect(user.company.isEmpty, isTrue);
      expect(user.role, UserRole.driver);
    });

    test('User.hasPermission verifica jerarquía correctamente', () {
      const admin = User(
        id: '1',
        name: 'Admin',
        email: 'a@t.com',
        role: UserRole.admin,
      );
      expect(admin.hasPermission(UserRole.driver), isTrue);
      expect(admin.hasPermission(UserRole.admin), isTrue);
      expect(admin.hasPermission(UserRole.superAdmin), isFalse);
    });

    test('User.copyWith crea copia con campos actualizados', () {
      const original = User(id: '1', name: 'Ana', email: 'ana@t.com');
      final updated = original.copyWith(
        name: 'Ana María',
        role: UserRole.supervisor,
      );
      expect(updated.name, 'Ana María');
      expect(updated.role, UserRole.supervisor);
      expect(updated.email, 'ana@t.com'); // sin cambiar
    });
  });

  group('UserRole', () {
    test('fromValue parsea valores válidos', () {
      expect(UserRole.fromValue('super_admin'), UserRole.superAdmin);
      expect(UserRole.fromValue('admin'), UserRole.admin);
      expect(UserRole.fromValue('supervisor'), UserRole.supervisor);
      expect(UserRole.fromValue('driver'), UserRole.driver);
      expect(UserRole.fromValue('finance'), UserRole.finance);
    });

    test('fromValue con valor desconocido retorna driver', () {
      expect(UserRole.fromValue('unknown'), UserRole.driver);
      expect(UserRole.fromValue(null), UserRole.driver);
    });

    test('label retorna texto en español', () {
      expect(UserRole.superAdmin.label, 'Super Administrador');
      expect(UserRole.driver.label, 'Conductor');
    });

    test('hasPermission respeta jerarquía', () {
      expect(UserRole.superAdmin.hasPermission(UserRole.admin), isTrue);
      expect(UserRole.driver.hasPermission(UserRole.admin), isFalse);
      expect(UserRole.admin.hasPermission(UserRole.admin), isTrue);
    });
  });

  group('Company Model', () {
    test('Company.empty está vacía', () {
      expect(Company.empty.isEmpty, isTrue);
    });

    test('Company.fromJson parsea correctamente', () {
      final json = {
        'id': 'c-1',
        'name': 'Mi Empresa',
        'social_reason': 'Mi Empresa SRL',
        'nit': '9876543',
        'status': 'active',
        'created_at': '2025-01-01T00:00:00Z',
      };

      final company = Company.fromJson(json);
      expect(company.id, 'c-1');
      expect(company.name, 'Mi Empresa');
      expect(company.socialReason, 'Mi Empresa SRL');
      expect(company.nit, '9876543');
      expect(company.isNotEmpty, isTrue);
      expect(company.createdAt, isNotNull);
    });

    test('Company.copyWith crea copia con campos actualizados', () {
      const original = Company(id: '1', name: 'Empresa A');
      final updated = original.copyWith(name: 'Empresa B', nit: '111');
      expect(updated.name, 'Empresa B');
      expect(updated.nit, '111');
      expect(updated.id, '1');
    });
  });
}
