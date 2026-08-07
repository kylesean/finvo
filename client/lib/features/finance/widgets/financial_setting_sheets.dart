import 'dart:async';
import 'dart:math' as math;

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import 'package:finvo/features/profile/models/financial_settings.dart';
import 'package:finvo/features/profile/providers/financial_settings_provider.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/shared/utils/amount_formatter.dart';
import 'package:logging/logging.dart';

final _logger = Logger('FinancialSettingSheets');

/// Show safety threshold settings
void showSafetyThresholdSettings(BuildContext context) {
  unawaited(
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return const _SafetyThresholdBottomSheet();
      },
    ),
  );
}

/// Show daily spending settings
void showDailySpendingSettings(BuildContext context) {
  unawaited(
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return const _DailySpendingBottomSheet();
      },
    ),
  );
}

// Bottom sheet components below

/// Shared slider-based amount input bottom sheet, used by both the safety
/// threshold and daily spending settings (previously near-duplicated).
class _AmountSliderBottomSheet extends ConsumerStatefulWidget {
  const _AmountSliderBottomSheet({
    required this.title,
    required this.subtitle,
    required this.successMessage,
    required this.fallbackValue,
    required this.maxSliderLimit,
    required this.initialValueOf,
    required this.onSave,
    this.textFieldWidth = 140,
    this.unitLabel,
  });

  final String title;
  final String subtitle;
  final String successMessage;
  final double fallbackValue;
  final double maxSliderLimit;

  /// Returns the persisted value used to prefill the field, or null if none is set.
  final double? Function(FinancialSettingsState state) initialValueOf;

  /// Persists the value; returns true on success, false on failure.
  final Future<bool> Function(double value) onSave;
  final double textFieldWidth;
  final String? unitLabel;

  @override
  ConsumerState<_AmountSliderBottomSheet> createState() =>
      _AmountSliderBottomSheetState();
}

class _AmountSliderBottomSheetState
    extends ConsumerState<_AmountSliderBottomSheet> {
  late double _currentValue;
  bool _hasInitialized = false;
  bool _isUpdatingFromSlider = false;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.fallbackValue;
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSliderChanged(double val) {
    _isUpdatingFromSlider = true;
    setState(() {
      _currentValue = val;
      _controller.text = val.toStringAsFixed(0);
    });
    _isUpdatingFromSlider = false;
  }

  void _onTextChanged(String text) {
    if (_isUpdatingFromSlider) return;
    final parsed = double.tryParse(text) ?? 0.0;
    setState(() {
      _currentValue = math.max(0.0, parsed);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colors;
    final settingsState = ref.watch(financialSettingsProvider);
    final primaryCurrency = settingsState.primaryCurrency;
    final symbol = AmountFormatter.getCurrencySymbol(primaryCurrency);

    if (!_hasInitialized && !settingsState.isLoading) {
      // Prefill the persisted value only once the provider has finished loading.
      // Guarding on isLoading avoids clobbering the field with the fallback value
      // on the first frame, before the async load completes. Previously
      // [_hasInitialized] was set true too early, so a real persisted value was
      // never backfilled and a blind save silently overwrote it with the
      // fallback value.
      final initial = widget.initialValueOf(settingsState);
      if (initial != null) {
        _currentValue = initial;
        _controller.text = _currentValue.toStringAsFixed(0);
        _hasInitialized = true;
      }
    }

    final double sliderValue = _currentValue.clamp(0.0, widget.maxSliderLimit);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.only(top: 12.0, bottom: 16.0),
                decoration: BoxDecoration(
                  color: colorScheme.border.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Text(widget.title, style: AppTextStyles.pageTitle(theme)),
                    const SizedBox(height: 6),
                    Text(
                      widget.subtitle,
                      style: theme.typography.body.sm.copyWith(
                        color: colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Minimal Underline Amount Input Area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(symbol, style: AppTextStyles.actionText(theme)),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: widget.textFieldWidth,
                      child: TextField(
                        controller: _controller,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: false,
                        ),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.statValue(theme),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.only(bottom: 4),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: colorScheme.border,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.colors.primary,
                              width: 2.0,
                            ),
                          ),
                        ),
                        onChanged: _onTextChanged,
                      ),
                    ),
                    if (widget.unitLabel != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        widget.unitLabel!,
                        style: AppTextStyles.listTitle(theme),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Slider Area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Slider(
                      value: sliderValue,
                      min: 0.0,
                      max: widget.maxSliderLimit,
                      activeColor: theme.colors.primary,
                      onChanged: settingsState.isLoading
                          ? null
                          : _onSliderChanged,
                    ),

                    const SizedBox(height: 28),

                    // Button area
                    Row(
                      children: [
                        Expanded(
                          child: FButton(
                            variant: .outline,
                            onPress: () => Navigator.of(context).pop(),
                            child: Text(t.common.cancel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FButton(
                            onPress: settingsState.isLoading
                                ? null
                                : _handleSave,
                            child: settingsState.isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(t.common.save),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    final success = await widget.onSave(_currentValue);
    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.financial.saveFailed)));
      }
      return;
    }
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(widget.successMessage)));
    }
  }
}

class _SafetyThresholdBottomSheet extends ConsumerWidget {
  const _SafetyThresholdBottomSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _AmountSliderBottomSheet(
      title: t.financial.safetyThresholdSettings,
      subtitle: t.financial.setSafetyThreshold,
      successMessage: t.financial.safetyThresholdSaved,
      fallbackValue: 1000.0,
      maxSliderLimit: 50000.0,
      initialValueOf: (s) => s.safetyThreshold != null
          ? s.effectiveSafetyThreshold.toDouble()
          : null,
      onSave: (value) async {
        final notifier = ref.read(financialSettingsProvider.notifier);
        notifier.updateSafetyThreshold(Decimal.parse(value.toStringAsFixed(0)));
        try {
          return await notifier.saveFinancialSettings();
        } catch (e) {
          _logger.warning('Failed to save safety threshold', e);
          return false;
        }
      },
    );
  }
}

class _DailySpendingBottomSheet extends ConsumerWidget {
  const _DailySpendingBottomSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _AmountSliderBottomSheet(
      title: t.financial.dailyBurnRateSettings,
      subtitle: t.financial.setDailyBurnRate,
      successMessage: t.financial.dailyBurnRateSaved,
      fallbackValue: 100.0,
      maxSliderLimit: 2000.0,
      textFieldWidth: 130,
      unitLabel: t.financial.dayUnit,
      initialValueOf: (s) =>
          s.dailyBurnRate != null ? s.effectiveDailyBurnRate.toDouble() : null,
      onSave: (value) async {
        final notifier = ref.read(financialSettingsProvider.notifier);
        notifier.updateDailyBurnRate(Decimal.parse(value.toStringAsFixed(0)));
        try {
          return await notifier.saveFinancialSettings();
        } catch (e) {
          _logger.warning('Failed to save daily burn rate', e);
          return false;
        }
      },
    );
  }
}
