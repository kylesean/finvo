import 'package:flutter_test/flutter_test.dart';
import 'package:finvo/features/auth/models/auth_response.dart';
import 'package:finvo/features/auth/models/user.dart';

void main() {
  group('UserModel Serialization', () {
    test('parses phone when phone field is present', () {
      final json = {
        'id': 'u1',
        'username': 'alice',
        'email': 'alice@example.com',
        'phone': '13800138000',
      };
      final user = UserModel.fromJson(json);
      expect(user.id, 'u1');
      expect(user.phone, '13800138000');
      expect(user.toJson()['phone'], '13800138000');
    });

    test('parses phone when only mobile field is present', () {
      final json = {
        'id': 'u2',
        'username': 'bob',
        'email': 'bob@example.com',
        'mobile': '13900139000',
      };
      final user = UserModel.fromJson(json);
      expect(user.id, 'u2');
      expect(user.phone, '13900139000');
      expect(user.toJson()['phone'], '13900139000');
    });

    test('prefers phone over mobile when both are present', () {
      final json = {
        'id': 'u3',
        'phone': '13800138000',
        'mobile': '13900139000',
      };
      final user = UserModel.fromJson(json);
      expect(user.phone, '13800138000');
    });

    test(
      'serializes to json cleanly and integrates with AuthResponseModel',
      () {
        final authJson = {
          'user': {'id': 'u4', 'username': 'charlie', 'mobile': '13700137000'},
          'token': 'jwt-test-token',
        };
        final authResponse = AuthResponseModel.fromJson(authJson);
        expect(authResponse.user.phone, '13700137000');
        expect(authResponse.token, 'jwt-test-token');

        final serialized = authResponse.toJson();
        expect(serialized['user']['phone'], '13700137000');
        expect(serialized['token'], 'jwt-test-token');
      },
    );
  });
}
