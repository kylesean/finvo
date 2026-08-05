// features/chat/widgets/tool_execution_block.dart
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import '../models/tool_call_info.dart';
import '../../../i18n/strings.g.dart';
import 'dart:async';
import 'package:finvo/shared/theme/form_text_styles.dart';

/// A simplified row showing tool execution status
/// Consistent with the semantic "Processing..." indicator
class ToolExecutionBlock extends StatefulWidget {
  final ToolCallInfo toolCall;

  const ToolExecutionBlock({super.key, required this.toolCall});

  @override
  State<ToolExecutionBlock> createState() => _ToolExecutionBlockState();
}

class _ToolExecutionBlockState extends State<ToolExecutionBlock>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    if (widget.toolCall.status == ToolExecutionStatus.running ||
        widget.toolCall.status == ToolExecutionStatus.pending) {
      unawaited(_controller.repeat());
    }
    // Do not start animation for cancelled/success/error status
  }

  @override
  void didUpdateWidget(ToolExecutionBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.toolCall.status == ToolExecutionStatus.running ||
        widget.toolCall.status == ToolExecutionStatus.pending) {
      if (!_controller.isAnimating) {
        unawaited(_controller.repeat());
      }
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = Translations.of(context);

    // Get semantic label text based on status
    final label = _getLabelForStatus(
      widget.toolCall.name,
      widget.toolCall.status,
      t,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusIcon(theme),
          const SizedBox(width: 8),
          _buildStatusLabel(theme, label),
          if (widget.toolCall.status == ToolExecutionStatus.success &&
              widget.toolCall.durationMs != null)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(
                '(${widget.toolCall.durationMs}ms)',
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusLabel(FThemeData theme, String label) {
    final colors = theme.colors;

    if (widget.toolCall.status != ToolExecutionStatus.running &&
        widget.toolCall.status != ToolExecutionStatus.pending) {
      return Text(
        label,
        style: AppTextStyles.listTrailing(theme).copyWith(
          color: widget.toolCall.status == ToolExecutionStatus.error
              ? colors.destructive
              : colors.mutedForeground,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                colors.mutedForeground,
                colors.primary,
                colors.mutedForeground,
              ],
              stops: [
                (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                _shimmerAnimation.value.clamp(0.0, 1.0),
                (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: Text(
            label,
            style: theme.typography.body.sm.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }

  /// Get label text based on status
  /// - pending/running: in-progress label with "..."
  /// - success: completed label without "..."
  /// - error: failure label
  String _getLabelForStatus(
    String toolName,
    ToolExecutionStatus status,
    Translations t,
  ) {
    // For execute tool, try to parse script name from args for more semantic status display
    final semanticName = _getSemanticToolName(toolName, widget.toolCall.args);

    switch (status) {
      case ToolExecutionStatus.pending:
      case ToolExecutionStatus.running:
        return _toolLabels(semanticName, t).running;
      case ToolExecutionStatus.success:
        return _toolLabels(semanticName, t).done;
      case ToolExecutionStatus.error:
        return t.chat.tools.failed.unknown;
      case ToolExecutionStatus.cancelled:
        return t.chat.tools.cancelled;
    }
  }

  /// Parse semantic tool name from execute tool arguments
  /// e.g.: execute({command: "python analyze_finance.py"}) -> "analyze_finance"
  String _getSemanticToolName(String toolName, Map<String, dynamic> args) {
    if (toolName != 'execute') return toolName;

    final command = args['command']?.toString() ?? '';

    // Script to semantic name mapping (updated for redesigned skills)
    const scriptMappings = {
      // reviewing-finances
      'analyze_spending.py': 'analyze_spending',
      'analyze_cashflow.py': 'analyze_cashflow',
      // forecasting-finances
      'forecast_balance.py': 'forecast_balance',
      // planning-budgets
      'suggest_budget.py': 'suggest_budget',
      'prepare_budget_simulation.py': 'prepare_budget_simulation',
      'simulate_budget.py': 'simulate_budget',
      // managing-shared-ledgers
      'list_spaces.py': 'list_spaces',
      'query_space_summary.py': 'query_space_summary',
      // executing-transfers
      'prepare_transfer.py': 'prepare_transfer',
    };

    for (final entry in scriptMappings.entries) {
      if (command.contains(entry.key)) {
        return entry.value;
      }
    }

    return toolName; // Return original tool name when unrecognized
  }

  /// Label pair for a tool name: (running, done)
  ({String running, String done}) _toolLabels(String toolName, Translations t) {
    final tools = t.chat.tools;
    final done = tools.done;
    return switch (toolName) {
      'read_file' => (running: tools.readFile, done: done.readFile),
      'search_transactions' => (
        running: tools.searchTransactions,
        done: done.searchTransactions,
      ),
      'query_budget_status' => (
        running: tools.queryBudgetStatus,
        done: done.queryBudgetStatus,
      ),
      'create_budget' => (running: tools.createBudget, done: done.createBudget),
      'analyze_spending' => (
        running: tools.analyzeSpending,
        done: done.analyzeSpending,
      ),
      'analyze_cashflow' => (
        running: tools.analyzeCashflow,
        done: done.analyzeCashflow,
      ),
      'forecast_balance' => (
        running: tools.forecastBalance,
        done: done.forecastBalance,
      ),
      'suggest_budget' => (
        running: tools.suggestBudget,
        done: done.suggestBudget,
      ),
      'prepare_budget_simulation' => (
        running: tools.prepareBudgetSimulation,
        done: done.prepareBudgetSimulation,
      ),
      'simulate_budget' => (
        running: tools.simulateBudget,
        done: done.simulateBudget,
      ),
      'list_spaces' => (running: tools.listSpaces, done: done.listSpaces),
      'query_space_summary' => (
        running: tools.querySpaceSummary,
        done: done.querySpaceSummary,
      ),
      'prepare_transfer' => (
        running: tools.prepareTransfer,
        done: done.prepareTransfer,
      ),
      // Keep legacy tool mappings (backward compatibility)
      'get_cash_flow_analysis' => (
        running: tools.getCashFlowAnalysis,
        done: done.getCashFlowAnalysis,
      ),
      'get_financial_health_score' => (
        running: tools.getFinancialHealthScore,
        done: done.getFinancialHealthScore,
      ),
      'get_financial_summary' => (
        running: tools.getFinancialSummary,
        done: done.getFinancialSummary,
      ),
      'evaluate_financial_health' => (
        running: tools.evaluateFinancialHealth,
        done: done.evaluateFinancialHealth,
      ),
      'simulate_expense_impact' => (
        running: tools.simulateExpenseImpact,
        done: done.simulateExpenseImpact,
      ),
      'record_transactions' => (
        running: tools.recordTransactions,
        done: done.recordTransactions,
      ),
      'create_transaction' => (
        running: tools.createTransaction,
        done: done.createTransaction,
      ),
      'duckduckgo_search' => (
        running: tools.duckduckgoSearch,
        done: done.duckduckgoSearch,
      ),
      'execute_transfer' => (
        running: tools.executeTransfer,
        done: done.executeTransfer,
      ),
      'list_dir' => (running: tools.listDir, done: done.listDir),
      'execute' => (running: tools.execute, done: done.execute),
      _ => (running: tools.unknown, done: done.unknown),
    };
  }

  Widget _buildStatusIcon(FThemeData theme) {
    switch (widget.toolCall.status) {
      case ToolExecutionStatus.pending:
      case ToolExecutionStatus.running:
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * 3.14159,
              child: Icon(
                FLucideIcons.loader,
                size: 14,
                color: theme.colors.primary,
              ),
            );
          },
        );
      case ToolExecutionStatus.success:
        return const Icon(FLucideIcons.check, size: 14, color: Colors.green);
      case ToolExecutionStatus.error:
        return Icon(
          FLucideIcons.triangleAlert,
          size: 14,
          color: theme.colors.destructive,
        );
      case ToolExecutionStatus.cancelled:
        return Icon(
          FLucideIcons.x,
          size: 14,
          color: theme.colors.mutedForeground,
        );
    }
  }
}
