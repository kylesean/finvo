import 'package:collection/collection.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:finvo/core/widgets/top_toast.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../models/recurring_transaction.dart';
import '../providers/recurring_transaction_provider.dart';
import '../services/recurring_transaction_service.dart';
import '../widgets/recurrence_rule_sheet.dart';
import '../widgets/account_selection_sheet.dart';
import '../widgets/category_selection_sheet.dart';
import '../widgets/date_picker_sheet.dart';
import 'package:finvo/core/constants/category_constants.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/models/currency.dart';
import '../../profile/providers/financial_account_provider.dart';
import '../../profile/providers/financial_settings_provider.dart';
import '../../../shared/widgets/app_filter_chip.dart';
import '../../../shared/theme/form_text_styles.dart';

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

  bool get isZh => LocaleSettings.currentLocale == AppLocale.zh;

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

  // Is loading edit data
  // ignore: unused_field - used for future loading indicator
  bool _isLoadingEdit = false;

  // Original data in edit mode
  // ignore: unused_field - stores original for comparison/reset
  RecurringTransaction? _editingTransaction;

  @override
  void initState() {
    super.initState();
    _recurrenceDescription = t.budget.periodMonthly;
    if (widget.editId != null) {
      unawaited(_loadEditData());
    }
  }

  Future<void> _loadEditData() async {
    setState(() => _isLoadingEdit = true);
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

      // Parse the end date (UNTIL) from RRULE
      // Format may be UNTIL=20261231 or UNTIL=20261231T000000Z
      DateTime? endDateFromRule;
      final untilMatch = RegExp(
        r'UNTIL=(\d{4})(\d{2})(\d{2})',
      ).firstMatch(transaction.recurrenceRule);
      if (untilMatch != null) {
        final year = int.parse(untilMatch.group(1)!);
        final month = int.parse(untilMatch.group(2)!);
        final day = int.parse(untilMatch.group(3)!);
        endDateFromRule = DateTime(year, month, day);
      }

      if (mounted) {
        setState(() {
          _editingTransaction = transaction;
          _selectedType = transaction.type;
          _amountType = transaction.amountType;
          _amountController.text = transaction.amount.toString();
          _recurrenceRule = transaction.recurrenceRule;
          _recurrenceDescription = _parseRecurrenceDescription(
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
          _isLoadingEdit = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingEdit = false);
        TopToast.error(context, '${t.common.loadFailed}: $e');
      }
    }
  }

  String _parseRecurrenceDescription(String rule) {
    final isZh = LocaleSettings.currentLocale == AppLocale.zh;

    if (rule.contains('FREQ=DAILY')) {
      final intervalMatch = RegExp(r'INTERVAL=(\d+)').firstMatch(rule);
      final interval = intervalMatch != null
          ? int.tryParse(intervalMatch.group(1)!) ?? 1
          : 1;
      if (isZh) {
        return interval == 1 ? '每天' : '每 $interval 天';
      } else {
        return interval == 1 ? 'Daily' : 'Every $interval days';
      }
    } else if (rule.contains('FREQ=WEEKLY')) {
      final intervalMatch = RegExp(r'INTERVAL=(\d+)').firstMatch(rule);
      final interval = intervalMatch != null
          ? int.tryParse(intervalMatch.group(1)!) ?? 1
          : 1;
      if (isZh) {
        return interval == 1 ? '每周' : '每 $interval 周';
      } else {
        return interval == 1 ? 'Weekly' : 'Every $interval weeks';
      }
    } else if (rule.contains('FREQ=MONTHLY')) {
      final intervalMatch = RegExp(r'INTERVAL=(\d+)').firstMatch(rule);
      final interval = intervalMatch != null
          ? int.tryParse(intervalMatch.group(1)!) ?? 1
          : 1;
      final dayMatch = RegExp(r'BYMONTHDAY=(\d+)').firstMatch(rule);
      final day = dayMatch != null ? dayMatch.group(1) : '';
      if (isZh) {
        if (interval == 1) {
          return day!.isNotEmpty ? '每月 $day 号' : '每月';
        } else {
          return day!.isNotEmpty ? '每 $interval 个月的 $day 号' : '每 $interval 个月';
        }
      } else {
        final daySuffix = _getDaySuffix(day ?? '1');
        if (interval == 1) {
          return day != null ? 'Monthly on the $day$daySuffix' : 'Monthly';
        } else {
          return day != null
              ? 'Every $interval months on the $day$daySuffix'
              : 'Every $interval months';
        }
      }
    } else if (rule.contains('FREQ=YEARLY')) {
      return isZh ? '每年' : 'Yearly';
    }
    return isZh ? '自定义' : 'Custom';
  }

  String _getDaySuffix(String dayStr) {
    final day = int.tryParse(dayStr) ?? 0;
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  String _getTypeLabel(RecurringTransactionType type) {
    switch (type) {
      case RecurringTransactionType.expense:
        return t.forecast.recurringTransaction.expense;
      case RecurringTransactionType.income:
        return t.forecast.recurringTransaction.income;
      case RecurringTransactionType.transfer:
        return t.forecast.recurringTransaction.transfer;
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
                    // Top three-button toggle (expense/income/transfer)
                    _buildTypeSelector(theme, colors),
                    const SizedBox(height: 24),

                    // Amount input area
                    _buildAmountSection(theme, colors),
                    const SizedBox(height: 24),

                    // Period settings card
                    _buildPeriodSettingsCard(theme, colors),
                    const SizedBox(height: 16),

                    // Account, category and tags card
                    _buildAccountCategoryTagsCard(theme, colors),
                    const SizedBox(height: 16),

                    // Advanced options
                    _buildAdvancedOptions(theme, colors),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Bottom save button
            _buildBottomBar(theme, colors),
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
            : (isZh ? '新建周期交易' : 'New Recurring Transaction'),
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

  Widget _buildTypeSelector(FThemeData theme, FColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: RecurringTransactionType.values.map((type) {
          final isSelected = _selectedType == type;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: AppFilterChip(
                label: _getTypeLabel(type),
                isSelected: isSelected,
                onTap: () => _changeTransactionType(type),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ignore: unused_element - reserved for future use
  IconData _getTypeIcon(RecurringTransactionType type) {
    switch (type) {
      case RecurringTransactionType.expense:
        return FLucideIcons.trendingDown;
      case RecurringTransactionType.income:
        return FLucideIcons.trendingUp;
      case RecurringTransactionType.transfer:
        return FLucideIcons.arrowLeftRight;
    }
  }

  // ignore: unused_element - reserved for future use
  Color _getTypeColor(RecurringTransactionType type, FColors colors) {
    switch (type) {
      case RecurringTransactionType.expense:
        return colors.destructive;
      case RecurringTransactionType.income:
        return Colors.green;
      case RecurringTransactionType.transfer:
        return colors.primary;
    }
  }

  /// Amount input area
  Widget _buildAmountSection(FThemeData theme, FColors colors) {
    final amountFontSize = theme.typography.body.xl2.fontSize ?? 24.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Amount input row
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.border, width: 1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Currency symbol - follows global settings
              Text(
                Currency.fromCode(
                      ref.watch(financialSettingsProvider).primaryCurrency,
                    )?.symbol ??
                    '¥',
                style: AppTextStyles.statLabel(
                  theme,
                ).copyWith(fontSize: amountFontSize),
              ),
              const SizedBox(width: 8),
              // Amount input field
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: amountFontSize,
                    color: colors.foreground,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                  cursorColor: colors.primary,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    isCollapsed: true,
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      fontSize: amountFontSize,
                      color: colors.mutedForeground,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Amount not fixed switch
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isZh
                  ? '每次${_getTypeLabel(_selectedType)}金额不固定'
                  : 'Amount not fixed for each ${_getTypeLabel(_selectedType).toLowerCase()}',
              style: AppTextStyles.listTrailing(theme),
            ),
            FSwitch(
              value: _amountType == AmountType.estimate,
              onChange: (value) {
                setState(() {
                  _amountType = value ? AmountType.estimate : AmountType.fixed;
                });
              },
            ),
          ],
        ),

        // Amount not fixed alert
        if (_amountType == AmountType.estimate) ...[
          const SizedBox(height: 16),
          FAlert(
            icon: const Icon(FLucideIcons.info, size: 20),
            title: Text(t.forecast.recurringTransaction.dynamicAmountTitle),
            subtitle: Text(
              t.forecast.recurringTransaction.dynamicAmountDescription,
            ),
            variant: .destructive,
          ),
        ],
      ],
    );
  }

  /// Period settings card
  Widget _buildPeriodSettingsCard(FThemeData theme, FColors colors) {
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
            color: colors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              // Start date (above repeat rule)
              _buildSettingsRow(
                theme,
                colors,
                icon: FLucideIcons.calendar,
                title: t.dateRange.startDate,
                subtitle:
                    '${_startDate.year}/${_startDate.month}/${_startDate.day}',
                onTap: _showDatePicker,
                trailing: Icon(
                  FLucideIcons.calendar,
                  size: 20,
                  color: colors.mutedForeground,
                ),
              ),
              Divider(height: 1, color: colors.border),
              // Repeat rule
              _buildSettingsRow(
                theme,
                colors,
                icon: FLucideIcons.repeat,
                title: t.budget.period,
                subtitle: _recurrenceDescription,
                onTap: _showRecurrenceRuleSheet,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Account, category and tag card
  Widget _buildAccountCategoryTagsCard(FThemeData theme, FColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${t.transaction.account} & ${t.transaction.category}',
          style: AppTextStyles.sectionHeader(theme),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              // Account selection (different content based on type)
              if (_selectedType == RecurringTransactionType.transfer) ...[
                _buildSettingsRow(
                  theme,
                  colors,
                  icon: FLucideIcons.wallet,
                  title: isZh ? '转出账户' : 'Source Account',
                  subtitle: _sourceAccountName ?? t.common.all,
                  onTap: () => _showAccountSelector(isSource: true),
                ),
                Divider(height: 1, color: colors.border),
                _buildSettingsRow(
                  theme,
                  colors,
                  icon: FLucideIcons.landmark,
                  title: isZh ? '转入账户' : 'Target Account',
                  subtitle: _targetAccountName ?? t.common.all,
                  onTap: () => _showAccountSelector(isSource: false),
                ),
              ] else ...[
                _buildSettingsRow(
                  theme,
                  colors,
                  icon: FLucideIcons.wallet,
                  title: _selectedType == RecurringTransactionType.expense
                      ? (isZh ? '支出账户' : 'Expense Account')
                      : (isZh ? '收入账户' : 'Income Account'),
                  subtitle: _sourceAccountName ?? t.common.all,
                  onTap: () => _showAccountSelector(isSource: true),
                ),
              ],
              Divider(height: 1, color: colors.border),
              // Category selection
              _buildSettingsRow(
                theme,
                colors,
                icon: FLucideIcons.layers,
                title: t.transaction.category,
                subtitle: _category.displayText,
                onTap: _showCategoryPicker,
              ),
              Divider(height: 1, color: colors.border),
              // Tag area
              _buildTagsRow(theme, colors),
            ],
          ),
        ),
      ],
    );
  }

  /// Tag row - icon + input + add button (refer to image design)
  Widget _buildTagsRow(FThemeData theme, FColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Added tags list (removable)
          if (_tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags.map((tag) {
                return _buildRemovableTag(theme, colors, tag);
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
          // Input row: icon + input + add button
          Row(
            children: [
              Icon(FLucideIcons.tag, size: 20, color: colors.mutedForeground),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _tagController,
                  decoration: InputDecoration(
                    hintText: t.transaction.tags,
                    hintStyle: AppTextStyles.listSubtitle(theme),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: AppTextStyles.listTrailing(theme),
                  onChanged: (_) => setState(
                    () {},
                  ), // Trigger rebuild to show/hide add button
                  onSubmitted: (value) {
                    _addTag(value);
                  },
                ),
              ),
              // Add button (only shows when there is input content)
              if (_tagController.text.trim().isNotEmpty)
                GestureDetector(
                  onTap: () => _addTag(_tagController.text),
                  child: Text(
                    t.common.add,
                    style: AppTextStyles.actionText(theme),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Removable tag
  Widget _buildRemovableTag(FThemeData theme, FColors colors, String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.muted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: theme.typography.body.sm.copyWith(color: colors.foreground),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _removeTag(tag),
            child: Icon(
              FLucideIcons.x,
              size: 14,
              color: colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  /// Generic settings row
  Widget _buildSettingsRow(
    FThemeData theme,
    FColors colors, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: colors.mutedForeground),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.detailLabel(theme)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.switchTitle(theme)),
                ],
              ),
            ),
            trailing ??
                Icon(
                  FLucideIcons.chevronRight,
                  size: 20,
                  color: colors.mutedForeground,
                ),
          ],
        ),
      ),
    );
  }

  /// Tag input area - removable tags + add button
  // ignore: unused_element - alternate implementation of tags section
  Widget _buildTagsSection(FThemeData theme, FColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // Added tags list
        if (_tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.muted,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(tag, style: AppTextStyles.listTrailing(theme)),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _removeTag(tag),
                        child: Icon(
                          FLucideIcons.x,
                          size: 14,
                          color: colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        // Tag input row - tag icon + input + add button
        Row(
          children: [
            Icon(FLucideIcons.tag, size: 20, color: colors.mutedForeground),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: InputDecoration(
                  hintText: t.transaction.tags,
                  hintStyle: AppTextStyles.listSubtitle(theme),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: AppTextStyles.listTrailing(theme),
                onSubmitted: _addTag,
              ),
            ),
            GestureDetector(
              onTap: () => _addTag(_tagController.text),
              child: Text(t.common.add, style: AppTextStyles.actionText(theme)),
            ),
          ],
        ),
      ],
    );
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

  /// Advanced options - confirmation required before generation + activation switch
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
            color: colors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              // Confirm before generation toggle
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t
                                .forecast
                                .recurringTransaction
                                .confirmBeforeGeneration,
                            style: AppTextStyles.switchTitle(theme),
                          ),
                          Text(
                            t
                                .forecast
                                .recurringTransaction
                                .confirmBeforeGenerationDesc,
                            style: AppTextStyles.detailLabel(theme),
                          ),
                        ],
                      ),
                    ),
                    FSwitch(
                      value: _requiresConfirmation,
                      onChange: (value) {
                        setState(() => _requiresConfirmation = value);
                      },
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: colors.border),
              // Activation toggle
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.budget.enabled,
                            style: AppTextStyles.switchTitle(theme),
                          ),
                          Text(
                            isZh
                                ? '开启后按规则自动生成交易'
                                : 'Automatically generate transactions by rule',
                            style: AppTextStyles.detailLabel(theme),
                          ),
                        ],
                      ),
                    ),
                    FSwitch(
                      value: _isActive,
                      onChange: (value) => setState(() => _isActive = value),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Bottom save button bar
  Widget _buildBottomBar(FThemeData theme, FColors colors) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: FButton(
        onPress: _isSaving ? null : _handleSave,
        variant: .primary,
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(t.common.save),
      ),
    );
  }

  Future<void> _showRecurrenceRuleSheet() async {
    final result = await RecurrenceRuleSheet.show(
      context,
      initialStartDate: _startDate,
      initialRule: _recurrenceRule,
    );

    if (result != null) {
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
      setState(() {
        _startDate = picked;
        // Update the date part of the recurrence rule
        _updateRecurrenceRuleWithNewDate(picked);
      });
    }
  }

  /// Update the recurrence rule with the new start date
  void _updateRecurrenceRuleWithNewDate(DateTime newDate) {
    // If it's a monthly rule, update BYMONTHDAY (preserve -1 for last day of month)
    if (_recurrenceRule.contains('FREQ=MONTHLY')) {
      if (_recurrenceRule.contains('BYMONTHDAY=-1')) {
        _recurrenceDescription = isZh ? '每月最后一天' : 'Monthly on the last day';
      } else {
        _recurrenceRule = _recurrenceRule.replaceAllMapped(
          RegExp(r'BYMONTHDAY=-?\d+'),
          (match) => 'BYMONTHDAY=${newDate.day}',
        );
        // If there is no BYMONTHDAY, add it
        if (!_recurrenceRule.contains('BYMONTHDAY')) {
          _recurrenceRule += ';BYMONTHDAY=${newDate.day}';
        }
        _recurrenceDescription = isZh
            ? '每月 ${newDate.day} 号'
            : 'Monthly on the ${newDate.day}${_getDaySuffix(newDate.day.toString())}';
      }
    } else if (_recurrenceRule.contains('FREQ=WEEKLY')) {
      // If it's a weekly rule, update BYDAY
      final weekdays = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
      final weekdayLabels = isZh
          ? ['一', '二', '三', '四', '五', '六', '日']
          : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final weekdayIndex = newDate.weekday - 1;
      _recurrenceRule = _recurrenceRule.replaceAllMapped(
        RegExp(r'BYDAY=[A-Z,]+'),
        (match) => 'BYDAY=${weekdays[weekdayIndex]}',
      );
      if (!_recurrenceRule.contains('BYDAY')) {
        _recurrenceRule += ';BYDAY=${weekdays[weekdayIndex]}';
      }
      _recurrenceDescription = isZh
          ? '每周${weekdayLabels[weekdayIndex]}'
          : 'Weekly on ${weekdayLabels[weekdayIndex]}';
    }
  }

  Future<void> _showAccountSelector({required bool isSource}) async {
    final title = _selectedType == RecurringTransactionType.transfer
        ? (isSource
              ? (isZh ? '选择转出账户' : 'Source')
              : (isZh ? '选择转入账户' : 'Target'))
        : (_selectedType == RecurringTransactionType.expense
              ? (isZh ? '选择支出账户' : 'Expense')
              : (isZh ? '选择收入账户' : 'Income'));

    final result = await AccountSelectionSheet.show(
      context,
      title: title,
      selectedAccountId: isSource ? _sourceAccountId : _targetAccountId,
    );

    if (result != null) {
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
          isZh ? '请选择转出和转入账户' : 'Please select source and target accounts',
        );
        return;
      }
    } else {
      if (_sourceAccountId == null) {
        TopToast.warning(
          context,
          isZh
              ? '请选择${_getTypeLabel(_selectedType)}账户'
              : 'Please select ${_getTypeLabel(_selectedType).toLowerCase()} account',
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      bool success;

      if (widget.editId != null) {
        // Edit mode - call update
        final updateRequest = RecurringTransactionUpdateRequest(
          type: _selectedType,
          amount: amount,
          recurrenceRule: _recurrenceRule,
          startDate: _startDate,
          sourceAccountId: _sourceAccountId,
          targetAccountId: _targetAccountId,
          amountType: _amountType,
          requiresConfirmation: _requiresConfirmation,
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

  // ignore: unused_element - delete functionality to be activated from UI
  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.forecast.recurringTransaction.confirmDelete),
        content: Text(
          isZh
              ? '确定要删除这个周期交易吗？此操作不可撤销。'
              : 'Are you sure you want to delete this recurring transaction? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.common.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              t.common.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.editId != null) {
      setState(() => _isSaving = true);
      try {
        final success = await ref
            .read(recurringTransactionProvider.notifier)
            .delete(widget.editId!);
        if (mounted) {
          if (success) {
            TopToast.success(context, t.transaction.deleted);
            context.pop();
          } else {
            TopToast.error(context, t.transaction.deleteFailed);
          }
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }
}
