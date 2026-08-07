import 'package:decimal/decimal.dart';
import 'package:finvo/shared/widgets/amount_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:finvo/shared/widgets/top_toast.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import 'package:finvo/core/constants/category_constants.dart';
import 'package:finvo/features/finance/widgets/category_selection_sheet.dart';
import 'package:finvo/features/finance/models/recurring_transaction.dart';
import 'package:finvo/features/budget/models/budget_models.dart';
import 'package:finvo/features/budget/providers/budget_provider.dart';
import 'package:finvo/features/budget/services/budget_service.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/widgets/app_filter_chip.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/features/budget/widgets/budget_period_type_picker.dart';
import 'package:finvo/features/budget/widgets/budget_anchor_day_picker.dart';

class BudgetFormPage extends ConsumerStatefulWidget {
  final String? editId;

  const BudgetFormPage({super.key, this.editId});

  @override
  ConsumerState<BudgetFormPage> createState() => _BudgetFormPageState();
}

class _BudgetFormPageState extends ConsumerState<BudgetFormPage> {
  BudgetScope _scope = BudgetScope.total;

  final _amountController = TextEditingController(text: '');

  BudgetPeriodType _periodType = BudgetPeriodType.monthly;

  int _periodAnchorDay = 1;

  bool _rolloverEnabled = true;

  TransactionCategory _category = TransactionCategory.expenseCategories.first;

  final _nameController = TextEditingController();

  bool _isSaving = false;

  bool _isLoadingEdit = false;

  late FPickerController _periodPickerController;
  late FPickerController _anchorDayPickerController;

  @override
  void initState() {
    super.initState();
    _periodPickerController = FPickerController(indexes: [2]);
    _anchorDayPickerController = FPickerController(indexes: [0]);

    if (widget.editId != null) {
      unawaited(_loadEditData());
    }
  }

