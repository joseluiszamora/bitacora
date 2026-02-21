import 'package:flutter_test/flutter_test.dart';

import 'package:bitacora/core/data/models/client_company.dart';
import 'package:bitacora/core/data/models/company.dart';
import 'package:bitacora/core/data/models/company_client.dart';
import 'package:bitacora/core/data/models/user.dart';
import 'package:bitacora/core/data/models/user_role.dart';
import 'package:bitacora/core/blocs/company/company_bloc.dart';
import 'package:bitacora/core/blocs/client_company/client_company_bloc.dart';
import 'package:bitacora/core/blocs/user_management/user_management_bloc.dart';

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
      expect(updated.email, 'ana@t.com');
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

    test('Company.toJson serializa correctamente', () {
      const company = Company(
        id: 'c-1',
        name: 'Test',
        socialReason: 'Test SRL',
        nit: '123',
      );
      final json = company.toJson();
      expect(json['id'], 'c-1');
      expect(json['name'], 'Test');
      expect(json['social_reason'], 'Test SRL');
      expect(json['nit'], '123');
      expect(json['status'], 'active');
    });
  });

  group('CompanyBloc', () {
    test('estado inicial es correcto', () {
      const state = CompanyState();
      expect(state.status, CompanyStatus.initial);
      expect(state.companies, isEmpty);
      expect(state.errorMessage, isEmpty);
      expect(state.isIdle, isTrue);
    });

    test('CompanyState.copyWith actualiza campos', () {
      const state = CompanyState();
      final updated = state.copyWith(
        status: CompanyStatus.loaded,
        companies: [const Company(id: '1', name: 'Test')],
      );
      expect(updated.status, CompanyStatus.loaded);
      expect(updated.companies.length, 1);
      expect(updated.errorMessage, isEmpty);
    });

    test('CompanyState.isIdle retorna false durante operaciones', () {
      const loading = CompanyState(status: CompanyStatus.loading);
      const creating = CompanyState(status: CompanyStatus.creating);
      const deleting = CompanyState(status: CompanyStatus.deleting);

      expect(loading.isIdle, isFalse);
      expect(creating.isIdle, isFalse);
      expect(deleting.isIdle, isFalse);
    });

    test('CompanyEvent — CompanyCreateRequested tiene props correctos', () {
      const event = CompanyCreateRequested(
        name: 'Test',
        socialReason: 'Test SRL',
        nit: '123',
      );
      expect(event.name, 'Test');
      expect(event.socialReason, 'Test SRL');
      expect(event.nit, '123');
      expect(event.props, ['Test', 'Test SRL', '123']);
    });

    test('CompanyEvent — CompanyDeleteRequested tiene props correctos', () {
      const event = CompanyDeleteRequested('abc-123');
      expect(event.id, 'abc-123');
      expect(event.props, ['abc-123']);
    });
  });

  group('UserManagementBloc', () {
    test('estado inicial es correcto', () {
      const state = UserManagementState();
      expect(state.status, UserManagementStatus.initial);
      expect(state.users, isEmpty);
      expect(state.errorMessage, isEmpty);
      expect(state.isIdle, isTrue);
    });

    test('UserManagementState.copyWith actualiza campos', () {
      const state = UserManagementState();
      final updated = state.copyWith(
        status: UserManagementStatus.loaded,
        users: [const User(id: '1', name: 'Test', email: 'test@t.com')],
      );
      expect(updated.status, UserManagementStatus.loaded);
      expect(updated.users.length, 1);
      expect(updated.errorMessage, isEmpty);
    });

    test('UserManagementState.isIdle retorna false durante operaciones', () {
      const loading = UserManagementState(status: UserManagementStatus.loading);
      const creating = UserManagementState(
        status: UserManagementStatus.creating,
      );
      const updating = UserManagementState(
        status: UserManagementStatus.updating,
      );

      expect(loading.isIdle, isFalse);
      expect(creating.isIdle, isFalse);
      expect(updating.isIdle, isFalse);
    });

    test('UserManagementEvent — CreateRequested tiene props correctos', () {
      const event = UserManagementCreateRequested(
        email: 'test@t.com',
        password: '123456',
        fullName: 'Test User',
        role: UserRole.driver,
        companyId: 'comp-1',
        phone: '77700000',
      );
      expect(event.email, 'test@t.com');
      expect(event.password, '123456');
      expect(event.fullName, 'Test User');
      expect(event.role, UserRole.driver);
      expect(event.companyId, 'comp-1');
      expect(event.phone, '77700000');
      expect(event.clientCompanyId, isNull);
      expect(event.props, [
        'test@t.com',
        '123456',
        'Test User',
        UserRole.driver,
        'comp-1',
        null,
        '77700000',
      ]);
    });

    test('UserManagementEvent — UpdateRequested tiene props correctos', () {
      const event = UserManagementUpdateRequested(
        userId: 'u-1',
        fullName: 'Updated',
        role: 'admin',
        companyId: 'comp-2',
      );
      expect(event.userId, 'u-1');
      expect(event.fullName, 'Updated');
      expect(event.role, 'admin');
      expect(event.companyId, 'comp-2');
      expect(event.clientCompanyId, isNull);
    });

    test(
      'UserManagementEvent — ToggleActiveRequested tiene props correctos',
      () {
        const event = UserManagementToggleActiveRequested(
          userId: 'u-1',
          isActive: false,
        );
        expect(event.userId, 'u-1');
        expect(event.isActive, isFalse);
        expect(event.props, ['u-1', false]);
      },
    );

    test('UserManagementEvent — LoadRequested tiene props vacíos', () {
      const event = UserManagementLoadRequested();
      expect(event.props, isEmpty);
    });
  });

  group('ClientCompany Model', () {
    test('ClientCompany.empty está vacía', () {
      expect(ClientCompany.empty.isEmpty, isTrue);
    });

    test('ClientCompany con datos no está vacía', () {
      const cc = ClientCompany(id: '1', name: 'Minera');
      expect(cc.isNotEmpty, isTrue);
    });

    test('ClientCompany.fromJson parsea correctamente', () {
      final json = {
        'id': 'cc-1',
        'name': 'Minera Bolivia',
        'nit': '999888',
        'address': 'Av. Principal 123',
        'contact_email': 'contacto@minera.bo',
        'created_at': '2025-01-15T10:00:00Z',
      };
      final cc = ClientCompany.fromJson(json);
      expect(cc.id, 'cc-1');
      expect(cc.name, 'Minera Bolivia');
      expect(cc.nit, '999888');
      expect(cc.address, 'Av. Principal 123');
      expect(cc.contactEmail, 'contacto@minera.bo');
      expect(cc.createdAt, isNotNull);
    });

    test('ClientCompany.copyWith crea copia con campos actualizados', () {
      const original = ClientCompany(id: '1', name: 'Empresa A');
      final updated = original.copyWith(name: 'Empresa B', nit: '111');
      expect(updated.name, 'Empresa B');
      expect(updated.nit, '111');
      expect(updated.id, '1');
    });

    test('ClientCompany.toJson serializa correctamente', () {
      const cc = ClientCompany(
        id: 'cc-1',
        name: 'Test Cliente',
        nit: '456',
        address: 'Calle 1',
        contactEmail: 'test@cliente.bo',
      );
      final json = cc.toJson();
      expect(json['id'], 'cc-1');
      expect(json['name'], 'Test Cliente');
      expect(json['nit'], '456');
      expect(json['address'], 'Calle 1');
      expect(json['contact_email'], 'test@cliente.bo');
    });
  });

  group('CompanyClient Model', () {
    test('CompanyClient.empty está vacío', () {
      expect(CompanyClient.empty.isEmpty, isTrue);
    });

    test('CompanyClient.fromJson parsea correctamente', () {
      final json = {
        'id': 'rel-1',
        'company_id': 'comp-1',
        'client_company_id': 'cc-1',
        'contract_type': 'annual',
        'status': 'active',
        'created_at': '2025-02-01T00:00:00Z',
      };
      final cc = CompanyClient.fromJson(json);
      expect(cc.id, 'rel-1');
      expect(cc.companyId, 'comp-1');
      expect(cc.clientCompanyId, 'cc-1');
      expect(cc.contractType, 'annual');
      expect(cc.status, 'active');
    });

    test('CompanyClient.copyWith crea copia', () {
      const original = CompanyClient(
        id: '1',
        companyId: 'c',
        clientCompanyId: 'cc',
      );
      final updated = original.copyWith(status: 'inactive');
      expect(updated.status, 'inactive');
      expect(updated.id, '1');
    });
  });

  group('UserRole — client roles', () {
    test('fromValue parsea client_admin y client_user', () {
      expect(UserRole.fromValue('client_admin'), UserRole.clientAdmin);
      expect(UserRole.fromValue('client_user'), UserRole.clientUser);
    });

    test('isTransportRole y isClientRole son correctos', () {
      expect(UserRole.admin.isTransportRole, isTrue);
      expect(UserRole.admin.isClientRole, isFalse);
      expect(UserRole.clientAdmin.isClientRole, isTrue);
      expect(UserRole.clientAdmin.isTransportRole, isFalse);
      expect(UserRole.clientUser.isClientRole, isTrue);
      expect(UserRole.driver.isTransportRole, isTrue);
    });

    test('hasPermission entre grupos', () {
      // Mismo grupo transporte
      expect(UserRole.admin.hasPermission(UserRole.driver), isTrue);
      // Mismo grupo cliente
      expect(UserRole.clientAdmin.hasPermission(UserRole.clientUser), isTrue);
      // Cross-group: admin no tiene permisos sobre clientUser
      expect(UserRole.admin.hasPermission(UserRole.clientUser), isFalse);
      // super_admin tiene permisos sobre todos
      expect(UserRole.superAdmin.hasPermission(UserRole.clientAdmin), isTrue);
      expect(UserRole.superAdmin.hasPermission(UserRole.clientUser), isTrue);
    });

    test('label y shortLabel de roles cliente', () {
      expect(UserRole.clientAdmin.label, 'Admin Cliente');
      expect(UserRole.clientUser.label, 'Usuario Cliente');
      expect(UserRole.clientAdmin.shortLabel, 'Admin Cliente');
      expect(UserRole.clientUser.shortLabel, 'Cliente');
    });
  });

  group('User Model — clientCompany', () {
    test('User.fromProfile parsea client_company', () {
      final json = {
        'id': 'u-1',
        'full_name': 'Carlos',
        'email': 'carlos@test.com',
        'role': 'client_admin',
        'client_company': {
          'id': 'cc-1',
          'name': 'Minera Andina',
          'nit': '123456',
        },
      };
      final user = User.fromProfile(json);
      expect(user.role, UserRole.clientAdmin);
      expect(user.clientCompany.isNotEmpty, isTrue);
      expect(user.clientCompany.name, 'Minera Andina');
      expect(user.company.isEmpty, isTrue);
    });

    test('User.copyWith actualiza clientCompany', () {
      const user = User(id: '1', name: 'A', email: 'a@t.com');
      final updated = user.copyWith(
        clientCompany: const ClientCompany(id: 'cc-1', name: 'Test'),
      );
      expect(updated.clientCompany.isNotEmpty, isTrue);
      expect(updated.clientCompany.name, 'Test');
    });
  });

  group('ClientCompanyBloc', () {
    test('estado inicial es correcto', () {
      const state = ClientCompanyState();
      expect(state.status, ClientCompanyStatus.initial);
      expect(state.clientCompanies, isEmpty);
      expect(state.errorMessage, isEmpty);
      expect(state.isIdle, isTrue);
    });

    test('ClientCompanyState.copyWith actualiza campos', () {
      const state = ClientCompanyState();
      final updated = state.copyWith(
        status: ClientCompanyStatus.loaded,
        clientCompanies: [const ClientCompany(id: '1', name: 'Test')],
      );
      expect(updated.status, ClientCompanyStatus.loaded);
      expect(updated.clientCompanies.length, 1);
      expect(updated.errorMessage, isEmpty);
    });

    test('ClientCompanyState.isIdle retorna false durante operaciones', () {
      const loading = ClientCompanyState(status: ClientCompanyStatus.loading);
      const creating = ClientCompanyState(status: ClientCompanyStatus.creating);
      const deleting = ClientCompanyState(status: ClientCompanyStatus.deleting);

      expect(loading.isIdle, isFalse);
      expect(creating.isIdle, isFalse);
      expect(deleting.isIdle, isFalse);
    });

    test('ClientCompanyEvent — CreateRequested tiene props correctos', () {
      const event = ClientCompanyCreateRequested(
        name: 'Minera Test',
        nit: '999',
        address: 'Av. 1',
        contactEmail: 'test@minera.bo',
      );
      expect(event.name, 'Minera Test');
      expect(event.nit, '999');
      expect(event.address, 'Av. 1');
      expect(event.contactEmail, 'test@minera.bo');
      expect(event.props, ['Minera Test', '999', 'Av. 1', 'test@minera.bo']);
    });

    test('ClientCompanyEvent — DeleteRequested tiene props correctos', () {
      const event = ClientCompanyDeleteRequested('cc-123');
      expect(event.id, 'cc-123');
      expect(event.props, ['cc-123']);
    });
  });
}
