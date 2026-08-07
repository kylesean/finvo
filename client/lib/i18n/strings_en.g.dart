///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsEn extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsEn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsEn _root = this; // ignore: unused_field

	@override
	TranslationsEn $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsEn(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$common$en common = _Translations$common$en._(_root);
	@override late final _Translations$genui$en genui = _Translations$genui$en._(_root);
	@override late final _Translations$time$en time = _Translations$time$en._(_root);
	@override late final _Translations$greeting$en greeting = _Translations$greeting$en._(_root);
	@override late final _Translations$navigation$en navigation = _Translations$navigation$en._(_root);
	@override late final _Translations$auth$en auth = _Translations$auth$en._(_root);
	@override late final _Translations$transaction$en transaction = _Translations$transaction$en._(_root);
	@override late final _Translations$home$en home = _Translations$home$en._(_root);
	@override late final _Translations$comment$en comment = _Translations$comment$en._(_root);
	@override late final _Translations$calendar$en calendar = _Translations$calendar$en._(_root);
	@override late final _Translations$category$en category = _Translations$category$en._(_root);
	@override late final _Translations$settings$en settings = _Translations$settings$en._(_root);
	@override late final _Translations$appearance$en appearance = _Translations$appearance$en._(_root);
	@override late final _Translations$speech$en speech = _Translations$speech$en._(_root);
	@override late final _Translations$amountTheme$en amountTheme = _Translations$amountTheme$en._(_root);
	@override late final _Translations$locale$en locale = _Translations$locale$en._(_root);
	@override late final _Translations$budget$en budget = _Translations$budget$en._(_root);
	@override late final _Translations$dateRange$en dateRange = _Translations$dateRange$en._(_root);
	@override late final _Translations$forecast$en forecast = _Translations$forecast$en._(_root);
	@override late final _Translations$chat$en chat = _Translations$chat$en._(_root);
	@override late final _Translations$image$en image = _Translations$image$en._(_root);
	@override late final _Translations$footprint$en footprint = _Translations$footprint$en._(_root);
	@override late final _Translations$media$en media = _Translations$media$en._(_root);
	@override late final _Translations$error$en error = _Translations$error$en._(_root);
	@override late final _Translations$fontTest$en fontTest = _Translations$fontTest$en._(_root);
	@override late final _Translations$wizard$en wizard = _Translations$wizard$en._(_root);
	@override late final _Translations$user$en user = _Translations$user$en._(_root);
	@override late final _Translations$account$en account = _Translations$account$en._(_root);
	@override late final _Translations$financial$en financial = _Translations$financial$en._(_root);
	@override late final _Translations$app$en app = _Translations$app$en._(_root);
	@override late final _Translations$statistics$en statistics = _Translations$statistics$en._(_root);
	@override late final _Translations$currency$en currency = _Translations$currency$en._(_root);
	@override late final _Translations$budgetSuggestion$en budgetSuggestion = _Translations$budgetSuggestion$en._(_root);
	@override late final _Translations$server$en server = _Translations$server$en._(_root);
	@override late final _Translations$sharedSpace$en sharedSpace = _Translations$sharedSpace$en._(_root);
	@override late final _Translations$errorMapping$en errorMapping = _Translations$errorMapping$en._(_root);
	@override late final _Translations$notification$en notification = _Translations$notification$en._(_root);
}

// Path: common
class _Translations$common$en extends Translations$common$zh {
	_Translations$common$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get loading => 'Loading...';
	@override String get error => 'Error';
	@override String get retry => 'Retry';
	@override String get cancel => 'Cancel';
	@override String get confirm => 'Confirm';
	@override String get save => 'Save';
	@override String get delete => 'Delete';
	@override String get edit => 'Edit';
	@override String get add => 'Add';
	@override String get search => 'Search';
	@override String get filter => 'Filter';
	@override String get sort => 'Sort';
	@override String get refresh => 'Refresh';
	@override String get more => 'More';
	@override String get less => 'Less';
	@override String get all => 'All';
	@override String get none => 'None';
	@override String get ok => 'OK';
	@override String get unknown => 'Unknown';
	@override String get noData => 'No Data';
	@override String get loadMore => 'Load More';
	@override String get noMore => 'No More';
	@override String get loadFailed => 'Loading failed';
	@override String get history => 'Transactions';
	@override String get reset => 'Reset';
	@override String get cancelled => 'Cancelled';
	@override String get saving => 'Saving...';
	@override String get saveFailed => 'Save failed';
}

// Path: genui
class _Translations$genui$en extends Translations$genui$zh {
	_Translations$genui$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get errorBusy => 'Sorry, the service is temporarily busy, please try again later';
	@override String get errorTimeout => 'Request timed out, please check your network and retry';
	@override String get errorNetwork => 'Network connection issue, please check and retry';
	@override String get errorSessionExpired => 'Session expired, please log in again';
	@override String get errorGeneric => 'Something went wrong, please try again later';
}

// Path: time
class _Translations$time$en extends Translations$time$zh {
	_Translations$time$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get today => 'Today';
	@override String get yesterday => 'Yesterday';
	@override String get dayBeforeYesterday => 'Day Before Yesterday';
	@override String get thisWeek => 'Week';
	@override String get thisMonth => 'Month';
	@override String get thisYear => 'Year';
	@override String get selectDate => 'Select Date';
	@override String get selectTime => 'Select Time';
	@override String get justNow => 'Just now';
	@override String minutesAgo({required Object count}) => '${count}m ago';
	@override String hoursAgo({required Object count}) => '${count}h ago';
	@override String daysAgo({required Object count}) => '${count}d ago';
	@override String weeksAgo({required Object count}) => '${count}w ago';
	@override String monthsAgo({required Object count}) => '${count}mo ago';
	@override String yearsAgo({required Object count}) => '${count}y ago';
}

// Path: greeting
class _Translations$greeting$en extends Translations$greeting$zh {
	_Translations$greeting$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get morning => 'Good Morning';
	@override String get afternoon => 'Good Afternoon';
	@override String get evening => 'Good Evening';
}

// Path: navigation
class _Translations$navigation$en extends Translations$navigation$zh {
	_Translations$navigation$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get home => 'Home';
	@override String get budget => 'Budget';
	@override String get chat => 'AI Chat';
	@override String get statistics => 'Statistics';
	@override String get forecast => 'Forecast';
	@override String get footprint => 'Footprint';
	@override String get profile => 'Profile';
}

// Path: auth
class _Translations$auth$en extends Translations$auth$zh {
	_Translations$auth$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get login => 'Log In';
	@override String get loggingIn => 'Logging in...';
	@override String get logout => 'Log Out';
	@override String get logoutSuccess => 'Logged out successfully';
	@override String get confirmLogoutTitle => 'Confirm Logout';
	@override String get confirmLogoutContent => 'Are you sure you want to log out?';
	@override String get register => 'Sign Up';
	@override String get registering => 'Signing up...';
	@override String get welcomeBack => 'Welcome Back';
	@override String get loginSuccess => 'Welcome back!';
	@override String get loginFailed => 'Login Failed';
	@override String get pleaseTryAgain => 'Please try again later.';
	@override String get loginSubtitle => 'Log in to continue using Finvo';
	@override String get noAccount => 'Don\'t have an account? Sign Up';
	@override String get createAccount => 'Create Your Account';
	@override String get setPassword => 'Set Password';
	@override String get setAccountPassword => 'Set Your Account Password';
	@override String get completeRegistration => 'Complete Registration';
	@override String get registrationSuccess => 'Registration successful!';
	@override String get registrationFailed => 'Registration failed';
	@override late final _Translations$auth$email$en email = _Translations$auth$email$en._(_root);
	@override late final _Translations$auth$password$en password = _Translations$auth$password$en._(_root);
	@override late final _Translations$auth$verificationCode$en verificationCode = _Translations$auth$verificationCode$en._(_root);
}

// Path: transaction
class _Translations$transaction$en extends Translations$transaction$zh {
	_Translations$transaction$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get expense => 'Expense';
	@override String get income => 'Income';
	@override String get transfer => 'Transfer';
	@override String get amount => 'Amount';
	@override String get category => 'Category';
	@override String get description => 'Description';
	@override String get tags => 'Tags';
	@override String get saveTransaction => 'Save Transaction';
	@override String get pleaseEnterAmount => 'Please enter amount';
	@override String get pleaseSelectCategory => 'Please select category';
	@override String get saveFailed => 'Failed to save';
	@override String get descriptionHint => 'Record details of this transaction...';
	@override String get addCustomTag => 'Add Custom Tag';
	@override String get commonTags => 'Common Tags';
	@override String maxTagsHint({required Object maxTags}) => 'Maximum ${maxTags} tags allowed';
	@override String get noTransactionsFound => 'No transactions found';
	@override String get tryAdjustingSearch => 'Try adjusting search criteria or create new transactions';
	@override String get noDescription => 'No description';
	@override String get payment => 'Payment';
	@override String get account => 'Account';
	@override String get time => 'Time';
	@override String get location => 'Location';
	@override String get transactionDetail => 'Transaction Details';
	@override String get favorite => 'Favorite';
	@override String get confirmDelete => 'Confirm Delete';
	@override String get deleteTransactionConfirm => 'Are you sure you want to delete this transaction? This action cannot be undone.';
	@override String get noActions => 'No actions available';
	@override String get deleted => 'Deleted';
	@override String get deleteFailed => 'Delete failed, please try again';
	@override String get linkedAccount => 'Linked Account';
	@override String get linkedSpace => 'Linked Space';
	@override String get notLinked => 'Not linked';
	@override String get link => 'Link';
	@override String get changeAccount => 'Change Account';
	@override String get addSpace => 'Add Space';
	@override String nSpaces({required Object count}) => '${count} spaces';
	@override String get selectLinkedAccount => 'Select Linked Account';
	@override String get selectLinkedSpace => 'Select Linked Space';
	@override String get noSpacesAvailable => 'No spaces available';
	@override String get linkSuccess => 'Link successful';
	@override String get linkFailed => 'Link failed';
	@override String get rawInput => 'Message';
	@override String get noRawInput => 'No message';
	@override String attachments({required Object count}) => '${count} attachments';
	@override String get viewInConversation => 'View more in conversation';
	@override String get statusPending => 'Pending';
}

// Path: home
class _Translations$home$en extends Translations$home$zh {
	_Translations$home$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get totalExpense => 'Total Expense';
	@override String get todayExpense => 'Today\'s';
	@override String get monthExpense => 'This Month\'s';
	@override String yearProgress({required Object year}) => '${year} Progress';
	@override String yearRemainingInfo({required Object days, required Object percent}) => 'Left ${days} days · ${percent}%';
	@override String get amountHidden => '••••••••';
	@override String get loadFailed => 'Load failed';
	@override String get noTransactions => 'No transactions';
	@override String get tryRefresh => 'Pull to refresh';
	@override String get noMoreData => 'No more data';
	@override String get userNotLoggedIn => 'User not logged in';
}

// Path: comment
class _Translations$comment$en extends Translations$comment$zh {
	_Translations$comment$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get error => 'Error';
	@override String get commentFailed => 'Comment failed';
	@override String replyToPrefix({required Object name}) => 'Reply to @${name}:';
	@override String get reply => 'Reply';
	@override String get contentRequired => 'Comment content is required';
	@override String get copyContent => 'Copy content';
	@override String get contentCopied => 'Comment content copied';
	@override String get collapseReplies => 'Collapse replies';
	@override String expandMoreReplies({required Object count}) => 'Show ${count} more replies';
	@override String get recordedBy => 'Recorded by';
	@override String get addNote => 'Add a note...';
	@override String get addNoteWithMention => 'Comment or @mention members...';
	@override String get confirmDeleteTitle => 'Confirm Delete';
	@override String get confirmDeleteContent => 'Are you sure you want to delete this comment? This action cannot be undone.';
	@override String get success => 'Success';
	@override String get commentDeleted => 'Comment deleted';
	@override String get deleteFailed => 'Failed to delete';
	@override String get deleteComment => 'Delete Comment';
	@override String get hint => 'Hint';
	@override String get noActions => 'No actions available';
	@override String get note => 'Note';
	@override String get noNote => 'No notes yet';
	@override String get loadFailed => 'Failed to load notes';
}

// Path: calendar
class _Translations$calendar$en extends Translations$calendar$zh {
	_Translations$calendar$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Expense Calendar';
	@override late final _Translations$calendar$weekdays$en weekdays = _Translations$calendar$weekdays$en._(_root);
	@override String get loadFailed => 'Failed to load calendar data';
	@override String thisMonth({required Object amount}) => 'Month: ${amount}';
	@override String get counting => 'Counting...';
	@override String get unableToCount => 'Unable to count';
	@override String get trend => 'Trend: ';
	@override String get noTransactionsTitle => 'No transactions on this day';
	@override String get loadTransactionFailed => 'Failed to load transactions';
}

// Path: category
class _Translations$category$en extends Translations$category$zh {
	_Translations$category$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get dailyConsumption => 'Daily Expenses';
	@override String get transportation => 'Transportation';
	@override String get healthcare => 'Healthcare';
	@override String get housing => 'Housing & Utilities';
	@override String get education => 'Education';
	@override String get incomeCategory => 'Income';
	@override String get socialGifts => 'Gifts & Donations';
	@override String get moneyTransfer => 'Transfers';
	@override String get other => 'Other';
	@override String get foodDining => 'Food & Dining';
	@override String get shoppingRetail => 'Shopping';
	@override String get housingUtilities => 'Housing & Utilities';
	@override String get personalCare => 'Personal Care';
	@override String get entertainment => 'Entertainment';
	@override String get medicalHealth => 'Medical & Health';
	@override String get insurance => 'Insurance';
	@override String get socialGifting => 'Social & Gifting';
	@override String get financialTax => 'Financial & Tax';
	@override String get others => 'Others';
	@override String get salaryWage => 'Salary';
	@override String get businessTrade => 'Business';
	@override String get investmentReturns => 'Investment Returns';
	@override String get giftBonus => 'Gift & Bonus';
	@override String get refundRebate => 'Refund';
	@override String get generalTransfer => 'Transfer';
	@override String get debtRepayment => 'Debt Repayment';
}

