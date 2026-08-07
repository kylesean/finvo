import 'package:intl/intl.dart';

import 'package:finvo/core/constants/category_constants.dart';
import 'package:finvo/features/finance/models/recurring_transaction.dart';
import 'package:finvo/i18n/strings.g.dart';

/// Display-name helper for a recurring transaction.
///
/// Uses the description if present, otherwise falls back to the localized
/// category name, then to a type-based default label.
///
/// M-28: extracted from `RecurringTransactionListPage._getDisplayName` so both
/// the list card and its confirm dialogs share one implementation.
String recurringTransactionDisplayName(RecurringTransaction transaction) {
  if (transaction.description != null && transaction.description!.isNotEmpty) {
    return transaction.description!;
  }

  // Use localized category display name (already internationalized)
  if (transaction.categoryKey != null) {
    final category = TransactionCategory.fromKey(transaction.categoryKey!);
    return category.displayText;
  }

  // Default name: return based on type
  return switch (transaction.type) {
    RecurringTransactionType.expense => t.transaction.expense,
    RecurringTransactionType.income => t.transaction.income,
    RecurringTransactionType.transfer => t.transaction.transfer,
  };
}

/// Format a short date (i18n support).
///
/// Uses a switch expression for easy addition of more language support.
///
/// M-28: extracted from `RecurringTransactionListPage._formatShortDate`.
String formatShortDate(DateTime date) {
  final locale = LocaleSettings.currentLocale;
  final (dateFormatLocale, pattern) = switch (locale) {
    AppLocale.zh => ('zh_CN', 'M 月 d 日'),
    AppLocale.en => ('en', 'MMM d'),
    AppLocale.ja => ('ja', 'M月d日'),
    AppLocale.ko => ('ko', 'M월 d일'),
    AppLocale.zhHant => ('zh_TW', 'M 月 d 日'),
  };
  return DateFormat(pattern, dateFormatLocale).format(date);
}
