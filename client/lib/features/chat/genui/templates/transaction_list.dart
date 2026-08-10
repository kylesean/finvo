import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finvo/shared/widgets/amount_text.dart';
import 'package:finvo/shared/utils/amount_formatter.dart';
import 'package:finvo/shared/widgets/themed_icon.dart';
import 'package:finvo/features/home/services/home_service.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/core/constants/category_constants.dart';
import 'package:finvo/features/home/models/transaction_model.dart';
import 'dart:async';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/app/router/app_routes.dart';

/// Transaction list component - supports waterfall pagination
class TransactionList extends ConsumerStatefulWidget {
  final Map<String, dynamic> data;

  const TransactionList({super.key, required this.data});

  @override
  ConsumerState<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends ConsumerState<TransactionList> {
  late List<dynamic> _items;
  late int _currentPage;
  late bool _hasMore;
  late int _total;
  bool _isLoadingMore = false;

  // Cache search parameters for pagination
  Map<String, dynamic>? _searchMetadata;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    final d = widget.data;
    final itemsRaw = d['items'];
    _items = List.from(itemsRaw is List ? itemsRaw : const []);
    _total = (d['total'] is num ? (d['total'] as num).toInt() : 0);
    _currentPage = (d['page'] is num ? (d['page'] as num).toInt() : 1);
    _hasMore = d['hasMore'] == true;
    final metaRaw = d['metadata'];
    _searchMetadata = metaRaw is Map
        ? Map<String, dynamic>.from(metaRaw)
        : null;
  }

  // Monitor and execute pagination
  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final homeService = ref.read(homeServiceProvider);

      // Extract and convert transaction_types
      String? typesString;
      final rawTypes = _searchMetadata?['transaction_types'];
      if (rawTypes is List) {
        typesString = rawTypes.join(',');
      }

      final result = await homeService.searchTransactions(
        page: _currentPage + 1,
        size: widget.data['per_page'] is num
            ? (widget.data['per_page'] as num).toInt()
            : 10,
        keyword: _searchMetadata?['keyword']?.toString(),
        startDate: _searchMetadata?['start_date']?.toString(),
        endDate: _searchMetadata?['end_date']?.toString(),
        type: typesString,
      );

      if (mounted) {
        setState(() {
          final newItems = result['items'];
          _items.addAll(newItems is List ? newItems : const []);
          _currentPage = result['page'] is num
              ? (result['page'] as num).toInt()
              : (_currentPage + 1);
          _hasMore = result['hasMore'] == true;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
      debugPrint('Error loading more transactions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    if (_items.isEmpty) {
      return _buildEmptyState(theme, colors);
    }

    // When inside a Modal, use Column + Expanded to fill space
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top: summary
        _buildHeader(theme, colors),

        // List content - fills remaining space
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (!_isLoadingMore &&
                  _hasMore &&
                  scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent - 200) {
                unawaited(_loadMore());
              }
              return false;
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _items.length + (_hasMore ? 1 : 0),
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 56,
                color: colors.muted.withValues(alpha: 0.5),
              ),
              itemBuilder: (context, index) {
                if (index == _items.length) {
                  return _buildLoadMoreIndicator(theme, colors);
                }
                final item = _items[index];
                if (item is! Map) {
                  return const SizedBox.shrink();
                }
                return _buildTransactionItem(
                  context,
                  theme,
                  colors,
                  Map<String, dynamic>.from(item),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(FThemeData theme, FColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: colors.muted.withValues(alpha: 0.2)),
      child: Row(
        children: [
          Icon(FLucideIcons.list, color: colors.primary, size: 18),
          const SizedBox(width: 8),
          Text(
            t.chat.genui.transactionList.searchResults(count: _total),
            style: AppTextStyles.actionText(theme),
          ),
          const Spacer(),
          if (_items.length < _total)
            Text(
              t.chat.genui.transactionList.loaded(count: _items.length),
              style: theme.typography.body.sm.copyWith(
                color: colors.primary.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(FThemeData theme, FColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(FLucideIcons.search, size: 48, color: colors.mutedForeground),
          const SizedBox(height: 16),
          Text(
            t.chat.genui.transactionList.noResults,
            style: theme.typography.body.md.copyWith(
              color: colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator(FThemeData theme, FColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      child: _isLoadingMore
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.primary,
              ),
            )
          : Text(
              _hasMore
                  ? t.chat.genui.transactionList.loadMore
                  : t.chat.genui.transactionList.allLoaded,
              style: AppTextStyles.listSubtitle(theme),
            ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    FThemeData theme,
    FColors colors,
    Map<String, dynamic> item,
  ) {
    final amount = AmountFormatter.parseDecimal(item['amount']?.toString());
    final currency = item['currency']?.toString() ?? 'CNY';
    final categoryKey = item['category']?.toString();
    final categoryEnum = TransactionCategory.fromKey(categoryKey);
    final tagsRaw = item['tags'];
    final tags = tagsRaw is List
        ? tagsRaw.map((e) => e.toString()).toList()
        : <String>[];
    final type = (item['type']?.toString() ?? 'EXPENSE').toUpperCase();
    final time = item['transaction_time']?.toString() ?? '';

    final isExpense = type == 'EXPENSE';
    final isIncome = type == 'INCOME';

    final transactionType = isExpense
        ? TransactionType.expense
        : (isIncome ? TransactionType.income : TransactionType.transfer);
    final transactionId = item['id']?.toString();

    return InkWell(
      onTap: transactionId != null
          ? () => context.pushNamed(
              AppRouteNames.transactionDetail,
              pathParameters: {'transactionId': transactionId},
            )
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ThemedIcon.large(icon: categoryEnum.icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        categoryEnum.displayText,
                        style: AppTextStyles.listTitle(theme),
                      ),
                      // Use unified AmountText component
                      item['display'] is Map
                          ? AmountText.fromDisplay(
                              display: Map<String, dynamic>.from(
                                item['display'] as Map,
                              ),
                              type: transactionType,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : AmountText(
                              amount: amount,
                              type: transactionType,
                              currency: currency,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          tags.isNotEmpty
                              ? tags.join(' · ')
                              : (item['description']?.toString() ?? ''),
                          style: AppTextStyles.listSubtitle(theme),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatDate(time),
                        style: AppTextStyles.listSubtitle(theme),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Add right arrow to indicate tappable
            const SizedBox(width: 8),
            Icon(
              FLucideIcons.chevronRight,
              color: colors.mutedForeground.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String isoTime) {
    if (isoTime.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(isoTime);
      return '${dateTime.month}/${dateTime.day}';
    } catch (e) {
      return '';
    }
  }
}
