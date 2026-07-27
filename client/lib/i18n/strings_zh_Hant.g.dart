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
class TranslationsZhHant extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsZhHant({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.zhHant,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <zh-Hant>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsZhHant _root = this; // ignore: unused_field

	@override
	TranslationsZhHant $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsZhHant(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$common$zh_Hant common = _Translations$common$zh_Hant._(_root);
	@override late final _Translations$time$zh_Hant time = _Translations$time$zh_Hant._(_root);
	@override late final _Translations$greeting$zh_Hant greeting = _Translations$greeting$zh_Hant._(_root);
	@override late final _Translations$navigation$zh_Hant navigation = _Translations$navigation$zh_Hant._(_root);
	@override late final _Translations$auth$zh_Hant auth = _Translations$auth$zh_Hant._(_root);
	@override late final _Translations$transaction$zh_Hant transaction = _Translations$transaction$zh_Hant._(_root);
	@override late final _Translations$home$zh_Hant home = _Translations$home$zh_Hant._(_root);
	@override late final _Translations$comment$zh_Hant comment = _Translations$comment$zh_Hant._(_root);
	@override late final _Translations$calendar$zh_Hant calendar = _Translations$calendar$zh_Hant._(_root);
	@override late final _Translations$category$zh_Hant category = _Translations$category$zh_Hant._(_root);
	@override late final _Translations$settings$zh_Hant settings = _Translations$settings$zh_Hant._(_root);
	@override late final _Translations$appearance$zh_Hant appearance = _Translations$appearance$zh_Hant._(_root);
	@override late final _Translations$speech$zh_Hant speech = _Translations$speech$zh_Hant._(_root);
	@override late final _Translations$amountTheme$zh_Hant amountTheme = _Translations$amountTheme$zh_Hant._(_root);
	@override late final _Translations$locale$zh_Hant locale = _Translations$locale$zh_Hant._(_root);
	@override late final _Translations$budget$zh_Hant budget = _Translations$budget$zh_Hant._(_root);
	@override late final _Translations$dateRange$zh_Hant dateRange = _Translations$dateRange$zh_Hant._(_root);
	@override late final _Translations$forecast$zh_Hant forecast = _Translations$forecast$zh_Hant._(_root);
	@override late final _Translations$chat$zh_Hant chat = _Translations$chat$zh_Hant._(_root);
	@override late final _Translations$footprint$zh_Hant footprint = _Translations$footprint$zh_Hant._(_root);
	@override late final _Translations$media$zh_Hant media = _Translations$media$zh_Hant._(_root);
	@override late final _Translations$error$zh_Hant error = _Translations$error$zh_Hant._(_root);
	@override late final _Translations$fontTest$zh_Hant fontTest = _Translations$fontTest$zh_Hant._(_root);
	@override late final _Translations$wizard$zh_Hant wizard = _Translations$wizard$zh_Hant._(_root);
	@override late final _Translations$user$zh_Hant user = _Translations$user$zh_Hant._(_root);
	@override late final _Translations$account$zh_Hant account = _Translations$account$zh_Hant._(_root);
	@override late final _Translations$financial$zh_Hant financial = _Translations$financial$zh_Hant._(_root);
	@override late final _Translations$app$zh_Hant app = _Translations$app$zh_Hant._(_root);
	@override late final _Translations$statistics$zh_Hant statistics = _Translations$statistics$zh_Hant._(_root);
	@override late final _Translations$currency$zh_Hant currency = _Translations$currency$zh_Hant._(_root);
	@override late final _Translations$sharedSpace$zh_Hant sharedSpace = _Translations$sharedSpace$zh_Hant._(_root);
	@override late final _Translations$budgetSuggestion$zh_Hant budgetSuggestion = _Translations$budgetSuggestion$zh_Hant._(_root);
	@override late final _Translations$server$zh_Hant server = _Translations$server$zh_Hant._(_root);
	@override late final _Translations$errorMapping$zh_Hant errorMapping = _Translations$errorMapping$zh_Hant._(_root);
	@override late final _Translations$notification$zh_Hant notification = _Translations$notification$zh_Hant._(_root);
}

// Path: common
class _Translations$common$zh_Hant extends Translations$common$zh {
	_Translations$common$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get loading => '載入中...';
	@override String get error => '錯誤';
	@override String get retry => '重試';
	@override String get cancel => '取消';
	@override String get confirm => '確認';
	@override String get save => '儲存';
	@override String get delete => '刪除';
	@override String get edit => '編輯';
	@override String get add => '添加';
	@override String get search => '搜尋';
	@override String get filter => '篩選';
	@override String get sort => '排序';
	@override String get refresh => '刷新';
	@override String get more => '更多';
	@override String get less => '收起';
	@override String get all => '全部';
	@override String get none => '無';
	@override String get ok => '確定';
	@override String get unknown => '未知';
	@override String get noData => '暫無數據';
	@override String get loadMore => '載入更多';
	@override String get noMore => '沒有更多了';
	@override String get loadFailed => '載入失敗';
	@override String get history => '交易記錄';
	@override String get reset => '重置';
}

// Path: time
class _Translations$time$zh_Hant extends Translations$time$zh {
	_Translations$time$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get today => '今天';
	@override String get yesterday => '昨天';
	@override String get dayBeforeYesterday => '前天';
	@override String get thisWeek => '本週';
	@override String get thisMonth => '本月';
	@override String get thisYear => '今年';
	@override String get selectDate => '選擇日期';
	@override String get selectTime => '選擇時間';
	@override String get justNow => '剛剛';
	@override String minutesAgo({required Object count}) => '${count}分鐘前';
	@override String hoursAgo({required Object count}) => '${count}小時前';
	@override String daysAgo({required Object count}) => '${count}天前';
	@override String weeksAgo({required Object count}) => '${count}週前';
}

// Path: greeting
class _Translations$greeting$zh_Hant extends Translations$greeting$zh {
	_Translations$greeting$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get morning => '上午好';
	@override String get afternoon => '下午好';
	@override String get evening => '晚上好';
}

// Path: navigation
class _Translations$navigation$zh_Hant extends Translations$navigation$zh {
	_Translations$navigation$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get home => '首頁';
	@override String get forecast => '預測';
	@override String get footprint => '足跡';
	@override String get profile => '我的';
}

// Path: auth
class _Translations$auth$zh_Hant extends Translations$auth$zh {
	_Translations$auth$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get login => '登錄';
	@override String get loggingIn => '登錄中...';
	@override String get logout => '登出';
	@override String get register => '註冊';
	@override String get registering => '註冊中...';
	@override String get welcomeBack => '歡迎回來';
	@override String get loginSuccess => '歡迎回來!';
	@override String get loginFailed => '登錄失敗';
	@override String get pleaseTryAgain => '請稍後重試。';
	@override String get loginSubtitle => '登錄以繼續使用 AI 記帳助理';
	@override String get noAccount => '還沒有帳戶？註冊';
	@override String get createAccount => '創建您的帳戶';
	@override String get setPassword => '設置密碼';
	@override String get setAccountPassword => '設置您的帳戶密碼';
	@override String get completeRegistration => '完成註冊';
	@override String get registrationSuccess => '註冊成功!';
	@override String get registrationFailed => '註冊失敗';
	@override late final _Translations$auth$email$zh_Hant email = _Translations$auth$email$zh_Hant._(_root);
	@override late final _Translations$auth$password$zh_Hant password = _Translations$auth$password$zh_Hant._(_root);
	@override late final _Translations$auth$verificationCode$zh_Hant verificationCode = _Translations$auth$verificationCode$zh_Hant._(_root);
	@override String get logoutSuccess => 'Logged out successfully';
	@override String get confirmLogoutTitle => 'Confirm Logout';
	@override String get confirmLogoutContent => 'Are you sure you want to log out?';
}

// Path: transaction
class _Translations$transaction$zh_Hant extends Translations$transaction$zh {
	_Translations$transaction$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get expense => '支出';
	@override String get income => '收入';
	@override String get transfer => '轉帳';
	@override String get amount => '金額';
	@override String get category => '分類';
	@override String get description => '描述';
	@override String get tags => '標籤';
	@override String get saveTransaction => '儲存記帳';
	@override String get pleaseEnterAmount => '請輸入金額';
	@override String get pleaseSelectCategory => '請選擇分類';
	@override String get saveFailed => '儲存失敗';
	@override String get descriptionHint => '記錄這筆交易的詳細信息...';
	@override String get addCustomTag => '添加自定義標籤';
	@override String get commonTags => '常用標籤';
	@override String maxTagsHint({required Object maxTags}) => '最多添加 ${maxTags} 個標籤';
	@override String get noTransactionsFound => '沒有找到交易記錄';
	@override String get tryAdjustingSearch => '嘗試調整搜尋條件或創建新的交易記錄';
	@override String get noDescription => '無描述';
	@override String get payment => '支付';
	@override String get account => '帳戶';
	@override String get time => '時間';
	@override String get location => '地點';
	@override String get transactionDetail => '交易詳情';
	@override String get favorite => '收藏';
	@override String get confirmDelete => '確認刪除';
	@override String get deleteTransactionConfirm => '您確定要刪除此條交易記錄嗎？此操作無法撤銷。';
	@override String get noActions => '沒有可用的操作';
	@override String get deleted => '已刪除';
	@override String get deleteFailed => '刪除失敗，請稍後重試';
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
}

// Path: home
class _Translations$home$zh_Hant extends Translations$home$zh {
	_Translations$home$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get totalExpense => '總消費金額';
	@override String get todayExpense => '今日支出';
	@override String get monthExpense => '本月支出';
	@override String yearProgress({required Object year}) => '${year}年進度';
	@override String get amountHidden => '••••••••';
	@override String get loadFailed => '載入失敗';
	@override String get noTransactions => '暫無交易記錄';
	@override String get tryRefresh => '刷新試試';
	@override String get noMoreData => '沒有更多數據了';
	@override String get userNotLoggedIn => '用戶未登錄，無法載入數據';
}

// Path: comment
class _Translations$comment$zh_Hant extends Translations$comment$zh {
	_Translations$comment$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get error => '錯誤';
	@override String get commentFailed => '評論失敗';
	@override String replyToPrefix({required Object name}) => '回覆 @${name}:';
	@override String get reply => '回覆';
	@override String get addNote => '添加備註...';
	@override String get confirmDeleteTitle => '確認刪除';
	@override String get confirmDeleteContent => '你確定要刪除這條評論嗎？此操作無法撤銷。';
	@override String get success => '成功';
	@override String get commentDeleted => '評論已刪除';
	@override String get deleteFailed => '刪除失敗';
	@override String get deleteComment => '刪除評論';
	@override String get hint => '提示';
	@override String get noActions => '沒有可用的操作';
	@override String get note => '備註';
	@override String get noNote => '暫無備註';
	@override String get loadFailed => '載入備註失敗';
}

// Path: calendar
class _Translations$calendar$zh_Hant extends Translations$calendar$zh {
	_Translations$calendar$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => '消費日曆';
	@override late final _Translations$calendar$weekdays$zh_Hant weekdays = _Translations$calendar$weekdays$zh_Hant._(_root);
	@override String get loadFailed => '載入日曆數據失敗';
	@override String thisMonth({required Object amount}) => '本月: ${amount}';
	@override String get counting => '統計中...';
	@override String get unableToCount => '無法統計';
	@override String get trend => '趨勢: ';
	@override String get noTransactionsTitle => '當日無交易記錄';
	@override String get loadTransactionFailed => '載入交易失敗';
}

// Path: category
class _Translations$category$zh_Hant extends Translations$category$zh {
	_Translations$category$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get dailyConsumption => '日常消費';
	@override String get transportation => '交通出行';
	@override String get healthcare => '醫療健康';
	@override String get housing => '住房物業';
	@override String get education => '教育培訓';
	@override String get incomeCategory => '收入進帳';
	@override String get socialGifts => '社交饋贈';
	@override String get moneyTransfer => '資金周轉';
	@override String get other => '其他';
	@override String get foodDining => '餐飲美食';
	@override String get shoppingRetail => '購物消費';
	@override String get housingUtilities => '居住物業';
	@override String get personalCare => '個人護理';
	@override String get entertainment => '休閒娛樂';
	@override String get medicalHealth => '醫療健康';
	@override String get insurance => '保險';
	@override String get socialGifting => '人情往來';
	@override String get financialTax => '金融稅務';
	@override String get others => '其他支出';
	@override String get salaryWage => '工資薪水';
	@override String get businessTrade => '經營交易';
	@override String get investmentReturns => '投資回報';
	@override String get giftBonus => '禮金紅包';
	@override String get refundRebate => '退款返利';
	@override String get generalTransfer => '轉帳';
	@override String get debtRepayment => '債務還款';
}

// Path: settings
class _Translations$settings$zh_Hant extends Translations$settings$zh {
	_Translations$settings$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => '設置';
	@override String get language => '語言';
	@override String get languageSettings => '語言設置';
	@override String get selectLanguage => '選擇語言';
	@override String get languageChanged => '語言已更改';
	@override String get restartToApply => '重啟應用以應用更改';
	@override String get theme => '主題';
	@override String get darkMode => '深色模式';
	@override String get lightMode => '淺色模式';
	@override String get systemMode => '跟隨系統';
	@override String get developerOptions => '開發者選項';
	@override String get authDebug => '認證狀態調試';
	@override String get authDebugSubtitle => '查看認證狀態和調試信息';
	@override String get fontTest => '字體測試';
	@override String get fontTestSubtitle => '測試應用字體顯示效果';
	@override String get helpAndFeedback => '幫助與反饋';
	@override String get helpAndFeedbackSubtitle => '獲取幫助或提供反饋';
	@override String get aboutApp => '關於應用';
	@override String get aboutAppSubtitle => '版本信息和開發者信息';
	@override String currencyChangedRefreshHint({required Object currency}) => '已切換為 ${currency}，新交易將以此貨幣記錄';
	@override String get sharedSpace => '共享空間';
	@override String get speechRecognition => '語音識別';
	@override String get speechRecognitionSubtitle => '配置語音輸入參數';
	@override String get amountDisplayStyle => '金額顯示樣式';
	@override String get currency => '顯示幣種';
	@override String get appearance => '外觀設置';
	@override String get appearanceSubtitle => '主題模式與配色方案';
	@override String get speechTest => '語音測試';
	@override String get speechTestSubtitle => '測試 WebSocket 語音連接';
	@override String get userTypeRegular => '普通用戶';
	@override String get selectAmountStyle => '選擇金額顯示樣式';
	@override String get currencyDescription => '選擇您偏好的顯示幣種。所有金額都將以此幣種顯示。';
	@override String get amountStyleNotice => 'Note: Amount styles are primarily applied to \'Transactions\' and \'Trends\'. To maintain visual clarity, \'Account Balances\' and \'Asset Summaries\' will remain in neutral colors.';
	@override String get editUsername => 'Edit Username';
	@override String get enterUsername => 'Enter username';
	@override String get usernameRequired => 'Username is required';
	@override String get usernameUpdated => 'Username updated';
	@override String get avatarUpdated => 'Avatar updated';
	@override String get appearanceUpdated => '外观设置已更新';
}

// Path: appearance
class _Translations$appearance$zh_Hant extends Translations$appearance$zh {
	_Translations$appearance$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => '外觀設置';
	@override String get themeMode => '主題模式';
	@override String get light => '淺色';
	@override String get dark => '深色';
	@override String get system => '跟隨系統';
	@override String get colorScheme => '配色方案';
	@override late final _Translations$appearance$palettes$zh_Hant palettes = _Translations$appearance$palettes$zh_Hant._(_root);
}

// Path: speech
class _Translations$speech$zh_Hant extends Translations$speech$zh {
	_Translations$speech$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => '語音識別設置';
	@override String get service => '語音識別服務';
	@override String get systemVoice => '系統語音';
	@override String get systemVoiceSubtitle => '使用手機內置的語音識別服務（推薦）';
	@override String get selfHostedASR => '自建 ASR 服務';
	@override String get selfHostedASRSubtitle => '使用 WebSocket 連接到自建語音識別服務';
	@override String get serverConfig => '服務器配置';
	@override String get serverAddress => '服務器地址';
	@override String get port => '端口';
	@override String get path => '路徑';
	@override String get saveConfig => '儲存配置';
	@override String get info => '信息';
	@override String get infoContent => '• 系統語音：使用設備內置服務，無需配置，響應更快\n• 自建 ASR：適用於自定義模型或離線場景\n\n更改將在下次使用語音輸入時生效。';
	@override String get enterAddress => '請輸入服務器地址';
	@override String get enterValidPort => '請輸入有效的端口 (1-65535)';
	@override String get configSaved => '配置已儲存';
}

// Path: amountTheme
class _Translations$amountTheme$zh_Hant extends Translations$amountTheme$zh {
	_Translations$amountTheme$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get chinaMarket => '中國市場習慣';
	@override String get chinaMarketDesc => '紅漲綠跌/黑跌 (推薦)';
	@override String get international => '國際標準';
	@override String get internationalDesc => '綠漲紅跌';
	@override String get minimalist => '極簡模式';
	@override String get minimalistDesc => '僅通過符號區分';
	@override String get colorBlind => '色弱友好';
	@override String get colorBlindDesc => '藍橙配色方案';
}

// Path: locale
class _Translations$locale$zh_Hant extends Translations$locale$zh {
	_Translations$locale$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get chinese => '中文（簡體）';
	@override String get traditionalChinese => '中文（繁體）';
	@override String get english => 'English';
	@override String get japanese => '日本語';
	@override String get korean => '한국어';
}

// Path: budget
class _Translations$budget$zh_Hant extends Translations$budget$zh {
	_Translations$budget$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => '預算管理';
	@override String get detail => '預算詳情';
	@override String get info => '預算信息';
	@override String get totalBudget => '總預算';
	@override String get categoryBudget => '分類預算';
	@override String get monthlySummary => '本月預算彙總';
	@override String get used => '已使用';
	@override String get remaining => '剩餘';
	@override String get overspent => '超支';
	@override String get budget => '預算';
	@override String get loadFailed => '載入失敗';
	@override String get noBudget => '暫無預算';
	@override String get createHint => '點擊下方按鈕設置您的預算';
	@override String get paused => '已暫停';
	@override String get pause => '暫停';
	@override String get resume => '恢復';
	@override String get budgetPaused => '預算已暫停';
	@override String get budgetResumed => '預算已恢復';
	@override String get operationFailed => '操作失敗';
	@override String get deleteBudget => '刪除預算';
	@override String get deleteConfirm => '確定要刪除這個預算嗎？此操作不可撤銷。';
	@override String get type => '類型';
	@override String get category => '分類';
	@override String get period => '週期';
	@override String get rollover => '滾動預算';
	@override String get rolloverBalance => '滾動餘額';
	@override String get enabled => '開啟';
	@override String get disabled => '關閉';
	@override String get statusNormal => '預算正常';
	@override String get statusWarning => '接近上限';
	@override String get statusOverspent => '已超支';
	@override String get statusAchieved => '目標達成';
	@override String tipNormal({required Object amount}) => '還剩 ${amount} 可用';
	@override String tipWarning({required Object amount}) => '僅剩 ${amount}，請注意控制';
	@override String tipOverspent({required Object amount}) => '已超支 ${amount}';
	@override String get tipAchieved => '恭喜完成儲蓄目標！';
	@override String remainingAmount({required Object amount}) => '剩餘 ${amount}';
	@override String overspentAmount({required Object amount}) => '超支 ${amount}';
	@override String budgetAmount({required Object amount}) => '預算 ${amount}';
	@override String get active => '活躍';
	@override String get all => '全部';
	@override String get notFound => '預算不存在或已被刪除';
	@override String get setup => '預算設置';
	@override String get settings => '預算設置';
	@override String get setAmount => '設置預算金額';
	@override String get setAmountDesc => '為每個分類設置預算金額';
	@override String get monthly => '月度預算';
	@override String get monthlyDesc => '按月管理您的支出，適合大多數人';
	@override String get weekly => '周預算';
	@override String get weeklyDesc => '按周管理支出，更精細的控制';
	@override String get yearly => '年度預算';
	@override String get yearlyDesc => '長期財務規劃，適合大額支出管理';
	@override String get editBudget => '編輯預算';
	@override String get editBudgetDesc => '修改預算金額和分類';
	@override String get reminderSettings => '提醒設置';
	@override String get reminderSettingsDesc => '設置預算提醒和通知';
	@override String get report => '預算報告';
	@override String get reportDesc => '查看詳細的預算分析報告';
	@override String get welcome => '歡迎使用預算功能！';
	@override String get createNewPlan => '創建新的預算計劃';
	@override String get welcomeDesc => '通過設置預算，您可以更好地控制支出，實現財務目標。讓我們開始設置您的第一個預算計劃吧！';
	@override String get createDesc => '為不同的支出類別設置預算限額，幫助您更好地管理財務。';
	@override String get newBudget => '新建預算';
	@override String get budgetAmountLabel => '預算金額';
	@override String get currency => '貨幣';
	@override String get periodSettings => '週期設置';
	@override String get autoGenerateTransactions => '開啟後按規則自動生成交易';
	@override String get cycle => '週期';
	@override String get budgetCategory => '預算分類';
	@override String get advancedOptions => '高級選項';
	@override String get periodType => '週期類型';
	@override String get anchorDay => '起算日';
	@override String get selectPeriodType => '選擇週期類型';
	@override String get selectAnchorDay => '選擇起算日';
	@override String get rolloverDescription => '未用完的預算結轉到下期';
	@override String get createBudget => '創建預算';
	@override String get save => '儲存';
	@override String get pleaseEnterAmount => '請輸入預算金額';
	@override String get invalidAmount => '請輸入有效的預算金額';
	@override String get updateSuccess => '預算更新成功';
	@override String get createSuccess => '預算創建成功';
	@override String get deleteSuccess => '預算已刪除';
	@override String get deleteFailed => '刪除失敗';
	@override String everyMonthDay({required Object day}) => '每月 ${day} 號';
	@override String get periodWeekly => '每週';
	@override String get periodBiweekly => '雙週';
	@override String get periodMonthly => '每月';
	@override String get periodYearly => '每年';
	@override String get statusActive => '進行中';
	@override String get statusArchived => '已歸檔';
	@override String get periodStatusOnTrack => '正常';
	@override String get periodStatusWarning => '預警';
	@override String get periodStatusExceeded => '超支';
	@override String get periodStatusAchieved => '達成';
	@override String usedPercent({required Object percent}) => '${percent}% 已使用';
	@override String dayOfMonth({required Object day}) => '${day} 號';
	@override String get tenThousandSuffix => '萬';
	@override String get settingsLoadFailed => '載入設定失敗';
	@override String get settingsSaveSuccess => '設定已儲存';
	@override String get settingsSaveFailed => '儲存失敗';
	@override String get settingsSave => '儲存設定';
	@override String get settingsWarningThreshold => '預警閾值';
	@override String get settingsWarningDesc => '當使用率達到此百分比時顯示預警狀態';
	@override String get settingsAlertThreshold => '超支閾值';
	@override String get settingsAlertDesc => '當使用率達到此百分比時顯示超支狀態';
	@override String get settingsThresholdOrder => '預警閾值不能大於超支閾值';
}

// Path: dateRange
class _Translations$dateRange$zh_Hant extends Translations$dateRange$zh {
	_Translations$dateRange$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get custom => '自定義';
	@override String get pickerTitle => '選擇時間範圍';
	@override String get startDate => '開始日期';
	@override String get endDate => '結束日期';
	@override String get hint => '請選擇日期範圍';
}

// Path: forecast
class _Translations$forecast$zh_Hant extends Translations$forecast$zh {
	_Translations$forecast$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => '預測';
	@override String get subtitle => '基於您的財務數據智能預測未來現金流';
	@override String get financialNavigator => '你好，我是你的財務領航員';
	@override String get financialMapSubtitle => '只需 3 步，我們一起繪製你未來的財務地圖';
	@override String get predictCashFlow => '預測未來現金流';
	@override String get predictCashFlowDesc => '看清每一天的財務狀況';
	@override String get aiSmartSuggestions => 'AI 智能建議';
	@override String get aiSmartSuggestionsDesc => '個性化的財務決策指導';
	@override String get riskWarning => '風險預警';
	@override String get riskWarningDesc => '提前發現潛在的財務風險';
	@override String get analyzing => '我正在分析你的財務數據，生成未來 30 天的現金流預測';
	@override String get analyzePattern => '分析收入支出模式';
	@override String get calculateTrend => '計算現金流趨勢';
	@override String get generateWarning => '生成風險預警';
	@override String get loadingForecast => '正在載入財務預測...';
	@override String get todayLabel => '今日';
	@override String get tomorrowLabel => '明日';
	@override String get balanceLabel => '餘額';
	@override String get noSpecialEvents => '無特殊事件';
	@override String get financialSafetyLine => '財務安全線';
	@override String get currentSetting => '當前設置';
	@override String get dailySpendingEstimate => '日常消費預估';
	@override String get adjustDailySpendingAmount => '調整每日消費預測金額';
	@override String get tellMeYourSafetyLine => '告訴我你的財務"安心線"是多少？';
	@override String get safetyLineDescription => '這是你希望帳戶保持的最低餘額，當餘額接近這個數值時，我會提醒你注意財務風險。';
	@override String get dailySpendingQuestion => '每天的"小日子"大概花多少？';
	@override String get dailySpendingDescription => '包括吃飯、交通、購物等日常開銷\n這只是一個初始估算，我會通過你未來的真實記錄，讓預測越來越準';
	@override String get perDay => '每天';
	@override String get referenceStandard => '參考標準';
	@override String get frugalType => '節儉型';
	@override String get comfortableType => '舒適型';
	@override String get relaxedType => '寬鬆型';
	@override String get frugalAmount => '50-100元/天';
	@override String get comfortableAmount => '100-200元/天';
	@override String get relaxedAmount => '200-300元/天';
	@override late final _Translations$forecast$recurringTransaction$zh_Hant recurringTransaction = _Translations$forecast$recurringTransaction$zh_Hant._(_root);
}

// Path: chat
class _Translations$chat$zh_Hant extends Translations$chat$zh {
	_Translations$chat$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get newChat => '新聊天';
	@override String get noMessages => '沒有消息可顯示。';
	@override String get loadingFailed => '載入失敗';
	@override String get inputMessage => '輸入消息...';
	@override String get listening => '正在聆聽...';
	@override String get aiThinking => '正在處理...';
	@override late final _Translations$chat$tools$zh_Hant tools = _Translations$chat$tools$zh_Hant._(_root);
	@override String get speechNotRecognized => '未識別到語音，請重試';
	@override String get currentExpense => '当前支出';
	@override String get loadingComponent => '正在載入組件...';
	@override String get noHistory => '暫無歷史會話';
	@override String get startNewChat => '開啟一段新對話吧！';
	@override String get searchHint => '搜尋會話';
	@override String get library => '庫';
	@override String get viewProfile => '查看個人資料';
	@override String get noRelatedFound => '未找到相關會話';
	@override String get tryOtherKeywords => '嘗試搜尋其他關鍵詞';
	@override String get searchFailed => '搜尋失敗';
	@override String get deleteConversation => '刪除對話';
	@override String get deleteConversationConfirm => '確定要刪除這個對話嗎？此操作無法撤回。';
	@override String get conversationDeleted => '對話已刪除';
	@override String get deleteConversationFailed => '刪除對話失敗';
	@override late final _Translations$chat$transferWizard$zh_Hant transferWizard = _Translations$chat$transferWizard$zh_Hant._(_root);
	@override late final _Translations$chat$genui$zh_Hant genui = _Translations$chat$genui$zh_Hant._(_root);
	@override late final _Translations$chat$welcome$zh_Hant welcome = _Translations$chat$welcome$zh_Hant._(_root);
}

// Path: footprint
class _Translations$footprint$zh_Hant extends Translations$footprint$zh {
	_Translations$footprint$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get searchIn => '搜尋';
	@override String get searchInAllRecords => '在所有記錄中搜尋相關內容';
}

// Path: media
class _Translations$media$zh_Hant extends Translations$media$zh {
	_Translations$media$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get selectPhotos => '選擇照片';
	@override String get addFiles => '添加文件';
	@override String get takePhoto => '拍照';
	@override String get camera => '相機';
	@override String get photos => '照片';
	@override String get files => '文件';
	@override String get showAll => '顯示全部';
	@override String get allPhotos => '所有照片';
	@override String get takingPhoto => '拍照中...';
	@override String get photoTaken => '照片已保存';
	@override String get cameraPermissionRequired => '需要相機權限';
	@override String get fileSizeExceeded => '文件大小超過 10MB 限制';
	@override String get unsupportedFormat => '不支持的文件格式';
	@override String get permissionDenied => '需要相冊訪問權限';
	@override String get storageInsufficient => '存儲空間不足';
	@override String get networkError => '網絡連接錯誤';
	@override String get unknownUploadError => '上傳時發生未知錯誤';
}

// Path: error
class _Translations$error$zh_Hant extends Translations$error$zh {
	_Translations$error$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get permissionRequired => '需要權限';
	@override String get permissionInstructions => '請在設置中開啟相冊和存儲權限，以便選擇和上傳文件。';
	@override String get openSettings => '打開設置';
	@override String get fileTooLarge => '文件過大';
	@override String get fileSizeHint => '請選擇小於 10MB 的文件，或者壓縮後再上傳。';
	@override String get supportedFormatsHint => '支持的格式包括：圖片 (jpg, png, gif 等)、文檔 (pdf, doc, txt 等)、音視頻文件等。';
	@override String get storageCleanupHint => '請清理設備存儲空間後重試，或選擇較小的文件。';
	@override String get networkErrorHint => '請檢查網絡連接是否正常，然後重試。';
	@override String get platformNotSupported => '平台不支持';
	@override String get fileReadError => '文件讀取失敗';
	@override String get fileReadErrorHint => '文件可能已損壞或被其他程序占用，請重新選擇文件。';
	@override String get validationError => '文件驗證失敗';
	@override String get unknownError => '未知錯誤';
	@override String get unknownErrorHint => '發生了意外錯誤，請重試或聯繫技術支持。';
	@override late final _Translations$error$genui$zh_Hant genui = _Translations$error$genui$zh_Hant._(_root);
}

// Path: fontTest
class _Translations$fontTest$zh_Hant extends Translations$fontTest$zh {
	_Translations$fontTest$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get page => '字體測試頁面';
	@override String get displayTest => '字體顯示測試';
	@override String get chineseTextTest => '中文文本測試';
	@override String get englishTextTest => '英文文本測試';
	@override String get sample1 => '這是一段中文文本，用於測試字體顯示效果。';
	@override String get sample2 => '支出分類彙總，購物最高';
	@override String get sample3 => '人工智能助手為您提供專業的財務分析服務';
	@override String get sample4 => '數據可視化圖表展示您的消費趨勢';
	@override String get sample5 => '微信支付、支付寶、銀行卡等多種支付方式';
}

// Path: wizard
class _Translations$wizard$zh_Hant extends Translations$wizard$zh {
	_Translations$wizard$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get nextStep => '下一步';
	@override String get previousStep => '上一步';
	@override String get completeMapping => '完成繪製';
}

// Path: user
class _Translations$user$zh_Hant extends Translations$user$zh {
	_Translations$user$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get username => '用戶名';
	@override String get defaultEmail => 'user@example.com';
}

// Path: account
class _Translations$account$zh_Hant extends Translations$account$zh {
	_Translations$account$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get editTitle => '編輯帳戶';
	@override String get addTitle => '新建帳戶';
	@override String get selectTypeTitle => '選擇帳戶類型';
	@override String get nameLabel => '帳戶名稱';
	@override String get amountLabel => '當前餘額';
	@override String get currencyLabel => '幣種';
	@override String get hiddenLabel => '隱藏';
	@override String get hiddenDesc => '在帳戶列表中隱藏該帳戶';
	@override String get includeInNetWorthLabel => '計入資產';
	@override String get includeInNetWorthDesc => '用於淨資產統計';
	@override String get nameHint => '例如：工資卡';
	@override String get amountHint => '0.00';
	@override String get deleteAccount => '刪除帳戶';
	@override String get deleteConfirm => '確定要刪除該帳戶嗎？此操作無法撤銷。';
	@override String get save => '保存修改';
	@override String get assetsCategory => '資產類';
	@override String get liabilitiesCategory => '負債/信用類';
	@override String get cash => '現金錢包';
	@override String get deposit => '銀行存款';
	@override String get creditCard => '信用卡';
	@override String get investment => '投資理財';
	@override String get eWallet => '電子錢包';
	@override String get loan => '貸款帳戶';
	@override String get receivable => '應收款項';
	@override String get payable => '應付款項';
	@override String get other => '其他帳戶';
	@override late final _Translations$account$types$zh_Hant types = _Translations$account$types$zh_Hant._(_root);
}

// Path: financial
class _Translations$financial$zh_Hant extends Translations$financial$zh {
	_Translations$financial$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => '財務';
	@override String get management => '財務管理';
	@override String get netWorth => '總淨值';
	@override String get assets => '總資產';
	@override String get liabilities => '總負債';
	@override String get noAccounts => '暫無帳戶';
	@override String get addFirstAccount => '點擊下方按鈕添加您的第一個帳戶';
	@override String get assetAccounts => '資產帳戶';
	@override String get liabilityAccounts => '負債帳戶';
	@override String get selectCurrency => '選擇貨幣';
	@override String get cancel => '取消';
	@override String get confirm => '確定';
	@override String get settings => '財務設置';
	@override String get budgetManagement => '預算管理';
	@override String get recurringTransactions => '週期交易';
	@override String get safetyThreshold => '安全閾值';
	@override String get dailyBurnRate => '每日消費';
	@override String get financialAssistant => '財務助手';
	@override String get manageFinancialSettings => '管理您的財務設置';
	@override String get safetyThresholdSettings => '財務安全線設置';
	@override String get setSafetyThreshold => '設置您的財務安全閾值';
	@override String get safetyThresholdSaved => '財務安全線已保存';
	@override String get dailyBurnRateSettings => '日常消費預估';
	@override String get setDailyBurnRate => '設置您的日常消費預估金額';
	@override String get dailyBurnRateSaved => '日常消費預估已保存';
	@override String get dayUnit => '天';
	@override String get saveFailed => '保存失敗';
}

// Path: app
class _Translations$app$zh_Hant extends Translations$app$zh {
	_Translations$app$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get splashTitle => '智見增長，格物致富。';
	@override String get splashSubtitle => '智能財務助手';
}

// Path: statistics
class _Translations$statistics$zh_Hant extends Translations$statistics$zh {
	_Translations$statistics$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => '統計分析';
	@override String get analyze => '統計分析';
	@override String get exportInProgress => '導出功能開發中...';
	@override String get ranking => '大額消費排行';
	@override String get noData => '暫無數據';
	@override late final _Translations$statistics$overview$zh_Hant overview = _Translations$statistics$overview$zh_Hant._(_root);
	@override late final _Translations$statistics$trend$zh_Hant trend = _Translations$statistics$trend$zh_Hant._(_root);
	@override late final _Translations$statistics$analysis$zh_Hant analysis = _Translations$statistics$analysis$zh_Hant._(_root);
	@override late final _Translations$statistics$filter$zh_Hant filter = _Translations$statistics$filter$zh_Hant._(_root);
	@override late final _Translations$statistics$sort$zh_Hant sort = _Translations$statistics$sort$zh_Hant._(_root);
	@override String get exportList => '導出列表';
	@override String get noMoreData => '沒有更多數據了';
	@override late final _Translations$statistics$emptyState$zh_Hant emptyState = _Translations$statistics$emptyState$zh_Hant._(_root);
}

// Path: currency
class _Translations$currency$zh_Hant extends Translations$currency$zh {
	_Translations$currency$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get cny => '人民幣';
	@override String get usd => '美元';
	@override String get eur => '歐元';
	@override String get jpy => '日元';
	@override String get gbp => '英鎊';
	@override String get aud => '澳元';
	@override String get cad => '加元';
	@override String get chf => '瑞士法郎';
	@override String get rub => '俄羅斯盧布';
	@override String get hkd => '港幣';
	@override String get twd => '新台幣';
	@override String get inr => '印度盧比';
}

// Path: sharedSpace
class _Translations$sharedSpace$zh_Hant extends Translations$sharedSpace$zh {
	_Translations$sharedSpace$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override late final _Translations$sharedSpace$dashboard$zh_Hant dashboard = _Translations$sharedSpace$dashboard$zh_Hant._(_root);
	@override late final _Translations$sharedSpace$roles$zh_Hant roles = _Translations$sharedSpace$roles$zh_Hant._(_root);
	@override String get title => '共享空間';
	@override late final _Translations$sharedSpace$create$zh_Hant create = _Translations$sharedSpace$create$zh_Hant._(_root);
	@override late final _Translations$sharedSpace$join$zh_Hant join = _Translations$sharedSpace$join$zh_Hant._(_root);
	@override late final _Translations$sharedSpace$list$zh_Hant list = _Translations$sharedSpace$list$zh_Hant._(_root);
	@override late final _Translations$sharedSpace$detail$zh_Hant detail = _Translations$sharedSpace$detail$zh_Hant._(_root);
	@override late final _Translations$sharedSpace$notifications$zh_Hant notifications = _Translations$sharedSpace$notifications$zh_Hant._(_root);
	@override late final _Translations$sharedSpace$inviteCard$zh_Hant inviteCard = _Translations$sharedSpace$inviteCard$zh_Hant._(_root);
	@override late final _Translations$sharedSpace$inviteSuccess$zh_Hant inviteSuccess = _Translations$sharedSpace$inviteSuccess$zh_Hant._(_root);
	@override late final _Translations$sharedSpace$notificationCard$zh_Hant notificationCard = _Translations$sharedSpace$notificationCard$zh_Hant._(_root);
	@override late final _Translations$sharedSpace$spaceCard$zh_Hant spaceCard = _Translations$sharedSpace$spaceCard$zh_Hant._(_root);
	@override late final _Translations$sharedSpace$settings$zh_Hant settings = _Translations$sharedSpace$settings$zh_Hant._(_root);
}

// Path: budgetSuggestion
class _Translations$budgetSuggestion$zh_Hant extends Translations$budgetSuggestion$zh {
	_Translations$budgetSuggestion$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String highPercentage({required Object category, required Object percentage}) => '${category} accounts for ${percentage}% of spending. Consider setting a budget limit.';
	@override String monthlyIncrease({required Object percentage}) => 'Spending increased by ${percentage}% this month. Needs attention.';
	@override String frequentSmall({required Object category, required Object count}) => '${category} has ${count} small transactions. These might be subscriptions.';
	@override String get financialInsights => 'Financial Insights';
}

// Path: server
class _Translations$server$zh_Hant extends Translations$server$zh {
	_Translations$server$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

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
	@override String get serverSettings => 'Server Settings';
	@override String get currentServer => 'Current Server';
	@override String get version => 'Version';
	@override String get environment => 'Environment';
	@override String get changeServer => 'Change Server';
	@override String get changeServerWarning => 'Changing server will log you out. Continue?';
	@override late final _Translations$server$error$zh_Hant error = _Translations$server$error$zh_Hant._(_root);
}

// Path: errorMapping
class _Translations$errorMapping$zh_Hant extends Translations$errorMapping$zh {
	_Translations$errorMapping$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override late final _Translations$errorMapping$generic$zh_Hant generic = _Translations$errorMapping$generic$zh_Hant._(_root);
	@override late final _Translations$errorMapping$auth$zh_Hant auth = _Translations$errorMapping$auth$zh_Hant._(_root);
	@override late final _Translations$errorMapping$transaction$zh_Hant transaction = _Translations$errorMapping$transaction$zh_Hant._(_root);
	@override late final _Translations$errorMapping$space$zh_Hant space = _Translations$errorMapping$space$zh_Hant._(_root);
	@override late final _Translations$errorMapping$recurring$zh_Hant recurring = _Translations$errorMapping$recurring$zh_Hant._(_root);
	@override late final _Translations$errorMapping$upload$zh_Hant upload = _Translations$errorMapping$upload$zh_Hant._(_root);
	@override late final _Translations$errorMapping$ai$zh_Hant ai = _Translations$errorMapping$ai$zh_Hant._(_root);
}

// Path: notification
class _Translations$notification$zh_Hant extends Translations$notification$zh {
	_Translations$notification$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => '訊息通知';
	@override String get markAllRead => '全部已讀';
	@override String get empty => '暫無通知訊息';
	@override String get loadFailed => '載入失敗';
	@override String get retry => '重試';
	@override String get justNow => '剛剛';
	@override String minutesAgo({required Object minutes}) => '${minutes}分鐘前';
	@override String hoursAgo({required Object hours}) => '${hours}小時前';
	@override String daysAgo({required Object days}) => '${days}天前';
	@override String get deleted => '已刪除';
	@override late final _Translations$notification$types$zh_Hant types = _Translations$notification$types$zh_Hant._(_root);
	@override late final _Translations$notification$semantic$zh_Hant semantic = _Translations$notification$semantic$zh_Hant._(_root);
}

// Path: auth.email
class _Translations$auth$email$zh_Hant extends Translations$auth$email$zh {
	_Translations$auth$email$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get label => '電子郵件';
	@override String get placeholder => '請輸入您的電子郵件';
	@override String get required => '電子郵件不能為空';
	@override String get invalid => '請輸入有效的電子郵件地址';
}

// Path: auth.password
class _Translations$auth$password$zh_Hant extends Translations$auth$password$zh {
	_Translations$auth$password$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get label => '密碼';
	@override String get placeholder => '請輸入您的密碼';
	@override String get required => '密碼不能為空';
	@override String get tooShort => '密碼長度不能少於 6 位';
	@override String get mustContainNumbersAndLetters => '密碼必須包含數字和字母';
	@override String get confirm => '確認密碼';
	@override String get confirmPlaceholder => '請再次輸入您的密碼';
	@override String get mismatch => '兩次輸入的密碼不一致';
}

// Path: auth.verificationCode
class _Translations$auth$verificationCode$zh_Hant extends Translations$auth$verificationCode$zh {
	_Translations$auth$verificationCode$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get label => '驗證碼';
	@override String get get => '獲取驗證碼';
	@override String get sending => '發送中...';
	@override String get sent => '驗證碼已發送';
	@override String get sendFailed => '發送失敗';
	@override String get placeholder => '請輸入驗證碼';
	@override String get required => '驗證碼不能為空';
}

// Path: calendar.weekdays
class _Translations$calendar$weekdays$zh_Hant extends Translations$calendar$weekdays$zh {
	_Translations$calendar$weekdays$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get mon => '一';
	@override String get tue => '二';
	@override String get wed => '三';
	@override String get thu => '四';
	@override String get fri => '五';
	@override String get sat => '六';
	@override String get sun => '日';
}

// Path: appearance.palettes
class _Translations$appearance$palettes$zh_Hant extends Translations$appearance$palettes$zh {
	_Translations$appearance$palettes$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

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
class _Translations$forecast$recurringTransaction$zh_Hant extends Translations$forecast$recurringTransaction$zh {
	_Translations$forecast$recurringTransaction$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => '週期交易';
	@override String get all => '全部';
	@override String get expense => '支出';
	@override String get income => '收入';
	@override String get transfer => '轉帳';
	@override String get noRecurring => '暫無週期交易';
	@override String get createHint => '創建週期交易後，系統將自動為您生成交易記錄';
	@override String get create => '創建週期交易';
	@override String get edit => '編輯週期交易';
	@override String get newTransaction => '新建週期交易';
	@override String deleteConfirm({required Object name}) => '確定要刪除週期交易「${name}」嗎？此操作不可撤銷。';
	@override String activateConfirm({required Object name}) => '確定要啟用週期交易「${name}」嗎？啟用後將按照設定的規則自動生成交易記錄。';
	@override String pauseConfirm({required Object name}) => '確定要暫停週期交易「${name}」嗎？暫停後將不再自動生成交易記錄。';
	@override String get created => '週期交易已創建';
	@override String get updated => '週期交易已更新';
	@override String get activated => '已啟用';
	@override String get paused => '已暫停';
	@override String get nextTime => '下次';
	@override String get sortByTime => '按時間排序';
	@override String get allPeriod => '全部週期';
	@override String periodCount({required Object type, required Object count}) => '${type}週期 (${count})';
	@override String get confirmDelete => '確認刪除';
	@override String get confirmActivate => '確認啟用';
	@override String get confirmPause => '確認暫停';
	@override String get dynamicAmount => '動態均值';
	@override String get dynamicAmountTitle => '金額需手動確認';
	@override String get dynamicAmountDescription => '系統將在帳單日發送提醒，需要您手動確認具體金額後才會記帳。';
	@override String get confirmBeforeGeneration => '生成前需確認';
	@override String get confirmBeforeGenerationDesc => '到期時生成待確認交易，需手動確認後記帳';
	@override String get pendingTitle => '待確認交易';
	@override String pendingCount({required Object count}) => '${count} 筆待確認';
	@override String get confirm => '確認';
	@override String get skip => '跳過';
	@override String get noPending => '無待確認交易';
	@override String get confirmSuccess => '已確認記帳';
	@override String get skipSuccess => '已跳過';
}

// Path: chat.tools
class _Translations$chat$tools$zh_Hant extends Translations$chat$tools$zh {
	_Translations$chat$tools$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get processing => '正在處理...';
	@override String get readFile => '正在查看文件...';
	@override String get searchTransactions => '正在查詢交易...';
	@override String get queryBudgetStatus => '正在檢查預算...';
	@override String get createBudget => '正在創建預算計劃...';
	@override String get getCashFlowAnalysis => '正在分析現金流...';
	@override String get getFinancialHealthScore => '正在計算財務健康分...';
	@override String get getFinancialSummary => '正在生成財務報告...';
	@override String get evaluateFinancialHealth => '正在評估財務健康...';
	@override String get forecastBalance => '正在預測未來餘額...';
	@override String get simulateExpenseImpact => '正在模擬購買影響...';
	@override String get recordTransactions => '正在記帳...';
	@override String get createTransaction => '正在記帳...';
	@override String get duckduckgoSearch => '正在搜尋網絡...';
	@override String get executeTransfer => '正在執行轉帳...';
	@override String get listDir => '正在瀏覽目錄...';
	@override String get execute => '正在執行腳本...';
	@override String get analyzeFinance => '正在分析財務狀況...';
	@override String get forecastFinance => '正在預測財務趨勢...';
	@override String get analyzeBudget => '正在分析預算...';
	@override String get auditAnalysis => '正在審計分析...';
	@override String get budgetOps => '正在處理預算...';
	@override String get createSharedTransaction => '正在創建共享帳單...';
	@override String get listSpaces => '正在獲取共享空間...';
	@override String get querySpaceSummary => '正在查詢空間摘要...';
	@override String get prepareTransfer => '正在準備轉帳...';
	@override String get unknown => '正在處理請求...';
	@override late final _Translations$chat$tools$done$zh_Hant done = _Translations$chat$tools$done$zh_Hant._(_root);
	@override late final _Translations$chat$tools$failed$zh_Hant failed = _Translations$chat$tools$failed$zh_Hant._(_root);
	@override String get analyzeSpending => 'Analyzing spendings...';
	@override String get analyzeCashflow => 'Analyzing cashflow...';
	@override String get suggestBudget => 'Suggesting budget...';
	@override String get cancelled => 'Cancelled';
	@override String get prepareBudgetSimulation => '正在準備預算模擬';
	@override String get simulateBudget => '正在模擬預算';
}

// Path: chat.transferWizard
class _Translations$chat$transferWizard$zh_Hant extends Translations$chat$transferWizard$zh {
	_Translations$chat$transferWizard$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => '轉帳向導';
	@override String get amount => '轉帳金額';
	@override String get amountHint => '請輸入金額';
	@override String get sourceAccount => '轉出帳戶';
	@override String get targetAccount => '轉入帳戶';
	@override String get selectAccount => '請選擇帳戶';
	@override String get confirmTransfer => '確認轉帳';
	@override String get confirmed => '已確認';
	@override String get transferSuccess => '轉帳成功';
	@override String get selectReceiveAccount => '选择收款账户';
}

// Path: chat.genui
class _Translations$chat$genui$zh_Hant extends Translations$chat$genui$zh {
	_Translations$chat$genui$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override late final _Translations$chat$genui$expenseSummary$zh_Hant expenseSummary = _Translations$chat$genui$expenseSummary$zh_Hant._(_root);
	@override late final _Translations$chat$genui$transactionList$zh_Hant transactionList = _Translations$chat$genui$transactionList$zh_Hant._(_root);
	@override late final _Translations$chat$genui$transactionGroupReceipt$zh_Hant transactionGroupReceipt = _Translations$chat$genui$transactionGroupReceipt$zh_Hant._(_root);
	@override late final _Translations$chat$genui$transactionCard$zh_Hant transactionCard = _Translations$chat$genui$transactionCard$zh_Hant._(_root);
	@override late final _Translations$chat$genui$cashFlowCard$zh_Hant cashFlowCard = _Translations$chat$genui$cashFlowCard$zh_Hant._(_root);
	@override late final _Translations$chat$genui$budgetSimulator$zh_Hant budgetSimulator = _Translations$chat$genui$budgetSimulator$zh_Hant._(_root);
	@override late final _Translations$chat$genui$budgetReceipt$zh_Hant budgetReceipt = _Translations$chat$genui$budgetReceipt$zh_Hant._(_root);
	@override late final _Translations$chat$genui$budgetStatusCard$zh_Hant budgetStatusCard = _Translations$chat$genui$budgetStatusCard$zh_Hant._(_root);
	@override late final _Translations$chat$genui$cashFlowForecast$zh_Hant cashFlowForecast = _Translations$chat$genui$cashFlowForecast$zh_Hant._(_root);
	@override late final _Translations$chat$genui$healthScore$zh_Hant healthScore = _Translations$chat$genui$healthScore$zh_Hant._(_root);
	@override late final _Translations$chat$genui$spaceSelector$zh_Hant spaceSelector = _Translations$chat$genui$spaceSelector$zh_Hant._(_root);
	@override late final _Translations$chat$genui$transferPath$zh_Hant transferPath = _Translations$chat$genui$transferPath$zh_Hant._(_root);
	@override late final _Translations$chat$genui$transactionConfirmation$zh_Hant transactionConfirmation = _Translations$chat$genui$transactionConfirmation$zh_Hant._(_root);
	@override late final _Translations$chat$genui$budgetAnalysis$zh_Hant budgetAnalysis = _Translations$chat$genui$budgetAnalysis$zh_Hant._(_root);
}

// Path: chat.welcome
class _Translations$chat$welcome$zh_Hant extends Translations$chat$welcome$zh {
	_Translations$chat$welcome$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override late final _Translations$chat$welcome$morning$zh_Hant morning = _Translations$chat$welcome$morning$zh_Hant._(_root);
	@override late final _Translations$chat$welcome$midday$zh_Hant midday = _Translations$chat$welcome$midday$zh_Hant._(_root);
	@override late final _Translations$chat$welcome$afternoon$zh_Hant afternoon = _Translations$chat$welcome$afternoon$zh_Hant._(_root);
	@override late final _Translations$chat$welcome$evening$zh_Hant evening = _Translations$chat$welcome$evening$zh_Hant._(_root);
	@override late final _Translations$chat$welcome$night$zh_Hant night = _Translations$chat$welcome$night$zh_Hant._(_root);
}

// Path: error.genui
class _Translations$error$genui$zh_Hant extends Translations$error$genui$zh {
	_Translations$error$genui$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get loadingFailed => '組件載入失敗';
	@override String get schemaFailed => '架構驗證失敗';
	@override String get schemaDescription => '組件定義不符合 GenUI 規範，降級為純文本顯示';
	@override String get networkError => '網絡錯誤';
	@override String retryStatus({required Object retryCount, required Object maxRetries}) => '已重試 ${retryCount}/${maxRetries} 次';
	@override String get maxRetriesReached => '已達最大重試次數';
}

// Path: account.types
class _Translations$account$types$zh_Hant extends Translations$account$types$zh {
	_Translations$account$types$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

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
class _Translations$statistics$overview$zh_Hant extends Translations$statistics$overview$zh {
	_Translations$statistics$overview$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get balance => '總結餘';
	@override String get income => '總收入';
	@override String get expense => '總支出';
}

// Path: statistics.trend
class _Translations$statistics$trend$zh_Hant extends Translations$statistics$trend$zh {
	_Translations$statistics$trend$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => '收支趨勢';
	@override String get expense => '支出';
	@override String get income => '收入';
}

// Path: statistics.analysis
class _Translations$statistics$analysis$zh_Hant extends Translations$statistics$analysis$zh {
	_Translations$statistics$analysis$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => '支出分析';
	@override String get total => '總計';
	@override String get breakdown => '支出分類明細';
}

// Path: statistics.filter
class _Translations$statistics$filter$zh_Hant extends Translations$statistics$filter$zh {
	_Translations$statistics$filter$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get accountType => '帳戶類型';
	@override String get allAccounts => '全部帳戶';
	@override String get apply => '確認應用';
}

// Path: statistics.sort
class _Translations$statistics$sort$zh_Hant extends Translations$statistics$sort$zh {
	_Translations$statistics$sort$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get amount => '按金額排序';
	@override String get date => '按時間排序';
}

// Path: statistics.emptyState
class _Translations$statistics$emptyState$zh_Hant extends Translations$statistics$emptyState$zh {
	_Translations$statistics$emptyState$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => 'Unlock Financial Insights';
	@override String get description => 'Your financial report is currently a blank canvas.\nRecord your first transaction and let the data tell your story.';
	@override String get action => 'Record First Transaction';
}

// Path: sharedSpace.dashboard
class _Translations$sharedSpace$dashboard$zh_Hant extends Translations$sharedSpace$dashboard$zh {
	_Translations$sharedSpace$dashboard$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get sectionTitle => '財務概覽';
	@override String get cumulativeTotalExpense => '累計總支出';
	@override String get participatingMembers => '參與成員';
	@override String membersCount({required Object count}) => '${count} 人';
	@override String get averagePerMember => '成員人均';
	@override String get spendingDistribution => '成員消費分佈';
	@override String get realtimeUpdates => '實時更新';
	@override String get paid => '已支付';
}

// Path: sharedSpace.roles
class _Translations$sharedSpace$roles$zh_Hant extends Translations$sharedSpace$roles$zh {
	_Translations$sharedSpace$roles$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get owner => '主理人';
	@override String get admin => '管理員';
	@override String get member => '成員';
}

// Path: sharedSpace.create
class _Translations$sharedSpace$create$zh_Hant extends Translations$sharedSpace$create$zh {
	_Translations$sharedSpace$create$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => '建立共享空間';
	@override String get subtitle => '建立一個新的共享空間，與朋友一起記帳';
	@override String get nameLabel => '空間名稱';
	@override String get nameHint => '例如：畢業旅行';
	@override String get descLabel => '描述（選填）';
	@override String get descHint => '記錄我們的共同旅行開銷';
	@override String get cancel => '取消';
	@override String get submit => '建立';
	@override String get nameRequired => '請輸入空間名稱';
	@override String get nameTooShort => '空間名稱至少需要 2 個字元';
	@override String get nameTooLong => '空間名稱不能超過 50 個字元';
}

// Path: sharedSpace.join
class _Translations$sharedSpace$join$zh_Hant extends Translations$sharedSpace$join$zh {
	_Translations$sharedSpace$join$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => '加入共享空間';
	@override String get subtitle => '輸入朋友分享的邀請碼，開始協作記帳';
	@override String get codeLabel => '邀請碼';
	@override String get codeHint => '輸入邀請碼，例如：123456';
	@override String get cancel => '取消';
	@override String get submit => '加入';
	@override String get codeRequired => '請輸入邀請碼';
	@override String get codeInvalid => '邀請碼格式無效';
	@override String get codeFormat => '邀請碼只能包含字母和數字';
}

// Path: sharedSpace.list
class _Translations$sharedSpace$list$zh_Hant extends Translations$sharedSpace$list$zh {
	_Translations$sharedSpace$list$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get emptyTitle => '開啟多方協同的財務空間';
	@override String get emptySubtitle => '建立或加入共享空間，與家人、夥伴或團隊協同管理共享帳目與資產';
	@override String get getStarted => '開始使用';
	@override String get hasInviteCode => '有邀請碼？點擊加入';
	@override String joinedSuccess({required Object name}) => '成功加入「${name}」！';
}

// Path: sharedSpace.detail
class _Translations$sharedSpace$detail$zh_Hant extends Translations$sharedSpace$detail$zh {
	_Translations$sharedSpace$detail$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get members => '成員';
	@override String get transactions => '交易紀錄';
	@override String recordsCount({required Object count}) => '${count} 筆';
	@override String get settlement => '結算';
	@override String get inviteCode => '邀請碼';
	@override String get copyCode => '複製邀請碼';
	@override String codeCopied({required Object code}) => '邀請碼已複製：${code}';
	@override String get validFor24h => '24 小時內有效';
	@override String get leaveSpace => '退出空間';
	@override String get deleteSpace => '刪除空間';
	@override String get removeMember => '移除成員';
	@override String get leaveConfirm => '確定要退出此共享空間嗎？退出後將無法查看空間內的交易紀錄。';
	@override String get deleteConfirm => '確定要刪除此共享空間嗎？此操作不可撤銷，所有成員將被移出。';
	@override String get removeConfirm => '確定要將此成員移出共享空間嗎？';
	@override String get generatingCode => '正在產生邀請碼...';
	@override String get loadFailed => '載入失敗';
	@override String get retry => '重試';
	@override String get noTransactions => '暫無交易紀錄';
	@override String get noTransactionsHint => '空間內的交易將顯示在這裡';
	@override String get refreshCode => '重新產生新碼';
	@override String get joinOtherSpace => '加入其他空間';
}

// Path: sharedSpace.notifications
class _Translations$sharedSpace$notifications$zh_Hant extends Translations$sharedSpace$notifications$zh {
	_Translations$sharedSpace$notifications$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => '通知';
	@override String get empty => '暫無通知';
	@override String get emptyHint => '當你收到新的邀請或動態時，\n通知將顯示在這裡';
	@override String get incompleteInfo => '邀請資訊不完整';
	@override String get inviteAccepted => '已接受邀請！';
	@override String get inviteRejected => '已拒絕邀請';
	@override String get allMarkedRead => '全部標記為已讀';
}

// Path: sharedSpace.inviteCard
class _Translations$sharedSpace$inviteCard$zh_Hant extends Translations$sharedSpace$inviteCard$zh {
	_Translations$sharedSpace$inviteCard$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => '邀請碼';
	@override String get subtitle => '分享給朋友以加入空間';
	@override String get copyCode => '複製邀請碼';
	@override String get shareLink => '分享邀請連結';
	@override String get codeCopied => '邀請碼已複製';
	@override String get noExpiry => '無有效期限制';
	@override String get expired => '已過期';
	@override String expiresInDays({required Object days}) => '${days} 天後過期';
	@override String expiresInHours({required Object hours}) => '${hours} 小時後過期';
	@override String expiresInMinutes({required Object minutes}) => '${minutes} 分鐘後過期';
	@override String get expiringSoon => '即將過期';
	@override String shareText({required Object spaceName, required Object code, required Object link, required Object expiry}) => '邀請你加入共享空間「${spaceName}」\n\n邀請碼：${code}\n或點擊連結直接加入：${link}\n\n邀請碼${expiry}';
}

// Path: sharedSpace.inviteSuccess
class _Translations$sharedSpace$inviteSuccess$zh_Hant extends Translations$sharedSpace$inviteSuccess$zh {
	_Translations$sharedSpace$inviteSuccess$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => '建立成功';
	@override String get subtitle => '共享空間建立成功';
	@override String get inviteLater => '稍後邀請';
	@override String get enterSpace => '進入空間';
	@override String get generatingCode => '正在產生邀請碼...';
	@override String get generateFailed => '邀請碼產生失敗';
	@override String get codeCopied => '邀請碼已複製';
	@override String get retry => '重試';
	@override String get codeLabel => '邀請碼';
	@override String get validHint => '24 小時內有效 · 點擊複製';
}

// Path: sharedSpace.notificationCard
class _Translations$sharedSpace$notificationCard$zh_Hant extends Translations$sharedSpace$notificationCard$zh {
	_Translations$sharedSpace$notificationCard$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get accept => '接受';
	@override String get reject => '拒絕';
	@override String get unknownTime => '未知時間';
	@override String get justNow => '剛剛';
}

// Path: sharedSpace.spaceCard
class _Translations$sharedSpace$spaceCard$zh_Hant extends Translations$sharedSpace$spaceCard$zh {
	_Translations$sharedSpace$spaceCard$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get noDescription => '暫無描述';
	@override String get creator => '建立者';
	@override String get member => '成員';
	@override String membersCount({required Object count}) => '${count} 位成員';
	@override String transactionsCount({required Object count}) => '${count} 筆帳單';
}

// Path: sharedSpace.settings
class _Translations$sharedSpace$settings$zh_Hant extends Translations$sharedSpace$settings$zh {
	_Translations$sharedSpace$settings$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => '空間設定';
	@override String get spaceInfo => '空間資訊';
	@override String get nameLabel => '空間名稱';
	@override String get descLabel => '空間描述';
	@override String get save => '儲存';
	@override String get saved => '儲存成功';
	@override String get saveFailed => '儲存失敗';
	@override String get memberManagement => '成員管理';
	@override String membersCount({required Object count}) => '${count} 位成員';
	@override String removeMemberConfirm({required Object name}) => '確定要將「${name}」移出空間嗎？';
	@override String get removed => '已移除成員';
	@override String get removeFailed => '移除失敗';
	@override String get inviteManagement => '邀請管理';
	@override String get currentCode => '目前邀請碼';
	@override String get generateNew => '產生新邀請碼';
	@override String get noValidCode => '暫無有效邀請碼';
	@override String get refreshCode => '重新產生新碼';
	@override String get refreshConfirm => '產生新碼將使舊邀請碼失效，確定繼續？';
	@override String get codeRefreshed => '邀請碼已重新整理';
	@override String get dangerZone => '危險操作';
	@override String get editHint => '僅管理員可編輯';
	@override String get edit => '編輯';
	@override String get you => '我';
	@override String get pending => '待接受';
	@override String get declined => '已拒絕';
	@override String get setAsAdmin => '設為管理員';
	@override String get setAsMember => '設為普通成員';
	@override String get changeRole => '變更角色';
	@override String changeRoleConfirm({required Object name, required Object role}) => '確定要將「${name}」的角色變更為「${role}」嗎？';
	@override String get confirm => '確認';
	@override String get roleChanged => '角色已變更';
	@override String get roleChangeFailed => '角色變更失敗';
}

// Path: server.error
class _Translations$server$error$zh_Hant extends Translations$server$error$zh {
	_Translations$server$error$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get urlRequired => 'Server address is required';
	@override String get invalidUrl => 'Invalid URL format';
	@override String get connectionTimeout => 'Connection timed out';
	@override String get connectionRefused => 'Could not connect to server';
	@override String get sslError => 'SSL certificate error';
	@override String get serverError => 'Server error';
}

// Path: errorMapping.generic
class _Translations$errorMapping$generic$zh_Hant extends Translations$errorMapping$generic$zh {
	_Translations$errorMapping$generic$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

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
class _Translations$errorMapping$auth$zh_Hant extends Translations$errorMapping$auth$zh {
	_Translations$errorMapping$auth$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

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
class _Translations$errorMapping$transaction$zh_Hant extends Translations$errorMapping$transaction$zh {
	_Translations$errorMapping$transaction$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get commentEmpty => 'Comment content cannot be empty';
	@override String get invalidParent => 'Invalid parent comment ID';
	@override String get saveFailed => 'Failed to save comment';
	@override String get deleteFailed => 'Failed to delete comment';
	@override String get notExists => 'Transaction does not exist';
}

// Path: errorMapping.space
class _Translations$errorMapping$space$zh_Hant extends Translations$errorMapping$space$zh {
	_Translations$errorMapping$space$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

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
}

// Path: errorMapping.recurring
class _Translations$errorMapping$recurring$zh_Hant extends Translations$errorMapping$recurring$zh {
	_Translations$errorMapping$recurring$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get invalidRule => 'Invalid recurrence rule';
	@override String get ruleNotFound => 'Recurrence rule not found';
}

// Path: errorMapping.upload
class _Translations$errorMapping$upload$zh_Hant extends Translations$errorMapping$upload$zh {
	_Translations$errorMapping$upload$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get noFile => 'No file uploaded';
	@override String get tooLarge => 'File too large';
	@override String get unsupportedType => 'Unsupported file type';
	@override String get tooManyFiles => 'Too many files';
}

// Path: errorMapping.ai
class _Translations$errorMapping$ai$zh_Hant extends Translations$errorMapping$ai$zh {
	_Translations$errorMapping$ai$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get contextLimit => 'Context limit exceeded';
	@override String get tokenLimit => 'Insufficient tokens';
	@override String get emptyMessage => 'Empty user message';
}

// Path: notification.types
class _Translations$notification$types$zh_Hant extends Translations$notification$types$zh {
	_Translations$notification$types$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get system => '系統通知';
	@override String get spaceInvite => '空間邀請';
	@override String get spaceActivity => '空間動態';
	@override String get billComment => '帳單評論';
	@override String get budgetAlert => '預算提醒';
	@override String get transaction => '交易通知';
}

// Path: notification.semantic
class _Translations$notification$semantic$zh_Hant extends Translations$notification$semantic$zh {
	_Translations$notification$semantic$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String memberJoined({required Object name}) => '${name} 加入了你的空間';
	@override String memberJoinedDetail({required Object space}) => '新成員加入了「${space}」';
	@override String welcome({required Object space}) => '歡迎加入「${space}」';
	@override String newTransaction({required Object name}) => '${name} 記錄了一筆新帳單';
	@override String newTransactionDetail({required Object amount, required Object space}) => '${amount}，來自「${space}」';
	@override String memberLeft({required Object name}) => '${name} 離開了空間';
	@override String get recurringPending => '週期交易待確認';
	@override String recurringPendingDetail({required Object description, required Object amount}) => '${description} ${amount}，等待您確認記帳';
}

// Path: chat.tools.done
class _Translations$chat$tools$done$zh_Hant extends Translations$chat$tools$done$zh {
	_Translations$chat$tools$done$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get readFile => '已查看文件';
	@override String get searchTransactions => '已查詢交易';
	@override String get queryBudgetStatus => '已檢查預算';
	@override String get createBudget => '已創建預算';
	@override String get getCashFlowAnalysis => '已分析現金流';
	@override String get getFinancialHealthScore => '已計算健康分';
	@override String get getFinancialSummary => '財務報告生成完成';
	@override String get evaluateFinancialHealth => '財務健康評估完成';
	@override String get forecastBalance => '餘額預測完成';
	@override String get simulateExpenseImpact => '購買影響模擬完成';
	@override String get recordTransactions => '記帳完成';
	@override String get createTransaction => '已完成記帳';
	@override String get duckduckgoSearch => '已搜尋網絡';
	@override String get executeTransfer => '轉帳完成';
	@override String get listDir => '已瀏覽目錄';
	@override String get execute => '腳本執行完成';
	@override String get analyzeFinance => '財務分析完成';
	@override String get forecastFinance => '財務預測完成';
	@override String get analyzeBudget => '預算分析完成';
	@override String get auditAnalysis => '審計分析完成';
	@override String get budgetOps => '預算處理完成';
	@override String get createSharedTransaction => '共享帳單創建完成';
	@override String get listSpaces => '共享空間獲取完成';
	@override String get querySpaceSummary => '空間摘要查詢完成';
	@override String get prepareTransfer => '轉帳準備完成';
	@override String get unknown => '處理完成';
	@override String get analyzeSpending => 'Spending analysis complete';
	@override String get analyzeCashflow => 'Cashflow analysis complete';
	@override String get suggestBudget => 'Budget suggestion complete';
	@override String get prepareBudgetSimulation => '預算模擬準備完成';
	@override String get simulateBudget => '預算模擬完成';
}

// Path: chat.tools.failed
class _Translations$chat$tools$failed$zh_Hant extends Translations$chat$tools$failed$zh {
	_Translations$chat$tools$failed$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get unknown => '操作失敗';
}

// Path: chat.genui.expenseSummary
class _Translations$chat$genui$expenseSummary$zh_Hant extends Translations$chat$genui$expenseSummary$zh {
	_Translations$chat$genui$expenseSummary$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get totalExpense => '總支出';
	@override String get mainExpenses => '主要支出';
	@override String viewAll({required Object count}) => '查看全部 ${count} 筆消費';
	@override String get details => '消費明細';
}

// Path: chat.genui.transactionList
class _Translations$chat$genui$transactionList$zh_Hant extends Translations$chat$genui$transactionList$zh {
	_Translations$chat$genui$transactionList$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String searchResults({required Object count}) => '搜尋結果 (${count})';
	@override String loaded({required Object count}) => '已載入 ${count}';
	@override String get noResults => '未找到相關交易';
	@override String get loadMore => '滾動載入更多';
	@override String get allLoaded => '全部載入完成';
}

// Path: chat.genui.transactionGroupReceipt
class _Translations$chat$genui$transactionGroupReceipt$zh_Hant extends Translations$chat$genui$transactionGroupReceipt$zh {
	_Translations$chat$genui$transactionGroupReceipt$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => '記帳成功';
	@override String count({required Object count}) => '${count}筆';
	@override String get selectAccount => '選擇關聯帳戶';
	@override String get selectAccountSubtitle => '此帳戶將應用到以上所有筆交易';
	@override String associatedAccount({required Object name}) => '已關聯帳戶：${name}';
	@override String get clickToAssociate => '點擊關聯帳戶（支持批量操作）';
	@override String get associateSuccess => '已成功為所有交易關聯帳戶';
	@override String associateFailed({required Object error}) => '操作失敗: ${error}';
	@override String get accountAssociation => '帳戶關聯';
	@override String get sharedSpace => '共享空間';
	@override String get notAssociated => '未關聯';
	@override String get addSpace => '添加';
	@override String get selectSpace => '選擇共享空間';
	@override String get spaceAssociateSuccess => '已關聯到共享空間';
	@override String spaceAssociateFailed({required Object error}) => '關聯共享空間失敗: ${error}';
	@override String get currencyMismatchTitle => '幣種不一致';
	@override String get currencyMismatchDesc => '交易幣種與帳戶幣種不同，系統將按當時匯率換算後扣減帳戶餘額。';
	@override String get transactionAmount => '交易金額';
	@override String get accountCurrency => '帳戶幣種';
	@override String get targetAccount => '目標帳戶';
	@override String get currencyMismatchNote => '提示：帳戶餘額將按當時匯率進行換算扣減';
	@override String get confirmAssociate => '確認關聯';
	@override String get total => 'Total';
	@override String spaceCount({required Object count}) => '${count} spaces';
}

// Path: chat.genui.transactionCard
class _Translations$chat$genui$transactionCard$zh_Hant extends Translations$chat$genui$transactionCard$zh {
	_Translations$chat$genui$transactionCard$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => '交易成功';
	@override String get associatedAccount => '已關聯帳戶';
	@override String get notCounted => '不計入資產';
	@override String get modify => '修改';
	@override String get associate => '關聯帳戶';
	@override String get selectAccount => '選擇關聯帳戶';
	@override String get noAccount => '暫無可用帳戶，請先添加帳戶';
	@override String get missingId => '交易 ID 缺失，無法更新';
	@override String associatedTo({required Object name}) => '已關聯到 ${name}';
	@override String updateFailed({required Object error}) => '更新失敗: ${error}';
	@override String get sharedSpace => 'Shared Space';
	@override String get noSpace => 'No shared spaces available';
	@override String get selectSpace => 'Select Shared Space';
	@override String get linkedToSpace => 'Linked to shared space';
}

// Path: chat.genui.cashFlowCard
class _Translations$chat$genui$cashFlowCard$zh_Hant extends Translations$chat$genui$cashFlowCard$zh {
	_Translations$chat$genui$cashFlowCard$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => '現金流分析';
	@override String savingsRate({required Object rate}) => '儲蓄 ${rate}%';
	@override String get totalIncome => '總收入';
	@override String get totalExpense => '總支出';
	@override String get essentialExpense => '必要支出';
	@override String get discretionaryExpense => '可選消費';
	@override String get aiInsight => 'AI 分析';
}

// Path: chat.genui.budgetSimulator
class _Translations$chat$genui$budgetSimulator$zh_Hant extends Translations$chat$genui$budgetSimulator$zh {
	_Translations$chat$genui$budgetSimulator$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

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

// Path: chat.genui.budgetReceipt
class _Translations$chat$genui$budgetReceipt$zh_Hant extends Translations$chat$genui$budgetReceipt$zh {
	_Translations$chat$genui$budgetReceipt$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get newBudget => 'New Budget';
	@override String get budgetCreated => 'Budget Created';
	@override String get rolloverBudget => 'Rollover Budget';
	@override String get createFailed => 'Failed to create budget';
	@override String get thisMonth => 'This Month';
	@override String dateRange({required Object start, required Object startDay, required Object end, required Object endDay}) => '${start}/${startDay} - ${end}/${endDay}';
}

// Path: chat.genui.budgetStatusCard
class _Translations$chat$genui$budgetStatusCard$zh_Hant extends Translations$chat$genui$budgetStatusCard$zh {
	_Translations$chat$genui$budgetStatusCard$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

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
class _Translations$chat$genui$cashFlowForecast$zh_Hant extends Translations$chat$genui$cashFlowForecast$zh {
	_Translations$chat$genui$cashFlowForecast$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

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
class _Translations$chat$genui$healthScore$zh_Hant extends Translations$chat$genui$healthScore$zh {
	_Translations$chat$genui$healthScore$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => 'Financial Health';
	@override String get suggestions => 'Suggestions';
	@override String scorePoint({required Object score}) => '${score} pts';
	@override late final _Translations$chat$genui$healthScore$status$zh_Hant status = _Translations$chat$genui$healthScore$status$zh_Hant._(_root);
}

// Path: chat.genui.spaceSelector
class _Translations$chat$genui$spaceSelector$zh_Hant extends Translations$chat$genui$spaceSelector$zh {
	_Translations$chat$genui$spaceSelector$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get selected => 'Selected';
	@override String get unnamedSpace => 'Unnamed Space';
	@override String get linked => 'Linked';
	@override String get roleOwner => 'Owner';
	@override String get roleAdmin => 'Admin';
	@override String get roleMember => 'Member';
}

// Path: chat.genui.transferPath
class _Translations$chat$genui$transferPath$zh_Hant extends Translations$chat$genui$transferPath$zh {
	_Translations$chat$genui$transferPath$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

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
}

// Path: chat.genui.transactionConfirmation
class _Translations$chat$genui$transactionConfirmation$zh_Hant extends Translations$chat$genui$transactionConfirmation$zh {
	_Translations$chat$genui$transactionConfirmation$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get multipleAccounts => '检测到多个关联账户';
	@override String get confirmed => '已确认';
}

// Path: chat.genui.budgetAnalysis
class _Translations$chat$genui$budgetAnalysis$zh_Hant extends Translations$chat$genui$budgetAnalysis$zh {
	_Translations$chat$genui$budgetAnalysis$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => '预算分析报告';
	@override String periodDays({required Object days}) => '过去 ${days} 天';
	@override String get totalExpense => '总支出';
	@override String momChange({required Object change}) => '环比 ${change}%';
	@override String get categoryDistribution => '分类占比';
	@override String get topSpenders => '大额支出';
	@override String amountWan({required Object amount}) => '${amount}万';
}

// Path: chat.welcome.morning
class _Translations$chat$welcome$morning$zh_Hant extends Translations$chat$welcome$morning$zh {
	_Translations$chat$welcome$morning$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get subtitle => 'Start your day by tracking';
	@override late final _Translations$chat$welcome$morning$breakfast$zh_Hant breakfast = _Translations$chat$welcome$morning$breakfast$zh_Hant._(_root);
	@override late final _Translations$chat$welcome$morning$yesterdayReview$zh_Hant yesterdayReview = _Translations$chat$welcome$morning$yesterdayReview$zh_Hant._(_root);
	@override late final _Translations$chat$welcome$morning$todayBudget$zh_Hant todayBudget = _Translations$chat$welcome$morning$todayBudget$zh_Hant._(_root);
}

// Path: chat.welcome.midday
class _Translations$chat$welcome$midday$zh_Hant extends Translations$chat$welcome$midday$zh {
	_Translations$chat$welcome$midday$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get greeting => 'Good Afternoon';
	@override String get subtitle => 'Quick record during lunch';
	@override late final _Translations$chat$welcome$midday$lunch$zh_Hant lunch = _Translations$chat$welcome$midday$lunch$zh_Hant._(_root);
	@override late final _Translations$chat$welcome$midday$weeklyExpense$zh_Hant weeklyExpense = _Translations$chat$welcome$midday$weeklyExpense$zh_Hant._(_root);
	@override late final _Translations$chat$welcome$midday$checkBalance$zh_Hant checkBalance = _Translations$chat$welcome$midday$checkBalance$zh_Hant._(_root);
}

// Path: chat.welcome.afternoon
class _Translations$chat$welcome$afternoon$zh_Hant extends Translations$chat$welcome$afternoon$zh {
	_Translations$chat$welcome$afternoon$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get subtitle => 'Tea time, let\'s review finances';
	@override late final _Translations$chat$welcome$afternoon$quickRecord$zh_Hant quickRecord = _Translations$chat$welcome$afternoon$quickRecord$zh_Hant._(_root);
	@override late final _Translations$chat$welcome$afternoon$analyzeSpending$zh_Hant analyzeSpending = _Translations$chat$welcome$afternoon$analyzeSpending$zh_Hant._(_root);
	@override late final _Translations$chat$welcome$afternoon$budgetProgress$zh_Hant budgetProgress = _Translations$chat$welcome$afternoon$budgetProgress$zh_Hant._(_root);
}

// Path: chat.welcome.evening
class _Translations$chat$welcome$evening$zh_Hant extends Translations$chat$welcome$evening$zh {
	_Translations$chat$welcome$evening$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get subtitle => 'End of day, time to balance the books';
	@override late final _Translations$chat$welcome$evening$dinner$zh_Hant dinner = _Translations$chat$welcome$evening$dinner$zh_Hant._(_root);
	@override late final _Translations$chat$welcome$evening$todaySummary$zh_Hant todaySummary = _Translations$chat$welcome$evening$todaySummary$zh_Hant._(_root);
	@override late final _Translations$chat$welcome$evening$tomorrowPlan$zh_Hant tomorrowPlan = _Translations$chat$welcome$evening$tomorrowPlan$zh_Hant._(_root);
}

// Path: chat.welcome.night
class _Translations$chat$welcome$night$zh_Hant extends Translations$chat$welcome$night$zh {
	_Translations$chat$welcome$night$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get greeting => 'Late Night';
	@override String get subtitle => 'Quiet time for financial planning';
	@override late final _Translations$chat$welcome$night$makeupRecord$zh_Hant makeupRecord = _Translations$chat$welcome$night$makeupRecord$zh_Hant._(_root);
	@override late final _Translations$chat$welcome$night$monthlyReview$zh_Hant monthlyReview = _Translations$chat$welcome$night$monthlyReview$zh_Hant._(_root);
	@override late final _Translations$chat$welcome$night$financialThinking$zh_Hant financialThinking = _Translations$chat$welcome$night$financialThinking$zh_Hant._(_root);
}

// Path: chat.genui.healthScore.status
class _Translations$chat$genui$healthScore$status$zh_Hant extends Translations$chat$genui$healthScore$status$zh {
	_Translations$chat$genui$healthScore$status$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get excellent => 'Excellent';
	@override String get good => 'Good';
	@override String get fair => 'Fair';
	@override String get needsImprovement => 'Needs Improvement';
	@override String get poor => 'Poor';
}

// Path: chat.welcome.morning.breakfast
class _Translations$chat$welcome$morning$breakfast$zh_Hant extends Translations$chat$welcome$morning$breakfast$zh {
	_Translations$chat$welcome$morning$breakfast$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => 'Breakfast';
	@override String get prompt => 'Record breakfast expense';
	@override String get description => 'Log today\'s first expense';
}

// Path: chat.welcome.morning.yesterdayReview
class _Translations$chat$welcome$morning$yesterdayReview$zh_Hant extends Translations$chat$welcome$morning$yesterdayReview$zh {
	_Translations$chat$welcome$morning$yesterdayReview$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => 'Yesterday Review';
	@override String get prompt => 'Analyze yesterday\'s spending';
	@override String get description => 'Check how much you spent yesterday';
}

// Path: chat.welcome.morning.todayBudget
class _Translations$chat$welcome$morning$todayBudget$zh_Hant extends Translations$chat$welcome$morning$todayBudget$zh {
	_Translations$chat$welcome$morning$todayBudget$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => 'Today\'s Budget';
	@override String get prompt => 'How much budget left for today';
	@override String get description => 'Plan your spending for today';
}

// Path: chat.welcome.midday.lunch
class _Translations$chat$welcome$midday$lunch$zh_Hant extends Translations$chat$welcome$midday$lunch$zh {
	_Translations$chat$welcome$midday$lunch$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => 'Lunch';
	@override String get prompt => 'Record lunch expense';
	@override String get description => 'Log your lunch spending';
}

// Path: chat.welcome.midday.weeklyExpense
class _Translations$chat$welcome$midday$weeklyExpense$zh_Hant extends Translations$chat$welcome$midday$weeklyExpense$zh {
	_Translations$chat$welcome$midday$weeklyExpense$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => 'Weekly Spending';
	@override String get prompt => 'Analyze this week\'s spending';
	@override String get description => 'See your weekly expenses';
}

// Path: chat.welcome.midday.checkBalance
class _Translations$chat$welcome$midday$checkBalance$zh_Hant extends Translations$chat$welcome$midday$checkBalance$zh {
	_Translations$chat$welcome$midday$checkBalance$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => 'Check Balance';
	@override String get prompt => 'Check my account balance';
	@override String get description => 'View your account balances';
}

// Path: chat.welcome.afternoon.quickRecord
class _Translations$chat$welcome$afternoon$quickRecord$zh_Hant extends Translations$chat$welcome$afternoon$quickRecord$zh {
	_Translations$chat$welcome$afternoon$quickRecord$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => 'Quick Record';
	@override String get prompt => 'Help me record an expense';
	@override String get description => 'Quickly log a transaction';
}

// Path: chat.welcome.afternoon.analyzeSpending
class _Translations$chat$welcome$afternoon$analyzeSpending$zh_Hant extends Translations$chat$welcome$afternoon$analyzeSpending$zh {
	_Translations$chat$welcome$afternoon$analyzeSpending$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => 'Analyze Spending';
	@override String get prompt => 'Analyze this month\'s spending';
	@override String get description => 'View spending trends and breakdown';
}

// Path: chat.welcome.afternoon.budgetProgress
class _Translations$chat$welcome$afternoon$budgetProgress$zh_Hant extends Translations$chat$welcome$afternoon$budgetProgress$zh {
	_Translations$chat$welcome$afternoon$budgetProgress$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => 'Budget Progress';
	@override String get prompt => 'Check budget status';
	@override String get description => 'See how your budget is doing';
}

// Path: chat.welcome.evening.dinner
class _Translations$chat$welcome$evening$dinner$zh_Hant extends Translations$chat$welcome$evening$dinner$zh {
	_Translations$chat$welcome$evening$dinner$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => 'Dinner';
	@override String get prompt => 'Record dinner expense';
	@override String get description => 'Log tonight\'s dinner spending';
}

// Path: chat.welcome.evening.todaySummary
class _Translations$chat$welcome$evening$todaySummary$zh_Hant extends Translations$chat$welcome$evening$todaySummary$zh {
	_Translations$chat$welcome$evening$todaySummary$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => 'Today\'s Summary';
	@override String get prompt => 'Summarize today\'s spending';
	@override String get description => 'See what you spent today';
}

// Path: chat.welcome.evening.tomorrowPlan
class _Translations$chat$welcome$evening$tomorrowPlan$zh_Hant extends Translations$chat$welcome$evening$tomorrowPlan$zh {
	_Translations$chat$welcome$evening$tomorrowPlan$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => 'Tomorrow\'s Plan';
	@override String get prompt => 'What fixed expenses tomorrow';
	@override String get description => 'Plan ahead for tomorrow';
}

// Path: chat.welcome.night.makeupRecord
class _Translations$chat$welcome$night$makeupRecord$zh_Hant extends Translations$chat$welcome$night$makeupRecord$zh {
	_Translations$chat$welcome$night$makeupRecord$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => 'Catch Up';
	@override String get prompt => 'Help me log any missed expenses';
	@override String get description => 'Record expenses you forgot today';
}

// Path: chat.welcome.night.monthlyReview
class _Translations$chat$welcome$night$monthlyReview$zh_Hant extends Translations$chat$welcome$night$monthlyReview$zh {
	_Translations$chat$welcome$night$monthlyReview$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => 'Monthly Review';
	@override String get prompt => 'Analyze this month\'s spending';
	@override String get description => 'Review your monthly expenses';
}

// Path: chat.welcome.night.financialThinking
class _Translations$chat$welcome$night$financialThinking$zh_Hant extends Translations$chat$welcome$night$financialThinking$zh {
	_Translations$chat$welcome$night$financialThinking$zh_Hant._(TranslationsZhHant root) : this._root = root, super.internal(root);

	final TranslationsZhHant _root; // ignore: unused_field

	// Translations
	@override String get title => 'Financial Tips';
	@override String get prompt => 'Give me some financial advice';
	@override String get description => 'Get AI-powered financial insights';
}

/// The flat map containing all translations for locale <zh-Hant>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsZhHant {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.loading' => '載入中...',
			'common.error' => '錯誤',
			'common.retry' => '重試',
			'common.cancel' => '取消',
			'common.confirm' => '確認',
			'common.save' => '儲存',
			'common.delete' => '刪除',
			'common.edit' => '編輯',
			'common.add' => '添加',
			'common.search' => '搜尋',
			'common.filter' => '篩選',
			'common.sort' => '排序',
			'common.refresh' => '刷新',
			'common.more' => '更多',
			'common.less' => '收起',
			'common.all' => '全部',
			'common.none' => '無',
			'common.ok' => '確定',
			'common.unknown' => '未知',
			'common.noData' => '暫無數據',
			'common.loadMore' => '載入更多',
			'common.noMore' => '沒有更多了',
			'common.loadFailed' => '載入失敗',
			'common.history' => '交易記錄',
			'common.reset' => '重置',
			'time.today' => '今天',
			'time.yesterday' => '昨天',
			'time.dayBeforeYesterday' => '前天',
			'time.thisWeek' => '本週',
			'time.thisMonth' => '本月',
			'time.thisYear' => '今年',
			'time.selectDate' => '選擇日期',
			'time.selectTime' => '選擇時間',
			'time.justNow' => '剛剛',
			'time.minutesAgo' => ({required Object count}) => '${count}分鐘前',
			'time.hoursAgo' => ({required Object count}) => '${count}小時前',
			'time.daysAgo' => ({required Object count}) => '${count}天前',
			'time.weeksAgo' => ({required Object count}) => '${count}週前',
			'greeting.morning' => '上午好',
			'greeting.afternoon' => '下午好',
			'greeting.evening' => '晚上好',
			'navigation.home' => '首頁',
			'navigation.forecast' => '預測',
			'navigation.footprint' => '足跡',
			'navigation.profile' => '我的',
			'auth.login' => '登錄',
			'auth.loggingIn' => '登錄中...',
			'auth.logout' => '登出',
			'auth.register' => '註冊',
			'auth.registering' => '註冊中...',
			'auth.welcomeBack' => '歡迎回來',
			'auth.loginSuccess' => '歡迎回來!',
			'auth.loginFailed' => '登錄失敗',
			'auth.pleaseTryAgain' => '請稍後重試。',
			'auth.loginSubtitle' => '登錄以繼續使用 AI 記帳助理',
			'auth.noAccount' => '還沒有帳戶？註冊',
			'auth.createAccount' => '創建您的帳戶',
			'auth.setPassword' => '設置密碼',
			'auth.setAccountPassword' => '設置您的帳戶密碼',
			'auth.completeRegistration' => '完成註冊',
			'auth.registrationSuccess' => '註冊成功!',
			'auth.registrationFailed' => '註冊失敗',
			'auth.email.label' => '電子郵件',
			'auth.email.placeholder' => '請輸入您的電子郵件',
			'auth.email.required' => '電子郵件不能為空',
			'auth.email.invalid' => '請輸入有效的電子郵件地址',
			'auth.password.label' => '密碼',
			'auth.password.placeholder' => '請輸入您的密碼',
			'auth.password.required' => '密碼不能為空',
			'auth.password.tooShort' => '密碼長度不能少於 6 位',
			'auth.password.mustContainNumbersAndLetters' => '密碼必須包含數字和字母',
			'auth.password.confirm' => '確認密碼',
			'auth.password.confirmPlaceholder' => '請再次輸入您的密碼',
			'auth.password.mismatch' => '兩次輸入的密碼不一致',
			'auth.verificationCode.label' => '驗證碼',
			'auth.verificationCode.get' => '獲取驗證碼',
			'auth.verificationCode.sending' => '發送中...',
			'auth.verificationCode.sent' => '驗證碼已發送',
			'auth.verificationCode.sendFailed' => '發送失敗',
			'auth.verificationCode.placeholder' => '請輸入驗證碼',
			'auth.verificationCode.required' => '驗證碼不能為空',
			'auth.logoutSuccess' => 'Logged out successfully',
			'auth.confirmLogoutTitle' => 'Confirm Logout',
			'auth.confirmLogoutContent' => 'Are you sure you want to log out?',
			'transaction.expense' => '支出',
			'transaction.income' => '收入',
			'transaction.transfer' => '轉帳',
			'transaction.amount' => '金額',
			'transaction.category' => '分類',
			'transaction.description' => '描述',
			'transaction.tags' => '標籤',
			'transaction.saveTransaction' => '儲存記帳',
			'transaction.pleaseEnterAmount' => '請輸入金額',
			'transaction.pleaseSelectCategory' => '請選擇分類',
			'transaction.saveFailed' => '儲存失敗',
			'transaction.descriptionHint' => '記錄這筆交易的詳細信息...',
			'transaction.addCustomTag' => '添加自定義標籤',
			'transaction.commonTags' => '常用標籤',
			'transaction.maxTagsHint' => ({required Object maxTags}) => '最多添加 ${maxTags} 個標籤',
			'transaction.noTransactionsFound' => '沒有找到交易記錄',
			'transaction.tryAdjustingSearch' => '嘗試調整搜尋條件或創建新的交易記錄',
			'transaction.noDescription' => '無描述',
			'transaction.payment' => '支付',
			'transaction.account' => '帳戶',
			'transaction.time' => '時間',
			'transaction.location' => '地點',
			'transaction.transactionDetail' => '交易詳情',
			'transaction.favorite' => '收藏',
			'transaction.confirmDelete' => '確認刪除',
			'transaction.deleteTransactionConfirm' => '您確定要刪除此條交易記錄嗎？此操作無法撤銷。',
			'transaction.noActions' => '沒有可用的操作',
			'transaction.deleted' => '已刪除',
			'transaction.deleteFailed' => '刪除失敗，請稍後重試',
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
			'home.totalExpense' => '總消費金額',
			'home.todayExpense' => '今日支出',
			'home.monthExpense' => '本月支出',
			'home.yearProgress' => ({required Object year}) => '${year}年進度',
			'home.amountHidden' => '••••••••',
			'home.loadFailed' => '載入失敗',
			'home.noTransactions' => '暫無交易記錄',
			'home.tryRefresh' => '刷新試試',
			'home.noMoreData' => '沒有更多數據了',
			'home.userNotLoggedIn' => '用戶未登錄，無法載入數據',
			'comment.error' => '錯誤',
			'comment.commentFailed' => '評論失敗',
			'comment.replyToPrefix' => ({required Object name}) => '回覆 @${name}:',
			'comment.reply' => '回覆',
			'comment.addNote' => '添加備註...',
			'comment.confirmDeleteTitle' => '確認刪除',
			'comment.confirmDeleteContent' => '你確定要刪除這條評論嗎？此操作無法撤銷。',
			'comment.success' => '成功',
			'comment.commentDeleted' => '評論已刪除',
			'comment.deleteFailed' => '刪除失敗',
			'comment.deleteComment' => '刪除評論',
			'comment.hint' => '提示',
			'comment.noActions' => '沒有可用的操作',
			'comment.note' => '備註',
			'comment.noNote' => '暫無備註',
			'comment.loadFailed' => '載入備註失敗',
			'calendar.title' => '消費日曆',
			'calendar.weekdays.mon' => '一',
			'calendar.weekdays.tue' => '二',
			'calendar.weekdays.wed' => '三',
			'calendar.weekdays.thu' => '四',
			'calendar.weekdays.fri' => '五',
			'calendar.weekdays.sat' => '六',
			'calendar.weekdays.sun' => '日',
			'calendar.loadFailed' => '載入日曆數據失敗',
			'calendar.thisMonth' => ({required Object amount}) => '本月: ${amount}',
			'calendar.counting' => '統計中...',
			'calendar.unableToCount' => '無法統計',
			'calendar.trend' => '趨勢: ',
			'calendar.noTransactionsTitle' => '當日無交易記錄',
			'calendar.loadTransactionFailed' => '載入交易失敗',
			'category.dailyConsumption' => '日常消費',
			'category.transportation' => '交通出行',
			'category.healthcare' => '醫療健康',
			'category.housing' => '住房物業',
			'category.education' => '教育培訓',
			'category.incomeCategory' => '收入進帳',
			'category.socialGifts' => '社交饋贈',
			'category.moneyTransfer' => '資金周轉',
			'category.other' => '其他',
			'category.foodDining' => '餐飲美食',
			'category.shoppingRetail' => '購物消費',
			'category.housingUtilities' => '居住物業',
			'category.personalCare' => '個人護理',
			'category.entertainment' => '休閒娛樂',
			'category.medicalHealth' => '醫療健康',
			'category.insurance' => '保險',
			'category.socialGifting' => '人情往來',
			'category.financialTax' => '金融稅務',
			'category.others' => '其他支出',
			'category.salaryWage' => '工資薪水',
			'category.businessTrade' => '經營交易',
			'category.investmentReturns' => '投資回報',
			'category.giftBonus' => '禮金紅包',
			'category.refundRebate' => '退款返利',
			'category.generalTransfer' => '轉帳',
			'category.debtRepayment' => '債務還款',
			'settings.title' => '設置',
			'settings.language' => '語言',
			'settings.languageSettings' => '語言設置',
			'settings.selectLanguage' => '選擇語言',
			'settings.languageChanged' => '語言已更改',
			'settings.restartToApply' => '重啟應用以應用更改',
			'settings.theme' => '主題',
			'settings.darkMode' => '深色模式',
			'settings.lightMode' => '淺色模式',
			'settings.systemMode' => '跟隨系統',
			'settings.developerOptions' => '開發者選項',
			'settings.authDebug' => '認證狀態調試',
			'settings.authDebugSubtitle' => '查看認證狀態和調試信息',
			'settings.fontTest' => '字體測試',
			'settings.fontTestSubtitle' => '測試應用字體顯示效果',
			'settings.helpAndFeedback' => '幫助與反饋',
			'settings.helpAndFeedbackSubtitle' => '獲取幫助或提供反饋',
			'settings.aboutApp' => '關於應用',
			'settings.aboutAppSubtitle' => '版本信息和開發者信息',
			'settings.currencyChangedRefreshHint' => ({required Object currency}) => '已切換為 ${currency}，新交易將以此貨幣記錄',
			'settings.sharedSpace' => '共享空間',
			'settings.speechRecognition' => '語音識別',
			'settings.speechRecognitionSubtitle' => '配置語音輸入參數',
			'settings.amountDisplayStyle' => '金額顯示樣式',
			'settings.currency' => '顯示幣種',
			'settings.appearance' => '外觀設置',
			'settings.appearanceSubtitle' => '主題模式與配色方案',
			'settings.speechTest' => '語音測試',
			'settings.speechTestSubtitle' => '測試 WebSocket 語音連接',
			'settings.userTypeRegular' => '普通用戶',
			'settings.selectAmountStyle' => '選擇金額顯示樣式',
			'settings.currencyDescription' => '選擇您偏好的顯示幣種。所有金額都將以此幣種顯示。',
			'settings.amountStyleNotice' => 'Note: Amount styles are primarily applied to \'Transactions\' and \'Trends\'. To maintain visual clarity, \'Account Balances\' and \'Asset Summaries\' will remain in neutral colors.',
			'settings.editUsername' => 'Edit Username',
			'settings.enterUsername' => 'Enter username',
			'settings.usernameRequired' => 'Username is required',
			'settings.usernameUpdated' => 'Username updated',
			'settings.avatarUpdated' => 'Avatar updated',
			'settings.appearanceUpdated' => '外观设置已更新',
			'appearance.title' => '外觀設置',
			'appearance.themeMode' => '主題模式',
			'appearance.light' => '淺色',
			'appearance.dark' => '深色',
			'appearance.system' => '跟隨系統',
			'appearance.colorScheme' => '配色方案',
			'appearance.palettes.zinc' => 'Zinc',
			'appearance.palettes.slate' => 'Slate',
			'appearance.palettes.red' => 'Red',
			'appearance.palettes.rose' => 'Rose',
			'appearance.palettes.orange' => 'Orange',
			'appearance.palettes.green' => 'Green',
			'appearance.palettes.blue' => 'Blue',
			'appearance.palettes.yellow' => 'Yellow',
			'appearance.palettes.violet' => 'Violet',
			'speech.title' => '語音識別設置',
			'speech.service' => '語音識別服務',
			'speech.systemVoice' => '系統語音',
			'speech.systemVoiceSubtitle' => '使用手機內置的語音識別服務（推薦）',
			'speech.selfHostedASR' => '自建 ASR 服務',
			'speech.selfHostedASRSubtitle' => '使用 WebSocket 連接到自建語音識別服務',
			'speech.serverConfig' => '服務器配置',
			'speech.serverAddress' => '服務器地址',
			'speech.port' => '端口',
			'speech.path' => '路徑',
			'speech.saveConfig' => '儲存配置',
			'speech.info' => '信息',
			'speech.infoContent' => '• 系統語音：使用設備內置服務，無需配置，響應更快\n• 自建 ASR：適用於自定義模型或離線場景\n\n更改將在下次使用語音輸入時生效。',
			'speech.enterAddress' => '請輸入服務器地址',
			'speech.enterValidPort' => '請輸入有效的端口 (1-65535)',
			'speech.configSaved' => '配置已儲存',
			'amountTheme.chinaMarket' => '中國市場習慣',
			'amountTheme.chinaMarketDesc' => '紅漲綠跌/黑跌 (推薦)',
			'amountTheme.international' => '國際標準',
			'amountTheme.internationalDesc' => '綠漲紅跌',
			'amountTheme.minimalist' => '極簡模式',
			'amountTheme.minimalistDesc' => '僅通過符號區分',
			'amountTheme.colorBlind' => '色弱友好',
			'amountTheme.colorBlindDesc' => '藍橙配色方案',
			'locale.chinese' => '中文（簡體）',
			'locale.traditionalChinese' => '中文（繁體）',
			'locale.english' => 'English',
			'locale.japanese' => '日本語',
			'locale.korean' => '한국어',
			'budget.title' => '預算管理',
			'budget.detail' => '預算詳情',
			'budget.info' => '預算信息',
			'budget.totalBudget' => '總預算',
			'budget.categoryBudget' => '分類預算',
			'budget.monthlySummary' => '本月預算彙總',
			'budget.used' => '已使用',
			'budget.remaining' => '剩餘',
			'budget.overspent' => '超支',
			'budget.budget' => '預算',
			'budget.loadFailed' => '載入失敗',
			'budget.noBudget' => '暫無預算',
			'budget.createHint' => '點擊下方按鈕設置您的預算',
			'budget.paused' => '已暫停',
			'budget.pause' => '暫停',
			'budget.resume' => '恢復',
			'budget.budgetPaused' => '預算已暫停',
			'budget.budgetResumed' => '預算已恢復',
			'budget.operationFailed' => '操作失敗',
			'budget.deleteBudget' => '刪除預算',
			'budget.deleteConfirm' => '確定要刪除這個預算嗎？此操作不可撤銷。',
			'budget.type' => '類型',
			'budget.category' => '分類',
			'budget.period' => '週期',
			'budget.rollover' => '滾動預算',
			'budget.rolloverBalance' => '滾動餘額',
			'budget.enabled' => '開啟',
			'budget.disabled' => '關閉',
			'budget.statusNormal' => '預算正常',
			'budget.statusWarning' => '接近上限',
			'budget.statusOverspent' => '已超支',
			'budget.statusAchieved' => '目標達成',
			'budget.tipNormal' => ({required Object amount}) => '還剩 ${amount} 可用',
			'budget.tipWarning' => ({required Object amount}) => '僅剩 ${amount}，請注意控制',
			'budget.tipOverspent' => ({required Object amount}) => '已超支 ${amount}',
			'budget.tipAchieved' => '恭喜完成儲蓄目標！',
			'budget.remainingAmount' => ({required Object amount}) => '剩餘 ${amount}',
			'budget.overspentAmount' => ({required Object amount}) => '超支 ${amount}',
			'budget.budgetAmount' => ({required Object amount}) => '預算 ${amount}',
			'budget.active' => '活躍',
			'budget.all' => '全部',
			'budget.notFound' => '預算不存在或已被刪除',
			'budget.setup' => '預算設置',
			'budget.settings' => '預算設置',
			'budget.setAmount' => '設置預算金額',
			'budget.setAmountDesc' => '為每個分類設置預算金額',
			'budget.monthly' => '月度預算',
			'budget.monthlyDesc' => '按月管理您的支出，適合大多數人',
			'budget.weekly' => '周預算',
			'budget.weeklyDesc' => '按周管理支出，更精細的控制',
			'budget.yearly' => '年度預算',
			'budget.yearlyDesc' => '長期財務規劃，適合大額支出管理',
			'budget.editBudget' => '編輯預算',
			'budget.editBudgetDesc' => '修改預算金額和分類',
			'budget.reminderSettings' => '提醒設置',
			'budget.reminderSettingsDesc' => '設置預算提醒和通知',
			'budget.report' => '預算報告',
			'budget.reportDesc' => '查看詳細的預算分析報告',
			'budget.welcome' => '歡迎使用預算功能！',
			'budget.createNewPlan' => '創建新的預算計劃',
			'budget.welcomeDesc' => '通過設置預算，您可以更好地控制支出，實現財務目標。讓我們開始設置您的第一個預算計劃吧！',
			'budget.createDesc' => '為不同的支出類別設置預算限額，幫助您更好地管理財務。',
			'budget.newBudget' => '新建預算',
			'budget.budgetAmountLabel' => '預算金額',
			'budget.currency' => '貨幣',
			'budget.periodSettings' => '週期設置',
			'budget.autoGenerateTransactions' => '開啟後按規則自動生成交易',
			'budget.cycle' => '週期',
			'budget.budgetCategory' => '預算分類',
			'budget.advancedOptions' => '高級選項',
			'budget.periodType' => '週期類型',
			'budget.anchorDay' => '起算日',
			'budget.selectPeriodType' => '選擇週期類型',
			'budget.selectAnchorDay' => '選擇起算日',
			'budget.rolloverDescription' => '未用完的預算結轉到下期',
			'budget.createBudget' => '創建預算',
			'budget.save' => '儲存',
			'budget.pleaseEnterAmount' => '請輸入預算金額',
			'budget.invalidAmount' => '請輸入有效的預算金額',
			'budget.updateSuccess' => '預算更新成功',
			'budget.createSuccess' => '預算創建成功',
			'budget.deleteSuccess' => '預算已刪除',
			'budget.deleteFailed' => '刪除失敗',
			'budget.everyMonthDay' => ({required Object day}) => '每月 ${day} 號',
			'budget.periodWeekly' => '每週',
			'budget.periodBiweekly' => '雙週',
			'budget.periodMonthly' => '每月',
			'budget.periodYearly' => '每年',
			'budget.statusActive' => '進行中',
			'budget.statusArchived' => '已歸檔',
			'budget.periodStatusOnTrack' => '正常',
			'budget.periodStatusWarning' => '預警',
			'budget.periodStatusExceeded' => '超支',
			'budget.periodStatusAchieved' => '達成',
			'budget.usedPercent' => ({required Object percent}) => '${percent}% 已使用',
			'budget.dayOfMonth' => ({required Object day}) => '${day} 號',
			'budget.tenThousandSuffix' => '萬',
			'budget.settingsLoadFailed' => '載入設定失敗',
			'budget.settingsSaveSuccess' => '設定已儲存',
			'budget.settingsSaveFailed' => '儲存失敗',
			'budget.settingsSave' => '儲存設定',
			'budget.settingsWarningThreshold' => '預警閾值',
			'budget.settingsWarningDesc' => '當使用率達到此百分比時顯示預警狀態',
			'budget.settingsAlertThreshold' => '超支閾值',
			'budget.settingsAlertDesc' => '當使用率達到此百分比時顯示超支狀態',
			'budget.settingsThresholdOrder' => '預警閾值不能大於超支閾值',
			'dateRange.custom' => '自定義',
			'dateRange.pickerTitle' => '選擇時間範圍',
			'dateRange.startDate' => '開始日期',
			'dateRange.endDate' => '結束日期',
			'dateRange.hint' => '請選擇日期範圍',
			'forecast.title' => '預測',
			'forecast.subtitle' => '基於您的財務數據智能預測未來現金流',
			'forecast.financialNavigator' => '你好，我是你的財務領航員',
			'forecast.financialMapSubtitle' => '只需 3 步，我們一起繪製你未來的財務地圖',
			'forecast.predictCashFlow' => '預測未來現金流',
			'forecast.predictCashFlowDesc' => '看清每一天的財務狀況',
			'forecast.aiSmartSuggestions' => 'AI 智能建議',
			'forecast.aiSmartSuggestionsDesc' => '個性化的財務決策指導',
			'forecast.riskWarning' => '風險預警',
			'forecast.riskWarningDesc' => '提前發現潛在的財務風險',
			'forecast.analyzing' => '我正在分析你的財務數據，生成未來 30 天的現金流預測',
			'forecast.analyzePattern' => '分析收入支出模式',
			'forecast.calculateTrend' => '計算現金流趨勢',
			'forecast.generateWarning' => '生成風險預警',
			'forecast.loadingForecast' => '正在載入財務預測...',
			'forecast.todayLabel' => '今日',
			'forecast.tomorrowLabel' => '明日',
			'forecast.balanceLabel' => '餘額',
			'forecast.noSpecialEvents' => '無特殊事件',
			'forecast.financialSafetyLine' => '財務安全線',
			'forecast.currentSetting' => '當前設置',
			'forecast.dailySpendingEstimate' => '日常消費預估',
			'forecast.adjustDailySpendingAmount' => '調整每日消費預測金額',
			'forecast.tellMeYourSafetyLine' => '告訴我你的財務"安心線"是多少？',
			'forecast.safetyLineDescription' => '這是你希望帳戶保持的最低餘額，當餘額接近這個數值時，我會提醒你注意財務風險。',
			'forecast.dailySpendingQuestion' => '每天的"小日子"大概花多少？',
			'forecast.dailySpendingDescription' => '包括吃飯、交通、購物等日常開銷\n這只是一個初始估算，我會通過你未來的真實記錄，讓預測越來越準',
			'forecast.perDay' => '每天',
			'forecast.referenceStandard' => '參考標準',
			'forecast.frugalType' => '節儉型',
			'forecast.comfortableType' => '舒適型',
			'forecast.relaxedType' => '寬鬆型',
			'forecast.frugalAmount' => '50-100元/天',
			'forecast.comfortableAmount' => '100-200元/天',
			'forecast.relaxedAmount' => '200-300元/天',
			'forecast.recurringTransaction.title' => '週期交易',
			'forecast.recurringTransaction.all' => '全部',
			'forecast.recurringTransaction.expense' => '支出',
			'forecast.recurringTransaction.income' => '收入',
			'forecast.recurringTransaction.transfer' => '轉帳',
			'forecast.recurringTransaction.noRecurring' => '暫無週期交易',
			'forecast.recurringTransaction.createHint' => '創建週期交易後，系統將自動為您生成交易記錄',
			'forecast.recurringTransaction.create' => '創建週期交易',
			'forecast.recurringTransaction.edit' => '編輯週期交易',
			'forecast.recurringTransaction.newTransaction' => '新建週期交易',
			'forecast.recurringTransaction.deleteConfirm' => ({required Object name}) => '確定要刪除週期交易「${name}」嗎？此操作不可撤銷。',
			'forecast.recurringTransaction.activateConfirm' => ({required Object name}) => '確定要啟用週期交易「${name}」嗎？啟用後將按照設定的規則自動生成交易記錄。',
			'forecast.recurringTransaction.pauseConfirm' => ({required Object name}) => '確定要暫停週期交易「${name}」嗎？暫停後將不再自動生成交易記錄。',
			'forecast.recurringTransaction.created' => '週期交易已創建',
			'forecast.recurringTransaction.updated' => '週期交易已更新',
			'forecast.recurringTransaction.activated' => '已啟用',
			'forecast.recurringTransaction.paused' => '已暫停',
			'forecast.recurringTransaction.nextTime' => '下次',
			'forecast.recurringTransaction.sortByTime' => '按時間排序',
			'forecast.recurringTransaction.allPeriod' => '全部週期',
			'forecast.recurringTransaction.periodCount' => ({required Object type, required Object count}) => '${type}週期 (${count})',
			'forecast.recurringTransaction.confirmDelete' => '確認刪除',
			'forecast.recurringTransaction.confirmActivate' => '確認啟用',
			'forecast.recurringTransaction.confirmPause' => '確認暫停',
			'forecast.recurringTransaction.dynamicAmount' => '動態均值',
			'forecast.recurringTransaction.dynamicAmountTitle' => '金額需手動確認',
			'forecast.recurringTransaction.dynamicAmountDescription' => '系統將在帳單日發送提醒，需要您手動確認具體金額後才會記帳。',
			'forecast.recurringTransaction.confirmBeforeGeneration' => '生成前需確認',
			'forecast.recurringTransaction.confirmBeforeGenerationDesc' => '到期時生成待確認交易，需手動確認後記帳',
			'forecast.recurringTransaction.pendingTitle' => '待確認交易',
			'forecast.recurringTransaction.pendingCount' => ({required Object count}) => '${count} 筆待確認',
			'forecast.recurringTransaction.confirm' => '確認',
			'forecast.recurringTransaction.skip' => '跳過',
			'forecast.recurringTransaction.noPending' => '無待確認交易',
			'forecast.recurringTransaction.confirmSuccess' => '已確認記帳',
			'forecast.recurringTransaction.skipSuccess' => '已跳過',
			'chat.newChat' => '新聊天',
			'chat.noMessages' => '沒有消息可顯示。',
			'chat.loadingFailed' => '載入失敗',
			'chat.inputMessage' => '輸入消息...',
			'chat.listening' => '正在聆聽...',
			'chat.aiThinking' => '正在處理...',
			'chat.tools.processing' => '正在處理...',
			'chat.tools.readFile' => '正在查看文件...',
			'chat.tools.searchTransactions' => '正在查詢交易...',
			'chat.tools.queryBudgetStatus' => '正在檢查預算...',
			'chat.tools.createBudget' => '正在創建預算計劃...',
			'chat.tools.getCashFlowAnalysis' => '正在分析現金流...',
			'chat.tools.getFinancialHealthScore' => '正在計算財務健康分...',
			'chat.tools.getFinancialSummary' => '正在生成財務報告...',
			'chat.tools.evaluateFinancialHealth' => '正在評估財務健康...',
			'chat.tools.forecastBalance' => '正在預測未來餘額...',
			'chat.tools.simulateExpenseImpact' => '正在模擬購買影響...',
			'chat.tools.recordTransactions' => '正在記帳...',
			'chat.tools.createTransaction' => '正在記帳...',
			'chat.tools.duckduckgoSearch' => '正在搜尋網絡...',
			'chat.tools.executeTransfer' => '正在執行轉帳...',
			'chat.tools.listDir' => '正在瀏覽目錄...',
			'chat.tools.execute' => '正在執行腳本...',
			'chat.tools.analyzeFinance' => '正在分析財務狀況...',
			'chat.tools.forecastFinance' => '正在預測財務趨勢...',
			'chat.tools.analyzeBudget' => '正在分析預算...',
			'chat.tools.auditAnalysis' => '正在審計分析...',
			'chat.tools.budgetOps' => '正在處理預算...',
			'chat.tools.createSharedTransaction' => '正在創建共享帳單...',
			'chat.tools.listSpaces' => '正在獲取共享空間...',
			'chat.tools.querySpaceSummary' => '正在查詢空間摘要...',
			'chat.tools.prepareTransfer' => '正在準備轉帳...',
			'chat.tools.unknown' => '正在處理請求...',
			'chat.tools.done.readFile' => '已查看文件',
			'chat.tools.done.searchTransactions' => '已查詢交易',
			'chat.tools.done.queryBudgetStatus' => '已檢查預算',
			'chat.tools.done.createBudget' => '已創建預算',
			'chat.tools.done.getCashFlowAnalysis' => '已分析現金流',
			'chat.tools.done.getFinancialHealthScore' => '已計算健康分',
			'chat.tools.done.getFinancialSummary' => '財務報告生成完成',
			'chat.tools.done.evaluateFinancialHealth' => '財務健康評估完成',
			'chat.tools.done.forecastBalance' => '餘額預測完成',
			'chat.tools.done.simulateExpenseImpact' => '購買影響模擬完成',
			'chat.tools.done.recordTransactions' => '記帳完成',
			'chat.tools.done.createTransaction' => '已完成記帳',
			'chat.tools.done.duckduckgoSearch' => '已搜尋網絡',
			'chat.tools.done.executeTransfer' => '轉帳完成',
			'chat.tools.done.listDir' => '已瀏覽目錄',
			'chat.tools.done.execute' => '腳本執行完成',
			'chat.tools.done.analyzeFinance' => '財務分析完成',
			'chat.tools.done.forecastFinance' => '財務預測完成',
			'chat.tools.done.analyzeBudget' => '預算分析完成',
			'chat.tools.done.auditAnalysis' => '審計分析完成',
			_ => null,
		} ?? switch (path) {
			'chat.tools.done.budgetOps' => '預算處理完成',
			'chat.tools.done.createSharedTransaction' => '共享帳單創建完成',
			'chat.tools.done.listSpaces' => '共享空間獲取完成',
			'chat.tools.done.querySpaceSummary' => '空間摘要查詢完成',
			'chat.tools.done.prepareTransfer' => '轉帳準備完成',
			'chat.tools.done.unknown' => '處理完成',
			'chat.tools.done.analyzeSpending' => 'Spending analysis complete',
			'chat.tools.done.analyzeCashflow' => 'Cashflow analysis complete',
			'chat.tools.done.suggestBudget' => 'Budget suggestion complete',
			'chat.tools.done.prepareBudgetSimulation' => '預算模擬準備完成',
			'chat.tools.done.simulateBudget' => '預算模擬完成',
			'chat.tools.failed.unknown' => '操作失敗',
			'chat.tools.analyzeSpending' => 'Analyzing spendings...',
			'chat.tools.analyzeCashflow' => 'Analyzing cashflow...',
			'chat.tools.suggestBudget' => 'Suggesting budget...',
			'chat.tools.cancelled' => 'Cancelled',
			'chat.tools.prepareBudgetSimulation' => '正在準備預算模擬',
			'chat.tools.simulateBudget' => '正在模擬預算',
			'chat.speechNotRecognized' => '未識別到語音，請重試',
			'chat.currentExpense' => '当前支出',
			'chat.loadingComponent' => '正在載入組件...',
			'chat.noHistory' => '暫無歷史會話',
			'chat.startNewChat' => '開啟一段新對話吧！',
			'chat.searchHint' => '搜尋會話',
			'chat.library' => '庫',
			'chat.viewProfile' => '查看個人資料',
			'chat.noRelatedFound' => '未找到相關會話',
			'chat.tryOtherKeywords' => '嘗試搜尋其他關鍵詞',
			'chat.searchFailed' => '搜尋失敗',
			'chat.deleteConversation' => '刪除對話',
			'chat.deleteConversationConfirm' => '確定要刪除這個對話嗎？此操作無法撤回。',
			'chat.conversationDeleted' => '對話已刪除',
			'chat.deleteConversationFailed' => '刪除對話失敗',
			'chat.transferWizard.title' => '轉帳向導',
			'chat.transferWizard.amount' => '轉帳金額',
			'chat.transferWizard.amountHint' => '請輸入金額',
			'chat.transferWizard.sourceAccount' => '轉出帳戶',
			'chat.transferWizard.targetAccount' => '轉入帳戶',
			'chat.transferWizard.selectAccount' => '請選擇帳戶',
			'chat.transferWizard.confirmTransfer' => '確認轉帳',
			'chat.transferWizard.confirmed' => '已確認',
			'chat.transferWizard.transferSuccess' => '轉帳成功',
			'chat.transferWizard.selectReceiveAccount' => '选择收款账户',
			'chat.genui.expenseSummary.totalExpense' => '總支出',
			'chat.genui.expenseSummary.mainExpenses' => '主要支出',
			'chat.genui.expenseSummary.viewAll' => ({required Object count}) => '查看全部 ${count} 筆消費',
			'chat.genui.expenseSummary.details' => '消費明細',
			'chat.genui.transactionList.searchResults' => ({required Object count}) => '搜尋結果 (${count})',
			'chat.genui.transactionList.loaded' => ({required Object count}) => '已載入 ${count}',
			'chat.genui.transactionList.noResults' => '未找到相關交易',
			'chat.genui.transactionList.loadMore' => '滾動載入更多',
			'chat.genui.transactionList.allLoaded' => '全部載入完成',
			'chat.genui.transactionGroupReceipt.title' => '記帳成功',
			'chat.genui.transactionGroupReceipt.count' => ({required Object count}) => '${count}筆',
			'chat.genui.transactionGroupReceipt.selectAccount' => '選擇關聯帳戶',
			'chat.genui.transactionGroupReceipt.selectAccountSubtitle' => '此帳戶將應用到以上所有筆交易',
			'chat.genui.transactionGroupReceipt.associatedAccount' => ({required Object name}) => '已關聯帳戶：${name}',
			'chat.genui.transactionGroupReceipt.clickToAssociate' => '點擊關聯帳戶（支持批量操作）',
			'chat.genui.transactionGroupReceipt.associateSuccess' => '已成功為所有交易關聯帳戶',
			'chat.genui.transactionGroupReceipt.associateFailed' => ({required Object error}) => '操作失敗: ${error}',
			'chat.genui.transactionGroupReceipt.accountAssociation' => '帳戶關聯',
			'chat.genui.transactionGroupReceipt.sharedSpace' => '共享空間',
			'chat.genui.transactionGroupReceipt.notAssociated' => '未關聯',
			'chat.genui.transactionGroupReceipt.addSpace' => '添加',
			'chat.genui.transactionGroupReceipt.selectSpace' => '選擇共享空間',
			'chat.genui.transactionGroupReceipt.spaceAssociateSuccess' => '已關聯到共享空間',
			'chat.genui.transactionGroupReceipt.spaceAssociateFailed' => ({required Object error}) => '關聯共享空間失敗: ${error}',
			'chat.genui.transactionGroupReceipt.currencyMismatchTitle' => '幣種不一致',
			'chat.genui.transactionGroupReceipt.currencyMismatchDesc' => '交易幣種與帳戶幣種不同，系統將按當時匯率換算後扣減帳戶餘額。',
			'chat.genui.transactionGroupReceipt.transactionAmount' => '交易金額',
			'chat.genui.transactionGroupReceipt.accountCurrency' => '帳戶幣種',
			'chat.genui.transactionGroupReceipt.targetAccount' => '目標帳戶',
			'chat.genui.transactionGroupReceipt.currencyMismatchNote' => '提示：帳戶餘額將按當時匯率進行換算扣減',
			'chat.genui.transactionGroupReceipt.confirmAssociate' => '確認關聯',
			'chat.genui.transactionGroupReceipt.total' => 'Total',
			'chat.genui.transactionGroupReceipt.spaceCount' => ({required Object count}) => '${count} spaces',
			'chat.genui.transactionCard.title' => '交易成功',
			'chat.genui.transactionCard.associatedAccount' => '已關聯帳戶',
			'chat.genui.transactionCard.notCounted' => '不計入資產',
			'chat.genui.transactionCard.modify' => '修改',
			'chat.genui.transactionCard.associate' => '關聯帳戶',
			'chat.genui.transactionCard.selectAccount' => '選擇關聯帳戶',
			'chat.genui.transactionCard.noAccount' => '暫無可用帳戶，請先添加帳戶',
			'chat.genui.transactionCard.missingId' => '交易 ID 缺失，無法更新',
			'chat.genui.transactionCard.associatedTo' => ({required Object name}) => '已關聯到 ${name}',
			'chat.genui.transactionCard.updateFailed' => ({required Object error}) => '更新失敗: ${error}',
			'chat.genui.transactionCard.sharedSpace' => 'Shared Space',
			'chat.genui.transactionCard.noSpace' => 'No shared spaces available',
			'chat.genui.transactionCard.selectSpace' => 'Select Shared Space',
			'chat.genui.transactionCard.linkedToSpace' => 'Linked to shared space',
			'chat.genui.cashFlowCard.title' => '現金流分析',
			'chat.genui.cashFlowCard.savingsRate' => ({required Object rate}) => '儲蓄 ${rate}%',
			'chat.genui.cashFlowCard.totalIncome' => '總收入',
			'chat.genui.cashFlowCard.totalExpense' => '總支出',
			'chat.genui.cashFlowCard.essentialExpense' => '必要支出',
			'chat.genui.cashFlowCard.discretionaryExpense' => '可選消費',
			'chat.genui.cashFlowCard.aiInsight' => 'AI 分析',
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
			'chat.genui.transactionConfirmation.multipleAccounts' => '检测到多个关联账户',
			'chat.genui.transactionConfirmation.confirmed' => '已确认',
			'chat.genui.budgetAnalysis.title' => '预算分析报告',
			'chat.genui.budgetAnalysis.periodDays' => ({required Object days}) => '过去 ${days} 天',
			'chat.genui.budgetAnalysis.totalExpense' => '总支出',
			'chat.genui.budgetAnalysis.momChange' => ({required Object change}) => '环比 ${change}%',
			'chat.genui.budgetAnalysis.categoryDistribution' => '分类占比',
			'chat.genui.budgetAnalysis.topSpenders' => '大额支出',
			'chat.genui.budgetAnalysis.amountWan' => ({required Object amount}) => '${amount}万',
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
			'footprint.searchIn' => '搜尋',
			'footprint.searchInAllRecords' => '在所有記錄中搜尋相關內容',
			'media.selectPhotos' => '選擇照片',
			'media.addFiles' => '添加文件',
			'media.takePhoto' => '拍照',
			'media.camera' => '相機',
			'media.photos' => '照片',
			'media.files' => '文件',
			'media.showAll' => '顯示全部',
			'media.allPhotos' => '所有照片',
			'media.takingPhoto' => '拍照中...',
			'media.photoTaken' => '照片已保存',
			'media.cameraPermissionRequired' => '需要相機權限',
			'media.fileSizeExceeded' => '文件大小超過 10MB 限制',
			'media.unsupportedFormat' => '不支持的文件格式',
			'media.permissionDenied' => '需要相冊訪問權限',
			'media.storageInsufficient' => '存儲空間不足',
			'media.networkError' => '網絡連接錯誤',
			'media.unknownUploadError' => '上傳時發生未知錯誤',
			'error.permissionRequired' => '需要權限',
			'error.permissionInstructions' => '請在設置中開啟相冊和存儲權限，以便選擇和上傳文件。',
			'error.openSettings' => '打開設置',
			'error.fileTooLarge' => '文件過大',
			'error.fileSizeHint' => '請選擇小於 10MB 的文件，或者壓縮後再上傳。',
			'error.supportedFormatsHint' => '支持的格式包括：圖片 (jpg, png, gif 等)、文檔 (pdf, doc, txt 等)、音視頻文件等。',
			'error.storageCleanupHint' => '請清理設備存儲空間後重試，或選擇較小的文件。',
			'error.networkErrorHint' => '請檢查網絡連接是否正常，然後重試。',
			'error.platformNotSupported' => '平台不支持',
			'error.fileReadError' => '文件讀取失敗',
			'error.fileReadErrorHint' => '文件可能已損壞或被其他程序占用，請重新選擇文件。',
			'error.validationError' => '文件驗證失敗',
			'error.unknownError' => '未知錯誤',
			'error.unknownErrorHint' => '發生了意外錯誤，請重試或聯繫技術支持。',
			'error.genui.loadingFailed' => '組件載入失敗',
			'error.genui.schemaFailed' => '架構驗證失敗',
			'error.genui.schemaDescription' => '組件定義不符合 GenUI 規範，降級為純文本顯示',
			'error.genui.networkError' => '網絡錯誤',
			'error.genui.retryStatus' => ({required Object retryCount, required Object maxRetries}) => '已重試 ${retryCount}/${maxRetries} 次',
			'error.genui.maxRetriesReached' => '已達最大重試次數',
			'fontTest.page' => '字體測試頁面',
			'fontTest.displayTest' => '字體顯示測試',
			'fontTest.chineseTextTest' => '中文文本測試',
			'fontTest.englishTextTest' => '英文文本測試',
			'fontTest.sample1' => '這是一段中文文本，用於測試字體顯示效果。',
			'fontTest.sample2' => '支出分類彙總，購物最高',
			'fontTest.sample3' => '人工智能助手為您提供專業的財務分析服務',
			'fontTest.sample4' => '數據可視化圖表展示您的消費趨勢',
			'fontTest.sample5' => '微信支付、支付寶、銀行卡等多種支付方式',
			'wizard.nextStep' => '下一步',
			'wizard.previousStep' => '上一步',
			'wizard.completeMapping' => '完成繪製',
			'user.username' => '用戶名',
			'user.defaultEmail' => 'user@example.com',
			'account.editTitle' => '編輯帳戶',
			'account.addTitle' => '新建帳戶',
			'account.selectTypeTitle' => '選擇帳戶類型',
			'account.nameLabel' => '帳戶名稱',
			'account.amountLabel' => '當前餘額',
			'account.currencyLabel' => '幣種',
			'account.hiddenLabel' => '隱藏',
			'account.hiddenDesc' => '在帳戶列表中隱藏該帳戶',
			'account.includeInNetWorthLabel' => '計入資產',
			'account.includeInNetWorthDesc' => '用於淨資產統計',
			'account.nameHint' => '例如：工資卡',
			'account.amountHint' => '0.00',
			'account.deleteAccount' => '刪除帳戶',
			'account.deleteConfirm' => '確定要刪除該帳戶嗎？此操作無法撤銷。',
			'account.save' => '保存修改',
			'account.assetsCategory' => '資產類',
			'account.liabilitiesCategory' => '負債/信用類',
			'account.cash' => '現金錢包',
			'account.deposit' => '銀行存款',
			'account.creditCard' => '信用卡',
			'account.investment' => '投資理財',
			'account.eWallet' => '電子錢包',
			'account.loan' => '貸款帳戶',
			'account.receivable' => '應收款項',
			'account.payable' => '應付款項',
			'account.other' => '其他帳戶',
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
			'financial.title' => '財務',
			'financial.management' => '財務管理',
			'financial.netWorth' => '總淨值',
			'financial.assets' => '總資產',
			'financial.liabilities' => '總負債',
			'financial.noAccounts' => '暫無帳戶',
			'financial.addFirstAccount' => '點擊下方按鈕添加您的第一個帳戶',
			'financial.assetAccounts' => '資產帳戶',
			'financial.liabilityAccounts' => '負債帳戶',
			'financial.selectCurrency' => '選擇貨幣',
			'financial.cancel' => '取消',
			'financial.confirm' => '確定',
			'financial.settings' => '財務設置',
			'financial.budgetManagement' => '預算管理',
			'financial.recurringTransactions' => '週期交易',
			'financial.safetyThreshold' => '安全閾值',
			'financial.dailyBurnRate' => '每日消費',
			'financial.financialAssistant' => '財務助手',
			'financial.manageFinancialSettings' => '管理您的財務設置',
			'financial.safetyThresholdSettings' => '財務安全線設置',
			'financial.setSafetyThreshold' => '設置您的財務安全閾值',
			'financial.safetyThresholdSaved' => '財務安全線已保存',
			'financial.dailyBurnRateSettings' => '日常消費預估',
			'financial.setDailyBurnRate' => '設置您的日常消費預估金額',
			'financial.dailyBurnRateSaved' => '日常消費預估已保存',
			'financial.dayUnit' => '天',
			'financial.saveFailed' => '保存失敗',
			'app.splashTitle' => '智見增長，格物致富。',
			'app.splashSubtitle' => '智能財務助手',
			'statistics.title' => '統計分析',
			'statistics.analyze' => '統計分析',
			'statistics.exportInProgress' => '導出功能開發中...',
			'statistics.ranking' => '大額消費排行',
			'statistics.noData' => '暫無數據',
			'statistics.overview.balance' => '總結餘',
			'statistics.overview.income' => '總收入',
			'statistics.overview.expense' => '總支出',
			'statistics.trend.title' => '收支趨勢',
			'statistics.trend.expense' => '支出',
			'statistics.trend.income' => '收入',
			'statistics.analysis.title' => '支出分析',
			'statistics.analysis.total' => '總計',
			'statistics.analysis.breakdown' => '支出分類明細',
			'statistics.filter.accountType' => '帳戶類型',
			'statistics.filter.allAccounts' => '全部帳戶',
			'statistics.filter.apply' => '確認應用',
			'statistics.sort.amount' => '按金額排序',
			'statistics.sort.date' => '按時間排序',
			'statistics.exportList' => '導出列表',
			'statistics.noMoreData' => '沒有更多數據了',
			'statistics.emptyState.title' => 'Unlock Financial Insights',
			'statistics.emptyState.description' => 'Your financial report is currently a blank canvas.\nRecord your first transaction and let the data tell your story.',
			'statistics.emptyState.action' => 'Record First Transaction',
			'currency.cny' => '人民幣',
			'currency.usd' => '美元',
			'currency.eur' => '歐元',
			'currency.jpy' => '日元',
			'currency.gbp' => '英鎊',
			'currency.aud' => '澳元',
			'currency.cad' => '加元',
			'currency.chf' => '瑞士法郎',
			'currency.rub' => '俄羅斯盧布',
			'currency.hkd' => '港幣',
			'currency.twd' => '新台幣',
			'currency.inr' => '印度盧比',
			'sharedSpace.dashboard.sectionTitle' => '財務概覽',
			'sharedSpace.dashboard.cumulativeTotalExpense' => '累計總支出',
			'sharedSpace.dashboard.participatingMembers' => '參與成員',
			'sharedSpace.dashboard.membersCount' => ({required Object count}) => '${count} 人',
			'sharedSpace.dashboard.averagePerMember' => '成員人均',
			'sharedSpace.dashboard.spendingDistribution' => '成員消費分佈',
			'sharedSpace.dashboard.realtimeUpdates' => '實時更新',
			'sharedSpace.dashboard.paid' => '已支付',
			'sharedSpace.roles.owner' => '主理人',
			'sharedSpace.roles.admin' => '管理員',
			'sharedSpace.roles.member' => '成員',
			'sharedSpace.title' => '共享空間',
			'sharedSpace.create.title' => '建立共享空間',
			'sharedSpace.create.subtitle' => '建立一個新的共享空間，與朋友一起記帳',
			'sharedSpace.create.nameLabel' => '空間名稱',
			'sharedSpace.create.nameHint' => '例如：畢業旅行',
			'sharedSpace.create.descLabel' => '描述（選填）',
			'sharedSpace.create.descHint' => '記錄我們的共同旅行開銷',
			'sharedSpace.create.cancel' => '取消',
			'sharedSpace.create.submit' => '建立',
			'sharedSpace.create.nameRequired' => '請輸入空間名稱',
			'sharedSpace.create.nameTooShort' => '空間名稱至少需要 2 個字元',
			'sharedSpace.create.nameTooLong' => '空間名稱不能超過 50 個字元',
			'sharedSpace.join.title' => '加入共享空間',
			'sharedSpace.join.subtitle' => '輸入朋友分享的邀請碼，開始協作記帳',
			'sharedSpace.join.codeLabel' => '邀請碼',
			'sharedSpace.join.codeHint' => '輸入邀請碼，例如：123456',
			'sharedSpace.join.cancel' => '取消',
			'sharedSpace.join.submit' => '加入',
			'sharedSpace.join.codeRequired' => '請輸入邀請碼',
			'sharedSpace.join.codeInvalid' => '邀請碼格式無效',
			'sharedSpace.join.codeFormat' => '邀請碼只能包含字母和數字',
			'sharedSpace.list.emptyTitle' => '開啟多方協同的財務空間',
			'sharedSpace.list.emptySubtitle' => '建立或加入共享空間，與家人、夥伴或團隊協同管理共享帳目與資產',
			'sharedSpace.list.getStarted' => '開始使用',
			'sharedSpace.list.hasInviteCode' => '有邀請碼？點擊加入',
			'sharedSpace.list.joinedSuccess' => ({required Object name}) => '成功加入「${name}」！',
			'sharedSpace.detail.members' => '成員',
			'sharedSpace.detail.transactions' => '交易紀錄',
			'sharedSpace.detail.recordsCount' => ({required Object count}) => '${count} 筆',
			'sharedSpace.detail.settlement' => '結算',
			'sharedSpace.detail.inviteCode' => '邀請碼',
			'sharedSpace.detail.copyCode' => '複製邀請碼',
			'sharedSpace.detail.codeCopied' => ({required Object code}) => '邀請碼已複製：${code}',
			'sharedSpace.detail.validFor24h' => '24 小時內有效',
			'sharedSpace.detail.leaveSpace' => '退出空間',
			'sharedSpace.detail.deleteSpace' => '刪除空間',
			'sharedSpace.detail.removeMember' => '移除成員',
			'sharedSpace.detail.leaveConfirm' => '確定要退出此共享空間嗎？退出後將無法查看空間內的交易紀錄。',
			'sharedSpace.detail.deleteConfirm' => '確定要刪除此共享空間嗎？此操作不可撤銷，所有成員將被移出。',
			'sharedSpace.detail.removeConfirm' => '確定要將此成員移出共享空間嗎？',
			'sharedSpace.detail.generatingCode' => '正在產生邀請碼...',
			'sharedSpace.detail.loadFailed' => '載入失敗',
			'sharedSpace.detail.retry' => '重試',
			'sharedSpace.detail.noTransactions' => '暫無交易紀錄',
			'sharedSpace.detail.noTransactionsHint' => '空間內的交易將顯示在這裡',
			'sharedSpace.detail.refreshCode' => '重新產生新碼',
			'sharedSpace.detail.joinOtherSpace' => '加入其他空間',
			'sharedSpace.notifications.title' => '通知',
			'sharedSpace.notifications.empty' => '暫無通知',
			'sharedSpace.notifications.emptyHint' => '當你收到新的邀請或動態時，\n通知將顯示在這裡',
			'sharedSpace.notifications.incompleteInfo' => '邀請資訊不完整',
			'sharedSpace.notifications.inviteAccepted' => '已接受邀請！',
			'sharedSpace.notifications.inviteRejected' => '已拒絕邀請',
			'sharedSpace.notifications.allMarkedRead' => '全部標記為已讀',
			'sharedSpace.inviteCard.title' => '邀請碼',
			'sharedSpace.inviteCard.subtitle' => '分享給朋友以加入空間',
			'sharedSpace.inviteCard.copyCode' => '複製邀請碼',
			'sharedSpace.inviteCard.shareLink' => '分享邀請連結',
			'sharedSpace.inviteCard.codeCopied' => '邀請碼已複製',
			'sharedSpace.inviteCard.noExpiry' => '無有效期限制',
			'sharedSpace.inviteCard.expired' => '已過期',
			'sharedSpace.inviteCard.expiresInDays' => ({required Object days}) => '${days} 天後過期',
			'sharedSpace.inviteCard.expiresInHours' => ({required Object hours}) => '${hours} 小時後過期',
			'sharedSpace.inviteCard.expiresInMinutes' => ({required Object minutes}) => '${minutes} 分鐘後過期',
			'sharedSpace.inviteCard.expiringSoon' => '即將過期',
			'sharedSpace.inviteCard.shareText' => ({required Object spaceName, required Object code, required Object link, required Object expiry}) => '邀請你加入共享空間「${spaceName}」\n\n邀請碼：${code}\n或點擊連結直接加入：${link}\n\n邀請碼${expiry}',
			'sharedSpace.inviteSuccess.title' => '建立成功',
			'sharedSpace.inviteSuccess.subtitle' => '共享空間建立成功',
			'sharedSpace.inviteSuccess.inviteLater' => '稍後邀請',
			'sharedSpace.inviteSuccess.enterSpace' => '進入空間',
			'sharedSpace.inviteSuccess.generatingCode' => '正在產生邀請碼...',
			'sharedSpace.inviteSuccess.generateFailed' => '邀請碼產生失敗',
			'sharedSpace.inviteSuccess.codeCopied' => '邀請碼已複製',
			'sharedSpace.inviteSuccess.retry' => '重試',
			'sharedSpace.inviteSuccess.codeLabel' => '邀請碼',
			'sharedSpace.inviteSuccess.validHint' => '24 小時內有效 · 點擊複製',
			'sharedSpace.notificationCard.accept' => '接受',
			'sharedSpace.notificationCard.reject' => '拒絕',
			'sharedSpace.notificationCard.unknownTime' => '未知時間',
			'sharedSpace.notificationCard.justNow' => '剛剛',
			'sharedSpace.spaceCard.noDescription' => '暫無描述',
			'sharedSpace.spaceCard.creator' => '建立者',
			'sharedSpace.spaceCard.member' => '成員',
			'sharedSpace.spaceCard.membersCount' => ({required Object count}) => '${count} 位成員',
			'sharedSpace.spaceCard.transactionsCount' => ({required Object count}) => '${count} 筆帳單',
			'sharedSpace.settings.title' => '空間設定',
			'sharedSpace.settings.spaceInfo' => '空間資訊',
			'sharedSpace.settings.nameLabel' => '空間名稱',
			'sharedSpace.settings.descLabel' => '空間描述',
			'sharedSpace.settings.save' => '儲存',
			'sharedSpace.settings.saved' => '儲存成功',
			'sharedSpace.settings.saveFailed' => '儲存失敗',
			'sharedSpace.settings.memberManagement' => '成員管理',
			'sharedSpace.settings.membersCount' => ({required Object count}) => '${count} 位成員',
			'sharedSpace.settings.removeMemberConfirm' => ({required Object name}) => '確定要將「${name}」移出空間嗎？',
			'sharedSpace.settings.removed' => '已移除成員',
			'sharedSpace.settings.removeFailed' => '移除失敗',
			'sharedSpace.settings.inviteManagement' => '邀請管理',
			'sharedSpace.settings.currentCode' => '目前邀請碼',
			'sharedSpace.settings.generateNew' => '產生新邀請碼',
			'sharedSpace.settings.noValidCode' => '暫無有效邀請碼',
			'sharedSpace.settings.refreshCode' => '重新產生新碼',
			'sharedSpace.settings.refreshConfirm' => '產生新碼將使舊邀請碼失效，確定繼續？',
			'sharedSpace.settings.codeRefreshed' => '邀請碼已重新整理',
			'sharedSpace.settings.dangerZone' => '危險操作',
			'sharedSpace.settings.editHint' => '僅管理員可編輯',
			'sharedSpace.settings.edit' => '編輯',
			'sharedSpace.settings.you' => '我',
			_ => null,
		} ?? switch (path) {
			'sharedSpace.settings.pending' => '待接受',
			'sharedSpace.settings.declined' => '已拒絕',
			'sharedSpace.settings.setAsAdmin' => '設為管理員',
			'sharedSpace.settings.setAsMember' => '設為普通成員',
			'sharedSpace.settings.changeRole' => '變更角色',
			'sharedSpace.settings.changeRoleConfirm' => ({required Object name, required Object role}) => '確定要將「${name}」的角色變更為「${role}」嗎？',
			'sharedSpace.settings.confirm' => '確認',
			'sharedSpace.settings.roleChanged' => '角色已變更',
			'sharedSpace.settings.roleChangeFailed' => '角色變更失敗',
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
			'errorMapping.recurring.invalidRule' => 'Invalid recurrence rule',
			'errorMapping.recurring.ruleNotFound' => 'Recurrence rule not found',
			'errorMapping.upload.noFile' => 'No file uploaded',
			'errorMapping.upload.tooLarge' => 'File too large',
			'errorMapping.upload.unsupportedType' => 'Unsupported file type',
			'errorMapping.upload.tooManyFiles' => 'Too many files',
			'errorMapping.ai.contextLimit' => 'Context limit exceeded',
			'errorMapping.ai.tokenLimit' => 'Insufficient tokens',
			'errorMapping.ai.emptyMessage' => 'Empty user message',
			'notification.title' => '訊息通知',
			'notification.markAllRead' => '全部已讀',
			'notification.empty' => '暫無通知訊息',
			'notification.loadFailed' => '載入失敗',
			'notification.retry' => '重試',
			'notification.justNow' => '剛剛',
			'notification.minutesAgo' => ({required Object minutes}) => '${minutes}分鐘前',
			'notification.hoursAgo' => ({required Object hours}) => '${hours}小時前',
			'notification.daysAgo' => ({required Object days}) => '${days}天前',
			'notification.deleted' => '已刪除',
			'notification.types.system' => '系統通知',
			'notification.types.spaceInvite' => '空間邀請',
			'notification.types.spaceActivity' => '空間動態',
			'notification.types.billComment' => '帳單評論',
			'notification.types.budgetAlert' => '預算提醒',
			'notification.types.transaction' => '交易通知',
			'notification.semantic.memberJoined' => ({required Object name}) => '${name} 加入了你的空間',
			'notification.semantic.memberJoinedDetail' => ({required Object space}) => '新成員加入了「${space}」',
			'notification.semantic.welcome' => ({required Object space}) => '歡迎加入「${space}」',
			'notification.semantic.newTransaction' => ({required Object name}) => '${name} 記錄了一筆新帳單',
			'notification.semantic.newTransactionDetail' => ({required Object amount, required Object space}) => '${amount}，來自「${space}」',
			'notification.semantic.memberLeft' => ({required Object name}) => '${name} 離開了空間',
			'notification.semantic.recurringPending' => '週期交易待確認',
			'notification.semantic.recurringPendingDetail' => ({required Object description, required Object amount}) => '${description} ${amount}，等待您確認記帳',
			_ => null,
		};
	}
}
