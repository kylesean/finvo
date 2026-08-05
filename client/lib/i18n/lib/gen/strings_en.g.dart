///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final Translations$common$en common = Translations$common$en._(_root);
	late final Translations$time$en time = Translations$time$en._(_root);
	late final Translations$greeting$en greeting = Translations$greeting$en._(_root);
	late final Translations$navigation$en navigation = Translations$navigation$en._(_root);
	late final Translations$auth$en auth = Translations$auth$en._(_root);
	late final Translations$transaction$en transaction = Translations$transaction$en._(_root);
	late final Translations$home$en home = Translations$home$en._(_root);
	late final Translations$comment$en comment = Translations$comment$en._(_root);
	late final Translations$calendar$en calendar = Translations$calendar$en._(_root);
	late final Translations$category$en category = Translations$category$en._(_root);
	late final Translations$settings$en settings = Translations$settings$en._(_root);
	late final Translations$appearance$en appearance = Translations$appearance$en._(_root);
	late final Translations$speech$en speech = Translations$speech$en._(_root);
	late final Translations$amountTheme$en amountTheme = Translations$amountTheme$en._(_root);
	late final Translations$locale$en locale = Translations$locale$en._(_root);
	late final Translations$budget$en budget = Translations$budget$en._(_root);
	late final Translations$dateRange$en dateRange = Translations$dateRange$en._(_root);
	late final Translations$forecast$en forecast = Translations$forecast$en._(_root);
	late final Translations$chat$en chat = Translations$chat$en._(_root);
	late final Translations$footprint$en footprint = Translations$footprint$en._(_root);
	late final Translations$media$en media = Translations$media$en._(_root);
	late final Translations$error$en error = Translations$error$en._(_root);
	late final Translations$fontTest$en fontTest = Translations$fontTest$en._(_root);
	late final Translations$wizard$en wizard = Translations$wizard$en._(_root);
	late final Translations$user$en user = Translations$user$en._(_root);
	late final Translations$account$en account = Translations$account$en._(_root);
	late final Translations$financial$en financial = Translations$financial$en._(_root);
	late final Translations$app$en app = Translations$app$en._(_root);
	late final Translations$statistics$en statistics = Translations$statistics$en._(_root);
	late final Translations$currency$en currency = Translations$currency$en._(_root);
	late final Translations$budgetSuggestion$en budgetSuggestion = Translations$budgetSuggestion$en._(_root);
	late final Translations$server$en server = Translations$server$en._(_root);
	late final Translations$sharedSpace$en sharedSpace = Translations$sharedSpace$en._(_root);
	late final Translations$errorMapping$en errorMapping = Translations$errorMapping$en._(_root);
	late final Translations$notification$en notification = Translations$notification$en._(_root);
}

// Path: common
class Translations$common$en {
	Translations$common$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Loading...'
	String get loading => 'Loading...';

	/// en: 'Error'
	String get error => 'Error';

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Confirm'
	String get confirm => 'Confirm';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Add'
	String get add => 'Add';

	/// en: 'Search'
	String get search => 'Search';

	/// en: 'Filter'
	String get filter => 'Filter';

	/// en: 'Sort'
	String get sort => 'Sort';

	/// en: 'Refresh'
	String get refresh => 'Refresh';

	/// en: 'More'
	String get more => 'More';

	/// en: 'Less'
	String get less => 'Less';

	/// en: 'All'
	String get all => 'All';

	/// en: 'None'
	String get none => 'None';

	/// en: 'OK'
	String get ok => 'OK';

	/// en: 'Unknown'
	String get unknown => 'Unknown';

	/// en: 'No Data'
	String get noData => 'No Data';

	/// en: 'Load More'
	String get loadMore => 'Load More';

	/// en: 'No More'
	String get noMore => 'No More';

	/// en: 'Loading failed'
	String get loadFailed => 'Loading failed';

	/// en: 'Transactions'
	String get history => 'Transactions';

	/// en: 'Reset'
	String get reset => 'Reset';
}

// Path: time
class Translations$time$en {
	Translations$time$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Today'
	String get today => 'Today';

	/// en: 'Yesterday'
	String get yesterday => 'Yesterday';

	/// en: 'Day Before Yesterday'
	String get dayBeforeYesterday => 'Day Before Yesterday';

	/// en: 'Week'
	String get thisWeek => 'Week';

	/// en: 'Month'
	String get thisMonth => 'Month';

	/// en: 'Year'
	String get thisYear => 'Year';

	/// en: 'Select Date'
	String get selectDate => 'Select Date';

	/// en: 'Select Time'
	String get selectTime => 'Select Time';

	/// en: 'Just now'
	String get justNow => 'Just now';

	/// en: '${count}m ago'
	String minutesAgo({required Object count}) => '${count}m ago';

	/// en: '${count}h ago'
	String hoursAgo({required Object count}) => '${count}h ago';

	/// en: '${count}d ago'
	String daysAgo({required Object count}) => '${count}d ago';

	/// en: '${count}w ago'
	String weeksAgo({required Object count}) => '${count}w ago';
}

// Path: greeting
class Translations$greeting$en {
	Translations$greeting$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Good Morning'
	String get morning => 'Good Morning';

	/// en: 'Good Afternoon'
	String get afternoon => 'Good Afternoon';

	/// en: 'Good Evening'
	String get evening => 'Good Evening';
}

// Path: navigation
class Translations$navigation$en {
	Translations$navigation$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Home'
	String get home => 'Home';

	/// en: 'Forecast'
	String get forecast => 'Forecast';

	/// en: 'Footprint'
	String get footprint => 'Footprint';

	/// en: 'Profile'
	String get profile => 'Profile';
}

// Path: auth
class Translations$auth$en {
	Translations$auth$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Log In'
	String get login => 'Log In';

	/// en: 'Logging in...'
	String get loggingIn => 'Logging in...';

	/// en: 'Log Out'
	String get logout => 'Log Out';

	/// en: 'Logged out successfully'
	String get logoutSuccess => 'Logged out successfully';

	/// en: 'Confirm Logout'
	String get confirmLogoutTitle => 'Confirm Logout';

	/// en: 'Are you sure you want to log out?'
	String get confirmLogoutContent => 'Are you sure you want to log out?';

	/// en: 'Sign Up'
	String get register => 'Sign Up';

	/// en: 'Signing up...'
	String get registering => 'Signing up...';

	/// en: 'Welcome Back'
	String get welcomeBack => 'Welcome Back';

	/// en: 'Welcome back!'
	String get loginSuccess => 'Welcome back!';

	/// en: 'Login Failed'
	String get loginFailed => 'Login Failed';

	/// en: 'Please try again later.'
	String get pleaseTryAgain => 'Please try again later.';

	/// en: 'Log in to continue using Finvo'
	String get loginSubtitle => 'Log in to continue using Finvo';

	/// en: 'Don't have an account? Sign Up'
	String get noAccount => 'Don\'t have an account? Sign Up';

	/// en: 'Create Your Account'
	String get createAccount => 'Create Your Account';

	/// en: 'Set Password'
	String get setPassword => 'Set Password';

	/// en: 'Set Your Account Password'
	String get setAccountPassword => 'Set Your Account Password';

	/// en: 'Complete Registration'
	String get completeRegistration => 'Complete Registration';

	/// en: 'Registration successful!'
	String get registrationSuccess => 'Registration successful!';

	/// en: 'Registration failed'
	String get registrationFailed => 'Registration failed';

	late final Translations$auth$email$en email = Translations$auth$email$en._(_root);
	late final Translations$auth$password$en password = Translations$auth$password$en._(_root);
	late final Translations$auth$verificationCode$en verificationCode = Translations$auth$verificationCode$en._(_root);
}

// Path: transaction
class Translations$transaction$en {
	Translations$transaction$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Expense'
	String get expense => 'Expense';

	/// en: 'Income'
	String get income => 'Income';

	/// en: 'Transfer'
	String get transfer => 'Transfer';

	/// en: 'Amount'
	String get amount => 'Amount';

	/// en: 'Category'
	String get category => 'Category';

	/// en: 'Description'
	String get description => 'Description';

	/// en: 'Tags'
	String get tags => 'Tags';

	/// en: 'Save Transaction'
	String get saveTransaction => 'Save Transaction';

	/// en: 'Please enter amount'
	String get pleaseEnterAmount => 'Please enter amount';

	/// en: 'Please select category'
	String get pleaseSelectCategory => 'Please select category';

	/// en: 'Failed to save'
	String get saveFailed => 'Failed to save';

	/// en: 'Record details of this transaction...'
	String get descriptionHint => 'Record details of this transaction...';

	/// en: 'Add Custom Tag'
	String get addCustomTag => 'Add Custom Tag';

	/// en: 'Common Tags'
	String get commonTags => 'Common Tags';

	/// en: 'Maximum $maxTags tags allowed'
	String maxTagsHint({required Object maxTags}) => 'Maximum ${maxTags} tags allowed';

	/// en: 'No transactions found'
	String get noTransactionsFound => 'No transactions found';

	/// en: 'Try adjusting search criteria or create new transactions'
	String get tryAdjustingSearch => 'Try adjusting search criteria or create new transactions';

	/// en: 'No description'
	String get noDescription => 'No description';

	/// en: 'Payment'
	String get payment => 'Payment';

	/// en: 'Account'
	String get account => 'Account';

	/// en: 'Time'
	String get time => 'Time';

	/// en: 'Location'
	String get location => 'Location';

	/// en: 'Transaction Details'
	String get transactionDetail => 'Transaction Details';

	/// en: 'Favorite'
	String get favorite => 'Favorite';

	/// en: 'Confirm Delete'
	String get confirmDelete => 'Confirm Delete';

	/// en: 'Are you sure you want to delete this transaction? This action cannot be undone.'
	String get deleteTransactionConfirm => 'Are you sure you want to delete this transaction? This action cannot be undone.';

	/// en: 'No actions available'
	String get noActions => 'No actions available';

	/// en: 'Deleted'
	String get deleted => 'Deleted';

	/// en: 'Delete failed, please try again'
	String get deleteFailed => 'Delete failed, please try again';

	/// en: 'Linked Account'
	String get linkedAccount => 'Linked Account';

	/// en: 'Linked Space'
	String get linkedSpace => 'Linked Space';

	/// en: 'Not linked'
	String get notLinked => 'Not linked';

	/// en: 'Link'
	String get link => 'Link';

	/// en: 'Change Account'
	String get changeAccount => 'Change Account';

	/// en: 'Add Space'
	String get addSpace => 'Add Space';

	/// en: '$count spaces'
	String nSpaces({required Object count}) => '${count} spaces';

	/// en: 'Select Linked Account'
	String get selectLinkedAccount => 'Select Linked Account';

	/// en: 'Select Linked Space'
	String get selectLinkedSpace => 'Select Linked Space';

	/// en: 'No spaces available'
	String get noSpacesAvailable => 'No spaces available';

	/// en: 'Link successful'
	String get linkSuccess => 'Link successful';

	/// en: 'Link failed'
	String get linkFailed => 'Link failed';

	/// en: 'Message'
	String get rawInput => 'Message';

	/// en: 'No message'
	String get noRawInput => 'No message';

	/// en: '$count attachments'
	String attachments({required Object count}) => '${count} attachments';

	/// en: 'View more in conversation'
	String get viewInConversation => 'View more in conversation';

	/// en: 'Pending'
	String get statusPending => 'Pending';
}

// Path: home
class Translations$home$en {
	Translations$home$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Total Expense'
	String get totalExpense => 'Total Expense';

	/// en: 'Today's'
	String get todayExpense => 'Today\'s';

	/// en: 'This Month's'
	String get monthExpense => 'This Month\'s';

	/// en: '$year Progress'
	String yearProgress({required Object year}) => '${year} Progress';

	/// en: 'Left $days days · $percent%'
	String yearRemainingInfo({required Object days, required Object percent}) => 'Left ${days} days · ${percent}%';

	/// en: '••••••••'
	String get amountHidden => '••••••••';

	/// en: 'Load failed'
	String get loadFailed => 'Load failed';

	/// en: 'No transactions'
	String get noTransactions => 'No transactions';

	/// en: 'Pull to refresh'
	String get tryRefresh => 'Pull to refresh';

	/// en: 'No more data'
	String get noMoreData => 'No more data';

	/// en: 'User not logged in'
	String get userNotLoggedIn => 'User not logged in';
}

// Path: comment
class Translations$comment$en {
	Translations$comment$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Error'
	String get error => 'Error';

	/// en: 'Comment failed'
	String get commentFailed => 'Comment failed';

	/// en: 'Reply to @$name:'
	String replyToPrefix({required Object name}) => 'Reply to @${name}:';

	/// en: 'Reply'
	String get reply => 'Reply';

	/// en: 'Add a note...'
	String get addNote => 'Add a note...';

	/// en: 'Comment or @mention members...'
	String get addNoteWithMention => 'Comment or @mention members...';

	/// en: 'Confirm Delete'
	String get confirmDeleteTitle => 'Confirm Delete';

	/// en: 'Are you sure you want to delete this comment? This action cannot be undone.'
	String get confirmDeleteContent => 'Are you sure you want to delete this comment? This action cannot be undone.';

	/// en: 'Success'
	String get success => 'Success';

	/// en: 'Comment deleted'
	String get commentDeleted => 'Comment deleted';

	/// en: 'Failed to delete'
	String get deleteFailed => 'Failed to delete';

	/// en: 'Delete Comment'
	String get deleteComment => 'Delete Comment';

	/// en: 'Hint'
	String get hint => 'Hint';

	/// en: 'No actions available'
	String get noActions => 'No actions available';

	/// en: 'Note'
	String get note => 'Note';

	/// en: 'No notes yet'
	String get noNote => 'No notes yet';

	/// en: 'Failed to load notes'
	String get loadFailed => 'Failed to load notes';
}

// Path: calendar
class Translations$calendar$en {
	Translations$calendar$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Expense Calendar'
	String get title => 'Expense Calendar';

	late final Translations$calendar$weekdays$en weekdays = Translations$calendar$weekdays$en._(_root);

	/// en: 'Failed to load calendar data'
	String get loadFailed => 'Failed to load calendar data';

	/// en: 'Month: $amount'
	String thisMonth({required Object amount}) => 'Month: ${amount}';

	/// en: 'Counting...'
	String get counting => 'Counting...';

	/// en: 'Unable to count'
	String get unableToCount => 'Unable to count';

	/// en: 'Trend: '
	String get trend => 'Trend: ';

	/// en: 'No transactions on this day'
	String get noTransactionsTitle => 'No transactions on this day';

	/// en: 'Failed to load transactions'
	String get loadTransactionFailed => 'Failed to load transactions';
}

// Path: category
class Translations$category$en {
	Translations$category$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Daily Expenses'
	String get dailyConsumption => 'Daily Expenses';

	/// en: 'Transportation'
	String get transportation => 'Transportation';

	/// en: 'Healthcare'
	String get healthcare => 'Healthcare';

	/// en: 'Housing & Utilities'
	String get housing => 'Housing & Utilities';

	/// en: 'Education'
	String get education => 'Education';

	/// en: 'Income'
	String get incomeCategory => 'Income';

	/// en: 'Gifts & Donations'
	String get socialGifts => 'Gifts & Donations';

	/// en: 'Transfers'
	String get moneyTransfer => 'Transfers';

	/// en: 'Other'
	String get other => 'Other';

	/// en: 'Food & Dining'
	String get foodDining => 'Food & Dining';

	/// en: 'Shopping'
	String get shoppingRetail => 'Shopping';

	/// en: 'Housing & Utilities'
	String get housingUtilities => 'Housing & Utilities';

	/// en: 'Personal Care'
	String get personalCare => 'Personal Care';

	/// en: 'Entertainment'
	String get entertainment => 'Entertainment';

	/// en: 'Medical & Health'
	String get medicalHealth => 'Medical & Health';

	/// en: 'Insurance'
	String get insurance => 'Insurance';

	/// en: 'Social & Gifting'
	String get socialGifting => 'Social & Gifting';

	/// en: 'Financial & Tax'
	String get financialTax => 'Financial & Tax';

	/// en: 'Others'
	String get others => 'Others';

	/// en: 'Salary'
	String get salaryWage => 'Salary';

	/// en: 'Business'
	String get businessTrade => 'Business';

	/// en: 'Investment Returns'
	String get investmentReturns => 'Investment Returns';

	/// en: 'Gift & Bonus'
	String get giftBonus => 'Gift & Bonus';

	/// en: 'Refund'
	String get refundRebate => 'Refund';

	/// en: 'Transfer'
	String get generalTransfer => 'Transfer';

	/// en: 'Debt Repayment'
	String get debtRepayment => 'Debt Repayment';
}

// Path: settings
class Translations$settings$en {
	Translations$settings$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Settings'
	String get title => 'Settings';

	/// en: 'Language'
	String get language => 'Language';

	/// en: 'Language Settings'
	String get languageSettings => 'Language Settings';

	/// en: 'Select Language'
	String get selectLanguage => 'Select Language';

	/// en: 'Language Changed'
	String get languageChanged => 'Language Changed';

	/// en: 'Restart app to apply changes'
	String get restartToApply => 'Restart app to apply changes';

	/// en: 'Theme'
	String get theme => 'Theme';

	/// en: 'Dark Mode'
	String get darkMode => 'Dark Mode';

	/// en: 'Light Mode'
	String get lightMode => 'Light Mode';

	/// en: 'Follow System'
	String get systemMode => 'Follow System';

	/// en: 'Developer Options'
	String get developerOptions => 'Developer Options';

	/// en: 'Auth Debug'
	String get authDebug => 'Auth Debug';

	/// en: 'View authentication status and debug info'
	String get authDebugSubtitle => 'View authentication status and debug info';

	/// en: 'Font Test'
	String get fontTest => 'Font Test';

	/// en: 'Test application font display'
	String get fontTestSubtitle => 'Test application font display';

	/// en: 'Help & Feedback'
	String get helpAndFeedback => 'Help & Feedback';

	/// en: 'Get help or provide feedback'
	String get helpAndFeedbackSubtitle => 'Get help or provide feedback';

	/// en: 'About'
	String get aboutApp => 'About';

	/// en: 'Version info and check for updates'
	String get aboutAppSubtitle => 'Version info and check for updates';

	/// en: 'Check for Updates'
	String get checkUpdate => 'Check for Updates';

	/// en: 'Checking for updates...'
	String get checkingUpdate => 'Checking for updates...';

	/// en: 'You are on the latest version'
	String get latestVersionToast => 'You are on the latest version';

	/// en: 'New Version Available'
	String get newVersionTitle => 'New Version Available';

	/// en: 'Update Now'
	String get updateNow => 'Update Now';

	/// en: 'Later'
	String get updateLater => 'Later';

	/// en: 'Failed to check for updates, please try again later'
	String get fetchUpdateFailed => 'Failed to check for updates, please try again later';

	/// en: 'Switched to $currency. New transactions will use this currency.'
	String currencyChangedRefreshHint({required Object currency}) => 'Switched to ${currency}. New transactions will use this currency.';

	/// en: 'Shared Space'
	String get sharedSpace => 'Shared Space';

	/// en: 'Speech Recognition'
	String get speechRecognition => 'Speech Recognition';

	/// en: 'Configure voice input parameters'
	String get speechRecognitionSubtitle => 'Configure voice input parameters';

	/// en: 'Amount Display Style'
	String get amountDisplayStyle => 'Amount Display Style';

	/// en: 'Currency'
	String get currency => 'Currency';

	/// en: 'Appearance Settings'
	String get appearance => 'Appearance Settings';

	/// en: 'Theme mode and color scheme'
	String get appearanceSubtitle => 'Theme mode and color scheme';

	/// en: 'Speech Test'
	String get speechTest => 'Speech Test';

	/// en: 'Test WebSocket speech connection'
	String get speechTestSubtitle => 'Test WebSocket speech connection';

	/// en: 'Regular User'
	String get userTypeRegular => 'Regular User';

	/// en: 'Select Amount Display Style'
	String get selectAmountStyle => 'Select Amount Display Style';

	/// en: 'Note: Amount styles are primarily applied to 'Transactions' and 'Trends'. To maintain visual clarity, 'Account Balances' and 'Asset Summaries' will remain in neutral colors.'
	String get amountStyleNotice => 'Note: Amount styles are primarily applied to \'Transactions\' and \'Trends\'. To maintain visual clarity, \'Account Balances\' and \'Asset Summaries\' will remain in neutral colors.';

	/// en: 'Choose your preferred display currency. All amounts will be displayed in this currency.'
	String get currencyDescription => 'Choose your preferred display currency. All amounts will be displayed in this currency.';

	/// en: 'Edit Username'
	String get editUsername => 'Edit Username';

	/// en: 'Enter username'
	String get enterUsername => 'Enter username';

	/// en: 'Username is required'
	String get usernameRequired => 'Username is required';

	/// en: 'Username updated'
	String get usernameUpdated => 'Username updated';

	/// en: 'Avatar updated'
	String get avatarUpdated => 'Avatar updated';

	/// en: '外观设置已更新'
	String get appearanceUpdated => '外观设置已更新';
}

// Path: appearance
class Translations$appearance$en {
	Translations$appearance$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Appearance Settings'
	String get title => 'Appearance Settings';

	/// en: 'Theme Mode'
	String get themeMode => 'Theme Mode';

	/// en: 'Light'
	String get light => 'Light';

	/// en: 'Dark'
	String get dark => 'Dark';

	/// en: 'System'
	String get system => 'System';

	/// en: 'Color Scheme'
	String get colorScheme => 'Color Scheme';

	late final Translations$appearance$palettes$en palettes = Translations$appearance$palettes$en._(_root);
}

// Path: speech
class Translations$speech$en {
	Translations$speech$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Speech Recognition Settings'
	String get title => 'Speech Recognition Settings';

	/// en: 'Speech Recognition Service'
	String get service => 'Speech Recognition Service';

	/// en: 'System Voice'
	String get systemVoice => 'System Voice';

	/// en: 'Use built-in device service (Recommended)'
	String get systemVoiceSubtitle => 'Use built-in device service (Recommended)';

	/// en: 'Self-hosted ASR'
	String get selfHostedASR => 'Self-hosted ASR';

	/// en: 'Use WebSocket connection to self-hosted service'
	String get selfHostedASRSubtitle => 'Use WebSocket connection to self-hosted service';

	/// en: 'Server Configuration'
	String get serverConfig => 'Server Configuration';

	/// en: 'Server Address'
	String get serverAddress => 'Server Address';

	/// en: 'Port'
	String get port => 'Port';

	/// en: 'Path'
	String get path => 'Path';

	/// en: 'Save Configuration'
	String get saveConfig => 'Save Configuration';

	/// en: 'Information'
	String get info => 'Information';

	/// en: '• System Voice: Uses device service, no config needed, faster response • Self-hosted ASR: Suitable for custom models or offline scenarios Changes will take effect next time you use voice input.'
	String get infoContent => '• System Voice: Uses device service, no config needed, faster response\n• Self-hosted ASR: Suitable for custom models or offline scenarios\n\nChanges will take effect next time you use voice input.';

	/// en: 'Please enter server address'
	String get enterAddress => 'Please enter server address';

	/// en: 'Please enter a valid port (1-65535)'
	String get enterValidPort => 'Please enter a valid port (1-65535)';

	/// en: 'Configuration saved'
	String get configSaved => 'Configuration saved';

	/// en: 'System Speech Unavailable'
	String get systemVoiceRestrictedTitle => 'System Speech Unavailable';

	/// en: 'System speech service is unavailable or disabled. You can check system settings or configure a custom WebSocket ASR in Speech Settings.'
	String get systemVoiceRestrictedContent => 'System speech service is unavailable or disabled. You can check system settings or configure a custom WebSocket ASR in Speech Settings.';

	/// en: 'Dictation Disabled'
	String get dictationDisabledTitle => 'Dictation Disabled';

	/// en: 'System speech dictation service is disabled. On iOS devices, please go to Settings -> General -> Keyboard and enable Dictation.'
	String get dictationDisabledContent => 'System speech dictation service is disabled. On iOS devices, please go to Settings -> General -> Keyboard and enable Dictation.';

	/// en: 'Permissions Required'
	String get permissionDeniedTitle => 'Permissions Required';

	/// en: 'Microphone and speech recognition permissions are required for this feature. Please grant them in System Settings.'
	String get permissionDeniedContent => 'Microphone and speech recognition permissions are required for this feature. Please grant them in System Settings.';

	/// en: 'Go to Settings'
	String get goToSettings => 'Go to Settings';

	/// en: 'System Speech Supported'
	String get systemVoiceStatusAvailable => 'System Speech Supported';

	/// en: 'System Speech Restricted or Unavailable (Self-hosted ASR recommended)'
	String get systemVoiceStatusRestricted => 'System Speech Restricted or Unavailable (Self-hosted ASR recommended)';

	/// en: 'Speech service is not configured. Please set the server address in Speech Settings.'
	String get serviceNotConfigured => 'Speech service is not configured. Please set the server address in Speech Settings.';

	/// en: 'Speech Service Connection Failed'
	String get connectionFailedTitle => 'Speech Service Connection Failed';

	/// en: 'Cannot connect to WebSocket speech recognition service. Please check your server address, port, or network connectivity.'
	String get connectionFailed => 'Cannot connect to WebSocket speech recognition service. Please check your server address, port, or network connectivity.';

	/// en: 'No speech input detected, please try again.'
	String get noSpeechRecognized => 'No speech input detected, please try again.';
}

// Path: amountTheme
class Translations$amountTheme$en {
	Translations$amountTheme$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'China Market Style'
	String get chinaMarket => 'China Market Style';

	/// en: 'Red up, Green/Black down (Recommended)'
	String get chinaMarketDesc => 'Red up, Green/Black down (Recommended)';

	/// en: 'International Standard'
	String get international => 'International Standard';

	/// en: 'Green up, Red down'
	String get internationalDesc => 'Green up, Red down';

	/// en: 'Minimalist'
	String get minimalist => 'Minimalist';

	/// en: 'Distinguish with symbols only'
	String get minimalistDesc => 'Distinguish with symbols only';

	/// en: 'Color Blind Friendly'
	String get colorBlind => 'Color Blind Friendly';

	/// en: 'Blue-Orange color scheme'
	String get colorBlindDesc => 'Blue-Orange color scheme';
}

// Path: locale
class Translations$locale$en {
	Translations$locale$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Simplified Chinese'
	String get chinese => 'Simplified Chinese';

	/// en: 'English'
	String get english => 'English';

	/// en: 'Japanese'
	String get japanese => 'Japanese';

	/// en: 'Korean'
	String get korean => 'Korean';

	/// en: 'Traditional Chinese'
	String get traditionalChinese => 'Traditional Chinese';
}

// Path: budget
class Translations$budget$en {
	Translations$budget$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Budget Management'
	String get title => 'Budget Management';

	/// en: 'Budget Details'
	String get detail => 'Budget Details';

	/// en: 'Budget Info'
	String get info => 'Budget Info';

	/// en: 'Total Budget'
	String get totalBudget => 'Total Budget';

