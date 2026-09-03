import 'package:decimal/decimal.dart';

/// Form validation errors for a recurring-transaction form.
enum RecurringFormError {
  invalidAmount,
  missingAccount,
  sameAccount,
  endBeforeStart,
}

/// Pure validation for the recurring-transaction form. Returns the first
/// failure, or null when the form is submittable. No UI side effects.
RecurringFormError? validateRecurringForm({
  required String amountText,
  required bool isTransfer,
  required String? sourceAccountId,
  required String? targetAccountId,
  required DateTime startDate,
  required DateTime? endDate,
}) {
  final amount = Decimal.tryParse(amountText);
  if (amount == null || amount <= Decimal.zero) {
    return RecurringFormError.invalidAmount;
  }
  if (isTransfer) {
    if (sourceAccountId == null || targetAccountId == null) {
      return RecurringFormError.missingAccount;
    }
    if (sourceAccountId == targetAccountId) {
      return RecurringFormError.sameAccount;
    }
  } else if (sourceAccountId == null) {
    return RecurringFormError.missingAccount;
  }
  if (endDate != null && endDate.isBefore(startDate)) {
    return RecurringFormError.endBeforeStart;
  }
  return null;
}
