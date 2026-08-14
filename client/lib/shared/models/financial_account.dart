import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:decimal/decimal.dart';
import 'package:finvo/shared/utils/tolerant_json.dart';

part 'financial_account.freezed.dart';
part 'financial_account.g.dart';

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
    required FinancialNature nature,

    /// Account type: CASH, DEPOSIT, E_MONEY etc.
    FinancialAccountType? type,

    /// Currency code (Default: CNY)
    @Default('CNY') String currencyCode,

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
    @Default(AccountStatus.active) AccountStatus status,

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
