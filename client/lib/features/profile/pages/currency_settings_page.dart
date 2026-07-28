// features/profile/pages/currency_settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';
import 'package:finvo/shared/models/currency.dart';
import 'package:finvo/shared/services/toast_service.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/i18n/strings.g.dart';
import '../providers/financial_settings_provider.dart';

class CurrencySettingsPage extends ConsumerWidget {
  const CurrencySettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colors = theme.colors;
    final state = ref.watch(financialSettingsProvider);
    final notifier = ref.read(financialSettingsProvider.notifier);

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
        title: Text(t.settings.currency, style: AppTextStyles.pageTitle(theme)),
        centerTitle: true,
        actions: [
          if (state.hasChanges)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Center(
                child: FButton(
                  variant: .ghost,
                  onPress: state.isLoading
                      ? null
                      : () async {
                          final newCurrency = state.primaryCurrency;
                          final currencyInfo = Currency.fromCode(newCurrency);
                          final success = await notifier
                              .saveFinancialSettings();
                          if (success && context.mounted) {
                            // Show switched currency name and symbol
                            final currencyDisplay = currencyInfo != null
                                ? '${currencyInfo.flag} ${currencyInfo.code}'
                                : newCurrency;
                            ToastService.success(
                              description: Text(
                                t.settings.currencyChangedRefreshHint(
                                  currency: currencyDisplay,
                                ),
                              ),
                            );
                            context.pop();
                          }
                        },
                  child: Text(t.common.save),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Description
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
              child: Text(
                t.settings.currencyDescription,
                style: AppTextStyles.sectionHeader(theme),
              ),
            ),

            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: LinearProgressIndicator(),
              ),

            // Currency list in FTileGroup to match consistency
            FTileGroup(
              children: Currency.values.map((currency) {
                final isSelected = state.primaryCurrency == currency.code;

                return FTile(
                  prefix: Text(
                    currency.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    '${currency.code} - ${currency.localizedName}',
                    style: theme.typography.body.md.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected ? colors.primary : colors.foreground,
                    ),
                  ),
                  suffix: isSelected
                      ? Icon(
                          FLucideIcons.check,
                          size: 20,
                          color: colors.primary,
                        )
                      : null,
                  onPress: () {
                    notifier.updatePrimaryCurrency(currency.code);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
