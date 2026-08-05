/// GenUI Composable Widget System
///
/// A 4-layer atomic widget architecture following flutter_genui design philosophy:
///
/// - **Atoms**: Smallest, indivisible UI elements (IconBadge, AmountDisplay, etc.)
/// - **Molecules**: Composed components from atoms (AccountCard, TransactionItem, etc.)
/// - **Organisms**: Complex containers managing molecules (AccountSelector, AccountList, etc.)
/// - **Templates**: Full business flows (registered in app_catalog.dart)
///
/// Usage:
/// ```dart
/// import 'package:finvo/features/chat/genui/genui_widgets.dart';
///
/// // Use atoms
/// IconBadge(icon: FLucideIcons.wallet, ...);
/// AmountDisplay(amount: 1234.56, currency: 'CNY');
///
/// // Use molecules
/// AccountCard(data: accountData, selected: true);
///
/// // Use organisms
/// AccountSelector(data: selectorData, dispatchEvent: context.dispatchEvent);
/// ```
library;

// Layer 1: Atoms
export 'package:finvo/features/chat/genui/atoms/atoms.dart';

// Layer 2: Molecules
export 'package:finvo/features/chat/genui/molecules/molecules.dart';

// Layer 3: Organisms
export 'package:finvo/features/chat/genui/organisms/organisms.dart';

// Utilities
export 'package:finvo/features/chat/genui/utils/formatters.dart';
export 'package:finvo/features/chat/genui/utils/theme_helpers.dart';
export 'package:finvo/features/chat/genui/utils/genui_data_paths.dart';