// Path: settings
class _Translations$settings$en extends Translations$settings$zh {
	_Translations$settings$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Settings';
	@override String get language => 'Language';
	@override String get languageSettings => 'Language Settings';
	@override String get selectLanguage => 'Select Language';
	@override String get languageChanged => 'Language Changed';
	@override String get restartToApply => 'Restart app to apply changes';
	@override String get theme => 'Theme';
	@override String get darkMode => 'Dark Mode';
	@override String get lightMode => 'Light Mode';
	@override String get systemMode => 'Follow System';
	@override String get developerOptions => 'Developer Options';
	@override String get authDebug => 'Auth Debug';
	@override String get authDebugSubtitle => 'View authentication status and debug info';
	@override String get fontTest => 'Font Test';
	@override String get fontTestSubtitle => 'Test application font display';
	@override String get helpAndFeedback => 'Help & Feedback';
	@override String get helpAndFeedbackSubtitle => 'Get help or provide feedback';
	@override String get aboutApp => 'About';
	@override String get aboutAppSubtitle => 'Version info and check for updates';
	@override String get checkUpdate => 'Check for Updates';
	@override String get checkingUpdate => 'Checking for updates...';
	@override String get latestVersionToast => 'You are on the latest version';
	@override String get newVersionTitle => 'New Version Available';
	@override String currentVersion({required Object version}) => 'Current version: v${version}';
	@override String get updateNow => 'Update Now';
	@override String get updateLater => 'Later';
	@override String get fetchUpdateFailed => 'Failed to check for updates, please try again later';
	@override String currencyChangedRefreshHint({required Object currency}) => 'Switched to ${currency}. New transactions will use this currency.';
	@override String get sharedSpace => 'Shared Space';
	@override String get speechRecognition => 'Speech Recognition';
	@override String get speechRecognitionSubtitle => 'Configure voice input parameters';
	@override String get amountDisplayStyle => 'Amount Display Style';
	@override String get currency => 'Currency';
	@override String get appearance => 'Appearance Settings';
	@override String get appearanceSubtitle => 'Theme mode and color scheme';
	@override String get speechTest => 'Speech Test';
	@override String get speechTestSubtitle => 'Test WebSocket speech connection';
	@override String get userTypeRegular => 'Regular User';
	@override String get selectAmountStyle => 'Select Amount Display Style';
	@override String get amountStyleNotice => 'Note: Amount styles are primarily applied to \'Transactions\' and \'Trends\'. To maintain visual clarity, \'Account Balances\' and \'Asset Summaries\' will remain in neutral colors.';
	@override String get currencyDescription => 'Choose your preferred display currency. All amounts will be displayed in this currency.';
	@override String get editUsername => 'Edit Username';
	@override String get enterUsername => 'Enter username';
	@override String get usernameRequired => 'Username is required';
	@override String get usernameUpdated => 'Username updated';
	@override String get avatarUpdated => 'Avatar updated';
	@override String get appearanceUpdated => '外观设置已更新';
}

// Path: appearance
class _Translations$appearance$en extends Translations$appearance$zh {
	_Translations$appearance$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Appearance Settings';
	@override String get themeMode => 'Theme Mode';
	@override String get light => 'Light';
	@override String get dark => 'Dark';
	@override String get system => 'System';
	@override String get colorScheme => 'Color Scheme';
	@override late final _Translations$appearance$palettes$en palettes = _Translations$appearance$palettes$en._(_root);
}

// Path: speech
class _Translations$speech$en extends Translations$speech$zh {
	_Translations$speech$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Speech Recognition Settings';
	@override String get service => 'Speech Recognition Service';
	@override String get systemVoice => 'System Voice';
	@override String get systemVoiceSubtitle => 'Use built-in device service (Recommended)';
	@override String get selfHostedASR => 'Self-hosted ASR';
	@override String get selfHostedASRSubtitle => 'Use WebSocket connection to self-hosted service';
	@override String get serverConfig => 'Server Configuration';
	@override String get serverAddress => 'Server Address';
	@override String get port => 'Port';
	@override String get path => 'Path';
	@override String get saveConfig => 'Save Configuration';
	@override String get info => 'Information';
	@override String get infoContent => '• System Voice: Uses device service, no config needed, faster response\n• Self-hosted ASR: Suitable for custom models or offline scenarios\n\nChanges will take effect next time you use voice input.';
	@override String get enterAddress => 'Please enter server address';
	@override String get enterValidPort => 'Please enter a valid port (1-65535)';
	@override String get configSaved => 'Configuration saved';
	@override String get configSaveFailed => 'Failed to save configuration';
	@override String get systemVoiceRestrictedTitle => 'System Speech Unavailable';
	@override String get systemVoiceRestrictedContent => 'System speech service is unavailable or disabled. You can check system settings or configure a custom WebSocket ASR in Speech Settings.';
	@override String get dictationDisabledTitle => 'Dictation Disabled';
	@override String get dictationDisabledContent => 'System speech dictation service is disabled. On iOS devices, please go to Settings -> General -> Keyboard and enable Dictation.';
	@override String get permissionDeniedTitle => 'Permissions Required';
	@override String get permissionDeniedContent => 'Microphone and speech recognition permissions are required for this feature. Please grant them in System Settings.';
	@override String get goToSettings => 'Go to Settings';
	@override String get systemVoiceStatusAvailable => 'System Speech Supported';
	@override String get systemVoiceStatusRestricted => 'System Speech Restricted or Unavailable (Self-hosted ASR recommended)';
	@override String get serviceNotConfigured => 'Speech service is not configured. Please set the server address in Speech Settings.';
	@override String get connectionFailedTitle => 'Speech Service Connection Failed';
	@override String get connectionFailed => 'Cannot connect to WebSocket speech recognition service. Please check your server address, port, or network connectivity.';
	@override String get noSpeechRecognized => 'No speech input detected, please try again.';
}

// Path: amountTheme
class _Translations$amountTheme$en extends Translations$amountTheme$zh {
	_Translations$amountTheme$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get chinaMarket => 'China Market Style';
	@override String get chinaMarketDesc => 'Red up, Green/Black down (Recommended)';
	@override String get international => 'International Standard';
	@override String get internationalDesc => 'Green up, Red down';
	@override String get minimalist => 'Minimalist';
	@override String get minimalistDesc => 'Distinguish with symbols only';
	@override String get colorBlind => 'Color Blind Friendly';
	@override String get colorBlindDesc => 'Blue-Orange color scheme';
}

// Path: locale
class _Translations$locale$en extends Translations$locale$zh {
	_Translations$locale$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get chinese => 'Simplified Chinese';
	@override String get english => 'English';
	@override String get japanese => 'Japanese';
	@override String get korean => 'Korean';
	@override String get traditionalChinese => 'Traditional Chinese';
}

// Path: budget
class _Translations$budget$en extends Translations$budget$zh {
	_Translations$budget$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Budget Management';
	@override String get detail => 'Budget Details';
	@override String get info => 'Budget Info';
	@override String get totalBudget => 'Total Budget';
	@override String get categoryBudget => 'Category Budget';
	@override String get monthlySummary => 'Monthly Budget Summary';
	@override String get used => 'Used';
	@override String get remaining => 'Remaining';
	@override String get overspent => 'Overspent';
	@override String get budget => 'Budget';
	@override String get loadFailed => 'Failed to load';
	@override String get noBudget => 'No budgets yet';
	@override String get createHint => 'Tap the button below to set up your budget';
	@override String get paused => 'Paused';
	@override String get pause => 'Pause';
	@override String get resume => 'Resume';
	@override String get budgetPaused => 'Budget paused';
	@override String get budgetResumed => 'Budget resumed';
	@override String get operationFailed => 'Operation failed';
	@override String get deleteBudget => 'Delete Budget';
	@override String get deleteConfirm => 'Are you sure you want to delete this budget? This cannot be undone.';
	@override String get type => 'Type';
	@override String get category => 'Category';
	@override String get period => 'Repeat Rule';
	@override String get rollover => 'Rollover';
	@override String get rolloverBalance => 'Rollover Balance';
	@override String get enabled => 'Enabled';
	@override String get disabled => 'Disabled';
	@override String get statusNormal => 'On Track';
	@override String get statusWarning => 'Near Limit';
	@override String get statusOverspent => 'Overspent';
	@override String get statusAchieved => 'Goal Achieved';
	@override String tipNormal({required Object amount}) => '${amount} remaining';
	@override String tipWarning({required Object amount}) => 'Only ${amount} left, be careful';
	@override String tipOverspent({required Object amount}) => 'Overspent by ${amount}';
	@override String get tipAchieved => 'Congratulations on achieving your savings goal!';
	@override String remainingAmount({required Object amount}) => '${amount} remaining';
	@override String overspentAmount({required Object amount}) => 'Overspent ${amount}';
	@override String budgetAmount({required Object amount}) => 'Budget ${amount}';
	@override String get active => 'Active';
	@override String get all => 'All';
	@override String get notFound => 'Budget not found or deleted';
	@override String get setup => 'Budget Setup';
	@override String get settings => 'Budget Settings';
	@override String get setAmount => 'Set Budget Amount';
	@override String get setAmountDesc => 'Set budget amount for each category';
	@override String get monthly => 'Monthly Budget';
	@override String get monthlyDesc => 'Manage expenses monthly, suitable for most users';
	@override String get weekly => 'Weekly Budget';
	@override String get weeklyDesc => 'Manage expenses weekly for finer control';
	@override String get yearly => 'Annual Budget';
	@override String get yearlyDesc => 'Long-term financial planning for major expenses';
	@override String get editBudget => 'Edit Budget';
	@override String get editBudgetDesc => 'Modify budget amounts and categories';
	@override String get reminderSettings => 'Reminder Settings';
	@override String get reminderSettingsDesc => 'Set budget reminders and notifications';
	@override String get report => 'Budget Report';
	@override String get reportDesc => 'View detailed budget analysis reports';
	@override String get welcome => 'Welcome to Budget Feature!';
	@override String get createNewPlan => 'Create New Budget Plan';
	@override String get welcomeDesc => 'Set budgets to better control spending and achieve financial goals. Let\'s start setting up your first budget plan!';
	@override String get createDesc => 'Set budget limits for different spending categories to manage your finances better.';
	@override String get newBudget => 'New Budget';
	@override String get budgetAmountLabel => 'Budget Amount';
	@override String get currency => 'Currency';
	@override String get periodSettings => 'Period Settings';
	@override String get autoGenerateTransactions => 'Automatically generate transactions by rule';
	@override String get cycle => 'Cycle';
	@override String get budgetCategory => 'Budget Category';
	@override String get advancedOptions => 'Advanced Options';
	@override String get periodType => 'Period Type';
	@override String get anchorDay => 'Anchor Day';
	@override String get selectPeriodType => 'Select Period Type';
	@override String get selectAnchorDay => 'Select Anchor Day';
	@override String get rolloverDescription => 'Carry over unused budget to next period';
	@override String get createBudget => 'Create Budget';
	@override String get save => 'Save';
	@override String get pleaseEnterAmount => 'Please enter budget amount';
	@override String get invalidAmount => 'Please enter a valid amount';
	@override String get updateSuccess => 'Budget updated successfully';
	@override String get createSuccess => 'Budget created successfully';
	@override String get deleteSuccess => 'Budget deleted';
	@override String get deleteFailed => 'Delete failed';
	@override String everyMonthDay({required Object day}) => 'Day ${day} of each month';
	@override String get periodWeekly => 'Weekly';
	@override String get periodBiweekly => 'Biweekly';
	@override String get periodMonthly => 'Monthly';
	@override String get periodYearly => 'Yearly';
	@override String get statusActive => 'Active';
	@override String get statusArchived => 'Archived';
	@override String get periodStatusOnTrack => 'On Track';
	@override String get periodStatusWarning => 'Warning';
	@override String get periodStatusExceeded => 'Exceeded';
	@override String get periodStatusAchieved => 'Achieved';
	@override String usedPercent({required Object percent}) => '${percent}% used';
	@override String dayOfMonth({required Object day}) => 'Day ${day}';
	@override String get tenThousandSuffix => '0k';
	@override String get settingsLoadFailed => 'Failed to load settings';
	@override String get settingsSaveSuccess => 'Settings saved';
	@override String get settingsSaveFailed => 'Failed to save';
	@override String get settingsSave => 'Save Settings';
	@override String get settingsWarningThreshold => 'Warning Threshold';
	@override String get settingsWarningDesc => 'Shows warning status when usage reaches this percentage';
	@override String get settingsAlertThreshold => 'Alert Threshold';
	@override String get settingsAlertDesc => 'Shows exceeded status when usage reaches this percentage';
	@override String get settingsThresholdOrder => 'Warning threshold cannot exceed alert threshold';
}

// Path: dateRange
class _Translations$dateRange$en extends Translations$dateRange$zh {
	_Translations$dateRange$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get custom => 'Custom';
	@override String get pickerTitle => 'Select Date Range';
	@override String get startDate => 'Start Date';
	@override String get endDate => 'End Date';
	@override String get hint => 'Please select a date range';
}

