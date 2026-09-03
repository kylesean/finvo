import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/features/shared_space/models/shared_space_models.dart';
import 'package:finvo/features/shared_space/providers/shared_space_provider.dart';
import 'package:finvo/features/shared_space/services/shared_space_service.dart';

SharedSpace spaceFixture({
  required String id,
  MemberRole role = MemberRole.owner,
}) {
  return SharedSpace(
    id: id,
    name: 'Space $id',
    creator: const SpaceCreator(id: 'u1', username: 'alice'),
    role: role,
  );
}

class FakeSharedSpaceService extends SharedSpaceService {
  FakeSharedSpaceService() : super(NetworkClient(Dio()));

  final spaces = <SharedSpace>[
    spaceFixture(id: 's1', role: MemberRole.owner),
    spaceFixture(id: 's2', role: MemberRole.member),
  ];
  Object? failure;

  @override
  Future<SharedSpace> createSharedSpace({
    required String name,
    String? description,
  }) async {
    if (failure != null) throw failure!;
    final space = spaceFixture(id: 's-new');
    spaces.insert(0, space);
    return space;
  }

  @override
  Future<SharedSpace> joinSpaceWithCode(String inviteCode) async {
    if (failure != null) throw failure!;
    return spaceFixture(id: 's1', role: MemberRole.admin);
  }

  @override
  Future<void> leaveSpace(String spaceId) async {
    if (failure != null) throw failure!;
    spaces.removeWhere((s) => s.id == spaceId);
  }

  @override
  Future<void> deleteSpace(String spaceId) async {
    if (failure != null) throw failure!;
    spaces.removeWhere((s) => s.id == spaceId);
  }
}

ProviderContainer containerWith(FakeSharedSpaceService service) {
  final container = ProviderContainer(
    overrides: [sharedSpaceServiceProvider.overrideWithValue(service)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('SharedSpaceNotifier', () {
    test('createSpace prepends the new space', () async {
      final service = FakeSharedSpaceService();
      final container = containerWith(service);

      final created = await container
          .read(sharedSpaceProvider.notifier)
          .createSpace(name: 'Trip');

      expect(created?.id, 's-new');
      expect(container.read(sharedSpaceProvider).spaces.first.id, 's-new');
    });

    test('createSpace failure surfaces the typed message', () async {
      final service = FakeSharedSpaceService()
        ..failure = BusinessException('name taken');
      final container = containerWith(service);

      final created = await container
          .read(sharedSpaceProvider.notifier)
          .createSpace(name: 'Trip');

      expect(created, isNull);
      expect(container.read(sharedSpaceProvider).error, 'name taken');
    });

    test('joinSpaceWithCode updates the existing entry in place', () async {
      final service = FakeSharedSpaceService();
      final container = containerWith(service);
      final notifier = container.read(sharedSpaceProvider.notifier);
      await notifier.joinSpaceWithCode('CODE');
      final before = container.read(sharedSpaceProvider).spaces.length;

      final joined = await notifier.joinSpaceWithCode('CODE');

      expect(joined?.role, MemberRole.admin);
      final spaces = container.read(sharedSpaceProvider).spaces;
      expect(spaces.length, before);
      expect(spaces.firstWhere((s) => s.id == 's1').role, MemberRole.admin);
    });

    test('leaveSpace removes the space', () async {
      final service = FakeSharedSpaceService();
      final container = containerWith(service);
      final notifier = container.read(sharedSpaceProvider.notifier);
      await notifier.createSpace(name: 'x');

      final ok = await notifier.leaveSpace('s-new');

      expect(ok, isTrue);
      expect(
        container.read(sharedSpaceProvider).spaces.any((s) => s.id == 's-new'),
        isFalse,
      );
    });

    test('leaveSpace failure keeps the list and records the error', () async {
      final service = FakeSharedSpaceService()
        ..failure = NetworkException('offline');
      final container = containerWith(service);
      final notifier = container.read(sharedSpaceProvider.notifier);

      final ok = await notifier.leaveSpace('s2');

      expect(ok, isFalse);
      expect(container.read(sharedSpaceProvider).error, isNotNull);
    });
  });

  group('SharedSpacePermissions', () {
    test('owner manages, admin manages without ownership', () {
      expect(spaceFixture(id: 'a').isOwner, isTrue);
      expect(spaceFixture(id: 'a').canManage, isTrue);
      final admin = spaceFixture(id: 'b', role: MemberRole.admin);
      expect(admin.isOwner, isFalse);
      expect(admin.canManage, isTrue);
      expect(spaceFixture(id: 'c', role: MemberRole.member).canManage, isFalse);
    });

    test('unknown server role degrades to member', () {
      final space = SharedSpace.fromJson({
        'id': 's9',
        'name': 'Legacy',
        'creator': {'id': 'u1', 'username': 'alice'},
        'role': 'SUPERADMIN',
      });
      expect(space.role, MemberRole.member);
      expect(space.canManage, isFalse);
    });
  });
}