  Future<void> _loadEditData() async {
    setState(() => _isLoadingEdit = true);
    try {
      final service = ref.read(budgetServiceProvider);
      final budget = await service.getById(widget.editId!);

      if (mounted) {
        setState(() {
          // Destructure budget into form fields
          _scope = budget.scope;
          _amountController.text = budget.amount.toString();
          _periodType = budget.periodType;
          // Keep the existing anchor day: dropping it here silently reset every
          // edited budget's cycle start back to day 1 on the next save.
          _periodAnchorDay = budget.periodAnchorDay;
          _rolloverEnabled = budget.rolloverEnabled;
          // Use the raw server name, not the localised displayName: displayName
          // resolves category/total budgets to a *localised* label which would
          // overwrite the server's original name on save and stop the name from
          // following locale changes.
          _nameController.text = budget.name;

          if (budget.categoryKey != null) {
            _category = TransactionCategory.fromKey(budget.categoryKey!);
          }
          final periodIndex = BudgetPeriodType.values.indexOf(_periodType);
          _periodPickerController.dispose();
          _periodPickerController = FPickerController(
            indexes: [periodIndex >= 0 ? periodIndex : 2],
          );
          _anchorDayPickerController.dispose();
          _anchorDayPickerController = FPickerController(
            indexes: [(_periodAnchorDay - 1).clamp(0, 30)],
          );

          _isLoadingEdit = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingEdit = false);
        TopToast.error(context, '${t.budget.loadFailed}: $e');
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _periodPickerController.dispose();
    _anchorDayPickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    if (_isLoadingEdit) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: _buildAppBar(theme, colors),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(theme, colors),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildScopeSelector(theme, colors),
              const SizedBox(height: 24),

              _buildAmountSection(theme, colors),
              const SizedBox(height: 24),

              if (_scope == BudgetScope.category) ...[
                _buildCategorySection(theme, colors),
                const SizedBox(height: 24),
              ],
              _buildPeriodSection(theme, colors),
              const SizedBox(height: 24),
              _buildAdvancedOptions(theme, colors),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(theme, colors),
    );
  }

  PreferredSizeWidget _buildAppBar(FThemeData theme, FColors colors) {
    return AppBar(
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
        widget.editId != null ? t.budget.editBudget : t.budget.newBudget,
        style: AppTextStyles.pageTitle(theme),
      ),
      centerTitle: true,
    );
  }

  Widget _buildScopeSelector(FThemeData theme, FColors colors) {
    if (widget.editId != null) {
      return Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: colors.muted,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              _scope == BudgetScope.total
                  ? FLucideIcons.wallet
                  : FLucideIcons.layers,
              color: colors.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              _scope == BudgetScope.total
                  ? t.budget.totalBudget
                  : t.budget.categoryBudget,
              style: AppTextStyles.listTitle(theme),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: AppFilterChip(
                label: t.budget.totalBudget,
                isSelected: _scope == BudgetScope.total,
                onTap: () => setState(() => _scope = BudgetScope.total),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: AppFilterChip(
                label: t.budget.categoryBudget,
                isSelected: _scope == BudgetScope.category,
                onTap: () => setState(() => _scope = BudgetScope.category),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection(FThemeData theme, FColors colors) {
    final amountFontSize = theme.typography.body.xl2.fontSize ?? 24.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.budget.budgetAmountLabel,
          style: AppTextStyles.sectionHeader(theme),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.border, width: 1)),
          ),
          child: AmountInputField(
            controller: _amountController,
            fontSize: amountFontSize,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(FThemeData theme, FColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.budget.budgetCategory,
          style: AppTextStyles.sectionHeader(theme),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _showCategoryPicker,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _category.themedColor(theme).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _category.icon,
                    color: _category.themedColor(theme),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _category.displayText,
                    style: AppTextStyles.formValue(theme),
                  ),
                ),
                Icon(FLucideIcons.chevronRight, color: colors.mutedForeground),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSection(FThemeData theme, FColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.budget.periodSettings,
          style: AppTextStyles.sectionHeader(theme),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              // Period type
              InkWell(
                onTap: _showPeriodTypePicker,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        FLucideIcons.calendarClock,
                        size: 22,
                        color: colors.mutedForeground,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.budget.periodType,
                              style: AppTextStyles.detailLabel(theme),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _periodType.label,
                              style: AppTextStyles.switchTitle(theme),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        FLucideIcons.chevronRight,
                        size: 20,
                        color: colors.mutedForeground,
                      ),
                    ],
                  ),
                ),
              ),
              if (_periodType == BudgetPeriodType.monthly) ...[
                Divider(height: 1, color: colors.border),
                InkWell(
                  onTap: _showAnchorDayPicker,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          FLucideIcons.calendar,
                          size: 22,
                          color: colors.mutedForeground,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.budget.anchorDay,
                                style: AppTextStyles.detailLabel(theme),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                t.budget.everyMonthDay(
                                  day: _periodAnchorDay.toString(),
                                ),
                                style: AppTextStyles.switchTitle(theme),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          FLucideIcons.chevronRight,
                          size: 20,
                          color: colors.mutedForeground,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedOptions(FThemeData theme, FColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.budget.advancedOptions,
          style: AppTextStyles.sectionHeader(theme),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  FLucideIcons.repeat,
                  size: 22,
                  color: colors.mutedForeground,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.budget.rollover,
                        style: AppTextStyles.switchTitle(theme),
                      ),
                      Text(
                        t.budget.rolloverDescription,
                        style: AppTextStyles.detailLabel(theme),
                      ),
                    ],
                  ),
                ),
                FSwitch(
                  value: _rolloverEnabled,
                  onChange: (value) {
                    setState(() => _rolloverEnabled = value);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(FThemeData theme, FColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        child: FButton(
          onPress: _isSaving ? null : _handleSave,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  widget.editId != null ? t.budget.save : t.budget.createBudget,
                ),
        ),
      ),
    );
  }

  Future<void> _showCategoryPicker() async {
    final result = await CategorySelectionSheet.show(
      context,
      selectedCategory: _category,
      transactionType: RecurringTransactionType
          .expense, // Budget is only for expense categories
    );
    if (result != null && mounted) {
      setState(() => _category = result.category);
    }
  }

  Future<void> _showPeriodTypePicker() async {
    // The period type is immutable after creation: switching it would
    // invalidate all already-aggregated usage history of this budget.
    if (widget.editId != null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BudgetPeriodTypePicker(
        selectedType: _periodType,
        onSelected: (type) {
          setState(() => _periodType = type);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _showAnchorDayPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BudgetAnchorDayPicker(
        selectedDay: _periodAnchorDay,
        onSelected: (day) {
          setState(() => _periodAnchorDay = day);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _handleSave() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      TopToast.error(context, t.budget.pleaseEnterAmount);
      return;
    }

    final amount = Decimal.tryParse(amountText);
    if (amount == null || amount <= Decimal.zero) {
      TopToast.error(context, t.budget.invalidAmount);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final service = ref.read(budgetServiceProvider);

      if (widget.editId != null) {
        // Update budget
        final request = BudgetUpdateRequest(
          name: _nameController.text.isNotEmpty ? _nameController.text : null,
          amount: amount,
          periodAnchorDay: _periodAnchorDay,
          rolloverEnabled: _rolloverEnabled,
          // The scope is immutable during edit, but the category is editable.
          // Passing [categoryKey] (and [scope] for safety) ensures a category
          // change is actually persisted instead of being silently dropped.
          scope: _scope,
          categoryKey: _scope == BudgetScope.category ? _category.key : null,
        );
        await service.update(widget.editId!, request);
        if (mounted) TopToast.success(context, t.budget.updateSuccess);
      } else {
        // Create budget
        final request = BudgetCreateRequest(
          scope: _scope,
          categoryKey: _scope == BudgetScope.category ? _category.key : null,
          amount: amount,
          periodType: _periodType,
          periodAnchorDay: _periodAnchorDay,
          rolloverEnabled: _rolloverEnabled,
          name: _nameController.text.isNotEmpty
              ? _nameController.text
              : (_scope == BudgetScope.category
                    ? _category.displayText
                    : t.budget.totalBudget),
        );
        await service.create(request);
        if (mounted) TopToast.success(context, t.budget.createSuccess);
      }

      // Refresh budget list
      await ref.read(budgetSummaryProvider.notifier).refresh();

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        TopToast.error(context, '${t.budget.operationFailed}: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
