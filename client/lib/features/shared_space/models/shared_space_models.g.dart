// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_space_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SharedSpaceMember _$SharedSpaceMemberFromJson(Map<String, dynamic> json) =>
    _SharedSpaceMember(
      userId: json['userId'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      role:
          $enumDecodeNullable(
            _$MemberRoleEnumMap,
            json['role'],
            unknownValue: MemberRole.member,
          ) ??
          MemberRole.member,
      createdAt: _$JsonConverterFromJson<String, DateTime>(
        json['createdAt'],
        const LocalDateTimeConverter().fromJson,
      ),
      email: json['email'] as String?,
      status:
          $enumDecodeNullable(
            _$InviteStatusEnumMap,
            json['status'],
            unknownValue: InviteStatus.pending,
          ) ??
          InviteStatus.accepted,
      contributionAmount: json['contributionAmount'] as String? ?? '0.00',
    );

Map<String, dynamic> _$SharedSpaceMemberToJson(_SharedSpaceMember instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'avatarUrl': instance.avatarUrl,
      'role': _$MemberRoleEnumMap[instance.role]!,
      'createdAt': _$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const LocalDateTimeConverter().toJson,
      ),
      'email': instance.email,
      'status': _$InviteStatusEnumMap[instance.status]!,
      'contributionAmount': instance.contributionAmount,
    };

