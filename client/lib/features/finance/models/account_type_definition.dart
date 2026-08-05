import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:finvo/features/profile/models/financial_account.dart';

/// UI-layer account nature classification (for grouped display)
enum AccountNature {
  liquidAssets,
  creditAccounts,
  investmentAssets,
  longTermLiabilities,
  receivables,
  payables,
  otherAssets,
}

extension AccountNatureX on AccountNature {
  /// Display name header matching the PRD wording.
  String get displayName {
    switch (this) {
      case AccountNature.liquidAssets:
        return 'Liquid Assets';
      case AccountNature.creditAccounts:
        return 'Credit Accounts';
      case AccountNature.investmentAssets:
        return 'Investment Assets';
      case AccountNature.longTermLiabilities:
        return 'Long-term Liabilities';
      case AccountNature.receivables:
        return 'Receivables';
      case AccountNature.payables:
        return 'Payables';
      case AccountNature.otherAssets:
        return 'Other Assets';
    }
  }

  /// Supporting description surfaced under the header.
  String get description {
    switch (this) {
      case AccountNature.liquidAssets:
        return 'Everyday accessible funds with the highest liquidity.';
      case AccountNature.creditAccounts:
        return 'Revolving credit lines granted by financial institutions.';
      case AccountNature.investmentAssets:
        return 'Assets aimed at appreciation, with values fluctuating by market.';
      case AccountNature.longTermLiabilities:
        return 'Structured long-term loans or financing debts.';
      case AccountNature.receivables:
        return 'Short-term amounts owed to you.';
      case AccountNature.payables:
        return 'Short-term amounts you owe to others.';
      case AccountNature.otherAssets:
        return 'Other special-purpose or less liquid assets.';
    }
  }
}

typedef AccountTypeIconBuilder = Widget Function(Color color);

class AccountTypeDefinition {
  const AccountTypeDefinition({
    required this.id,
    required this.apiType,
    required this.nature,
    required this.title,
    required this.subtitle,
    required this.iconBuilder,
    required this.accentColor,
    this.helper,
    this.requiresCustomName = true,
    this.keywords = const [],
  });

  /// Unique identifier at the UI layer (matches backend FinancialAccountType)
  final String id;

  /// Corresponding backend FinancialAccountType enum value
  final FinancialAccountType apiType;

  /// UI-layer account nature classification
  final AccountNature nature;

  final String title;
  final String subtitle;
  final AccountTypeIconBuilder iconBuilder;
  final Color accentColor;
  final String? helper;
  final bool requiresCustomName;
  final List<String> keywords;

  bool matches(String query) {
    final lowerQuery = query.trim().toLowerCase();
    if (lowerQuery.isEmpty) {
      return true;
    }
    final haystack = <String?>[
      id,
      title,
      subtitle,
      helper,
      ...keywords,
    ].whereType<String>().map((value) => value.toLowerCase());
    return haystack.any((value) => value.contains(lowerQuery));
  }
}

AccountTypeIconBuilder _lucideIcon(IconData iconData) {
  return (Color color) => Icon(iconData, color: color, size: 24);
}

