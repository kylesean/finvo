abstract class AppRouteNames {
  static const login = 'login';
  static const registerStep1 = 'registerStep1';
  static const registerStep2 = 'registerStep2';

  static const home = 'home';
  static const transactionDetail = 'transactionDetail';

  static const finance = 'finance';
  static const financialAccounts = 'financialAccounts';
  static const financialAccountTypePicker = 'financialAccountTypePicker';
  static const financialAccountAdd = 'financialAccountAdd';
  static const financialAccountEdit = 'financialAccountEdit';
  static const financialAccountDetail = 'financialAccountDetail';
  static const recurringTransactions = 'recurringTransactions';
  static const recurringTransactionNew = 'recurringTransactionNew';
  static const recurringTransactionEdit = 'recurringTransactionEdit';

  static const budgetOverview = 'budgetOverview';
  static const budgetNew = 'budgetNew';
  static const budgetSettings = 'budgetSettings';
  static const budgetDetail = 'budgetDetail';
  static const budgetEdit = 'budgetEdit';

  static const ai = 'ai';

  static const report = 'report';

  static const profile = 'profile';
  static const appearanceSettings = 'appearanceSettings';
  static const languageSettings = 'languageSettings';
  static const speechSettings = 'speechSettings';
  static const currencySettings = 'currencySettings';
  static const amountStyleSettings = 'amountStyleSettings';

  static const sharedSpaceList = 'sharedSpaceList';
  static const inviteSuccess = 'inviteSuccess';
  static const sharedSpaceDetail = 'sharedSpaceDetail';
  static const sharedSpaceSettings = 'sharedSpaceSettings';
}

abstract class AppRoutePaths {
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const finance = '/finance';
  static const ai = '/ai';
  static const report = '/report';
  static const profile = '/profile';
}

/// Route prefixes that do not require authentication.
///
/// Consumed by the router's redirect guard so that public routes are defined
/// in a single place instead of being inlined in the router.
const List<String> publicRoutePrefixes = ['/login', '/register'];