const _$MemberRoleEnumMap = {
  MemberRole.owner: 'OWNER',
  MemberRole.admin: 'ADMIN',
  MemberRole.member: 'MEMBER',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

const _$InviteStatusEnumMap = {
  InviteStatus.pending: 'PENDING',
  InviteStatus.accepted: 'ACCEPTED',
  InviteStatus.declined: 'DECLINED',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_SpaceCreator _$SpaceCreatorFromJson(Map<String, dynamic> json) =>
    _SpaceCreator(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );

Map<String, dynamic> _$SpaceCreatorToJson(_SpaceCreator instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'avatarUrl': instance.avatarUrl,
    };

_SharedSpace _$SharedSpaceFromJson(Map<String, dynamic> json) => _SharedSpace(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  creator: SpaceCreator.fromJson(json['creator'] as Map<String, dynamic>),
  role:
      $enumDecodeNullable(
        _$MemberRoleEnumMap,
        json['role'],
        unknownValue: MemberRole.member,
      ) ??
      MemberRole.member,
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['createdAt'],
    const LocalDateTimeConverter().fromJson,
  ),
  updatedAt: _$JsonConverterFromJson<String, DateTime>(
    json['updatedAt'],
    const LocalDateTimeConverter().fromJson,
  ),
  members: (json['members'] as List<dynamic>?)
      ?.map((e) => SharedSpaceMember.fromJson(e as Map<String, dynamic>))
      .toList(),
  transactionCount: (json['transactionCount'] as num?)?.toInt() ?? 0,
  currentInviteCode: json['currentInviteCode'] as String?,
  inviteCodeExpiresAt: _$JsonConverterFromJson<String, DateTime>(
    json['inviteCodeExpiresAt'],
    const LocalDateTimeConverter().fromJson,
  ),
  totalExpense: json['totalExpense'] as String? ?? '0.00',
);

Map<String, dynamic> _$SharedSpaceToJson(_SharedSpace instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'creator': instance.creator,
      'role': _$MemberRoleEnumMap[instance.role]!,
      'createdAt': _$JsonConverterToJson<String, DateTime>(
        instance.createdAt,
        const LocalDateTimeConverter().toJson,
      ),
      'updatedAt': _$JsonConverterToJson<String, DateTime>(
        instance.updatedAt,
        const LocalDateTimeConverter().toJson,
      ),
      'members': instance.members,
      'transactionCount': instance.transactionCount,
      'currentInviteCode': instance.currentInviteCode,
      'inviteCodeExpiresAt': _$JsonConverterToJson<String, DateTime>(
        instance.inviteCodeExpiresAt,
        const LocalDateTimeConverter().toJson,
      ),
      'totalExpense': instance.totalExpense,
    };

_InviteCode _$InviteCodeFromJson(Map<String, dynamic> json) => _InviteCode(
  code: json['code'] as String,
  spaceId: json['spaceId'] as String,
  spaceName: json['spaceName'] as String,
  expiresAt: _$JsonConverterFromJson<String, DateTime>(
    json['expiresAt'],
    const LocalDateTimeConverter().fromJson,
  ),
);

Map<String, dynamic> _$InviteCodeToJson(_InviteCode instance) =>
    <String, dynamic>{
      'code': instance.code,
      'spaceId': instance.spaceId,
      'spaceName': instance.spaceName,
      'expiresAt': _$JsonConverterToJson<String, DateTime>(
        instance.expiresAt,
        const LocalDateTimeConverter().toJson,
      ),
    };

_SettlementItem _$SettlementItemFromJson(Map<String, dynamic> json) =>
    _SettlementItem(
      fromUserId: json['fromUserId'] as String,
      fromUsername: json['fromUsername'] as String,
      toUserId: json['toUserId'] as String,
      toUsername: json['toUsername'] as String,
      amount: decimalFromJson(json['amount']),
    );

Map<String, dynamic> _$SettlementItemToJson(_SettlementItem instance) =>
    <String, dynamic>{
      'fromUserId': instance.fromUserId,
      'fromUsername': instance.fromUsername,
      'toUserId': instance.toUserId,
      'toUsername': instance.toUsername,
      'amount': _decimalToString(instance.amount),
    };

_Settlement _$SettlementFromJson(Map<String, dynamic> json) => _Settlement(
  spaceId: json['spaceId'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => SettlementItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalAmount: decimalFromJson(json['totalAmount']),
  calculatedAt: const LocalDateTimeConverter().fromJson(
    json['calculatedAt'] as String,
  ),
  isSettled: json['isSettled'] as bool? ?? false,
);

Map<String, dynamic> _$SettlementToJson(
  _Settlement instance,
) => <String, dynamic>{
  'spaceId': instance.spaceId,
  'items': instance.items,
  'totalAmount': _decimalToString(instance.totalAmount),
  'calculatedAt': const LocalDateTimeConverter().toJson(instance.calculatedAt),
  'isSettled': instance.isSettled,
};

_SharedSpaceNotificationModel _$SharedSpaceNotificationModelFromJson(
  Map<String, dynamic> json,
) => _SharedSpaceNotificationModel(
  id: json['id'] as String,
  userId: json['userId'] as String,
  type: $enumDecode(
    _$NotificationTypeEnumMap,
    json['type'],
    unknownValue: NotificationType.other,
  ),
  title: json['title'] as String,
  message: json['message'] as String,
  data: json['data'] as Map<String, dynamic>?,
  isRead: json['isRead'] as bool? ?? false,
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['createdAt'],
    const LocalDateTimeConverter().fromJson,
  ),
  readAt: _$JsonConverterFromJson<String, DateTime>(
    json['readAt'],
    const LocalDateTimeConverter().fromJson,
  ),
);

Map<String, dynamic> _$SharedSpaceNotificationModelToJson(
  _SharedSpaceNotificationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'type': _$NotificationTypeEnumMap[instance.type]!,
  'title': instance.title,
  'message': instance.message,
  'data': instance.data,
  'isRead': instance.isRead,
  'createdAt': _$JsonConverterToJson<String, DateTime>(
    instance.createdAt,
    const LocalDateTimeConverter().toJson,
  ),
  'readAt': _$JsonConverterToJson<String, DateTime>(
    instance.readAt,
    const LocalDateTimeConverter().toJson,
  ),
};

const _$NotificationTypeEnumMap = {
  NotificationType.spaceInvite: 'space_invite',
  NotificationType.newTransaction: 'new_transaction',
  NotificationType.settlementUpdate: 'settlement_update',
  NotificationType.memberJoined: 'member_joined',
  NotificationType.memberLeft: 'member_left',
  NotificationType.billComment: 'bill_comment',
  NotificationType.other: 'other',
};

_SpaceTransaction _$SpaceTransactionFromJson(Map<String, dynamic> json) =>
    _SpaceTransaction(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: json['amount'] as String,
      currency: json['currency'] as String? ?? Currency.defaultCode,
      description: json['description'] as String?,
      categoryKey: json['categoryKey'] as String?,
      transactionAt: _$JsonConverterFromJson<String, DateTime>(
        json['transactionAt'],
        const LocalDateTimeConverter().fromJson,
      ),
      addedByUsername: json['addedByUsername'] as String?,
      addedAt: _$JsonConverterFromJson<String, DateTime>(
        json['addedAt'],
        const LocalDateTimeConverter().fromJson,
      ),
      display: json['display'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$SpaceTransactionToJson(_SpaceTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'amount': instance.amount,
      'currency': instance.currency,
      'description': instance.description,
      'categoryKey': instance.categoryKey,
      'transactionAt': _$JsonConverterToJson<String, DateTime>(
        instance.transactionAt,
        const LocalDateTimeConverter().toJson,
      ),
      'addedByUsername': instance.addedByUsername,
      'addedAt': _$JsonConverterToJson<String, DateTime>(
        instance.addedAt,
        const LocalDateTimeConverter().toJson,
      ),
      'display': instance.display,
    };

_SpaceTransactionListResponse _$SpaceTransactionListResponseFromJson(
  Map<String, dynamic> json,
) => _SpaceTransactionListResponse(
  transactions: (json['transactions'] as List<dynamic>)
      .map((e) => SpaceTransaction.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  pageSize: (json['page_size'] as num).toInt(),
);

Map<String, dynamic> _$SpaceTransactionListResponseToJson(
  _SpaceTransactionListResponse instance,
) => <String, dynamic>{
  'transactions': instance.transactions,
  'total': instance.total,
  'page': instance.page,
  'page_size': instance.pageSize,
};

_SharedSpaceListResponse _$SharedSpaceListResponseFromJson(
  Map<String, dynamic> json,
) => _SharedSpaceListResponse(
  spaces: (json['spaces'] as List<dynamic>)
      .map((e) => SharedSpace.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  pageSize: (json['page_size'] as num).toInt(),
);

Map<String, dynamic> _$SharedSpaceListResponseToJson(
  _SharedSpaceListResponse instance,
) => <String, dynamic>{
  'spaces': instance.spaces,
  'total': instance.total,
  'page': instance.page,
  'page_size': instance.pageSize,
};
