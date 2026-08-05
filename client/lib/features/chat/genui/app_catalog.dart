import 'package:genui/genui.dart';
import 'package:finvo/features/chat/genui/catalog_analytics_items.dart';
import 'package:finvo/features/chat/genui/catalog_budget_items.dart';
import 'package:finvo/features/chat/genui/catalog_space_artifact_items.dart';
import 'package:finvo/features/chat/genui/catalog_transaction_items.dart';

/// Application-specific component catalog
///
/// Aggregates the domain component groups (transaction, budget, analytics,
/// shared space / artifact) built in the sibling `catalog_*_items.dart` files.
class AppCatalog {
  /// Build the complete component catalog
  ///
  /// Starts with core components, then adds application-specific custom components.
  static Catalog build() {
    // Start with core components
    final catalog = BasicCatalogItems.asCatalog();

    // Add custom components
    return catalog.copyWith(
      newItems: [
        ...buildTransactionItems(),
        ...buildBudgetItems(),
        ...buildAnalyticsItems(),
        ...buildSpaceArtifactItems(),
      ],
    );
  }
}
