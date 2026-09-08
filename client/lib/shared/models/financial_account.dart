import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:finvo/shared/utils/date_time_utils.dart';
import 'package:decimal/decimal.dart';
import 'package:finvo/shared/utils/tolerant_json.dart';
import 'package:logging/logging.dart';
import 'package:finvo/shared/models/currency.dart';

part 'financial_account.freezed.dart';
part 'financial_account.g.dart';

final _logger = Logger('financial_account');

/// Account display info for cross-currency views
@freezed
abstract class AccountDisplay with _$AccountDisplay {
  const factory AccountDisplay({
    required String sign,
    required String value,
    required String valueFormatted,
    required String currencySymbol,
    required String fullString,
  }) = _AccountDisplay;

  factory AccountDisplay.fromJson(Map<String, dynamic> json) =>
      _$AccountDisplayFromJson(json);
}

/// Financial nature enum - Corresponds to the nature field in backend API
enum FinancialNature {
  @JsonValue('ASSET')
  asset,
  @JsonValue('LIABILITY')
  liability,
}

/// Financial account type enum - Corresponds to the type field in backend API
enum FinancialAccountType {
  @JsonValue('CASH')
  cash,
  @JsonValue('DEPOSIT')
  deposit,
  @JsonValue('E_MONEY')
  eMoney,
  @JsonValue('INVESTMENT')
  investment,
  @JsonValue('RECEIVABLE')
  receivable,
  @JsonValue('CREDIT_CARD')
  creditCard,
  @JsonValue('LOAN')
  loan,
  @JsonValue('PAYABLE')
  payable,
}

/// Account status enum - Corresponds to the status field in backend API
enum AccountStatus {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('INACTIVE')
  inactive,
  @JsonValue('CLOSED')
  closed,
}

/// Financial account data model - Corresponds to backend API response
@freezed
abstract class FinancialAccount with _$FinancialAccount {
  const factory FinancialAccount({
    /// Account ID (UUID from backend)
    String? id,

    /// Account name
    required String name,

    /// Account nature: ASSET or LIABILITY
    ///
    /// An unknown wire value degrades to [FinancialNature.asset] (with a
    /// warning) instead of crashing the whole account-list parse.
    @JsonKey(fromJson: _financialNatureFromJson)
    required FinancialNature nature,

    /// Account type: CASH, DEPOSIT, E_MONEY etc.
    ///
    /// An unknown wire value degrades to null (same as an absent type)
    /// instead of crashing the parse.
    @JsonKey(fromJson: _financialAccountTypeFromJson)
    FinancialAccountType? type,

    /// Currency code (Default: CNY)
    @Default(Currency.defaultCode) String currencyCode,

    /// Initial balance
    @JsonKey(fromJson: decimalFromJson, toJson: decimalToJson)
    required Decimal initialBalance,

    /// Current balance
    @JsonKey(fromJson: decimalOrNullFromJson, toJson: decimalToJsonOrZero)
    Decimal? currentBalance,

    /// Whether to include in net worth
    @Default(true) bool includeInNetWorth,

    /// Whether to include in daily cash flow forecast (Liquidity tag)
    @Default(false) bool includeInCashFlow,

    /// Display info (optional, used for cross-currency summary display)
    AccountDisplay? display,

    /// Account status
    ///
    /// Unknown status degrades to [AccountStatus.inactive] (conservative
    /// non-active) instead of crashing the parse.
    @JsonKey(unknownEnumValue: AccountStatus.inactive)
    @Default(AccountStatus.active)
    AccountStatus status,

    /// Creation time (ISO 8601 string)
    String? createdAt,

    /// Update time (ISO 8601 string)
    String? updatedAt,
  }) = _FinancialAccount;

  factory FinancialAccount.fromJson(Map<String, dynamic> json) =>
      _$FinancialAccountFromJson(json);
}

/// Financial account summary response model
@freezed
abstract class FinancialAccountSummary with _$FinancialAccountSummary {
  @JsonSerializable(converters: [LocalDateTimeConverter()])
  const factory FinancialAccountSummary({
    @JsonKey(fromJson: decimalFromJson, toJson: decimalToJson)
    required Decimal totalBalance,
    required DateTime lastUpdatedAt,
  }) = _FinancialAccountSummary;

  factory FinancialAccountSummary.fromJson(Map<String, dynamic> json) =>
      _$FinancialAccountSummaryFromJson(json);
}

/// Financial account list response model
@freezed
abstract class FinancialAccountResponse with _$FinancialAccountResponse {
  const factory FinancialAccountResponse({
    @Default([]) List<FinancialAccount> accounts,
    @JsonKey(fromJson: decimalFromJsonNullable, toJson: decimalToJson)
    required Decimal totalBalance,
    @Default('') String lastUpdatedAt,
  }) = _FinancialAccountResponse;

  factory FinancialAccountResponse.fromJson(Map<String, dynamic> json) =>
      _$FinancialAccountResponseFromJson(json);
}

/// Financial account request model
@freezed
abstract class FinancialAccountRequest with _$FinancialAccountRequest {
  @JsonSerializable(explicitToJson: true)
  const factory FinancialAccountRequest({
    required List<FinancialAccount> accounts,
  }) = _FinancialAccountRequest;

  factory FinancialAccountRequest.fromJson(Map<String, dynamic> json) =>
      _$FinancialAccountRequestFromJson(json);
}

/// Tolerant decoder for [FinancialNature] — unknown wire values degrade
/// to [FinancialNature.asset] (the majority case) with a warning instead of
/// crashing the whole account-list parse.
FinancialNature _financialNatureFromJson(dynamic value) {
  final wire = value?.toString().toUpperCase();
  if (wire == 'LIABILITY') return FinancialNature.liability;
  if (wire == 'ASSET') return FinancialNature.asset;
  _logger.warning('Unknown FinancialNature "$value"; degrading to asset');
  return FinancialNature.asset;
}

/// Tolerant decoder for [FinancialAccountType] — unknown wire values
/// degrade to null (same as an absent type) with a warning instead of
/// crashing the parse.
FinancialAccountType? _financialAccountTypeFromJson(dynamic value) {
  if (value == null) return null;
  final type = switch (value.toString().toUpperCase()) {
    'CASH' => FinancialAccountType.cash,
    'DEPOSIT' => FinancialAccountType.deposit,
    'E_MONEY' => FinancialAccountType.eMoney,
    'INVESTMENT' => FinancialAccountType.investment,
    'RECEIVABLE' => FinancialAccountType.receivable,
    'CREDIT_CARD' => FinancialAccountType.creditCard,
    'LOAN' => FinancialAccountType.loan,
    'PAYABLE' => FinancialAccountType.payable,
    _ => null,
  };
  if (type == null) {
    _logger.warning('Unknown FinancialAccountType "$value"; degrading to null');
  }
  return type;
}