	/// en: 'Category Budget'
	String get categoryBudget => 'Category Budget';

	/// en: 'Monthly Budget Summary'
	String get monthlySummary => 'Monthly Budget Summary';

	/// en: 'Used'
	String get used => 'Used';

	/// en: 'Remaining'
	String get remaining => 'Remaining';

	/// en: 'Overspent'
	String get overspent => 'Overspent';

	/// en: 'Budget'
	String get budget => 'Budget';

	/// en: 'Failed to load'
	String get loadFailed => 'Failed to load';

	/// en: 'No budgets yet'
	String get noBudget => 'No budgets yet';

	/// en: 'Tap the button below to set up your budget'
	String get createHint => 'Tap the button below to set up your budget';

	/// en: 'Paused'
	String get paused => 'Paused';

	/// en: 'Pause'
	String get pause => 'Pause';

	/// en: 'Resume'
	String get resume => 'Resume';

	/// en: 'Budget paused'
	String get budgetPaused => 'Budget paused';

	/// en: 'Budget resumed'
	String get budgetResumed => 'Budget resumed';

	/// en: 'Operation failed'
	String get operationFailed => 'Operation failed';

	/// en: 'Delete Budget'
	String get deleteBudget => 'Delete Budget';

	/// en: 'Are you sure you want to delete this budget? This cannot be undone.'
	String get deleteConfirm => 'Are you sure you want to delete this budget? This cannot be undone.';

	/// en: 'Type'
	String get type => 'Type';

	/// en: 'Category'
	String get category => 'Category';

	/// en: 'Repeat Rule'
	String get period => 'Repeat Rule';

	/// en: 'Rollover'
	String get rollover => 'Rollover';

	/// en: 'Rollover Balance'
	String get rolloverBalance => 'Rollover Balance';

	/// en: 'Enabled'
	String get enabled => 'Enabled';

	/// en: 'Disabled'
	String get disabled => 'Disabled';

	/// en: 'On Track'
	String get statusNormal => 'On Track';

	/// en: 'Near Limit'
	String get statusWarning => 'Near Limit';

	/// en: 'Overspent'
	String get statusOverspent => 'Overspent';

	/// en: 'Goal Achieved'
	String get statusAchieved => 'Goal Achieved';

	/// en: '$amount remaining'
	String tipNormal({required Object amount}) => '${amount} remaining';

	/// en: 'Only $amount left, be careful'
	String tipWarning({required Object amount}) => 'Only ${amount} left, be careful';

	/// en: 'Overspent by $amount'
	String tipOverspent({required Object amount}) => 'Overspent by ${amount}';

	/// en: 'Congratulations on achieving your savings goal!'
	String get tipAchieved => 'Congratulations on achieving your savings goal!';

	/// en: '$amount remaining'
	String remainingAmount({required Object amount}) => '${amount} remaining';

	/// en: 'Overspent $amount'
	String overspentAmount({required Object amount}) => 'Overspent ${amount}';

	/// en: 'Budget $amount'
	String budgetAmount({required Object amount}) => 'Budget ${amount}';

	/// en: 'Active'
	String get active => 'Active';

	/// en: 'All'
	String get all => 'All';

	/// en: 'Budget not found or deleted'
	String get notFound => 'Budget not found or deleted';

	/// en: 'Budget Setup'
	String get setup => 'Budget Setup';

	/// en: 'Budget Settings'
	String get settings => 'Budget Settings';

	/// en: 'Set Budget Amount'
	String get setAmount => 'Set Budget Amount';

	/// en: 'Set budget amount for each category'
	String get setAmountDesc => 'Set budget amount for each category';

	/// en: 'Monthly Budget'
	String get monthly => 'Monthly Budget';

	/// en: 'Manage expenses monthly, suitable for most users'
	String get monthlyDesc => 'Manage expenses monthly, suitable for most users';

	/// en: 'Weekly Budget'
	String get weekly => 'Weekly Budget';

	/// en: 'Manage expenses weekly for finer control'
	String get weeklyDesc => 'Manage expenses weekly for finer control';

	/// en: 'Annual Budget'
	String get yearly => 'Annual Budget';

	/// en: 'Long-term financial planning for major expenses'
	String get yearlyDesc => 'Long-term financial planning for major expenses';

	/// en: 'Edit Budget'
	String get editBudget => 'Edit Budget';

	/// en: 'Modify budget amounts and categories'
	String get editBudgetDesc => 'Modify budget amounts and categories';

	/// en: 'Reminder Settings'
	String get reminderSettings => 'Reminder Settings';

	/// en: 'Set budget reminders and notifications'
	String get reminderSettingsDesc => 'Set budget reminders and notifications';

	/// en: 'Budget Report'
	String get report => 'Budget Report';

	/// en: 'View detailed budget analysis reports'
	String get reportDesc => 'View detailed budget analysis reports';

	/// en: 'Welcome to Budget Feature!'
	String get welcome => 'Welcome to Budget Feature!';

	/// en: 'Create New Budget Plan'
	String get createNewPlan => 'Create New Budget Plan';

	/// en: 'Set budgets to better control spending and achieve financial goals. Let's start setting up your first budget plan!'
	String get welcomeDesc => 'Set budgets to better control spending and achieve financial goals. Let\'s start setting up your first budget plan!';

	/// en: 'Set budget limits for different spending categories to manage your finances better.'
	String get createDesc => 'Set budget limits for different spending categories to manage your finances better.';

	/// en: 'New Budget'
	String get newBudget => 'New Budget';

	/// en: 'Budget Amount'
	String get budgetAmountLabel => 'Budget Amount';

	/// en: 'Currency'
	String get currency => 'Currency';

	/// en: 'Period Settings'
	String get periodSettings => 'Period Settings';

	/// en: 'Automatically generate transactions by rule'
	String get autoGenerateTransactions => 'Automatically generate transactions by rule';

	/// en: 'Cycle'
	String get cycle => 'Cycle';

	/// en: 'Budget Category'
	String get budgetCategory => 'Budget Category';

	/// en: 'Advanced Options'
	String get advancedOptions => 'Advanced Options';

	/// en: 'Period Type'
	String get periodType => 'Period Type';

	/// en: 'Anchor Day'
	String get anchorDay => 'Anchor Day';

	/// en: 'Select Period Type'
	String get selectPeriodType => 'Select Period Type';

	/// en: 'Select Anchor Day'
	String get selectAnchorDay => 'Select Anchor Day';

	/// en: 'Carry over unused budget to next period'
	String get rolloverDescription => 'Carry over unused budget to next period';

	/// en: 'Create Budget'
	String get createBudget => 'Create Budget';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Please enter budget amount'
	String get pleaseEnterAmount => 'Please enter budget amount';

	/// en: 'Please enter a valid amount'
	String get invalidAmount => 'Please enter a valid amount';

	/// en: 'Budget updated successfully'
	String get updateSuccess => 'Budget updated successfully';

	/// en: 'Budget created successfully'
	String get createSuccess => 'Budget created successfully';

	/// en: 'Budget deleted'
	String get deleteSuccess => 'Budget deleted';

	/// en: 'Delete failed'
	String get deleteFailed => 'Delete failed';

	/// en: 'Day $day of each month'
	String everyMonthDay({required Object day}) => 'Day ${day} of each month';

	/// en: 'Weekly'
	String get periodWeekly => 'Weekly';

	/// en: 'Biweekly'
	String get periodBiweekly => 'Biweekly';

	/// en: 'Monthly'
	String get periodMonthly => 'Monthly';

	/// en: 'Yearly'
	String get periodYearly => 'Yearly';

	/// en: 'Active'
	String get statusActive => 'Active';

	/// en: 'Archived'
	String get statusArchived => 'Archived';

	/// en: 'On Track'
	String get periodStatusOnTrack => 'On Track';

	/// en: 'Warning'
	String get periodStatusWarning => 'Warning';

	/// en: 'Exceeded'
	String get periodStatusExceeded => 'Exceeded';

	/// en: 'Achieved'
	String get periodStatusAchieved => 'Achieved';

	/// en: '$percent% used'
	String usedPercent({required Object percent}) => '${percent}% used';

	/// en: 'Day $day'
	String dayOfMonth({required Object day}) => 'Day ${day}';

	/// en: '0k'
	String get tenThousandSuffix => '0k';

	/// en: 'Failed to load settings'
	String get settingsLoadFailed => 'Failed to load settings';

	/// en: 'Settings saved'
	String get settingsSaveSuccess => 'Settings saved';

	/// en: 'Failed to save'
	String get settingsSaveFailed => 'Failed to save';

	/// en: 'Save Settings'
	String get settingsSave => 'Save Settings';

	/// en: 'Warning Threshold'
	String get settingsWarningThreshold => 'Warning Threshold';

	/// en: 'Shows warning status when usage reaches this percentage'
	String get settingsWarningDesc => 'Shows warning status when usage reaches this percentage';

	/// en: 'Alert Threshold'
	String get settingsAlertThreshold => 'Alert Threshold';

	/// en: 'Shows exceeded status when usage reaches this percentage'
	String get settingsAlertDesc => 'Shows exceeded status when usage reaches this percentage';

	/// en: 'Warning threshold cannot exceed alert threshold'
	String get settingsThresholdOrder => 'Warning threshold cannot exceed alert threshold';
}

// Path: dateRange
class Translations$dateRange$en {
	Translations$dateRange$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Custom'
	String get custom => 'Custom';

	/// en: 'Select Date Range'
	String get pickerTitle => 'Select Date Range';

	/// en: 'Start Date'
	String get startDate => 'Start Date';

	/// en: 'End Date'
	String get endDate => 'End Date';

	/// en: 'Please select a date range'
	String get hint => 'Please select a date range';
}

// Path: forecast
class Translations$forecast$en {
	Translations$forecast$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Forecast'
	String get title => 'Forecast';

	/// en: 'AI-powered cash flow predictions based on your financial data'
	String get subtitle => 'AI-powered cash flow predictions based on your financial data';

	/// en: 'Hello, I'm your Financial Navigator'
	String get financialNavigator => 'Hello, I\'m your Financial Navigator';

	/// en: 'In just 3 steps, let's map your financial future together'
	String get financialMapSubtitle => 'In just 3 steps, let\'s map your financial future together';

	/// en: 'Predict Cash Flow'
	String get predictCashFlow => 'Predict Cash Flow';

	/// en: 'See your daily financial status'
	String get predictCashFlowDesc => 'See your daily financial status';

	/// en: 'AI Smart Suggestions'
	String get aiSmartSuggestions => 'AI Smart Suggestions';

	/// en: 'Personalized financial decision guidance'
	String get aiSmartSuggestionsDesc => 'Personalized financial decision guidance';

	/// en: 'Risk Alerts'
	String get riskWarning => 'Risk Alerts';

	/// en: 'Detect potential financial risks early'
	String get riskWarningDesc => 'Detect potential financial risks early';

	/// en: 'Analyzing your financial data to generate a 30-day cash flow forecast'
	String get analyzing => 'Analyzing your financial data to generate a 30-day cash flow forecast';

	/// en: 'Analyzing income & expense patterns'
	String get analyzePattern => 'Analyzing income & expense patterns';

	/// en: 'Calculating cash flow trends'
	String get calculateTrend => 'Calculating cash flow trends';

	/// en: 'Generating risk alerts'
	String get generateWarning => 'Generating risk alerts';

	/// en: 'Loading financial forecast...'
	String get loadingForecast => 'Loading financial forecast...';

	/// en: 'Today'
	String get todayLabel => 'Today';

	/// en: 'Tomorrow'
	String get tomorrowLabel => 'Tomorrow';

	/// en: 'Balance'
	String get balanceLabel => 'Balance';

	/// en: 'No special events'
	String get noSpecialEvents => 'No special events';

	/// en: 'Financial Safety Net'
	String get financialSafetyLine => 'Financial Safety Net';

	/// en: 'Current Setting'
	String get currentSetting => 'Current Setting';

	/// en: 'Daily Spending Estimate'
	String get dailySpendingEstimate => 'Daily Spending Estimate';

	/// en: 'Adjust daily spending forecast amount'
	String get adjustDailySpendingAmount => 'Adjust daily spending forecast amount';

	/// en: 'What's your financial safety threshold?'
	String get tellMeYourSafetyLine => 'What\'s your financial safety threshold?';

	/// en: 'This is the minimum balance you want to maintain. I'll alert you when your balance approaches this amount.'
	String get safetyLineDescription => 'This is the minimum balance you want to maintain. I\'ll alert you when your balance approaches this amount.';

	/// en: 'How much do you spend daily?'
	String get dailySpendingQuestion => 'How much do you spend daily?';

	/// en: 'Including meals, transportation, shopping and other daily expenses This is just an initial estimate - predictions will improve with your actual records'
	String get dailySpendingDescription => 'Including meals, transportation, shopping and other daily expenses\nThis is just an initial estimate - predictions will improve with your actual records';

	/// en: 'per day'
	String get perDay => 'per day';

	/// en: 'Reference'
	String get referenceStandard => 'Reference';

	/// en: 'Frugal'
	String get frugalType => 'Frugal';

	/// en: 'Comfortable'
	String get comfortableType => 'Comfortable';

	/// en: 'Relaxed'
	String get relaxedType => 'Relaxed';

	/// en: '¥50-100/day'
	String get frugalAmount => '¥50-100/day';

	/// en: '¥100-200/day'
	String get comfortableAmount => '¥100-200/day';

	/// en: '¥200-300/day'
	String get relaxedAmount => '¥200-300/day';

	late final Translations$forecast$recurringTransaction$en recurringTransaction = Translations$forecast$recurringTransaction$en._(_root);
}

// Path: chat
class Translations$chat$en {
	Translations$chat$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'New Chat'
	String get newChat => 'New Chat';

	/// en: 'No messages to display.'
	String get noMessages => 'No messages to display.';

	/// en: 'Loading failed'
	String get loadingFailed => 'Loading failed';

	/// en: 'Type a message...'
	String get inputMessage => 'Type a message...';

	/// en: 'AI processing...'
	String get aiThinking => 'AI processing...';

	/// en: 'Listening...'
	String get listening => 'Listening...';

	late final Translations$chat$tools$en tools = Translations$chat$tools$en._(_root);

	/// en: 'Speech not recognized, please try again'
	String get speechNotRecognized => 'Speech not recognized, please try again';

	/// en: 'Session Expense'
	String get currentExpense => 'Session Expense';

	/// en: 'Loading component...'
	String get loadingComponent => 'Loading component...';

	/// en: 'No historical sessions'
	String get noHistory => 'No historical sessions';

	/// en: 'Start a new conversation!'
	String get startNewChat => 'Start a new conversation!';

	/// en: 'Search conversations'
	String get searchHint => 'Search conversations';

	/// en: 'Library'
	String get library => 'Library';

	/// en: 'View profile'
	String get viewProfile => 'View profile';

	/// en: 'No related conversations found'
	String get noRelatedFound => 'No related conversations found';

	/// en: 'Try searching with other keywords'
	String get tryOtherKeywords => 'Try searching with other keywords';

	/// en: 'Search failed'
	String get searchFailed => 'Search failed';

	/// en: 'Delete Conversation'
	String get deleteConversation => 'Delete Conversation';

	/// en: 'Are you sure you want to delete this conversation? This action cannot be undone.'
	String get deleteConversationConfirm => 'Are you sure you want to delete this conversation? This action cannot be undone.';

	/// en: 'Conversation deleted'
	String get conversationDeleted => 'Conversation deleted';

	/// en: 'Failed to delete conversation'
	String get deleteConversationFailed => 'Failed to delete conversation';

	late final Translations$chat$transferWizard$en transferWizard = Translations$chat$transferWizard$en._(_root);
	late final Translations$chat$genui$en genui = Translations$chat$genui$en._(_root);
	late final Translations$chat$welcome$en welcome = Translations$chat$welcome$en._(_root);
}

// Path: footprint
class Translations$footprint$en {
	Translations$footprint$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Search'
	String get searchIn => 'Search';

	/// en: 'Search in all records'
	String get searchInAllRecords => 'Search in all records';
}

// Path: media
class Translations$media$en {
	Translations$media$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Select Photos'
	String get selectPhotos => 'Select Photos';

	/// en: 'Add Files'
	String get addFiles => 'Add Files';

	/// en: 'Take Photo'
	String get takePhoto => 'Take Photo';

	/// en: 'Camera'
	String get camera => 'Camera';

	/// en: 'Photos'
	String get photos => 'Photos';

	/// en: 'Files'
	String get files => 'Files';

	/// en: 'Show All'
	String get showAll => 'Show All';

	/// en: 'All Photos'
	String get allPhotos => 'All Photos';

	/// en: 'Taking photo...'
	String get takingPhoto => 'Taking photo...';

	/// en: 'Photo saved'
	String get photoTaken => 'Photo saved';

	/// en: 'Camera permission required'
	String get cameraPermissionRequired => 'Camera permission required';

	/// en: 'File size exceeds 10MB limit'
	String get fileSizeExceeded => 'File size exceeds 10MB limit';

	/// en: 'Unsupported file format'
	String get unsupportedFormat => 'Unsupported file format';

	/// en: 'Photo library access required'
	String get permissionDenied => 'Photo library access required';

	/// en: 'Insufficient storage space'
	String get storageInsufficient => 'Insufficient storage space';

	/// en: 'Network connection error'
	String get networkError => 'Network connection error';

	/// en: 'Unknown error during upload'
	String get unknownUploadError => 'Unknown error during upload';
}

// Path: error
class Translations$error$en {
	Translations$error$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Permission Required'
	String get permissionRequired => 'Permission Required';

	/// en: 'Please enable photo library and storage permissions in Settings to select and upload files.'
	String get permissionInstructions => 'Please enable photo library and storage permissions in Settings to select and upload files.';

	/// en: 'Open Settings'
	String get openSettings => 'Open Settings';

	/// en: 'File Too Large'
	String get fileTooLarge => 'File Too Large';

	/// en: 'Please select files under 10MB, or compress before uploading.'
	String get fileSizeHint => 'Please select files under 10MB, or compress before uploading.';

	/// en: 'Supported formats: images (jpg, png, gif), documents (pdf, doc, txt), audio/video files.'
	String get supportedFormatsHint => 'Supported formats: images (jpg, png, gif), documents (pdf, doc, txt), audio/video files.';

	/// en: 'Please free up storage space and try again, or select smaller files.'
	String get storageCleanupHint => 'Please free up storage space and try again, or select smaller files.';

	/// en: 'Please check your network connection and try again.'
	String get networkErrorHint => 'Please check your network connection and try again.';

	/// en: 'Platform Not Supported'
	String get platformNotSupported => 'Platform Not Supported';

	/// en: 'File Read Error'
	String get fileReadError => 'File Read Error';

	/// en: 'The file may be corrupted or in use. Please select a different file.'
	String get fileReadErrorHint => 'The file may be corrupted or in use. Please select a different file.';

	/// en: 'File Validation Error'
	String get validationError => 'File Validation Error';

	/// en: 'Unknown Error'
	String get unknownError => 'Unknown Error';

	/// en: 'An unexpected error occurred. Please try again or contact support.'
	String get unknownErrorHint => 'An unexpected error occurred. Please try again or contact support.';

	/// en: 'Registration flow error, missing required information.'
	String get registrationMissingInfo => 'Registration flow error, missing required information.';

	late final Translations$error$genui$en genui = Translations$error$genui$en._(_root);
}

// Path: fontTest
class Translations$fontTest$en {
	Translations$fontTest$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Font Test Page'
	String get page => 'Font Test Page';

	/// en: 'Font Display Test'
	String get displayTest => 'Font Display Test';

	/// en: 'Chinese Text Test'
	String get chineseTextTest => 'Chinese Text Test';

	/// en: 'English Text Test'
	String get englishTextTest => 'English Text Test';

	/// en: 'This is a sample text for testing font display effects.'
	String get sample1 => 'This is a sample text for testing font display effects.';

	/// en: 'Expense category summary, shopping is highest'
	String get sample2 => 'Expense category summary, shopping is highest';

	/// en: 'AI assistant provides professional financial analysis services'
	String get sample3 => 'AI assistant provides professional financial analysis services';

	/// en: 'Data visualization charts show your spending trends'
	String get sample4 => 'Data visualization charts show your spending trends';

	/// en: 'WeChat Pay, Alipay, bank cards and other payment methods'
	String get sample5 => 'WeChat Pay, Alipay, bank cards and other payment methods';
}

// Path: wizard
class Translations$wizard$en {
	Translations$wizard$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Next'
	String get nextStep => 'Next';

	/// en: 'Previous'
	String get previousStep => 'Previous';

	/// en: 'Complete'
	String get completeMapping => 'Complete';
}

// Path: user
class Translations$user$en {
	Translations$user$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Username'
	String get username => 'Username';

	/// en: 'user@example.com'
	String get defaultEmail => 'user@example.com';
}

// Path: account
class Translations$account$en {
	Translations$account$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Edit Account'
	String get editTitle => 'Edit Account';

	/// en: 'New Account'
	String get addTitle => 'New Account';

	/// en: 'Select Account Type'
	String get selectTypeTitle => 'Select Account Type';

	/// en: 'Account Name'
	String get nameLabel => 'Account Name';

	/// en: 'Current Balance'
	String get amountLabel => 'Current Balance';

	/// en: 'Currency'
	String get currencyLabel => 'Currency';

	/// en: 'Hidden'
	String get hiddenLabel => 'Hidden';

	/// en: 'Hide this account from the list'
	String get hiddenDesc => 'Hide this account from the list';

	/// en: 'Include in Net Worth'
	String get includeInNetWorthLabel => 'Include in Net Worth';

	/// en: 'Count towards total net worth'
	String get includeInNetWorthDesc => 'Count towards total net worth';

	/// en: 'e.g. Salary Card'
	String get nameHint => 'e.g. Salary Card';

	/// en: '0.00'
	String get amountHint => '0.00';

	/// en: 'Delete Account'
	String get deleteAccount => 'Delete Account';

	/// en: 'Are you sure you want to delete this account? This cannot be undone.'
	String get deleteConfirm => 'Are you sure you want to delete this account? This cannot be undone.';

	/// en: 'Save Changes'
	String get save => 'Save Changes';

	/// en: 'Assets'
	String get assetsCategory => 'Assets';

	/// en: 'Liabilities/Credit'
	String get liabilitiesCategory => 'Liabilities/Credit';

	/// en: 'Cash Wallet'
	String get cash => 'Cash Wallet';

	/// en: 'Bank Deposit'
	String get deposit => 'Bank Deposit';

	/// en: 'Credit Card'
	String get creditCard => 'Credit Card';

	/// en: 'Investment'
	String get investment => 'Investment';

	/// en: 'E-Wallet'
	String get eWallet => 'E-Wallet';

	/// en: 'Loan'
	String get loan => 'Loan';

	/// en: 'Receivable'
	String get receivable => 'Receivable';

	/// en: 'Payable'
	String get payable => 'Payable';

	/// en: 'Other'
	String get other => 'Other';

	late final Translations$account$types$en types = Translations$account$types$en._(_root);
}

// Path: financial
class Translations$financial$en {
	Translations$financial$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Financial'
	String get title => 'Financial';

	/// en: 'Financial Management'
	String get management => 'Financial Management';

	/// en: 'Total Net Worth'
	String get netWorth => 'Total Net Worth';

	/// en: 'Total Assets'
	String get assets => 'Total Assets';

	/// en: 'Total Liabilities'
	String get liabilities => 'Total Liabilities';

	/// en: 'No accounts yet'
	String get noAccounts => 'No accounts yet';

	/// en: 'Tap the button below to add your first account'
	String get addFirstAccount => 'Tap the button below to add your first account';

	/// en: 'Asset Accounts'
	String get assetAccounts => 'Asset Accounts';

	/// en: 'Liability Accounts'
	String get liabilityAccounts => 'Liability Accounts';

	/// en: 'Select Currency'
	String get selectCurrency => 'Select Currency';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Confirm'
	String get confirm => 'Confirm';

	/// en: 'Financial Settings'
	String get settings => 'Financial Settings';

	/// en: 'Budget Management'
	String get budgetManagement => 'Budget Management';

	/// en: 'Recurring Transactions'
	String get recurringTransactions => 'Recurring Transactions';

	/// en: 'Safety Threshold'
	String get safetyThreshold => 'Safety Threshold';

	/// en: 'Daily Burn Rate'
	String get dailyBurnRate => 'Daily Burn Rate';

	/// en: 'Financial Assistant'
	String get financialAssistant => 'Financial Assistant';

	/// en: 'Manage your financial settings'
	String get manageFinancialSettings => 'Manage your financial settings';

	/// en: 'Safety Threshold Settings'
	String get safetyThresholdSettings => 'Safety Threshold Settings';

	/// en: 'Set your financial safety threshold'
	String get setSafetyThreshold => 'Set your financial safety threshold';

	/// en: 'Safety threshold saved'
	String get safetyThresholdSaved => 'Safety threshold saved';

	/// en: 'Daily Burn Rate'
	String get dailyBurnRateSettings => 'Daily Burn Rate';

	/// en: 'Set your estimated daily spending'
	String get setDailyBurnRate => 'Set your estimated daily spending';

	/// en: 'Daily burn rate saved'
	String get dailyBurnRateSaved => 'Daily burn rate saved';

	/// en: 'day'
	String get dayUnit => 'day';

	/// en: 'Save failed'
	String get saveFailed => 'Save failed';
}

// Path: app
class Translations$app$en {
	Translations$app$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Finvo: Intelligence that Grows.'
	String get splashTitle => 'Finvo: Intelligence that Grows.';

	/// en: 'Smart Financial Assistant'
	String get splashSubtitle => 'Smart Financial Assistant';
}

// Path: statistics
class Translations$statistics$en {
	Translations$statistics$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Analysis'
	String get title => 'Analysis';

	/// en: 'Analysis'
	String get analyze => 'Analysis';

	/// en: 'Export feature coming soon...'
	String get exportInProgress => 'Export feature coming soon...';

	/// en: 'Top Spending'
	String get ranking => 'Top Spending';

	/// en: 'No data available'
	String get noData => 'No data available';

	late final Translations$statistics$overview$en overview = Translations$statistics$overview$en._(_root);
	late final Translations$statistics$trend$en trend = Translations$statistics$trend$en._(_root);
	late final Translations$statistics$analysis$en analysis = Translations$statistics$analysis$en._(_root);
	late final Translations$statistics$filter$en filter = Translations$statistics$filter$en._(_root);
	late final Translations$statistics$sort$en sort = Translations$statistics$sort$en._(_root);

	/// en: 'Export List'
	String get exportList => 'Export List';

	late final Translations$statistics$emptyState$en emptyState = Translations$statistics$emptyState$en._(_root);

	/// en: 'No more data'
	String get noMoreData => 'No more data';
}

// Path: currency
class Translations$currency$en {
	Translations$currency$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Chinese Yuan'
	String get cny => 'Chinese Yuan';

	/// en: 'US Dollar'
	String get usd => 'US Dollar';

	/// en: 'Euro'
	String get eur => 'Euro';

