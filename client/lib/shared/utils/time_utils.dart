import 'package:intl/intl.dart';
import 'package:finvo/i18n/strings.g.dart';

/// Compact relative-time label (e.g. "3m ago") following the app's language.
///
/// Centralizes the just-now / minutes / hours / days / weeks / months / years
/// thresholds that were previously duplicated (with slight drifts) in the
/// transaction card, the notification center and the shared-space detail page.
/// Replaces the former `timeago` package usage so all locales (including
/// Traditional Chinese, which timeago does not ship) are covered by the app's
/// own i18n strings.
String relativeTime(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  // Guard against future timestamps (clock skew or pre-scheduled content): a
  // negative difference would otherwise surface as a nonsensical negative
  // count. Clamp to "just now" instead of rendering e.g. "-3m ago".
  if (difference.isNegative) {
    return t.time.justNow;
  }

  if (difference.inSeconds < 60) {
    return t.time.justNow;
  } else if (difference.inMinutes < 60) {
    return t.time.minutesAgo(count: difference.inMinutes);
  } else if (difference.inHours < 24) {
    return t.time.hoursAgo(count: difference.inHours);
  } else if (difference.inDays < 7) {
    return t.time.daysAgo(count: difference.inDays);
  } else if (difference.inDays < 30) {
    return t.time.weeksAgo(count: (difference.inDays / 7).floor());
  } else if (difference.inDays < 365) {
    return t.time.monthsAgo(count: (difference.inDays / 30).floor());
  } else {
    return t.time.yearsAgo(count: (difference.inDays / 365).floor());
  }
}

/// A [DateFormat] that follows the app's current language for full
/// timestamps, instead of the previously hardcoded `zh_CN` pattern.
DateFormat appDateTimeFormat() {
  switch (LocaleSettings.currentLocale) {
    case AppLocale.zh:
    case AppLocale.zhHant:
      return DateFormat('yyyy年M月d日 HH:mm:ss', 'zh_CN');
    case AppLocale.ja:
      return DateFormat('yyyy/MM/dd HH:mm:ss', 'ja');
    case AppLocale.ko:
      return DateFormat('yyyy.MM.dd HH:mm:ss', 'ko');
    case AppLocale.en:
      return DateFormat('MMM d, yyyy HH:mm:ss', 'en');
  }
}
