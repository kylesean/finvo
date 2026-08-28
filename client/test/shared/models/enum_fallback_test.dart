import 'package:flutter_test/flutter_test.dart';

import 'package:finvo/features/chat/models/chat_message.dart';
import 'package:finvo/features/home/models/transaction_model.dart';
import 'package:finvo/features/shared_space/models/shared_space_models.dart';
import 'package:finvo/shared/models/financial_account.dart';

void main() {
  group('H5: unknown enum wire values degrade instead of crashing', () {
    test('NotificationType falls back to `other`', () {
      final model = SharedSpaceNotificationModel.fromJson({
        'id': 'n1',
        'userId': 'u1',
        'type': 'brand_new_server_type',
        'title': 't',
        'message': 'm',
      });
      expect(model.type, NotificationType.other);
    });

    test('MemberRole falls back to least-privileged `member`', () {
      final member = SharedSpaceMember.fromJson({
        'userId': 'u1',
        'username': 'alice',
        'role': 'SUPEROWNER',
      });
      expect(member.role, MemberRole.member);

      final space = SharedSpace.fromJson({
        'id': 's1',
        'name': 'Family',
        'creator': {'id': 'u1', 'username': 'alice'},
        'role': 'SUPEROWNER',
      });
      expect(space.role, MemberRole.member);
    });

    test('InviteStatus falls back to unresolved `pending`', () {
      final member = SharedSpaceMember.fromJson({
        'userId': 'u1',
        'username': 'alice',
        'status': 'MAYBE',
      });
      expect(member.status, InviteStatus.pending);
    });

    test('FinancialNature falls back to asset, AccountStatus to inactive', () {
      final account = FinancialAccount.fromJson({
        'name': 'Mystery',
        'nature': 'EQUITY',
        'initialBalance': '100.00',
        'status': 'FROZEN',
      });
      expect(account.nature, FinancialNature.asset);
      expect(account.status, AccountStatus.inactive);
    });

    test('FinancialAccountType falls back to null (same as absent)', () {
      final account = FinancialAccount.fromJson({
        'name': 'Mystery',
        'nature': 'ASSET',
        'type': 'CRYPTO',
        'initialBalance': '100.00',
      });
      expect(account.type, isNull);
    });

    test('TransactionType falls back to `other` (generated fromJson path)', () {
      final model = TransactionModel.fromJson({
        'id': 't1',
        'type': 'RECONCILE',
        'category': 'Misc',
        'iconUrl': '',
        'amount': '10.00',
        'timestamp': '2026-01-01T00:00:00.000Z',
      });
      expect(model.type, TransactionType.other);
    });

    test('ChatMessage enums fall back to their neutral defaults', () {
      final message = ChatMessage.fromJson({
        'id': 'm1',
        'role': 'assistant',
        'content': 'hello',
        'messageType': 'voice_note',
        'feedbackStatus': 'stared_at',
        'streamingStatus': 'warp_speed',
      });
      expect(message.messageType, MessageType.text);
      expect(message.feedbackStatus, AIFeedbackStatus.none);
      expect(message.streamingStatus, StreamingStatus.none);
    });
  });
}