// Path: forecast
class _Translations$forecast$en extends Translations$forecast$zh {
	_Translations$forecast$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Forecast';
	@override String get subtitle => 'AI-powered cash flow predictions based on your financial data';
	@override String get financialNavigator => 'Hello, I\'m your Financial Navigator';
	@override String get financialMapSubtitle => 'In just 3 steps, let\'s map your financial future together';
	@override String get predictCashFlow => 'Predict Cash Flow';
	@override String get predictCashFlowDesc => 'See your daily financial status';
	@override String get aiSmartSuggestions => 'AI Smart Suggestions';
	@override String get aiSmartSuggestionsDesc => 'Personalized financial decision guidance';
	@override String get riskWarning => 'Risk Alerts';
	@override String get riskWarningDesc => 'Detect potential financial risks early';
	@override String get analyzing => 'Analyzing your financial data to generate a 30-day cash flow forecast';
	@override String get analyzePattern => 'Analyzing income & expense patterns';
	@override String get calculateTrend => 'Calculating cash flow trends';
	@override String get generateWarning => 'Generating risk alerts';
	@override String get loadingForecast => 'Loading financial forecast...';
	@override String get todayLabel => 'Today';
	@override String get tomorrowLabel => 'Tomorrow';
	@override String get balanceLabel => 'Balance';
	@override String get noSpecialEvents => 'No special events';
	@override String get financialSafetyLine => 'Financial Safety Net';
	@override String get currentSetting => 'Current Setting';
	@override String get dailySpendingEstimate => 'Daily Spending Estimate';
	@override String get adjustDailySpendingAmount => 'Adjust daily spending forecast amount';
	@override String get tellMeYourSafetyLine => 'What\'s your financial safety threshold?';
	@override String get safetyLineDescription => 'This is the minimum balance you want to maintain. I\'ll alert you when your balance approaches this amount.';
	@override String get dailySpendingQuestion => 'How much do you spend daily?';
	@override String get dailySpendingDescription => 'Including meals, transportation, shopping and other daily expenses\nThis is just an initial estimate - predictions will improve with your actual records';
	@override String get perDay => 'per day';
	@override String get referenceStandard => 'Reference';
	@override String get frugalType => 'Frugal';
	@override String get comfortableType => 'Comfortable';
	@override String get relaxedType => 'Relaxed';
	@override String get frugalAmount => '¥50-100/day';
	@override String get comfortableAmount => '¥100-200/day';
	@override String get relaxedAmount => '¥200-300/day';
	@override late final _Translations$forecast$recurringTransaction$en recurringTransaction = _Translations$forecast$recurringTransaction$en._(_root);
}

// Path: chat
class _Translations$chat$en extends Translations$chat$zh {
	_Translations$chat$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get newChat => 'New Chat';
	@override String get noMessages => 'No messages to display.';
	@override String get loadingFailed => 'Loading failed';
	@override String get inputMessage => 'Type a message...';
	@override String get aiThinking => 'AI processing...';
	@override String get stoppedResponse => 'You have stopped this response';
	@override String get errorRecover => 'Sorry, I encountered an issue, please try again 🙏';
	@override String get contentCopied => 'Content copied';
	@override String get jsonCopied => 'JSON data copied';
	@override String get noContentToCopy => 'No content to copy';
	@override String get listening => 'Listening...';
	@override late final _Translations$chat$tools$en tools = _Translations$chat$tools$en._(_root);
	@override String get speechNotRecognized => 'Speech not recognized, please try again';
	@override String get currentExpense => 'Session Expense';
	@override String get loadingComponent => 'Loading component...';
	@override String get noHistory => 'No historical sessions';
	@override String get startNewChat => 'Start a new conversation!';
	@override String get searchHint => 'Search conversations';
	@override String get library => 'Library';
	@override String get viewProfile => 'View profile';
	@override String get noRelatedFound => 'No related conversations found';
	@override String get tryOtherKeywords => 'Try searching with other keywords';
	@override String get searchFailed => 'Search failed';
	@override String updatedAt({required Object time}) => 'Updated ${time}';
	@override String createdAt({required Object time}) => 'Created ${time}';
	@override String get deleteConversation => 'Delete Conversation';
	@override String get deleteConversationConfirm => 'Are you sure you want to delete this conversation? This action cannot be undone.';
	@override String get conversationDeleted => 'Conversation deleted';
	@override String get deleteConversationFailed => 'Failed to delete conversation';
	@override late final _Translations$chat$transferWizard$en transferWizard = _Translations$chat$transferWizard$en._(_root);
	@override late final _Translations$chat$genui$en genui = _Translations$chat$genui$en._(_root);
	@override late final _Translations$chat$welcome$en welcome = _Translations$chat$welcome$en._(_root);
	@override String get shareComingSoon => 'Share feature coming soon...';
	@override String get invalidAttachmentLink => 'Invalid attachment link';
	@override String get unableToOpenAttachmentLink => 'Unable to open attachment link';
	@override String aiCommunicationError({required Object error}) => 'Sorry, AI assistant communication error: ${error}';
}

// Path: image
class _Translations$image$en extends Translations$image$zh {
	_Translations$image$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get deleteTitle => 'Delete Image';
	@override String get deleteConfirm => 'Are you sure you want to delete this image? This action cannot be undone.';
}

// Path: footprint
class _Translations$footprint$en extends Translations$footprint$zh {
	_Translations$footprint$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get searchIn => 'Search';
	@override String get searchInAllRecords => 'Search in all records';
}

// Path: media
class _Translations$media$en extends Translations$media$zh {
	_Translations$media$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get selectPhotos => 'Select Photos';
	@override String get addFiles => 'Add Files';
	@override String get takePhoto => 'Take Photo';
	@override String get camera => 'Camera';
	@override String get photos => 'Photos';
	@override String get files => 'Files';
	@override String get showAll => 'Show All';
	@override String get allPhotos => 'All Photos';
	@override String get takingPhoto => 'Taking photo...';
	@override String get photoTaken => 'Photo saved';
	@override String get cameraPermissionRequired => 'Camera permission required';
	@override String get fileSizeExceeded => 'File size exceeds 10MB limit';
	@override String get unsupportedFormat => 'Unsupported file format';
	@override String get permissionDenied => 'Photo library access required';
	@override String get storageInsufficient => 'Insufficient storage space';
	@override String get networkError => 'Network connection error';
	@override String get unknownUploadError => 'Unknown error during upload';
}

// Path: error
class _Translations$error$en extends Translations$error$zh {
	_Translations$error$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get permissionRequired => 'Permission Required';
	@override String get permissionInstructions => 'Please enable photo library and storage permissions in Settings to select and upload files.';
	@override String get openSettings => 'Open Settings';
	@override String get fileTooLarge => 'File Too Large';
	@override String get fileSizeHint => 'Please select files under 10MB, or compress before uploading.';
	@override String get supportedFormatsHint => 'Supported formats: images (jpg, png, gif), documents (pdf, doc, txt), audio/video files.';
	@override String get storageCleanupHint => 'Please free up storage space and try again, or select smaller files.';
	@override String get networkErrorHint => 'Please check your network connection and try again.';
	@override String get platformNotSupported => 'Platform Not Supported';
	@override String get fileReadError => 'File Read Error';
	@override String get fileReadErrorHint => 'The file may be corrupted or in use. Please select a different file.';
	@override String get validationError => 'File Validation Error';
	@override String get unknownError => 'Unknown Error';
	@override String get unknownErrorHint => 'An unexpected error occurred. Please try again or contact support.';
	@override String get registrationMissingInfo => 'Registration flow error, missing required information.';
	@override String get accountInfoMissing => 'Account information missing';
	@override String get sharedSpaceInfoMissing => 'Shared space information missing';
	@override String get settingsSteps => 'Settings steps:';
	@override String get suggestions => 'Suggestions:';
	@override String get fileNotFound => 'File not found';
	@override String get fileNotFoundHint => 'Please confirm the file exists or select another file.';
	@override String get selectAgain => 'Select again';
	@override String get thumbnailGenerationFailed => 'Thumbnail generation failed';
	@override String get thumbnailGenerationHint => 'Failed to generate thumbnail for the image, but the file has been selected. You can still continue using this file.';
	@override String get help => 'Help:';
	@override late final _Translations$error$genui$en genui = _Translations$error$genui$en._(_root);
}

// Path: fontTest
class _Translations$fontTest$en extends Translations$fontTest$zh {
	_Translations$fontTest$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get page => 'Font Test Page';
	@override String get displayTest => 'Font Display Test';
	@override String get chineseTextTest => 'Chinese Text Test';
	@override String get englishTextTest => 'English Text Test';
	@override String get sample1 => 'This is a sample text for testing font display effects.';
	@override String get sample2 => 'Expense category summary, shopping is highest';
	@override String get sample3 => 'AI assistant provides professional financial analysis services';
	@override String get sample4 => 'Data visualization charts show your spending trends';
	@override String get sample5 => 'WeChat Pay, Alipay, bank cards and other payment methods';
}

// Path: wizard
class _Translations$wizard$en extends Translations$wizard$zh {
	_Translations$wizard$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get nextStep => 'Next';
	@override String get previousStep => 'Previous';
	@override String get completeMapping => 'Complete';
}

// Path: user
class _Translations$user$en extends Translations$user$zh {
	_Translations$user$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get username => 'Username';
	@override String get defaultEmail => 'user@example.com';
}

// Path: account
class _Translations$account$en extends Translations$account$zh {
	_Translations$account$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get editTitle => 'Edit Account';
	@override String get addTitle => 'New Account';
	@override String get selectTypeTitle => 'Select Account Type';
	@override String get nameLabel => 'Account Name';
	@override String get amountLabel => 'Current Balance';
	@override String get currencyLabel => 'Currency';
	@override String get hiddenLabel => 'Hidden';
	@override String get hiddenDesc => 'Hide this account from the list';
	@override String get includeInNetWorthLabel => 'Include in Net Worth';
	@override String get includeInNetWorthDesc => 'Count towards total net worth';
	@override String get nameHint => 'e.g. Salary Card';
	@override String get amountHint => '0.00';
	@override String get deleteAccount => 'Delete Account';
	@override String get deleteConfirm => 'Are you sure you want to delete this account? This cannot be undone.';
	@override String get save => 'Save Changes';
	@override String get assetsCategory => 'Assets';
	@override String get liabilitiesCategory => 'Liabilities/Credit';
	@override String get cash => 'Cash Wallet';
	@override String get deposit => 'Bank Deposit';
	@override String get creditCard => 'Credit Card';
	@override String get investment => 'Investment';
	@override String get eWallet => 'E-Wallet';
	@override String get loan => 'Loan';
	@override String get receivable => 'Receivable';
	@override String get payable => 'Payable';
	@override String get other => 'Other';
	@override late final _Translations$account$types$en types = _Translations$account$types$en._(_root);
}

// Path: financial
class _Translations$financial$en extends Translations$financial$zh {
	_Translations$financial$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Financial';
	@override String get management => 'Financial Management';
	@override String get netWorth => 'Total Net Worth';
	@override String get assets => 'Total Assets';
	@override String get liabilities => 'Total Liabilities';
	@override String get noAccounts => 'No accounts yet';
	@override String get addFirstAccount => 'Tap the button below to add your first account';
	@override String get assetAccounts => 'Asset Accounts';
	@override String get liabilityAccounts => 'Liability Accounts';
	@override String get selectCurrency => 'Select Currency';
	@override String get cancel => 'Cancel';
	@override String get confirm => 'Confirm';
	@override String get settings => 'Financial Settings';
	@override String get budgetManagement => 'Budget Management';
	@override String get recurringTransactions => 'Recurring Transactions';
	@override String get safetyThreshold => 'Safety Threshold';
	@override String get dailyBurnRate => 'Daily Burn Rate';
	@override String get financialAssistant => 'Financial Assistant';
	@override String get manageFinancialSettings => 'Manage your financial settings';
	@override String get safetyThresholdSettings => 'Safety Threshold Settings';
	@override String get setSafetyThreshold => 'Set your financial safety threshold';
	@override String get safetyThresholdSaved => 'Safety threshold saved';
	@override String get dailyBurnRateSettings => 'Daily Burn Rate';
	@override String get setDailyBurnRate => 'Set your estimated daily spending';
	@override String get dailyBurnRateSaved => 'Daily burn rate saved';
	@override String get dayUnit => 'day';
	@override String get saveFailed => 'Save failed';
	@override String get deleteFailed => 'Delete failed, please try again later';
	@override String missingExchangeRates({required Object currencies}) => 'Exchange rates are unavailable for some currencies, so the related accounts are excluded from totals: ${currencies}';
	@override String get cashPocketTitle => 'My Cash Pockets';
	@override String sourcesCount({required Object count}) => '${count} Sources';
	@override String lastUpdatedAt({required Object time}) => 'Last updated: ${time}';
	@override String get neverUpdated => 'Never updated';
	@override String get updateNow => 'Update Now';
}

// Path: app
class _Translations$app$en extends Translations$app$zh {
	_Translations$app$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get splashTitle => 'Finvo: Intelligence that Grows.';
	@override String get splashSubtitle => 'Smart Financial Assistant';
}

// Path: statistics
class _Translations$statistics$en extends Translations$statistics$zh {
	_Translations$statistics$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Analysis';
	@override String get analyze => 'Analysis';
	@override String get exportInProgress => 'Export feature coming soon...';
	@override String get ranking => 'Top Spending';
	@override String get noData => 'No data available';
	@override late final _Translations$statistics$overview$en overview = _Translations$statistics$overview$en._(_root);
	@override late final _Translations$statistics$trend$en trend = _Translations$statistics$trend$en._(_root);
	@override late final _Translations$statistics$analysis$en analysis = _Translations$statistics$analysis$en._(_root);
	@override late final _Translations$statistics$filter$en filter = _Translations$statistics$filter$en._(_root);
	@override late final _Translations$statistics$sort$en sort = _Translations$statistics$sort$en._(_root);
	@override String get exportList => 'Export List';
	@override late final _Translations$statistics$emptyState$en emptyState = _Translations$statistics$emptyState$en._(_root);
	@override String get noMoreData => 'No more data';
}

// Path: currency
class _Translations$currency$en extends Translations$currency$zh {
	_Translations$currency$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get cny => 'Chinese Yuan';
	@override String get usd => 'US Dollar';
	@override String get eur => 'Euro';
	@override String get jpy => 'Japanese Yen';
	@override String get gbp => 'British Pound';
	@override String get aud => 'Australian Dollar';
	@override String get cad => 'Canadian Dollar';
	@override String get chf => 'Swiss Franc';
	@override String get rub => 'Russian Ruble';
	@override String get hkd => 'Hong Kong Dollar';
	@override String get twd => 'New Taiwan Dollar';
	@override String get inr => 'Indian Rupee';
}

// Path: budgetSuggestion
class _Translations$budgetSuggestion$en extends Translations$budgetSuggestion$zh {
	_Translations$budgetSuggestion$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String highPercentage({required Object category, required Object percentage}) => '${category} accounts for ${percentage}% of spending. Consider setting a budget limit.';
	@override String monthlyIncrease({required Object percentage}) => 'Spending increased by ${percentage}% this month. Needs attention.';
	@override String frequentSmall({required Object category, required Object count}) => '${category} has ${count} small transactions. These might be subscriptions.';
	@override String get financialInsights => 'Financial Insights';
}

