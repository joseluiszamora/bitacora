import 'package:flutter_test/flutter_test.dart';

import 'package:bitacora/core/data/models/client_company.dart';
import 'package:bitacora/core/data/models/company.dart';
import 'package:bitacora/core/data/models/company_client.dart';
import 'package:bitacora/core/data/models/user.dart';
import 'package:bitacora/core/data/models/user_role.dart';
import 'package:bitacora/core/data/models/vehicle.dart';
import 'package:bitacora/core/data/models/vehicle_document.dart';
import 'package:bitacora/core/blocs/company/company_bloc.dart';
import 'package:bitacora/core/blocs/client_company/client_company_bloc.dart';
import 'package:bitacora/core/blocs/user_management/user_management_bloc.dart';
import 'package:bitacora/core/blocs/vehicle/vehicle_bloc.dart';
import 'package:bitacora/core/blocs/theme/theme_cubit.dart';
import 'package:bitacora/core/blocs/trip/trip_bloc.dart';
import 'package:bitacora/core/data/models/trip.dart';
import 'package:bitacora/core/blocs/vehicle_assignment/vehicle_assignment_bloc.dart';
import 'package:bitacora/core/data/models/vehicle_assignment.dart';
import 'package:bitacora/core/data/models/city.dart';
import 'package:bitacora/core/data/models/client_location.dart';
import 'package:bitacora/core/data/models/app_state.dart';
import 'package:bitacora/core/blocs/client_location/client_location_bloc.dart';
import 'package:bitacora/core/data/models/trip_log.dart';
import 'package:bitacora/core/data/models/trip_log_media.dart';
import 'package:bitacora/core/blocs/trip_log/trip_log_bloc.dart';
import 'package:flutter/material.dart';

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

  group('Vehicle Model', () {
    test('Vehicle.empty está vacío', () {
      expect(Vehicle.empty.isEmpty, isTrue);
    });

    test('Vehicle con datos no está vacío', () {
      const v = Vehicle(id: '1', companyId: 'c-1', plateNumber: 'ABC-123');
      expect(v.isNotEmpty, isTrue);
    });

    test('Vehicle.fromJson parsea correctamente', () {
      final json = {
        'id': 'v-1',
        'company_id': 'c-1',
        'plate_number': 'XYZ-789',
        'brand': 'Toyota',
        'model': 'Hilux',
        'year': 2022,
        'color': 'Blanco',
        'chasis_code': 'CH123',
        'motor_code': 'MT456',
        'ruat_number': 'R789',
        'status': 'active',
        'soat_expiration_date': '2025-12-31',
        'inspection_expiration_date': '2025-06-30',
        'insurance_expiration_date': '2025-09-15',
        'created_at': '2025-01-01T00:00:00Z',
        'company': {'id': 'c-1', 'name': 'Transportes Monval'},
      };
      final v = Vehicle.fromJson(json);
      expect(v.id, 'v-1');
      expect(v.companyId, 'c-1');
      expect(v.plateNumber, 'XYZ-789');
      expect(v.brand, 'Toyota');
      expect(v.model, 'Hilux');
      expect(v.year, 2022);
      expect(v.color, 'Blanco');
      expect(v.chasisCode, 'CH123');
      expect(v.motorCode, 'MT456');
      expect(v.ruatNumber, 'R789');
      expect(v.status, VehicleStatus.active);
      expect(v.soatExpirationDate, isNotNull);
      expect(v.inspectionExpirationDate, isNotNull);
      expect(v.insuranceExpirationDate, isNotNull);
      expect(v.company, isNotNull);
      expect(v.company!.name, 'Transportes Monval');
    });

    test('Vehicle.toJson serializa correctamente', () {
      const v = Vehicle(
        id: 'v-1',
        companyId: 'c-1',
        plateNumber: 'ABC-123',
        brand: 'Volvo',
        status: VehicleStatus.maintenance,
      );
      final json = v.toJson();
      expect(json['company_id'], 'c-1');
      expect(json['plate_number'], 'ABC-123');
      expect(json['brand'], 'Volvo');
      expect(json['status'], 'maintenance');
      // toJson no incluye 'id'
      expect(json.containsKey('id'), isFalse);
    });

    test('Vehicle.copyWith crea copia con campos actualizados', () {
      const original = Vehicle(
        id: '1',
        companyId: 'c-1',
        plateNumber: 'ABC-123',
      );
      final updated = original.copyWith(
        plateNumber: 'DEF-456',
        brand: 'Mercedes',
        status: VehicleStatus.inactive,
      );
      expect(updated.plateNumber, 'DEF-456');
      expect(updated.brand, 'Mercedes');
      expect(updated.status, VehicleStatus.inactive);
      expect(updated.id, '1');
      expect(updated.companyId, 'c-1');
    });

    test('Vehicle.displayName muestra info correcta', () {
      const v1 = Vehicle(
        id: '1',
        companyId: 'c-1',
        plateNumber: 'ABC-123',
        brand: 'Toyota',
        model: 'Hilux',
        year: 2022,
      );
      expect(v1.displayName, 'Toyota Hilux (2022)');

      const v2 = Vehicle(id: '2', companyId: 'c-1', plateNumber: 'XYZ-789');
      expect(v2.displayName, 'XYZ-789');
    });

    test('VehicleStatus.fromValue parsea valores válidos', () {
      expect(VehicleStatus.fromValue('active'), VehicleStatus.active);
      expect(VehicleStatus.fromValue('maintenance'), VehicleStatus.maintenance);
      expect(VehicleStatus.fromValue('inactive'), VehicleStatus.inactive);
      expect(VehicleStatus.fromValue(null), VehicleStatus.active);
      expect(VehicleStatus.fromValue('unknown'), VehicleStatus.active);
    });

    test('VehicleStatus.label retorna texto en español', () {
      expect(VehicleStatus.active.label, 'Activo');
      expect(VehicleStatus.maintenance.label, 'En Mantenimiento');
      expect(VehicleStatus.inactive.label, 'Inactivo');
    });
  });

  group('VehicleDocument Model', () {
    test('VehicleDocument.empty está vacío', () {
      expect(VehicleDocument.empty.isEmpty, isTrue);
    });

    test('VehicleDocument con datos no está vacío', () {
      const doc = VehicleDocument(
        id: '1',
        vehicleId: 'v-1',
        type: VehicleDocumentType.soat,
      );
      expect(doc.isNotEmpty, isTrue);
    });

    test('VehicleDocument.fromJson parsea correctamente', () {
      final json = {
        'id': 'd-1',
        'vehicle_id': 'v-1',
        'type': 'insurance',
        'file_url': 'https://example.com/doc.pdf',
        'expiration_date': '2025-12-31',
        'created_at': '2025-01-01T00:00:00Z',
      };
      final doc = VehicleDocument.fromJson(json);
      expect(doc.id, 'd-1');
      expect(doc.vehicleId, 'v-1');
      expect(doc.type, VehicleDocumentType.insurance);
      expect(doc.fileUrl, 'https://example.com/doc.pdf');
      expect(doc.expirationDate, isNotNull);
    });

    test('VehicleDocument.toJson serializa correctamente', () {
      const doc = VehicleDocument(
        id: 'd-1',
        vehicleId: 'v-1',
        type: VehicleDocumentType.ruat,
        fileUrl: 'https://example.com/ruat.pdf',
      );
      final json = doc.toJson();
      expect(json['vehicle_id'], 'v-1');
      expect(json['type'], 'ruat');
      expect(json['file_url'], 'https://example.com/ruat.pdf');
    });

    test('VehicleDocument.copyWith crea copia', () {
      const original = VehicleDocument(
        id: '1',
        vehicleId: 'v-1',
        type: VehicleDocumentType.soat,
      );
      final updated = original.copyWith(
        type: VehicleDocumentType.inspection,
        fileUrl: 'https://new-url.com/doc.pdf',
      );
      expect(updated.type, VehicleDocumentType.inspection);
      expect(updated.fileUrl, 'https://new-url.com/doc.pdf');
      expect(updated.id, '1');
    });

    test('VehicleDocument.isExpired detecta vencimiento', () {
      final expired = VehicleDocument(
        id: '1',
        vehicleId: 'v-1',
        type: VehicleDocumentType.soat,
        expirationDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(expired.isExpired, isTrue);
      expect(expired.isExpiringSoon, isFalse);
    });

    test('VehicleDocument.isExpiringSoon detecta próximo vencimiento', () {
      final expiringSoon = VehicleDocument(
        id: '1',
        vehicleId: 'v-1',
        type: VehicleDocumentType.soat,
        expirationDate: DateTime.now().add(const Duration(days: 15)),
      );
      expect(expiringSoon.isExpired, isFalse);
      expect(expiringSoon.isExpiringSoon, isTrue);
    });

    test('VehicleDocumentType.fromValue parsea valores', () {
      expect(VehicleDocumentType.fromValue('soat'), VehicleDocumentType.soat);
      expect(
        VehicleDocumentType.fromValue('inspection'),
        VehicleDocumentType.inspection,
      );
      expect(
        VehicleDocumentType.fromValue('insurance'),
        VehicleDocumentType.insurance,
      );
      expect(VehicleDocumentType.fromValue('ruat'), VehicleDocumentType.ruat);
      expect(VehicleDocumentType.fromValue(null), VehicleDocumentType.soat);
    });

    test('VehicleDocumentType.label retorna texto en español', () {
      expect(VehicleDocumentType.soat.label, 'SOAT');
      expect(VehicleDocumentType.inspection.label, 'Inspección Técnica');
      expect(VehicleDocumentType.insurance.label, 'Seguro');
      expect(VehicleDocumentType.ruat.label, 'RUAT');
    });
  });

  group('VehicleBloc', () {
    test('estado inicial es correcto', () {
      const state = VehicleState();
      expect(state.status, VehicleStateStatus.initial);
      expect(state.vehicles, isEmpty);
      expect(state.errorMessage, isEmpty);
      expect(state.isIdle, isTrue);
    });

    test('VehicleState.copyWith actualiza campos', () {
      const state = VehicleState();
      final updated = state.copyWith(
        status: VehicleStateStatus.loaded,
        vehicles: [
          const Vehicle(id: '1', companyId: 'c-1', plateNumber: 'ABC-123'),
        ],
      );
      expect(updated.status, VehicleStateStatus.loaded);
      expect(updated.vehicles.length, 1);
      expect(updated.errorMessage, isEmpty);
    });

    test('VehicleState.isIdle retorna false durante operaciones', () {
      const loading = VehicleState(status: VehicleStateStatus.loading);
      const creating = VehicleState(status: VehicleStateStatus.creating);
      const updating = VehicleState(status: VehicleStateStatus.updating);
      const deleting = VehicleState(status: VehicleStateStatus.deleting);

      expect(loading.isIdle, isFalse);
      expect(creating.isIdle, isFalse);
      expect(updating.isIdle, isFalse);
      expect(deleting.isIdle, isFalse);
    });

    test('VehicleEvent — CreateRequested tiene props correctos', () {
      const event = VehicleCreateRequested(
        companyId: 'c-1',
        plateNumber: 'ABC-123',
        brand: 'Toyota',
        model: 'Hilux',
        year: 2022,
      );
      expect(event.companyId, 'c-1');
      expect(event.plateNumber, 'ABC-123');
      expect(event.brand, 'Toyota');
      expect(event.model, 'Hilux');
      expect(event.year, 2022);
    });

    test('VehicleEvent — UpdateRequested tiene props correctos', () {
      const event = VehicleUpdateRequested(
        id: 'v-1',
        plateNumber: 'DEF-456',
        status: VehicleStatus.maintenance,
      );
      expect(event.id, 'v-1');
      expect(event.plateNumber, 'DEF-456');
      expect(event.status, VehicleStatus.maintenance);
      expect(event.companyId, isNull);
    });

    test('VehicleEvent — DeleteRequested tiene props correctos', () {
      const event = VehicleDeleteRequested('v-123');
      expect(event.id, 'v-123');
      expect(event.props, ['v-123']);
    });

    test('VehicleEvent — LoadRequested puede tener companyId', () {
      const event1 = VehicleLoadRequested();
      expect(event1.companyId, isNull);
      expect(event1.props, [null]);

      const event2 = VehicleLoadRequested(companyId: 'c-1');
      expect(event2.companyId, 'c-1');
      expect(event2.props, ['c-1']);
    });
  });

  // ─── ThemeCubit ─────────────────────────────────────────────────────
  group('ThemeCubit', () {
    test('ThemeState por defecto usa ThemeMode.system', () {
      const state = ThemeState();
      expect(state.themeMode, ThemeMode.system);
    });

    test('ThemeState con ThemeMode.dark', () {
      const state = ThemeState(themeMode: ThemeMode.dark);
      expect(state.themeMode, ThemeMode.dark);
    });

    test('ThemeState con ThemeMode.light', () {
      const state = ThemeState(themeMode: ThemeMode.light);
      expect(state.themeMode, ThemeMode.light);
    });

    test('ThemeState props contiene themeMode', () {
      const state = ThemeState(themeMode: ThemeMode.dark);
      expect(state.props, [ThemeMode.dark]);
    });

    test('ThemeState igualdad por valor', () {
      const state1 = ThemeState(themeMode: ThemeMode.light);
      const state2 = ThemeState(themeMode: ThemeMode.light);
      const state3 = ThemeState(themeMode: ThemeMode.dark);

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });
  });

  // ─── Trip Model ──────────────────────────────────────────────────────
  group('Trip Model', () {
    test('Trip.empty está vacío', () {
      expect(Trip.empty.isEmpty, isTrue);
    });

    test('Trip con datos no está vacío', () {
      const trip = Trip(
        id: '1',
        companyId: 'c1',
        clientCompanyId: 'cc1',
        vehicleId: 'v1',
        originLocationId: 'loc-1',
        destinationLocationId: 'loc-2',
      );
      expect(trip.isNotEmpty, isTrue);
    });

    test('Trip.fromJson parsea correctamente', () {
      final json = {
        'id': 'trip-1',
        'company_id': 'comp-1',
        'client_company_id': 'cc-1',
        'vehicle_id': 'v-1',
        'assigned_by_user_id': 'admin-1',
        'origin_location_id': 'loc-origin',
        'destination_location_id': 'loc-dest',
        'status': 'in_progress',
        'price': 1500.50,
      };
      final trip = Trip.fromJson(json);
      expect(trip.id, 'trip-1');
      expect(trip.companyId, 'comp-1');
      expect(trip.clientCompanyId, 'cc-1');
      expect(trip.vehicleId, 'v-1');
      expect(trip.assignedByUserId, 'admin-1');
      expect(trip.originLocationId, 'loc-origin');
      expect(trip.destinationLocationId, 'loc-dest');
      expect(trip.status, TripStatus.inProgress);
      expect(trip.price, 1500.50);
    });

    test('Trip.fromJson parsea join de origin_location', () {
      final json = {
        'id': 'trip-2',
        'company_id': 'comp-1',
        'client_company_id': 'cc-1',
        'vehicle_id': 'v-1',
        'origin_location_id': 'loc-1',
        'destination_location_id': 'loc-2',
        'status': 'pending',
        'origin_location': {
          'id': 'loc-1',
          'client_company_id': 'cc-1',
          'name': 'Almacén Central',
          'type': 'WAREHOUSE',
          'status': 'ACTIVE',
        },
        'destination_location': {
          'id': 'loc-2',
          'client_company_id': 'cc-1',
          'name': 'Planta Norte',
          'type': 'PLANT',
          'status': 'ACTIVE',
        },
      };
      final trip = Trip.fromJson(json);
      expect(trip.originLocation, isNotNull);
      expect(trip.originLocation!.name, 'Almacén Central');
      expect(trip.destinationLocation, isNotNull);
      expect(trip.destinationLocation!.name, 'Planta Norte');
    });

    test('Trip.toJson serializa correctamente', () {
      const trip = Trip(
        id: 't-1',
        companyId: 'c-1',
        clientCompanyId: 'cc-1',
        vehicleId: 'v-1',
        originLocationId: 'loc-a',
        destinationLocationId: 'loc-b',
        status: TripStatus.pending,
        price: 800.00,
      );
      final json = trip.toJson();
      expect(json['company_id'], 'c-1');
      expect(json['client_company_id'], 'cc-1');
      expect(json['vehicle_id'], 'v-1');
      expect(json['origin_location_id'], 'loc-a');
      expect(json['destination_location_id'], 'loc-b');
      expect(json['status'], 'pending');
      expect(json['price'], 800.00);
      expect(json.containsKey('origin'), isFalse);
      expect(json.containsKey('destination'), isFalse);
    });

    test('Trip.copyWith crea copia con campos actualizados', () {
      const trip = Trip(
        id: 't-1',
        companyId: 'c-1',
        clientCompanyId: 'cc-1',
        vehicleId: 'v-1',
        originLocationId: 'loc-1',
        destinationLocationId: 'loc-2',
        status: TripStatus.pending,
      );
      final updated = trip.copyWith(
        status: TripStatus.completed,
        price: 500.0,
        destinationLocationId: 'loc-3',
      );
      expect(updated.id, 't-1');
      expect(updated.originLocationId, 'loc-1');
      expect(updated.destinationLocationId, 'loc-3');
      expect(updated.status, TripStatus.completed);
      expect(updated.price, 500.0);
    });

    test('Trip.displayName muestra ruta con nombres de ubicación', () {
      const trip = Trip(
        id: '1',
        companyId: 'c1',
        clientCompanyId: 'cc1',
        vehicleId: 'v1',
        originLocationId: 'loc-1',
        destinationLocationId: 'loc-2',
      );
      // Sin join, usa IDs
      expect(trip.displayName, 'loc-1 → loc-2');
    });

    test('Trip.displayName usa nombre del join si está disponible', () {
      final trip = Trip.fromJson({
        'id': '1',
        'company_id': 'c1',
        'client_company_id': 'cc1',
        'vehicle_id': 'v1',
        'origin_location_id': 'loc-1',
        'destination_location_id': 'loc-2',
        'status': 'pending',
        'origin_location': {
          'id': 'loc-1',
          'client_company_id': 'cc1',
          'name': 'La Paz',
          'type': 'WAREHOUSE',
          'status': 'ACTIVE',
        },
        'destination_location': {
          'id': 'loc-2',
          'client_company_id': 'cc1',
          'name': 'Oruro',
          'type': 'PLANT',
          'status': 'ACTIVE',
        },
      });
      expect(trip.displayName, 'La Paz → Oruro');
    });

    test('TripStatus.fromValue parsea valores válidos', () {
      expect(TripStatus.fromValue('pending'), TripStatus.pending);
      expect(TripStatus.fromValue('in_progress'), TripStatus.inProgress);
      expect(TripStatus.fromValue('completed'), TripStatus.completed);
      expect(TripStatus.fromValue('cancelled'), TripStatus.cancelled);
      expect(TripStatus.fromValue('unknown'), TripStatus.pending);
      expect(TripStatus.fromValue(null), TripStatus.pending);
    });

    test('TripStatus.label retorna texto en español', () {
      expect(TripStatus.pending.label, 'Pendiente');
      expect(TripStatus.inProgress.label, 'En Curso');
      expect(TripStatus.completed.label, 'Completado');
      expect(TripStatus.cancelled.label, 'Cancelado');
    });

    test('Trip.props incluye 18 propiedades', () {
      expect(Trip.empty.props.length, 18);
    });
  });

  // ─── TripBloc ────────────────────────────────────────────────────────
  group('TripBloc', () {
    test('estado inicial es correcto', () {
      const state = TripState();
      expect(state.status, TripStateStatus.initial);
      expect(state.trips, isEmpty);
      expect(state.errorMessage, isEmpty);
    });

    test('TripState.copyWith actualiza campos', () {
      const state = TripState();
      final updated = state.copyWith(
        status: TripStateStatus.loaded,
        trips: [Trip.empty],
        errorMessage: 'error test',
      );
      expect(updated.status, TripStateStatus.loaded);
      expect(updated.trips.length, 1);
      expect(updated.errorMessage, 'error test');
    });

    test('TripState.isIdle retorna false durante operaciones', () {
      expect(const TripState(status: TripStateStatus.loading).isIdle, isFalse);
      expect(const TripState(status: TripStateStatus.creating).isIdle, isFalse);
      expect(const TripState(status: TripStateStatus.updating).isIdle, isFalse);
      expect(const TripState(status: TripStateStatus.deleting).isIdle, isFalse);
      expect(const TripState(status: TripStateStatus.loaded).isIdle, isTrue);
      expect(const TripState(status: TripStateStatus.success).isIdle, isTrue);
    });

    test('TripEvent — CreateRequested tiene props correctos', () {
      const event = TripCreateRequested(
        companyId: 'c-1',
        clientCompanyId: 'cc-1',
        vehicleId: 'v-1',
        originLocationId: 'loc-a',
        destinationLocationId: 'loc-b',
        price: 500.0,
      );
      expect(event.companyId, 'c-1');
      expect(event.clientCompanyId, 'cc-1');
      expect(event.vehicleId, 'v-1');
      expect(event.originLocationId, 'loc-a');
      expect(event.destinationLocationId, 'loc-b');
      expect(event.price, 500.0);
    });

    test('TripEvent — UpdateRequested tiene props correctos', () {
      const event = TripUpdateRequested(
        id: 't-1',
        status: TripStatus.completed,
        originLocationId: 'loc-new',
      );
      expect(event.id, 't-1');
      expect(event.status, TripStatus.completed);
      expect(event.originLocationId, 'loc-new');
      expect(event.vehicleId, isNull);
    });

    test('TripEvent — DeleteRequested tiene props correctos', () {
      const event = TripDeleteRequested('t-123');
      expect(event.id, 't-123');
      expect(event.props, ['t-123']);
    });

    test('TripEvent — LoadRequested puede tener companyId', () {
      const event1 = TripLoadRequested();
      expect(event1.companyId, isNull);
      expect(event1.props, [null]);

      const event2 = TripLoadRequested(companyId: 'c-1');
      expect(event2.companyId, 'c-1');
      expect(event2.props, ['c-1']);
    });
  });

  // ============================================================
  // VehicleAssignment Model
  // ============================================================
  group('VehicleAssignment Model', () {
    test('VehicleAssignment.empty devuelve una asignación vacía', () {
      expect(VehicleAssignment.empty.isEmpty, isTrue);
    });

    test('VehicleAssignment con datos no está vacía', () {
      final assignment = VehicleAssignment(
        id: 'va-1',
        vehicleId: 'v-1',
        driverId: 'd-1',
        startDate: DateTime(2025, 1, 1),
      );
      expect(assignment.isNotEmpty, isTrue);
    });

    test('VehicleAssignment.fromJson parsea correctamente', () {
      final json = {
        'id': 'va-1',
        'vehicle_id': 'v-1',
        'driver_id': 'd-1',
        'assigned_by_user_id': 'u-admin',
        'start_date': '2025-01-15',
        'end_date': null,
        'is_active': true,
        'created_at': '2025-01-15T10:00:00Z',
      };

      final assignment = VehicleAssignment.fromJson(json);
      expect(assignment.id, 'va-1');
      expect(assignment.vehicleId, 'v-1');
      expect(assignment.driverId, 'd-1');
      expect(assignment.assignedByUserId, 'u-admin');
      expect(assignment.startDate.year, 2025);
      expect(assignment.startDate.month, 1);
      expect(assignment.startDate.day, 15);
      expect(assignment.endDate, isNull);
      expect(assignment.isActive, isTrue);
      expect(assignment.createdAt, isNotNull);
    });

    test('VehicleAssignment.fromJson con end_date', () {
      final json = {
        'id': 'va-2',
        'vehicle_id': 'v-2',
        'driver_id': 'd-2',
        'start_date': '2025-01-01',
        'end_date': '2025-06-30',
        'is_active': false,
      };

      final assignment = VehicleAssignment.fromJson(json);
      expect(assignment.endDate, isNotNull);
      expect(assignment.endDate!.month, 6);
      expect(assignment.isActive, isFalse);
    });

    test('VehicleAssignment.fromJson con vehicle join', () {
      final json = {
        'id': 'va-3',
        'vehicle_id': 'v-3',
        'driver_id': 'd-3',
        'start_date': '2025-03-01',
        'is_active': true,
        'vehicle': {
          'id': 'v-3',
          'company_id': 'c-1',
          'plate_number': 'ABC-123',
          'brand': 'Toyota',
          'model': 'Hilux',
          'year': 2023,
        },
      };

      final assignment = VehicleAssignment.fromJson(json);
      expect(assignment.vehicle, isNotNull);
      expect(assignment.vehicle!.plateNumber, 'ABC-123');
      expect(assignment.vehicle!.brand, 'Toyota');
    });

    test('VehicleAssignment.fromJson con driver join', () {
      final json = {
        'id': 'va-4',
        'vehicle_id': 'v-4',
        'driver_id': 'd-4',
        'start_date': '2025-02-01',
        'is_active': true,
        'driver': {
          'id': 'd-4',
          'full_name': 'Carlos Perez',
          'email': 'carlos@test.com',
          'role': 'driver',
        },
      };

      final assignment = VehicleAssignment.fromJson(json);
      expect(assignment.driver, isNotNull);
      expect(assignment.driver!.name, 'Carlos Perez');
      expect(assignment.driver!.email, 'carlos@test.com');
    });

    test('VehicleAssignment.toJson serializa correctamente', () {
      final assignment = VehicleAssignment(
        id: 'va-1',
        vehicleId: 'v-1',
        driverId: 'd-1',
        assignedByUserId: 'u-admin',
        startDate: DateTime(2025, 3, 15),
        isActive: true,
      );

      final json = assignment.toJson();
      expect(json['vehicle_id'], 'v-1');
      expect(json['driver_id'], 'd-1');
      expect(json['assigned_by_user_id'], 'u-admin');
      expect(json['is_active'], true);
      expect(json.containsKey('id'), isFalse);
    });

    test('VehicleAssignment.toJson con endDate', () {
      final assignment = VehicleAssignment(
        id: 'va-1',
        vehicleId: 'v-1',
        driverId: 'd-1',
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 12, 31),
        isActive: false,
      );

      final json = assignment.toJson();
      expect(json['end_date'], isNotNull);
      expect(json['is_active'], false);
    });

    test('VehicleAssignment.copyWith funciona correctamente', () {
      final original = VehicleAssignment(
        id: 'va-1',
        vehicleId: 'v-1',
        driverId: 'd-1',
        startDate: DateTime(2025, 1, 1),
        isActive: true,
      );

      final updated = original.copyWith(
        driverId: 'd-2',
        isActive: false,
        endDate: DateTime(2025, 6, 1),
      );

      expect(updated.id, 'va-1');
      expect(updated.vehicleId, 'v-1');
      expect(updated.driverId, 'd-2');
      expect(updated.isActive, false);
      expect(updated.endDate, isNotNull);
    });

    test('VehicleAssignment.displayName muestra nombre correcto', () {
      final assignment = VehicleAssignment(
        id: 'va-1',
        vehicleId: 'v-1',
        driverId: 'd-1',
        startDate: DateTime(2025, 1, 1),
      );

      // Sin joins: usa IDs
      expect(assignment.displayName, 'd-1 → v-1');
    });

    test('VehicleAssignment.displayName con joins muestra nombres', () {
      final assignment = VehicleAssignment(
        id: 'va-1',
        vehicleId: 'v-1',
        driverId: 'd-1',
        startDate: DateTime(2025, 1, 1),
        vehicle: const Vehicle(
          id: 'v-1',
          companyId: 'c-1',
          plateNumber: 'XYZ-789',
          brand: 'Ford',
          model: 'Ranger',
        ),
        driver: const User(
          id: 'd-1',
          name: 'Juan Lopez',
          email: 'juan@test.com',
        ),
      );

      expect(assignment.displayName, 'Juan Lopez → Ford Ranger');
    });

    test('VehicleAssignment props contiene todos los campos', () {
      final assignment = VehicleAssignment(
        id: 'va-1',
        vehicleId: 'v-1',
        driverId: 'd-1',
        startDate: DateTime(2025, 1, 1),
      );
      expect(assignment.props.length, 11);
    });

    test('VehicleAssignment igualdad por Equatable', () {
      final a = VehicleAssignment(
        id: 'va-1',
        vehicleId: 'v-1',
        driverId: 'd-1',
        startDate: DateTime(2025, 1, 1),
      );
      final b = VehicleAssignment(
        id: 'va-1',
        vehicleId: 'v-1',
        driverId: 'd-1',
        startDate: DateTime(2025, 1, 1),
      );
      expect(a, equals(b));
    });
  });

  // ============================================================
  // VehicleAssignment BLoC
  // ============================================================
  group('VehicleAssignment BLoC', () {
    test('VehicleAssignmentState initial es correcto', () {
      const state = VehicleAssignmentState();
      expect(state.status, VehicleAssignmentStatus.initial);
      expect(state.assignments, isEmpty);
      expect(state.errorMessage, isEmpty);
    });

    test('VehicleAssignmentState copyWith funciona', () {
      const state = VehicleAssignmentState();
      final updated = state.copyWith(
        status: VehicleAssignmentStatus.loading,
        errorMessage: 'test',
      );
      expect(updated.status, VehicleAssignmentStatus.loading);
      expect(updated.errorMessage, 'test');
      expect(updated.assignments, isEmpty);
    });

    test('VehicleAssignmentState copyWith con asignaciones', () {
      final assignments = [
        VehicleAssignment(
          id: 'va-1',
          vehicleId: 'v-1',
          driverId: 'd-1',
          startDate: DateTime(2025, 1, 1),
        ),
      ];
      const state = VehicleAssignmentState();
      final updated = state.copyWith(
        status: VehicleAssignmentStatus.loaded,
        assignments: assignments,
      );
      expect(updated.assignments.length, 1);
      expect(updated.assignments.first.id, 'va-1');
    });

    test('VehicleAssignmentState props contiene todos los campos', () {
      const state = VehicleAssignmentState();
      expect(state.props.length, 3);
    });

    test('VehicleAssignmentEvent — CreateRequested props', () {
      final event = VehicleAssignmentCreateRequested(
        vehicleId: 'v-1',
        driverId: 'd-1',
        assignedByUserId: 'u-1',
        startDate: DateTime(2025, 3, 1),
      );
      expect(event.vehicleId, 'v-1');
      expect(event.driverId, 'd-1');
      expect(event.assignedByUserId, 'u-1');
      expect(event.endDate, isNull);
    });

    test('VehicleAssignmentEvent — UpdateRequested props', () {
      const event = VehicleAssignmentUpdateRequested(
        id: 'va-1',
        isActive: false,
      );
      expect(event.id, 'va-1');
      expect(event.isActive, false);
      expect(event.vehicleId, isNull);
    });

    test('VehicleAssignmentEvent — EndRequested props', () {
      const event = VehicleAssignmentEndRequested('va-123');
      expect(event.id, 'va-123');
      expect(event.props, ['va-123']);
    });

    test('VehicleAssignmentEvent — DeleteRequested props', () {
      const event = VehicleAssignmentDeleteRequested('va-456');
      expect(event.id, 'va-456');
      expect(event.props, ['va-456']);
    });

    test('VehicleAssignmentEvent — LoadRequested filtros', () {
      const event1 = VehicleAssignmentLoadRequested();
      expect(event1.vehicleId, isNull);
      expect(event1.driverId, isNull);
      expect(event1.companyId, isNull);

      const event2 = VehicleAssignmentLoadRequested(vehicleId: 'v-1');
      expect(event2.vehicleId, 'v-1');

      const event3 = VehicleAssignmentLoadRequested(
        driverId: 'd-1',
        companyId: 'c-1',
      );
      expect(event3.driverId, 'd-1');
      expect(event3.companyId, 'c-1');
    });

    test('VehicleAssignmentEvent — CreateRequested con endDate', () {
      final event = VehicleAssignmentCreateRequested(
        vehicleId: 'v-1',
        driverId: 'd-1',
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 12, 31),
      );
      expect(event.endDate, isNotNull);
      expect(event.endDate!.month, 12);
    });
  });

  // ── AppState Model ─────────────────────────────────────────────

  group('AppState Model', () {
    test('AppState.empty devuelve un estado vacío', () {
      expect(AppState.empty.isEmpty, isTrue);
      expect(AppState.empty.isNotEmpty, isFalse);
    });

    test('AppState con datos no está vacío', () {
      const state = AppState(id: 1, name: 'Santa Cruz');
      expect(state.isNotEmpty, isTrue);
    });

    test('AppState.fromJson parsea correctamente', () {
      final json = {
        'id': 3,
        'name': 'Cochabamba',
        'code': 'CB',
        'country_code': 'BO',
      };
      final state = AppState.fromJson(json);
      expect(state.id, 3);
      expect(state.name, 'Cochabamba');
      expect(state.code, 'CB');
      expect(state.countryCode, 'BO');
    });

    test('AppState.displayName incluye código si existe', () {
      const s1 = AppState(id: 1, name: 'Santa Cruz', code: 'SC');
      expect(s1.displayName, 'Santa Cruz (SC)');

      const s2 = AppState(id: 2, name: 'La Paz');
      expect(s2.displayName, 'La Paz');
    });

    test('AppState.toJson serializa correctamente', () {
      const state = AppState(
        id: 1,
        name: 'Oruro',
        code: 'OR',
        countryCode: 'BO',
      );
      final json = state.toJson();
      expect(json['id'], 1);
      expect(json['name'], 'Oruro');
      expect(json['code'], 'OR');
      expect(json['country_code'], 'BO');
    });

    test('AppState.copyWith copia y sobreescribe campos', () {
      const state = AppState(id: 1, name: 'Potosí');
      final copy = state.copyWith(name: 'Potosí Dept', code: 'PT');
      expect(copy.id, 1);
      expect(copy.name, 'Potosí Dept');
      expect(copy.code, 'PT');
    });

    test('AppState.props contiene todos los campos', () {
      const state = AppState(id: 1, name: 'Test');
      expect(state.props.length, 4);
    });
  });

  // ── City Model ────────────────────────────────────────────────

  group('City Model', () {
    test('City.empty devuelve una ciudad vacía', () {
      expect(City.empty.isEmpty, isTrue);
      expect(City.empty.isNotEmpty, isFalse);
    });

    test('City con datos no está vacía', () {
      const city = City(id: 'c-1', name: 'Santa Cruz');
      expect(city.isNotEmpty, isTrue);
    });

    test('City.fromJson parsea correctamente sin estado', () {
      final json = {
        'id': 'c-1',
        'name': 'Cochabamba',
        'state_id': 3,
        'latitude': -17.39,
        'longitude': -66.16,
      };
      final city = City.fromJson(json);
      expect(city.id, 'c-1');
      expect(city.name, 'Cochabamba');
      expect(city.stateId, 3);
      expect(city.latitude, -17.39);
      expect(city.longitude, -66.16);
      expect(city.state, isNull);
    });

    test('City.fromJson parsea join de estado', () {
      final json = {
        'id': 'c-2',
        'name': 'La Paz',
        'state_id': 2,
        'state': {
          'id': 2,
          'name': 'La Paz',
          'code': 'LP',
          'country_code': 'BO',
        },
      };
      final city = City.fromJson(json);
      expect(city.state, isNotNull);
      expect(city.state!.name, 'La Paz');
      expect(city.state!.code, 'LP');
      expect(city.stateName, 'La Paz');
    });

    test('City.displayName incluye estado si existe', () {
      const city1 = City(id: 'c-1', name: 'Sucre', stateName: 'Chuquisaca');
      expect(city1.displayName, 'Sucre, Chuquisaca');

      const city2 = City(id: 'c-2', name: 'Oruro');
      expect(city2.displayName, 'Oruro');
    });

    test('City.displayName prefiere nombre del join', () {
      const city = City(
        id: 'c-1',
        name: 'Tarija',
        stateName: 'Viejo',
        state: AppState(id: 1, name: 'Tarija'),
      );
      expect(city.displayName, 'Tarija, Tarija');
    });

    test('City.toJson serializa correctamente', () {
      const city = City(
        id: 'c-1',
        name: 'Tarija',
        stateId: 5,
        latitude: -21.53,
        longitude: -64.73,
      );
      final json = city.toJson();
      expect(json['id'], 'c-1');
      expect(json['name'], 'Tarija');
      expect(json['state_id'], 5);
      expect(json['latitude'], -21.53);
      expect(json['longitude'], -64.73);
    });

    test('City.copyWith copia y sobreescribe campos', () {
      const city = City(id: 'c-1', name: 'Santa Cruz');
      final copy = city.copyWith(name: 'Montero', stateName: 'Santa Cruz');
      expect(copy.id, 'c-1');
      expect(copy.name, 'Montero');
      expect(copy.stateName, 'Santa Cruz');
    });

    test('City.props contiene todos los campos', () {
      const city = City(id: 'c-1', name: 'Potosí');
      expect(city.props.length, 7);
    });
  });

  // ── ClientLocation Model ─────────────────────────────────────

  group('ClientLocation Model', () {
    test('ClientLocation.empty devuelve ubicación vacía', () {
      expect(ClientLocation.empty.isEmpty, isTrue);
      expect(ClientLocation.empty.isNotEmpty, isFalse);
    });

    test('ClientLocation con datos no está vacía', () {
      const loc = ClientLocation(
        id: 'loc-1',
        clientCompanyId: 'cc-1',
        name: 'Almacén Central',
      );
      expect(loc.isNotEmpty, isTrue);
    });

    test('ClientLocationType.fromValue parsea correctamente', () {
      expect(
        ClientLocationType.fromValue('WAREHOUSE'),
        ClientLocationType.warehouse,
      );
      expect(
        ClientLocationType.fromValue('DISTRIBUTION_CENTER'),
        ClientLocationType.distributionCenter,
      );
      expect(ClientLocationType.fromValue('OFFICE'), ClientLocationType.office);
      expect(ClientLocationType.fromValue('PLANT'), ClientLocationType.plant);
      expect(ClientLocationType.fromValue(null), ClientLocationType.warehouse);
      expect(
        ClientLocationType.fromValue('UNKNOWN'),
        ClientLocationType.warehouse,
      );
    });

    test('ClientLocationType.label devuelve etiquetas en español', () {
      expect(ClientLocationType.warehouse.label, 'Almacén');
      expect(
        ClientLocationType.distributionCenter.label,
        'Centro de Distribución',
      );
      expect(ClientLocationType.office.label, 'Oficina');
      expect(ClientLocationType.plant.label, 'Planta');
    });

    test('ClientLocationStatus.fromValue parsea correctamente', () {
      expect(
        ClientLocationStatus.fromValue('ACTIVE'),
        ClientLocationStatus.active,
      );
      expect(
        ClientLocationStatus.fromValue('INACTIVE'),
        ClientLocationStatus.inactive,
      );
      expect(ClientLocationStatus.fromValue(null), ClientLocationStatus.active);
    });

    test('ClientLocationStatus.label devuelve etiquetas en español', () {
      expect(ClientLocationStatus.active.label, 'Activa');
      expect(ClientLocationStatus.inactive.label, 'Inactiva');
    });

    test('ClientLocation.fromJson parsea correctamente', () {
      final json = {
        'id': 'loc-1',
        'client_company_id': 'cc-1',
        'name': 'Planta Norte',
        'type': 'PLANT',
        'address': 'Av. Industrial 123',
        'city_id': 'c-1',
        'country': 'Bolivia',
        'latitude': -17.783,
        'longitude': -63.182,
        'contact_name': 'Juan Pérez',
        'contact_phone': '77712345',
        'status': 'ACTIVE',
        'created_at': '2025-06-01T00:00:00Z',
      };
      final loc = ClientLocation.fromJson(json);
      expect(loc.id, 'loc-1');
      expect(loc.clientCompanyId, 'cc-1');
      expect(loc.name, 'Planta Norte');
      expect(loc.type, ClientLocationType.plant);
      expect(loc.address, 'Av. Industrial 123');
      expect(loc.cityId, 'c-1');
      expect(loc.country, 'Bolivia');
      expect(loc.latitude, -17.783);
      expect(loc.longitude, -63.182);
      expect(loc.contactName, 'Juan Pérez');
      expect(loc.contactPhone, '77712345');
      expect(loc.status, ClientLocationStatus.active);
      expect(loc.createdAt, isNotNull);
    });

    test('ClientLocation.fromJson parsea joins de company y city', () {
      final json = {
        'id': 'loc-2',
        'client_company_id': 'cc-2',
        'name': 'Oficina Central',
        'type': 'OFFICE',
        'status': 'INACTIVE',
        'client_company': {'id': 'cc-2', 'name': 'Empresa ABC'},
        'city': {
          'id': 'c-3',
          'name': 'Cochabamba',
          'state_id': 3,
          'state': {
            'id': 3,
            'name': 'Cochabamba',
            'code': 'CB',
            'country_code': 'BO',
          },
        },
      };
      final loc = ClientLocation.fromJson(json);
      expect(loc.clientCompany, isNotNull);
      expect(loc.clientCompany!.name, 'Empresa ABC');
      expect(loc.city, isNotNull);
      expect(loc.city!.name, 'Cochabamba');
      expect(loc.city!.stateName, 'Cochabamba');
      expect(loc.city!.state, isNotNull);
      expect(loc.city!.state!.code, 'CB');
      expect(loc.status, ClientLocationStatus.inactive);
    });

    test('ClientLocation.toJson no incluye id', () {
      const loc = ClientLocation(
        id: 'loc-1',
        clientCompanyId: 'cc-1',
        name: 'Almacén Sur',
        type: ClientLocationType.warehouse,
      );
      final json = loc.toJson();
      expect(json.containsKey('id'), isFalse);
      expect(json['client_company_id'], 'cc-1');
      expect(json['name'], 'Almacén Sur');
      expect(json['type'], 'WAREHOUSE');
      expect(json['status'], 'ACTIVE');
    });

    test('ClientLocation.displayName genera nombre correcto', () {
      const loc = ClientLocation(
        id: 'loc-1',
        clientCompanyId: 'cc-1',
        name: 'Almacén Central',
        type: ClientLocationType.warehouse,
      );
      expect(loc.displayName, 'Almacén Central (Almacén)');

      const loc2 = ClientLocation(
        id: 'loc-2',
        clientCompanyId: 'cc-1',
        name: 'CD Principal',
        type: ClientLocationType.distributionCenter,
      );
      expect(loc2.displayName, 'CD Principal (Centro de Distribución)');
    });

    test('ClientLocation.copyWith copia y sobreescribe campos', () {
      const loc = ClientLocation(
        id: 'loc-1',
        clientCompanyId: 'cc-1',
        name: 'Original',
        type: ClientLocationType.warehouse,
      );
      final copy = loc.copyWith(
        name: 'Modificado',
        type: ClientLocationType.office,
        status: ClientLocationStatus.inactive,
        latitude: -17.5,
      );
      expect(copy.id, 'loc-1');
      expect(copy.name, 'Modificado');
      expect(copy.type, ClientLocationType.office);
      expect(copy.status, ClientLocationStatus.inactive);
      expect(copy.latitude, -17.5);
      expect(copy.clientCompanyId, 'cc-1');
    });

    test('ClientLocation.props contiene todos los campos', () {
      expect(ClientLocation.empty.props.length, 15);
    });

    test('ClientLocation valores por defecto', () {
      const loc = ClientLocation(
        id: 'loc-1',
        clientCompanyId: 'cc-1',
        name: 'Test',
      );
      expect(loc.type, ClientLocationType.warehouse);
      expect(loc.status, ClientLocationStatus.active);
      expect(loc.country, 'Bolivia');
      expect(loc.address, isNull);
      expect(loc.cityId, isNull);
      expect(loc.latitude, isNull);
      expect(loc.longitude, isNull);
      expect(loc.contactName, isNull);
      expect(loc.contactPhone, isNull);
      expect(loc.clientCompany, isNull);
      expect(loc.city, isNull);
    });
  });

  // ── ClientLocation Bloc ──────────────────────────────────────

  group('ClientLocation Bloc', () {
    test('ClientLocationState initial tiene valores por defecto', () {
      const state = ClientLocationState();
      expect(state.status, ClientLocationBlocStatus.initial);
      expect(state.locations, isEmpty);
      expect(state.errorMessage, '');
      expect(state.isIdle, isTrue);
    });

    test('ClientLocationState isIdle es false cuando loading', () {
      const state = ClientLocationState(
        status: ClientLocationBlocStatus.loading,
      );
      expect(state.isIdle, isFalse);
    });

    test('ClientLocationState isIdle es false cuando creating', () {
      const state = ClientLocationState(
        status: ClientLocationBlocStatus.creating,
      );
      expect(state.isIdle, isFalse);
    });

    test('ClientLocationState isIdle es false cuando updating', () {
      const state = ClientLocationState(
        status: ClientLocationBlocStatus.updating,
      );
      expect(state.isIdle, isFalse);
    });

    test('ClientLocationState isIdle es false cuando deleting', () {
      const state = ClientLocationState(
        status: ClientLocationBlocStatus.deleting,
      );
      expect(state.isIdle, isFalse);
    });

    test('ClientLocationState copyWith sobreescribe campos', () {
      final locations = [
        const ClientLocation(
          id: 'loc-1',
          clientCompanyId: 'cc-1',
          name: 'Test',
        ),
      ];
      const state = ClientLocationState();
      final updated = state.copyWith(
        status: ClientLocationBlocStatus.loaded,
        locations: locations,
      );
      expect(updated.locations.length, 1);
      expect(updated.locations.first.id, 'loc-1');
    });

    test('ClientLocationState props contiene todos los campos', () {
      const state = ClientLocationState();
      expect(state.props.length, 3);
    });

    test('ClientLocationEvent — LoadRequested props', () {
      const event1 = ClientLocationLoadRequested();
      expect(event1.clientCompanyId, isNull);

      const event2 = ClientLocationLoadRequested(clientCompanyId: 'cc-1');
      expect(event2.clientCompanyId, 'cc-1');
      expect(event2.props, ['cc-1']);
    });

    test('ClientLocationEvent — CreateRequested props', () {
      const event = ClientLocationCreateRequested(
        clientCompanyId: 'cc-1',
        name: 'Almacén Norte',
        type: ClientLocationType.warehouse,
        address: 'Calle 1',
        cityId: 'c-1',
        latitude: -17.5,
        longitude: -63.2,
        contactName: 'Pedro',
        contactPhone: '77700000',
      );
      expect(event.clientCompanyId, 'cc-1');
      expect(event.name, 'Almacén Norte');
      expect(event.type, ClientLocationType.warehouse);
      expect(event.address, 'Calle 1');
      expect(event.country, 'Bolivia');
    });

    test('ClientLocationEvent — UpdateRequested props', () {
      const event = ClientLocationUpdateRequested(
        id: 'loc-1',
        name: 'Nuevo Nombre',
        status: ClientLocationStatus.inactive,
      );
      expect(event.id, 'loc-1');
      expect(event.name, 'Nuevo Nombre');
      expect(event.status, ClientLocationStatus.inactive);
      expect(event.type, isNull);
      expect(event.clientCompanyId, isNull);
    });

    test('ClientLocationEvent — DeleteRequested props', () {
      const event = ClientLocationDeleteRequested('loc-123');
      expect(event.id, 'loc-123');
      expect(event.props, ['loc-123']);
    });
  });

  // ===========================================================
  //  TRIP LOG MEDIA MODEL
  // ===========================================================
  group('TripLogMedia Model', () {
    test('TripLogMedia.empty devuelve media vacío', () {
      expect(TripLogMedia.empty.isEmpty, isTrue);
    });

    test('TripLogMedia con datos no está vacío', () {
      const media = TripLogMedia(
        id: 'tlm-1',
        tripLogId: 'tl-1',
        url: 'https://example.com/photo.jpg',
      );
      expect(media.isNotEmpty, isTrue);
    });

    test('TripLogMedia.fromJson parsea correctamente', () {
      final json = {
        'id': 'tlm-1',
        'trip_log_id': 'tl-1',
        'url': 'https://example.com/photo.jpg',
        'type': 'PHOTO',
        'caption': 'Foto de carga',
        'created_at': '2025-06-01T10:00:00Z',
      };
      final media = TripLogMedia.fromJson(json);
      expect(media.id, 'tlm-1');
      expect(media.tripLogId, 'tl-1');
      expect(media.url, 'https://example.com/photo.jpg');
      expect(media.type, TripLogMediaType.photo);
      expect(media.caption, 'Foto de carga');
      expect(media.createdAt, isNotNull);
    });

    test('TripLogMedia.fromJson con tipo VIDEO', () {
      final json = {
        'id': 'tlm-2',
        'trip_log_id': 'tl-1',
        'url': 'https://example.com/video.mp4',
        'type': 'VIDEO',
      };
      final media = TripLogMedia.fromJson(json);
      expect(media.type, TripLogMediaType.video);
    });

    test('TripLogMedia.toJson serializa correctamente', () {
      const media = TripLogMedia(
        id: 'tlm-1',
        tripLogId: 'tl-1',
        url: 'https://example.com/photo.jpg',
        type: TripLogMediaType.photo,
        caption: 'Test caption',
      );
      final json = media.toJson();
      expect(json['trip_log_id'], 'tl-1');
      expect(json['url'], 'https://example.com/photo.jpg');
      expect(json['type'], 'PHOTO');
      expect(json['caption'], 'Test caption');
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('created_at'), isFalse);
    });

    test('TripLogMedia copyWith sobreescribe campos', () {
      const media = TripLogMedia(
        id: 'tlm-1',
        tripLogId: 'tl-1',
        url: 'https://example.com/photo.jpg',
      );
      final updated = media.copyWith(
        caption: 'Nueva descripción',
        type: TripLogMediaType.video,
      );
      expect(updated.caption, 'Nueva descripción');
      expect(updated.type, TripLogMediaType.video);
      expect(updated.id, 'tlm-1');
    });

    test('TripLogMediaType labels en español', () {
      expect(TripLogMediaType.photo.label, 'Foto');
      expect(TripLogMediaType.video.label, 'Video');
    });

    test('TripLogMediaType fromValue con valor desconocido retorna photo', () {
      expect(TripLogMediaType.fromValue('UNKNOWN'), TripLogMediaType.photo);
      expect(TripLogMediaType.fromValue(null), TripLogMediaType.photo);
    });

    test('TripLogMedia props contiene todos los campos', () {
      expect(TripLogMedia.empty.props.length, 6);
    });
  });

  // ===========================================================
  //  TRIP LOG MODEL
  // ===========================================================
  group('TripLog Model', () {
    test('TripLog.empty devuelve log vacío', () {
      expect(TripLog.empty.isEmpty, isTrue);
    });

    test('TripLog con datos no está vacío', () {
      const log = TripLog(
        id: 'tl-1',
        tripId: 'trip-1',
        eventType: TripLogEventType.started,
      );
      expect(log.isNotEmpty, isTrue);
    });

    test('TripLog.fromJson parsea correctamente (básico)', () {
      final json = {
        'id': 'tl-1',
        'trip_id': 'trip-1',
        'user_id': 'user-1',
        'driver_id': null,
        'event_type': 'STARTED',
        'description': 'Viaje iniciado',
        'latitude': -17.39389,
        'longitude': -66.15689,
        'metadata': {'speed': 60},
        'created_at': '2025-06-01T10:00:00Z',
      };
      final log = TripLog.fromJson(json);
      expect(log.id, 'tl-1');
      expect(log.tripId, 'trip-1');
      expect(log.userId, 'user-1');
      expect(log.driverId, isNull);
      expect(log.eventType, TripLogEventType.started);
      expect(log.description, 'Viaje iniciado');
      expect(log.latitude, -17.39389);
      expect(log.longitude, -66.15689);
      expect(log.metadata, {'speed': 60});
      expect(log.hasLocation, isTrue);
      expect(log.createdAt, isNotNull);
    });

    test('TripLog.fromJson con joins de user y driver', () {
      final json = {
        'id': 'tl-2',
        'trip_id': 'trip-1',
        'user_id': 'user-1',
        'driver_id': 'driver-1',
        'event_type': 'INCIDENT',
        'user': {
          'id': 'user-1',
          'full_name': 'Supervisor López',
          'email': 'supervisor@test.com',
        },
        'driver': {
          'id': 'driver-1',
          'full_name': 'Conductor Pérez',
          'email': 'driver@test.com',
        },
        'media': [
          {
            'id': 'tlm-1',
            'trip_log_id': 'tl-2',
            'url': 'https://example.com/photo.jpg',
            'type': 'PHOTO',
          },
        ],
      };
      final log = TripLog.fromJson(json);
      expect(log.user, isNotNull);
      expect(log.user!.name, 'Supervisor López');
      expect(log.driver, isNotNull);
      expect(log.driver!.name, 'Conductor Pérez');
      expect(log.media.length, 1);
      expect(log.media.first.url, 'https://example.com/photo.jpg');
    });

    test('TripLog.fromJson sin media retorna lista vacía', () {
      final json = {
        'id': 'tl-3',
        'trip_id': 'trip-1',
        'event_type': 'COMPLETED',
      };
      final log = TripLog.fromJson(json);
      expect(log.media, isEmpty);
    });

    test('TripLog.toJson serializa correctamente', () {
      const log = TripLog(
        id: 'tl-1',
        tripId: 'trip-1',
        userId: 'user-1',
        eventType: TripLogEventType.departed,
        description: 'En camino',
        latitude: -17.5,
        longitude: -63.2,
      );
      final json = log.toJson();
      expect(json['trip_id'], 'trip-1');
      expect(json['user_id'], 'user-1');
      expect(json['event_type'], 'DEPARTED');
      expect(json['description'], 'En camino');
      expect(json['latitude'], -17.5);
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('created_at'), isFalse);
    });

    test('TripLog copyWith sobreescribe campos', () {
      const log = TripLog(
        id: 'tl-1',
        tripId: 'trip-1',
        eventType: TripLogEventType.assigned,
      );
      final updated = log.copyWith(
        eventType: TripLogEventType.completed,
        description: 'Completado exitosamente',
      );
      expect(updated.eventType, TripLogEventType.completed);
      expect(updated.description, 'Completado exitosamente');
      expect(updated.id, 'tl-1');
    });

    test('TripLog displayName incluye ícono y label', () {
      const log = TripLog(
        id: 'tl-1',
        tripId: 'trip-1',
        eventType: TripLogEventType.incident,
      );
      expect(log.displayName, '⚠️ Incidente');
    });

    test('TripLog hasLocation es false cuando no tiene coordenadas', () {
      const log = TripLog(
        id: 'tl-1',
        tripId: 'trip-1',
        eventType: TripLogEventType.assigned,
      );
      expect(log.hasLocation, isFalse);
    });

    test('TripLog props contiene todos los campos', () {
      expect(TripLog.empty.props.length, 14);
    });
  });

  // ===========================================================
  //  TRIP LOG EVENT TYPE
  // ===========================================================
  group('TripLogEventType', () {
    test('TripLogEventType tiene 14 valores', () {
      expect(TripLogEventType.values.length, 14);
    });

    test('TripLogEventType fromValue parsea todos los valores', () {
      expect(TripLogEventType.fromValue('ASSIGNED'), TripLogEventType.assigned);
      expect(TripLogEventType.fromValue('STARTED'), TripLogEventType.started);
      expect(
        TripLogEventType.fromValue('ARRIVED_AT_ORIGIN'),
        TripLogEventType.arrivedAtOrigin,
      );
      expect(
        TripLogEventType.fromValue('LOADING_STARTED'),
        TripLogEventType.loadingStarted,
      );
      expect(
        TripLogEventType.fromValue('LOADING_COMPLETED'),
        TripLogEventType.loadingCompleted,
      );
      expect(TripLogEventType.fromValue('DEPARTED'), TripLogEventType.departed);
      expect(
        TripLogEventType.fromValue('ARRIVED_AT_STOP'),
        TripLogEventType.arrivedAtStop,
      );
      expect(TripLogEventType.fromValue('INCIDENT'), TripLogEventType.incident);
      expect(TripLogEventType.fromValue('DELAY'), TripLogEventType.delay);
      expect(
        TripLogEventType.fromValue('ARRIVED_AT_DESTINATION'),
        TripLogEventType.arrivedAtDestination,
      );
      expect(
        TripLogEventType.fromValue('UNLOADING_STARTED'),
        TripLogEventType.unloadingStarted,
      );
      expect(
        TripLogEventType.fromValue('UNLOADING_COMPLETED'),
        TripLogEventType.unloadingCompleted,
      );
      expect(
        TripLogEventType.fromValue('COMPLETED'),
        TripLogEventType.completed,
      );
      expect(
        TripLogEventType.fromValue('CANCELLED'),
        TripLogEventType.cancelled,
      );
    });

    test(
      'TripLogEventType fromValue con valor desconocido retorna assigned',
      () {
        expect(
          TripLogEventType.fromValue('UNKNOWN'),
          TripLogEventType.assigned,
        );
        expect(TripLogEventType.fromValue(null), TripLogEventType.assigned);
      },
    );

    test('TripLogEventType labels en español', () {
      expect(TripLogEventType.assigned.label, 'Asignado');
      expect(TripLogEventType.started.label, 'Iniciado');
      expect(TripLogEventType.arrivedAtOrigin.label, 'Llegó al Origen');
      expect(TripLogEventType.loadingStarted.label, 'Carga Iniciada');
      expect(TripLogEventType.loadingCompleted.label, 'Carga Completada');
      expect(TripLogEventType.departed.label, 'En Camino');
      expect(TripLogEventType.arrivedAtStop.label, 'Llegó a Parada');
      expect(TripLogEventType.incident.label, 'Incidente');
      expect(TripLogEventType.delay.label, 'Retraso');
      expect(TripLogEventType.arrivedAtDestination.label, 'Llegó al Destino');
      expect(TripLogEventType.unloadingStarted.label, 'Descarga Iniciada');
      expect(TripLogEventType.unloadingCompleted.label, 'Descarga Completada');
      expect(TripLogEventType.completed.label, 'Completado');
      expect(TripLogEventType.cancelled.label, 'Cancelado');
    });

    test('TripLogEventType icon no está vacío', () {
      for (final type in TripLogEventType.values) {
        expect(type.icon.isNotEmpty, isTrue);
      }
    });
  });

  // ===========================================================
  //  TRIP LOG BLOC
  // ===========================================================
  group('TripLogBloc', () {
    test('TripLogState inicial tiene valores por defecto', () {
      const state = TripLogState();
      expect(state.status, TripLogStateStatus.initial);
      expect(state.logs, isEmpty);
      expect(state.errorMessage, '');
    });

    test('TripLogState copyWith sobreescribe campos', () {
      final logs = [
        const TripLog(
          id: 'tl-1',
          tripId: 'trip-1',
          eventType: TripLogEventType.started,
        ),
      ];
      const state = TripLogState();
      final updated = state.copyWith(
        status: TripLogStateStatus.loaded,
        logs: logs,
      );
      expect(updated.status, TripLogStateStatus.loaded);
      expect(updated.logs.length, 1);
      expect(updated.logs.first.id, 'tl-1');
    });

    test('TripLogState isIdle correcto', () {
      expect(
        const TripLogState(status: TripLogStateStatus.initial).isIdle,
        isTrue,
      );
      expect(
        const TripLogState(status: TripLogStateStatus.loaded).isIdle,
        isTrue,
      );
      expect(
        const TripLogState(status: TripLogStateStatus.success).isIdle,
        isTrue,
      );
      expect(
        const TripLogState(status: TripLogStateStatus.failure).isIdle,
        isTrue,
      );
      expect(
        const TripLogState(status: TripLogStateStatus.loading).isIdle,
        isFalse,
      );
      expect(
        const TripLogState(status: TripLogStateStatus.creating).isIdle,
        isFalse,
      );
    });

    test('TripLogState props contiene todos los campos', () {
      const state = TripLogState();
      expect(state.props.length, 3);
    });

    test('TripLogEvent — LoadRequested props', () {
      const event = TripLogLoadRequested(tripId: 'trip-1');
      expect(event.tripId, 'trip-1');
      expect(event.props, ['trip-1']);
    });

    test('TripLogEvent — CreateRequested props', () {
      const event = TripLogCreateRequested(
        tripId: 'trip-1',
        userId: 'user-1',
        eventType: TripLogEventType.started,
        description: 'Iniciado',
        latitude: -17.5,
        longitude: -63.2,
      );
      expect(event.tripId, 'trip-1');
      expect(event.userId, 'user-1');
      expect(event.driverId, isNull);
      expect(event.eventType, TripLogEventType.started);
      expect(event.description, 'Iniciado');
      expect(event.latitude, -17.5);
      expect(event.longitude, -63.2);
      expect(event.metadata, isNull);
    });

    test('TripLogEvent — CreateRequested con driver', () {
      const event = TripLogCreateRequested(
        tripId: 'trip-1',
        driverId: 'driver-1',
        eventType: TripLogEventType.arrivedAtOrigin,
      );
      expect(event.userId, isNull);
      expect(event.driverId, 'driver-1');
      expect(event.eventType, TripLogEventType.arrivedAtOrigin);
    });

    test('TripLogEvent — UpdateRequested props', () {
      const event = TripLogUpdateRequested(
        id: 'tl-1',
        eventType: TripLogEventType.completed,
        description: 'Completado',
      );
      expect(event.id, 'tl-1');
      expect(event.eventType, TripLogEventType.completed);
      expect(event.description, 'Completado');
      expect(event.userId, isNull);
      expect(event.driverId, isNull);
    });

    test('TripLogEvent — DeleteRequested props', () {
      const event = TripLogDeleteRequested('tl-123');
      expect(event.id, 'tl-123');
      expect(event.props, ['tl-123']);
    });
  });
}