	/// en: 'Japanese Yen'
	String get jpy => 'Japanese Yen';

	/// en: 'British Pound'
	String get gbp => 'British Pound';

	/// en: 'Australian Dollar'
	String get aud => 'Australian Dollar';

	/// en: 'Canadian Dollar'
	String get cad => 'Canadian Dollar';

	/// en: 'Swiss Franc'
	String get chf => 'Swiss Franc';

	/// en: 'Russian Ruble'
	String get rub => 'Russian Ruble';

	/// en: 'Hong Kong Dollar'
	String get hkd => 'Hong Kong Dollar';

	/// en: 'New Taiwan Dollar'
	String get twd => 'New Taiwan Dollar';

	/// en: 'Indian Rupee'
	String get inr => 'Indian Rupee';
}

// Path: budgetSuggestion
class Translations$budgetSuggestion$en {
	Translations$budgetSuggestion$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '$category accounts for $percentage% of spending. Consider setting a budget limit.'
	String highPercentage({required Object category, required Object percentage}) => '${category} accounts for ${percentage}% of spending. Consider setting a budget limit.';

	/// en: 'Spending increased by $percentage% this month. Needs attention.'
	String monthlyIncrease({required Object percentage}) => 'Spending increased by ${percentage}% this month. Needs attention.';

	/// en: '$category has $count small transactions. These might be subscriptions.'
	String frequentSmall({required Object category, required Object count}) => '${category} has ${count} small transactions. These might be subscriptions.';

	/// en: 'Financial Insights'
	String get financialInsights => 'Financial Insights';
}

// Path: server
class Translations$server$en {
	Translations$server$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Connect to Server'
	String get title => 'Connect to Server';

	/// en: 'Enter your self-hosted server address or scan the QR code displayed when starting the server'
	String get subtitle => 'Enter your self-hosted server address or scan the QR code displayed when starting the server';

	/// en: 'Server Address'
	String get urlLabel => 'Server Address';

	/// en: 'e.g. https://api.example.com or 192.168.1.100:8000'
	String get urlPlaceholder => 'e.g. https://api.example.com or 192.168.1.100:8000';

	/// en: 'Scan QR Code'
	String get scanQr => 'Scan QR Code';

	/// en: 'Point at the QR code displayed in the server terminal'
	String get scanQrInstruction => 'Point at the QR code displayed in the server terminal';

	/// en: 'Test Connection'
	String get testConnection => 'Test Connection';

	/// en: 'Connecting...'
	String get connecting => 'Connecting...';

	/// en: 'Connected'
	String get connected => 'Connected';

	/// en: 'Connection Failed'
	String get connectionFailed => 'Connection Failed';

	/// en: 'Continue to Login'
	String get continueToLogin => 'Continue to Login';

	/// en: 'Save and Return'
	String get saveAndReturn => 'Save and Return';

	/// en: 'Save and Re-login'
	String get saveAndReLogin => 'Save and Re-login';

	/// en: 'Server configuration updated, please log in again'
	String get serverUrlSavedRedirectLogin => 'Server configuration updated, please log in again';

	/// en: 'Server Settings'
	String get serverSettings => 'Server Settings';

	/// en: 'Current Server'
	String get currentServer => 'Current Server';

	/// en: 'Version'
	String get version => 'Version';

	/// en: 'Environment'
	String get environment => 'Environment';

	/// en: 'Change Server'
	String get changeServer => 'Change Server';

	/// en: 'Changing server will log you out. Continue?'
	String get changeServerWarning => 'Changing server will log you out. Continue?';

	late final Translations$server$error$en error = Translations$server$error$en._(_root);
}

// Path: sharedSpace
class Translations$sharedSpace$en {
	Translations$sharedSpace$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$sharedSpace$dashboard$en dashboard = Translations$sharedSpace$dashboard$en._(_root);
	late final Translations$sharedSpace$roles$en roles = Translations$sharedSpace$roles$en._(_root);

	/// en: 'Shared Space'
	String get title => 'Shared Space';

	late final Translations$sharedSpace$create$en create = Translations$sharedSpace$create$en._(_root);
	late final Translations$sharedSpace$join$en join = Translations$sharedSpace$join$en._(_root);
	late final Translations$sharedSpace$list$en list = Translations$sharedSpace$list$en._(_root);
	late final Translations$sharedSpace$detail$en detail = Translations$sharedSpace$detail$en._(_root);
	late final Translations$sharedSpace$notifications$en notifications = Translations$sharedSpace$notifications$en._(_root);
	late final Translations$sharedSpace$inviteCard$en inviteCard = Translations$sharedSpace$inviteCard$en._(_root);
	late final Translations$sharedSpace$inviteSuccess$en inviteSuccess = Translations$sharedSpace$inviteSuccess$en._(_root);
	late final Translations$sharedSpace$notificationCard$en notificationCard = Translations$sharedSpace$notificationCard$en._(_root);
	late final Translations$sharedSpace$spaceCard$en spaceCard = Translations$sharedSpace$spaceCard$en._(_root);
	late final Translations$sharedSpace$settings$en settings = Translations$sharedSpace$settings$en._(_root);
}

// Path: errorMapping
class Translations$errorMapping$en {
	Translations$errorMapping$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$errorMapping$generic$en generic = Translations$errorMapping$generic$en._(_root);
	late final Translations$errorMapping$auth$en auth = Translations$errorMapping$auth$en._(_root);
	late final Translations$errorMapping$transaction$en transaction = Translations$errorMapping$transaction$en._(_root);
	late final Translations$errorMapping$space$en space = Translations$errorMapping$space$en._(_root);
	late final Translations$errorMapping$recurring$en recurring = Translations$errorMapping$recurring$en._(_root);
	late final Translations$errorMapping$upload$en upload = Translations$errorMapping$upload$en._(_root);
	late final Translations$errorMapping$storage$en storage = Translations$errorMapping$storage$en._(_root);
	late final Translations$errorMapping$ai$en ai = Translations$errorMapping$ai$en._(_root);
}

// Path: notification
class Translations$notification$en {
	Translations$notification$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Notifications'
	String get title => 'Notifications';

	/// en: 'Mark all read'
	String get markAllRead => 'Mark all read';

	/// en: 'No notifications yet'
	String get empty => 'No notifications yet';

	/// en: 'Failed to load'
	String get loadFailed => 'Failed to load';

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'Just now'
	String get justNow => 'Just now';

	/// en: '${minutes}m ago'
	String minutesAgo({required Object minutes}) => '${minutes}m ago';

	/// en: '${hours}h ago'
	String hoursAgo({required Object hours}) => '${hours}h ago';

	/// en: '${days}d ago'
	String daysAgo({required Object days}) => '${days}d ago';

	/// en: 'Deleted'
	String get deleted => 'Deleted';

	late final Translations$notification$types$en types = Translations$notification$types$en._(_root);
	late final Translations$notification$semantic$en semantic = Translations$notification$semantic$en._(_root);
}

// Path: auth.email
class Translations$auth$email$en {
	Translations$auth$email$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Email'
	String get label => 'Email';

	/// en: 'Enter your email'
	String get placeholder => 'Enter your email';

	/// en: 'Email is required'
	String get required => 'Email is required';

	/// en: 'Please enter a valid email address'
	String get invalid => 'Please enter a valid email address';
}

// Path: auth.password
class Translations$auth$password$en {
	Translations$auth$password$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Password'
	String get label => 'Password';

	/// en: 'Enter your password'
	String get placeholder => 'Enter your password';

	/// en: 'Password is required'
	String get required => 'Password is required';

	/// en: 'Password must be at least 6 characters'
	String get tooShort => 'Password must be at least 6 characters';

	/// en: 'Password must contain both numbers and letters'
	String get mustContainNumbersAndLetters => 'Password must contain both numbers and letters';

	/// en: 'Confirm Password'
	String get confirm => 'Confirm Password';

	/// en: 'Re-enter your password'
	String get confirmPlaceholder => 'Re-enter your password';

	/// en: 'Passwords do not match'
	String get mismatch => 'Passwords do not match';
}

// Path: auth.verificationCode
class Translations$auth$verificationCode$en {
	Translations$auth$verificationCode$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Verification Code'
	String get label => 'Verification Code';

	/// en: 'Get Code'
	String get get => 'Get Code';

	/// en: 'Sending...'
	String get sending => 'Sending...';

	/// en: 'Code sent'
	String get sent => 'Code sent';

	/// en: 'Failed to send'
	String get sendFailed => 'Failed to send';

	/// en: 'Optional for now, enter anything'
	String get placeholder => 'Optional for now, enter anything';

	/// en: 'Verification code is required'
	String get required => 'Verification code is required';
}

// Path: calendar.weekdays
class Translations$calendar$weekdays$en {
	Translations$calendar$weekdays$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'M'
	String get mon => 'M';

	/// en: 'T'
	String get tue => 'T';

	/// en: 'W'
	String get wed => 'W';

	/// en: 'T'
	String get thu => 'T';

	/// en: 'F'
	String get fri => 'F';

	/// en: 'S'
	String get sat => 'S';

	/// en: 'S'
	String get sun => 'S';
}

// Path: appearance.palettes
class Translations$appearance$palettes$en {
	Translations$appearance$palettes$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Zinc'
	String get zinc => 'Zinc';

	/// en: 'Slate'
	String get slate => 'Slate';

	/// en: 'Red'
	String get red => 'Red';

	/// en: 'Rose'
	String get rose => 'Rose';

	/// en: 'Orange'
	String get orange => 'Orange';

	/// en: 'Green'
	String get green => 'Green';

	/// en: 'Blue'
	String get blue => 'Blue';

	/// en: 'Yellow'
	String get yellow => 'Yellow';

	/// en: 'Violet'
	String get violet => 'Violet';
}

// Path: forecast.recurringTransaction
class Translations$forecast$recurringTransaction$en {
	Translations$forecast$recurringTransaction$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Recurring Transactions'
	String get title => 'Recurring Transactions';

	/// en: 'All'
	String get all => 'All';

	/// en: 'Expense'
	String get expense => 'Expense';

	/// en: 'Income'
	String get income => 'Income';

	/// en: 'Transfer'
	String get transfer => 'Transfer';

	/// en: 'No recurring transactions'
	String get noRecurring => 'No recurring transactions';

	/// en: 'The system will automatically generate transactions after you create recurring rules'
	String get createHint => 'The system will automatically generate transactions after you create recurring rules';

	/// en: 'Create Recurring Transaction'
	String get create => 'Create Recurring Transaction';

	/// en: 'Edit Recurring Transaction'
	String get edit => 'Edit Recurring Transaction';

	/// en: 'New Recurring Transaction'
	String get newTransaction => 'New Recurring Transaction';

	/// en: 'Are you sure you want to delete recurring transaction "$name"? This cannot be undone.'
	String deleteConfirm({required Object name}) => 'Are you sure you want to delete recurring transaction "${name}"? This cannot be undone.';

	/// en: 'Are you sure you want to activate recurring transaction "$name"? It will automatically generate transactions.'
	String activateConfirm({required Object name}) => 'Are you sure you want to activate recurring transaction "${name}"? It will automatically generate transactions.';

	/// en: 'Are you sure you want to pause recurring transaction "$name"? No transactions will be generated while paused.'
	String pauseConfirm({required Object name}) => 'Are you sure you want to pause recurring transaction "${name}"? No transactions will be generated while paused.';

	/// en: 'Recurring transaction created'
	String get created => 'Recurring transaction created';

	/// en: 'Recurring transaction updated'
	String get updated => 'Recurring transaction updated';

	/// en: 'Activated'
	String get activated => 'Activated';

	/// en: 'Paused'
	String get paused => 'Paused';

	/// en: 'Next'
	String get nextTime => 'Next';

	/// en: 'Sort by time'
	String get sortByTime => 'Sort by time';

	/// en: 'All recurring'
	String get allPeriod => 'All recurring';

	/// en: '$type recurring ($count)'
	String periodCount({required Object type, required Object count}) => '${type} recurring (${count})';

	/// en: 'Confirm Delete'
	String get confirmDelete => 'Confirm Delete';

	/// en: 'Confirm Activate'
	String get confirmActivate => 'Confirm Activate';

	/// en: 'Confirm Pause'
	String get confirmPause => 'Confirm Pause';

	/// en: 'Est. Avg'
	String get dynamicAmount => 'Est. Avg';

	/// en: 'Amount Requires Confirmation'
	String get dynamicAmountTitle => 'Amount Requires Confirmation';

	/// en: 'System will send a reminder on the due date. You need to manually confirm the amount before recording.'
	String get dynamicAmountDescription => 'System will send a reminder on the due date. You need to manually confirm the amount before recording.';

	/// en: 'Confirm Before Generation'
	String get confirmBeforeGeneration => 'Confirm Before Generation';

	/// en: 'Generates a pending transaction on due date, requires manual confirmation'
	String get confirmBeforeGenerationDesc => 'Generates a pending transaction on due date, requires manual confirmation';

	/// en: 'Pending Transactions'
	String get pendingTitle => 'Pending Transactions';

	/// en: '$count pending'
	String pendingCount({required Object count}) => '${count} pending';

	/// en: 'Confirm'
	String get confirm => 'Confirm';

	/// en: 'Skip'
	String get skip => 'Skip';

	/// en: 'No pending transactions'
	String get noPending => 'No pending transactions';

	/// en: 'Transaction confirmed'
	String get confirmSuccess => 'Transaction confirmed';

	/// en: 'Transaction skipped'
	String get skipSuccess => 'Transaction skipped';

	/// en: 'Interval'
	String get interval => 'Interval';

	/// en: 'Select Days'
	String get selectDays => 'Select Days';

	/// en: 'Always execute on last day'
	String get alwaysLastDay => 'Always execute on last day';

	/// en: 'Will execute on the last day of each month'
	String get lastDayExecution => 'Will execute on the last day of each month';

	/// en: 'Will execute on the $day$suffix of each month (clamped for short months)'
	String dayExecution({required Object day, required Object suffix}) => 'Will execute on the ${day}${suffix} of each month (clamped for short months)';

	/// en: 'Set End Date'
	String get setEndDate => 'Set End Date';

	/// en: 'Select End Date'
	String get selectEndDate => 'Select End Date';

	/// en: 'Preview'
	String get preview => 'Preview';

	/// en: 'Daily'
	String get daily => 'Daily';

	/// en: 'Weekly'
	String get weekly => 'Weekly';

	/// en: 'Monthly'
	String get monthly => 'Monthly';

	/// en: 'Yearly'
	String get yearly => 'Yearly';

	/// en: 'Custom'
	String get custom => 'Custom';

	/// en: 'Cycle'
	String get cycle => 'Cycle';

	/// en: '{count, plural, =1 {Day} other {Days}}'
	String get dayUnit => '{count, plural, =1 {Day} other {Days}}';

	/// en: '{count, plural, =1 {Week} other {Weeks}}'
	String get weekUnit => '{count, plural, =1 {Week} other {Weeks}}';

	/// en: '{count, plural, =1 {Month} other {Months}}'
	String get monthUnit => '{count, plural, =1 {Month} other {Months}}';

	/// en: '{count, plural, =1 {Year} other {Years}}'
	String get yearUnit => '{count, plural, =1 {Year} other {Years}}';

	/// en: 'Every $count days'
	String everyDays({required Object count}) => 'Every ${count} days';

	/// en: 'Every $count weeks'
	String everyWeeks({required Object count}) => 'Every ${count} weeks';

	/// en: 'Every $count months'
	String everyMonths({required Object count}) => 'Every ${count} months';

	/// en: 'Every $count years'
	String everyYears({required Object count}) => 'Every ${count} years';

	/// en: 'Monthly on the $day$suffix'
	String monthlyOnDay({required Object day, required Object suffix}) => 'Monthly on the ${day}${suffix}';

	/// en: 'Every $count months on the $day$suffix'
	String everyMonthsOnDay({required Object count, required Object day, required Object suffix}) => 'Every ${count} months on the ${day}${suffix}';

	/// en: 'Monthly on the last day'
	String get monthlyLastDay => 'Monthly on the last day';

	/// en: 'Every $count months on the last day'
	String everyMonthsLastDay({required Object count}) => 'Every ${count} months on the last day';

	/// en: 'Yearly on $month/$day'
	String yearlyOn({required Object month, required Object day}) => 'Yearly on ${month}/${day}';

	/// en: 'Every $count years on $month/$day'
	String everyYearsOn({required Object count, required Object month, required Object day}) => 'Every ${count} years on ${month}/${day}';

	/// en: 'Weekly on $day'
	String weeklyOnDay({required Object day}) => 'Weekly on ${day}';

	/// en: 'Mon'
	String get weekdayMon => 'Mon';

	/// en: 'Tue'
	String get weekdayTue => 'Tue';

	/// en: 'Wed'
	String get weekdayWed => 'Wed';

	/// en: 'Thu'
	String get weekdayThu => 'Thu';

	/// en: 'Fri'
	String get weekdayFri => 'Fri';

	/// en: 'Sat'
	String get weekdaySat => 'Sat';

	/// en: 'Sun'
	String get weekdaySun => 'Sun';

	/// en: ''
	String get weekdayOn => '';

	/// en: ', '
	String get weekdayJoiner => ', ';

	/// en: ' on '
	String get weeklyDaysPrefix => ' on ';

	/// en: 'Source Account'
	String get sourceAccount => 'Source Account';

	/// en: 'Target Account'
	String get targetAccount => 'Target Account';

	/// en: 'Expense Account'
	String get expenseAccount => 'Expense Account';

	/// en: 'Income Account'
	String get incomeAccount => 'Income Account';

	/// en: 'Source'
	String get selectSourceAccount => 'Source';

	/// en: 'Target'
	String get selectTargetAccount => 'Target';

	/// en: 'Expense'
	String get selectExpenseAccount => 'Expense';

	/// en: 'Income'
	String get selectIncomeAccount => 'Income';

	/// en: 'Amount not fixed for each $type'
	String amountNotFixed({required Object type}) => 'Amount not fixed for each ${type}';

	/// en: 'Please select source and target accounts'
	String get selectBothAccounts => 'Please select source and target accounts';

	/// en: 'Please select $type account'
	String selectAccountForType({required Object type}) => 'Please select ${type} account';

	/// en: 'Are you sure you want to delete this recurring transaction? This action cannot be undone.'
	String get deleteConfirmGeneric => 'Are you sure you want to delete this recurring transaction? This action cannot be undone.';

	/// en: 'Select $date'
	String selectDate({required Object date}) => 'Select ${date}';

	/// en: 'Cash'
	String get accountTypeCash => 'Cash';

	/// en: 'Bank Deposit'
	String get accountTypeDeposit => 'Bank Deposit';

	/// en: 'E-Wallet'
	String get accountTypeEMoney => 'E-Wallet';

	/// en: 'Investment'
	String get accountTypeInvestment => 'Investment';

	/// en: 'Accounts Receivable'
	String get accountTypeReceivable => 'Accounts Receivable';

	/// en: 'Credit Card'
	String get accountTypeCreditCard => 'Credit Card';

	/// en: 'Loan Account'
	String get accountTypeLoan => 'Loan Account';

	/// en: 'Accounts Payable'
	String get accountTypePayable => 'Accounts Payable';

	/// en: 'Asset Account'
	String get assetAccount => 'Asset Account';

	/// en: 'Liability Account'
	String get liabilityAccount => 'Liability Account';

	/// en: 'No asset accounts'
	String get noAssetAccounts => 'No asset accounts';

	/// en: 'Please go to the financial page to add accounts'
	String get goToFinanceToAddAccounts => 'Please go to the financial page to add accounts';

	/// en: 'Select Account'
	String get selectAccount => 'Select Account';

	/// en: 'Automatically generate transactions by rule'
	String get autoGenerateByRule => 'Automatically generate transactions by rule';
}

// Path: chat.tools
class Translations$chat$tools$en {
	Translations$chat$tools$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Processing...'
	String get processing => 'Processing...';

	/// en: 'Reading file...'
	String get read_file => 'Reading file...';

	/// en: 'Searching transactions...'
	String get search_transactions => 'Searching transactions...';

	/// en: 'Checking budget...'
	String get query_budget_status => 'Checking budget...';

	/// en: 'Creating budget plan...'
	String get create_budget => 'Creating budget plan...';

	/// en: 'Analyzing cash flow...'
	String get get_cash_flow_analysis => 'Analyzing cash flow...';

	/// en: 'Calculating financial health score...'
	String get get_financial_health_score => 'Calculating financial health score...';

	/// en: 'Generating financial report...'
	String get get_financial_summary => 'Generating financial report...';

	/// en: 'Evaluating financial health...'
	String get evaluate_financial_health => 'Evaluating financial health...';

	/// en: 'Simulating purchase impact...'
	String get simulate_expense_impact => 'Simulating purchase impact...';

	/// en: 'Recording transactions...'
	String get record_transactions => 'Recording transactions...';

	/// en: 'Recording transaction...'
	String get create_transaction => 'Recording transaction...';

	/// en: 'Searching the web...'
	String get duckduckgo_search => 'Searching the web...';

	/// en: 'Executing transfer...'
	String get execute_transfer => 'Executing transfer...';

	/// en: 'Browsing directory...'
	String get list_dir => 'Browsing directory...';

	/// en: 'Processing...'
	String get execute => 'Processing...';

	/// en: 'Analyzing spendings...'
	String get analyze_spending => 'Analyzing spendings...';

	/// en: 'Analyzing cashflow...'
	String get analyze_cashflow => 'Analyzing cashflow...';

	/// en: 'Forecasting balance...'
	String get forecast_balance => 'Forecasting balance...';

	/// en: 'Suggesting budget...'
	String get suggest_budget => 'Suggesting budget...';

	/// en: 'Loading shared spaces...'
	String get list_spaces => 'Loading shared spaces...';

	/// en: 'Querying space summary...'
	String get query_space_summary => 'Querying space summary...';

	/// en: 'Preparing transfer...'
	String get prepare_transfer => 'Preparing transfer...';

	/// en: 'Processing request...'
	String get unknown => 'Processing request...';

	late final Translations$chat$tools$done$en done = Translations$chat$tools$done$en._(_root);
	late final Translations$chat$tools$failed$en failed = Translations$chat$tools$failed$en._(_root);

	/// en: 'Cancelled'
	String get cancelled => 'Cancelled';

	/// en: '正在分析財務狀況...'
	String get analyze_finance => '正在分析財務狀況...';

	/// en: '正在預測財務趨勢...'
	String get forecast_finance => '正在預測財務趨勢...';

	/// en: '正在分析預算...'
	String get analyze_budget => '正在分析預算...';

	/// en: '正在審計分析...'
	String get audit_analysis => '正在審計分析...';

	/// en: '正在處理預算...'
	String get budget_ops => '正在處理預算...';

	/// en: '正在創建共享帳單...'
	String get create_shared_transaction => '正在創建共享帳單...';

	/// en: 'Preparing budget simulation'
	String get prepareBudgetSimulation => 'Preparing budget simulation';

	/// en: 'Simulating budget'
	String get simulateBudget => 'Simulating budget';
}

// Path: chat.transferWizard
class Translations$chat$transferWizard$en {
	Translations$chat$transferWizard$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Transfer Wizard'
	String get title => 'Transfer Wizard';

	/// en: 'Transfer Amount'
	String get amount => 'Transfer Amount';

	/// en: 'Enter amount'
	String get amountHint => 'Enter amount';

	/// en: 'Source Account'
	String get sourceAccount => 'Source Account';

	/// en: 'Target Account'
	String get targetAccount => 'Target Account';

	/// en: 'Select Account'
	String get selectAccount => 'Select Account';

	/// en: 'Automatically generate transactions by rule'
	String get autoGenerateByRule => 'Automatically generate transactions by rule';

	/// en: 'Confirm Transfer'
	String get confirmTransfer => 'Confirm Transfer';

	/// en: 'Confirmed'
	String get confirmed => 'Confirmed';

	/// en: 'Transfer Successful'
	String get transferSuccess => 'Transfer Successful';

	/// en: '选择收款账户'
	String get selectReceiveAccount => '选择收款账户';
}

// Path: chat.genui
class Translations$chat$genui$en {
	Translations$chat$genui$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$chat$genui$expenseSummary$en expenseSummary = Translations$chat$genui$expenseSummary$en._(_root);
	late final Translations$chat$genui$transactionList$en transactionList = Translations$chat$genui$transactionList$en._(_root);
	late final Translations$chat$genui$transactionGroupReceipt$en transactionGroupReceipt = Translations$chat$genui$transactionGroupReceipt$en._(_root);
	late final Translations$chat$genui$budgetReceipt$en budgetReceipt = Translations$chat$genui$budgetReceipt$en._(_root);
	late final Translations$chat$genui$budgetStatusCard$en budgetStatusCard = Translations$chat$genui$budgetStatusCard$en._(_root);
	late final Translations$chat$genui$cashFlowForecast$en cashFlowForecast = Translations$chat$genui$cashFlowForecast$en._(_root);
	late final Translations$chat$genui$healthScore$en healthScore = Translations$chat$genui$healthScore$en._(_root);
	late final Translations$chat$genui$spaceSelector$en spaceSelector = Translations$chat$genui$spaceSelector$en._(_root);
	late final Translations$chat$genui$transferPath$en transferPath = Translations$chat$genui$transferPath$en._(_root);
	late final Translations$chat$genui$transactionCard$en transactionCard = Translations$chat$genui$transactionCard$en._(_root);
	late final Translations$chat$genui$cashFlowCard$en cashFlowCard = Translations$chat$genui$cashFlowCard$en._(_root);
	late final Translations$chat$genui$transactionConfirmation$en transactionConfirmation = Translations$chat$genui$transactionConfirmation$en._(_root);
	late final Translations$chat$genui$budgetAnalysis$en budgetAnalysis = Translations$chat$genui$budgetAnalysis$en._(_root);
	late final Translations$chat$genui$budgetSimulator$en budgetSimulator = Translations$chat$genui$budgetSimulator$en._(_root);
}

// Path: chat.welcome
class Translations$chat$welcome$en {
	Translations$chat$welcome$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$chat$welcome$morning$en morning = Translations$chat$welcome$morning$en._(_root);
	late final Translations$chat$welcome$midday$en midday = Translations$chat$welcome$midday$en._(_root);
	late final Translations$chat$welcome$afternoon$en afternoon = Translations$chat$welcome$afternoon$en._(_root);
	late final Translations$chat$welcome$evening$en evening = Translations$chat$welcome$evening$en._(_root);
	late final Translations$chat$welcome$night$en night = Translations$chat$welcome$night$en._(_root);
}

// Path: error.genui
class Translations$error$genui$en {
	Translations$error$genui$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Component loading failed'
	String get loadingFailed => 'Component loading failed';

	/// en: 'Schema validation failed'
	String get schemaFailed => 'Schema validation failed';

	/// en: 'Component definition does not comply with GenUI specifications, degraded to plain text display'
	String get schemaDescription => 'Component definition does not comply with GenUI specifications, degraded to plain text display';

	/// en: 'Network error'
	String get networkError => 'Network error';

