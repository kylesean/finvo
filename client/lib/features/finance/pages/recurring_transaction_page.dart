import 'package:collection/collection.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:finvo/shared/widgets/top_toast.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import 'package:finvo/features/finance/models/recurring_transaction.dart';
import 'package:finvo/features/finance/providers/recurring_transaction_provider.dart';
import 'package:finvo/features/finance/services/recurring_transaction_service.dart';
import 'package:finvo/features/finance/widgets/recurrence_rule_sheet.dart';
import 'package:finvo/features/finance/widgets/recurring_transaction_form_sections.dart';
import 'package:finvo/features/finance/utils/recurrence_rule_utils.dart';
import 'package:finvo/features/finance/widgets/account_selection_sheet.dart';
import 'package:finvo/features/finance/widgets/category_selection_sheet.dart';
import 'package:finvo/features/finance/widgets/date_picker_sheet.dart';
import 'package:finvo/core/constants/category_constants.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/features/profile/providers/financial_account_provider.dart';
import 'package:finvo/features/profile/providers/financial_settings_provider.dart';
import 'package:finvo/shared/services/timezone_service.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// Recurring transaction create/edit page
class RecurringTransactionPage extends ConsumerStatefulWidget {
  final String? editId; // If provided, enters edit mode

  const RecurringTransactionPage({super.key, this.editId});

  @override
  ConsumerState<RecurringTransactionPage> createState() =>
      _RecurringTransactionPageState();
}