/// Registry of all account-type definitions.
///
/// Each backend FinancialAccountType maps to exactly one UI definition.
class AccountTypeRegistry {
  static final List<AccountTypeDefinition> definitions = [
    // === Asset types (ASSET) ===

    // CASH: physical currency, pocket change
    AccountTypeDefinition(
      id: 'cash',
      apiType: FinancialAccountType.cash,
      nature: AccountNature.liquidAssets,
      title: 'Cash',
      subtitle: 'Physical currency and pocket change.',
      iconBuilder: _lucideIcon(FLucideIcons.banknote),
      accentColor: const Color(0xFF16A34A),
      requiresCustomName: false,
      keywords: ['cash', 'wallet', 'change'],
    ),

    // DEPOSIT: bank deposits (demand, fixed, checking accounts)
    AccountTypeDefinition(
      id: 'deposit',
      apiType: FinancialAccountType.deposit,
      nature: AccountNature.liquidAssets,
      title: 'Bank Deposit',
      subtitle: 'Savings, demand, fixed, and checking accounts.',
      iconBuilder: _lucideIcon(FLucideIcons.landmark),
      accentColor: const Color(0xFF2563EB),
      keywords: ['bank', 'deposit', 'savings', 'checking'],
    ),

    // E_MONEY: electronic money accounts, third-party payment platform balances
    AccountTypeDefinition(
      id: 'e_money',
      apiType: FinancialAccountType.eMoney,
      nature: AccountNature.liquidAssets,
      title: 'E-Wallet',
      subtitle: 'WeChat Pay, Alipay, PayPal, etc.',
      iconBuilder: _lucideIcon(FLucideIcons.wallet),
      accentColor: const Color(0xFF7C3AED),
      keywords: ['digital', 'wallet', 'alipay', 'wechat', 'pay', 'e-wallet'],
    ),

    // INVESTMENT: stocks, funds, bonds, wealth management products
    AccountTypeDefinition(
      id: 'investment',
      apiType: FinancialAccountType.investment,
      nature: AccountNature.investmentAssets,
      title: 'Investment',
      subtitle: 'Stocks, funds, bonds, and wealth management products.',
      iconBuilder: _lucideIcon(FLucideIcons.chartLine),
      accentColor: const Color(0xFF0EA5E9),
      keywords: ['stocks', 'funds', 'securities', 'bonds', 'investment'],
    ),

    // RECEIVABLE: amounts owed to you (e.g. money lent to friends)
    AccountTypeDefinition(
      id: 'receivable',
      apiType: FinancialAccountType.receivable,
      nature: AccountNature.receivables,
      title: 'Receivable',
      subtitle: 'Money others owe you or lent out.',
      helper: 'Others owe me',
      iconBuilder: _lucideIcon(FLucideIcons.circleArrowRight),
      accentColor: const Color(0xFF10B981),
      keywords: ['receivable', 'lent', 'owed'],
    ),

    // === Liability types (LIABILITY) ===

    // CREDIT_CARD: credit card accounts (outstanding balance)
    AccountTypeDefinition(
      id: 'credit_card',
      apiType: FinancialAccountType.creditCard,
      nature: AccountNature.creditAccounts,
      title: 'Credit Card',
      subtitle: 'Outstanding credit card balances.',
      iconBuilder: _lucideIcon(FLucideIcons.creditCard),
      accentColor: const Color(0xFFDB2777),
      keywords: ['credit card', 'credit'],
    ),

    // LOAN: mortgages, auto loans, personal loans
    AccountTypeDefinition(
      id: 'loan',
      apiType: FinancialAccountType.loan,
      nature: AccountNature.longTermLiabilities,
      title: 'Loan',
      subtitle: 'Mortgages, auto loans, personal loans, student loans, etc.',
      iconBuilder: _lucideIcon(FLucideIcons.circleDollarSign),
      accentColor: const Color(0xFFFB7185),
      keywords: ['mortgage', 'auto loan', 'personal loan', 'loan'],
    ),

    // PAYABLE: amounts you owe (e.g. pending payment installments)
    AccountTypeDefinition(
      id: 'payable',
      apiType: FinancialAccountType.payable,
      nature: AccountNature.payables,
      title: 'Payable',
      subtitle: 'Money you owe, pending installments, etc.',
      helper: 'I owe others',
      iconBuilder: _lucideIcon(FLucideIcons.circleArrowLeft),
      accentColor: const Color(0xFFEF4444),
      keywords: ['payable', 'owe', 'installment', 'short-term loan'],
    ),
  ];

  static final Map<String, AccountTypeDefinition> _definitionsById = {
    for (final definition in definitions) definition.id: definition,
  };

  static final Map<FinancialAccountType, AccountTypeDefinition>
  _definitionsByApiType = {
    for (final definition in definitions) definition.apiType: definition,
  };

  /// Look up definition by UI id
  static AccountTypeDefinition? resolve(String? id) {
    if (id == null) {
      return null;
    }
    return _definitionsById[id];
  }

  /// Look up definition by backend FinancialAccountType
  static AccountTypeDefinition? resolveByApiType(FinancialAccountType? type) {
    if (type == null) {
      return null;
    }
    return _definitionsByApiType[type];
  }

  static List<AccountTypeDefinition> byNature(AccountNature nature) {
    return definitions
        .where((definition) => definition.nature == nature)
        .toList();
  }

  /// Get default account type definition based on backend FinancialNature
  /// Used as a fallback when no matching definition is found
  static AccountTypeDefinition getDefaultDefinition(FinancialNature nature) {
    if (nature == FinancialNature.liability) {
      // Liability accounts default to PAYABLE type
      return _definitionsByApiType[FinancialAccountType.payable] ??
          definitions.last;
    } else {
      // Asset accounts default to CASH type
      return _definitionsByApiType[FinancialAccountType.cash] ??
          definitions.first;
    }
  }
}
