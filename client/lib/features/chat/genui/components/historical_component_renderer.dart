import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:finvo/features/chat/genui/templates/templates.dart';
import 'package:finvo/features/chat/genui/utils/utils.dart';

/// Renders historical UI components from stored message data.
///
/// This widget is used to render UI components that were saved in message
/// history. It uses the same widget builders as the GenUI catalog but
/// bypasses the dynamic surface system.
///
class HistoricalComponentRenderer extends StatelessWidget {
  /// The component type name (e.g., 'TransactionReceipt')
  final String componentType;

  /// The component data
  final Map<String, dynamic> data;

  const HistoricalComponentRenderer({
    super.key,
    required this.componentType,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return buildComponent(context, componentType, data);
  }

  /// The component type names this renderer understands. Tests assert the
  /// GenUI catalog's registered names are a subset of this set, so a catalog
  /// rename can never silently orphan the historical renderer again (GENUI-3).
  static const Set<String> supportedTypes = {
    'TransactionReceipt',
    'TransferReceipt',
    'DataTable',
    'ExpenseTable',
    'ChartCard',
    'SummaryCard',
    'BudgetStatusCard',
    'BudgetReceipt',
    'BudgetAnalysisCard',
    'TransactionGroupReceipt',
    'TransactionList',
    'CashFlowCard',
    'HealthScoreCard',
    'ExpenseSummaryCard',
    'CashFlowForecastChart',
    'TransferWizard',
    'SpaceSelectorCard',
    'SpaceAssociationReceipt',
    'artifact_link',
    'ArtifactLinkCard',
  };

  static Widget buildComponent(
    BuildContext context,
    String componentType,
    Map<String, dynamic> data,
  ) {
    // Use HistoricalModeHelper to add historical mode marker
    final historicalData = HistoricalModeHelper.markAsHistorical(data);

    // Reuse templates/ widgets
    // Note: Component names must match the definitions in the backend TOOL_UI_MAP
    return switch (componentType) {
      'TransactionReceipt' => TransactionCard(data: historicalData),
      'TransferReceipt' => TransferReceipt(data: historicalData),
      // GENUI-3: the live catalog registers this component as 'DataTable'
      // (catalog_transaction_items.dart) — the historical renderer previously
      // matched 'ExpenseTable' only, so stored DataTable components silently
      // degraded to the "unsupported" box. 'ExpenseTable' is kept as a legacy
      // alias for messages stored before the rename.
      'DataTable' || 'ExpenseTable' => ExpenseTable(data: historicalData),
      'ChartCard' => ChartCard(data: historicalData),
      'SummaryCard' => SummaryCard(data: historicalData),
      // Budget components
      'BudgetStatusCard' => BudgetStatusCard(data: historicalData),
      'BudgetReceipt' => BudgetReceipt(data: historicalData),
      'BudgetAnalysisCard' => BudgetAnalysisCard(data: historicalData),
      // Transaction group receipt
      'TransactionGroupReceipt' => TransactionGroupReceipt(
        data: historicalData,
      ),
      // Transaction list
      'TransactionList' => TransactionList(data: historicalData),
      // Statistics analysis components
      'CashFlowCard' => CashFlowAnalysisCard(data: historicalData),
      'HealthScoreCard' => HealthScoreAnalysisCard(data: historicalData),
      // Expense summary
      'ExpenseSummaryCard' => ExpenseSummaryCard(data: historicalData),
      // Forecast prediction components
      'CashFlowForecastChart' => CashFlowForecastChart(data: historicalData),
      'TransferWizard' => TransferWizard(
        data: historicalData,
        dispatchEvent: HistoricalModeHelper.noopDispatch,
      ),
      // Shared-space components (interaction is disabled in historical mode)
      'SpaceSelectorCard' => SpaceSelectorCard(
        data: historicalData,
        dispatchEvent: HistoricalModeHelper.noopDispatch,
      ),
      'SpaceAssociationReceipt' => SpaceAssociationReceipt(
        data: historicalData,
        dispatchEvent: HistoricalModeHelper.noopDispatch,
      ),
      // Artifact link: rendered as a static tile (live mode is a simple
      // non-interactive link card as well).
      'artifact_link' ||
      'ArtifactLinkCard' => _buildArtifactLinkTile(context, historicalData),
      _ => _buildUnsupportedComponent(context, componentType),
    };
  }

  static Widget _buildArtifactLinkTile(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final colors = context.theme.colors;
    final artifactName =
        data['artifactName'] as String? ??
        data['path'] as String? ??
        'Artifact File';
    final url = data['artifactUrl'] as String? ?? data['url'] as String? ?? '';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: colors.border.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(FLucideIcons.fileText, size: 24.0),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  artifactName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (url.isNotEmpty)
                  Text(
                    url,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: colors.mutedForeground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildUnsupportedComponent(
    BuildContext context,
    String componentType,
  ) {
    final colors = context.theme.colors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.muted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(FLucideIcons.triangleAlert, color: colors.mutedForeground),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Unsupported component type: $componentType',
              style: TextStyle(color: colors.mutedForeground),
            ),
          ),
        ],
      ),
    );
  }
}