class _RecurringTransactionPageState
    extends ConsumerState<RecurringTransactionPage> {
  // Currently selected transaction type
  RecurringTransactionType _selectedType = RecurringTransactionType.expense;

  // Amount type
  AmountType _amountType = AmountType.fixed;

  // Amount input controller
  final _amountController = TextEditingController(text: '0.00');

  // Recurrence rule
  String _recurrenceRule = 'FREQ=MONTHLY;BYMONTHDAY=1';
  late String _recurrenceDescription;

  // Start date
  DateTime _startDate = DateTime.now();

  // End date (optional)
  DateTime? _endDate;

  // Selected accounts
  String? _sourceAccountId;
  String? _targetAccountId;
  String? _sourceAccountName;
  String? _targetAccountName;

  // Category - defaults to first expense category
  TransactionCategory _category = TransactionCategory.expenseCategories.first;

  // Tags
  final List<String> _tags = [];
  final _tagController = TextEditingController();

  // Advanced options
  bool _requiresConfirmation = false;
  bool _isActive = true;

  // Description
  final _descriptionController = TextEditingController();

  // Is saving in progress
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _recurrenceDescription = t.budget.periodMonthly;
    if (widget.editId != null) {
      unawaited(_loadEditData());
    }
  }

  Future<void> _loadEditData() async {
    try {
      final service = ref.read(recurringTransactionServiceProvider);
      final transaction = await service.getById(widget.editId!);

      // Load account names
      final accountState = ref.read(financialAccountProvider);
      String? sourceAccountName;
      String? targetAccountName;
      if (transaction.sourceAccountId != null) {
        final account = accountState.accounts.firstWhereOrNull(
          (a) => a.id == transaction.sourceAccountId,
        );
        sourceAccountName = account?.name;
      }
      if (transaction.targetAccountId != null) {
        final account = accountState.accounts.firstWhereOrNull(
          (a) => a.id == transaction.targetAccountId,
        );
        targetAccountName = account?.name;
      }

      // Parse the end date (UNTIL) from RRULE (handles both the current
      // date-only writer and the legacy UTC-encoded writer).
      final endDateFromRule = parseUntilFromRule(transaction.recurrenceRule);

      if (mounted) {
        setState(() {
          _selectedType = transaction.type;
          _amountType = transaction.amountType;
          _amountController.text = transaction.amount.toString();
          _recurrenceRule = transaction.recurrenceRule;
          _recurrenceDescription = describeRecurrenceRule(
            transaction.recurrenceRule,
          );
          _startDate = transaction.startDate;
          _endDate = transaction.endDate ?? endDateFromRule;
          _sourceAccountId = transaction.sourceAccountId;
          _targetAccountId = transaction.targetAccountId;
          _sourceAccountName = sourceAccountName;
          _targetAccountName = targetAccountName;
          _requiresConfirmation = transaction.requiresConfirmation;
          _isActive = transaction.isActive;
          if (transaction.categoryKey != null) {
            _category = TransactionCategory.fromKey(transaction.categoryKey!);
          }
          if (transaction.tags != null) {
            _tags.clear();
            _tags.addAll(transaction.tags!);
          }
          if (transaction.description != null) {
            _descriptionController.text = transaction.description!;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        TopToast.error(context, '${t.common.loadFailed}: $e');
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _tagController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(theme, colors),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RecurringTypeSelector(
                      selectedType: _selectedType,
                      onChanged: _changeTransactionType,
                    ),
                    const SizedBox(height: 24),

                    RecurringAmountSection(
                      amountController: _amountController,
                      amountType: _amountType,
                      typeName: recurringTransactionTypeLabel(_selectedType),
                      onAmountTypeChanged: (value) {
                        setState(() {
                          _amountType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    RecurringPeriodCard(
                      startDate: _startDate,
                      recurrenceDescription: _recurrenceDescription,
                      onStartDateTap: _showDatePicker,
                      onRepeatTap: _showRecurrenceRuleSheet,
                    ),
                    const SizedBox(height: 16),

                    RecurringAccountCategoryCard(
                      selectedType: _selectedType,
                      sourceAccountName: _sourceAccountName,
                      targetAccountName: _targetAccountName,
                      categoryText: _category.displayText,
                      tags: _tags,
                      tagController: _tagController,
                      onAddTag: _addTag,
                      onRemoveTag: _removeTag,
                      onSourceTap: () => _showAccountSelector(isSource: true),
                      onTargetTap: () => _showAccountSelector(isSource: false),
                      onCategoryTap: _showCategoryPicker,
                      onTagChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: 16),

                    RecurringAdvancedOptions(
                      requiresConfirmation: _requiresConfirmation,
                      isActive: _isActive,
                      onConfirmationChanged: (value) {
                        setState(() => _requiresConfirmation = value);
                      },
                      onActiveChanged: (value) {
                        setState(() => _isActive = value);
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            RecurringBottomBar(isSaving: _isSaving, onSave: _handleSave),
          ],
        ),
      ),
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
        widget.editId != null
            ? t.forecast.recurringTransaction.edit
            : t.forecast.recurringTransaction.newTransaction,
        style: AppTextStyles.pageTitle(theme),
      ),
      centerTitle: true,
    );
  }

  /// Switch transaction type and reset category to the default for that type
  void _changeTransactionType(RecurringTransactionType newType) {
    if (_selectedType == newType) return;

    setState(() {
      _selectedType = newType;
      // Reset category to the default for the selected type
      switch (newType) {
        case RecurringTransactionType.expense:
          _category = TransactionCategory.expenseCategories.first;
          break;
        case RecurringTransactionType.income:
          _category = TransactionCategory.incomeCategories.first;
          break;
        case RecurringTransactionType.transfer:
          _category = TransactionCategory.transferCategories.first;
          break;
      }
    });
  }

  void _addTag(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isNotEmpty && !_tags.contains(trimmed)) {
      setState(() {
        _tags.add(trimmed);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _showRecurrenceRuleSheet() async {
    final result = await RecurrenceRuleSheet.show(
      context,
      initialStartDate: _startDate,
      initialRule: _recurrenceRule,
    );

    if (result != null) {
      if (!mounted) return;
      setState(() {
        _recurrenceRule = result.rule;
        _recurrenceDescription = result.description;
        _startDate = result.startDate;
        _endDate = result.endDate;
      });
    }
  }

  Future<void> _showDatePicker() async {
    final picked = await DatePickerSheet.show(
      context,
      initialDate: _startDate,
      // Allow selecting past dates (for retroactive records)
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      title: t.dateRange.startDate,
    );
    if (picked != null) {
      if (!mounted) return;
      setState(() {
        _startDate = picked;
        // Update the date part of the recurrence rule (M-8: delegates to the
        // single shared updateRuleAndDescribe).
        final result = updateRuleAndDescribe(_recurrenceRule, picked);
        _recurrenceRule = result.rule;
        _recurrenceDescription = result.description;
      });
    }
  }

  Future<void> _showAccountSelector({required bool isSource}) async {
    final rt = t.forecast.recurringTransaction;
    final title = _selectedType == RecurringTransactionType.transfer
        ? (isSource ? rt.selectSourceAccount : rt.selectTargetAccount)
        : (_selectedType == RecurringTransactionType.expense
              ? rt.selectExpenseAccount
              : rt.selectIncomeAccount);

    final result = await AccountSelectionSheet.show(
      context,
      title: title,
      selectedAccountId: isSource ? _sourceAccountId : _targetAccountId,
    );

    if (result != null) {
      if (!mounted) return;
      setState(() {
        if (isSource) {
          _sourceAccountId = result.accountId;
          _sourceAccountName = result.accountName;
        } else {
          _targetAccountId = result.accountId;
          _targetAccountName = result.accountName;
        }
      });
    }
  }

  Future<void> _showCategoryPicker() async {
    final result = await CategorySelectionSheet.show(
      context,
      selectedCategory: _category,
      transactionType:
          _selectedType, // Filter categories based on transaction type
    );

    if (result != null) {
      if (!mounted) return;
      setState(() {
        _category = result.category;
      });
    }
  }

  Future<void> _handleSave() async {
    // Validate required fields
    final amount = Decimal.tryParse(_amountController.text);
    if (amount == null || amount <= Decimal.zero) {
      TopToast.warning(context, t.transaction.pleaseEnterAmount);
      return;
    }

    // Validate account selection
    if (_selectedType == RecurringTransactionType.transfer) {
      if (_sourceAccountId == null || _targetAccountId == null) {
        TopToast.warning(
          context,
          t.forecast.recurringTransaction.selectBothAccounts,
        );
        return;
      }
      // A transfer between the same account is meaningless; the backend would
      // reject it, so surface a clear message instead of a confusing error.
      if (_sourceAccountId == _targetAccountId) {
        TopToast.warning(context, t.forecast.recurringTransaction.sameAccount);
        return;
      }
    } else {
      if (_sourceAccountId == null) {
        TopToast.warning(
          context,
          t.forecast.recurringTransaction.selectAccountForType(
            type: recurringTransactionTypeLabel(_selectedType),
          ),
        );
        return;
      }
    }

    // Validate the optional end date is not before the start date.
    if (_endDate != null && _endDate!.isBefore(_startDate)) {
      TopToast.warning(context, t.forecast.recurringTransaction.endBeforeStart);
      return;
    }

    setState(() => _isSaving = true);

    try {
      bool success;

      // Resolve the user's real currency/timezone instead of the model
      // defaults (which were previously hardcoded to CNY/Asia-Shanghai and
      // silently persisted for every recurring transaction).
      // FinancialSettingsState.primaryCurrency defaults to 'CNY' while
      // settings are still loading, so this is safe on first frame.
      final currency = ref.read(financialSettingsProvider).primaryCurrency;
      final timezone = await ref
          .read(timezoneServiceProvider)
          .getCurrentTimezone();

      if (widget.editId != null) {
        // Edit mode - call update. Fields the user cleared in the form must
        // be sent as explicit nulls (tracked via clearedFields), otherwise
        // the backend's exclude_unset handling would silently keep the old
        // values and the user's clearing would have no effect.
        final cleared = <UpdateClearableField>{};
        if (_endDate == null) cleared.add(UpdateClearableField.endDate);
        if (_tags.isEmpty) cleared.add(UpdateClearableField.tags);
        if (_descriptionController.text.isEmpty) {
          cleared.add(UpdateClearableField.description);
        }
        if (_targetAccountId == null) {
          cleared.add(UpdateClearableField.targetAccountId);
        }

        final updateRequest = RecurringTransactionUpdateRequest(
          type: _selectedType,
          amount: amount,
          recurrenceRule: _recurrenceRule,
          startDate: _startDate,
          sourceAccountId: _sourceAccountId,
          targetAccountId: _targetAccountId,
          amountType: _amountType,
          requiresConfirmation: _requiresConfirmation,
          currency: currency,
          timezone: timezone,
          categoryKey: _category.key,
          tags: _tags.isEmpty ? null : _tags,
          endDate: _endDate,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          isActive: _isActive,
          clearedFields: cleared,
        );
        success = await ref
            .read(recurringTransactionProvider.notifier)
            .update(widget.editId!, updateRequest.toJson());
      } else {
        // New mode - call create
        final request = RecurringTransactionCreateRequest(
          type: _selectedType,
          amount: amount,
          recurrenceRule: _recurrenceRule,
          startDate: _startDate,
          sourceAccountId: _sourceAccountId,
          targetAccountId: _targetAccountId,
          amountType: _amountType,
          requiresConfirmation: _requiresConfirmation,
          currency: currency,
          timezone: timezone,
          categoryKey: _category.key,
          tags: _tags.isEmpty ? null : _tags,
          endDate: _endDate,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          isActive: _isActive,
        );
        success = await ref
            .read(recurringTransactionProvider.notifier)
            .create(request);
      }

      if (mounted) {
        if (success) {
          TopToast.success(
            context,
            widget.editId != null
                ? t.forecast.recurringTransaction.updated
                : t.forecast.recurringTransaction.created,
          );
          context.pop();
        } else {
          TopToast.error(context, t.transaction.saveFailed);
        }
      }
    } catch (e) {
      if (mounted) {
        TopToast.error(context, '${t.transaction.saveFailed}: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