	/// en: 'Retried $retryCount/$maxRetries times'
	String retryStatus({required Object retryCount, required Object maxRetries}) => 'Retried ${retryCount}/${maxRetries} times';

	/// en: 'Maximum retry attempts reached'
	String get maxRetriesReached => 'Maximum retry attempts reached';
}

// Path: account.types
class Translations$account$types$en {
	Translations$account$types$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Cash'
	String get cashTitle => 'Cash';

	/// en: 'Physical currency and coins'
	String get cashSubtitle => 'Physical currency and coins';

	/// en: 'Bank Deposit'
	String get depositTitle => 'Bank Deposit';

	/// en: 'Savings, checking accounts'
	String get depositSubtitle => 'Savings, checking accounts';

	/// en: 'E-Wallet'
	String get eMoneyTitle => 'E-Wallet';

	/// en: 'Digital payment balances'
	String get eMoneySubtitle => 'Digital payment balances';

	/// en: 'Investment'
	String get investmentTitle => 'Investment';

	/// en: 'Stocks, funds, bonds, etc.'
	String get investmentSubtitle => 'Stocks, funds, bonds, etc.';

	/// en: 'Receivable'
	String get receivableTitle => 'Receivable';

	/// en: 'Loans to others, pending'
	String get receivableSubtitle => 'Loans to others, pending';

	/// en: 'Owed to me'
	String get receivableHelper => 'Owed to me';

	/// en: 'Credit Card'
	String get creditCardTitle => 'Credit Card';

	/// en: 'Credit card balances'
	String get creditCardSubtitle => 'Credit card balances';

	/// en: 'Loan'
	String get loanTitle => 'Loan';

	/// en: 'Mortgage, auto, personal'
	String get loanSubtitle => 'Mortgage, auto, personal';

	/// en: 'Payable'
	String get payableTitle => 'Payable';

	/// en: 'Amounts owed to others'
	String get payableSubtitle => 'Amounts owed to others';

	/// en: 'I owe'
	String get payableHelper => 'I owe';
}

// Path: statistics.overview
class Translations$statistics$overview$en {
	Translations$statistics$overview$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Total Balance'
	String get balance => 'Total Balance';

	/// en: 'Total Income'
	String get income => 'Total Income';

	/// en: 'Total Expense'
	String get expense => 'Total Expense';
}

// Path: statistics.trend
class Translations$statistics$trend$en {
	Translations$statistics$trend$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Trends'
	String get title => 'Trends';

	/// en: 'Expense'
	String get expense => 'Expense';

	/// en: 'Income'
	String get income => 'Income';
}

// Path: statistics.analysis
class Translations$statistics$analysis$en {
	Translations$statistics$analysis$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Expense Analysis'
	String get title => 'Expense Analysis';

	/// en: 'Expense Analysis'
	String get expenseTitle => 'Expense Analysis';

	/// en: 'Income Analysis'
	String get incomeTitle => 'Income Analysis';

	/// en: 'Total'
	String get total => 'Total';

	/// en: 'Expense Breakdown'
	String get breakdown => 'Expense Breakdown';

	/// en: 'Radar chart requires at least 3 categories'
	String get radarNeedMoreData => 'Radar chart requires at least 3 categories';
}

// Path: statistics.filter
class Translations$statistics$filter$en {
	Translations$statistics$filter$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Account Type'
	String get accountType => 'Account Type';

	/// en: 'All Accounts'
	String get allAccounts => 'All Accounts';

	/// en: 'Apply'
	String get apply => 'Apply';
}

// Path: statistics.sort
class Translations$statistics$sort$en {
	Translations$statistics$sort$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'By Amount'
	String get amount => 'By Amount';

	/// en: 'By Time'
	String get date => 'By Time';
}

// Path: statistics.emptyState
class Translations$statistics$emptyState$en {
	Translations$statistics$emptyState$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Unlock Financial Insights'
	String get title => 'Unlock Financial Insights';

	/// en: 'Your financial report is currently a blank canvas. Record your first transaction and let the data tell your story.'
	String get description => 'Your financial report is currently a blank canvas.\nRecord your first transaction and let the data tell your story.';

	/// en: 'Record First Transaction'
	String get action => 'Record First Transaction';
}

// Path: server.error
class Translations$server$error$en {
	Translations$server$error$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Server address is required'
	String get urlRequired => 'Server address is required';

	/// en: 'Invalid URL format'
	String get invalidUrl => 'Invalid URL format';

	/// en: 'Connection timed out'
	String get connectionTimeout => 'Connection timed out';

	/// en: 'Could not connect to server'
	String get connectionRefused => 'Could not connect to server';

	/// en: 'SSL certificate error'
	String get sslError => 'SSL certificate error';

	/// en: 'Server error'
	String get serverError => 'Server error';
}

// Path: sharedSpace.dashboard
class Translations$sharedSpace$dashboard$en {
	Translations$sharedSpace$dashboard$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Financial Overview'
	String get sectionTitle => 'Financial Overview';

	/// en: 'Cumulative Total Expense'
	String get cumulativeTotalExpense => 'Cumulative Total Expense';

	/// en: 'Participating Members'
	String get participatingMembers => 'Participating Members';

	/// en: '$count people'
	String membersCount({required Object count}) => '${count} people';

	/// en: 'Avg per member'
	String get averagePerMember => 'Avg per member';

	/// en: 'Spending Distribution'
	String get spendingDistribution => 'Spending Distribution';

	/// en: 'Real-time updates'
	String get realtimeUpdates => 'Real-time updates';

	/// en: 'Paid'
	String get paid => 'Paid';
}

// Path: sharedSpace.roles
class Translations$sharedSpace$roles$en {
	Translations$sharedSpace$roles$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Owner'
	String get owner => 'Owner';

	/// en: 'Admin'
	String get admin => 'Admin';

	/// en: 'Member'
	String get member => 'Member';
}

// Path: sharedSpace.create
class Translations$sharedSpace$create$en {
	Translations$sharedSpace$create$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Create Shared Space'
	String get title => 'Create Shared Space';

	/// en: 'Create a new shared space to track expenses with friends'
	String get subtitle => 'Create a new shared space to track expenses with friends';

	/// en: 'Space Name'
	String get nameLabel => 'Space Name';

	/// en: 'e.g., Graduation Trip'
	String get nameHint => 'e.g., Graduation Trip';

	/// en: 'Description (Optional)'
	String get descLabel => 'Description (Optional)';

	/// en: 'Track our joint travel expenses'
	String get descHint => 'Track our joint travel expenses';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Create'
	String get submit => 'Create';

	/// en: 'Please enter a space name'
	String get nameRequired => 'Please enter a space name';

	/// en: 'Space name must be at least 2 characters'
	String get nameTooShort => 'Space name must be at least 2 characters';

	/// en: 'Space name cannot exceed 50 characters'
	String get nameTooLong => 'Space name cannot exceed 50 characters';
}

// Path: sharedSpace.join
class Translations$sharedSpace$join$en {
	Translations$sharedSpace$join$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Join Shared Space'
	String get title => 'Join Shared Space';

	/// en: 'Enter the invite code shared by a friend to start collaborative bookkeeping'
	String get subtitle => 'Enter the invite code shared by a friend to start collaborative bookkeeping';

	/// en: 'Invite Code'
	String get codeLabel => 'Invite Code';

	/// en: 'Enter invite code, e.g.: 123456'
	String get codeHint => 'Enter invite code, e.g.: 123456';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Join'
	String get submit => 'Join';

	/// en: 'Please enter invite code'
	String get codeRequired => 'Please enter invite code';

	/// en: 'Invalid invite code format'
	String get codeInvalid => 'Invalid invite code format';

	/// en: 'Invite code can only contain letters and numbers'
	String get codeFormat => 'Invite code can only contain letters and numbers';
}

// Path: sharedSpace.list
class Translations$sharedSpace$list$en {
	Translations$sharedSpace$list$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Start Collaborative Financial Spaces'
	String get emptyTitle => 'Start Collaborative Financial Spaces';

	/// en: 'Create or join a space to manage shared accounts and assets with family, partners, or teams'
	String get emptySubtitle => 'Create or join a space to manage shared accounts and assets with family, partners, or teams';

	/// en: 'Get Started'
	String get getStarted => 'Get Started';

	/// en: 'Have an invite code? Tap to join'
	String get hasInviteCode => 'Have an invite code? Tap to join';

	/// en: 'Successfully joined "${name}"!'
	String joinedSuccess({required Object name}) => 'Successfully joined "${name}"!';
}

// Path: sharedSpace.detail
class Translations$sharedSpace$detail$en {
	Translations$sharedSpace$detail$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Members'
	String get members => 'Members';

	/// en: 'Transactions'
	String get transactions => 'Transactions';

	/// en: '${count} records'
	String recordsCount({required Object count}) => '${count} records';

	/// en: 'Settlement'
	String get settlement => 'Settlement';

	/// en: 'Invite Code'
	String get inviteCode => 'Invite Code';

	/// en: 'Copy Invite Code'
	String get copyCode => 'Copy Invite Code';

	/// en: 'Invite code copied: ${code}'
	String codeCopied({required Object code}) => 'Invite code copied: ${code}';

	/// en: 'Valid for 24 hours'
	String get validFor24h => 'Valid for 24 hours';

	/// en: 'Leave Space'
	String get leaveSpace => 'Leave Space';

	/// en: 'Delete Space'
	String get deleteSpace => 'Delete Space';

	/// en: 'Remove Member'
	String get removeMember => 'Remove Member';

	/// en: 'Are you sure you want to leave this shared space? You will no longer have access to its transactions.'
	String get leaveConfirm => 'Are you sure you want to leave this shared space? You will no longer have access to its transactions.';

	/// en: 'Are you sure you want to delete this shared space? This action cannot be undone and all members will be removed.'
	String get deleteConfirm => 'Are you sure you want to delete this shared space? This action cannot be undone and all members will be removed.';

	/// en: 'Are you sure you want to remove this member from the shared space?'
	String get removeConfirm => 'Are you sure you want to remove this member from the shared space?';

	/// en: 'Generating invite code...'
	String get generatingCode => 'Generating invite code...';

	/// en: 'Failed to load'
	String get loadFailed => 'Failed to load';

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'No transactions yet'
	String get noTransactions => 'No transactions yet';

	/// en: 'Transactions in this space will appear here'
	String get noTransactionsHint => 'Transactions in this space will appear here';

	/// en: 'Refresh Code'
	String get refreshCode => 'Refresh Code';

	/// en: 'Join Another Space'
	String get joinOtherSpace => 'Join Another Space';
}

// Path: sharedSpace.notifications
class Translations$sharedSpace$notifications$en {
	Translations$sharedSpace$notifications$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Notifications'
	String get title => 'Notifications';

	/// en: 'No notifications'
	String get empty => 'No notifications';

	/// en: 'When you have new invites or activities, you will receive notifications here'
	String get emptyHint => 'When you have new invites or activities,\nyou will receive notifications here';

	/// en: 'Incomplete invite info'
	String get incompleteInfo => 'Incomplete invite info';

	/// en: 'Invite accepted!'
	String get inviteAccepted => 'Invite accepted!';

	/// en: 'Invite rejected'
	String get inviteRejected => 'Invite rejected';

	/// en: 'All notifications marked as read'
	String get allMarkedRead => 'All notifications marked as read';
}

// Path: sharedSpace.inviteCard
class Translations$sharedSpace$inviteCard$en {
	Translations$sharedSpace$inviteCard$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Invite Code'
	String get title => 'Invite Code';

	/// en: 'Share with friends to join the space'
	String get subtitle => 'Share with friends to join the space';

	/// en: 'Copy Invite Code'
	String get copyCode => 'Copy Invite Code';

	/// en: 'Share Invite Link'
	String get shareLink => 'Share Invite Link';

	/// en: 'Invite code copied'
	String get codeCopied => 'Invite code copied';

	/// en: 'No expiry'
	String get noExpiry => 'No expiry';

	/// en: 'Expired'
	String get expired => 'Expired';

	/// en: 'Expires in ${days} days'
	String expiresInDays({required Object days}) => 'Expires in ${days} days';

	/// en: 'Expires in ${hours} hours'
	String expiresInHours({required Object hours}) => 'Expires in ${hours} hours';

	/// en: 'Expires in ${minutes} minutes'
	String expiresInMinutes({required Object minutes}) => 'Expires in ${minutes} minutes';

	/// en: 'Expiring soon'
	String get expiringSoon => 'Expiring soon';

	/// en: 'You are invited to join the shared space "${spaceName}" Invite code: ${code} Or click the link to join directly: ${link} Invite code ${expiry}'
	String shareText({required Object spaceName, required Object code, required Object link, required Object expiry}) => 'You are invited to join the shared space "${spaceName}"\n\nInvite code: ${code}\nOr click the link to join directly: ${link}\n\nInvite code ${expiry}';
}

// Path: sharedSpace.inviteSuccess
class Translations$sharedSpace$inviteSuccess$en {
	Translations$sharedSpace$inviteSuccess$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Created Successfully'
	String get title => 'Created Successfully';

	/// en: 'Space Created Successfully'
	String get subtitle => 'Space Created Successfully';

	/// en: 'Invite Later'
	String get inviteLater => 'Invite Later';

	/// en: 'Enter Space'
	String get enterSpace => 'Enter Space';

	/// en: 'Generating invite code...'
	String get generatingCode => 'Generating invite code...';

	/// en: 'Failed to generate invite code'
	String get generateFailed => 'Failed to generate invite code';

	/// en: 'Invite code copied'
	String get codeCopied => 'Invite code copied';

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'Invite Code'
	String get codeLabel => 'Invite Code';

	/// en: 'Valid for 24 hours · Tap to copy'
	String get validHint => 'Valid for 24 hours · Tap to copy';
}

// Path: sharedSpace.notificationCard
class Translations$sharedSpace$notificationCard$en {
	Translations$sharedSpace$notificationCard$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Accept'
	String get accept => 'Accept';

	/// en: 'Reject'
	String get reject => 'Reject';

	/// en: 'Unknown time'
	String get unknownTime => 'Unknown time';

	/// en: 'Just now'
	String get justNow => 'Just now';
}

// Path: sharedSpace.spaceCard
class Translations$sharedSpace$spaceCard$en {
	Translations$sharedSpace$spaceCard$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No description'
	String get noDescription => 'No description';

	/// en: 'Creator'
	String get creator => 'Creator';

	/// en: 'Member'
	String get member => 'Member';

	/// en: '${count} members'
	String membersCount({required Object count}) => '${count} members';

	/// en: '${count} transactions'
	String transactionsCount({required Object count}) => '${count} transactions';
}

// Path: sharedSpace.settings
class Translations$sharedSpace$settings$en {
	Translations$sharedSpace$settings$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Space Settings'
	String get title => 'Space Settings';

	/// en: 'Space Info'
	String get spaceInfo => 'Space Info';

	/// en: 'Space Name'
	String get nameLabel => 'Space Name';

	/// en: 'Space Description'
	String get descLabel => 'Space Description';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Saved successfully'
	String get saved => 'Saved successfully';

	/// en: 'Failed to save'
	String get saveFailed => 'Failed to save';

	/// en: 'Member Management'
	String get memberManagement => 'Member Management';

	/// en: '$count members'
	String membersCount({required Object count}) => '${count} members';

	/// en: 'Are you sure you want to remove "$name" from this space?'
	String removeMemberConfirm({required Object name}) => 'Are you sure you want to remove "${name}" from this space?';

	/// en: 'Member removed'
	String get removed => 'Member removed';

	/// en: 'Failed to remove member'
	String get removeFailed => 'Failed to remove member';

	/// en: 'Invite Management'
	String get inviteManagement => 'Invite Management';

	/// en: 'Current Invite Code'
	String get currentCode => 'Current Invite Code';

	/// en: 'Generate New Code'
	String get generateNew => 'Generate New Code';

	/// en: 'No valid invite code'
	String get noValidCode => 'No valid invite code';

	/// en: 'Refresh Code'
	String get refreshCode => 'Refresh Code';

	/// en: 'Generating a new code will invalidate the old one. Continue?'
	String get refreshConfirm => 'Generating a new code will invalidate the old one. Continue?';

	/// en: 'Invite code refreshed'
	String get codeRefreshed => 'Invite code refreshed';

	/// en: 'Danger Zone'
	String get dangerZone => 'Danger Zone';

	/// en: 'Only admins can edit'
	String get editHint => 'Only admins can edit';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'You'
	String get you => 'You';

	/// en: 'Pending'
	String get pending => 'Pending';

	/// en: 'Declined'
	String get declined => 'Declined';

	/// en: 'Set as Admin'
	String get setAsAdmin => 'Set as Admin';

	/// en: 'Set as Member'
	String get setAsMember => 'Set as Member';

	/// en: 'Change Role'
	String get changeRole => 'Change Role';

	/// en: 'Are you sure you want to change "$name"'s role to "$role"?'
	String changeRoleConfirm({required Object name, required Object role}) => 'Are you sure you want to change "${name}"\'s role to "${role}"?';

	/// en: 'Confirm'
	String get confirm => 'Confirm';

	/// en: 'Role changed'
	String get roleChanged => 'Role changed';

	/// en: 'Failed to change role'
	String get roleChangeFailed => 'Failed to change role';
}

// Path: errorMapping.generic
class Translations$errorMapping$generic$en {
	Translations$errorMapping$generic$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Bad Request'
	String get badRequest => 'Bad Request';

	/// en: 'Authentication failed, please login again'
	String get authFailed => 'Authentication failed, please login again';

	/// en: 'Permission denied'
	String get permissionDenied => 'Permission denied';

	/// en: 'Resource not found'
	String get notFound => 'Resource not found';

	/// en: 'Internal server error'
	String get serverError => 'Internal server error';

	/// en: 'System error'
	String get systemError => 'System error';

	/// en: 'Validation failed'
	String get validationFailed => 'Validation failed';
}

// Path: errorMapping.auth
class Translations$errorMapping$auth$en {
	Translations$errorMapping$auth$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Authentication failed'
	String get failed => 'Authentication failed';

	/// en: 'Incorrect email'
	String get emailWrong => 'Incorrect email';

	/// en: 'Incorrect phone number'
	String get phoneWrong => 'Incorrect phone number';

	/// en: 'Phone number already registered'
	String get phoneRegistered => 'Phone number already registered';

	/// en: 'Email already registered'
	String get emailRegistered => 'Email already registered';

	/// en: 'Failed to send verification code'
	String get sendFailed => 'Failed to send verification code';

	/// en: 'Verification code expired'
	String get expired => 'Verification code expired';

	/// en: 'Code sent too frequently'
	String get tooFrequent => 'Code sent too frequently';

	/// en: 'Unsupported code type'
	String get unsupportedType => 'Unsupported code type';

	/// en: 'Incorrect password'
	String get wrongPassword => 'Incorrect password';

	/// en: 'User not found'
	String get userNotFound => 'User not found';

	/// en: 'Preference parameters missing'
	String get prefsMissing => 'Preference parameters missing';

	/// en: 'Invalid client timezone'
	String get invalidTimezone => 'Invalid client timezone';
}

// Path: errorMapping.transaction
class Translations$errorMapping$transaction$en {
	Translations$errorMapping$transaction$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Comment content cannot be empty'
	String get commentEmpty => 'Comment content cannot be empty';

	/// en: 'Invalid parent comment ID'
	String get invalidParent => 'Invalid parent comment ID';

	/// en: 'Failed to save comment'
	String get saveFailed => 'Failed to save comment';

	/// en: 'Failed to delete comment'
	String get deleteFailed => 'Failed to delete comment';

	/// en: 'Transaction does not exist'
	String get notExists => 'Transaction does not exist';
}

// Path: errorMapping.space
class Translations$errorMapping$space$en {
	Translations$errorMapping$space$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Shared space not found or access denied'
	String get notFound => 'Shared space not found or access denied';

	/// en: 'No permission to invite members'
	String get inviteDenied => 'No permission to invite members';

	/// en: 'Cannot invite yourself'
	String get inviteSelf => 'Cannot invite yourself';

	/// en: 'Invitation sent'
	String get inviteSent => 'Invitation sent';

	/// en: 'User is already a member or invited'
	String get alreadyMember => 'User is already a member or invited';

	/// en: 'Invalid action'
	String get invalidAction => 'Invalid action';

	/// en: 'Invitation does not exist'
	String get invitationNotFound => 'Invitation does not exist';

	/// en: 'Only owner can perform this action'
	String get onlyOwner => 'Only owner can perform this action';

	/// en: 'Owner cannot be removed'
	String get ownerNotRemovable => 'Owner cannot be removed';

	/// en: 'Member not found'
	String get memberNotFound => 'Member not found';

	/// en: 'User is not a member of this space'
	String get notMember => 'User is not a member of this space';

	/// en: 'Owner cannot leave directly, please transfer ownership first'
	String get ownerCantLeave => 'Owner cannot leave directly, please transfer ownership first';

	/// en: 'Invalid invitation code'
	String get invalidCode => 'Invalid invitation code';

	/// en: 'Invitation code expired or usage limit reached'
	String get codeExpired => 'Invitation code expired or usage limit reached';

	/// en: 'Transaction already in this space'
	String get transactionAlreadyInSpace => 'Transaction already in this space';
}

// Path: errorMapping.recurring
class Translations$errorMapping$recurring$en {
	Translations$errorMapping$recurring$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Invalid recurrence rule'
	String get invalidRule => 'Invalid recurrence rule';

	/// en: 'Recurrence rule not found'
	String get ruleNotFound => 'Recurrence rule not found';
}

// Path: errorMapping.upload
class Translations$errorMapping$upload$en {
	Translations$errorMapping$upload$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No file uploaded'
	String get noFile => 'No file uploaded';

	/// en: 'File too large'
	String get tooLarge => 'File too large';

	/// en: 'Unsupported file type'
	String get unsupportedType => 'Unsupported file type';

	/// en: 'Too many files'
	String get tooManyFiles => 'Too many files';
}

// Path: errorMapping.storage
class Translations$errorMapping$storage$en {
	Translations$errorMapping$storage$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Storage config not found or access denied'
	String get configNotFound => 'Storage config not found or access denied';

	/// en: 'Cannot delete: storage config is still in use by attachments'
	String get configInUse => 'Cannot delete: storage config is still in use by attachments';

	/// en: 'Invalid storage provider type'
	String get invalidProviderType => 'Invalid storage provider type';
}

// Path: errorMapping.ai
class Translations$errorMapping$ai$en {
	Translations$errorMapping$ai$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Context limit exceeded'
	String get contextLimit => 'Context limit exceeded';

	/// en: 'Insufficient tokens'
	String get tokenLimit => 'Insufficient tokens';

	/// en: 'Empty user message'
	String get emptyMessage => 'Empty user message';
}

// Path: notification.types
class Translations$notification$types$en {
	Translations$notification$types$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'System'
	String get system => 'System';

	/// en: 'Space Invite'
	String get spaceInvite => 'Space Invite';

	/// en: 'Space Activity'
	String get spaceActivity => 'Space Activity';

	/// en: 'Bill Comment'
	String get billComment => 'Bill Comment';

	/// en: 'Budget Alert'
	String get budgetAlert => 'Budget Alert';

	/// en: 'Transaction'
	String get transaction => 'Transaction';
}

// Path: notification.semantic
class Translations$notification$semantic$en {
	Translations$notification$semantic$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '${name} joined your space'
	String memberJoined({required Object name}) => '${name} joined your space';

	/// en: 'A new member joined "${space}"'
	String memberJoinedDetail({required Object space}) => 'A new member joined "${space}"';

	/// en: 'Welcome to "${space}"'
	String welcome({required Object space}) => 'Welcome to "${space}"';

	/// en: '${name} recorded a new expense'
	String newTransaction({required Object name}) => '${name} recorded a new expense';

	/// en: '${amount} in "${space}"'
	String newTransactionDetail({required Object amount, required Object space}) => '${amount} in "${space}"';

	/// en: '${name} left the space'
	String memberLeft({required Object name}) => '${name} left the space';

	/// en: 'Recurring transaction pending'
	String get recurringPending => 'Recurring transaction pending';

	/// en: '${description} ${amount}, awaiting your confirmation'
	String recurringPendingDetail({required Object description, required Object amount}) => '${description} ${amount}, awaiting your confirmation';
}

// Path: chat.tools.done
class Translations$chat$tools$done$en {
	Translations$chat$tools$done$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Read file'
	String get read_file => 'Read file';

	/// en: 'Searched transactions'
	String get search_transactions => 'Searched transactions';

	/// en: 'Checked budget'
	String get query_budget_status => 'Checked budget';

	/// en: 'Created budget'
	String get create_budget => 'Created budget';

	/// en: 'Analyzed cash flow'
	String get get_cash_flow_analysis => 'Analyzed cash flow';

	/// en: 'Calculated health score'
	String get get_financial_health_score => 'Calculated health score';

	/// en: 'Financial report ready'
	String get get_financial_summary => 'Financial report ready';

	/// en: 'Health evaluation complete'
	String get evaluate_financial_health => 'Health evaluation complete';

	/// en: 'Balance forecast ready'
	String get forecast_balance => 'Balance forecast ready';

	/// en: 'Impact simulation complete'
	String get simulate_expense_impact => 'Impact simulation complete';

	/// en: 'Recorded transactions'
	String get record_transactions => 'Recorded transactions';

	/// en: 'Recorded transaction'
	String get create_transaction => 'Recorded transaction';

	/// en: 'Searched the web'
	String get duckduckgo_search => 'Searched the web';

	/// en: 'Transfer complete'
	String get execute_transfer => 'Transfer complete';

	/// en: 'Browsed directory'
	String get list_dir => 'Browsed directory';

	/// en: 'Processing complete'
	String get execute => 'Processing complete';

	/// en: 'Spending analysis complete'
	String get analyze_spending => 'Spending analysis complete';

	/// en: 'Cashflow analysis complete'
	String get analyze_cashflow => 'Cashflow analysis complete';

	/// en: 'Budget suggestion complete'
	String get suggest_budget => 'Budget suggestion complete';

	/// en: 'Shared spaces loaded'
	String get list_spaces => 'Shared spaces loaded';

	/// en: 'Space summary ready'
	String get query_space_summary => 'Space summary ready';

	/// en: 'Transfer ready'
	String get prepare_transfer => 'Transfer ready';

	/// en: 'Processing complete'
	String get unknown => 'Processing complete';

	/// en: '財務分析完成'
	String get analyze_finance => '財務分析完成';

	/// en: '財務預測完成'
	String get forecast_finance => '財務預測完成';

	/// en: '預算分析完成'
	String get analyze_budget => '預算分析完成';

	/// en: '審計分析完成'
	String get audit_analysis => '審計分析完成';

	/// en: '預算處理完成'
	String get budget_ops => '預算處理完成';

	/// en: '共享帳單創建完成'
	String get create_shared_transaction => '共享帳單創建完成';

	/// en: 'Budget simulation prepared'
	String get prepareBudgetSimulation => 'Budget simulation prepared';

	/// en: 'Budget simulation completed'
	String get simulateBudget => 'Budget simulation completed';
}

