import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:finvo/shared/utils/date_time_utils.dart';
import 'package:decimal/decimal.dart';
import 'package:finvo/shared/utils/tolerant_json.dart';
import 'package:finvo/shared/models/currency.dart';

part 'shared_space_models.freezed.dart';
part 'shared_space_models.g.dart';

enum MemberRole {
  @JsonValue('OWNER')
  owner,
  @JsonValue('ADMIN')
  admin,
  @JsonValue('MEMBER')
  member,
}

enum InviteStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('ACCEPTED')
  accepted,
  @JsonValue('DECLINED')
  declined,
}

enum NotificationType {
  @JsonValue('space_invite')
  spaceInvite,
  @JsonValue('new_transaction')
  newTransaction,
  @JsonValue('settlement_update')
  settlementUpdate,
  @JsonValue('member_joined')
  memberJoined,
  @JsonValue('member_left')
  memberLeft,
  @JsonValue('bill_comment')
  billComment,

  /// Fallback for unknown/unsupported notification types coming from the
  /// backend. Previously the mapper defaulted to [spaceInvite], which caused
  /// non-invite notifications to render accept/reject actions. Mapped here
  /// instead so the UI renders a neutral card with no invite actions.
  @JsonValue('other')
  other,
}

@freezed
abstract class SharedSpaceMember with _$SharedSpaceMember {
  @JsonSerializable(converters: [LocalDateTimeConverter()])
  const factory SharedSpaceMember({
    required String userId,
    required String username,
    String? avatarUrl,
    // An unknown server-side role must degrade to the least-privileged
    // value instead of crashing the whole space/member payload parse.
    @JsonKey(unknownEnumValue: MemberRole.member)
    @Default(MemberRole.member)
    MemberRole role,
    DateTime? createdAt,
    String? email,
    // An unknown invite status is an *unresolved* state, not an accepted
    // membership — degrade to pending instead of crashing the parse.
    @JsonKey(unknownEnumValue: InviteStatus.pending)
    @Default(InviteStatus.accepted)
    InviteStatus status,
    @Default('0.00') String contributionAmount,
  }) = _SharedSpaceMember;

  factory SharedSpaceMember.fromJson(Map<String, dynamic> json) =>
      _$SharedSpaceMemberFromJson(json);
}

@freezed
abstract class SpaceCreator with _$SpaceCreator {
  const factory SpaceCreator({
    required String id,
    required String username,
    String? avatarUrl,
  }) = _SpaceCreator;

  factory SpaceCreator.fromJson(Map<String, dynamic> json) =>
      _$SpaceCreatorFromJson(json);
}

@freezed
abstract class SharedSpace with _$SharedSpace {
  @JsonSerializable(converters: [LocalDateTimeConverter()])
  const factory SharedSpace({
    required String id,
    required String name,
    String? description,
    required SpaceCreator creator,
    // Unknown role degrades to least-privileged member (see
    // SharedSpaceMember.role).
    @JsonKey(unknownEnumValue: MemberRole.member)
    @Default(MemberRole.member)
    MemberRole role,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<SharedSpaceMember>? members,
    @Default(0) int transactionCount,
    String? currentInviteCode,
    DateTime? inviteCodeExpiresAt,
    @Default('0.00') String totalExpense,
  }) = _SharedSpace;

  factory SharedSpace.fromJson(Map<String, dynamic> json) =>
      _$SharedSpaceFromJson(json);
}

/// Permission helpers for the current user's role in a space.
extension SharedSpacePermissions on SharedSpace {
  /// Whether the current user can manage the space (edit info, manage members).
  bool get canManage => role == MemberRole.owner || role == MemberRole.admin;

  /// Whether the current user is the owner.
  bool get isOwner => role == MemberRole.owner;

  /// Whether the current user can generate/refresh invite codes.
  bool get canGenerateInvite => canManage;
}

@freezed
abstract class InviteCode with _$InviteCode {
  @JsonSerializable(converters: [LocalDateTimeConverter()])
  const factory InviteCode({
    required String code,
    required String spaceId,
    required String spaceName,
    DateTime? expiresAt,
  }) = _InviteCode;

