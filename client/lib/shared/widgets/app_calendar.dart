import 'dart:async';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Custom day builder for FCalendar that displays pure numbers (e.g. "1", "28")
/// instead of appending CJK date suffixes like "日" in Chinese locales.
///
/// Preserves all Forui native styling (selected, today, range, disabled).
Widget appCalendarDayBuilder(
  BuildContext context,
  FCalendarDayStyles styles,
  FLocalizations localizations,
  DateTime date,
  Set<FCalendarDayVariant> variants,
) {
  final style = styles.resolve(variants);
  return DecoratedBox(
    decoration: style.background,
    child: DecoratedBox(
      decoration: style.foreground,
      child: Center(child: Text('${date.day}', style: style.textStyle)),
    ),
  );
}

/// Unified AppCalendar component wrapping FCalendar with robust layout and i18n day formatting.
class AppCalendar {
  /// Renders a standardized FCalendar.grid with i18n day formatting and clean layout.
  static Widget grid({
    required FDateSelectionControl<dynamic> selectionControl,
    FGridCalendarControl control = const FGridCalendarControl(),
    FCalendarStyleDelta style = const .context(),
    bool fixedWeeks = false,
    Widget Function(
          BuildContext,
          FCalendarDayStyles,
          FLocalizations,
          DateTime,
          Set<FCalendarDayVariant>,
        )
        dayBuilder =
        appCalendarDayBuilder,
    Widget Function(
      BuildContext,
      FGridCalendarController,
      FDateSelectionController<dynamic>,
      Widget,
    )?
    headerBuilder,
    Widget Function(
      BuildContext,
      FGridCalendarController,
      FDateSelectionController<dynamic>,
    )?
    footerBuilder,
    FutureOr<void> Function(DateTime)? onDayPress,
    FutureOr<void> Function(DateTime)? onDayLongPress,
    Key? key,
  }) {
    return FCalendar.grid(
      key: key,
      selectionControl: selectionControl,
      control: control,
      style: style,
      fixedWeeks: fixedWeeks,
      dayBuilder: dayBuilder,
      headerBuilder: headerBuilder ?? FCalendar.defaultHeaderBuilder,
      footerBuilder: footerBuilder ?? FCalendar.defaultFooterBuilder,
      onDayPress: onDayPress,
      onDayLongPress: onDayLongPress,
    );
  }
}
