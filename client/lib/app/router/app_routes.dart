abstract class AppRouteNames {
  static const login = 'login';
  static const registerStep1 = 'registerStep1';
  static const registerStep2 = 'registerStep2';
  static const serverSetup = 'serverSetup';

  static const home = 'home';
  static const transactionDetail = 'transactionDetail';
  static const notifications = 'notifications';

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
  static const conversation = 'conversation';

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
  static const joinSpace = 'joinSpace';
}

abstract class AppRoutePaths {
  static const login = '/login';
  static const register = '/register';
  static const registerStep2 = '/register/step2';
  static const serverSetup = '/server-setup';
  static const home = '/home';
  static const notifications = '/notifications';
  static const finance = '/finance';
  static const ai = '/ai';
  static const report = '/report';
  static const profile = '/profile';
  static const joinSpace = '/join-space';
  static const sharedSpaceList = '/profile/shared-space';

  /// ``/home/transaction/:transactionId``
  static String transactionDetail(String transactionId) =>
      '/home/transaction/$transactionId';

  /// ``/ai/:conversationId``
  static String conversation(String conversationId) => '/ai/$conversationId';

  /// ``/profile/shared-space/:spaceId``
  static String sharedSpaceDetail(String spaceId) =>
      '/profile/shared-space/$spaceId';

  /// ``/profile/shared-space/:spaceId/settings``
  static String sharedSpaceSettings(String spaceId) =>
      '/profile/shared-space/$spaceId/settings';

  /// ``/finance/recurring-transactions/:id/edit``
  static String recurringTransactionEdit(String id) =>
      '/finance/recurring-transactions/$id/edit';

  /// ``/finance/budgets/:id``
  static String budgetDetail(String id) => '/finance/budgets/$id';

  /// ``/finance/budgets/:id/edit``
  static String budgetEdit(String id) => '/finance/budgets/$id/edit';
}

/// Route prefixes that do not require authentication.
///
/// Consumed by the router's redirect guard so that public routes are defined
/// in a single place instead of being inlined in the router.
const List<String> publicRoutePrefixes = ['/login', '/register'];