// Path: chat.tools.failed
class Translations$chat$tools$failed$en {
	Translations$chat$tools$failed$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Action failed'
	String get unknown => 'Action failed';
}

// Path: chat.genui.expenseSummary
class Translations$chat$genui$expenseSummary$en {
	Translations$chat$genui$expenseSummary$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Total Expense'
	String get totalExpense => 'Total Expense';

	/// en: 'Main Expenses'
	String get mainExpenses => 'Main Expenses';

	/// en: 'View all $count transactions'
	String viewAll({required Object count}) => 'View all ${count} transactions';

	/// en: 'Transaction Details'
	String get details => 'Transaction Details';
}

// Path: chat.genui.transactionList
class Translations$chat$genui$transactionList$en {
	Translations$chat$genui$transactionList$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Search Results ($count)'
	String searchResults({required Object count}) => 'Search Results (${count})';

	/// en: 'Loaded $count'
	String loaded({required Object count}) => 'Loaded ${count}';

	/// en: 'No transactions found'
	String get noResults => 'No transactions found';

	/// en: 'Scroll to load more'
	String get loadMore => 'Scroll to load more';

	/// en: 'All loaded'
	String get allLoaded => 'All loaded';
}

// Path: chat.genui.transactionGroupReceipt
class Translations$chat$genui$transactionGroupReceipt$en {
	Translations$chat$genui$transactionGroupReceipt$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Successfully'
	String get title => 'Successfully';

	/// en: '$count items'
	String count({required Object count}) => '${count} items';

	/// en: 'Total'
	String get total => 'Total';

	/// en: 'Select Account'
	String get selectAccount => 'Select Account';

	/// en: 'Automatically generate transactions by rule'
	String get autoGenerateByRule => 'Automatically generate transactions by rule';

	/// en: 'This account will be applied to all transactions above'
	String get selectAccountSubtitle => 'This account will be applied to all transactions above';

	/// en: 'Associated: $name'
	String associatedAccount({required Object name}) => 'Associated: ${name}';

	/// en: 'Click to associate account'
	String get clickToAssociate => 'Click to associate account';

	/// en: 'Successfully associated account to all transactions'
	String get associateSuccess => 'Successfully associated account to all transactions';

	/// en: 'Action failed: $error'
	String associateFailed({required Object error}) => 'Action failed: ${error}';

	/// en: 'Account'
	String get accountAssociation => 'Account';

	/// en: 'Shared Space'
	String get sharedSpace => 'Shared Space';

	/// en: 'Not linked'
	String get notAssociated => 'Not linked';

	/// en: 'Add'
	String get addSpace => 'Add';

	/// en: 'Select Shared Space'
	String get selectSpace => 'Select Shared Space';

	/// en: 'Linked to shared space'
	String get spaceAssociateSuccess => 'Linked to shared space';

	/// en: 'Failed to link: $error'
	String spaceAssociateFailed({required Object error}) => 'Failed to link: ${error}';

	/// en: 'Currency Mismatch'
	String get currencyMismatchTitle => 'Currency Mismatch';

	/// en: 'The transaction currency differs from the account currency. The account balance will be deducted at the exchange rate.'
	String get currencyMismatchDesc => 'The transaction currency differs from the account currency. The account balance will be deducted at the exchange rate.';

	/// en: 'Transaction Amount'
	String get transactionAmount => 'Transaction Amount';

	/// en: 'Account Currency'
	String get accountCurrency => 'Account Currency';

	/// en: 'Target Account'
	String get targetAccount => 'Target Account';

	/// en: 'Note: Account balance will be converted using current exchange rate'
	String get currencyMismatchNote => 'Note: Account balance will be converted using current exchange rate';

	/// en: 'Confirm'
	String get confirmAssociate => 'Confirm';

	/// en: '$count spaces'
	String spaceCount({required Object count}) => '${count} spaces';
}

// Path: chat.genui.budgetReceipt
class Translations$chat$genui$budgetReceipt$en {
	Translations$chat$genui$budgetReceipt$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'New Budget'
	String get newBudget => 'New Budget';

	/// en: 'Budget Created'
	String get budgetCreated => 'Budget Created';

	/// en: 'Rollover Budget'
	String get rolloverBudget => 'Rollover Budget';

	/// en: 'Failed to create budget'
	String get createFailed => 'Failed to create budget';

	/// en: 'This Month'
	String get thisMonth => 'This Month';

	/// en: '$start/$startDay - $end/$endDay'
	String dateRange({required Object start, required Object startDay, required Object end, required Object endDay}) => '${start}/${startDay} - ${end}/${endDay}';
}

// Path: chat.genui.budgetStatusCard
class Translations$chat$genui$budgetStatusCard$en {
	Translations$chat$genui$budgetStatusCard$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Budget'
	String get budget => 'Budget';

	/// en: 'Budget Overview'
	String get overview => 'Budget Overview';

	/// en: 'Total Budget'
	String get totalBudget => 'Total Budget';

	/// en: 'Used ¥$amount'
	String spent({required Object amount}) => 'Used ¥${amount}';

	/// en: 'Remaining ¥$amount'
	String remaining({required Object amount}) => 'Remaining ¥${amount}';

	/// en: 'Exceeded'
	String get exceeded => 'Exceeded';

	/// en: 'Warning'
	String get warning => 'Warning';

	/// en: 'Healthy'
	String get plentiful => 'Healthy';

	/// en: 'Normal'
	String get normal => 'Normal';
}

// Path: chat.genui.cashFlowForecast
class Translations$chat$genui$cashFlowForecast$en {
	Translations$chat$genui$cashFlowForecast$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Cash Flow Forecast'
	String get title => 'Cash Flow Forecast';

	/// en: 'Recurring Transaction'
	String get recurringTransaction => 'Recurring Transaction';

	/// en: 'Recurring Income'
	String get recurringIncome => 'Recurring Income';

	/// en: 'Recurring Expense'
	String get recurringExpense => 'Recurring Expense';

	/// en: 'Recurring Transfer'
	String get recurringTransfer => 'Recurring Transfer';

	/// en: 'Next $days days'
	String nextDays({required Object days}) => 'Next ${days} days';

	/// en: 'No forecast data'
	String get noData => 'No forecast data';

	/// en: 'Forecast Summary'
	String get summary => 'Forecast Summary';

	/// en: 'Predicted Variable Expense'
	String get variableExpense => 'Predicted Variable Expense';

	/// en: 'Est. Net Change'
	String get netChange => 'Est. Net Change';

	/// en: 'Key Events'
	String get keyEvents => 'Key Events';

	/// en: 'No significant events in forecast period'
	String get noSignificantEvents => 'No significant events in forecast period';

	/// en: 'M/d'
	String get dateFormat => 'M/d';
}

// Path: chat.genui.healthScore
class Translations$chat$genui$healthScore$en {
	Translations$chat$genui$healthScore$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Financial Health'
	String get title => 'Financial Health';

	/// en: 'Suggestions'
	String get suggestions => 'Suggestions';

	/// en: '$score pts'
	String scorePoint({required Object score}) => '${score} pts';

	late final Translations$chat$genui$healthScore$status$en status = Translations$chat$genui$healthScore$status$en._(_root);
}

// Path: chat.genui.spaceSelector
class Translations$chat$genui$spaceSelector$en {
	Translations$chat$genui$spaceSelector$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Selected'
	String get selected => 'Selected';

	/// en: 'Unnamed Space'
	String get unnamedSpace => 'Unnamed Space';

	/// en: 'Linked'
	String get linked => 'Linked';

	/// en: 'Owner'
	String get roleOwner => 'Owner';

	/// en: 'Admin'
	String get roleAdmin => 'Admin';

	/// en: 'Member'
	String get roleMember => 'Member';

	/// en: 'Associate selected space'
	String get associateAction => 'Associate selected space';
}

// Path: chat.genui.transferPath
class Translations$chat$genui$transferPath$en {
	Translations$chat$genui$transferPath$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Select Source Account'
	String get selectSource => 'Select Source Account';

	/// en: 'Select Target Account'
	String get selectTarget => 'Select Target Account';

	/// en: 'From (Source)'
	String get from => 'From (Source)';

	/// en: 'To (Target)'
	String get to => 'To (Target)';

	/// en: 'Select'
	String get select => 'Select';

	/// en: 'Operation Cancelled'
	String get cancelled => 'Operation Cancelled';

	/// en: 'Failed to load account data'
	String get loadError => 'Failed to load account data';

	/// en: 'Account info missing in history'
	String get historyMissing => 'Account info missing in history';

	/// en: 'Amount Unconfirmed'
	String get amountUnconfirmed => 'Amount Unconfirmed';

	/// en: 'Confirmed: $source → $target'
	String confirmedWithArrow({required Object source, required Object target}) => 'Confirmed: ${source} → ${target}';

	/// en: 'Confirm: $source → $target'
	String confirmAction({required Object source, required Object target}) => 'Confirm: ${source} → ${target}';

	/// en: 'Please select source account'
	String get pleaseSelectSource => 'Please select source account';

	/// en: 'Please select target account'
	String get pleaseSelectTarget => 'Please select target account';

	/// en: 'Confirm Transfer Path'
	String get confirmLinks => 'Confirm Transfer Path';

	/// en: 'Path Locked'
	String get linkLocked => 'Path Locked';

	/// en: 'Click button below to confirm'
	String get clickToConfirm => 'Click button below to confirm';

	/// en: 'Reselect'
	String get reselect => 'Reselect';

	/// en: 'Transfer'
	String get title => 'Transfer';

	/// en: 'History'
	String get history => 'History';

	/// en: 'Unknown Account'
	String get unknownAccount => 'Unknown Account';

	/// en: 'Confirmed'
	String get confirmed => 'Confirmed';

	/// en: 'Execute transfer according to my selection'
	String get executeAction => 'Execute transfer according to my selection';
}

// Path: chat.genui.transactionCard
class Translations$chat$genui$transactionCard$en {
	Translations$chat$genui$transactionCard$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Transaction Successful'
	String get title => 'Transaction Successful';

	/// en: 'Associated Account'
	String get associatedAccount => 'Associated Account';

	/// en: 'Not counted'
	String get notCounted => 'Not counted';

	/// en: 'Modify'
	String get modify => 'Modify';

	/// en: 'Associate Account'
	String get associate => 'Associate Account';

	/// en: 'Select Account'
	String get selectAccount => 'Select Account';

	/// en: 'Automatically generate transactions by rule'
	String get autoGenerateByRule => 'Automatically generate transactions by rule';

	/// en: 'No accounts available, please add one first'
	String get noAccount => 'No accounts available, please add one first';

	/// en: 'Transaction ID missing, cannot update'
	String get missingId => 'Transaction ID missing, cannot update';

	/// en: 'Associated to $name'
	String associatedTo({required Object name}) => 'Associated to ${name}';

	/// en: 'Update failed: $error'
	String updateFailed({required Object error}) => 'Update failed: ${error}';

	/// en: 'Shared Space'
	String get sharedSpace => 'Shared Space';

	/// en: 'No shared spaces available'
	String get noSpace => 'No shared spaces available';

	/// en: 'Select Shared Space'
	String get selectSpace => 'Select Shared Space';

	/// en: 'Linked to shared space'
	String get linkedToSpace => 'Linked to shared space';
}

// Path: chat.genui.cashFlowCard
class Translations$chat$genui$cashFlowCard$en {
	Translations$chat$genui$cashFlowCard$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Cash Flow Analysis'
	String get title => 'Cash Flow Analysis';

	/// en: 'Savings $rate%'
	String savingsRate({required Object rate}) => 'Savings ${rate}%';

	/// en: 'Total Income'
	String get totalIncome => 'Total Income';

	/// en: 'Total Expense'
	String get totalExpense => 'Total Expense';

	/// en: 'Essential'
	String get essentialExpense => 'Essential';

	/// en: 'Discretionary'
	String get discretionaryExpense => 'Discretionary';

	/// en: 'AI Insight'
	String get aiInsight => 'AI Insight';
}

// Path: chat.genui.transactionConfirmation
class Translations$chat$genui$transactionConfirmation$en {
	Translations$chat$genui$transactionConfirmation$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '检测到多个关联账户'
	String get multipleAccounts => '检测到多个关联账户';

	/// en: '已确认'
	String get confirmed => '已确认';
}

// Path: chat.genui.budgetAnalysis
class Translations$chat$genui$budgetAnalysis$en {
	Translations$chat$genui$budgetAnalysis$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '预算分析报告'
	String get title => '预算分析报告';

	/// en: '过去 $days 天'
	String periodDays({required Object days}) => '过去 ${days} 天';

	/// en: '总支出'
	String get totalExpense => '总支出';

	/// en: '环比 $change%'
	String momChange({required Object change}) => '环比 ${change}%';

	/// en: '分类占比'
	String get categoryDistribution => '分类占比';

	/// en: '大额支出'
	String get topSpenders => '大额支出';

	/// en: '$amount万'
	String amountWan({required Object amount}) => '${amount}万';
}

// Path: chat.genui.budgetSimulator
class Translations$chat$genui$budgetSimulator$en {
	Translations$chat$genui$budgetSimulator$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '預算壓力模擬器'
	String get title => '預算壓力模擬器';

	/// en: '目標預算金額'
	String get targetAmount => '目標預算金額';

	/// en: '預計超支機率'
	String get overspendProbability => '預計超支機率';

	/// en: '風險極低'
	String get riskLow => '風險極低';

	/// en: '風險適中'
	String get riskMedium => '風險適中';

	/// en: '超支高危'
	String get riskHigh => '超支高危';

	/// en: '正在評估歷史消費習慣...'
	String get evaluating => '正在評估歷史消費習慣...';

	/// en: '歷史月均'
	String get historyAverage => '歷史月均';

	/// en: '每日限額'
	String get dailyAllowance => '每日限額';

	/// en: '放棄'
	String get cancel => '放棄';

	/// en: '採用此預算'
	String get confirm => '採用此預算';
}

// Path: chat.welcome.morning
class Translations$chat$welcome$morning$en {
	Translations$chat$welcome$morning$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Start your day by tracking'
	String get subtitle => 'Start your day by tracking';

	late final Translations$chat$welcome$morning$breakfast$en breakfast = Translations$chat$welcome$morning$breakfast$en._(_root);
	late final Translations$chat$welcome$morning$yesterdayReview$en yesterdayReview = Translations$chat$welcome$morning$yesterdayReview$en._(_root);
	late final Translations$chat$welcome$morning$todayBudget$en todayBudget = Translations$chat$welcome$morning$todayBudget$en._(_root);
}

// Path: chat.welcome.midday
class Translations$chat$welcome$midday$en {
	Translations$chat$welcome$midday$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Good Afternoon'
	String get greeting => 'Good Afternoon';

	/// en: 'Quick record during lunch'
	String get subtitle => 'Quick record during lunch';

	late final Translations$chat$welcome$midday$lunch$en lunch = Translations$chat$welcome$midday$lunch$en._(_root);
	late final Translations$chat$welcome$midday$weeklyExpense$en weeklyExpense = Translations$chat$welcome$midday$weeklyExpense$en._(_root);
	late final Translations$chat$welcome$midday$checkBalance$en checkBalance = Translations$chat$welcome$midday$checkBalance$en._(_root);
}

// Path: chat.welcome.afternoon
class Translations$chat$welcome$afternoon$en {
	Translations$chat$welcome$afternoon$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Tea time, let's review finances'
	String get subtitle => 'Tea time, let\'s review finances';

	late final Translations$chat$welcome$afternoon$quickRecord$en quickRecord = Translations$chat$welcome$afternoon$quickRecord$en._(_root);
	late final Translations$chat$welcome$afternoon$analyzeSpending$en analyzeSpending = Translations$chat$welcome$afternoon$analyzeSpending$en._(_root);
	late final Translations$chat$welcome$afternoon$budgetProgress$en budgetProgress = Translations$chat$welcome$afternoon$budgetProgress$en._(_root);
}

// Path: chat.welcome.evening
class Translations$chat$welcome$evening$en {
	Translations$chat$welcome$evening$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'End of day, time to balance the books'
	String get subtitle => 'End of day, time to balance the books';

	late final Translations$chat$welcome$evening$dinner$en dinner = Translations$chat$welcome$evening$dinner$en._(_root);
	late final Translations$chat$welcome$evening$todaySummary$en todaySummary = Translations$chat$welcome$evening$todaySummary$en._(_root);
	late final Translations$chat$welcome$evening$tomorrowPlan$en tomorrowPlan = Translations$chat$welcome$evening$tomorrowPlan$en._(_root);
}

// Path: chat.welcome.night
class Translations$chat$welcome$night$en {
	Translations$chat$welcome$night$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Late Night'
	String get greeting => 'Late Night';

	/// en: 'Quiet time for financial planning'
	String get subtitle => 'Quiet time for financial planning';

	late final Translations$chat$welcome$night$makeupRecord$en makeupRecord = Translations$chat$welcome$night$makeupRecord$en._(_root);
	late final Translations$chat$welcome$night$monthlyReview$en monthlyReview = Translations$chat$welcome$night$monthlyReview$en._(_root);
	late final Translations$chat$welcome$night$financialThinking$en financialThinking = Translations$chat$welcome$night$financialThinking$en._(_root);
}

// Path: chat.genui.healthScore.status
class Translations$chat$genui$healthScore$status$en {
	Translations$chat$genui$healthScore$status$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Excellent'
	String get excellent => 'Excellent';

	/// en: 'Good'
	String get good => 'Good';

	/// en: 'Fair'
	String get fair => 'Fair';

	/// en: 'Needs Improvement'
	String get needsImprovement => 'Needs Improvement';

	/// en: 'Poor'
	String get poor => 'Poor';
}

// Path: chat.welcome.morning.breakfast
class Translations$chat$welcome$morning$breakfast$en {
	Translations$chat$welcome$morning$breakfast$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Breakfast'
	String get title => 'Breakfast';

	/// en: 'Record breakfast expense'
	String get prompt => 'Record breakfast expense';

	/// en: 'Log today's first expense'
	String get description => 'Log today\'s first expense';
}

// Path: chat.welcome.morning.yesterdayReview
class Translations$chat$welcome$morning$yesterdayReview$en {
	Translations$chat$welcome$morning$yesterdayReview$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Yesterday Review'
	String get title => 'Yesterday Review';

	/// en: 'Analyze yesterday's spending'
	String get prompt => 'Analyze yesterday\'s spending';

	/// en: 'Check how much you spent yesterday'
	String get description => 'Check how much you spent yesterday';
}

// Path: chat.welcome.morning.todayBudget
class Translations$chat$welcome$morning$todayBudget$en {
	Translations$chat$welcome$morning$todayBudget$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Today's Budget'
	String get title => 'Today\'s Budget';

	/// en: 'How much budget left for today'
	String get prompt => 'How much budget left for today';

	/// en: 'Plan your spending for today'
	String get description => 'Plan your spending for today';
}

// Path: chat.welcome.midday.lunch
class Translations$chat$welcome$midday$lunch$en {
	Translations$chat$welcome$midday$lunch$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Lunch'
	String get title => 'Lunch';

	/// en: 'Record lunch expense'
	String get prompt => 'Record lunch expense';

	/// en: 'Log your lunch spending'
	String get description => 'Log your lunch spending';
}

// Path: chat.welcome.midday.weeklyExpense
class Translations$chat$welcome$midday$weeklyExpense$en {
	Translations$chat$welcome$midday$weeklyExpense$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Weekly Spending'
	String get title => 'Weekly Spending';

	/// en: 'Analyze this week's spending'
	String get prompt => 'Analyze this week\'s spending';

	/// en: 'See your weekly expenses'
	String get description => 'See your weekly expenses';
}

// Path: chat.welcome.midday.checkBalance
class Translations$chat$welcome$midday$checkBalance$en {
	Translations$chat$welcome$midday$checkBalance$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Check Balance'
	String get title => 'Check Balance';

	/// en: 'Check my account balance'
	String get prompt => 'Check my account balance';

	/// en: 'View your account balances'
	String get description => 'View your account balances';
}

// Path: chat.welcome.afternoon.quickRecord
class Translations$chat$welcome$afternoon$quickRecord$en {
	Translations$chat$welcome$afternoon$quickRecord$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Quick Record'
	String get title => 'Quick Record';

	/// en: 'Help me record an expense'
	String get prompt => 'Help me record an expense';

	/// en: 'Quickly log a transaction'
	String get description => 'Quickly log a transaction';
}

// Path: chat.welcome.afternoon.analyzeSpending
class Translations$chat$welcome$afternoon$analyzeSpending$en {
	Translations$chat$welcome$afternoon$analyzeSpending$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Analyze Spending'
	String get title => 'Analyze Spending';

	/// en: 'Analyze this month's spending'
	String get prompt => 'Analyze this month\'s spending';

	/// en: 'View spending trends and breakdown'
	String get description => 'View spending trends and breakdown';
}

// Path: chat.welcome.afternoon.budgetProgress
class Translations$chat$welcome$afternoon$budgetProgress$en {
	Translations$chat$welcome$afternoon$budgetProgress$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Budget Progress'
	String get title => 'Budget Progress';

	/// en: 'Check budget status'
	String get prompt => 'Check budget status';

	/// en: 'See how your budget is doing'
	String get description => 'See how your budget is doing';
}

// Path: chat.welcome.evening.dinner
class Translations$chat$welcome$evening$dinner$en {
	Translations$chat$welcome$evening$dinner$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Dinner'
	String get title => 'Dinner';

	/// en: 'Record dinner expense'
	String get prompt => 'Record dinner expense';

	/// en: 'Log tonight's dinner spending'
	String get description => 'Log tonight\'s dinner spending';
}

// Path: chat.welcome.evening.todaySummary
class Translations$chat$welcome$evening$todaySummary$en {
	Translations$chat$welcome$evening$todaySummary$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Today's Summary'
	String get title => 'Today\'s Summary';

	/// en: 'Summarize today's spending'
	String get prompt => 'Summarize today\'s spending';

	/// en: 'See what you spent today'
	String get description => 'See what you spent today';
}

// Path: chat.welcome.evening.tomorrowPlan
class Translations$chat$welcome$evening$tomorrowPlan$en {
	Translations$chat$welcome$evening$tomorrowPlan$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Tomorrow's Plan'
	String get title => 'Tomorrow\'s Plan';

	/// en: 'What fixed expenses tomorrow'
	String get prompt => 'What fixed expenses tomorrow';

	/// en: 'Plan ahead for tomorrow'
	String get description => 'Plan ahead for tomorrow';
}

// Path: chat.welcome.night.makeupRecord
class Translations$chat$welcome$night$makeupRecord$en {
	Translations$chat$welcome$night$makeupRecord$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Catch Up'
	String get title => 'Catch Up';

	/// en: 'Help me log any missed expenses'
	String get prompt => 'Help me log any missed expenses';

	/// en: 'Record expenses you forgot today'
	String get description => 'Record expenses you forgot today';
}

// Path: chat.welcome.night.monthlyReview
class Translations$chat$welcome$night$monthlyReview$en {
	Translations$chat$welcome$night$monthlyReview$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Monthly Review'
	String get title => 'Monthly Review';

	/// en: 'Analyze this month's spending'
	String get prompt => 'Analyze this month\'s spending';

	/// en: 'Review your monthly expenses'
	String get description => 'Review your monthly expenses';
}

// Path: chat.welcome.night.financialThinking
class Translations$chat$welcome$night$financialThinking$en {
	Translations$chat$welcome$night$financialThinking$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Financial Tips'
	String get title => 'Financial Tips';

	/// en: 'Give me some financial advice'
	String get prompt => 'Give me some financial advice';

