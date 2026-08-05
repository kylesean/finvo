import 'package:dio/dio.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/features/shared_space/models/shared_space_models.dart';
import 'package:finvo/features/shared_space/services/shared_space_service.dart';

void main() {
  late Dio dio;
  late NetworkClient networkClient;
  late SharedSpaceService service;
  late RequestOptions lastRequest;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://localhost:9999'));
    networkClient = NetworkClient(dio);
    service = SharedSpaceService(networkClient);
  });

  void mockResponse(Map<String, dynamic> response) {
    dio.interceptors.clear();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          lastRequest = options;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              data: response,
              statusCode: 200,
            ),
          );
        },
      ),
    );
  }

  const spaceJson = {
    'id': 's1',
    'name': 'Team Trip',
    'description': 'Summer trip',
    'creator': {'id': 'u1', 'username': 'alice'},
    'role': 'OWNER',
  };

  group('getSharedSpaces', () {
    test('parses paginated response shape', () async {
      mockResponse({
        'data': {
          'spaces': [spaceJson],
          'total': 1,
          'page': 1,
          'limit': 20,
        },
      });

      final result = await service.getSharedSpaces(page: 2, limit: 50);

      expect(lastRequest.path, '/shared-spaces');
      expect(lastRequest.queryParameters['page'], 2);
      expect(lastRequest.queryParameters['limit'], 50);
      expect(result.spaces, hasLength(1));
      expect(result.spaces.first.id, 's1');
      expect(result.spaces.first.canManage, isTrue);
      expect(result.total, 1);
      expect(result.page, 1);
      expect(result.limit, 20);
    });
  });

  group('createSharedSpace', () {
    test('sends description when provided', () async {
      mockResponse({'data': spaceJson});

      final space = await service.createSharedSpace(
        name: 'Team Trip',
        description: 'Summer trip',
      );

      final body = lastRequest.data as Map<String, dynamic>;
      expect(body['name'], 'Team Trip');
      expect(body['description'], 'Summer trip');
      expect(space.id, 's1');
    });

    test('omits description when absent', () async {
      mockResponse({'data': spaceJson});

      await service.createSharedSpace(name: 'Team Trip');

      final body = lastRequest.data as Map<String, dynamic>;
      expect(body.containsKey('description'), isFalse);
    });
  });

  group('getSpaceTransactions', () {
    const txJson = {
      'id': 't1',
      'type': 'EXPENSE',
      'amount': '120.00',
      'currency': 'CNY',
      'transactionAt': '2026-01-01T10:00:00Z',
      'addedByUsername': 'alice',
      'addedAt': '2026-01-01T10:05:00Z',
    };

    test('parses paginated backend shape', () async {
      mockResponse({
        'data': {
          'transactions': [txJson],
          'total': 7,
          'page': 3,
          'limit': 2,
        },
      });

      final result = await service.getSpaceTransactions(
        's1',
        page: 3,
        limit: 2,
      );

      expect(lastRequest.path, '/shared-spaces/s1/transactions');
      expect(result.transactions, hasLength(1));
      expect(result.transactions.first.id, 't1');
      expect(result.total, 7);
      expect(result.page, 3);
      expect(result.limit, 2);
    });

    test('parses plain list shape with fallback counts', () async {
      mockResponse({
        'data': [txJson, txJson],
      });

      final result = await service.getSpaceTransactions('s1');

      expect(result.transactions, hasLength(2));
      expect(result.total, 2);
      expect(result.page, 1);
      expect(result.limit, 20);
    });

    test('throws DataParsingException on malformed payload', () async {
      mockResponse({'data': 'not-a-list'});

      await expectLater(
        service.getSpaceTransactions('s1'),
        throwsA(isA<DataParsingException>()),
      );
    });
  });

  group('joinSpaceWithCode', () {
    test('sends code without retry (non-idempotent)', () async {
      mockResponse({'data': spaceJson});

      final space = await service.joinSpaceWithCode('INVITE123');

      final body = lastRequest.data as Map<String, dynamic>;
      expect(body['code'], 'INVITE123');
      expect(space.name, 'Team Trip');
    });
  });

  group('member management', () {
    test('removeMember issues DELETE to the member endpoint', () async {
      mockResponse(<String, dynamic>{'data': null});

      await service.removeMember('s1', 'u9');

      expect(lastRequest.path, '/shared-spaces/s1/members/u9');
      expect(lastRequest.method, 'DELETE');
    });

    test('updateMemberRole PUTs the role', () async {
      mockResponse(<String, dynamic>{'data': null});

      await service.updateMemberRole('s1', 'u9', 'ADMIN');

      expect(lastRequest.path, '/shared-spaces/s1/members/u9/role');
      expect((lastRequest.data as Map<String, dynamic>)['role'], 'ADMIN');
    });
  });

  group('getSpaceSettlement', () {
    test('parses settlement response', () async {
      mockResponse({
        'data': {
          'spaceId': 's1',
          'items': [
            {
              'fromUserId': 'u1',
              'fromUsername': 'alice',
              'toUserId': 'u2',
              'toUsername': 'bob',
              'amount': '50.00',
            },
          ],
          'totalAmount': '50.00',
          'calculatedAt': '2026-01-01T00:00:00Z',
          'isSettled': false,
        },
      });

      final result = await service.getSpaceSettlement('s1');

      expect(result.spaceId, 's1');
      expect(result.items, hasLength(1));
      expect(result.totalAmount, Decimal.parse('50.00'));
      expect(result.isSettled, isFalse);
    });
  });
}