  factory InviteCode.fromJson(Map<String, dynamic> json) =>
      _$InviteCodeFromJson(json);
}

@freezed
abstract class SettlementItem with _$SettlementItem {
  const factory SettlementItem({
    required String fromUserId,
    required String fromUsername,
    required String toUserId,
    required String toUsername,
    // Tolerant converter — strict Decimal.parse crashed the whole
    // settlement parse on a malformed/empty string.
    @JsonKey(fromJson: decimalFromJson, toJson: _decimalToString)
    required Decimal amount,
  }) = _SettlementItem;

  factory SettlementItem.fromJson(Map<String, dynamic> json) =>
      _$SettlementItemFromJson(json);
}

@freezed
abstract class Settlement with _$Settlement {
  @JsonSerializable(converters: [LocalDateTimeConverter()])
  const factory Settlement({
    required String spaceId,
    required List<SettlementItem> items,
    // Tolerant converter — strict Decimal.parse crashed the whole
    // settlement parse on a malformed/empty string.
    @JsonKey(fromJson: decimalFromJson, toJson: _decimalToString)
    required Decimal totalAmount,
    required DateTime calculatedAt,
    @Default(false) bool isSettled,
  }) = _Settlement;

  factory Settlement.fromJson(Map<String, dynamic> json) =>
      _$SettlementFromJson(json);
}

@freezed
abstract class SharedSpaceNotificationModel
    with _$SharedSpaceNotificationModel {
  @JsonSerializable(converters: [LocalDateTimeConverter()])
  const factory SharedSpaceNotificationModel({
    required String id,
    required String userId,
    // `other` is the designed neutral fallback for unknown notification
    // types (see the enum's doc) — wire it so server-side additions render a
    // neutral card instead of crashing the whole list parse.
    @JsonKey(unknownEnumValue: NotificationType.other)
    required NotificationType type,
    required String title,
    required String message,
    Map<String, dynamic>? data,
    @Default(false) bool isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) = _SharedSpaceNotificationModel;

  factory SharedSpaceNotificationModel.fromJson(Map<String, dynamic> json) =>
      _$SharedSpaceNotificationModelFromJson(json);
}

@freezed
abstract class SpaceTransaction with _$SpaceTransaction {
  @JsonSerializable(converters: [LocalDateTimeConverter()])
  const factory SpaceTransaction({
    required String id,
    required String type, // EXPENSE, INCOME, TRANSFER
    required String amount,
    @Default(Currency.defaultCode) String currency,
    String? description,
    String? categoryKey,
    @JsonKey(name: 'transactionAt') DateTime? transactionAt,
    @JsonKey(name: 'addedByUsername') String? addedByUsername,
    @JsonKey(name: 'addedAt') DateTime? addedAt,

    Map<String, dynamic>? display,
  }) = _SpaceTransaction;

  factory SpaceTransaction.fromJson(Map<String, dynamic> json) =>
      _$SpaceTransactionFromJson(json);
}

@freezed
abstract class SpaceTransactionListResponse
    with _$SpaceTransactionListResponse {
  const factory SpaceTransactionListResponse({
    required List<SpaceTransaction> transactions,
    required int total,
    required int page,
    @JsonKey(name: 'page_size') required int pageSize,
  }) = _SpaceTransactionListResponse;

  factory SpaceTransactionListResponse.fromJson(Map<String, dynamic> json) =>
      _$SpaceTransactionListResponseFromJson(json);
}

@freezed
abstract class SharedSpaceListResponse with _$SharedSpaceListResponse {
  const factory SharedSpaceListResponse({
    required List<SharedSpace> spaces,
    required int total,
    required int page,
    @JsonKey(name: 'page_size') required int pageSize,
  }) = _SharedSpaceListResponse;

  factory SharedSpaceListResponse.fromJson(Map<String, dynamic> json) =>
      _$SharedSpaceListResponseFromJson(json);
}

String _decimalToString(Decimal decimal) => decimal.toString();
