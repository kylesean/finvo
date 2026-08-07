import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import 'package:finvo/features/finance/widgets/financial_setting_sheets.dart';
import 'package:finvo/app/router/app_routes.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/shared/widgets/themed_icon.dart';

/// Left navigation drawer for the financial accounts page.
class FinancialAccountsDrawer extends StatelessWidget {
  const FinancialAccountsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colors;

    return Drawer(
      backgroundColor: colorScheme.background,
      shape: const RoundedRectangleBorder(), // Remove rounded corners
      child: SafeArea(
        child: Column(
          children: [
            // Top: title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    FLucideIcons.wallet,
                    size: 24,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t.financial.management,
                      style: AppTextStyles.pageTitle(theme),
                    ),
                  ),
                ],
              ),
            ),

            // Middle: feature list
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Financial settings group
                    Text(
                      t.financial.settings,
                      style: AppTextStyles.sectionHeader(theme),
                    ),
                    const SizedBox(height: 8),
                    FItemGroup(
                      children: [
                        FItem(
                          prefix: const ThemedIcon(
                            icon: FLucideIcons.dollarSign,
                          ),
                          title: Text(t.financial.budgetManagement),
                          suffix: const Icon(FLucideIcons.chevronRight),
                          onPress: () {
                            Navigator.of(context).pop(); // Close drawer
                            // Delay navigation to wait for drawer close animation
                            unawaited(
                              Future<void>.delayed(
                                const Duration(milliseconds: 100),
                                () {
                                  if (context.mounted) {
                                    unawaited(
                                      context.pushNamed(
                                        AppRouteNames.budgetOverview,
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ),
                        FItem(
                          prefix: const ThemedIcon(icon: FLucideIcons.repeat),
                          title: Text(t.financial.recurringTransactions),
                          suffix: const Icon(FLucideIcons.chevronRight),
                          onPress: () {
                            Navigator.of(context).pop(); // Close drawer
                            // Delay navigation to wait for drawer close animation
                            unawaited(
                              Future<void>.delayed(
                                const Duration(milliseconds: 100),
                                () {
                                  if (context.mounted) {
                                    unawaited(
                                      context.pushNamed(
                                        AppRouteNames.recurringTransactions,
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ),
                        FItem(
                          prefix: const ThemedIcon(icon: FLucideIcons.shield),
                          title: Text(t.financial.safetyThreshold),
                          suffix: const Icon(FLucideIcons.chevronRight),
                          onPress: () {
                            Navigator.of(context).pop(); // Close drawer
                            showSafetyThresholdSettings(context);
                          },
                        ),
                        FItem(
                          prefix: const ThemedIcon(
                            icon: FLucideIcons.calculator,
                          ),
                          title: Text(t.financial.dailyBurnRate),
                          suffix: const Icon(FLucideIcons.chevronRight),
                          onPress: () {
                            Navigator.of(context).pop(); // Close drawer
                            showDailySpendingSettings(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom: user info (optional)
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colorScheme.border)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Navigate to profile page or other features
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            FLucideIcons.user,
                            size: 16,
                            color: colorScheme.primaryForeground,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                t.financial.financialAssistant,
                                style: AppTextStyles.listTrailing(theme),
                              ),
                              Text(
                                t.financial.manageFinancialSettings,
                                style: theme.typography.body.xs.copyWith(
                                  color: colorScheme.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          FLucideIcons.chevronRight,
                          size: 16,
                          color: colorScheme.mutedForeground,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