// Path: server
class _Translations$server$en extends Translations$server$zh {
	_Translations$server$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Connect to Server';
	@override String get subtitle => 'Enter your self-hosted server address or scan the QR code displayed when starting the server';
	@override String get urlLabel => 'Server Address';
	@override String get urlPlaceholder => 'e.g. https://api.example.com or 192.168.1.100:8000';
	@override String get scanQr => 'Scan QR Code';
	@override String get scanQrInstruction => 'Point at the QR code displayed in the server terminal';
	@override String get testConnection => 'Test Connection';
	@override String get connecting => 'Connecting...';
	@override String get connected => 'Connected';
	@override String get connectionFailed => 'Connection Failed';
	@override String get continueToLogin => 'Continue to Login';
	@override String get saveAndReturn => 'Save and Return';
	@override String get saveAndReLogin => 'Save and Re-login';
	@override String get serverUrlSavedRedirectLogin => 'Server configuration updated, please log in again';
	@override String get serverSettings => 'Server Settings';
	@override String get currentServer => 'Current Server';
	@override String get version => 'Version';
	@override String get environment => 'Environment';
	@override String get changeServer => 'Change Server';
	@override String get changeServerWarning => 'Changing server will log you out. Continue?';
	@override late final _Translations$server$error$en error = _Translations$server$error$en._(_root);
}

// Path: sharedSpace
class _Translations$sharedSpace$en extends Translations$sharedSpace$zh {
	_Translations$sharedSpace$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$sharedSpace$dashboard$en dashboard = _Translations$sharedSpace$dashboard$en._(_root);
	@override late final _Translations$sharedSpace$roles$en roles = _Translations$sharedSpace$roles$en._(_root);
	@override String get title => 'Shared Space';
	@override late final _Translations$sharedSpace$create$en create = _Translations$sharedSpace$create$en._(_root);
	@override late final _Translations$sharedSpace$join$en join = _Translations$sharedSpace$join$en._(_root);
	@override late final _Translations$sharedSpace$list$en list = _Translations$sharedSpace$list$en._(_root);
	@override late final _Translations$sharedSpace$detail$en detail = _Translations$sharedSpace$detail$en._(_root);
	@override late final _Translations$sharedSpace$notifications$en notifications = _Translations$sharedSpace$notifications$en._(_root);
	@override late final _Translations$sharedSpace$inviteCard$en inviteCard = _Translations$sharedSpace$inviteCard$en._(_root);
	@override late final _Translations$sharedSpace$inviteSuccess$en inviteSuccess = _Translations$sharedSpace$inviteSuccess$en._(_root);
	@override late final _Translations$sharedSpace$notificationCard$en notificationCard = _Translations$sharedSpace$notificationCard$en._(_root);
	@override late final _Translations$sharedSpace$spaceCard$en spaceCard = _Translations$sharedSpace$spaceCard$en._(_root);
	@override late final _Translations$sharedSpace$settings$en settings = _Translations$sharedSpace$settings$en._(_root);
}

// Path: errorMapping
class _Translations$errorMapping$en extends Translations$errorMapping$zh {
	_Translations$errorMapping$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$errorMapping$generic$en generic = _Translations$errorMapping$generic$en._(_root);
	@override late final _Translations$errorMapping$auth$en auth = _Translations$errorMapping$auth$en._(_root);
	@override late final _Translations$errorMapping$transaction$en transaction = _Translations$errorMapping$transaction$en._(_root);
	@override late final _Translations$errorMapping$space$en space = _Translations$errorMapping$space$en._(_root);
	@override late final _Translations$errorMapping$recurring$en recurring = _Translations$errorMapping$recurring$en._(_root);
	@override late final _Translations$errorMapping$upload$en upload = _Translations$errorMapping$upload$en._(_root);
	@override late final _Translations$errorMapping$storage$en storage = _Translations$errorMapping$storage$en._(_root);
	@override late final _Translations$errorMapping$ai$en ai = _Translations$errorMapping$ai$en._(_root);
}

// Path: notification
class _Translations$notification$en extends Translations$notification$zh {
	_Translations$notification$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Notifications';
	@override String get markAllRead => 'Mark all read';
	@override String get empty => 'No notifications yet';
	@override String get loadFailed => 'Failed to load';
	@override String get retry => 'Retry';
	@override String get justNow => 'Just now';
	@override String minutesAgo({required Object minutes}) => '${minutes}m ago';
	@override String hoursAgo({required Object hours}) => '${hours}h ago';
	@override String daysAgo({required Object days}) => '${days}d ago';
	@override String get deleted => 'Deleted';
	@override late final _Translations$notification$types$en types = _Translations$notification$types$en._(_root);
	@override late final _Translations$notification$semantic$en semantic = _Translations$notification$semantic$en._(_root);
}

// Path: auth.email
class _Translations$auth$email$en extends Translations$auth$email$zh {
	_Translations$auth$email$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get label => 'Email';
	@override String get placeholder => 'Enter your email';
	@override String get required => 'Email is required';
	@override String get invalid => 'Please enter a valid email address';
}

// Path: auth.password
class _Translations$auth$password$en extends Translations$auth$password$zh {
	_Translations$auth$password$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get label => 'Password';
	@override String get placeholder => 'Enter your password';
	@override String get required => 'Password is required';
	@override String get tooShort => 'Password must be at least 6 characters';
	@override String get mustContainNumbersAndLetters => 'Password must contain both numbers and letters';
	@override String get confirm => 'Confirm Password';
	@override String get confirmPlaceholder => 'Re-enter your password';
	@override String get mismatch => 'Passwords do not match';
}

// Path: auth.verificationCode
class _Translations$auth$verificationCode$en extends Translations$auth$verificationCode$zh {
	_Translations$auth$verificationCode$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get label => 'Verification Code';
	@override String get get => 'Get Code';
	@override String get sending => 'Sending...';
	@override String get sent => 'Code sent';
	@override String get sendFailed => 'Failed to send';
	@override String get placeholder => 'Optional for now, enter anything';
	@override String get required => 'Verification code is required';
}

// Path: calendar.weekdays
class _Translations$calendar$weekdays$en extends Translations$calendar$weekdays$zh {
	_Translations$calendar$weekdays$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get mon => 'M';
	@override String get tue => 'T';
	@override String get wed => 'W';
	@override String get thu => 'T';
	@override String get fri => 'F';
	@override String get sat => 'S';
	@override String get sun => 'S';
}

// Path: appearance.palettes
class _Translations$appearance$palettes$en extends Translations$appearance$palettes$zh {
	_Translations$appearance$palettes$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get zinc => 'Zinc';
	@override String get slate => 'Slate';
	@override String get red => 'Red';
	@override String get rose => 'Rose';
	@override String get orange => 'Orange';
	@override String get green => 'Green';
	@override String get blue => 'Blue';
	@override String get yellow => 'Yellow';
	@override String get violet => 'Violet';
}