	/// en: 'Get AI-powered financial insights'
	String get description => 'Get AI-powered financial insights';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.loading' => 'Loading...',
			'common.error' => 'Error',
			'common.retry' => 'Retry',
			'common.cancel' => 'Cancel',
			'common.confirm' => 'Confirm',
			'common.save' => 'Save',
			'common.delete' => 'Delete',
			'common.edit' => 'Edit',
			'common.add' => 'Add',
			'common.search' => 'Search',
			'common.filter' => 'Filter',
			'common.sort' => 'Sort',
			'common.refresh' => 'Refresh',
			'common.more' => 'More',
			'common.less' => 'Less',
			'common.all' => 'All',
			'common.none' => 'None',
			'common.ok' => 'OK',
			'common.unknown' => 'Unknown',
			'common.noData' => 'No Data',
			'common.loadMore' => 'Load More',
			'common.noMore' => 'No More',
			'common.loadFailed' => 'Loading failed',
			'common.history' => 'Transactions',
			'common.reset' => 'Reset',
			'time.today' => 'Today',
			'time.yesterday' => 'Yesterday',
			'time.dayBeforeYesterday' => 'Day Before Yesterday',
			'time.thisWeek' => 'Week',
			'time.thisMonth' => 'Month',
			'time.thisYear' => 'Year',
			'time.selectDate' => 'Select Date',
			'time.selectTime' => 'Select Time',
			'time.justNow' => 'Just now',
			'time.minutesAgo' => ({required Object count}) => '${count}m ago',
			'time.hoursAgo' => ({required Object count}) => '${count}h ago',
			'time.daysAgo' => ({required Object count}) => '${count}d ago',
			'time.weeksAgo' => ({required Object count}) => '${count}w ago',
			'greeting.morning' => 'Good Morning',
			'greeting.afternoon' => 'Good Afternoon',
			'greeting.evening' => 'Good Evening',
			'navigation.home' => 'Home',
			'navigation.forecast' => 'Forecast',
			'navigation.footprint' => 'Footprint',
			'navigation.profile' => 'Profile',
			'auth.login' => 'Log In',
			'auth.loggingIn' => 'Logging in...',
			'auth.logout' => 'Log Out',
			'auth.logoutSuccess' => 'Logged out successfully',
			'auth.confirmLogoutTitle' => 'Confirm Logout',
			'auth.confirmLogoutContent' => 'Are you sure you want to log out?',
			'auth.register' => 'Sign Up',
			'auth.registering' => 'Signing up...',
			'auth.welcomeBack' => 'Welcome Back',
			'auth.loginSuccess' => 'Welcome back!',
			'auth.loginFailed' => 'Login Failed',
			'auth.pleaseTryAgain' => 'Please try again later.',
			'auth.loginSubtitle' => 'Log in to continue using Finvo',
			'auth.noAccount' => 'Don\'t have an account? Sign Up',
			'auth.createAccount' => 'Create Your Account',
			'auth.setPassword' => 'Set Password',
			'auth.setAccountPassword' => 'Set Your Account Password',
			'auth.completeRegistration' => 'Complete Registration',
			'auth.registrationSuccess' => 'Registration successful!',
			'auth.registrationFailed' => 'Registration failed',
			'auth.email.label' => 'Email',
			'auth.email.placeholder' => 'Enter your email',
			'auth.email.required' => 'Email is required',
			'auth.email.invalid' => 'Please enter a valid email address',
			'auth.password.label' => 'Password',
			'auth.password.placeholder' => 'Enter your password',
			'auth.password.required' => 'Password is required',
			'auth.password.tooShort' => 'Password must be at least 6 characters',
			'auth.password.mustContainNumbersAndLetters' => 'Password must contain both numbers and letters',
			'auth.password.confirm' => 'Confirm Password',
			'auth.password.confirmPlaceholder' => 'Re-enter your password',
			'auth.password.mismatch' => 'Passwords do not match',
			'auth.verificationCode.label' => 'Verification Code',
			'auth.verificationCode.get' => 'Get Code',
			'auth.verificationCode.sending' => 'Sending...',
			'auth.verificationCode.sent' => 'Code sent',
			'auth.verificationCode.sendFailed' => 'Failed to send',
			'auth.verificationCode.placeholder' => 'Optional for now, enter anything',
			'auth.verificationCode.required' => 'Verification code is required',
			'transaction.expense' => 'Expense',
			'transaction.income' => 'Income',
			'transaction.transfer' => 'Transfer',
			'transaction.amount' => 'Amount',
			'transaction.category' => 'Category',
			'transaction.description' => 'Description',
			'transaction.tags' => 'Tags',
			'transaction.saveTransaction' => 'Save Transaction',
			'transaction.pleaseEnterAmount' => 'Please enter amount',
			'transaction.pleaseSelectCategory' => 'Please select category',
			'transaction.saveFailed' => 'Failed to save',
			'transaction.descriptionHint' => 'Record details of this transaction...',
			'transaction.addCustomTag' => 'Add Custom Tag',
			'transaction.commonTags' => 'Common Tags',
			'transaction.maxTagsHint' => ({required Object maxTags}) => 'Maximum ${maxTags} tags allowed',
			'transaction.noTransactionsFound' => 'No transactions found',
			'transaction.tryAdjustingSearch' => 'Try adjusting search criteria or create new transactions',
			'transaction.noDescription' => 'No description',
			'transaction.payment' => 'Payment',
			'transaction.account' => 'Account',
			'transaction.time' => 'Time',
			'transaction.location' => 'Location',
			'transaction.transactionDetail' => 'Transaction Details',
			'transaction.favorite' => 'Favorite',
			'transaction.confirmDelete' => 'Confirm Delete',
			'transaction.deleteTransactionConfirm' => 'Are you sure you want to delete this transaction? This action cannot be undone.',
			'transaction.noActions' => 'No actions available',
			'transaction.deleted' => 'Deleted',
			'transaction.deleteFailed' => 'Delete failed, please try again',
			'transaction.linkedAccount' => 'Linked Account',
			'transaction.linkedSpace' => 'Linked Space',
			'transaction.notLinked' => 'Not linked',
			'transaction.link' => 'Link',
			'transaction.changeAccount' => 'Change Account',
			'transaction.addSpace' => 'Add Space',
			'transaction.nSpaces' => ({required Object count}) => '${count} spaces',
			'transaction.selectLinkedAccount' => 'Select Linked Account',
			'transaction.selectLinkedSpace' => 'Select Linked Space',
			'transaction.noSpacesAvailable' => 'No spaces available',
			'transaction.linkSuccess' => 'Link successful',
			'transaction.linkFailed' => 'Link failed',
			'transaction.rawInput' => 'Message',
			'transaction.noRawInput' => 'No message',
			'transaction.attachments' => ({required Object count}) => '${count} attachments',
			'transaction.viewInConversation' => 'View more in conversation',
			'transaction.statusPending' => 'Pending',
			'home.totalExpense' => 'Total Expense',
			'home.todayExpense' => 'Today\'s',
			'home.monthExpense' => 'This Month\'s',
			'home.yearProgress' => ({required Object year}) => '${year} Progress',
			'home.yearRemainingInfo' => ({required Object days, required Object percent}) => 'Left ${days} days · ${percent}%',
			'home.amountHidden' => '••••••••',
			'home.loadFailed' => 'Load failed',
			'home.noTransactions' => 'No transactions',
			'home.tryRefresh' => 'Pull to refresh',
			'home.noMoreData' => 'No more data',
			'home.userNotLoggedIn' => 'User not logged in',
			'comment.error' => 'Error',
			'comment.commentFailed' => 'Comment failed',
			'comment.replyToPrefix' => ({required Object name}) => 'Reply to @${name}:',
			'comment.reply' => 'Reply',
			'comment.addNote' => 'Add a note...',
			'comment.addNoteWithMention' => 'Comment or @mention members...',
			'comment.confirmDeleteTitle' => 'Confirm Delete',
			'comment.confirmDeleteContent' => 'Are you sure you want to delete this comment? This action cannot be undone.',
			'comment.success' => 'Success',
			'comment.commentDeleted' => 'Comment deleted',
			'comment.deleteFailed' => 'Failed to delete',
			'comment.deleteComment' => 'Delete Comment',
			'comment.hint' => 'Hint',
			'comment.noActions' => 'No actions available',
			'comment.note' => 'Note',
			'comment.noNote' => 'No notes yet',
			'comment.loadFailed' => 'Failed to load notes',
			'calendar.title' => 'Expense Calendar',
			'calendar.weekdays.mon' => 'M',
			'calendar.weekdays.tue' => 'T',
			'calendar.weekdays.wed' => 'W',
			'calendar.weekdays.thu' => 'T',
			'calendar.weekdays.fri' => 'F',
			'calendar.weekdays.sat' => 'S',
			'calendar.weekdays.sun' => 'S',
			'calendar.loadFailed' => 'Failed to load calendar data',
			'calendar.thisMonth' => ({required Object amount}) => 'Month: ${amount}',
			'calendar.counting' => 'Counting...',
			'calendar.unableToCount' => 'Unable to count',
			'calendar.trend' => 'Trend: ',
			'calendar.noTransactionsTitle' => 'No transactions on this day',
			'calendar.loadTransactionFailed' => 'Failed to load transactions',
			'category.dailyConsumption' => 'Daily Expenses',
			'category.transportation' => 'Transportation',
			'category.healthcare' => 'Healthcare',
			'category.housing' => 'Housing & Utilities',
			'category.education' => 'Education',
			'category.incomeCategory' => 'Income',
			'category.socialGifts' => 'Gifts & Donations',
			'category.moneyTransfer' => 'Transfers',
			'category.other' => 'Other',
			'category.foodDining' => 'Food & Dining',
			'category.shoppingRetail' => 'Shopping',
			'category.housingUtilities' => 'Housing & Utilities',
			'category.personalCare' => 'Personal Care',
			'category.entertainment' => 'Entertainment',
			'category.medicalHealth' => 'Medical & Health',
			'category.insurance' => 'Insurance',
			'category.socialGifting' => 'Social & Gifting',
			'category.financialTax' => 'Financial & Tax',
			'category.others' => 'Others',
			'category.salaryWage' => 'Salary',
			'category.businessTrade' => 'Business',
			'category.investmentReturns' => 'Investment Returns',
			'category.giftBonus' => 'Gift & Bonus',
			'category.refundRebate' => 'Refund',
			'category.generalTransfer' => 'Transfer',
			'category.debtRepayment' => 'Debt Repayment',
			'settings.title' => 'Settings',
			'settings.language' => 'Language',
			'settings.languageSettings' => 'Language Settings',
			'settings.selectLanguage' => 'Select Language',
			'settings.languageChanged' => 'Language Changed',
			'settings.restartToApply' => 'Restart app to apply changes',
			'settings.theme' => 'Theme',
			'settings.darkMode' => 'Dark Mode',
			'settings.lightMode' => 'Light Mode',
			'settings.systemMode' => 'Follow System',
			'settings.developerOptions' => 'Developer Options',
			'settings.authDebug' => 'Auth Debug',
			'settings.authDebugSubtitle' => 'View authentication status and debug info',
			'settings.fontTest' => 'Font Test',
			'settings.fontTestSubtitle' => 'Test application font display',
			'settings.helpAndFeedback' => 'Help & Feedback',
			'settings.helpAndFeedbackSubtitle' => 'Get help or provide feedback',
			'settings.aboutApp' => 'About',
			'settings.aboutAppSubtitle' => 'Version info and check for updates',
			'settings.checkUpdate' => 'Check for Updates',
			'settings.checkingUpdate' => 'Checking for updates...',
			'settings.latestVersionToast' => 'You are on the latest version',
			'settings.newVersionTitle' => 'New Version Available',
			'settings.updateNow' => 'Update Now',
			'settings.updateLater' => 'Later',
			'settings.fetchUpdateFailed' => 'Failed to check for updates, please try again later',
			'settings.currencyChangedRefreshHint' => ({required Object currency}) => 'Switched to ${currency}. New transactions will use this currency.',
			'settings.sharedSpace' => 'Shared Space',
			'settings.speechRecognition' => 'Speech Recognition',
			'settings.speechRecognitionSubtitle' => 'Configure voice input parameters',
			'settings.amountDisplayStyle' => 'Amount Display Style',
			'settings.currency' => 'Currency',
			'settings.appearance' => 'Appearance Settings',
			'settings.appearanceSubtitle' => 'Theme mode and color scheme',
			'settings.speechTest' => 'Speech Test',
			'settings.speechTestSubtitle' => 'Test WebSocket speech connection',
			'settings.userTypeRegular' => 'Regular User',
			'settings.selectAmountStyle' => 'Select Amount Display Style',
			'settings.amountStyleNotice' => 'Note: Amount styles are primarily applied to \'Transactions\' and \'Trends\'. To maintain visual clarity, \'Account Balances\' and \'Asset Summaries\' will remain in neutral colors.',
			'settings.currencyDescription' => 'Choose your preferred display currency. All amounts will be displayed in this currency.',
			'settings.editUsername' => 'Edit Username',
			'settings.enterUsername' => 'Enter username',
			'settings.usernameRequired' => 'Username is required',
			'settings.usernameUpdated' => 'Username updated',
			'settings.avatarUpdated' => 'Avatar updated',
			'settings.appearanceUpdated' => '外观设置已更新',
			'appearance.title' => 'Appearance Settings',
			'appearance.themeMode' => 'Theme Mode',
			'appearance.light' => 'Light',
			'appearance.dark' => 'Dark',
			'appearance.system' => 'System',
			'appearance.colorScheme' => 'Color Scheme',
			'appearance.palettes.zinc' => 'Zinc',
			'appearance.palettes.slate' => 'Slate',
			'appearance.palettes.red' => 'Red',
			'appearance.palettes.rose' => 'Rose',
			'appearance.palettes.orange' => 'Orange',
			'appearance.palettes.green' => 'Green',
			'appearance.palettes.blue' => 'Blue',
			'appearance.palettes.yellow' => 'Yellow',
			'appearance.palettes.violet' => 'Violet',
			'speech.title' => 'Speech Recognition Settings',
			'speech.service' => 'Speech Recognition Service',
			'speech.systemVoice' => 'System Voice',
			'speech.systemVoiceSubtitle' => 'Use built-in device service (Recommended)',
			'speech.selfHostedASR' => 'Self-hosted ASR',
			'speech.selfHostedASRSubtitle' => 'Use WebSocket connection to self-hosted service',
			'speech.serverConfig' => 'Server Configuration',
			'speech.serverAddress' => 'Server Address',
			'speech.port' => 'Port',
			'speech.path' => 'Path',
			'speech.saveConfig' => 'Save Configuration',
			'speech.info' => 'Information',
			'speech.infoContent' => '• System Voice: Uses device service, no config needed, faster response\n• Self-hosted ASR: Suitable for custom models or offline scenarios\n\nChanges will take effect next time you use voice input.',
			'speech.enterAddress' => 'Please enter server address',
			'speech.enterValidPort' => 'Please enter a valid port (1-65535)',
			'speech.configSaved' => 'Configuration saved',
			'speech.systemVoiceRestrictedTitle' => 'System Speech Unavailable',
			'speech.systemVoiceRestrictedContent' => 'System speech service is unavailable or disabled. You can check system settings or configure a custom WebSocket ASR in Speech Settings.',
			'speech.dictationDisabledTitle' => 'Dictation Disabled',
			'speech.dictationDisabledContent' => 'System speech dictation service is disabled. On iOS devices, please go to Settings -> General -> Keyboard and enable Dictation.',
			'speech.permissionDeniedTitle' => 'Permissions Required',
			'speech.permissionDeniedContent' => 'Microphone and speech recognition permissions are required for this feature. Please grant them in System Settings.',
			'speech.goToSettings' => 'Go to Settings',
			'speech.systemVoiceStatusAvailable' => 'System Speech Supported',
			'speech.systemVoiceStatusRestricted' => 'System Speech Restricted or Unavailable (Self-hosted ASR recommended)',
			'speech.serviceNotConfigured' => 'Speech service is not configured. Please set the server address in Speech Settings.',
			'speech.connectionFailedTitle' => 'Speech Service Connection Failed',
			'speech.connectionFailed' => 'Cannot connect to WebSocket speech recognition service. Please check your server address, port, or network connectivity.',
			'speech.noSpeechRecognized' => 'No speech input detected, please try again.',
			'amountTheme.chinaMarket' => 'China Market Style',
			'amountTheme.chinaMarketDesc' => 'Red up, Green/Black down (Recommended)',
			'amountTheme.international' => 'International Standard',
			'amountTheme.internationalDesc' => 'Green up, Red down',
			'amountTheme.minimalist' => 'Minimalist',
			'amountTheme.minimalistDesc' => 'Distinguish with symbols only',
			'amountTheme.colorBlind' => 'Color Blind Friendly',
			'amountTheme.colorBlindDesc' => 'Blue-Orange color scheme',
			'locale.chinese' => 'Simplified Chinese',
			'locale.english' => 'English',
			'locale.japanese' => 'Japanese',
			'locale.korean' => 'Korean',
			'locale.traditionalChinese' => 'Traditional Chinese',
			'budget.title' => 'Budget Management',
			'budget.detail' => 'Budget Details',
			'budget.info' => 'Budget Info',
			'budget.totalBudget' => 'Total Budget',
			'budget.categoryBudget' => 'Category Budget',
			'budget.monthlySummary' => 'Monthly Budget Summary',
			'budget.used' => 'Used',
			'budget.remaining' => 'Remaining',
			'budget.overspent' => 'Overspent',
			'budget.budget' => 'Budget',
			'budget.loadFailed' => 'Failed to load',
			'budget.noBudget' => 'No budgets yet',
			'budget.createHint' => 'Tap the button below to set up your budget',
			'budget.paused' => 'Paused',
			'budget.pause' => 'Pause',
			'budget.resume' => 'Resume',
			'budget.budgetPaused' => 'Budget paused',
			'budget.budgetResumed' => 'Budget resumed',
			'budget.operationFailed' => 'Operation failed',
			'budget.deleteBudget' => 'Delete Budget',
			'budget.deleteConfirm' => 'Are you sure you want to delete this budget? This cannot be undone.',
			'budget.type' => 'Type',
			'budget.category' => 'Category',
			'budget.period' => 'Repeat Rule',
			'budget.rollover' => 'Rollover',
			'budget.rolloverBalance' => 'Rollover Balance',
			'budget.enabled' => 'Enabled',
			'budget.disabled' => 'Disabled',
			'budget.statusNormal' => 'On Track',
			'budget.statusWarning' => 'Near Limit',
			'budget.statusOverspent' => 'Overspent',
			'budget.statusAchieved' => 'Goal Achieved',
			'budget.tipNormal' => ({required Object amount}) => '${amount} remaining',
			'budget.tipWarning' => ({required Object amount}) => 'Only ${amount} left, be careful',
			'budget.tipOverspent' => ({required Object amount}) => 'Overspent by ${amount}',
			'budget.tipAchieved' => 'Congratulations on achieving your savings goal!',
			'budget.remainingAmount' => ({required Object amount}) => '${amount} remaining',
			'budget.overspentAmount' => ({required Object amount}) => 'Overspent ${amount}',
			'budget.budgetAmount' => ({required Object amount}) => 'Budget ${amount}',
			'budget.active' => 'Active',
			'budget.all' => 'All',
			'budget.notFound' => 'Budget not found or deleted',
			'budget.setup' => 'Budget Setup',
			'budget.settings' => 'Budget Settings',
			'budget.setAmount' => 'Set Budget Amount',
			'budget.setAmountDesc' => 'Set budget amount for each category',
			'budget.monthly' => 'Monthly Budget',
			'budget.monthlyDesc' => 'Manage expenses monthly, suitable for most users',
			'budget.weekly' => 'Weekly Budget',
			'budget.weeklyDesc' => 'Manage expenses weekly for finer control',
			'budget.yearly' => 'Annual Budget',
			'budget.yearlyDesc' => 'Long-term financial planning for major expenses',
			'budget.editBudget' => 'Edit Budget',
			'budget.editBudgetDesc' => 'Modify budget amounts and categories',
			'budget.reminderSettings' => 'Reminder Settings',
			'budget.reminderSettingsDesc' => 'Set budget reminders and notifications',
			'budget.report' => 'Budget Report',
			'budget.reportDesc' => 'View detailed budget analysis reports',
			'budget.welcome' => 'Welcome to Budget Feature!',
			'budget.createNewPlan' => 'Create New Budget Plan',
			'budget.welcomeDesc' => 'Set budgets to better control spending and achieve financial goals. Let\'s start setting up your first budget plan!',
			'budget.createDesc' => 'Set budget limits for different spending categories to manage your finances better.',
			'budget.newBudget' => 'New Budget',
			'budget.budgetAmountLabel' => 'Budget Amount',
			'budget.currency' => 'Currency',
			'budget.periodSettings' => 'Period Settings',
			'budget.autoGenerateTransactions' => 'Automatically generate transactions by rule',
			'budget.cycle' => 'Cycle',
			'budget.budgetCategory' => 'Budget Category',
			'budget.advancedOptions' => 'Advanced Options',
			'budget.periodType' => 'Period Type',
			'budget.anchorDay' => 'Anchor Day',
			'budget.selectPeriodType' => 'Select Period Type',
			'budget.selectAnchorDay' => 'Select Anchor Day',
			'budget.rolloverDescription' => 'Carry over unused budget to next period',
			'budget.createBudget' => 'Create Budget',
			'budget.save' => 'Save',
			'budget.pleaseEnterAmount' => 'Please enter budget amount',
			'budget.invalidAmount' => 'Please enter a valid amount',
			'budget.updateSuccess' => 'Budget updated successfully',
			'budget.createSuccess' => 'Budget created successfully',
			'budget.deleteSuccess' => 'Budget deleted',
			'budget.deleteFailed' => 'Delete failed',
			'budget.everyMonthDay' => ({required Object day}) => 'Day ${day} of each month',
			'budget.periodWeekly' => 'Weekly',
			'budget.periodBiweekly' => 'Biweekly',
			'budget.periodMonthly' => 'Monthly',
			'budget.periodYearly' => 'Yearly',
			'budget.statusActive' => 'Active',
			'budget.statusArchived' => 'Archived',
			'budget.periodStatusOnTrack' => 'On Track',
			'budget.periodStatusWarning' => 'Warning',
			'budget.periodStatusExceeded' => 'Exceeded',
			'budget.periodStatusAchieved' => 'Achieved',
			'budget.usedPercent' => ({required Object percent}) => '${percent}% used',
			'budget.dayOfMonth' => ({required Object day}) => 'Day ${day}',
			'budget.tenThousandSuffix' => '0k',
			'budget.settingsLoadFailed' => 'Failed to load settings',
			'budget.settingsSaveSuccess' => 'Settings saved',
			'budget.settingsSaveFailed' => 'Failed to save',
			'budget.settingsSave' => 'Save Settings',
			'budget.settingsWarningThreshold' => 'Warning Threshold',
			'budget.settingsWarningDesc' => 'Shows warning status when usage reaches this percentage',
			'budget.settingsAlertThreshold' => 'Alert Threshold',
			'budget.settingsAlertDesc' => 'Shows exceeded status when usage reaches this percentage',
			'budget.settingsThresholdOrder' => 'Warning threshold cannot exceed alert threshold',
			'dateRange.custom' => 'Custom',
			'dateRange.pickerTitle' => 'Select Date Range',
			'dateRange.startDate' => 'Start Date',
			'dateRange.endDate' => 'End Date',
			'dateRange.hint' => 'Please select a date range',
			'forecast.title' => 'Forecast',
			'forecast.subtitle' => 'AI-powered cash flow predictions based on your financial data',
			'forecast.financialNavigator' => 'Hello, I\'m your Financial Navigator',
			'forecast.financialMapSubtitle' => 'In just 3 steps, let\'s map your financial future together',
			'forecast.predictCashFlow' => 'Predict Cash Flow',
			'forecast.predictCashFlowDesc' => 'See your daily financial status',
			'forecast.aiSmartSuggestions' => 'AI Smart Suggestions',
			'forecast.aiSmartSuggestionsDesc' => 'Personalized financial decision guidance',
			'forecast.riskWarning' => 'Risk Alerts',
			'forecast.riskWarningDesc' => 'Detect potential financial risks early',
			'forecast.analyzing' => 'Analyzing your financial data to generate a 30-day cash flow forecast',
			'forecast.analyzePattern' => 'Analyzing income & expense patterns',
			'forecast.calculateTrend' => 'Calculating cash flow trends',
			'forecast.generateWarning' => 'Generating risk alerts',
			'forecast.loadingForecast' => 'Loading financial forecast...',
			'forecast.todayLabel' => 'Today',
			'forecast.tomorrowLabel' => 'Tomorrow',
			'forecast.balanceLabel' => 'Balance',
			'forecast.noSpecialEvents' => 'No special events',
			'forecast.financialSafetyLine' => 'Financial Safety Net',
			'forecast.currentSetting' => 'Current Setting',
			'forecast.dailySpendingEstimate' => 'Daily Spending Estimate',
			'forecast.adjustDailySpendingAmount' => 'Adjust daily spending forecast amount',
			'forecast.tellMeYourSafetyLine' => 'What\'s your financial safety threshold?',
			'forecast.safetyLineDescription' => 'This is the minimum balance you want to maintain. I\'ll alert you when your balance approaches this amount.',
			'forecast.dailySpendingQuestion' => 'How much do you spend daily?',
			'forecast.dailySpendingDescription' => 'Including meals, transportation, shopping and other daily expenses\nThis is just an initial estimate - predictions will improve with your actual records',
			'forecast.perDay' => 'per day',
			'forecast.referenceStandard' => 'Reference',
			'forecast.frugalType' => 'Frugal',
			'forecast.comfortableType' => 'Comfortable',
			'forecast.relaxedType' => 'Relaxed',
			'forecast.frugalAmount' => '¥50-100/day',
			'forecast.comfortableAmount' => '¥100-200/day',
			'forecast.relaxedAmount' => '¥200-300/day',
			'forecast.recurringTransaction.title' => 'Recurring Transactions',
			'forecast.recurringTransaction.all' => 'All',
			'forecast.recurringTransaction.expense' => 'Expense',
			'forecast.recurringTransaction.income' => 'Income',
			'forecast.recurringTransaction.transfer' => 'Transfer',
			'forecast.recurringTransaction.noRecurring' => 'No recurring transactions',
			'forecast.recurringTransaction.createHint' => 'The system will automatically generate transactions after you create recurring rules',
			'forecast.recurringTransaction.create' => 'Create Recurring Transaction',
			'forecast.recurringTransaction.edit' => 'Edit Recurring Transaction',
			'forecast.recurringTransaction.newTransaction' => 'New Recurring Transaction',
			'forecast.recurringTransaction.deleteConfirm' => ({required Object name}) => 'Are you sure you want to delete recurring transaction "${name}"? This cannot be undone.',
			'forecast.recurringTransaction.activateConfirm' => ({required Object name}) => 'Are you sure you want to activate recurring transaction "${name}"? It will automatically generate transactions.',
			'forecast.recurringTransaction.pauseConfirm' => ({required Object name}) => 'Are you sure you want to pause recurring transaction "${name}"? No transactions will be generated while paused.',
			'forecast.recurringTransaction.created' => 'Recurring transaction created',
			'forecast.recurringTransaction.updated' => 'Recurring transaction updated',
			'forecast.recurringTransaction.activated' => 'Activated',
			'forecast.recurringTransaction.paused' => 'Paused',
			'forecast.recurringTransaction.nextTime' => 'Next',
			'forecast.recurringTransaction.sortByTime' => 'Sort by time',
			'forecast.recurringTransaction.allPeriod' => 'All recurring',
			'forecast.recurringTransaction.periodCount' => ({required Object type, required Object count}) => '${type} recurring (${count})',
			'forecast.recurringTransaction.confirmDelete' => 'Confirm Delete',
			'forecast.recurringTransaction.confirmActivate' => 'Confirm Activate',
			'forecast.recurringTransaction.confirmPause' => 'Confirm Pause',
			'forecast.recurringTransaction.dynamicAmount' => 'Est. Avg',
			'forecast.recurringTransaction.dynamicAmountTitle' => 'Amount Requires Confirmation',
			'forecast.recurringTransaction.dynamicAmountDescription' => 'System will send a reminder on the due date. You need to manually confirm the amount before recording.',
			'forecast.recurringTransaction.confirmBeforeGeneration' => 'Confirm Before Generation',
			'forecast.recurringTransaction.confirmBeforeGenerationDesc' => 'Generates a pending transaction on due date, requires manual confirmation',
			'forecast.recurringTransaction.pendingTitle' => 'Pending Transactions',
			'forecast.recurringTransaction.pendingCount' => ({required Object count}) => '${count} pending',
			'forecast.recurringTransaction.confirm' => 'Confirm',
			'forecast.recurringTransaction.skip' => 'Skip',
			'forecast.recurringTransaction.noPending' => 'No pending transactions',
			'forecast.recurringTransaction.confirmSuccess' => 'Transaction confirmed',
			'forecast.recurringTransaction.skipSuccess' => 'Transaction skipped',
			'forecast.recurringTransaction.interval' => 'Interval',
			'forecast.recurringTransaction.selectDays' => 'Select Days',
			'forecast.recurringTransaction.alwaysLastDay' => 'Always execute on last day',
			'forecast.recurringTransaction.lastDayExecution' => 'Will execute on the last day of each month',
			'forecast.recurringTransaction.dayExecution' => ({required Object day, required Object suffix}) => 'Will execute on the ${day}${suffix} of each month (clamped for short months)',
			'forecast.recurringTransaction.setEndDate' => 'Set End Date',
			'forecast.recurringTransaction.selectEndDate' => 'Select End Date',
			'forecast.recurringTransaction.preview' => 'Preview',
			'forecast.recurringTransaction.daily' => 'Daily',
			'forecast.recurringTransaction.weekly' => 'Weekly',
			'forecast.recurringTransaction.monthly' => 'Monthly',
			'forecast.recurringTransaction.yearly' => 'Yearly',
			'forecast.recurringTransaction.custom' => 'Custom',
			'forecast.recurringTransaction.cycle' => 'Cycle',
			'forecast.recurringTransaction.dayUnit' => '{count, plural, =1 {Day} other {Days}}',
			'forecast.recurringTransaction.weekUnit' => '{count, plural, =1 {Week} other {Weeks}}',
			'forecast.recurringTransaction.monthUnit' => '{count, plural, =1 {Month} other {Months}}',
			'forecast.recurringTransaction.yearUnit' => '{count, plural, =1 {Year} other {Years}}',
			'forecast.recurringTransaction.everyDays' => ({required Object count}) => 'Every ${count} days',
			'forecast.recurringTransaction.everyWeeks' => ({required Object count}) => 'Every ${count} weeks',
			'forecast.recurringTransaction.everyMonths' => ({required Object count}) => 'Every ${count} months',
			'forecast.recurringTransaction.everyYears' => ({required Object count}) => 'Every ${count} years',
			'forecast.recurringTransaction.monthlyOnDay' => ({required Object day, required Object suffix}) => 'Monthly on the ${day}${suffix}',
			'forecast.recurringTransaction.everyMonthsOnDay' => ({required Object count, required Object day, required Object suffix}) => 'Every ${count} months on the ${day}${suffix}',
			'forecast.recurringTransaction.monthlyLastDay' => 'Monthly on the last day',
			'forecast.recurringTransaction.everyMonthsLastDay' => ({required Object count}) => 'Every ${count} months on the last day',
			'forecast.recurringTransaction.yearlyOn' => ({required Object month, required Object day}) => 'Yearly on ${month}/${day}',
			'forecast.recurringTransaction.everyYearsOn' => ({required Object count, required Object month, required Object day}) => 'Every ${count} years on ${month}/${day}',
			_ => null,
		} ?? switch (path) {
			'forecast.recurringTransaction.weeklyOnDay' => ({required Object day}) => 'Weekly on ${day}',
			'forecast.recurringTransaction.weekdayMon' => 'Mon',
			'forecast.recurringTransaction.weekdayTue' => 'Tue',
			'forecast.recurringTransaction.weekdayWed' => 'Wed',
			'forecast.recurringTransaction.weekdayThu' => 'Thu',
			'forecast.recurringTransaction.weekdayFri' => 'Fri',
			'forecast.recurringTransaction.weekdaySat' => 'Sat',
			'forecast.recurringTransaction.weekdaySun' => 'Sun',
			'forecast.recurringTransaction.weekdayOn' => '',
			'forecast.recurringTransaction.weekdayJoiner' => ', ',
			'forecast.recurringTransaction.weeklyDaysPrefix' => ' on ',
			'forecast.recurringTransaction.sourceAccount' => 'Source Account',
			'forecast.recurringTransaction.targetAccount' => 'Target Account',
			'forecast.recurringTransaction.expenseAccount' => 'Expense Account',
			'forecast.recurringTransaction.incomeAccount' => 'Income Account',
			'forecast.recurringTransaction.selectSourceAccount' => 'Source',
			'forecast.recurringTransaction.selectTargetAccount' => 'Target',
			'forecast.recurringTransaction.selectExpenseAccount' => 'Expense',
			'forecast.recurringTransaction.selectIncomeAccount' => 'Income',
			'forecast.recurringTransaction.amountNotFixed' => ({required Object type}) => 'Amount not fixed for each ${type}',
			'forecast.recurringTransaction.selectBothAccounts' => 'Please select source and target accounts',
			'forecast.recurringTransaction.selectAccountForType' => ({required Object type}) => 'Please select ${type} account',
			'forecast.recurringTransaction.deleteConfirmGeneric' => 'Are you sure you want to delete this recurring transaction? This action cannot be undone.',
			'forecast.recurringTransaction.selectDate' => ({required Object date}) => 'Select ${date}',
			'forecast.recurringTransaction.accountTypeCash' => 'Cash',
			'forecast.recurringTransaction.accountTypeDeposit' => 'Bank Deposit',
			'forecast.recurringTransaction.accountTypeEMoney' => 'E-Wallet',
			'forecast.recurringTransaction.accountTypeInvestment' => 'Investment',
			'forecast.recurringTransaction.accountTypeReceivable' => 'Accounts Receivable',
			'forecast.recurringTransaction.accountTypeCreditCard' => 'Credit Card',
			'forecast.recurringTransaction.accountTypeLoan' => 'Loan Account',
			'forecast.recurringTransaction.accountTypePayable' => 'Accounts Payable',
			'forecast.recurringTransaction.assetAccount' => 'Asset Account',
			'forecast.recurringTransaction.liabilityAccount' => 'Liability Account',
			'forecast.recurringTransaction.noAssetAccounts' => 'No asset accounts',
			'forecast.recurringTransaction.goToFinanceToAddAccounts' => 'Please go to the financial page to add accounts',
			'forecast.recurringTransaction.selectAccount' => 'Select Account',
			'forecast.recurringTransaction.autoGenerateByRule' => 'Automatically generate transactions by rule',
			'chat.newChat' => 'New Chat',
			'chat.noMessages' => 'No messages to display.',
			'chat.loadingFailed' => 'Loading failed',
			'chat.inputMessage' => 'Type a message...',
			'chat.aiThinking' => 'AI processing...',
			'chat.listening' => 'Listening...',
			'chat.tools.processing' => 'Processing...',
			'chat.tools.read_file' => 'Reading file...',
			'chat.tools.search_transactions' => 'Searching transactions...',
			'chat.tools.query_budget_status' => 'Checking budget...',
			'chat.tools.create_budget' => 'Creating budget plan...',
			'chat.tools.get_cash_flow_analysis' => 'Analyzing cash flow...',
			'chat.tools.get_financial_health_score' => 'Calculating financial health score...',
			'chat.tools.get_financial_summary' => 'Generating financial report...',
			'chat.tools.evaluate_financial_health' => 'Evaluating financial health...',
			'chat.tools.simulate_expense_impact' => 'Simulating purchase impact...',
			'chat.tools.record_transactions' => 'Recording transactions...',
			'chat.tools.create_transaction' => 'Recording transaction...',
			'chat.tools.duckduckgo_search' => 'Searching the web...',
			'chat.tools.execute_transfer' => 'Executing transfer...',
			'chat.tools.list_dir' => 'Browsing directory...',
			'chat.tools.execute' => 'Processing...',
			'chat.tools.analyze_spending' => 'Analyzing spendings...',
			'chat.tools.analyze_cashflow' => 'Analyzing cashflow...',
			'chat.tools.forecast_balance' => 'Forecasting balance...',
			'chat.tools.suggest_budget' => 'Suggesting budget...',
			'chat.tools.list_spaces' => 'Loading shared spaces...',
			'chat.tools.query_space_summary' => 'Querying space summary...',
			'chat.tools.prepare_transfer' => 'Preparing transfer...',
			'chat.tools.unknown' => 'Processing request...',
			'chat.tools.done.read_file' => 'Read file',
			'chat.tools.done.search_transactions' => 'Searched transactions',
			'chat.tools.done.query_budget_status' => 'Checked budget',
			'chat.tools.done.create_budget' => 'Created budget',
			'chat.tools.done.get_cash_flow_analysis' => 'Analyzed cash flow',
			'chat.tools.done.get_financial_health_score' => 'Calculated health score',
			'chat.tools.done.get_financial_summary' => 'Financial report ready',
			'chat.tools.done.evaluate_financial_health' => 'Health evaluation complete',
			'chat.tools.done.forecast_balance' => 'Balance forecast ready',
			'chat.tools.done.simulate_expense_impact' => 'Impact simulation complete',
			'chat.tools.done.record_transactions' => 'Recorded transactions',
			'chat.tools.done.create_transaction' => 'Recorded transaction',
			'chat.tools.done.duckduckgo_search' => 'Searched the web',
			'chat.tools.done.execute_transfer' => 'Transfer complete',
			'chat.tools.done.list_dir' => 'Browsed directory',
			'chat.tools.done.execute' => 'Processing complete',
			'chat.tools.done.analyze_spending' => 'Spending analysis complete',
			'chat.tools.done.analyze_cashflow' => 'Cashflow analysis complete',
			'chat.tools.done.suggest_budget' => 'Budget suggestion complete',
			'chat.tools.done.list_spaces' => 'Shared spaces loaded',
			'chat.tools.done.query_space_summary' => 'Space summary ready',
			'chat.tools.done.prepare_transfer' => 'Transfer ready',
			'chat.tools.done.unknown' => 'Processing complete',
			'chat.tools.done.analyze_finance' => '財務分析完成',
			'chat.tools.done.forecast_finance' => '財務預測完成',
			'chat.tools.done.analyze_budget' => '預算分析完成',
			'chat.tools.done.audit_analysis' => '審計分析完成',
			'chat.tools.done.budget_ops' => '預算處理完成',
			'chat.tools.done.create_shared_transaction' => '共享帳單創建完成',
			'chat.tools.done.prepareBudgetSimulation' => 'Budget simulation prepared',
			'chat.tools.done.simulateBudget' => 'Budget simulation completed',
			'chat.tools.failed.unknown' => 'Action failed',
			'chat.tools.cancelled' => 'Cancelled',
			'chat.tools.analyze_finance' => '正在分析財務狀況...',
			'chat.tools.forecast_finance' => '正在預測財務趨勢...',
			'chat.tools.analyze_budget' => '正在分析預算...',
			'chat.tools.audit_analysis' => '正在審計分析...',
			'chat.tools.budget_ops' => '正在處理預算...',
			'chat.tools.create_shared_transaction' => '正在創建共享帳單...',
			'chat.tools.prepareBudgetSimulation' => 'Preparing budget simulation',
			'chat.tools.simulateBudget' => 'Simulating budget',
			'chat.speechNotRecognized' => 'Speech not recognized, please try again',
			'chat.currentExpense' => 'Session Expense',
			'chat.loadingComponent' => 'Loading component...',
			'chat.noHistory' => 'No historical sessions',
			'chat.startNewChat' => 'Start a new conversation!',
			'chat.searchHint' => 'Search conversations',
			'chat.library' => 'Library',
			'chat.viewProfile' => 'View profile',
			'chat.noRelatedFound' => 'No related conversations found',
			'chat.tryOtherKeywords' => 'Try searching with other keywords',
			'chat.searchFailed' => 'Search failed',
			'chat.deleteConversation' => 'Delete Conversation',
			'chat.deleteConversationConfirm' => 'Are you sure you want to delete this conversation? This action cannot be undone.',
			'chat.conversationDeleted' => 'Conversation deleted',
			'chat.deleteConversationFailed' => 'Failed to delete conversation',
			'chat.transferWizard.title' => 'Transfer Wizard',
			'chat.transferWizard.amount' => 'Transfer Amount',
			'chat.transferWizard.amountHint' => 'Enter amount',
			'chat.transferWizard.sourceAccount' => 'Source Account',
			'chat.transferWizard.targetAccount' => 'Target Account',
			'chat.transferWizard.selectAccount' => 'Select Account',
			'chat.transferWizard.autoGenerateByRule' => 'Automatically generate transactions by rule',
			'chat.transferWizard.confirmTransfer' => 'Confirm Transfer',
			'chat.transferWizard.confirmed' => 'Confirmed',
			'chat.transferWizard.transferSuccess' => 'Transfer Successful',
			'chat.transferWizard.selectReceiveAccount' => '选择收款账户',
			'chat.genui.expenseSummary.totalExpense' => 'Total Expense',
			'chat.genui.expenseSummary.mainExpenses' => 'Main Expenses',
			'chat.genui.expenseSummary.viewAll' => ({required Object count}) => 'View all ${count} transactions',
			'chat.genui.expenseSummary.details' => 'Transaction Details',
			'chat.genui.transactionList.searchResults' => ({required Object count}) => 'Search Results (${count})',
			'chat.genui.transactionList.loaded' => ({required Object count}) => 'Loaded ${count}',
			'chat.genui.transactionList.noResults' => 'No transactions found',
			'chat.genui.transactionList.loadMore' => 'Scroll to load more',
			'chat.genui.transactionList.allLoaded' => 'All loaded',
			'chat.genui.transactionGroupReceipt.title' => 'Successfully',
			'chat.genui.transactionGroupReceipt.count' => ({required Object count}) => '${count} items',
			'chat.genui.transactionGroupReceipt.total' => 'Total',
			'chat.genui.transactionGroupReceipt.selectAccount' => 'Select Account',
			'chat.genui.transactionGroupReceipt.autoGenerateByRule' => 'Automatically generate transactions by rule',
			'chat.genui.transactionGroupReceipt.selectAccountSubtitle' => 'This account will be applied to all transactions above',
			'chat.genui.transactionGroupReceipt.associatedAccount' => ({required Object name}) => 'Associated: ${name}',
			'chat.genui.transactionGroupReceipt.clickToAssociate' => 'Click to associate account',
			'chat.genui.transactionGroupReceipt.associateSuccess' => 'Successfully associated account to all transactions',
			'chat.genui.transactionGroupReceipt.associateFailed' => ({required Object error}) => 'Action failed: ${error}',
			'chat.genui.transactionGroupReceipt.accountAssociation' => 'Account',
			'chat.genui.transactionGroupReceipt.sharedSpace' => 'Shared Space',
			'chat.genui.transactionGroupReceipt.notAssociated' => 'Not linked',
			'chat.genui.transactionGroupReceipt.addSpace' => 'Add',
			'chat.genui.transactionGroupReceipt.selectSpace' => 'Select Shared Space',
			'chat.genui.transactionGroupReceipt.spaceAssociateSuccess' => 'Linked to shared space',
			'chat.genui.transactionGroupReceipt.spaceAssociateFailed' => ({required Object error}) => 'Failed to link: ${error}',
			'chat.genui.transactionGroupReceipt.currencyMismatchTitle' => 'Currency Mismatch',
			'chat.genui.transactionGroupReceipt.currencyMismatchDesc' => 'The transaction currency differs from the account currency. The account balance will be deducted at the exchange rate.',
			'chat.genui.transactionGroupReceipt.transactionAmount' => 'Transaction Amount',
			'chat.genui.transactionGroupReceipt.accountCurrency' => 'Account Currency',
			'chat.genui.transactionGroupReceipt.targetAccount' => 'Target Account',
			'chat.genui.transactionGroupReceipt.currencyMismatchNote' => 'Note: Account balance will be converted using current exchange rate',
			'chat.genui.transactionGroupReceipt.confirmAssociate' => 'Confirm',
			'chat.genui.transactionGroupReceipt.spaceCount' => ({required Object count}) => '${count} spaces',
			'chat.genui.budgetReceipt.newBudget' => 'New Budget',
			'chat.genui.budgetReceipt.budgetCreated' => 'Budget Created',
			'chat.genui.budgetReceipt.rolloverBudget' => 'Rollover Budget',
			'chat.genui.budgetReceipt.createFailed' => 'Failed to create budget',
			'chat.genui.budgetReceipt.thisMonth' => 'This Month',
			'chat.genui.budgetReceipt.dateRange' => ({required Object start, required Object startDay, required Object end, required Object endDay}) => '${start}/${startDay} - ${end}/${endDay}',
			'chat.genui.budgetStatusCard.budget' => 'Budget',
			'chat.genui.budgetStatusCard.overview' => 'Budget Overview',
			'chat.genui.budgetStatusCard.totalBudget' => 'Total Budget',
			'chat.genui.budgetStatusCard.spent' => ({required Object amount}) => 'Used ¥${amount}',
			'chat.genui.budgetStatusCard.remaining' => ({required Object amount}) => 'Remaining ¥${amount}',
			'chat.genui.budgetStatusCard.exceeded' => 'Exceeded',
			'chat.genui.budgetStatusCard.warning' => 'Warning',
			'chat.genui.budgetStatusCard.plentiful' => 'Healthy',
			'chat.genui.budgetStatusCard.normal' => 'Normal',
			'chat.genui.cashFlowForecast.title' => 'Cash Flow Forecast',
			'chat.genui.cashFlowForecast.recurringTransaction' => 'Recurring Transaction',
			'chat.genui.cashFlowForecast.recurringIncome' => 'Recurring Income',
			'chat.genui.cashFlowForecast.recurringExpense' => 'Recurring Expense',
			'chat.genui.cashFlowForecast.recurringTransfer' => 'Recurring Transfer',
			'chat.genui.cashFlowForecast.nextDays' => ({required Object days}) => 'Next ${days} days',
			'chat.genui.cashFlowForecast.noData' => 'No forecast data',
			'chat.genui.cashFlowForecast.summary' => 'Forecast Summary',
			'chat.genui.cashFlowForecast.variableExpense' => 'Predicted Variable Expense',
			'chat.genui.cashFlowForecast.netChange' => 'Est. Net Change',
			'chat.genui.cashFlowForecast.keyEvents' => 'Key Events',
			'chat.genui.cashFlowForecast.noSignificantEvents' => 'No significant events in forecast period',
			'chat.genui.cashFlowForecast.dateFormat' => 'M/d',
			'chat.genui.healthScore.title' => 'Financial Health',
			'chat.genui.healthScore.suggestions' => 'Suggestions',
			'chat.genui.healthScore.scorePoint' => ({required Object score}) => '${score} pts',
			'chat.genui.healthScore.status.excellent' => 'Excellent',
			'chat.genui.healthScore.status.good' => 'Good',
			'chat.genui.healthScore.status.fair' => 'Fair',
			'chat.genui.healthScore.status.needsImprovement' => 'Needs Improvement',
			'chat.genui.healthScore.status.poor' => 'Poor',
			'chat.genui.spaceSelector.selected' => 'Selected',
			'chat.genui.spaceSelector.unnamedSpace' => 'Unnamed Space',
			'chat.genui.spaceSelector.linked' => 'Linked',
			'chat.genui.spaceSelector.roleOwner' => 'Owner',
			'chat.genui.spaceSelector.roleAdmin' => 'Admin',
			'chat.genui.spaceSelector.roleMember' => 'Member',
			'chat.genui.spaceSelector.associateAction' => 'Associate selected space',
			'chat.genui.transferPath.selectSource' => 'Select Source Account',
			'chat.genui.transferPath.selectTarget' => 'Select Target Account',
			'chat.genui.transferPath.from' => 'From (Source)',
			'chat.genui.transferPath.to' => 'To (Target)',
			'chat.genui.transferPath.select' => 'Select',
			'chat.genui.transferPath.cancelled' => 'Operation Cancelled',
			'chat.genui.transferPath.loadError' => 'Failed to load account data',
			'chat.genui.transferPath.historyMissing' => 'Account info missing in history',
			'chat.genui.transferPath.amountUnconfirmed' => 'Amount Unconfirmed',
			'chat.genui.transferPath.confirmedWithArrow' => ({required Object source, required Object target}) => 'Confirmed: ${source} → ${target}',
			'chat.genui.transferPath.confirmAction' => ({required Object source, required Object target}) => 'Confirm: ${source} → ${target}',
			'chat.genui.transferPath.pleaseSelectSource' => 'Please select source account',
			'chat.genui.transferPath.pleaseSelectTarget' => 'Please select target account',
			'chat.genui.transferPath.confirmLinks' => 'Confirm Transfer Path',
			'chat.genui.transferPath.linkLocked' => 'Path Locked',
			'chat.genui.transferPath.clickToConfirm' => 'Click button below to confirm',
			'chat.genui.transferPath.reselect' => 'Reselect',
			'chat.genui.transferPath.title' => 'Transfer',
			'chat.genui.transferPath.history' => 'History',
			'chat.genui.transferPath.unknownAccount' => 'Unknown Account',
			'chat.genui.transferPath.confirmed' => 'Confirmed',
			'chat.genui.transferPath.executeAction' => 'Execute transfer according to my selection',
			'chat.genui.transactionCard.title' => 'Transaction Successful',
			'chat.genui.transactionCard.associatedAccount' => 'Associated Account',
			'chat.genui.transactionCard.notCounted' => 'Not counted',
			'chat.genui.transactionCard.modify' => 'Modify',
			'chat.genui.transactionCard.associate' => 'Associate Account',
			'chat.genui.transactionCard.selectAccount' => 'Select Account',
			'chat.genui.transactionCard.autoGenerateByRule' => 'Automatically generate transactions by rule',
			'chat.genui.transactionCard.noAccount' => 'No accounts available, please add one first',
			'chat.genui.transactionCard.missingId' => 'Transaction ID missing, cannot update',
			'chat.genui.transactionCard.associatedTo' => ({required Object name}) => 'Associated to ${name}',
			'chat.genui.transactionCard.updateFailed' => ({required Object error}) => 'Update failed: ${error}',
			'chat.genui.transactionCard.sharedSpace' => 'Shared Space',
			'chat.genui.transactionCard.noSpace' => 'No shared spaces available',
			'chat.genui.transactionCard.selectSpace' => 'Select Shared Space',
			'chat.genui.transactionCard.linkedToSpace' => 'Linked to shared space',
			'chat.genui.cashFlowCard.title' => 'Cash Flow Analysis',
			'chat.genui.cashFlowCard.savingsRate' => ({required Object rate}) => 'Savings ${rate}%',
			'chat.genui.cashFlowCard.totalIncome' => 'Total Income',
			'chat.genui.cashFlowCard.totalExpense' => 'Total Expense',
			'chat.genui.cashFlowCard.essentialExpense' => 'Essential',
			'chat.genui.cashFlowCard.discretionaryExpense' => 'Discretionary',
			'chat.genui.cashFlowCard.aiInsight' => 'AI Insight',
			'chat.genui.transactionConfirmation.multipleAccounts' => '检测到多个关联账户',
			'chat.genui.transactionConfirmation.confirmed' => '已确认',
			'chat.genui.budgetAnalysis.title' => '预算分析报告',
			'chat.genui.budgetAnalysis.periodDays' => ({required Object days}) => '过去 ${days} 天',
			'chat.genui.budgetAnalysis.totalExpense' => '总支出',
			'chat.genui.budgetAnalysis.momChange' => ({required Object change}) => '环比 ${change}%',
			'chat.genui.budgetAnalysis.categoryDistribution' => '分类占比',
			'chat.genui.budgetAnalysis.topSpenders' => '大额支出',
			'chat.genui.budgetAnalysis.amountWan' => ({required Object amount}) => '${amount}万',
			'chat.genui.budgetSimulator.title' => '預算壓力模擬器',
			'chat.genui.budgetSimulator.targetAmount' => '目標預算金額',
			'chat.genui.budgetSimulator.overspendProbability' => '預計超支機率',
			'chat.genui.budgetSimulator.riskLow' => '風險極低',
			'chat.genui.budgetSimulator.riskMedium' => '風險適中',
			'chat.genui.budgetSimulator.riskHigh' => '超支高危',
			'chat.genui.budgetSimulator.evaluating' => '正在評估歷史消費習慣...',
			'chat.genui.budgetSimulator.historyAverage' => '歷史月均',
			'chat.genui.budgetSimulator.dailyAllowance' => '每日限額',
			'chat.genui.budgetSimulator.cancel' => '放棄',
			'chat.genui.budgetSimulator.confirm' => '採用此預算',
			'chat.welcome.morning.subtitle' => 'Start your day by tracking',
			'chat.welcome.morning.breakfast.title' => 'Breakfast',
			'chat.welcome.morning.breakfast.prompt' => 'Record breakfast expense',
			'chat.welcome.morning.breakfast.description' => 'Log today\'s first expense',
			'chat.welcome.morning.yesterdayReview.title' => 'Yesterday Review',
			'chat.welcome.morning.yesterdayReview.prompt' => 'Analyze yesterday\'s spending',
			'chat.welcome.morning.yesterdayReview.description' => 'Check how much you spent yesterday',
			'chat.welcome.morning.todayBudget.title' => 'Today\'s Budget',
			'chat.welcome.morning.todayBudget.prompt' => 'How much budget left for today',
			'chat.welcome.morning.todayBudget.description' => 'Plan your spending for today',
			'chat.welcome.midday.greeting' => 'Good Afternoon',
			'chat.welcome.midday.subtitle' => 'Quick record during lunch',
			'chat.welcome.midday.lunch.title' => 'Lunch',
			'chat.welcome.midday.lunch.prompt' => 'Record lunch expense',
			'chat.welcome.midday.lunch.description' => 'Log your lunch spending',
			'chat.welcome.midday.weeklyExpense.title' => 'Weekly Spending',
			'chat.welcome.midday.weeklyExpense.prompt' => 'Analyze this week\'s spending',
			'chat.welcome.midday.weeklyExpense.description' => 'See your weekly expenses',
			'chat.welcome.midday.checkBalance.title' => 'Check Balance',
			'chat.welcome.midday.checkBalance.prompt' => 'Check my account balance',
			'chat.welcome.midday.checkBalance.description' => 'View your account balances',
			'chat.welcome.afternoon.subtitle' => 'Tea time, let\'s review finances',
			'chat.welcome.afternoon.quickRecord.title' => 'Quick Record',
			'chat.welcome.afternoon.quickRecord.prompt' => 'Help me record an expense',
			'chat.welcome.afternoon.quickRecord.description' => 'Quickly log a transaction',
			'chat.welcome.afternoon.analyzeSpending.title' => 'Analyze Spending',
			'chat.welcome.afternoon.analyzeSpending.prompt' => 'Analyze this month\'s spending',
			'chat.welcome.afternoon.analyzeSpending.description' => 'View spending trends and breakdown',
			'chat.welcome.afternoon.budgetProgress.title' => 'Budget Progress',
			'chat.welcome.afternoon.budgetProgress.prompt' => 'Check budget status',
			'chat.welcome.afternoon.budgetProgress.description' => 'See how your budget is doing',
			'chat.welcome.evening.subtitle' => 'End of day, time to balance the books',
			'chat.welcome.evening.dinner.title' => 'Dinner',
			'chat.welcome.evening.dinner.prompt' => 'Record dinner expense',
			'chat.welcome.evening.dinner.description' => 'Log tonight\'s dinner spending',
			'chat.welcome.evening.todaySummary.title' => 'Today\'s Summary',
			'chat.welcome.evening.todaySummary.prompt' => 'Summarize today\'s spending',
			'chat.welcome.evening.todaySummary.description' => 'See what you spent today',
			'chat.welcome.evening.tomorrowPlan.title' => 'Tomorrow\'s Plan',
			'chat.welcome.evening.tomorrowPlan.prompt' => 'What fixed expenses tomorrow',
			'chat.welcome.evening.tomorrowPlan.description' => 'Plan ahead for tomorrow',
			'chat.welcome.night.greeting' => 'Late Night',
			'chat.welcome.night.subtitle' => 'Quiet time for financial planning',
			'chat.welcome.night.makeupRecord.title' => 'Catch Up',
			'chat.welcome.night.makeupRecord.prompt' => 'Help me log any missed expenses',
			'chat.welcome.night.makeupRecord.description' => 'Record expenses you forgot today',
			'chat.welcome.night.monthlyReview.title' => 'Monthly Review',
			'chat.welcome.night.monthlyReview.prompt' => 'Analyze this month\'s spending',
			'chat.welcome.night.monthlyReview.description' => 'Review your monthly expenses',
			'chat.welcome.night.financialThinking.title' => 'Financial Tips',
			'chat.welcome.night.financialThinking.prompt' => 'Give me some financial advice',
			'chat.welcome.night.financialThinking.description' => 'Get AI-powered financial insights',
			'footprint.searchIn' => 'Search',
			'footprint.searchInAllRecords' => 'Search in all records',
			'media.selectPhotos' => 'Select Photos',
			'media.addFiles' => 'Add Files',
			'media.takePhoto' => 'Take Photo',
			'media.camera' => 'Camera',
			'media.photos' => 'Photos',
			'media.files' => 'Files',
			'media.showAll' => 'Show All',
			'media.allPhotos' => 'All Photos',
			'media.takingPhoto' => 'Taking photo...',
			'media.photoTaken' => 'Photo saved',
			'media.cameraPermissionRequired' => 'Camera permission required',
			'media.fileSizeExceeded' => 'File size exceeds 10MB limit',
			'media.unsupportedFormat' => 'Unsupported file format',
			'media.permissionDenied' => 'Photo library access required',
			'media.storageInsufficient' => 'Insufficient storage space',
			'media.networkError' => 'Network connection error',
			'media.unknownUploadError' => 'Unknown error during upload',
			'error.permissionRequired' => 'Permission Required',
			'error.permissionInstructions' => 'Please enable photo library and storage permissions in Settings to select and upload files.',
			'error.openSettings' => 'Open Settings',
			'error.fileTooLarge' => 'File Too Large',
			'error.fileSizeHint' => 'Please select files under 10MB, or compress before uploading.',
			'error.supportedFormatsHint' => 'Supported formats: images (jpg, png, gif), documents (pdf, doc, txt), audio/video files.',
			'error.storageCleanupHint' => 'Please free up storage space and try again, or select smaller files.',
			'error.networkErrorHint' => 'Please check your network connection and try again.',
			'error.platformNotSupported' => 'Platform Not Supported',
			'error.fileReadError' => 'File Read Error',
			'error.fileReadErrorHint' => 'The file may be corrupted or in use. Please select a different file.',
			'error.validationError' => 'File Validation Error',
			'error.unknownError' => 'Unknown Error',
			'error.unknownErrorHint' => 'An unexpected error occurred. Please try again or contact support.',
			'error.registrationMissingInfo' => 'Registration flow error, missing required information.',
			'error.genui.loadingFailed' => 'Component loading failed',
			'error.genui.schemaFailed' => 'Schema validation failed',
			'error.genui.schemaDescription' => 'Component definition does not comply with GenUI specifications, degraded to plain text display',
			'error.genui.networkError' => 'Network error',
			'error.genui.retryStatus' => ({required Object retryCount, required Object maxRetries}) => 'Retried ${retryCount}/${maxRetries} times',
			'error.genui.maxRetriesReached' => 'Maximum retry attempts reached',
			'fontTest.page' => 'Font Test Page',
			'fontTest.displayTest' => 'Font Display Test',
			'fontTest.chineseTextTest' => 'Chinese Text Test',
			'fontTest.englishTextTest' => 'English Text Test',
			'fontTest.sample1' => 'This is a sample text for testing font display effects.',
			'fontTest.sample2' => 'Expense category summary, shopping is highest',
			'fontTest.sample3' => 'AI assistant provides professional financial analysis services',
			'fontTest.sample4' => 'Data visualization charts show your spending trends',
			'fontTest.sample5' => 'WeChat Pay, Alipay, bank cards and other payment methods',
			'wizard.nextStep' => 'Next',
			'wizard.previousStep' => 'Previous',
			'wizard.completeMapping' => 'Complete',
			'user.username' => 'Username',
			'user.defaultEmail' => 'user@example.com',
			'account.editTitle' => 'Edit Account',
			'account.addTitle' => 'New Account',
			'account.selectTypeTitle' => 'Select Account Type',
			'account.nameLabel' => 'Account Name',
			'account.amountLabel' => 'Current Balance',
			'account.currencyLabel' => 'Currency',
			'account.hiddenLabel' => 'Hidden',
			'account.hiddenDesc' => 'Hide this account from the list',
			'account.includeInNetWorthLabel' => 'Include in Net Worth',
			'account.includeInNetWorthDesc' => 'Count towards total net worth',
			'account.nameHint' => 'e.g. Salary Card',
			'account.amountHint' => '0.00',
			'account.deleteAccount' => 'Delete Account',
			'account.deleteConfirm' => 'Are you sure you want to delete this account? This cannot be undone.',
			'account.save' => 'Save Changes',
			'account.assetsCategory' => 'Assets',
			'account.liabilitiesCategory' => 'Liabilities/Credit',
			'account.cash' => 'Cash Wallet',
			'account.deposit' => 'Bank Deposit',
			'account.creditCard' => 'Credit Card',
			'account.investment' => 'Investment',
			'account.eWallet' => 'E-Wallet',
			'account.loan' => 'Loan',
			'account.receivable' => 'Receivable',
			'account.payable' => 'Payable',
			'account.other' => 'Other',
			'account.types.cashTitle' => 'Cash',
			'account.types.cashSubtitle' => 'Physical currency and coins',
			'account.types.depositTitle' => 'Bank Deposit',
			'account.types.depositSubtitle' => 'Savings, checking accounts',
			'account.types.eMoneyTitle' => 'E-Wallet',
			'account.types.eMoneySubtitle' => 'Digital payment balances',
			'account.types.investmentTitle' => 'Investment',
			'account.types.investmentSubtitle' => 'Stocks, funds, bonds, etc.',
			'account.types.receivableTitle' => 'Receivable',
			'account.types.receivableSubtitle' => 'Loans to others, pending',
			'account.types.receivableHelper' => 'Owed to me',
			'account.types.creditCardTitle' => 'Credit Card',
			'account.types.creditCardSubtitle' => 'Credit card balances',
			'account.types.loanTitle' => 'Loan',
			'account.types.loanSubtitle' => 'Mortgage, auto, personal',
			'account.types.payableTitle' => 'Payable',
			'account.types.payableSubtitle' => 'Amounts owed to others',
			'account.types.payableHelper' => 'I owe',
			'financial.title' => 'Financial',
			'financial.management' => 'Financial Management',
			'financial.netWorth' => 'Total Net Worth',
			'financial.assets' => 'Total Assets',
			'financial.liabilities' => 'Total Liabilities',
			'financial.noAccounts' => 'No accounts yet',
			'financial.addFirstAccount' => 'Tap the button below to add your first account',
			'financial.assetAccounts' => 'Asset Accounts',
			'financial.liabilityAccounts' => 'Liability Accounts',
			'financial.selectCurrency' => 'Select Currency',
			'financial.cancel' => 'Cancel',
			'financial.confirm' => 'Confirm',
			'financial.settings' => 'Financial Settings',
			'financial.budgetManagement' => 'Budget Management',
			'financial.recurringTransactions' => 'Recurring Transactions',
			'financial.safetyThreshold' => 'Safety Threshold',
			'financial.dailyBurnRate' => 'Daily Burn Rate',
			'financial.financialAssistant' => 'Financial Assistant',
			'financial.manageFinancialSettings' => 'Manage your financial settings',
			'financial.safetyThresholdSettings' => 'Safety Threshold Settings',
			'financial.setSafetyThreshold' => 'Set your financial safety threshold',
			'financial.safetyThresholdSaved' => 'Safety threshold saved',
			'financial.dailyBurnRateSettings' => 'Daily Burn Rate',
			'financial.setDailyBurnRate' => 'Set your estimated daily spending',
			'financial.dailyBurnRateSaved' => 'Daily burn rate saved',
			'financial.dayUnit' => 'day',
			'financial.saveFailed' => 'Save failed',
			'app.splashTitle' => 'Finvo: Intelligence that Grows.',
			'app.splashSubtitle' => 'Smart Financial Assistant',
			'statistics.title' => 'Analysis',
			'statistics.analyze' => 'Analysis',
			'statistics.exportInProgress' => 'Export feature coming soon...',
			'statistics.ranking' => 'Top Spending',
			'statistics.noData' => 'No data available',
			'statistics.overview.balance' => 'Total Balance',
			'statistics.overview.income' => 'Total Income',
			'statistics.overview.expense' => 'Total Expense',
			'statistics.trend.title' => 'Trends',
			'statistics.trend.expense' => 'Expense',
			'statistics.trend.income' => 'Income',
			'statistics.analysis.title' => 'Expense Analysis',
			'statistics.analysis.expenseTitle' => 'Expense Analysis',
			'statistics.analysis.incomeTitle' => 'Income Analysis',
			'statistics.analysis.total' => 'Total',
			'statistics.analysis.breakdown' => 'Expense Breakdown',
			'statistics.analysis.radarNeedMoreData' => 'Radar chart requires at least 3 categories',
			'statistics.filter.accountType' => 'Account Type',
			'statistics.filter.allAccounts' => 'All Accounts',
			'statistics.filter.apply' => 'Apply',
			'statistics.sort.amount' => 'By Amount',
			'statistics.sort.date' => 'By Time',
			'statistics.exportList' => 'Export List',
			'statistics.emptyState.title' => 'Unlock Financial Insights',
			'statistics.emptyState.description' => 'Your financial report is currently a blank canvas.\nRecord your first transaction and let the data tell your story.',
			'statistics.emptyState.action' => 'Record First Transaction',
			'statistics.noMoreData' => 'No more data',
			'currency.cny' => 'Chinese Yuan',
			'currency.usd' => 'US Dollar',
			'currency.eur' => 'Euro',
			'currency.jpy' => 'Japanese Yen',
			'currency.gbp' => 'British Pound',
			'currency.aud' => 'Australian Dollar',
			'currency.cad' => 'Canadian Dollar',
			'currency.chf' => 'Swiss Franc',
			'currency.rub' => 'Russian Ruble',
			'currency.hkd' => 'Hong Kong Dollar',
			'currency.twd' => 'New Taiwan Dollar',
			'currency.inr' => 'Indian Rupee',
			'budgetSuggestion.highPercentage' => ({required Object category, required Object percentage}) => '${category} accounts for ${percentage}% of spending. Consider setting a budget limit.',
			'budgetSuggestion.monthlyIncrease' => ({required Object percentage}) => 'Spending increased by ${percentage}% this month. Needs attention.',
			'budgetSuggestion.frequentSmall' => ({required Object category, required Object count}) => '${category} has ${count} small transactions. These might be subscriptions.',
			'budgetSuggestion.financialInsights' => 'Financial Insights',
			'server.title' => 'Connect to Server',
			'server.subtitle' => 'Enter your self-hosted server address or scan the QR code displayed when starting the server',
			'server.urlLabel' => 'Server Address',
			'server.urlPlaceholder' => 'e.g. https://api.example.com or 192.168.1.100:8000',
			'server.scanQr' => 'Scan QR Code',
			'server.scanQrInstruction' => 'Point at the QR code displayed in the server terminal',
			'server.testConnection' => 'Test Connection',
			'server.connecting' => 'Connecting...',
			'server.connected' => 'Connected',
			'server.connectionFailed' => 'Connection Failed',
			'server.continueToLogin' => 'Continue to Login',
			'server.saveAndReturn' => 'Save and Return',
			'server.saveAndReLogin' => 'Save and Re-login',
			'server.serverUrlSavedRedirectLogin' => 'Server configuration updated, please log in again',
			_ => null,
		} ?? switch (path) {
			'server.serverSettings' => 'Server Settings',
			'server.currentServer' => 'Current Server',
			'server.version' => 'Version',
			'server.environment' => 'Environment',
			'server.changeServer' => 'Change Server',
			'server.changeServerWarning' => 'Changing server will log you out. Continue?',
			'server.error.urlRequired' => 'Server address is required',
			'server.error.invalidUrl' => 'Invalid URL format',
			'server.error.connectionTimeout' => 'Connection timed out',
			'server.error.connectionRefused' => 'Could not connect to server',
			'server.error.sslError' => 'SSL certificate error',
			'server.error.serverError' => 'Server error',
			'sharedSpace.dashboard.sectionTitle' => 'Financial Overview',
			'sharedSpace.dashboard.cumulativeTotalExpense' => 'Cumulative Total Expense',
			'sharedSpace.dashboard.participatingMembers' => 'Participating Members',
			'sharedSpace.dashboard.membersCount' => ({required Object count}) => '${count} people',
			'sharedSpace.dashboard.averagePerMember' => 'Avg per member',
			'sharedSpace.dashboard.spendingDistribution' => 'Spending Distribution',
			'sharedSpace.dashboard.realtimeUpdates' => 'Real-time updates',
			'sharedSpace.dashboard.paid' => 'Paid',
			'sharedSpace.roles.owner' => 'Owner',
			'sharedSpace.roles.admin' => 'Admin',
			'sharedSpace.roles.member' => 'Member',
			'sharedSpace.title' => 'Shared Space',
			'sharedSpace.create.title' => 'Create Shared Space',
			'sharedSpace.create.subtitle' => 'Create a new shared space to track expenses with friends',
			'sharedSpace.create.nameLabel' => 'Space Name',
			'sharedSpace.create.nameHint' => 'e.g., Graduation Trip',
			'sharedSpace.create.descLabel' => 'Description (Optional)',
			'sharedSpace.create.descHint' => 'Track our joint travel expenses',
			'sharedSpace.create.cancel' => 'Cancel',
			'sharedSpace.create.submit' => 'Create',
			'sharedSpace.create.nameRequired' => 'Please enter a space name',
			'sharedSpace.create.nameTooShort' => 'Space name must be at least 2 characters',
			'sharedSpace.create.nameTooLong' => 'Space name cannot exceed 50 characters',
			'sharedSpace.join.title' => 'Join Shared Space',
			'sharedSpace.join.subtitle' => 'Enter the invite code shared by a friend to start collaborative bookkeeping',
			'sharedSpace.join.codeLabel' => 'Invite Code',
			'sharedSpace.join.codeHint' => 'Enter invite code, e.g.: 123456',
			'sharedSpace.join.cancel' => 'Cancel',
			'sharedSpace.join.submit' => 'Join',
			'sharedSpace.join.codeRequired' => 'Please enter invite code',
			'sharedSpace.join.codeInvalid' => 'Invalid invite code format',
			'sharedSpace.join.codeFormat' => 'Invite code can only contain letters and numbers',
			'sharedSpace.list.emptyTitle' => 'Start Collaborative Financial Spaces',
			'sharedSpace.list.emptySubtitle' => 'Create or join a space to manage shared accounts and assets with family, partners, or teams',
			'sharedSpace.list.getStarted' => 'Get Started',
			'sharedSpace.list.hasInviteCode' => 'Have an invite code? Tap to join',
			'sharedSpace.list.joinedSuccess' => ({required Object name}) => 'Successfully joined "${name}"!',
			'sharedSpace.detail.members' => 'Members',
			'sharedSpace.detail.transactions' => 'Transactions',
			'sharedSpace.detail.recordsCount' => ({required Object count}) => '${count} records',
			'sharedSpace.detail.settlement' => 'Settlement',
			'sharedSpace.detail.inviteCode' => 'Invite Code',
			'sharedSpace.detail.copyCode' => 'Copy Invite Code',
			'sharedSpace.detail.codeCopied' => ({required Object code}) => 'Invite code copied: ${code}',
			'sharedSpace.detail.validFor24h' => 'Valid for 24 hours',
			'sharedSpace.detail.leaveSpace' => 'Leave Space',
			'sharedSpace.detail.deleteSpace' => 'Delete Space',
			'sharedSpace.detail.removeMember' => 'Remove Member',
			'sharedSpace.detail.leaveConfirm' => 'Are you sure you want to leave this shared space? You will no longer have access to its transactions.',
			'sharedSpace.detail.deleteConfirm' => 'Are you sure you want to delete this shared space? This action cannot be undone and all members will be removed.',
			'sharedSpace.detail.removeConfirm' => 'Are you sure you want to remove this member from the shared space?',
			'sharedSpace.detail.generatingCode' => 'Generating invite code...',
			'sharedSpace.detail.loadFailed' => 'Failed to load',
			'sharedSpace.detail.retry' => 'Retry',
			'sharedSpace.detail.noTransactions' => 'No transactions yet',
			'sharedSpace.detail.noTransactionsHint' => 'Transactions in this space will appear here',
			'sharedSpace.detail.refreshCode' => 'Refresh Code',
			'sharedSpace.detail.joinOtherSpace' => 'Join Another Space',
			'sharedSpace.notifications.title' => 'Notifications',
			'sharedSpace.notifications.empty' => 'No notifications',
			'sharedSpace.notifications.emptyHint' => 'When you have new invites or activities,\nyou will receive notifications here',
			'sharedSpace.notifications.incompleteInfo' => 'Incomplete invite info',
			'sharedSpace.notifications.inviteAccepted' => 'Invite accepted!',
			'sharedSpace.notifications.inviteRejected' => 'Invite rejected',
			'sharedSpace.notifications.allMarkedRead' => 'All notifications marked as read',
			'sharedSpace.inviteCard.title' => 'Invite Code',
			'sharedSpace.inviteCard.subtitle' => 'Share with friends to join the space',
			'sharedSpace.inviteCard.copyCode' => 'Copy Invite Code',
			'sharedSpace.inviteCard.shareLink' => 'Share Invite Link',
			'sharedSpace.inviteCard.codeCopied' => 'Invite code copied',
			'sharedSpace.inviteCard.noExpiry' => 'No expiry',
			'sharedSpace.inviteCard.expired' => 'Expired',
			'sharedSpace.inviteCard.expiresInDays' => ({required Object days}) => 'Expires in ${days} days',
			'sharedSpace.inviteCard.expiresInHours' => ({required Object hours}) => 'Expires in ${hours} hours',
			'sharedSpace.inviteCard.expiresInMinutes' => ({required Object minutes}) => 'Expires in ${minutes} minutes',
			'sharedSpace.inviteCard.expiringSoon' => 'Expiring soon',
			'sharedSpace.inviteCard.shareText' => ({required Object spaceName, required Object code, required Object link, required Object expiry}) => 'You are invited to join the shared space "${spaceName}"\n\nInvite code: ${code}\nOr click the link to join directly: ${link}\n\nInvite code ${expiry}',
			'sharedSpace.inviteSuccess.title' => 'Created Successfully',
			'sharedSpace.inviteSuccess.subtitle' => 'Space Created Successfully',
			'sharedSpace.inviteSuccess.inviteLater' => 'Invite Later',
			'sharedSpace.inviteSuccess.enterSpace' => 'Enter Space',
			'sharedSpace.inviteSuccess.generatingCode' => 'Generating invite code...',
			'sharedSpace.inviteSuccess.generateFailed' => 'Failed to generate invite code',
			'sharedSpace.inviteSuccess.codeCopied' => 'Invite code copied',
			'sharedSpace.inviteSuccess.retry' => 'Retry',
			'sharedSpace.inviteSuccess.codeLabel' => 'Invite Code',
			'sharedSpace.inviteSuccess.validHint' => 'Valid for 24 hours · Tap to copy',
			'sharedSpace.notificationCard.accept' => 'Accept',
			'sharedSpace.notificationCard.reject' => 'Reject',
			'sharedSpace.notificationCard.unknownTime' => 'Unknown time',
			'sharedSpace.notificationCard.justNow' => 'Just now',
			'sharedSpace.spaceCard.noDescription' => 'No description',
			'sharedSpace.spaceCard.creator' => 'Creator',
			'sharedSpace.spaceCard.member' => 'Member',
			'sharedSpace.spaceCard.membersCount' => ({required Object count}) => '${count} members',
			'sharedSpace.spaceCard.transactionsCount' => ({required Object count}) => '${count} transactions',
			'sharedSpace.settings.title' => 'Space Settings',
			'sharedSpace.settings.spaceInfo' => 'Space Info',
			'sharedSpace.settings.nameLabel' => 'Space Name',
			'sharedSpace.settings.descLabel' => 'Space Description',
			'sharedSpace.settings.save' => 'Save',
			'sharedSpace.settings.saved' => 'Saved successfully',
			'sharedSpace.settings.saveFailed' => 'Failed to save',
			'sharedSpace.settings.memberManagement' => 'Member Management',
			'sharedSpace.settings.membersCount' => ({required Object count}) => '${count} members',
			'sharedSpace.settings.removeMemberConfirm' => ({required Object name}) => 'Are you sure you want to remove "${name}" from this space?',
			'sharedSpace.settings.removed' => 'Member removed',
			'sharedSpace.settings.removeFailed' => 'Failed to remove member',
			'sharedSpace.settings.inviteManagement' => 'Invite Management',
			'sharedSpace.settings.currentCode' => 'Current Invite Code',
			'sharedSpace.settings.generateNew' => 'Generate New Code',
			'sharedSpace.settings.noValidCode' => 'No valid invite code',
			'sharedSpace.settings.refreshCode' => 'Refresh Code',
			'sharedSpace.settings.refreshConfirm' => 'Generating a new code will invalidate the old one. Continue?',
			'sharedSpace.settings.codeRefreshed' => 'Invite code refreshed',
			'sharedSpace.settings.dangerZone' => 'Danger Zone',
			'sharedSpace.settings.editHint' => 'Only admins can edit',
			'sharedSpace.settings.edit' => 'Edit',
			'sharedSpace.settings.you' => 'You',
			'sharedSpace.settings.pending' => 'Pending',
			'sharedSpace.settings.declined' => 'Declined',
			'sharedSpace.settings.setAsAdmin' => 'Set as Admin',
			'sharedSpace.settings.setAsMember' => 'Set as Member',
			'sharedSpace.settings.changeRole' => 'Change Role',
			'sharedSpace.settings.changeRoleConfirm' => ({required Object name, required Object role}) => 'Are you sure you want to change "${name}"\'s role to "${role}"?',
			'sharedSpace.settings.confirm' => 'Confirm',
			'sharedSpace.settings.roleChanged' => 'Role changed',
			'sharedSpace.settings.roleChangeFailed' => 'Failed to change role',
			'errorMapping.generic.badRequest' => 'Bad Request',
			'errorMapping.generic.authFailed' => 'Authentication failed, please login again',
			'errorMapping.generic.permissionDenied' => 'Permission denied',
			'errorMapping.generic.notFound' => 'Resource not found',
			'errorMapping.generic.serverError' => 'Internal server error',
			'errorMapping.generic.systemError' => 'System error',
			'errorMapping.generic.validationFailed' => 'Validation failed',
			'errorMapping.auth.failed' => 'Authentication failed',
			'errorMapping.auth.emailWrong' => 'Incorrect email',
			'errorMapping.auth.phoneWrong' => 'Incorrect phone number',
			'errorMapping.auth.phoneRegistered' => 'Phone number already registered',
			'errorMapping.auth.emailRegistered' => 'Email already registered',
			'errorMapping.auth.sendFailed' => 'Failed to send verification code',
			'errorMapping.auth.expired' => 'Verification code expired',
			'errorMapping.auth.tooFrequent' => 'Code sent too frequently',
			'errorMapping.auth.unsupportedType' => 'Unsupported code type',
			'errorMapping.auth.wrongPassword' => 'Incorrect password',
			'errorMapping.auth.userNotFound' => 'User not found',
			'errorMapping.auth.prefsMissing' => 'Preference parameters missing',
			'errorMapping.auth.invalidTimezone' => 'Invalid client timezone',
			'errorMapping.transaction.commentEmpty' => 'Comment content cannot be empty',
			'errorMapping.transaction.invalidParent' => 'Invalid parent comment ID',
			'errorMapping.transaction.saveFailed' => 'Failed to save comment',
			'errorMapping.transaction.deleteFailed' => 'Failed to delete comment',
			'errorMapping.transaction.notExists' => 'Transaction does not exist',
			'errorMapping.space.notFound' => 'Shared space not found or access denied',
			'errorMapping.space.inviteDenied' => 'No permission to invite members',
			'errorMapping.space.inviteSelf' => 'Cannot invite yourself',
			'errorMapping.space.inviteSent' => 'Invitation sent',
			'errorMapping.space.alreadyMember' => 'User is already a member or invited',
			'errorMapping.space.invalidAction' => 'Invalid action',
			'errorMapping.space.invitationNotFound' => 'Invitation does not exist',
			'errorMapping.space.onlyOwner' => 'Only owner can perform this action',
			'errorMapping.space.ownerNotRemovable' => 'Owner cannot be removed',
			'errorMapping.space.memberNotFound' => 'Member not found',
			'errorMapping.space.notMember' => 'User is not a member of this space',
			'errorMapping.space.ownerCantLeave' => 'Owner cannot leave directly, please transfer ownership first',
			'errorMapping.space.invalidCode' => 'Invalid invitation code',
			'errorMapping.space.codeExpired' => 'Invitation code expired or usage limit reached',
			'errorMapping.space.transactionAlreadyInSpace' => 'Transaction already in this space',
			'errorMapping.recurring.invalidRule' => 'Invalid recurrence rule',
			'errorMapping.recurring.ruleNotFound' => 'Recurrence rule not found',
			'errorMapping.upload.noFile' => 'No file uploaded',
			'errorMapping.upload.tooLarge' => 'File too large',
			'errorMapping.upload.unsupportedType' => 'Unsupported file type',
			'errorMapping.upload.tooManyFiles' => 'Too many files',
			'errorMapping.storage.configNotFound' => 'Storage config not found or access denied',
			'errorMapping.storage.configInUse' => 'Cannot delete: storage config is still in use by attachments',
			'errorMapping.storage.invalidProviderType' => 'Invalid storage provider type',
			'errorMapping.ai.contextLimit' => 'Context limit exceeded',
			'errorMapping.ai.tokenLimit' => 'Insufficient tokens',
			'errorMapping.ai.emptyMessage' => 'Empty user message',
			'notification.title' => 'Notifications',
			'notification.markAllRead' => 'Mark all read',
			'notification.empty' => 'No notifications yet',
			'notification.loadFailed' => 'Failed to load',
			'notification.retry' => 'Retry',
			'notification.justNow' => 'Just now',
			'notification.minutesAgo' => ({required Object minutes}) => '${minutes}m ago',
			'notification.hoursAgo' => ({required Object hours}) => '${hours}h ago',
			'notification.daysAgo' => ({required Object days}) => '${days}d ago',
			'notification.deleted' => 'Deleted',
			'notification.types.system' => 'System',
			'notification.types.spaceInvite' => 'Space Invite',
			'notification.types.spaceActivity' => 'Space Activity',
			'notification.types.billComment' => 'Bill Comment',
			'notification.types.budgetAlert' => 'Budget Alert',
			'notification.types.transaction' => 'Transaction',
			'notification.semantic.memberJoined' => ({required Object name}) => '${name} joined your space',
			'notification.semantic.memberJoinedDetail' => ({required Object space}) => 'A new member joined "${space}"',
			'notification.semantic.welcome' => ({required Object space}) => 'Welcome to "${space}"',
			'notification.semantic.newTransaction' => ({required Object name}) => '${name} recorded a new expense',
			'notification.semantic.newTransactionDetail' => ({required Object amount, required Object space}) => '${amount} in "${space}"',
			'notification.semantic.memberLeft' => ({required Object name}) => '${name} left the space',
			'notification.semantic.recurringPending' => 'Recurring transaction pending',
			'notification.semantic.recurringPendingDetail' => ({required Object description, required Object amount}) => '${description} ${amount}, awaiting your confirmation',
			_ => null,
		};
	}
}
