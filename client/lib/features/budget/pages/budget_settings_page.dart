import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../../core/widgets/top_toast.dart';
import '../../../app/theme/app_semantic_colors.dart';
import '../services/budget_service.dart';
import '../models/budget_models.dart';
import 'package:finvo/i18n/strings.g.dart';

class BudgetSettingsPage extends ConsumerStatefulWidget {
  const BudgetSettingsPage({super.key});

  @override
  ConsumerState<BudgetSettingsPage> createState() => _BudgetSettingsPageState();
}

class _BudgetSettingsPageState extends ConsumerState<BudgetSettingsPage> {
  int _warningThreshold = 70;
  int _alertThreshold = 90;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadSettings());
  }

  Future<void> _loadSettings() async {
    try {
      final service = ref.read(budgetServiceProvider);
      final settings = await service.getSettings();
      if (mounted) {
        setState(() {
          _warningThreshold = settings.warningThreshold;
          _alertThreshold = settings.alertThreshold;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        TopToast.error(context, '${t.budget.settingsLoadFailed}: $e');
      }
    }
  }

  Future<void> _saveSettings() async {
    if (_warningThreshold > _alertThreshold) {
      TopToast.error(context, t.budget.settingsThresholdOrder);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final service = ref.read(budgetServiceProvider);
      await service.updateSettings(
        BudgetSettingsUpdateRequest(
          warningThreshold: _warningThreshold,
          alertThreshold: _alertThreshold,
        ),
      );
      if (mounted) {
        TopToast.success(context, t.budget.settingsSaveSuccess);
      }
    } catch (e) {
      if (mounted) {
        TopToast.error(context, '${t.budget.settingsSaveFailed}: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: FButton.icon(
          variant: .ghost,
          onPress: () => context.pop(),
          child: Icon(
            FLucideIcons.chevronLeft,
            color: colors.foreground,
            size: 20,
          ),
        ),
        title: Text(
          t.budget.settings,
          style: theme.typography.body.lg.copyWith(
            fontWeight: FontWeight.w500,
            color: colors.foreground,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildThresholdSlider(
                    theme,
                    colors,
                    label: t.budget.settingsWarningThreshold,
                    description: t.budget.settingsWarningDesc,
                    value: _warningThreshold,
                    color: theme.semantic.warningAccent,
                    onChanged: (v) {
                      if (v <= _alertThreshold) {
                        setState(() => _warningThreshold = v);
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  _buildThresholdSlider(
                    theme,
                    colors,
                    label: t.budget.settingsAlertThreshold,
                    description: t.budget.settingsAlertDesc,
                    value: _alertThreshold,
                    color: colors.destructive,
                    onChanged: (v) {
                      if (v >= _warningThreshold) {
                        setState(() => _alertThreshold = v);
                      }
                    },
                  ),
                  const Spacer(),
                  FButton(
                    onPress: _isSaving ? null : _saveSettings,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(t.budget.settingsSave),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildThresholdSlider(
    FThemeData theme,
    FColors colors, {
    required String label,
    required String description,
    required int value,
    required Color color,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w500,
                color: colors.foreground,
              ),
            ),
            Text(
              '$value%',
              style: theme.typography.body.lg.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: theme.typography.body.xs.copyWith(
            color: colors.mutedForeground,
          ),
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.2),
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.1),
          ),
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: 100,
            divisions: 20,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
      ],
    );
  }
}
