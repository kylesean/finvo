/// GenUI DataPath Constants
///
/// Centrally manage all business-related DataPath strings to avoid spelling errors from hardcoding in multiple components.
class GenUiDataPaths {
  GenUiDataPaths._();

  // Common fields
  static const String amount = '/amount';
  static const String currency = '/currency';
  static const String memo = '/memo';
  static const String surfaceId = '/_surfaceId';

  // Account related
  static const String preselectedSourceId = '/preselectedSourceId';
  static const String preselectedTargetId = '/preselectedTargetId';
  static const String sourceBalance = '/source_balance';
  static const String targetBalance = '/target_balance';

  // Warnings and errors
  static const String balanceWarning = '/balance_warning';
  static const String amountError = '/amount_error';
  static const String generalError = '/_error';
}
