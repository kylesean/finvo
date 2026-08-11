import 'package:genui/genui.dart';
import 'package:finvo/features/chat/genui/catalog_analytics_items.dart';
import 'package:finvo/features/chat/genui/catalog_budget_items.dart';
import 'package:finvo/features/chat/genui/catalog_space_artifact_items.dart';
import 'package:finvo/features/chat/genui/catalog_transaction_items.dart';

/// Abstract contract for domain catalog item providers.
abstract interface class CatalogGroup {
  List<CatalogItem> buildItems();
}

class TransactionCatalogGroup implements CatalogGroup {
  const TransactionCatalogGroup();
  @override
  List<CatalogItem> buildItems() => buildTransactionItems();
}

class BudgetCatalogGroup implements CatalogGroup {
  const BudgetCatalogGroup();
  @override
  List<CatalogItem> buildItems() => buildBudgetItems();
}

class AnalyticsCatalogGroup implements CatalogGroup {
  const AnalyticsCatalogGroup();
  @override
  List<CatalogItem> buildItems() => buildAnalyticsItems();
}

class SpaceArtifactCatalogGroup implements CatalogGroup {
  const SpaceArtifactCatalogGroup();
  @override
  List<CatalogItem> buildItems() => buildSpaceArtifactItems();
}

/// Application-specific component catalog
///
/// Aggregates domain component groups (transaction, budget, analytics,
/// shared space / artifact) using modular [CatalogGroup] providers.
class AppCatalog {
  static const List<CatalogGroup> _groups = [
    TransactionCatalogGroup(),
    BudgetCatalogGroup(),
    AnalyticsCatalogGroup(),
    SpaceArtifactCatalogGroup(),
  ];

  /// Build the complete component catalog
  ///
  /// Starts with core components, then adds application-specific custom components.
  static Catalog build() {
    final catalog = BasicCatalogItems.asCatalog();
    final customItems = [for (final group in _groups) ...group.buildItems()];
    return catalog.copyWith(newItems: customItems);
  }
}