// Path: forecast.recurringTransaction
class _Translations$forecast$recurringTransaction$en extends Translations$forecast$recurringTransaction$zh {
	_Translations$forecast$recurringTransaction$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Recurring Transactions';
	@override String get all => 'All';
	@override String get expense => 'Expense';
	@override String get income => 'Income';
	@override String get transfer => 'Transfer';
	@override String get noRecurring => 'No recurring transactions';
	@override String get createHint => 'The system will automatically generate transactions after you create recurring rules';
	@override String get create => 'Create Recurring Transaction';
	@override String get edit => 'Edit Recurring Transaction';
	@override String get newTransaction => 'New Recurring Transaction';
	@override String deleteConfirm({required Object name}) => 'Are you sure you want to delete recurring transaction "${name}"? This cannot be undone.';
	@override String activateConfirm({required Object name}) => 'Are you sure you want to activate recurring transaction "${name}"? It will automatically generate transactions.';
	@override String pauseConfirm({required Object name}) => 'Are you sure you want to pause recurring transaction "${name}"? No transactions will be generated while paused.';
	@override String get created => 'Recurring transaction created';
	@override String get updated => 'Recurring transaction updated';
	@override String get activated => 'Activated';
	@override String get paused => 'Paused';
	@override String get nextTime => 'Next';
	@override String get sortByTime => 'Sort by time';
	@override String get allPeriod => 'All recurring';
	@override String periodCount({required Object type, required Object count}) => '${type} recurring (${count})';
	@override String get confirmDelete => 'Confirm Delete';
	@override String get confirmActivate => 'Confirm Activate';
	@override String get confirmPause => 'Confirm Pause';
	@override String get dynamicAmount => 'Est. Avg';
	@override String get dynamicAmountTitle => 'Amount Requires Confirmation';
	@override String get dynamicAmountDescription => 'System will send a reminder on the due date. You need to manually confirm the amount before recording.';
	@override String get confirmBeforeGeneration => 'Confirm Before Generation';
	@override String get confirmBeforeGenerationDesc => 'Generates a pending transaction on due date, requires manual confirmation';
	@override String get pendingTitle => 'Pending Transactions';
	@override String pendingCount({required Object count}) => '${count} pending';
	@override String get confirm => 'Confirm';
	@override String get skip => 'Skip';
	@override String get noPending => 'No pending transactions';
	@override String get confirmSuccess => 'Transaction confirmed';
	@override String get skipSuccess => 'Transaction skipped';
	@override String get interval => 'Interval';
	@override String get selectDays => 'Select Days';
	@override String get alwaysLastDay => 'Always execute on last day';
	@override String get lastDayExecution => 'Will execute on the last day of each month';
	@override String dayExecution({required Object day, required Object suffix}) => 'Will execute on the ${day}${suffix} of each month (clamped for short months)';
	@override String get setEndDate => 'Set End Date';
	@override String get selectEndDate => 'Select End Date';
	@override String get preview => 'Preview';
	@override String get daily => 'Daily';
	@override String get weekly => 'Weekly';
	@override String get monthly => 'Monthly';
	@override String get yearly => 'Yearly';
	@override String get custom => 'Custom';
	@override String get cycle => 'Cycle';
	@override String everyDays({required Object count}) => 'Every ${count} days';
	@override String everyWeeks({required Object count}) => 'Every ${count} weeks';
	@override String everyMonths({required Object count}) => 'Every ${count} months';
	@override String everyYears({required Object count}) => 'Every ${count} years';
	@override String monthlyOnDay({required Object day, required Object suffix}) => 'Monthly on the ${day}${suffix}';
	@override String everyMonthsOnDay({required Object count, required Object day, required Object suffix}) => 'Every ${count} months on the ${day}${suffix}';
	@override String get monthlyLastDay => 'Monthly on the last day';
	@override String everyMonthsLastDay({required Object count}) => 'Every ${count} months on the last day';
	@override String yearlyOn({required Object month, required Object day}) => 'Yearly on ${month}/${day}';
	@override String everyYearsOn({required Object count, required Object month, required Object day}) => 'Every ${count} years on ${month}/${day}';
	@override String weeklyOnDay({required Object day}) => 'Weekly on ${day}';
	@override String get weekdayMon => 'Mon';
	@override String get weekdayTue => 'Tue';
	@override String get weekdayWed => 'Wed';
	@override String get weekdayThu => 'Thu';
	@override String get weekdayFri => 'Fri';
	@override String get weekdaySat => 'Sat';
	@override String get weekdaySun => 'Sun';
	@override String get weekdayOn => '';
	@override String get weekdayJoiner => ', ';
	@override String get weeklyDaysPrefix => ' on ';
	@override String get sourceAccount => 'Source Account';
	@override String get targetAccount => 'Target Account';
	@override String get expenseAccount => 'Expense Account';
	@override String get incomeAccount => 'Income Account';
	@override String get selectSourceAccount => 'Source';
	@override String get selectTargetAccount => 'Target';
	@override String get selectExpenseAccount => 'Expense';
	@override String get selectIncomeAccount => 'Income';
	@override String amountNotFixed({required Object type}) => 'Amount not fixed for each ${type}';
	@override String get selectBothAccounts => 'Please select source and target accounts';
	@override String get sameAccount => 'Source and target accounts must be different';
	@override String get endBeforeStart => 'End date cannot be earlier than start date';
	@override String selectAccountForType({required Object type}) => 'Please select ${type} account';
	@override String get deleteConfirmGeneric => 'Are you sure you want to delete this recurring transaction? This action cannot be undone.';
	@override String selectDate({required Object date}) => 'Select ${date}';
	@override String get accountTypeCash => 'Cash';
	@override String get accountTypeDeposit => 'Bank Deposit';
	@override String get accountTypeEMoney => 'E-Wallet';
	@override String get accountTypeInvestment => 'Investment';
	@override String get accountTypeReceivable => 'Accounts Receivable';
	@override String get accountTypeCreditCard => 'Credit Card';
	@override String get accountTypeLoan => 'Loan Account';
	@override String get accountTypePayable => 'Accounts Payable';
	@override String get assetAccount => 'Asset Account';
	@override String get liabilityAccount => 'Liability Account';
	@override String get noAssetAccounts => 'No asset accounts';
	@override String get goToFinanceToAddAccounts => 'Please go to the financial page to add accounts';
	@override String get selectAccount => 'Select Account';
	@override String get autoGenerateByRule => 'Automatically generate transactions by rule';
	@override String dayUnit({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(count,
		one: 'Day',
		other: 'Days',
	);
	@override String weekUnit({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(count,
		one: 'Week',
		other: 'Weeks',
	);
	@override String monthUnit({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(count,
		one: 'Month',
		other: 'Months',
	);
	@override String yearUnit({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(count,
		one: 'Year',
		other: 'Years',
	);
}

// Path: chat.tools
class _Translations$chat$tools$en extends Translations$chat$tools$zh {
	_Translations$chat$tools$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get processing => 'Processing...';
	@override String get readFile => 'Reading file...';
	@override String get searchTransactions => 'Searching transactions...';
	@override String get queryBudgetStatus => 'Checking budget...';
	@override String get createBudget => 'Creating budget plan...';
	@override String get getCashFlowAnalysis => 'Analyzing cash flow...';
	@override String get getFinancialHealthScore => 'Calculating financial health score...';
	@override String get getFinancialSummary => 'Generating financial report...';
	@override String get evaluateFinancialHealth => 'Evaluating financial health...';
	@override String get simulateExpenseImpact => 'Simulating purchase impact...';
	@override String get recordTransactions => 'Recording transactions...';
	@override String get createTransaction => 'Recording transaction...';
	@override String get duckduckgoSearch => 'Searching the web...';
	@override String get executeTransfer => 'Executing transfer...';
	@override String get listDir => 'Browsing directory...';
	@override String get execute => 'Processing...';
	@override String get analyzeSpending => 'Analyzing spendings...';
	@override String get analyzeCashflow => 'Analyzing cashflow...';
	@override String get forecastBalance => 'Forecasting balance...';
	@override String get suggestBudget => 'Suggesting budget...';
	@override String get listSpaces => 'Loading shared spaces...';
	@override String get querySpaceSummary => 'Querying space summary...';
	@override String get prepareTransfer => 'Preparing transfer...';
	@override String get unknown => 'Processing request...';
	@override late final _Translations$chat$tools$done$en done = _Translations$chat$tools$done$en._(_root);
	@override late final _Translations$chat$tools$failed$en failed = _Translations$chat$tools$failed$en._(_root);
	@override String get cancelled => 'Cancelled';
	@override String get analyzeFinance => '正在分析財務狀況...';
	@override String get forecastFinance => '正在預測財務趨勢...';
	@override String get analyzeBudget => '正在分析預算...';
	@override String get auditAnalysis => '正在審計分析...';
	@override String get budgetOps => '正在處理預算...';
	@override String get createSharedTransaction => '正在創建共享帳單...';
	@override String get prepareBudgetSimulation => 'Preparing budget simulation';
	@override String get simulateBudget => 'Simulating budget';
}

// Path: chat.transferWizard
class _Translations$chat$transferWizard$en extends Translations$chat$transferWizard$zh {
	_Translations$chat$transferWizard$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Transfer Wizard';
	@override String get amount => 'Transfer Amount';
	@override String get amountHint => 'Enter amount';
	@override String get sourceAccount => 'Source Account';
	@override String get targetAccount => 'Target Account';
	@override String get selectAccount => 'Select Account';
	@override String get autoGenerateByRule => 'Automatically generate transactions by rule';
	@override String get confirmTransfer => 'Confirm Transfer';
	@override String get confirmed => 'Confirmed';
	@override String get transferSuccess => 'Transfer Successful';
	@override String get selectReceiveAccount => '选择收款账户';
}

// Path: chat.genui
class _Translations$chat$genui$en extends Translations$chat$genui$zh {
	_Translations$chat$genui$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$chat$genui$expenseSummary$en expenseSummary = _Translations$chat$genui$expenseSummary$en._(_root);
	@override late final _Translations$chat$genui$transactionList$en transactionList = _Translations$chat$genui$transactionList$en._(_root);
	@override late final _Translations$chat$genui$transactionGroupReceipt$en transactionGroupReceipt = _Translations$chat$genui$transactionGroupReceipt$en._(_root);
	@override late final _Translations$chat$genui$budgetReceipt$en budgetReceipt = _Translations$chat$genui$budgetReceipt$en._(_root);
	@override late final _Translations$chat$genui$budgetStatusCard$en budgetStatusCard = _Translations$chat$genui$budgetStatusCard$en._(_root);
	@override late final _Translations$chat$genui$cashFlowForecast$en cashFlowForecast = _Translations$chat$genui$cashFlowForecast$en._(_root);
	@override late final _Translations$chat$genui$healthScore$en healthScore = _Translations$chat$genui$healthScore$en._(_root);
	@override late final _Translations$chat$genui$spaceSelector$en spaceSelector = _Translations$chat$genui$spaceSelector$en._(_root);
	@override late final _Translations$chat$genui$transferPath$en transferPath = _Translations$chat$genui$transferPath$en._(_root);
	@override late final _Translations$chat$genui$transactionCard$en transactionCard = _Translations$chat$genui$transactionCard$en._(_root);
	@override late final _Translations$chat$genui$cashFlowCard$en cashFlowCard = _Translations$chat$genui$cashFlowCard$en._(_root);
	@override late final _Translations$chat$genui$transactionConfirmation$en transactionConfirmation = _Translations$chat$genui$transactionConfirmation$en._(_root);
	@override late final _Translations$chat$genui$budgetAnalysis$en budgetAnalysis = _Translations$chat$genui$budgetAnalysis$en._(_root);
	@override late final _Translations$chat$genui$budgetSimulator$en budgetSimulator = _Translations$chat$genui$budgetSimulator$en._(_root);
	@override late final _Translations$chat$genui$error$en error = _Translations$chat$genui$error$en._(_root);
}

// Path: chat.welcome
class _Translations$chat$welcome$en extends Translations$chat$welcome$zh {
	_Translations$chat$welcome$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override late final _Translations$chat$welcome$morning$en morning = _Translations$chat$welcome$morning$en._(_root);
	@override late final _Translations$chat$welcome$midday$en midday = _Translations$chat$welcome$midday$en._(_root);
	@override late final _Translations$chat$welcome$afternoon$en afternoon = _Translations$chat$welcome$afternoon$en._(_root);
	@override late final _Translations$chat$welcome$evening$en evening = _Translations$chat$welcome$evening$en._(_root);
	@override late final _Translations$chat$welcome$night$en night = _Translations$chat$welcome$night$en._(_root);
}

// Path: error.genui
class _Translations$error$genui$en extends Translations$error$genui$zh {
	_Translations$error$genui$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get loadingFailed => 'Component loading failed';
	@override String get schemaFailed => 'Schema validation failed';
	@override String get schemaDescription => 'Component definition does not comply with GenUI specifications, degraded to plain text display';
	@override String get networkError => 'Network error';
	@override String retryStatus({required Object retryCount, required Object maxRetries}) => 'Retried ${retryCount}/${maxRetries} times';
	@override String get maxRetriesReached => 'Maximum retry attempts reached';
}

// Path: account.types
class _Translations$account$types$en extends Translations$account$types$zh {
	_Translations$account$types$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get cashTitle => 'Cash';
	@override String get cashSubtitle => 'Physical currency and coins';
	@override String get depositTitle => 'Bank Deposit';
	@override String get depositSubtitle => 'Savings, checking accounts';
	@override String get eMoneyTitle => 'E-Wallet';
	@override String get eMoneySubtitle => 'Digital payment balances';
	@override String get investmentTitle => 'Investment';
	@override String get investmentSubtitle => 'Stocks, funds, bonds, etc.';
	@override String get receivableTitle => 'Receivable';
	@override String get receivableSubtitle => 'Loans to others, pending';
	@override String get receivableHelper => 'Owed to me';
	@override String get creditCardTitle => 'Credit Card';
	@override String get creditCardSubtitle => 'Credit card balances';
	@override String get loanTitle => 'Loan';
	@override String get loanSubtitle => 'Mortgage, auto, personal';
	@override String get payableTitle => 'Payable';
	@override String get payableSubtitle => 'Amounts owed to others';
	@override String get payableHelper => 'I owe';
}

// Path: statistics.overview
class _Translations$statistics$overview$en extends Translations$statistics$overview$zh {
	_Translations$statistics$overview$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get balance => 'Total Balance';
	@override String get income => 'Total Income';
	@override String get expense => 'Total Expense';
}

// Path: statistics.trend
class _Translations$statistics$trend$en extends Translations$statistics$trend$zh {
	_Translations$statistics$trend$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Trends';
	@override String get expense => 'Expense';
	@override String get income => 'Income';
}

// Path: statistics.analysis
class _Translations$statistics$analysis$en extends Translations$statistics$analysis$zh {
	_Translations$statistics$analysis$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Expense Analysis';
	@override String get expenseTitle => 'Expense Analysis';
	@override String get incomeTitle => 'Income Analysis';
	@override String get total => 'Total';
	@override String get breakdown => 'Expense Breakdown';
	@override String get radarNeedMoreData => 'Radar chart requires at least 3 categories';
}

// Path: statistics.filter
class _Translations$statistics$filter$en extends Translations$statistics$filter$zh {
	_Translations$statistics$filter$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get accountType => 'Account Type';
	@override String get allAccounts => 'All Accounts';
	@override String get apply => 'Apply';
}

// Path: statistics.sort
class _Translations$statistics$sort$en extends Translations$statistics$sort$zh {
	_Translations$statistics$sort$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get amount => 'By Amount';
	@override String get date => 'By Time';
}

// Path: statistics.emptyState
class _Translations$statistics$emptyState$en extends Translations$statistics$emptyState$zh {
	_Translations$statistics$emptyState$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Unlock Financial Insights';
	@override String get description => 'Your financial report is currently a blank canvas.\nRecord your first transaction and let the data tell your story.';
	@override String get action => 'Record First Transaction';
}

// Path: server.error
class _Translations$server$error$en extends Translations$server$error$zh {
	_Translations$server$error$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get urlRequired => 'Server address is required';
	@override String get invalidUrl => 'Invalid URL format';
	@override String get connectionTimeout => 'Connection timed out';
	@override String get connectionRefused => 'Could not connect to server';
	@override String get sslError => 'SSL certificate error';
	@override String get serverError => 'Server error';
}

// Path: sharedSpace.dashboard
class _Translations$sharedSpace$dashboard$en extends Translations$sharedSpace$dashboard$zh {
	_Translations$sharedSpace$dashboard$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get sectionTitle => 'Financial Overview';
	@override String get cumulativeTotalExpense => 'Cumulative Total Expense';
	@override String get participatingMembers => 'Participating Members';
	@override String membersCount({required Object count}) => '${count} people';
	@override String get averagePerMember => 'Avg per member';
	@override String get spendingDistribution => 'Spending Distribution';
	@override String get realtimeUpdates => 'Real-time updates';
	@override String get paid => 'Paid';
}

// Path: sharedSpace.roles
class _Translations$sharedSpace$roles$en extends Translations$sharedSpace$roles$zh {
	_Translations$sharedSpace$roles$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get owner => 'Owner';
	@override String get admin => 'Admin';
	@override String get member => 'Member';
}

// Path: sharedSpace.create
class _Translations$sharedSpace$create$en extends Translations$sharedSpace$create$zh {
	_Translations$sharedSpace$create$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Create Shared Space';
	@override String get subtitle => 'Create a shared space to view and analyze shared finances';
	@override String get nameLabel => 'Space Name';
	@override String get nameHint => 'e.g., Graduation Trip';
	@override String get descLabel => 'Description (Optional)';
	@override String get descHint => 'Track our joint travel expenses';
	@override String get cancel => 'Cancel';
	@override String get submit => 'Create';
	@override String get nameRequired => 'Please enter a space name';
	@override String get nameTooShort => 'Space name must be at least 2 characters';
	@override String get nameTooLong => 'Space name cannot exceed 50 characters';
}

// Path: sharedSpace.join
class _Translations$sharedSpace$join$en extends Translations$sharedSpace$join$zh {
	_Translations$sharedSpace$join$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Join Shared Space';
	@override String get subtitle => 'Enter the invite code to view and analyze shared finances';
	@override String get codeHint => 'Enter your 6-digit invite code';
	@override String get cancel => 'Cancel';
	@override String get submit => 'Join';
	@override String get codeRequired => 'Please enter invite code';
	@override String get codeInvalid => 'Please enter a 6-digit invite code';
}

// Path: sharedSpace.list
class _Translations$sharedSpace$list$en extends Translations$sharedSpace$list$zh {
	_Translations$sharedSpace$list$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get emptyTitle => 'Shared finances, clear at a glance';
	@override String get emptySubtitle => 'Create or join a space to view, analyze, and summarize shared finances with family and friends';
	@override String get getStarted => 'Get Started';
	@override String get hasInviteCode => 'Have an invite code? Tap to join';
	@override String joinedSuccess({required Object name}) => 'Successfully joined "${name}"!';
}

// Path: sharedSpace.detail
class _Translations$sharedSpace$detail$en extends Translations$sharedSpace$detail$zh {
	_Translations$sharedSpace$detail$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get members => 'Members';
	@override String get transactions => 'Transactions';
	@override String recordsCount({required Object count}) => '${count} records';
	@override String get settlement => 'Settlement';
	@override String get inviteCode => 'Invite Code';
	@override String get copyCode => 'Copy Invite Code';
	@override String codeCopied({required Object code}) => 'Invite code copied: ${code}';
	@override String get validFor24h => 'Valid for 24 hours';
	@override String get leaveSpace => 'Leave Space';
	@override String get deleteSpace => 'Delete Space';
	@override String get removeMember => 'Remove Member';
	@override String get leaveConfirm => 'Are you sure you want to leave this shared space? You will no longer have access to its transactions.';
	@override String get deleteConfirm => 'Are you sure you want to delete this shared space? This action cannot be undone and all members will be removed.';
	@override String get removeConfirm => 'Are you sure you want to remove this member from the shared space?';
	@override String get generatingCode => 'Generating invite code...';
	@override String get loadFailed => 'Failed to load';
	@override String get retry => 'Retry';
	@override String get noTransactions => 'No transactions yet';
	@override String get noTransactionsHint => 'Transactions in this space will appear here';
	@override String get refreshCode => 'Refresh Code';
	@override String get noMoreTransactions => 'No more transactions';
}

// Path: sharedSpace.notifications
class _Translations$sharedSpace$notifications$en extends Translations$sharedSpace$notifications$zh {
	_Translations$sharedSpace$notifications$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Notifications';
	@override String get empty => 'No notifications';
	@override String get emptyHint => 'When you have new invites or activities,\nyou will receive notifications here';
	@override String get incompleteInfo => 'Incomplete invite info';
	@override String get inviteAccepted => 'Invite accepted!';
	@override String get inviteRejected => 'Invite rejected';
	@override String get allMarkedRead => 'All notifications marked as read';
}

// Path: sharedSpace.inviteCard
class _Translations$sharedSpace$inviteCard$en extends Translations$sharedSpace$inviteCard$zh {
	_Translations$sharedSpace$inviteCard$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Invite Code';
	@override String get copyCode => 'Copy Invite Code';
	@override String get shareLink => 'Share Invite Link';
	@override String get codeCopied => 'Invite code copied';
	@override String get noExpiry => 'No expiry';
	@override String get expired => 'Expired';
	@override String expiresInDays({required Object days}) => 'Expires in ${days} days';
	@override String expiresInHours({required Object hours}) => 'Expires in ${hours} hours';
	@override String expiresInMinutes({required Object minutes}) => 'Expires in ${minutes} minutes';
	@override String get expiringSoon => 'Expiring soon';
	@override String shareText({required Object spaceName, required Object code, required Object link, required Object expiry}) => 'You are invited to join the shared space "${spaceName}"\n\nInvite code: ${code}\nOr click the link to join directly: ${link}\n\nInvite code ${expiry}';
}

// Path: sharedSpace.inviteSuccess
class _Translations$sharedSpace$inviteSuccess$en extends Translations$sharedSpace$inviteSuccess$zh {
	_Translations$sharedSpace$inviteSuccess$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Created Successfully';
	@override String get subtitle => 'Space Created Successfully';
	@override String get inviteLater => 'Invite Later';
	@override String get enterSpace => 'Enter Space';
	@override String get generatingCode => 'Generating invite code...';
	@override String get generateFailed => 'Failed to generate invite code';
	@override String get codeCopied => 'Invite code copied';
	@override String get retry => 'Retry';
	@override String get codeLabel => 'Invite Code';
	@override String get validHint => 'Valid for 24 hours · Tap to copy';
}

// Path: sharedSpace.notificationCard
class _Translations$sharedSpace$notificationCard$en extends Translations$sharedSpace$notificationCard$zh {
	_Translations$sharedSpace$notificationCard$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get accept => 'Accept';
	@override String get reject => 'Reject';
	@override String get unknownTime => 'Unknown time';
	@override String get justNow => 'Just now';
}

// Path: sharedSpace.spaceCard
class _Translations$sharedSpace$spaceCard$en extends Translations$sharedSpace$spaceCard$zh {
	_Translations$sharedSpace$spaceCard$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get noDescription => 'No description';
	@override String get creator => 'Creator';
	@override String get member => 'Member';
	@override String membersCount({required Object count}) => '${count} members';
	@override String transactionsCount({required Object count}) => '${count} transactions';
}

// Path: sharedSpace.settings
class _Translations$sharedSpace$settings$en extends Translations$sharedSpace$settings$zh {
	_Translations$sharedSpace$settings$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Space Settings';
	@override String get spaceInfo => 'Space Info';
	@override String get nameLabel => 'Space Name';
	@override String get descLabel => 'Space Description';
	@override String get save => 'Save';
	@override String get saved => 'Saved successfully';
	@override String get saveFailed => 'Failed to save';
	@override String get memberManagement => 'Member Management';
	@override String membersCount({required Object count}) => '${count} members';
	@override String removeMemberConfirm({required Object name}) => 'Are you sure you want to remove "${name}" from this space?';
	@override String get removed => 'Member removed';
	@override String get removeFailed => 'Failed to remove member';
	@override String get inviteManagement => 'Invite Management';
	@override String get currentCode => 'Current Invite Code';
	@override String get generateNew => 'Generate New Code';
	@override String get noValidCode => 'No valid invite code';
	@override String get refreshCode => 'Refresh Code';
	@override String get refreshConfirm => 'Generating a new code will invalidate the old one. Continue?';
	@override String get codeRefreshed => 'Invite code refreshed';
	@override String get dangerZone => 'Danger Zone';
	@override String get editHint => 'Only admins can edit';
	@override String get edit => 'Edit';
	@override String get you => 'You';
	@override String get pending => 'Pending';
	@override String get declined => 'Declined';
	@override String get setAsAdmin => 'Set as Admin';
	@override String get setAsMember => 'Set as Member';
	@override String get changeRole => 'Change Role';
	@override String changeRoleConfirm({required Object name, required Object role}) => 'Are you sure you want to change "${name}"\'s role to "${role}"?';
	@override String get confirm => 'Confirm';
	@override String get roleChanged => 'Role changed';
	@override String get roleChangeFailed => 'Failed to change role';
}

// Path: errorMapping.generic
class _Translations$errorMapping$generic$en extends Translations$errorMapping$generic$zh {
	_Translations$errorMapping$generic$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get badRequest => 'Bad Request';
	@override String get authFailed => 'Authentication failed, please login again';
	@override String get permissionDenied => 'Permission denied';
	@override String get notFound => 'Resource not found';
	@override String get serverError => 'Internal server error';
	@override String get systemError => 'System error';
	@override String get validationFailed => 'Validation failed';
}

// Path: errorMapping.auth
class _Translations$errorMapping$auth$en extends Translations$errorMapping$auth$zh {
	_Translations$errorMapping$auth$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get failed => 'Authentication failed';
	@override String get emailWrong => 'Incorrect email';
	@override String get phoneWrong => 'Incorrect phone number';
	@override String get phoneRegistered => 'Phone number already registered';
	@override String get emailRegistered => 'Email already registered';
	@override String get sendFailed => 'Failed to send verification code';
	@override String get expired => 'Verification code expired';
	@override String get tooFrequent => 'Code sent too frequently';
	@override String get unsupportedType => 'Unsupported code type';
	@override String get wrongPassword => 'Incorrect password';
	@override String get userNotFound => 'User not found';
	@override String get prefsMissing => 'Preference parameters missing';
	@override String get invalidTimezone => 'Invalid client timezone';
}

// Path: errorMapping.transaction
class _Translations$errorMapping$transaction$en extends Translations$errorMapping$transaction$zh {
	_Translations$errorMapping$transaction$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get commentEmpty => 'Comment content cannot be empty';
	@override String get invalidParent => 'Invalid parent comment ID';
	@override String get saveFailed => 'Failed to save comment';
	@override String get deleteFailed => 'Failed to delete comment';
	@override String get notExists => 'Transaction does not exist';
}

// Path: errorMapping.space
class _Translations$errorMapping$space$en extends Translations$errorMapping$space$zh {
	_Translations$errorMapping$space$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get notFound => 'Shared space not found or access denied';
	@override String get inviteDenied => 'No permission to invite members';
	@override String get inviteSelf => 'Cannot invite yourself';
	@override String get inviteSent => 'Invitation sent';
	@override String get alreadyMember => 'User is already a member or invited';
	@override String get invalidAction => 'Invalid action';
	@override String get invitationNotFound => 'Invitation does not exist';
	@override String get onlyOwner => 'Only owner can perform this action';
	@override String get ownerNotRemovable => 'Owner cannot be removed';
	@override String get memberNotFound => 'Member not found';
	@override String get notMember => 'User is not a member of this space';
	@override String get ownerCantLeave => 'Owner cannot leave directly, please transfer ownership first';
	@override String get invalidCode => 'Invalid invitation code';
	@override String get codeExpired => 'Invitation code expired or usage limit reached';
	@override String get transactionAlreadyInSpace => 'Transaction already in this space';
}

// Path: errorMapping.recurring
class _Translations$errorMapping$recurring$en extends Translations$errorMapping$recurring$zh {
	_Translations$errorMapping$recurring$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get invalidRule => 'Invalid recurrence rule';
	@override String get ruleNotFound => 'Recurrence rule not found';
}

// Path: errorMapping.upload
class _Translations$errorMapping$upload$en extends Translations$errorMapping$upload$zh {
	_Translations$errorMapping$upload$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get noFile => 'No file uploaded';
	@override String get tooLarge => 'File too large';
	@override String get unsupportedType => 'Unsupported file type';
	@override String get tooManyFiles => 'Too many files';
}

// Path: errorMapping.storage
class _Translations$errorMapping$storage$en extends Translations$errorMapping$storage$zh {
	_Translations$errorMapping$storage$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get configNotFound => 'Storage config not found or access denied';
	@override String get configInUse => 'Cannot delete: storage config is still in use by attachments';
	@override String get invalidProviderType => 'Invalid storage provider type';
}

// Path: errorMapping.ai
class _Translations$errorMapping$ai$en extends Translations$errorMapping$ai$zh {
	_Translations$errorMapping$ai$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get contextLimit => 'Context limit exceeded';
	@override String get tokenLimit => 'Insufficient tokens';
	@override String get emptyMessage => 'Empty user message';
}

// Path: notification.types
class _Translations$notification$types$en extends Translations$notification$types$zh {
	_Translations$notification$types$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get system => 'System';
	@override String get spaceInvite => 'Space Invite';
	@override String get spaceActivity => 'Space Activity';
	@override String get billComment => 'Bill Comment';
	@override String get budgetAlert => 'Budget Alert';
	@override String get transaction => 'Transaction';
}

// Path: notification.semantic
class _Translations$notification$semantic$en extends Translations$notification$semantic$zh {
	_Translations$notification$semantic$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String memberJoined({required Object name}) => '${name} joined your space';
	@override String memberJoinedDetail({required Object space}) => 'A new member joined "${space}"';
	@override String welcome({required Object space}) => 'Welcome to "${space}"';
	@override String newTransaction({required Object name}) => '${name} recorded a new expense';
	@override String newTransactionDetail({required Object amount, required Object space}) => '${amount} in "${space}"';
	@override String memberLeft({required Object name}) => '${name} left the space';
	@override String get recurringPending => 'Recurring transaction pending';
	@override String recurringPendingDetail({required Object description, required Object amount}) => '${description} ${amount}, awaiting your confirmation';
}

// Path: chat.tools.done
class _Translations$chat$tools$done$en extends Translations$chat$tools$done$zh {
	_Translations$chat$tools$done$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get readFile => 'Read file';
	@override String get searchTransactions => 'Searched transactions';
	@override String get queryBudgetStatus => 'Checked budget';
	@override String get createBudget => 'Created budget';
	@override String get getCashFlowAnalysis => 'Analyzed cash flow';
	@override String get getFinancialHealthScore => 'Calculated health score';
	@override String get getFinancialSummary => 'Financial report ready';
	@override String get evaluateFinancialHealth => 'Health evaluation complete';
	@override String get forecastBalance => 'Balance forecast ready';
	@override String get simulateExpenseImpact => 'Impact simulation complete';
	@override String get recordTransactions => 'Recorded transactions';
	@override String get createTransaction => 'Recorded transaction';
	@override String get duckduckgoSearch => 'Searched the web';
	@override String get executeTransfer => 'Transfer complete';
	@override String get listDir => 'Browsed directory';
	@override String get execute => 'Processing complete';
	@override String get analyzeSpending => 'Spending analysis complete';
	@override String get analyzeCashflow => 'Cashflow analysis complete';
	@override String get suggestBudget => 'Budget suggestion complete';
	@override String get listSpaces => 'Shared spaces loaded';
	@override String get querySpaceSummary => 'Space summary ready';
	@override String get prepareTransfer => 'Transfer ready';
	@override String get unknown => 'Processing complete';
	@override String get analyzeFinance => '財務分析完成';
	@override String get forecastFinance => '財務預測完成';
	@override String get analyzeBudget => '預算分析完成';
	@override String get auditAnalysis => '審計分析完成';
	@override String get budgetOps => '預算處理完成';
	@override String get createSharedTransaction => '共享帳單創建完成';
	@override String get prepareBudgetSimulation => 'Budget simulation prepared';
	@override String get simulateBudget => 'Budget simulation completed';
}

// Path: chat.tools.failed
class _Translations$chat$tools$failed$en extends Translations$chat$tools$failed$zh {
	_Translations$chat$tools$failed$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get unknown => 'Action failed';
}

// Path: chat.genui.expenseSummary
class _Translations$chat$genui$expenseSummary$en extends Translations$chat$genui$expenseSummary$zh {
	_Translations$chat$genui$expenseSummary$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get totalExpense => 'Total Expense';
	@override String get mainExpenses => 'Main Expenses';
	@override String viewAll({required Object count}) => 'View all ${count} transactions';
	@override String get details => 'Transaction Details';
}

// Path: chat.genui.transactionList
class _Translations$chat$genui$transactionList$en extends Translations$chat$genui$transactionList$zh {
	_Translations$chat$genui$transactionList$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String searchResults({required Object count}) => 'Search Results (${count})';
	@override String loaded({required Object count}) => 'Loaded ${count}';
	@override String get noResults => 'No transactions found';
	@override String get loadMore => 'Scroll to load more';
	@override String get allLoaded => 'All loaded';
}

// Path: chat.genui.transactionGroupReceipt
class _Translations$chat$genui$transactionGroupReceipt$en extends Translations$chat$genui$transactionGroupReceipt$zh {
	_Translations$chat$genui$transactionGroupReceipt$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Successfully';
	@override String count({required Object count}) => '${count} items';
	@override String get total => 'Total';
	@override String get selectAccount => 'Select Account';
	@override String get autoGenerateByRule => 'Automatically generate transactions by rule';
	@override String get selectAccountSubtitle => 'This account will be applied to all transactions above';
	@override String associatedAccount({required Object name}) => 'Associated: ${name}';
	@override String get clickToAssociate => 'Click to associate account';
	@override String get associateSuccess => 'Successfully associated account to all transactions';
	@override String associateFailed({required Object error}) => 'Action failed: ${error}';
	@override String get accountAssociation => 'Account';
	@override String get sharedSpace => 'Shared Space';
	@override String get notAssociated => 'Not linked';
	@override String get addSpace => 'Add';
	@override String get selectSpace => 'Select Shared Space';
	@override String get spaceAssociateSuccess => 'Linked to shared space';
	@override String spaceAssociateFailed({required Object error}) => 'Failed to link: ${error}';
	@override String get currencyMismatchTitle => 'Currency Mismatch';
	@override String get currencyMismatchDesc => 'The transaction currency differs from the account currency. The account balance will be deducted at the exchange rate.';
	@override String get transactionAmount => 'Transaction Amount';
	@override String get accountCurrency => 'Account Currency';
	@override String get targetAccount => 'Target Account';
	@override String get currencyMismatchNote => 'Note: Account balance will be converted using current exchange rate';
	@override String get confirmAssociate => 'Confirm';
	@override String spaceCount({required Object count}) => '${count} spaces';
}

// Path: chat.genui.budgetReceipt
class _Translations$chat$genui$budgetReceipt$en extends Translations$chat$genui$budgetReceipt$zh {
	_Translations$chat$genui$budgetReceipt$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get newBudget => 'New Budget';
	@override String get budgetCreated => 'Budget Created';
	@override String get rolloverBudget => 'Rollover Budget';
	@override String get createFailed => 'Failed to create budget';
	@override String get thisMonth => 'This Month';
	@override String dateRange({required Object start, required Object startDay, required Object end, required Object endDay}) => '${start}/${startDay} - ${end}/${endDay}';
}

// Path: chat.genui.budgetStatusCard
class _Translations$chat$genui$budgetStatusCard$en extends Translations$chat$genui$budgetStatusCard$zh {
	_Translations$chat$genui$budgetStatusCard$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get budget => 'Budget';
	@override String get overview => 'Budget Overview';
	@override String get totalBudget => 'Total Budget';
	@override String spent({required Object amount}) => 'Used ¥${amount}';
	@override String remaining({required Object amount}) => 'Remaining ¥${amount}';
	@override String get exceeded => 'Exceeded';
	@override String get warning => 'Warning';
	@override String get plentiful => 'Healthy';
	@override String get normal => 'Normal';
}

// Path: chat.genui.cashFlowForecast
class _Translations$chat$genui$cashFlowForecast$en extends Translations$chat$genui$cashFlowForecast$zh {
	_Translations$chat$genui$cashFlowForecast$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Cash Flow Forecast';
	@override String get recurringTransaction => 'Recurring Transaction';
	@override String get recurringIncome => 'Recurring Income';
	@override String get recurringExpense => 'Recurring Expense';
	@override String get recurringTransfer => 'Recurring Transfer';
	@override String nextDays({required Object days}) => 'Next ${days} days';
	@override String get noData => 'No forecast data';
	@override String get summary => 'Forecast Summary';
	@override String get variableExpense => 'Predicted Variable Expense';
	@override String get netChange => 'Est. Net Change';
	@override String get keyEvents => 'Key Events';
	@override String get noSignificantEvents => 'No significant events in forecast period';
	@override String get dateFormat => 'M/d';
}

// Path: chat.genui.healthScore
class _Translations$chat$genui$healthScore$en extends Translations$chat$genui$healthScore$zh {
	_Translations$chat$genui$healthScore$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Financial Health';
	@override String get suggestions => 'Suggestions';
	@override String scorePoint({required Object score}) => '${score} pts';
	@override late final _Translations$chat$genui$healthScore$status$en status = _Translations$chat$genui$healthScore$status$en._(_root);
}

// Path: chat.genui.spaceSelector
class _Translations$chat$genui$spaceSelector$en extends Translations$chat$genui$spaceSelector$zh {
	_Translations$chat$genui$spaceSelector$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get selected => 'Selected';
	@override String get unnamedSpace => 'Unnamed Space';
	@override String get linked => 'Linked';
	@override String get roleOwner => 'Owner';
	@override String get roleAdmin => 'Admin';
	@override String get roleMember => 'Member';
	@override String get associateAction => 'Associate selected space';
}

// Path: chat.genui.transferPath
class _Translations$chat$genui$transferPath$en extends Translations$chat$genui$transferPath$zh {
	_Translations$chat$genui$transferPath$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get selectSource => 'Select Source Account';
	@override String get selectTarget => 'Select Target Account';
	@override String get from => 'From (Source)';
	@override String get to => 'To (Target)';
	@override String get select => 'Select';
	@override String get cancelled => 'Operation Cancelled';
	@override String get loadError => 'Failed to load account data';
	@override String get historyMissing => 'Account info missing in history';
	@override String get amountUnconfirmed => 'Amount Unconfirmed';
	@override String confirmedWithArrow({required Object source, required Object target}) => 'Confirmed: ${source} → ${target}';
	@override String confirmAction({required Object source, required Object target}) => 'Confirm: ${source} → ${target}';
	@override String get pleaseSelectSource => 'Please select source account';
	@override String get pleaseSelectTarget => 'Please select target account';
	@override String get confirmLinks => 'Confirm Transfer Path';
	@override String get linkLocked => 'Path Locked';
	@override String get clickToConfirm => 'Click button below to confirm';
	@override String get reselect => 'Reselect';
	@override String get title => 'Transfer';
	@override String get history => 'History';
	@override String get unknownAccount => 'Unknown Account';
	@override String get confirmed => 'Confirmed';
	@override String get executeAction => 'Execute transfer according to my selection';
}

// Path: chat.genui.transactionCard
class _Translations$chat$genui$transactionCard$en extends Translations$chat$genui$transactionCard$zh {
	_Translations$chat$genui$transactionCard$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Transaction Successful';
	@override String get associatedAccount => 'Associated Account';
	@override String get notCounted => 'Not counted';
	@override String get modify => 'Modify';
	@override String get associate => 'Associate Account';
	@override String get selectAccount => 'Select Account';
	@override String get autoGenerateByRule => 'Automatically generate transactions by rule';
	@override String get noAccount => 'No accounts available, please add one first';
	@override String get missingId => 'Transaction ID missing, cannot update';
	@override String associatedTo({required Object name}) => 'Associated to ${name}';
	@override String updateFailed({required Object error}) => 'Update failed: ${error}';
	@override String get sharedSpace => 'Shared Space';
	@override String get noSpace => 'No shared spaces available';
	@override String get selectSpace => 'Select Shared Space';
	@override String get linkedToSpace => 'Linked to shared space';
}

// Path: chat.genui.cashFlowCard
class _Translations$chat$genui$cashFlowCard$en extends Translations$chat$genui$cashFlowCard$zh {
	_Translations$chat$genui$cashFlowCard$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Cash Flow Analysis';
	@override String savingsRate({required Object rate}) => 'Savings ${rate}%';
	@override String get totalIncome => 'Total Income';
	@override String get totalExpense => 'Total Expense';
	@override String get essentialExpense => 'Essential';
	@override String get discretionaryExpense => 'Discretionary';
	@override String get aiInsight => 'AI Insight';
}

// Path: chat.genui.transactionConfirmation
class _Translations$chat$genui$transactionConfirmation$en extends Translations$chat$genui$transactionConfirmation$zh {
	_Translations$chat$genui$transactionConfirmation$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get multipleAccounts => '检测到多个关联账户';
	@override String get confirmed => '已确认';
}

// Path: chat.genui.budgetAnalysis
class _Translations$chat$genui$budgetAnalysis$en extends Translations$chat$genui$budgetAnalysis$zh {
	_Translations$chat$genui$budgetAnalysis$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => '预算分析报告';
	@override String periodDays({required Object days}) => '过去 ${days} 天';
	@override String get totalExpense => '总支出';
	@override String momChange({required Object change}) => '环比 ${change}%';
	@override String get categoryDistribution => '分类占比';
	@override String get topSpenders => '大额支出';
	@override String amountWan({required Object amount}) => '${amount}万';
}

// Path: chat.genui.budgetSimulator
class _Translations$chat$genui$budgetSimulator$en extends Translations$chat$genui$budgetSimulator$zh {
	_Translations$chat$genui$budgetSimulator$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => '預算壓力模擬器';
	@override String get targetAmount => '目標預算金額';
	@override String get overspendProbability => '預計超支機率';
	@override String get riskLow => '風險極低';
	@override String get riskMedium => '風險適中';
	@override String get riskHigh => '超支高危';
	@override String get evaluating => '正在評估歷史消費習慣...';
	@override String get historyAverage => '歷史月均';
	@override String get dailyAllowance => '每日限額';
	@override String get cancel => '放棄';
	@override String get confirm => '採用此預算';
}

// Path: chat.genui.error
class _Translations$chat$genui$error$en extends Translations$chat$genui$error$zh {
	_Translations$chat$genui$error$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Rendering failed';
	@override String get fetchFailed => 'Failed to load, please retry later.';
	@override String get dataIncomplete => 'Incomplete data';
}

// Path: chat.welcome.morning
class _Translations$chat$welcome$morning$en extends Translations$chat$welcome$morning$zh {
	_Translations$chat$welcome$morning$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get subtitle => 'Start your day by tracking';
	@override late final _Translations$chat$welcome$morning$breakfast$en breakfast = _Translations$chat$welcome$morning$breakfast$en._(_root);
	@override late final _Translations$chat$welcome$morning$yesterdayReview$en yesterdayReview = _Translations$chat$welcome$morning$yesterdayReview$en._(_root);
	@override late final _Translations$chat$welcome$morning$todayBudget$en todayBudget = _Translations$chat$welcome$morning$todayBudget$en._(_root);
}

// Path: chat.welcome.midday
class _Translations$chat$welcome$midday$en extends Translations$chat$welcome$midday$zh {
	_Translations$chat$welcome$midday$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get greeting => 'Good Afternoon';
	@override String get subtitle => 'Quick record during lunch';
	@override late final _Translations$chat$welcome$midday$lunch$en lunch = _Translations$chat$welcome$midday$lunch$en._(_root);
	@override late final _Translations$chat$welcome$midday$weeklyExpense$en weeklyExpense = _Translations$chat$welcome$midday$weeklyExpense$en._(_root);
	@override late final _Translations$chat$welcome$midday$checkBalance$en checkBalance = _Translations$chat$welcome$midday$checkBalance$en._(_root);
}

// Path: chat.welcome.afternoon
class _Translations$chat$welcome$afternoon$en extends Translations$chat$welcome$afternoon$zh {
	_Translations$chat$welcome$afternoon$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get subtitle => 'Tea time, let\'s review finances';
	@override late final _Translations$chat$welcome$afternoon$quickRecord$en quickRecord = _Translations$chat$welcome$afternoon$quickRecord$en._(_root);
	@override late final _Translations$chat$welcome$afternoon$analyzeSpending$en analyzeSpending = _Translations$chat$welcome$afternoon$analyzeSpending$en._(_root);
	@override late final _Translations$chat$welcome$afternoon$budgetProgress$en budgetProgress = _Translations$chat$welcome$afternoon$budgetProgress$en._(_root);
}

// Path: chat.welcome.evening
class _Translations$chat$welcome$evening$en extends Translations$chat$welcome$evening$zh {
	_Translations$chat$welcome$evening$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get subtitle => 'End of day, time to balance the books';
	@override late final _Translations$chat$welcome$evening$dinner$en dinner = _Translations$chat$welcome$evening$dinner$en._(_root);
	@override late final _Translations$chat$welcome$evening$todaySummary$en todaySummary = _Translations$chat$welcome$evening$todaySummary$en._(_root);
	@override late final _Translations$chat$welcome$evening$tomorrowPlan$en tomorrowPlan = _Translations$chat$welcome$evening$tomorrowPlan$en._(_root);
}

// Path: chat.welcome.night
class _Translations$chat$welcome$night$en extends Translations$chat$welcome$night$zh {
	_Translations$chat$welcome$night$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get greeting => 'Late Night';
	@override String get subtitle => 'Quiet time for financial planning';
	@override late final _Translations$chat$welcome$night$makeupRecord$en makeupRecord = _Translations$chat$welcome$night$makeupRecord$en._(_root);
	@override late final _Translations$chat$welcome$night$monthlyReview$en monthlyReview = _Translations$chat$welcome$night$monthlyReview$en._(_root);
	@override late final _Translations$chat$welcome$night$financialThinking$en financialThinking = _Translations$chat$welcome$night$financialThinking$en._(_root);
}

// Path: chat.genui.healthScore.status
class _Translations$chat$genui$healthScore$status$en extends Translations$chat$genui$healthScore$status$zh {
	_Translations$chat$genui$healthScore$status$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get excellent => 'Excellent';
	@override String get good => 'Good';
	@override String get fair => 'Fair';
	@override String get needsImprovement => 'Needs Improvement';
	@override String get poor => 'Poor';
}

// Path: chat.welcome.morning.breakfast
class _Translations$chat$welcome$morning$breakfast$en extends Translations$chat$welcome$morning$breakfast$zh {
	_Translations$chat$welcome$morning$breakfast$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Breakfast';
	@override String get prompt => 'Record breakfast expense';
	@override String get description => 'Log today\'s first expense';
}

// Path: chat.welcome.morning.yesterdayReview
class _Translations$chat$welcome$morning$yesterdayReview$en extends Translations$chat$welcome$morning$yesterdayReview$zh {
	_Translations$chat$welcome$morning$yesterdayReview$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Yesterday Review';
	@override String get prompt => 'Analyze yesterday\'s spending';
	@override String get description => 'Check how much you spent yesterday';
}

// Path: chat.welcome.morning.todayBudget
class _Translations$chat$welcome$morning$todayBudget$en extends Translations$chat$welcome$morning$todayBudget$zh {
	_Translations$chat$welcome$morning$todayBudget$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Today\'s Budget';
	@override String get prompt => 'How much budget left for today';
	@override String get description => 'Plan your spending for today';
}

// Path: chat.welcome.midday.lunch
class _Translations$chat$welcome$midday$lunch$en extends Translations$chat$welcome$midday$lunch$zh {
	_Translations$chat$welcome$midday$lunch$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Lunch';
	@override String get prompt => 'Record lunch expense';
	@override String get description => 'Log your lunch spending';
}

// Path: chat.welcome.midday.weeklyExpense
class _Translations$chat$welcome$midday$weeklyExpense$en extends Translations$chat$welcome$midday$weeklyExpense$zh {
	_Translations$chat$welcome$midday$weeklyExpense$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Weekly Spending';
	@override String get prompt => 'Analyze this week\'s spending';
	@override String get description => 'See your weekly expenses';
}

// Path: chat.welcome.midday.checkBalance
class _Translations$chat$welcome$midday$checkBalance$en extends Translations$chat$welcome$midday$checkBalance$zh {
	_Translations$chat$welcome$midday$checkBalance$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Check Balance';
	@override String get prompt => 'Check my account balance';
	@override String get description => 'View your account balances';
}

// Path: chat.welcome.afternoon.quickRecord
class _Translations$chat$welcome$afternoon$quickRecord$en extends Translations$chat$welcome$afternoon$quickRecord$zh {
	_Translations$chat$welcome$afternoon$quickRecord$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Quick Record';
	@override String get prompt => 'Help me record an expense';
	@override String get description => 'Quickly log a transaction';
}

// Path: chat.welcome.afternoon.analyzeSpending
class _Translations$chat$welcome$afternoon$analyzeSpending$en extends Translations$chat$welcome$afternoon$analyzeSpending$zh {
	_Translations$chat$welcome$afternoon$analyzeSpending$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Analyze Spending';
	@override String get prompt => 'Analyze this month\'s spending';
	@override String get description => 'View spending trends and breakdown';
}

// Path: chat.welcome.afternoon.budgetProgress
class _Translations$chat$welcome$afternoon$budgetProgress$en extends Translations$chat$welcome$afternoon$budgetProgress$zh {
	_Translations$chat$welcome$afternoon$budgetProgress$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Budget Progress';
	@override String get prompt => 'Check budget status';
	@override String get description => 'See how your budget is doing';
}

// Path: chat.welcome.evening.dinner
class _Translations$chat$welcome$evening$dinner$en extends Translations$chat$welcome$evening$dinner$zh {
	_Translations$chat$welcome$evening$dinner$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Dinner';
	@override String get prompt => 'Record dinner expense';
	@override String get description => 'Log tonight\'s dinner spending';
}

// Path: chat.welcome.evening.todaySummary
class _Translations$chat$welcome$evening$todaySummary$en extends Translations$chat$welcome$evening$todaySummary$zh {
	_Translations$chat$welcome$evening$todaySummary$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Today\'s Summary';
	@override String get prompt => 'Summarize today\'s spending';
	@override String get description => 'See what you spent today';
}

// Path: chat.welcome.evening.tomorrowPlan
class _Translations$chat$welcome$evening$tomorrowPlan$en extends Translations$chat$welcome$evening$tomorrowPlan$zh {
	_Translations$chat$welcome$evening$tomorrowPlan$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Tomorrow\'s Plan';
	@override String get prompt => 'What fixed expenses tomorrow';
	@override String get description => 'Plan ahead for tomorrow';
}

// Path: chat.welcome.night.makeupRecord
class _Translations$chat$welcome$night$makeupRecord$en extends Translations$chat$welcome$night$makeupRecord$zh {
	_Translations$chat$welcome$night$makeupRecord$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Catch Up';
	@override String get prompt => 'Help me log any missed expenses';
	@override String get description => 'Record expenses you forgot today';
}

// Path: chat.welcome.night.monthlyReview
class _Translations$chat$welcome$night$monthlyReview$en extends Translations$chat$welcome$night$monthlyReview$zh {
	_Translations$chat$welcome$night$monthlyReview$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Monthly Review';
	@override String get prompt => 'Analyze this month\'s spending';
	@override String get description => 'Review your monthly expenses';
}

// Path: chat.welcome.night.financialThinking
class _Translations$chat$welcome$night$financialThinking$en extends Translations$chat$welcome$night$financialThinking$zh {
	_Translations$chat$welcome$night$financialThinking$en._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Financial Tips';
	@override String get prompt => 'Give me some financial advice';
	@override String get description => 'Get AI-powered financial insights';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsEn {
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
			'common.cancelled' => 'Cancelled',
			'common.saving' => 'Saving...',
			'common.saveFailed' => 'Save failed',
			'genui.errorBusy' => 'Sorry, the service is temporarily busy, please try again later',
			'genui.errorTimeout' => 'Request timed out, please check your network and retry',
			'genui.errorNetwork' => 'Network connection issue, please check and retry',
			'genui.errorSessionExpired' => 'Session expired, please log in again',
			'genui.errorGeneric' => 'Something went wrong, please try again later',
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
			'time.monthsAgo' => ({required Object count}) => '${count}mo ago',
			'time.yearsAgo' => ({required Object count}) => '${count}y ago',
			'greeting.morning' => 'Good Morning',
			'greeting.afternoon' => 'Good Afternoon',
			'greeting.evening' => 'Good Evening',
			'navigation.home' => 'Home',
			'navigation.budget' => 'Budget',
			'navigation.chat' => 'AI Chat',
			'navigation.statistics' => 'Statistics',
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
			'comment.contentRequired' => 'Comment content is required',
			'comment.copyContent' => 'Copy content',
			'comment.contentCopied' => 'Comment content copied',
			'comment.collapseReplies' => 'Collapse replies',
			'comment.expandMoreReplies' => ({required Object count}) => 'Show ${count} more replies',
			'comment.recordedBy' => 'Recorded by',
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
			'settings.currentVersion' => ({required Object version}) => 'Current version: v${version}',
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
			'speech.configSaveFailed' => 'Failed to save configuration',
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
			_ => null,
		} ?? switch (path) {
			'forecast.recurringTransaction.preview' => 'Preview',
			'forecast.recurringTransaction.daily' => 'Daily',
			'forecast.recurringTransaction.weekly' => 'Weekly',
			'forecast.recurringTransaction.monthly' => 'Monthly',
			'forecast.recurringTransaction.yearly' => 'Yearly',
			'forecast.recurringTransaction.custom' => 'Custom',
			'forecast.recurringTransaction.cycle' => 'Cycle',
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
			'forecast.recurringTransaction.sameAccount' => 'Source and target accounts must be different',
			'forecast.recurringTransaction.endBeforeStart' => 'End date cannot be earlier than start date',
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
			'forecast.recurringTransaction.dayUnit' => ({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(count, one: 'Day', other: 'Days', ),
			'forecast.recurringTransaction.weekUnit' => ({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(count, one: 'Week', other: 'Weeks', ),
			'forecast.recurringTransaction.monthUnit' => ({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(count, one: 'Month', other: 'Months', ),
			'forecast.recurringTransaction.yearUnit' => ({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(count, one: 'Year', other: 'Years', ),
			'chat.newChat' => 'New Chat',
			'chat.noMessages' => 'No messages to display.',
			'chat.loadingFailed' => 'Loading failed',
			'chat.inputMessage' => 'Type a message...',
			'chat.aiThinking' => 'AI processing...',
			'chat.stoppedResponse' => 'You have stopped this response',
			'chat.errorRecover' => 'Sorry, I encountered an issue, please try again 🙏',
			'chat.contentCopied' => 'Content copied',
			'chat.jsonCopied' => 'JSON data copied',
			'chat.noContentToCopy' => 'No content to copy',
			'chat.listening' => 'Listening...',
			'chat.tools.processing' => 'Processing...',
			'chat.tools.readFile' => 'Reading file...',
			'chat.tools.searchTransactions' => 'Searching transactions...',
			'chat.tools.queryBudgetStatus' => 'Checking budget...',
			'chat.tools.createBudget' => 'Creating budget plan...',
			'chat.tools.getCashFlowAnalysis' => 'Analyzing cash flow...',
			'chat.tools.getFinancialHealthScore' => 'Calculating financial health score...',
			'chat.tools.getFinancialSummary' => 'Generating financial report...',
			'chat.tools.evaluateFinancialHealth' => 'Evaluating financial health...',
			'chat.tools.simulateExpenseImpact' => 'Simulating purchase impact...',
			'chat.tools.recordTransactions' => 'Recording transactions...',
			'chat.tools.createTransaction' => 'Recording transaction...',
			'chat.tools.duckduckgoSearch' => 'Searching the web...',
			'chat.tools.executeTransfer' => 'Executing transfer...',
			'chat.tools.listDir' => 'Browsing directory...',
			'chat.tools.execute' => 'Processing...',
			'chat.tools.analyzeSpending' => 'Analyzing spendings...',
			'chat.tools.analyzeCashflow' => 'Analyzing cashflow...',
			'chat.tools.forecastBalance' => 'Forecasting balance...',
			'chat.tools.suggestBudget' => 'Suggesting budget...',
			'chat.tools.listSpaces' => 'Loading shared spaces...',
			'chat.tools.querySpaceSummary' => 'Querying space summary...',
			'chat.tools.prepareTransfer' => 'Preparing transfer...',
			'chat.tools.unknown' => 'Processing request...',
			'chat.tools.done.readFile' => 'Read file',
			'chat.tools.done.searchTransactions' => 'Searched transactions',
			'chat.tools.done.queryBudgetStatus' => 'Checked budget',
			'chat.tools.done.createBudget' => 'Created budget',
			'chat.tools.done.getCashFlowAnalysis' => 'Analyzed cash flow',
			'chat.tools.done.getFinancialHealthScore' => 'Calculated health score',
			'chat.tools.done.getFinancialSummary' => 'Financial report ready',
			'chat.tools.done.evaluateFinancialHealth' => 'Health evaluation complete',
			'chat.tools.done.forecastBalance' => 'Balance forecast ready',
			'chat.tools.done.simulateExpenseImpact' => 'Impact simulation complete',
			'chat.tools.done.recordTransactions' => 'Recorded transactions',
			'chat.tools.done.createTransaction' => 'Recorded transaction',
			'chat.tools.done.duckduckgoSearch' => 'Searched the web',
			'chat.tools.done.executeTransfer' => 'Transfer complete',
			'chat.tools.done.listDir' => 'Browsed directory',
			'chat.tools.done.execute' => 'Processing complete',
			'chat.tools.done.analyzeSpending' => 'Spending analysis complete',
			'chat.tools.done.analyzeCashflow' => 'Cashflow analysis complete',
			'chat.tools.done.suggestBudget' => 'Budget suggestion complete',
			'chat.tools.done.listSpaces' => 'Shared spaces loaded',
			'chat.tools.done.querySpaceSummary' => 'Space summary ready',
			'chat.tools.done.prepareTransfer' => 'Transfer ready',
			'chat.tools.done.unknown' => 'Processing complete',
			'chat.tools.done.analyzeFinance' => '財務分析完成',
			'chat.tools.done.forecastFinance' => '財務預測完成',
			'chat.tools.done.analyzeBudget' => '預算分析完成',
			'chat.tools.done.auditAnalysis' => '審計分析完成',
			'chat.tools.done.budgetOps' => '預算處理完成',
			'chat.tools.done.createSharedTransaction' => '共享帳單創建完成',
			'chat.tools.done.prepareBudgetSimulation' => 'Budget simulation prepared',
			'chat.tools.done.simulateBudget' => 'Budget simulation completed',
			'chat.tools.failed.unknown' => 'Action failed',
			'chat.tools.cancelled' => 'Cancelled',
			'chat.tools.analyzeFinance' => '正在分析財務狀況...',
			'chat.tools.forecastFinance' => '正在預測財務趨勢...',
			'chat.tools.analyzeBudget' => '正在分析預算...',
			'chat.tools.auditAnalysis' => '正在審計分析...',
			'chat.tools.budgetOps' => '正在處理預算...',
			'chat.tools.createSharedTransaction' => '正在創建共享帳單...',
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
			'chat.updatedAt' => ({required Object time}) => 'Updated ${time}',
			'chat.createdAt' => ({required Object time}) => 'Created ${time}',
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
			'chat.genui.error.title' => 'Rendering failed',
			'chat.genui.error.fetchFailed' => 'Failed to load, please retry later.',
			'chat.genui.error.dataIncomplete' => 'Incomplete data',
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
			'chat.shareComingSoon' => 'Share feature coming soon...',
			'chat.invalidAttachmentLink' => 'Invalid attachment link',
			'chat.unableToOpenAttachmentLink' => 'Unable to open attachment link',
			'chat.aiCommunicationError' => ({required Object error}) => 'Sorry, AI assistant communication error: ${error}',
			'image.deleteTitle' => 'Delete Image',
			'image.deleteConfirm' => 'Are you sure you want to delete this image? This action cannot be undone.',
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
			'error.accountInfoMissing' => 'Account information missing',
			'error.sharedSpaceInfoMissing' => 'Shared space information missing',
			'error.settingsSteps' => 'Settings steps:',
			'error.suggestions' => 'Suggestions:',
			'error.fileNotFound' => 'File not found',
			'error.fileNotFoundHint' => 'Please confirm the file exists or select another file.',
			'error.selectAgain' => 'Select again',
			'error.thumbnailGenerationFailed' => 'Thumbnail generation failed',
			'error.thumbnailGenerationHint' => 'Failed to generate thumbnail for the image, but the file has been selected. You can still continue using this file.',
			'error.help' => 'Help:',
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
			'financial.deleteFailed' => 'Delete failed, please try again later',
			'financial.missingExchangeRates' => ({required Object currencies}) => 'Exchange rates are unavailable for some currencies, so the related accounts are excluded from totals: ${currencies}',
			'financial.cashPocketTitle' => 'My Cash Pockets',
			'financial.sourcesCount' => ({required Object count}) => '${count} Sources',
			'financial.lastUpdatedAt' => ({required Object time}) => 'Last updated: ${time}',
			'financial.neverUpdated' => 'Never updated',
			'financial.updateNow' => 'Update Now',
			'app.splashTitle' => 'Finvo: Intelligence that Grows.',
			'app.splashSubtitle' => 'Smart Financial Assistant',
			'statistics.title' => 'Analysis',
			_ => null,
		} ?? switch (path) {
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
			'sharedSpace.create.subtitle' => 'Create a shared space to view and analyze shared finances',
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
			'sharedSpace.join.subtitle' => 'Enter the invite code to view and analyze shared finances',
			'sharedSpace.join.codeHint' => 'Enter your 6-digit invite code',
			'sharedSpace.join.cancel' => 'Cancel',
			'sharedSpace.join.submit' => 'Join',
			'sharedSpace.join.codeRequired' => 'Please enter invite code',
			'sharedSpace.join.codeInvalid' => 'Please enter a 6-digit invite code',
			'sharedSpace.list.emptyTitle' => 'Shared finances, clear at a glance',
			'sharedSpace.list.emptySubtitle' => 'Create or join a space to view, analyze, and summarize shared finances with family and friends',
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
			'sharedSpace.detail.noMoreTransactions' => 'No more transactions',
			'sharedSpace.notifications.title' => 'Notifications',
			'sharedSpace.notifications.empty' => 'No notifications',
			'sharedSpace.notifications.emptyHint' => 'When you have new invites or activities,\nyou will receive notifications here',
			'sharedSpace.notifications.incompleteInfo' => 'Incomplete invite info',
			'sharedSpace.notifications.inviteAccepted' => 'Invite accepted!',
			'sharedSpace.notifications.inviteRejected' => 'Invite rejected',
			'sharedSpace.notifications.allMarkedRead' => 'All notifications marked as read',
			'sharedSpace.inviteCard.title' => 'Invite Code',
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
