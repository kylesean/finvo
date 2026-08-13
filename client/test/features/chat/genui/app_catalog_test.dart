import 'package:flutter_test/flutter_test.dart';
import 'package:finvo/features/chat/genui/app_catalog.dart';
import 'package:finvo/features/chat/genui/components/historical_component_renderer.dart';

void main() {
  group('AppCatalog', () {
    test('build() returns a valid catalog', () {
      final catalog = AppCatalog.build();
      expect(catalog, isNotNull);
      expect(catalog.items, isNotEmpty);
      expect(
        catalog.items.any((item) => item.name == 'TransferWizard'),
        isTrue,
      );
    });

    // Note: Testing widget builders requires constructing a complex CatalogItemContext
    // which involves deep dependencies from the genui package.
    // We verified the structure above, which ensures the catalog is correctly assembled.
  });

  // GENUI-3 regression guard: every APPLICATION-specific component registered
  // in the live catalog (transaction/budget/analytics/space groups — not the
  // base GenUI primitives, which are dynamic-surface building blocks rather
  // than historical message components) must also be renderable by the
  // historical renderer. The catalog and the renderer previously diverged
  // ('DataTable' vs 'ExpenseTable'), silently degrading stored components to
  // the "unsupported" box.
  group('HistoricalComponentRenderer catalog alignment', () {
    test('every app catalog component name is renderable historically', () {
      final appItems = [
        ...const TransactionCatalogGroup().buildItems(),
        ...const BudgetCatalogGroup().buildItems(),
        ...const AnalyticsCatalogGroup().buildItems(),
        ...const SpaceArtifactCatalogGroup().buildItems(),
      ];
      final missing = appItems
          .map((item) => item.name)
          .where(
            (name) =>
                !HistoricalComponentRenderer.supportedTypes.contains(name),
          )
          .toList();
      expect(
        missing,
        isEmpty,
        reason:
            'Catalog components not supported by '
            'HistoricalComponentRenderer: $missing',
      );
    });
  });
}
