import 'package:flutter_test/flutter_test.dart';

import 'package:bitacora/core/data/models/user.dart';

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
  });
}
