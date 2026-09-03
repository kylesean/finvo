import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:finvo/i18n/strings.g.dart';

/// Legacy numeric category ids ('1'-'8'). New code uses [TransactionCategory]
/// (backend keys); this stays only as the unknown-key fallback.
class CategoryConfig {
  // Direct mapping from category ID to icon
  static const Map<String, IconData> _categoryIdToIcon = {
    '1': FLucideIcons.shoppingBag,
    '2': FLucideIcons.carTaxiFront,
    '3': FLucideIcons.briefcaseMedical,
    '4': FLucideIcons.housePlus,
    '5': FLucideIcons.libraryBig,
    '6': FLucideIcons.walletCards,
    '7': FLucideIcons.gift,
    '8': FLucideIcons.folderSync,
  };

  /// Get category name based on category ID (using slang internationalization)
  static String getCategoryName(String? categoryId) {
    if (categoryId == null) return t.category.other;
    switch (categoryId) {
      case '1':
        return t.category.dailyConsumption;
      case '2':
        return t.category.transportation;
      case '3':
        return t.category.healthcare;
      case '4':
        return t.category.housing;
      case '5':
        return t.category.education;
      case '6':
        return t.category.incomeCategory;
      case '7':
        return t.category.socialGifts;
      case '8':
        return t.category.moneyTransfer;
      default:
        return t.category.other;
    }
  }

  /// Get category icon based on category ID
  static IconData getCategoryIcon(String? categoryId) {
    if (categoryId == null) return FLucideIcons.shoppingBag;
    return _categoryIdToIcon[categoryId] ?? FLucideIcons.shoppingBag;
  }
}
