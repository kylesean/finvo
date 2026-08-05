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
class TranslationsZh with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsZh({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.zh,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <zh>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	late final TranslationsZh _root = this; // ignore: unused_field

	@override
	TranslationsZh $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsZh(meta: meta ?? this.$meta);

	// Translations
	@override late final Translations$common$zh common = Translations$common$zh.internal(_root);
	@override late final Translations$time$zh time = Translations$time$zh.internal(_root);
	@override late final Translations$greeting$zh greeting = Translations$greeting$zh.internal(_root);
	@override late final Translations$navigation$zh navigation = Translations$navigation$zh.internal(_root);
	@override late final Translations$auth$zh auth = Translations$auth$zh.internal(_root);
	@override late final Translations$transaction$zh transaction = Translations$transaction$zh.internal(_root);
	@override late final Translations$home$zh home = Translations$home$zh.internal(_root);
	@override late final Translations$comment$zh comment = Translations$comment$zh.internal(_root);
	@override late final Translations$calendar$zh calendar = Translations$calendar$zh.internal(_root);
	@override late final Translations$category$zh category = Translations$category$zh.internal(_root);
	@override late final Translations$settings$zh settings = Translations$settings$zh.internal(_root);
	@override late final Translations$appearance$zh appearance = Translations$appearance$zh.internal(_root);
	@override late final Translations$speech$zh speech = Translations$speech$zh.internal(_root);
	@override late final Translations$amountTheme$zh amountTheme = Translations$amountTheme$zh.internal(_root);
	@override late final Translations$locale$zh locale = Translations$locale$zh.internal(_root);
	@override late final Translations$budget$zh budget = Translations$budget$zh.internal(_root);
	@override late final Translations$dateRange$zh dateRange = Translations$dateRange$zh.internal(_root);
	@override late final Translations$forecast$zh forecast = Translations$forecast$zh.internal(_root);
	@override late final Translations$chat$zh chat = Translations$chat$zh.internal(_root);
	@override late final Translations$footprint$zh footprint = Translations$footprint$zh.internal(_root);
	@override late final Translations$media$zh media = Translations$media$zh.internal(_root);
	@override late final Translations$error$zh error = Translations$error$zh.internal(_root);
	@override late final Translations$fontTest$zh fontTest = Translations$fontTest$zh.internal(_root);
	@override late final Translations$wizard$zh wizard = Translations$wizard$zh.internal(_root);
	@override late final Translations$user$zh user = Translations$user$zh.internal(_root);
	@override late final Translations$account$zh account = Translations$account$zh.internal(_root);
	@override late final Translations$financial$zh financial = Translations$financial$zh.internal(_root);
	@override late final Translations$app$zh app = Translations$app$zh.internal(_root);
	@override late final Translations$statistics$zh statistics = Translations$statistics$zh.internal(_root);
	@override late final Translations$currency$zh currency = Translations$currency$zh.internal(_root);
	@override late final Translations$budgetSuggestion$zh budgetSuggestion = Translations$budgetSuggestion$zh.internal(_root);
	@override late final Translations$server$zh server = Translations$server$zh.internal(_root);
	@override late final Translations$sharedSpace$zh sharedSpace = Translations$sharedSpace$zh.internal(_root);
	@override late final Translations$errorMapping$zh errorMapping = Translations$errorMapping$zh.internal(_root);
	@override late final Translations$notification$zh notification = Translations$notification$zh.internal(_root);
}

// Path: common
class Translations$common$zh implements Translations$common$en {
	Translations$common$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get loading => '加载中...';
	@override String get error => '错误';
	@override String get retry => '重试';
	@override String get cancel => '取消';
	@override String get confirm => '确认';
	@override String get save => '保存';
	@override String get delete => '删除';
	@override String get edit => '编辑';
	@override String get add => '添加';
	@override String get search => '搜索';
	@override String get filter => '筛选';
	@override String get sort => '排序';
	@override String get refresh => '刷新';
	@override String get more => '更多';
	@override String get less => '收起';
	@override String get all => '全部';
	@override String get none => '无';
	@override String get ok => '确定';
	@override String get unknown => '未知';
	@override String get noData => '暂无数据';
	@override String get loadMore => '加载更多';
	@override String get noMore => '没有更多了';
	@override String get loadFailed => '加载失败';
	@override String get history => '交易记录';
	@override String get reset => '重置';
}

// Path: time
class Translations$time$zh implements Translations$time$en {
	Translations$time$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get today => '今天';
	@override String get yesterday => '昨天';
	@override String get dayBeforeYesterday => '前天';
	@override String get thisWeek => '本周';
	@override String get thisMonth => '本月';
	@override String get thisYear => '今年';
	@override String get selectDate => '选择日期';
	@override String get selectTime => '选择时间';
	@override String get justNow => '刚刚';
	@override String minutesAgo({required Object count}) => '${count}分钟前';
	@override String hoursAgo({required Object count}) => '${count}小时前';
	@override String daysAgo({required Object count}) => '${count}天前';
	@override String weeksAgo({required Object count}) => '${count}周前';
}

// Path: greeting
class Translations$greeting$zh implements Translations$greeting$en {
	Translations$greeting$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get morning => '上午好';
	@override String get afternoon => '下午好';
	@override String get evening => '晚上好';
}

// Path: navigation
class Translations$navigation$zh implements Translations$navigation$en {
	Translations$navigation$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get home => '首页';
	@override String get forecast => '预测';
	@override String get footprint => '足迹';
	@override String get profile => '我的';
}

// Path: auth
class Translations$auth$zh implements Translations$auth$en {
	Translations$auth$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get login => '登录';
	@override String get loggingIn => '登录中...';
	@override String get logout => '退出';
	@override String get logoutSuccess => '已成功退出登录';
	@override String get confirmLogoutTitle => '确认退出登录';
	@override String get confirmLogoutContent => '您确定要退出当前的登录状态吗？';
	@override String get register => '注册';
	@override String get registering => '注册中...';
	@override String get welcomeBack => '欢迎回来';
	@override String get loginSuccess => '欢迎回来!';
	@override String get loginFailed => '登录失败';
	@override String get pleaseTryAgain => '请稍后重试。';
	@override String get loginSubtitle => '登录以继续使用 AI 记账助理';
	@override String get noAccount => '还没有账户？注册';
	@override String get createAccount => '创建您的账户';
	@override String get setPassword => '设置密码';
	@override String get setAccountPassword => '设置您的账户密码';
	@override String get completeRegistration => '完成注册';
	@override String get registrationSuccess => '注册成功!';
	@override String get registrationFailed => '注册失败';
	@override late final Translations$auth$email$zh email = Translations$auth$email$zh.internal(_root);
	@override late final Translations$auth$password$zh password = Translations$auth$password$zh.internal(_root);
	@override late final Translations$auth$verificationCode$zh verificationCode = Translations$auth$verificationCode$zh.internal(_root);
}

// Path: transaction
class Translations$transaction$zh implements Translations$transaction$en {
	Translations$transaction$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get expense => '支出';
	@override String get income => '收入';
	@override String get transfer => '转账';
	@override String get amount => '金额';
	@override String get category => '分类';
	@override String get description => '描述';
	@override String get tags => '标签';
	@override String get saveTransaction => '保存记账';
	@override String get pleaseEnterAmount => '请输入金额';
	@override String get pleaseSelectCategory => '请选择分类';
	@override String get saveFailed => '保存失败';
	@override String get descriptionHint => '记录这笔交易的详细信息...';
	@override String get addCustomTag => '添加自定义标签';
	@override String get commonTags => '常用标签';
	@override String maxTagsHint({required Object maxTags}) => '最多添加 ${maxTags} 个标签';
	@override String get noTransactionsFound => '没有找到交易记录';
	@override String get tryAdjustingSearch => '尝试调整搜索条件或创建新的交易记录';
	@override String get noDescription => '无描述';
	@override String get payment => '支付';
	@override String get account => '账户';
	@override String get time => '时间';
	@override String get location => '地点';
	@override String get recorder => '记录人';
	@override String get transactionDetail => '交易详情';
	@override String get favorite => '收藏';
	@override String get confirmDelete => '确认删除';
	@override String get deleteTransactionConfirm => '您确定要删除此条交易记录吗？此操作无法撤销。';
	@override String get noActions => '没有可用的操作';
	@override String get deleted => '已删除';
	@override String get deleteFailed => '删除失败，请稍后重试';
	@override String get linkedAccount => '关联账户';
	@override String get linkedSpace => '关联空间';
	@override String get notLinked => '未关联';
	@override String get link => '关联';
	@override String get changeAccount => '更换账户';
	@override String get addSpace => '添加空间';
	@override String nSpaces({required Object count}) => '${count} 个空间';
	@override String get selectLinkedAccount => '选择关联账户';
	@override String get selectLinkedSpace => '选择关联空间';
	@override String get noSpacesAvailable => '暂无可用空间';
	@override String get linkSuccess => '关联成功';
	@override String get linkFailed => '关联失败';
	@override String get rawInput => '消息';
	@override String get noRawInput => '无消息';
	@override String attachments({required Object count}) => '${count} 个附件';
	@override String get viewInConversation => '在对话中查看更多';
	@override String get statusPending => '待确认';
}

// Path: home
class Translations$home$zh implements Translations$home$en {
	Translations$home$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get totalExpense => '总消费金额';
	@override String get todayExpense => '今日支出';
	@override String get monthExpense => '本月支出';
	@override String yearProgress({required Object year}) => '${year}年进度';
	@override String yearRemainingInfo({required Object days, required Object percent}) => '余 ${days} 天 · ${percent}%';
	@override String get amountHidden => '••••••••';
	@override String get loadFailed => '加载失败';
	@override String get noTransactions => '暂无交易记录';
	@override String get tryRefresh => '刷新试试';
	@override String get noMoreData => '没有更多数据了';
	@override String get userNotLoggedIn => '用户未登录，无法加载数据';
}

// Path: comment
class Translations$comment$zh implements Translations$comment$en {
	Translations$comment$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get error => '错误';
	@override String get commentFailed => '评论失败';
	@override String replyToPrefix({required Object name}) => '回复 @${name}:';
	@override String get reply => '回复';
	@override String get addNote => '添加备注...';
	@override String get addNoteWithMention => '评论或 @提及成员...';
	@override String get confirmDeleteTitle => '确认删除';
	@override String get confirmDeleteContent => '你确定要删除这条评论吗？此操作无法撤销。';
	@override String get success => '成功';
	@override String get commentDeleted => '评论已删除';
	@override String get deleteFailed => '删除失败';
	@override String get deleteComment => '删除评论';
	@override String get hint => '提示';
	@override String get noActions => '没有可用的操作';
	@override String get note => '备注';
	@override String get noNote => '暂无备注';
	@override String get loadFailed => '加载备注失败';
}

// Path: calendar
class Translations$calendar$zh implements Translations$calendar$en {
	Translations$calendar$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '消费日历';
	@override late final Translations$calendar$weekdays$zh weekdays = Translations$calendar$weekdays$zh.internal(_root);
	@override String get loadFailed => '加载日历数据失败';
	@override String thisMonth({required Object amount}) => '本月: ${amount}';
	@override String get counting => '统计中...';
	@override String get unableToCount => '无法统计';
	@override String get trend => '趋势: ';
	@override String get noTransactionsTitle => '当日无交易记录';
	@override String get loadTransactionFailed => '加载交易失败';
}

// Path: category
class Translations$category$zh implements Translations$category$en {
	Translations$category$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get dailyConsumption => '日常消费';
	@override String get transportation => '交通出行';
	@override String get healthcare => '医疗健康';
	@override String get housing => '住房物业';
	@override String get education => '教育培训';
	@override String get incomeCategory => '收入进账';
	@override String get socialGifts => '社交馈赠';
	@override String get moneyTransfer => '资金周转';
	@override String get other => '其他';
	@override String get foodDining => '餐饮美食';
	@override String get shoppingRetail => '购物消费';
	@override String get housingUtilities => '居住物业';
	@override String get personalCare => '个人护理';
	@override String get entertainment => '休闲娱乐';
	@override String get medicalHealth => '医疗健康';
	@override String get insurance => '保险';
	@override String get socialGifting => '人情往来';
	@override String get financialTax => '金融税务';
	@override String get others => '其他支出';
	@override String get salaryWage => '工资薪水';
	@override String get businessTrade => '经营交易';
	@override String get investmentReturns => '投资回报';
	@override String get giftBonus => '礼金红包';
	@override String get refundRebate => '退款返利';
	@override String get generalTransfer => '转账';
	@override String get debtRepayment => '债务还款';
}

// Path: settings
class Translations$settings$zh implements Translations$settings$en {
	Translations$settings$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '设置';
	@override String get language => '语言';
	@override String get languageSettings => '语言设置';
	@override String get selectLanguage => '选择语言';
	@override String get languageChanged => '语言已更改';
	@override String get restartToApply => '重启应用以应用更改';
	@override String get theme => '主题';
	@override String get darkMode => '深色模式';
	@override String get lightMode => '浅色模式';
	@override String get systemMode => '跟随系统';
	@override String get developerOptions => '开发者选项';
	@override String get authDebug => '认证状态调试';
	@override String get authDebugSubtitle => '查看认证状态和调试信息';
	@override String get fontTest => '字体测试';
	@override String get fontTestSubtitle => '测试应用字体显示效果';
	@override String get helpAndFeedback => '帮助与反馈';
	@override String get helpAndFeedbackSubtitle => '获取帮助或提供反馈';
	@override String get aboutApp => '关于应用';
	@override String get aboutAppSubtitle => '版本信息和检查更新';
	@override String get checkUpdate => '检查更新';
	@override String get checkingUpdate => '正在检查更新...';
	@override String get latestVersionToast => '当前已是最新版本';
	@override String get newVersionTitle => '发现新版本';
	@override String get updateNow => '立即更新';
	@override String get updateLater => '暂不更新';
	@override String get fetchUpdateFailed => '检查更新失败，请稍后重试';
	@override String currencyChangedRefreshHint({required Object currency}) => '已切换为 ${currency}，新交易将以此货币记录';
	@override String get sharedSpace => '共享空间';
	@override String get speechRecognition => '语音识别';
	@override String get speechRecognitionSubtitle => '配置语音输入参数';
	@override String get amountDisplayStyle => '金额显示样式';
	@override String get currency => '显示币种';
	@override String get appearance => '外观设置';
	@override String get appearanceSubtitle => '主题模式与配色方案';
	@override String get speechTest => '语音测试';
	@override String get speechTestSubtitle => '测试 WebSocket 语音连接';
	@override String get userTypeRegular => '普通用户';
	@override String get selectAmountStyle => '选择金额显示样式';
	@override String get amountStyleNotice => '注意：金额样式主要应用于「交易流水」和「趋势分析」。为了保持视觉清晰，「账户余额」和「资产概览」等状态类数值将保持中性颜色。';
	@override String get currencyDescription => '选择您的主要货币。未来的记账将默认使用此货币，统计和汇总也将以此货币显示。历史交易的原始金额不受影响。';
	@override String get editUsername => '修改用户名';
	@override String get enterUsername => '请输入用户名';
	@override String get usernameRequired => '用户名不能为空';
	@override String get usernameUpdated => '用户名已更新';
	@override String get avatarUpdated => '头像已更新';
	@override String get appearanceUpdated => '外观设置已更新';
}

// Path: appearance
class Translations$appearance$zh implements Translations$appearance$en {
	Translations$appearance$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '外观设置';
	@override String get themeMode => '主题模式';
	@override String get light => '浅色';
	@override String get dark => '深色';
	@override String get system => '跟随系统';
	@override String get colorScheme => '配色方案';
	@override late final Translations$appearance$palettes$zh palettes = Translations$appearance$palettes$zh.internal(_root);
}

// Path: speech
class Translations$speech$zh implements Translations$speech$en {
	Translations$speech$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '语音识别设置';
	@override String get service => '语音识别服务';
	@override String get systemVoice => '系统语音';
	@override String get systemVoiceSubtitle => '使用手机内置的语音识别服务（推荐）';
	@override String get selfHostedASR => '自建 ASR 服务';
	@override String get selfHostedASRSubtitle => '使用 WebSocket 连接到自建语音识别服务';
	@override String get serverConfig => '服务器配置';
	@override String get serverAddress => '服务器地址';
	@override String get port => '端口';
	@override String get path => '路径';
	@override String get saveConfig => '保存配置';
	@override String get info => '信息';
	@override String get infoContent => '• 系统语音：使用设备内置服务，无需配置，响应更快\n• 自建 ASR：适用于自定义模型或离线场景\n\n更改将在下次使用语音输入时生效。';
	@override String get enterAddress => '请输入服务器地址';
	@override String get enterValidPort => '请输入有效的端口 (1-65535)';
	@override String get configSaved => '配置已保存';
	@override String get systemVoiceRestrictedTitle => '系统语音不可用';
	@override String get systemVoiceRestrictedContent => '您的手机系统语音引擎不可用或服务未开启。建议在设置中开启语音服务或配置 WebSocket 自建语音服务。';
	@override String get dictationDisabledTitle => '语音听写未开启';
	@override String get dictationDisabledContent => '系统语音听写服务未开启。如果是 iOS 设备，请前往【设置 -> 通用 -> 键盘】开启【启用听写】。';
	@override String get permissionDeniedTitle => '缺少语音权限';
	@override String get permissionDeniedContent => '应用需要麦克风和语音识别权限才能使用此功能。请在系统设置中允许权限。';
	@override String get goToSettings => '前往设置';
	@override String get systemVoiceStatusAvailable => '系统语音服务支持正常';
	@override String get systemVoiceStatusRestricted => '系统语音限制或不可用 (建议使用自建 ASR)';
	@override String get serviceNotConfigured => '语音服务未配置，请在【设置 -> 语音识别】中配置服务器地址';
	@override String get connectionFailedTitle => '语音服务连接失败';
	@override String get connectionFailed => '无法连接到 WebSocket 语音识别服务，请检查服务器地址、端口或网络连通性。';
	@override String get noSpeechRecognized => '未检测到语音输入，请重试';
}

// Path: amountTheme
class Translations$amountTheme$zh implements Translations$amountTheme$en {
	Translations$amountTheme$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get chinaMarket => '中国市场';
	@override String get chinaMarketDesc => '红涨绿跌/黑跌';
	@override String get international => '国际标准';
	@override String get internationalDesc => '绿涨红跌';
	@override String get minimalist => '极简模式';
	@override String get minimalistDesc => '仅通过符号区分';
	@override String get colorBlind => '色弱友好';
	@override String get colorBlindDesc => '蓝橙配色方案';
}

// Path: locale
class Translations$locale$zh implements Translations$locale$en {
	Translations$locale$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get chinese => '中文（简体）';
	@override String get traditionalChinese => '中文（繁体）';
	@override String get english => 'English';
	@override String get japanese => '日本語';
	@override String get korean => '한국어';
}

// Path: budget
class Translations$budget$zh implements Translations$budget$en {
	Translations$budget$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '预算管理';
	@override String get detail => '预算详情';
	@override String get info => '预算信息';
	@override String get totalBudget => '总预算';
	@override String get categoryBudget => '分类预算';
	@override String get monthlySummary => '本月预算汇总';
	@override String get used => '已使用';
	@override String get remaining => '剩余';
	@override String get overspent => '超支';
	@override String get budget => '预算';
	@override String get loadFailed => '加载失败';
	@override String get noBudget => '暂无预算';
	@override String get createHint => '点击下方按钮设置您的预算';
	@override String get paused => '已暂停';
	@override String get pause => '暂停';
	@override String get resume => '恢复';
	@override String get budgetPaused => '预算已暂停';
	@override String get budgetResumed => '预算已恢复';
	@override String get operationFailed => '操作失败';
	@override String get deleteBudget => '删除预算';
	@override String get deleteConfirm => '确定要删除这个预算吗？此操作不可撤销。';
	@override String get type => '类型';
	@override String get category => '分类';
	@override String get period => '周期';
	@override String get rollover => '滚动预算';
	@override String get rolloverBalance => '滚动余额';
	@override String get enabled => '开启';
	@override String get disabled => '关闭';
	@override String get statusNormal => '预算正常';
	@override String get statusWarning => '接近上限';
	@override String get statusOverspent => '已超支';
	@override String get statusAchieved => '目标达成';
	@override String tipNormal({required Object amount}) => '还剩 ${amount} 可用';
	@override String tipWarning({required Object amount}) => '仅剩 ${amount}，请注意控制';
	@override String tipOverspent({required Object amount}) => '已超支 ${amount}';
	@override String get tipAchieved => '恭喜完成储蓄目标！';
	@override String remainingAmount({required Object amount}) => '剩余 ${amount}';
	@override String overspentAmount({required Object amount}) => '超支 ${amount}';
	@override String budgetAmount({required Object amount}) => '预算 ${amount}';
	@override String get active => '活跃';
	@override String get all => '全部';
	@override String get notFound => '预算不存在或已被删除';
	@override String get setup => '预算设置';
	@override String get settings => '预算设置';
	@override String get setAmount => '设置预算金额';
	@override String get setAmountDesc => '为每个分类设置预算金额';
	@override String get monthly => '月度预算';
	@override String get monthlyDesc => '按月管理您的支出，适合大多数人';
	@override String get weekly => '周预算';
	@override String get weeklyDesc => '按周管理支出，更精细的控制';
	@override String get yearly => '年度预算';
	@override String get yearlyDesc => '长期财务规划，适合大额支出管理';
	@override String get editBudget => '编辑预算';
	@override String get editBudgetDesc => '修改预算金额和分类';
	@override String get reminderSettings => '提醒设置';
	@override String get reminderSettingsDesc => '设置预算提醒和通知';
	@override String get report => '预算报告';
	@override String get reportDesc => '查看详细的预算分析报告';
	@override String get welcome => '欢迎使用预算功能！';
	@override String get createNewPlan => '创建新的预算计划';
	@override String get welcomeDesc => '通过设置预算，您可以更好地控制支出，实现财务目标。让我们开始设置您的第一个预算计划吧！';
	@override String get createDesc => '为不同的支出类别设置预算限额，帮助您更好地管理财务。';
	@override String get newBudget => '新建预算';
	@override String get budgetAmountLabel => '预算金额';
	@override String get currency => '货币';
	@override String get periodSettings => '周期设置';
	@override String get autoGenerateTransactions => '开启后按规则自动生成交易';
	@override String get cycle => '周期';
	@override String get budgetCategory => '预算分类';
	@override String get advancedOptions => '高级选项';
	@override String get periodType => '周期类型';
	@override String get anchorDay => '起算日';
	@override String get selectPeriodType => '选择周期类型';
	@override String get selectAnchorDay => '选择起算日';
	@override String get rolloverDescription => '未用完的预算结转到下期';
	@override String get createBudget => '创建预算';
	@override String get save => '保存';
	@override String get pleaseEnterAmount => '请输入预算金额';
	@override String get invalidAmount => '请输入有效的预算金额';
	@override String get updateSuccess => '预算更新成功';
	@override String get createSuccess => '预算创建成功';
	@override String get deleteSuccess => '预算已删除';
	@override String get deleteFailed => '删除失败';
	@override String everyMonthDay({required Object day}) => '每月 ${day} 号';
	@override String get periodWeekly => '每周';
	@override String get periodBiweekly => '双周';
	@override String get periodMonthly => '每月';
	@override String get periodYearly => '每年';
	@override String get statusActive => '进行中';
	@override String get statusArchived => '已归档';
	@override String get periodStatusOnTrack => '正常';
	@override String get periodStatusWarning => '预警';
	@override String get periodStatusExceeded => '超支';
	@override String get periodStatusAchieved => '达成';
	@override String usedPercent({required Object percent}) => '${percent}% 已使用';
	@override String dayOfMonth({required Object day}) => '${day} 号';
	@override String get tenThousandSuffix => '万';
	@override String get settingsLoadFailed => '加载设置失败';
	@override String get settingsSaveSuccess => '设置已保存';
	@override String get settingsSaveFailed => '保存失败';
	@override String get settingsSave => '保存设置';
	@override String get settingsWarningThreshold => '预警阈值';
	@override String get settingsWarningDesc => '当使用率达到此百分比时显示预警状态';
	@override String get settingsAlertThreshold => '超支阈值';
	@override String get settingsAlertDesc => '当使用率达到此百分比时显示超支状态';
	@override String get settingsThresholdOrder => '预警阈值不能大于超支阈值';
}

// Path: dateRange
class Translations$dateRange$zh implements Translations$dateRange$en {
	Translations$dateRange$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get custom => '自定义';
	@override String get pickerTitle => '选择时间范围';
	@override String get startDate => '开始日期';
	@override String get endDate => '结束日期';
	@override String get hint => '请选择日期范围';
}

// Path: forecast
class Translations$forecast$zh implements Translations$forecast$en {
	Translations$forecast$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '预测';
	@override String get subtitle => '基于您的财务数据智能预测未来现金流';
	@override String get financialNavigator => '你好，我是你的财务领航员';
	@override String get financialMapSubtitle => '只需3步，我们一起绘制你未来的财务地图';
	@override String get predictCashFlow => '预测未来现金流';
	@override String get predictCashFlowDesc => '看清每一天的财务状况';
	@override String get aiSmartSuggestions => 'AI智能建议';
	@override String get aiSmartSuggestionsDesc => '个性化的财务决策指导';
	@override String get riskWarning => '风险预警';
	@override String get riskWarningDesc => '提前发现潜在的财务风险';
	@override String get analyzing => '我正在分析你的财务数据，生成未来30天的现金流预测';
	@override String get analyzePattern => '分析收入支出模式';
	@override String get calculateTrend => '计算现金流趋势';
	@override String get generateWarning => '生成风险预警';
	@override String get loadingForecast => '正在加载财务预测...';
	@override String get todayLabel => '今日';
	@override String get tomorrowLabel => '明日';
	@override String get balanceLabel => '余额';
	@override String get noSpecialEvents => '无特殊事件';
	@override String get financialSafetyLine => '财务安全线';
	@override String get currentSetting => '当前设置';
	@override String get dailySpendingEstimate => '日常消费预估';
	@override String get adjustDailySpendingAmount => '调整每日消费预测金额';
	@override String get tellMeYourSafetyLine => '告诉我你的财务"安心线"是多少？';
	@override String get safetyLineDescription => '这是你希望账户保持的最低余额，当余额接近这个数值时，我会提醒你注意财务风险。';
	@override String get dailySpendingQuestion => '每天的"小日子"大概花多少？';
	@override String get dailySpendingDescription => '包括吃饭、交通、购物等日常开销\n这只是一个初始估算，我会通过你未来的真实记录，让预测越来越准';
	@override String get perDay => '每天';
	@override String get referenceStandard => '参考标准';
	@override String get frugalType => '节俭型';
	@override String get comfortableType => '舒适型';
	@override String get relaxedType => '宽松型';
	@override String get frugalAmount => '50-100元/天';
	@override String get comfortableAmount => '100-200元/天';
	@override String get relaxedAmount => '200-300元/天';
	@override late final Translations$forecast$recurringTransaction$zh recurringTransaction = Translations$forecast$recurringTransaction$zh.internal(_root);
}

// Path: chat
class Translations$chat$zh implements Translations$chat$en {
	Translations$chat$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get newChat => '新聊天';
	@override String get noMessages => '没有消息可显示。';
	@override String get loadingFailed => '加载失败';
	@override String get inputMessage => '输入消息...';
	@override String get listening => '正在聆听...';
	@override String get aiThinking => '正在处理...';
	@override late final Translations$chat$tools$zh tools = Translations$chat$tools$zh.internal(_root);
	@override String get speechNotRecognized => '未识别到语音，请重试';
	@override String get currentExpense => '当前支出';
	@override String get loadingComponent => '正在加载组件...';
	@override String get noHistory => '暂无历史会话';
	@override String get startNewChat => '开启一段新对话吧！';
	@override String get searchHint => '搜索会话';
	@override String get library => '库';
	@override String get viewProfile => '查看个人资料';
	@override String get noRelatedFound => '未找到相关会话';
	@override String get tryOtherKeywords => '尝试搜索其他关键词';
	@override String get searchFailed => '搜索失败';
	@override String get deleteConversation => '删除会话';
	@override String get deleteConversationConfirm => '确定要删除这个会话吗？此操作无法撤销。';
	@override String get conversationDeleted => '会话已删除';
	@override String get deleteConversationFailed => '删除会话失败';
	@override late final Translations$chat$transferWizard$zh transferWizard = Translations$chat$transferWizard$zh.internal(_root);
	@override late final Translations$chat$genui$zh genui = Translations$chat$genui$zh.internal(_root);
	@override late final Translations$chat$welcome$zh welcome = Translations$chat$welcome$zh.internal(_root);
}

// Path: footprint
class Translations$footprint$zh implements Translations$footprint$en {
	Translations$footprint$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get searchIn => '搜索';
	@override String get searchInAllRecords => '在所有记录中搜索相关内容';
}

// Path: media
class Translations$media$zh implements Translations$media$en {
	Translations$media$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get selectPhotos => '选择照片';
	@override String get addFiles => '添加文件';
	@override String get takePhoto => '拍照';
	@override String get camera => '相机';
	@override String get photos => '照片';
	@override String get files => '文件';
	@override String get showAll => '显示全部';
	@override String get allPhotos => '所有照片';
	@override String get takingPhoto => '拍照中...';
	@override String get photoTaken => '照片已保存';
	@override String get cameraPermissionRequired => '需要相机权限';
	@override String get fileSizeExceeded => '文件大小超过10MB限制';
	@override String get unsupportedFormat => '不支持的文件格式';
	@override String get permissionDenied => '需要相册访问权限';
	@override String get storageInsufficient => '存储空间不足';
	@override String get networkError => '网络连接错误';
	@override String get unknownUploadError => '上传时发生未知错误';
}

// Path: error
class Translations$error$zh implements Translations$error$en {
	Translations$error$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get permissionRequired => '需要权限';
	@override String get permissionInstructions => '请在设置中开启相册和存储权限，以便选择和上传文件。';
	@override String get openSettings => '打开设置';
	@override String get fileTooLarge => '文件过大';
	@override String get fileSizeHint => '请选择小于10MB的文件，或者压缩后再上传。';
	@override String get supportedFormatsHint => '支持的格式包括：图片(jpg, png, gif等)、文档(pdf, doc, txt等)、音视频文件等。';
	@override String get storageCleanupHint => '请清理设备存储空间后重试，或选择较小的文件。';
	@override String get networkErrorHint => '请检查网络连接是否正常，然后重试。';
	@override String get platformNotSupported => '平台不支持';
	@override String get fileReadError => '文件读取失败';
	@override String get fileReadErrorHint => '文件可能已损坏或被其他程序占用，请重新选择文件。';
	@override String get validationError => '文件验证失败';
	@override String get unknownError => '未知错误';
	@override String get unknownErrorHint => '发生了意外错误，请重试或联系技术支持。';
	@override String get registrationMissingInfo => '注册流程错误，缺少必要信息。';
	@override late final Translations$error$genui$zh genui = Translations$error$genui$zh.internal(_root);
}

// Path: fontTest
class Translations$fontTest$zh implements Translations$fontTest$en {
	Translations$fontTest$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get page => '字体测试页面';
	@override String get displayTest => '字体显示测试';
	@override String get chineseTextTest => '中文文本测试';
	@override String get englishTextTest => '英文文本测试';
	@override String get sample1 => '这是一段中文文本，用于测试字体显示效果。';
	@override String get sample2 => '支出分类汇总，购物最高';
	@override String get sample3 => '人工智能助手为您提供专业的财务分析服务';
	@override String get sample4 => '数据可视化图表展示您的消费趋势';
	@override String get sample5 => '微信支付、支付宝、银行卡等多种支付方式';
}

// Path: wizard
class Translations$wizard$zh implements Translations$wizard$en {
	Translations$wizard$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get nextStep => '下一步';
	@override String get previousStep => '上一步';
	@override String get completeMapping => '完成绘制';
}

// Path: user
class Translations$user$zh implements Translations$user$en {
	Translations$user$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get username => '用户名';
	@override String get defaultEmail => 'user@example.com';
}

// Path: account
class Translations$account$zh implements Translations$account$en {
	Translations$account$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get editTitle => '编辑账户';
	@override String get addTitle => '新建账户';
	@override String get selectTypeTitle => '选择账户类型';
	@override String get nameLabel => '账户名称';
	@override String get amountLabel => '当前余额';
	@override String get currencyLabel => '币种';
	@override String get hiddenLabel => '隐藏';
	@override String get hiddenDesc => '在账户列表中隐藏该账户';
	@override String get includeInNetWorthLabel => '计入资产';
	@override String get includeInNetWorthDesc => '用于净资产统计';
	@override String get nameHint => '例如：工资卡';
	@override String get amountHint => '0.00';
	@override String get deleteAccount => '删除账户';
	@override String get deleteConfirm => '确定要删除该账户吗？此操作无法撤销。';
	@override String get save => '保存修改';
	@override String get assetsCategory => '资产类';
	@override String get liabilitiesCategory => '负债/信用类';
	@override String get cash => '现金钱包';
	@override String get deposit => '银行存款';
	@override String get creditCard => '信用卡';
	@override String get investment => '投资理财';
	@override String get eWallet => '电子钱包';
	@override String get loan => '贷款账户';
	@override String get receivable => '应收款项';
	@override String get payable => '应付款项';
	@override String get other => '其他账户';
	@override late final Translations$account$types$zh types = Translations$account$types$zh.internal(_root);
}

// Path: financial
class Translations$financial$zh implements Translations$financial$en {
	Translations$financial$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '财务';
	@override String get management => '财务管理';
	@override String get netWorth => '总净值';
	@override String get assets => '总资产';
	@override String get liabilities => '总负债';
	@override String get noAccounts => '暂无账户';
	@override String get addFirstAccount => '点击下方按钮添加您的第一个账户';
	@override String get assetAccounts => '资产账户';
	@override String get liabilityAccounts => '负债账户';
	@override String get selectCurrency => '选择货币';
	@override String get cancel => '取消';
	@override String get confirm => '确定';
	@override String get settings => '财务设置';
	@override String get budgetManagement => '预算管理';
	@override String get recurringTransactions => '周期交易';
	@override String get safetyThreshold => '安全阈值';
	@override String get dailyBurnRate => '每日消费';
	@override String get financialAssistant => '财务助手';
	@override String get manageFinancialSettings => '管理您的财务设置';
	@override String get safetyThresholdSettings => '财务安全线设置';
	@override String get setSafetyThreshold => '设置您的财务安全阈值';
	@override String get safetyThresholdSaved => '财务安全线已保存';
	@override String get dailyBurnRateSettings => '日常消费预估';
	@override String get setDailyBurnRate => '设置您的日常消费预估金额';
	@override String get dailyBurnRateSaved => '日常消费预估已保存';
	@override String get dayUnit => '天';
	@override String get saveFailed => '保存失败';
}

// Path: app
class Translations$app$zh implements Translations$app$en {
	Translations$app$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get splashTitle => '智见增长，格物致富。';
	@override String get splashSubtitle => '智能财务助手';
}

// Path: statistics
class Translations$statistics$zh implements Translations$statistics$en {
	Translations$statistics$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '统计分析';
	@override String get analyze => '统计分析';
	@override String get exportInProgress => '导出功能开发中...';
	@override String get ranking => '大额消费排行';
	@override String get noData => '暂无数据';
	@override late final Translations$statistics$overview$zh overview = Translations$statistics$overview$zh.internal(_root);
	@override late final Translations$statistics$trend$zh trend = Translations$statistics$trend$zh.internal(_root);
	@override late final Translations$statistics$analysis$zh analysis = Translations$statistics$analysis$zh.internal(_root);
	@override late final Translations$statistics$filter$zh filter = Translations$statistics$filter$zh.internal(_root);
	@override late final Translations$statistics$sort$zh sort = Translations$statistics$sort$zh.internal(_root);
	@override String get exportList => '导出列表';
	@override late final Translations$statistics$emptyState$zh emptyState = Translations$statistics$emptyState$zh.internal(_root);
	@override String get noMoreData => '没有更多数据了';
}

// Path: currency
class Translations$currency$zh implements Translations$currency$en {
	Translations$currency$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get cny => '人民币';
	@override String get usd => '美元';
	@override String get eur => '欧元';
	@override String get jpy => '日元';
	@override String get gbp => '英镑';
	@override String get aud => '澳元';
	@override String get cad => '加元';
	@override String get chf => '瑞士法郎';
	@override String get rub => '俄罗斯卢布';
	@override String get hkd => '港币';
	@override String get twd => '新台币';
	@override String get inr => '印度卢比';
}

// Path: budgetSuggestion
class Translations$budgetSuggestion$zh implements Translations$budgetSuggestion$en {
	Translations$budgetSuggestion$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String highPercentage({required Object category, required Object percentage}) => '${category} 占支出的 ${percentage}%，建议设置预算上限';
	@override String monthlyIncrease({required Object percentage}) => '本月支出增长了 ${percentage}%，需要关注';
	@override String frequentSmall({required Object category, required Object count}) => '${category} 有 ${count} 笔小额交易，可能是订阅消费';
	@override String get financialInsights => '财务洞察';
}

// Path: server
class Translations$server$zh implements Translations$server$en {
	Translations$server$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '连接服务器';
	@override String get subtitle => '输入您自部署的服务器地址，或扫描服务器启动时显示的二维码';
	@override String get urlLabel => '服务器地址';
	@override String get urlPlaceholder => '例如：https://api.example.com 或 192.168.1.100:8000';
	@override String get scanQr => '扫描二维码';
	@override String get scanQrInstruction => '对准服务器终端显示的二维码';
	@override String get testConnection => '测试连接';
	@override String get connecting => '正在连接...';
	@override String get connected => '已连接';
	@override String get connectionFailed => '连接失败';
	@override String get continueToLogin => '继续登录';
	@override String get saveAndReturn => '保存并返回';
	@override String get saveAndReLogin => '保存并重新登录';
	@override String get serverUrlSavedRedirectLogin => '服务器配置已更新，请重新登录';
	@override String get serverSettings => '服务器设置';
	@override String get currentServer => '当前服务器';
	@override String get version => '版本';
	@override String get environment => '环境';
	@override String get changeServer => '更换服务器';
	@override String get changeServerWarning => '更换服务器将退出登录，是否继续？';
	@override late final Translations$server$error$zh error = Translations$server$error$zh.internal(_root);
}

// Path: sharedSpace
class Translations$sharedSpace$zh implements Translations$sharedSpace$en {
	Translations$sharedSpace$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override late final Translations$sharedSpace$dashboard$zh dashboard = Translations$sharedSpace$dashboard$zh.internal(_root);
	@override late final Translations$sharedSpace$roles$zh roles = Translations$sharedSpace$roles$zh.internal(_root);
	@override String get title => '共享空间';
	@override late final Translations$sharedSpace$create$zh create = Translations$sharedSpace$create$zh.internal(_root);
	@override late final Translations$sharedSpace$join$zh join = Translations$sharedSpace$join$zh.internal(_root);
	@override late final Translations$sharedSpace$list$zh list = Translations$sharedSpace$list$zh.internal(_root);
	@override late final Translations$sharedSpace$detail$zh detail = Translations$sharedSpace$detail$zh.internal(_root);
	@override late final Translations$sharedSpace$notifications$zh notifications = Translations$sharedSpace$notifications$zh.internal(_root);
	@override late final Translations$sharedSpace$inviteCard$zh inviteCard = Translations$sharedSpace$inviteCard$zh.internal(_root);
	@override late final Translations$sharedSpace$inviteSuccess$zh inviteSuccess = Translations$sharedSpace$inviteSuccess$zh.internal(_root);
	@override late final Translations$sharedSpace$notificationCard$zh notificationCard = Translations$sharedSpace$notificationCard$zh.internal(_root);
	@override late final Translations$sharedSpace$spaceCard$zh spaceCard = Translations$sharedSpace$spaceCard$zh.internal(_root);
	@override late final Translations$sharedSpace$settings$zh settings = Translations$sharedSpace$settings$zh.internal(_root);
}

// Path: errorMapping
class Translations$errorMapping$zh implements Translations$errorMapping$en {
	Translations$errorMapping$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override late final Translations$errorMapping$generic$zh generic = Translations$errorMapping$generic$zh.internal(_root);
	@override late final Translations$errorMapping$auth$zh auth = Translations$errorMapping$auth$zh.internal(_root);
	@override late final Translations$errorMapping$transaction$zh transaction = Translations$errorMapping$transaction$zh.internal(_root);
	@override late final Translations$errorMapping$space$zh space = Translations$errorMapping$space$zh.internal(_root);
	@override late final Translations$errorMapping$recurring$zh recurring = Translations$errorMapping$recurring$zh.internal(_root);
	@override late final Translations$errorMapping$upload$zh upload = Translations$errorMapping$upload$zh.internal(_root);
	@override late final Translations$errorMapping$storage$zh storage = Translations$errorMapping$storage$zh.internal(_root);
	@override late final Translations$errorMapping$ai$zh ai = Translations$errorMapping$ai$zh.internal(_root);
}

// Path: notification
class Translations$notification$zh implements Translations$notification$en {
	Translations$notification$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '消息通知';
	@override String get markAllRead => '全部已读';
	@override String get empty => '暂无通知消息';
	@override String get loadFailed => '加载失败';
	@override String get retry => '重试';
	@override String get justNow => '刚刚';
	@override String minutesAgo({required Object minutes}) => '${minutes}分钟前';
	@override String hoursAgo({required Object hours}) => '${hours}小时前';
	@override String daysAgo({required Object days}) => '${days}天前';
	@override String get deleted => '已删除';
	@override late final Translations$notification$types$zh types = Translations$notification$types$zh.internal(_root);
	@override late final Translations$notification$semantic$zh semantic = Translations$notification$semantic$zh.internal(_root);
}

// Path: auth.email
class Translations$auth$email$zh implements Translations$auth$email$en {
	Translations$auth$email$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get label => '邮箱';
	@override String get placeholder => '请输入您的邮箱';
	@override String get required => '邮箱不能为空';
	@override String get invalid => '请输入有效的邮箱地址';
}

// Path: auth.password
class Translations$auth$password$zh implements Translations$auth$password$en {
	Translations$auth$password$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get label => '密码';
	@override String get placeholder => '请输入您的密码';
	@override String get required => '密码不能为空';
	@override String get tooShort => '密码长度不能少于6位';
	@override String get mustContainNumbersAndLetters => '密码必须包含数字和字母';
	@override String get confirm => '确认密码';
	@override String get confirmPlaceholder => '请再次输入您的密码';
	@override String get mismatch => '两次输入的密码不一致';
}

// Path: auth.verificationCode
class Translations$auth$verificationCode$zh implements Translations$auth$verificationCode$en {
	Translations$auth$verificationCode$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get label => '验证码';
	@override String get get => '获取验证码';
	@override String get sending => '发送中...';
	@override String get sent => '验证码已发送';
	@override String get sendFailed => '发送失败';
	@override String get placeholder => '暂不校验，随意输入';
	@override String get required => '验证码不能为空';
}

// Path: calendar.weekdays
class Translations$calendar$weekdays$zh implements Translations$calendar$weekdays$en {
	Translations$calendar$weekdays$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

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
class Translations$appearance$palettes$zh implements Translations$appearance$palettes$en {
	Translations$appearance$palettes$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get zinc => '锌灰';
	@override String get slate => '板岩';
	@override String get red => '绯红';
	@override String get rose => '玫瑰';
	@override String get orange => '橙色';
	@override String get green => '绿色';
	@override String get blue => '蓝色';
	@override String get yellow => '黄色';
	@override String get violet => '紫罗兰';
}

// Path: forecast.recurringTransaction
class Translations$forecast$recurringTransaction$zh implements Translations$forecast$recurringTransaction$en {
	Translations$forecast$recurringTransaction$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '周期交易';
	@override String get all => '全部';
	@override String get expense => '支出';
	@override String get income => '收入';
	@override String get transfer => '转账';
	@override String get noRecurring => '暂无周期交易';
	@override String get createHint => '创建周期交易后，系统将自动为您生成交易记录';
	@override String get create => '创建周期交易';
	@override String get edit => '编辑周期交易';
	@override String get newTransaction => '新建周期交易';
	@override String deleteConfirm({required Object name}) => '确定要删除周期交易「${name}」吗？此操作不可撤销。';
	@override String activateConfirm({required Object name}) => '确定要启用周期交易「${name}」吗？启用后将按照设定的规则自动生成交易记录。';
	@override String pauseConfirm({required Object name}) => '确定要暂停周期交易「${name}」吗？暂停后将不再自动生成交易记录。';
	@override String get created => '周期交易已创建';
	@override String get updated => '周期交易已更新';
	@override String get activated => '已启用';
	@override String get paused => '已暂停';
	@override String get nextTime => '下次';
	@override String get sortByTime => '按时间排序';
	@override String get allPeriod => '全部周期';
	@override String periodCount({required Object type, required Object count}) => '${type}周期 (${count})';
	@override String get confirmDelete => '确认删除';
	@override String get confirmActivate => '确认启用';
	@override String get confirmPause => '确认暂停';
	@override String get dynamicAmount => '动态均值';
	@override String get dynamicAmountTitle => '金额需手动确认';
	@override String get dynamicAmountDescription => '系统将在账单日发送提醒，需要您手动确认具体金额后才会记账。';
	@override String get confirmBeforeGeneration => '生成前需确认';
	@override String get confirmBeforeGenerationDesc => '到期时生成待确认交易，需手动确认后记账';
	@override String get pendingTitle => '待确认交易';
	@override String pendingCount({required Object count}) => '${count} 笔待确认';
	@override String get confirm => '确认';
	@override String get skip => '跳过';
	@override String get noPending => '无待确认交易';
	@override String get confirmSuccess => '已确认记账';
	@override String get skipSuccess => '已跳过';
	@override String get interval => '重复间隔';
	@override String get selectDays => '选择星期';
	@override String get alwaysLastDay => '固定在每月最后一天';
	@override String get lastDayExecution => '将在每月最后一天执行';
	@override String dayExecution({required Object day, required Object suffix}) => '将在每月 ${day} 号${suffix}执行（短月份自动对齐月末）';
	@override String get setEndDate => '设置结束日期';
	@override String get selectEndDate => '选择结束日期';
	@override String get preview => '规则预览';
	@override String get daily => '每天';
	@override String get weekly => '每周';
	@override String get monthly => '每月';
	@override String get yearly => '每年';
	@override String get custom => '自定义';
	@override String get cycle => '周期';
	@override String get dayUnit => '天';
	@override String get weekUnit => '周';
	@override String get monthUnit => '个月';
	@override String get yearUnit => '年';
	@override String everyDays({required Object count}) => '每 ${count} 天';
	@override String everyWeeks({required Object count}) => '每 ${count} 周';
	@override String everyMonths({required Object count}) => '每 ${count} 个月';
	@override String everyYears({required Object count}) => '每 ${count} 年';
	@override String monthlyOnDay({required Object day, required Object suffix}) => '每月 ${day} 号${suffix}';
	@override String everyMonthsOnDay({required Object count, required Object day, required Object suffix}) => '每 ${count} 个月的 ${day} 号${suffix}';
	@override String get monthlyLastDay => '每月最后一天';
	@override String everyMonthsLastDay({required Object count}) => '每 ${count} 个月的最后一天';
	@override String yearlyOn({required Object month, required Object day}) => '每年 ${month}/${day}';
	@override String everyYearsOn({required Object count, required Object month, required Object day}) => '每 ${count} 年 ${month}/${day}';
	@override String weeklyOnDay({required Object day}) => '每周的${day}';
	@override String get weekdayMon => '一';
	@override String get weekdayTue => '二';
	@override String get weekdayWed => '三';
	@override String get weekdayThu => '四';
	@override String get weekdayFri => '五';
	@override String get weekdaySat => '六';
	@override String get weekdaySun => '日';
	@override String get weekdayOn => '周';
	@override String get weekdayJoiner => '、';
	@override String get weeklyDaysPrefix => '的';
	@override String get sourceAccount => '转出账户';
	@override String get targetAccount => '转入账户';
	@override String get expenseAccount => '支出账户';
	@override String get incomeAccount => '收入账户';
	@override String get selectSourceAccount => '选择转出账户';
	@override String get selectTargetAccount => '选择转入账户';
	@override String get selectExpenseAccount => '选择支出账户';
	@override String get selectIncomeAccount => '选择收入账户';
	@override String amountNotFixed({required Object type}) => '每次${type}金额不固定';
	@override String get selectBothAccounts => '请选择转出和转入账户';
	@override String selectAccountForType({required Object type}) => '请选择${type}账户';
	@override String get deleteConfirmGeneric => '确定要删除这个周期交易吗？此操作不可撤销。';
	@override String selectDate({required Object date}) => '选择 ${date}';
	@override String get accountTypeCash => '现金钱包';
	@override String get accountTypeDeposit => '银行存款';
	@override String get accountTypeEMoney => '电子钱包';
	@override String get accountTypeInvestment => '投资理财';
	@override String get accountTypeReceivable => '应收款项';
	@override String get accountTypeCreditCard => '信用卡';
	@override String get accountTypeLoan => '贷款账户';
	@override String get accountTypePayable => '应付款项';
	@override String get assetAccount => '资产账户';
	@override String get liabilityAccount => '负债账户';
	@override String get noAssetAccounts => '暂无资产账户';
	@override String get goToFinanceToAddAccounts => '请前往财务页面添加账户';
	@override String get selectAccount => '选择账户';
	@override String get autoGenerateByRule => '开启后按规则自动生成交易';
}

// Path: chat.tools
class Translations$chat$tools$zh implements Translations$chat$tools$en {
	Translations$chat$tools$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get processing => '正在处理...';
	@override String get read_file => '正在查看文件...';
	@override String get search_transactions => '正在查询交易...';
	@override String get query_budget_status => '正在检查预算...';
	@override String get create_budget => '正在创建预算计划...';
	@override String get get_cash_flow_analysis => '正在分析现金流...';
	@override String get get_financial_health_score => '正在计算财务健康分...';
	@override String get get_financial_summary => '正在生成财务报告...';
	@override String get evaluate_financial_health => '正在评估财务健康...';
	@override String get simulate_expense_impact => '正在模拟购买影响...';
	@override String get record_transactions => '正在记账...';
	@override String get create_transaction => '正在记账...';
	@override String get duckduckgo_search => '正在搜索网络...';
	@override String get execute_transfer => '正在执行转账...';
	@override String get list_dir => '正在浏览目录...';
	@override String get execute => '正在执行脚本...';
	@override String get analyze_spending => '正在分析支出明细...';
	@override String get analyze_cashflow => '正在分析现金流...';
	@override String get forecast_balance => '正在预测未来余额...';
	@override String get suggest_budget => '正在推荐预算...';
	@override String get list_spaces => '正在获取共享空间...';
	@override String get query_space_summary => '正在查询空间摘要...';
	@override String get prepare_transfer => '正在准备转账...';
	@override String get unknown => '正在处理请求...';
	@override late final Translations$chat$tools$done$zh done = Translations$chat$tools$done$zh.internal(_root);
	@override late final Translations$chat$tools$failed$zh failed = Translations$chat$tools$failed$zh.internal(_root);
	@override String get cancelled => '已取消';
	@override String get analyze_finance => '正在分析財務狀況...';
	@override String get forecast_finance => '正在預測財務趨勢...';
	@override String get analyze_budget => '正在分析預算...';
	@override String get audit_analysis => '正在審計分析...';
	@override String get budget_ops => '正在處理預算...';
	@override String get create_shared_transaction => '正在創建共享帳單...';
	@override String get prepareBudgetSimulation => '正在准备预算模拟';
	@override String get simulateBudget => '正在模拟预算';
}

// Path: chat.transferWizard
class Translations$chat$transferWizard$zh implements Translations$chat$transferWizard$en {
	Translations$chat$transferWizard$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '转账向导';
	@override String get amount => '转账金额';
	@override String get amountHint => '请输入金额';
	@override String get sourceAccount => '转出账户';
	@override String get targetAccount => '转入账户';
	@override String get selectAccount => '请选择账户';
	@override String get selectReceiveAccount => '选择收款账户';
	@override String get confirmTransfer => '确认转账';
	@override String get confirmed => '已确认';
	@override String get transferSuccess => '转账成功';
}

// Path: chat.genui
class Translations$chat$genui$zh implements Translations$chat$genui$en {
	Translations$chat$genui$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override late final Translations$chat$genui$expenseSummary$zh expenseSummary = Translations$chat$genui$expenseSummary$zh.internal(_root);
	@override late final Translations$chat$genui$transactionList$zh transactionList = Translations$chat$genui$transactionList$zh.internal(_root);
	@override late final Translations$chat$genui$transactionGroupReceipt$zh transactionGroupReceipt = Translations$chat$genui$transactionGroupReceipt$zh.internal(_root);
	@override late final Translations$chat$genui$budgetReceipt$zh budgetReceipt = Translations$chat$genui$budgetReceipt$zh.internal(_root);
	@override late final Translations$chat$genui$budgetStatusCard$zh budgetStatusCard = Translations$chat$genui$budgetStatusCard$zh.internal(_root);
	@override late final Translations$chat$genui$cashFlowForecast$zh cashFlowForecast = Translations$chat$genui$cashFlowForecast$zh.internal(_root);
	@override late final Translations$chat$genui$healthScore$zh healthScore = Translations$chat$genui$healthScore$zh.internal(_root);
	@override late final Translations$chat$genui$spaceSelector$zh spaceSelector = Translations$chat$genui$spaceSelector$zh.internal(_root);
	@override late final Translations$chat$genui$transferPath$zh transferPath = Translations$chat$genui$transferPath$zh.internal(_root);
	@override late final Translations$chat$genui$transactionCard$zh transactionCard = Translations$chat$genui$transactionCard$zh.internal(_root);
	@override late final Translations$chat$genui$transactionConfirmation$zh transactionConfirmation = Translations$chat$genui$transactionConfirmation$zh.internal(_root);
	@override late final Translations$chat$genui$budgetAnalysis$zh budgetAnalysis = Translations$chat$genui$budgetAnalysis$zh.internal(_root);
	@override late final Translations$chat$genui$cashFlowCard$zh cashFlowCard = Translations$chat$genui$cashFlowCard$zh.internal(_root);
	@override late final Translations$chat$genui$budgetSimulator$zh budgetSimulator = Translations$chat$genui$budgetSimulator$zh.internal(_root);
}

// Path: chat.welcome
class Translations$chat$welcome$zh implements Translations$chat$welcome$en {
	Translations$chat$welcome$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override late final Translations$chat$welcome$morning$zh morning = Translations$chat$welcome$morning$zh.internal(_root);
	@override late final Translations$chat$welcome$midday$zh midday = Translations$chat$welcome$midday$zh.internal(_root);
	@override late final Translations$chat$welcome$afternoon$zh afternoon = Translations$chat$welcome$afternoon$zh.internal(_root);
	@override late final Translations$chat$welcome$evening$zh evening = Translations$chat$welcome$evening$zh.internal(_root);
	@override late final Translations$chat$welcome$night$zh night = Translations$chat$welcome$night$zh.internal(_root);
}

// Path: error.genui
class Translations$error$genui$zh implements Translations$error$genui$en {
	Translations$error$genui$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get loadingFailed => '组件加载失败';
	@override String get schemaFailed => '架构验证失败';
	@override String get schemaDescription => '组件定义不符合 GenUI 规范，降级为纯文本显示';
	@override String get networkError => '网络错误';
	@override String retryStatus({required Object retryCount, required Object maxRetries}) => '已重试 ${retryCount}/${maxRetries} 次';
	@override String get maxRetriesReached => '已达最大重试次数';
}

// Path: account.types
class Translations$account$types$zh implements Translations$account$types$en {
	Translations$account$types$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get cashTitle => '现金';
	@override String get cashSubtitle => '纸币、硬币等实体货币';
	@override String get depositTitle => '银行存款';
	@override String get depositSubtitle => '储蓄卡、活期/定期存款';
	@override String get eMoneyTitle => '电子钱包';
	@override String get eMoneySubtitle => '第三方支付平台余额';
	@override String get investmentTitle => '投资账户';
	@override String get investmentSubtitle => '股票、基金、债券等';
	@override String get receivableTitle => '应收款项';
	@override String get receivableSubtitle => '借出款项、待收账款';
	@override String get receivableHelper => '他人欠我';
	@override String get creditCardTitle => '信用卡';
	@override String get creditCardSubtitle => '信用卡账户欠款';
	@override String get loanTitle => '贷款';
	@override String get loanSubtitle => '房贷、车贷、消费贷等';
	@override String get payableTitle => '应付款项';
	@override String get payableSubtitle => '借入款项、待付账款';
	@override String get payableHelper => '我欠他人';
}

// Path: statistics.overview
class Translations$statistics$overview$zh implements Translations$statistics$overview$en {
	Translations$statistics$overview$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get balance => '总结余';
	@override String get income => '总收入';
	@override String get expense => '总支出';
}

// Path: statistics.trend
class Translations$statistics$trend$zh implements Translations$statistics$trend$en {
	Translations$statistics$trend$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '收支趋势';
	@override String get expense => '支出';
	@override String get income => '收入';
}

// Path: statistics.analysis
class Translations$statistics$analysis$zh implements Translations$statistics$analysis$en {
	Translations$statistics$analysis$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '支出分析';
	@override String get expenseTitle => '支出分析';
	@override String get incomeTitle => '收入分析';
	@override String get total => '总计';
	@override String get breakdown => '支出分类明细';
	@override String get radarNeedMoreData => '雷达图需要至少3个分类数据';
}

// Path: statistics.filter
class Translations$statistics$filter$zh implements Translations$statistics$filter$en {
	Translations$statistics$filter$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get accountType => '账户类型';
	@override String get allAccounts => '全部账户';
	@override String get apply => '确认应用';
}

// Path: statistics.sort
class Translations$statistics$sort$zh implements Translations$statistics$sort$en {
	Translations$statistics$sort$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get amount => '按金额排序';
	@override String get date => '按时间排序';
}

// Path: statistics.emptyState
class Translations$statistics$emptyState$zh implements Translations$statistics$emptyState$en {
	Translations$statistics$emptyState$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '开启财务洞察';
	@override String get description => '您的财务报表目前是一张白纸。\n记录第一笔消费，让数据为您讲述财富故事。';
	@override String get action => '记录首笔交易';
}

// Path: server.error
class Translations$server$error$zh implements Translations$server$error$en {
	Translations$server$error$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get urlRequired => '请输入服务器地址';
	@override String get invalidUrl => 'URL 格式无效';
	@override String get connectionTimeout => '连接超时';
	@override String get connectionRefused => '无法连接到服务器';
	@override String get sslError => 'SSL 证书错误';
	@override String get serverError => '服务器错误';
}

// Path: sharedSpace.dashboard
class Translations$sharedSpace$dashboard$zh implements Translations$sharedSpace$dashboard$en {
	Translations$sharedSpace$dashboard$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get sectionTitle => '财务概览';
	@override String get cumulativeTotalExpense => '累计总支出';
	@override String get participatingMembers => '参与成员';
	@override String membersCount({required Object count}) => '${count} 人';
	@override String get averagePerMember => '成员人均';
	@override String get spendingDistribution => '成员消费分布';
	@override String get realtimeUpdates => '实时更新';
	@override String get paid => '已支付';
}

// Path: sharedSpace.roles
class Translations$sharedSpace$roles$zh implements Translations$sharedSpace$roles$en {
	Translations$sharedSpace$roles$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get owner => '主理人';
	@override String get admin => '管理员';
	@override String get member => '成员';
}

// Path: sharedSpace.create
class Translations$sharedSpace$create$zh implements Translations$sharedSpace$create$en {
	Translations$sharedSpace$create$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '创建共享空间';
	@override String get subtitle => '创建一个新的共享空间，与朋友一起记账';
	@override String get nameLabel => '空间名称';
	@override String get nameHint => '例如：毕业旅行';
	@override String get descLabel => '描述（可选）';
	@override String get descHint => '记录我们的共同旅行开销';
	@override String get cancel => '取消';
	@override String get submit => '创建';
	@override String get nameRequired => '请输入空间名称';
	@override String get nameTooShort => '空间名称至少需要 2 个字符';
	@override String get nameTooLong => '空间名称不能超过 50 个字符';
}

// Path: sharedSpace.join
class Translations$sharedSpace$join$zh implements Translations$sharedSpace$join$en {
	Translations$sharedSpace$join$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '加入共享空间';
	@override String get subtitle => '输入朋友分享的邀请码，开始协作记账';
	@override String get codeLabel => '邀请码';
	@override String get codeHint => '输入邀请码，例如：123456';
	@override String get cancel => '取消';
	@override String get submit => '加入';
	@override String get codeRequired => '请输入邀请码';
	@override String get codeInvalid => '邀请码格式无效';
	@override String get codeFormat => '邀请码只能包含字母和数字';
}

// Path: sharedSpace.list
class Translations$sharedSpace$list$zh implements Translations$sharedSpace$list$en {
	Translations$sharedSpace$list$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get emptyTitle => '开启多方协同的财务空间';
	@override String get emptySubtitle => '创建或加入共享空间，与家人、伴侣或团队协同管理共享账目与资产';
	@override String get getStarted => '开始使用';
	@override String get hasInviteCode => '有邀请码？点击加入';
	@override String joinedSuccess({required Object name}) => '成功加入「${name}」！';
}

// Path: sharedSpace.detail
class Translations$sharedSpace$detail$zh implements Translations$sharedSpace$detail$en {
	Translations$sharedSpace$detail$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get members => '成员';
	@override String get transactions => '交易记录';
	@override String recordsCount({required Object count}) => '${count} 笔';
	@override String get settlement => '结算';
	@override String get inviteCode => '邀请码';
	@override String get copyCode => '复制邀请码';
	@override String codeCopied({required Object code}) => '邀请码已复制：${code}';
	@override String get validFor24h => '24 小时内有效';
	@override String get leaveSpace => '退出空间';
	@override String get deleteSpace => '删除空间';
	@override String get removeMember => '移除成员';
	@override String get leaveConfirm => '确定要退出此共享空间吗？退出后将无法查看空间内的交易记录。';
	@override String get deleteConfirm => '确定要删除此共享空间吗？此操作不可撤销，所有成员将被移出。';
	@override String get removeConfirm => '确定要将此成员移出共享空间吗？';
	@override String get generatingCode => '正在生成邀请码...';
	@override String get loadFailed => '加载失败';
	@override String get retry => '重试';
	@override String get noTransactions => '暂无交易记录';
	@override String get noTransactionsHint => '空间内的交易将显示在这里';
	@override String get refreshCode => '刷新生成新码';
	@override String get joinOtherSpace => '加入其他空间';
}

// Path: sharedSpace.notifications
class Translations$sharedSpace$notifications$zh implements Translations$sharedSpace$notifications$en {
	Translations$sharedSpace$notifications$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '通知';
	@override String get empty => '暂无通知';
	@override String get emptyHint => '当你收到新的邀请或动态时，\n通知将显示在这里';
	@override String get incompleteInfo => '邀请信息不完整';
	@override String get inviteAccepted => '已接受邀请！';
	@override String get inviteRejected => '已拒绝邀请';
	@override String get allMarkedRead => '全部标记为已读';
}

// Path: sharedSpace.inviteCard
class Translations$sharedSpace$inviteCard$zh implements Translations$sharedSpace$inviteCard$en {
	Translations$sharedSpace$inviteCard$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '邀请码';
	@override String get subtitle => '分享给朋友以加入空间';
	@override String get copyCode => '复制邀请码';
	@override String get shareLink => '分享邀请链接';
	@override String get codeCopied => '邀请码已复制';
	@override String get noExpiry => '无有效期限制';
	@override String get expired => '已过期';
	@override String expiresInDays({required Object days}) => '${days} 天后过期';
	@override String expiresInHours({required Object hours}) => '${hours} 小时后过期';
	@override String expiresInMinutes({required Object minutes}) => '${minutes} 分钟后过期';
	@override String get expiringSoon => '即将过期';
	@override String shareText({required Object spaceName, required Object code, required Object link, required Object expiry}) => '邀请你加入共享空间「${spaceName}」\n\n邀请码：${code}\n或点击链接直接加入：${link}\n\n邀请码${expiry}';
}

// Path: sharedSpace.inviteSuccess
class Translations$sharedSpace$inviteSuccess$zh implements Translations$sharedSpace$inviteSuccess$en {
	Translations$sharedSpace$inviteSuccess$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '创建成功';
	@override String get subtitle => '共享空间创建成功';
	@override String get inviteLater => '稍后邀请';
	@override String get enterSpace => '进入空间';
	@override String get generatingCode => '正在生成邀请码...';
	@override String get generateFailed => '邀请码生成失败';
	@override String get codeCopied => '邀请码已复制';
	@override String get retry => '重试';
	@override String get codeLabel => '邀请码';
	@override String get validHint => '24 小时内有效 · 点击复制';
}

// Path: sharedSpace.notificationCard
class Translations$sharedSpace$notificationCard$zh implements Translations$sharedSpace$notificationCard$en {
	Translations$sharedSpace$notificationCard$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get accept => '接受';
	@override String get reject => '拒绝';
	@override String get unknownTime => '未知时间';
	@override String get justNow => '刚刚';
}

// Path: sharedSpace.spaceCard
class Translations$sharedSpace$spaceCard$zh implements Translations$sharedSpace$spaceCard$en {
	Translations$sharedSpace$spaceCard$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get noDescription => '暂无描述';
	@override String get creator => '创建者';
	@override String get member => '成员';
	@override String membersCount({required Object count}) => '${count} 位成员';
	@override String transactionsCount({required Object count}) => '${count} 笔账单';
}

// Path: sharedSpace.settings
class Translations$sharedSpace$settings$zh implements Translations$sharedSpace$settings$en {
	Translations$sharedSpace$settings$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '空间设置';
	@override String get spaceInfo => '空间信息';
	@override String get nameLabel => '空间名称';
	@override String get descLabel => '空间描述';
	@override String get save => '保存';
	@override String get saved => '保存成功';
	@override String get saveFailed => '保存失败';
	@override String get memberManagement => '成员管理';
	@override String membersCount({required Object count}) => '${count} 位成员';
	@override String removeMemberConfirm({required Object name}) => '确定要将「${name}」移出空间吗？';
	@override String get removed => '已移除成员';
	@override String get removeFailed => '移除失败';
	@override String get inviteManagement => '邀请管理';
	@override String get currentCode => '当前邀请码';
	@override String get generateNew => '生成新邀请码';
	@override String get noValidCode => '暂无有效邀请码';
	@override String get refreshCode => '刷新生成新码';
	@override String get refreshConfirm => '生成新码将使旧邀请码失效，确定继续？';
	@override String get codeRefreshed => '邀请码已刷新';
	@override String get dangerZone => '危险操作';
	@override String get editHint => '仅管理员可编辑';
	@override String get edit => '编辑';
	@override String get you => '我';
	@override String get pending => '待接受';
	@override String get declined => '已拒绝';
	@override String get setAsAdmin => '设为管理员';
	@override String get setAsMember => '设为普通成员';
	@override String get changeRole => '变更角色';
	@override String changeRoleConfirm({required Object name, required Object role}) => '确定要将「${name}」的角色变更为「${role}」吗？';
	@override String get confirm => '确认';
	@override String get roleChanged => '角色已变更';
	@override String get roleChangeFailed => '角色变更失败';
}

// Path: errorMapping.generic
class Translations$errorMapping$generic$zh implements Translations$errorMapping$generic$en {
	Translations$errorMapping$generic$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get badRequest => '请求无效';
	@override String get authFailed => '认证失败，请重新登录';
	@override String get permissionDenied => '权限不足';
	@override String get notFound => '资源未找到';
	@override String get serverError => '服务器内部错误';
	@override String get systemError => '系统错误';
	@override String get validationFailed => '数据验证失败';
}

// Path: errorMapping.auth
class Translations$errorMapping$auth$zh implements Translations$errorMapping$auth$en {
	Translations$errorMapping$auth$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get failed => '认证失败';
	@override String get emailWrong => '邮箱错误';
	@override String get phoneWrong => '手机号错误';
	@override String get phoneRegistered => '该手机号已被注册';
	@override String get emailRegistered => '该邮箱已被注册';
	@override String get sendFailed => '验证码发送失败';
	@override String get expired => '验证码已过期';
	@override String get tooFrequent => '验证码发送太频繁';
	@override String get unsupportedType => '不支持的验证码类型';
	@override String get wrongPassword => '密码错误';
	@override String get userNotFound => '用户不存在';
	@override String get prefsMissing => '偏好设置参数缺失';
	@override String get invalidTimezone => '无效的客户端时区';
}

// Path: errorMapping.transaction
class Translations$errorMapping$transaction$zh implements Translations$errorMapping$transaction$en {
	Translations$errorMapping$transaction$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get commentEmpty => '评论内容不能为空';
	@override String get invalidParent => '无效的父评论ID';
	@override String get saveFailed => '评论保存失败';
	@override String get deleteFailed => '评论删除失败';
	@override String get notExists => '交易记录不存在';
}

// Path: errorMapping.space
class Translations$errorMapping$space$zh implements Translations$errorMapping$space$en {
	Translations$errorMapping$space$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get notFound => '共享空间不存在或无权访问';
	@override String get inviteDenied => '无权邀请成员';
	@override String get inviteSelf => '不能邀请你自己';
	@override String get inviteSent => '邀请已发送';
	@override String get alreadyMember => '该用户已是成员或已被邀请';
	@override String get invalidAction => '无效操作';
	@override String get invitationNotFound => '邀请不存在';
	@override String get onlyOwner => '仅拥有者可执行此操作';
	@override String get ownerNotRemovable => '不能移除空间拥有者';
	@override String get memberNotFound => '成员不存在';
	@override String get notMember => '该用户不是此空间的成员';
	@override String get ownerCantLeave => '拥有者不能直接退出，请先转让所有权';
	@override String get invalidCode => '无效的邀请码';
	@override String get codeExpired => '邀请码已过期或达到上限';
	@override String get transactionAlreadyInSpace => '交易已在此共享空间中';
}

// Path: errorMapping.recurring
class Translations$errorMapping$recurring$zh implements Translations$errorMapping$recurring$en {
	Translations$errorMapping$recurring$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get invalidRule => '无效的重复规则';
	@override String get ruleNotFound => '未找到重复规则';
}

// Path: errorMapping.upload
class Translations$errorMapping$upload$zh implements Translations$errorMapping$upload$en {
	Translations$errorMapping$upload$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get noFile => '未上传文件';
	@override String get tooLarge => '文件过大';
	@override String get unsupportedType => '不支持的文件类型';
	@override String get tooManyFiles => '文件数量过多';
}

// Path: errorMapping.storage
class Translations$errorMapping$storage$zh implements Translations$errorMapping$storage$en {
	Translations$errorMapping$storage$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get configNotFound => '存储配置不存在或无权访问';
	@override String get configInUse => '无法删除：存储配置仍被附件使用';
	@override String get invalidProviderType => '无效的存储提供商类型';
}

// Path: errorMapping.ai
class Translations$errorMapping$ai$zh implements Translations$errorMapping$ai$en {
	Translations$errorMapping$ai$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get contextLimit => '上下文长度超出限制';
	@override String get tokenLimit => 'Token配额不足';
	@override String get emptyMessage => '用户消息为空';
}

// Path: notification.types
class Translations$notification$types$zh implements Translations$notification$types$en {
	Translations$notification$types$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get system => '系统通知';
	@override String get spaceInvite => '空间邀请';
	@override String get spaceActivity => '空间动态';
	@override String get billComment => '账单评论';
	@override String get budgetAlert => '预算提醒';
	@override String get transaction => '交易通知';
}

// Path: notification.semantic
class Translations$notification$semantic$zh implements Translations$notification$semantic$en {
	Translations$notification$semantic$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String memberJoined({required Object name}) => '${name} 加入了你的空间';
	@override String memberJoinedDetail({required Object space}) => '新成员加入了「${space}」';
	@override String welcome({required Object space}) => '欢迎加入「${space}」';
	@override String newTransaction({required Object name}) => '${name} 记录了一笔新账单';
	@override String newTransactionDetail({required Object amount, required Object space}) => '${amount}，来自「${space}」';
	@override String memberLeft({required Object name}) => '${name} 离开了空间';
	@override String get recurringPending => '周期交易待确认';
	@override String recurringPendingDetail({required Object description, required Object amount}) => '${description} ${amount}，等待您确认记账';
}

// Path: chat.tools.done
class Translations$chat$tools$done$zh implements Translations$chat$tools$done$en {
	Translations$chat$tools$done$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get read_file => '已查看文件';
	@override String get search_transactions => '已查询交易';
	@override String get query_budget_status => '已检查预算';
	@override String get create_budget => '已创建预算';
	@override String get get_cash_flow_analysis => '已分析现金流';
	@override String get get_financial_health_score => '已计算健康分';
	@override String get get_financial_summary => '财务报告生成完成';
	@override String get evaluate_financial_health => '财务健康评估完成';
	@override String get forecast_balance => '余额预测完成';
	@override String get simulate_expense_impact => '购买影响模拟完成';
	@override String get record_transactions => '记账完成';
	@override String get create_transaction => '已完成记账';
	@override String get duckduckgo_search => '已搜索网络';
	@override String get execute_transfer => '转账完成';
	@override String get list_dir => '已浏览目录';
	@override String get execute => '脚本执行完成';
	@override String get analyze_spending => '支出分析完成';
	@override String get analyze_cashflow => '现金流分析完成';
	@override String get suggest_budget => '预算推荐完成';
	@override String get list_spaces => '共享空间获取完成';
	@override String get query_space_summary => '空间摘要查询完成';
	@override String get prepare_transfer => '转账准备完成';
	@override String get unknown => '处理完成';
	@override String get analyze_finance => '財務分析完成';
	@override String get forecast_finance => '財務預測完成';
	@override String get analyze_budget => '預算分析完成';
	@override String get audit_analysis => '審計分析完成';
	@override String get budget_ops => '預算處理完成';
	@override String get create_shared_transaction => '共享帳單創建完成';
	@override String get prepareBudgetSimulation => '预算模拟准备完成';
	@override String get simulateBudget => '预算模拟完成';
}

// Path: chat.tools.failed
class Translations$chat$tools$failed$zh implements Translations$chat$tools$failed$en {
	Translations$chat$tools$failed$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get unknown => '操作失败';
}

// Path: chat.genui.expenseSummary
class Translations$chat$genui$expenseSummary$zh implements Translations$chat$genui$expenseSummary$en {
	Translations$chat$genui$expenseSummary$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get totalExpense => '总支出';
	@override String get mainExpenses => '主要支出';
	@override String viewAll({required Object count}) => '查看全部 ${count} 笔消费';
	@override String get details => '消费明细';
}

// Path: chat.genui.transactionList
class Translations$chat$genui$transactionList$zh implements Translations$chat$genui$transactionList$en {
	Translations$chat$genui$transactionList$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String searchResults({required Object count}) => '搜索结果 (${count})';
	@override String loaded({required Object count}) => '已加载 ${count}';
	@override String get noResults => '未找到相关交易';
	@override String get loadMore => '滚动加载更多';
	@override String get allLoaded => '全部加载完成';
}

// Path: chat.genui.transactionGroupReceipt
class Translations$chat$genui$transactionGroupReceipt$zh implements Translations$chat$genui$transactionGroupReceipt$en {
	Translations$chat$genui$transactionGroupReceipt$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '交易成功';
	@override String count({required Object count}) => '${count}笔';
	@override String get total => '共计';
	@override String get selectAccount => '选择关联账户';
	@override String get selectAccountSubtitle => '此账户将应用到以上所有笔交易';
	@override String associatedAccount({required Object name}) => '已关联账户：${name}';
	@override String get clickToAssociate => '点击关联账户（支持批量操作）';
	@override String get associateSuccess => '已成功为所有交易关联账户';
	@override String associateFailed({required Object error}) => '操作失败: ${error}';
	@override String get accountAssociation => '账户关联';
	@override String get sharedSpace => '共享空间';
	@override String get notAssociated => '未关联';
	@override String get addSpace => '添加';
	@override String get selectSpace => '选择共享空间';
	@override String get spaceAssociateSuccess => '已关联到共享空间';
	@override String spaceAssociateFailed({required Object error}) => '关联共享空间失败: ${error}';
	@override String get currencyMismatchTitle => '币种不一致';
	@override String get currencyMismatchDesc => '交易币种与账户币种不同，系统将按当时汇率换算后扣减账户余额。';
	@override String get transactionAmount => '交易金额';
	@override String get accountCurrency => '账户币种';
	@override String get targetAccount => '目标账户';
	@override String get currencyMismatchNote => '提示：账户余额将按当时汇率进行换算扣减';
	@override String get confirmAssociate => '确认关联';
	@override String spaceCount({required Object count}) => '${count} 空间';
}

// Path: chat.genui.budgetReceipt
class Translations$chat$genui$budgetReceipt$zh implements Translations$chat$genui$budgetReceipt$en {
	Translations$chat$genui$budgetReceipt$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get newBudget => '新预算';
	@override String get budgetCreated => '预算已创建';
	@override String get rolloverBudget => '滚动预算';
	@override String get createFailed => '创建预算失败';
	@override String get thisMonth => '本月';
	@override String dateRange({required Object start, required Object startDay, required Object end, required Object endDay}) => '${start}月${startDay}日 - ${end}月${endDay}日';
}

// Path: chat.genui.budgetStatusCard
class Translations$chat$genui$budgetStatusCard$zh implements Translations$chat$genui$budgetStatusCard$en {
	Translations$chat$genui$budgetStatusCard$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get budget => '预算';
	@override String get overview => '预算概览';
	@override String get totalBudget => '总预算';
	@override String spent({required Object amount}) => '已用 ¥${amount}';
	@override String remaining({required Object amount}) => '剩余 ¥${amount}';
	@override String get exceeded => '已超支';
	@override String get warning => '预算紧张';
	@override String get plentiful => '预算充裕';
	@override String get normal => '正常';
}

// Path: chat.genui.cashFlowForecast
class Translations$chat$genui$cashFlowForecast$zh implements Translations$chat$genui$cashFlowForecast$en {
	Translations$chat$genui$cashFlowForecast$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '现金流预测';
	@override String get recurringTransaction => '周期性交易';
	@override String get recurringIncome => '周期性收入';
	@override String get recurringExpense => '周期性支出';
	@override String get recurringTransfer => '周期性转账';
	@override String nextDays({required Object days}) => '未来 ${days} 天';
	@override String get noData => '暂无预测数据';
	@override String get summary => '预测摘要';
	@override String get variableExpense => '预测可变支出';
	@override String get netChange => '预计净变化';
	@override String get keyEvents => '关键事件';
	@override String get noSignificantEvents => '预测期内无重大事件';
	@override String get dateFormat => 'M月d日';
}

// Path: chat.genui.healthScore
class Translations$chat$genui$healthScore$zh implements Translations$chat$genui$healthScore$en {
	Translations$chat$genui$healthScore$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '财务健康';
	@override String get suggestions => '改进建议';
	@override String scorePoint({required Object score}) => '${score}分';
	@override late final Translations$chat$genui$healthScore$status$zh status = Translations$chat$genui$healthScore$status$zh.internal(_root);
}

// Path: chat.genui.spaceSelector
class Translations$chat$genui$spaceSelector$zh implements Translations$chat$genui$spaceSelector$en {
	Translations$chat$genui$spaceSelector$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get selected => '已选择';
	@override String get unnamedSpace => '未命名空间';
	@override String get linked => '已关联';
	@override String get roleOwner => '创建者';
	@override String get roleAdmin => '管理员';
	@override String get roleMember => '成员';
	@override String get associateAction => '关联到所选空间';
}

// Path: chat.genui.transferPath
class Translations$chat$genui$transferPath$zh implements Translations$chat$genui$transferPath$en {
	Translations$chat$genui$transferPath$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get selectSource => '选择转出账户';
	@override String get selectTarget => '选择转入账户';
	@override String get from => '转出 (FROM)';
	@override String get to => '转入 (TO)';
	@override String get select => '请选择';
	@override String get cancelled => '操作已取消';
	@override String get loadError => '无法加载账户数据';
	@override String get historyMissing => '历史记录中缺少账户信息';
	@override String get amountUnconfirmed => '金额待确认';
	@override String confirmedWithArrow({required Object source, required Object target}) => '已确认：${source} → ${target}';
	@override String confirmAction({required Object source, required Object target}) => '确认：${source} → ${target}';
	@override String get pleaseSelectSource => '请先选择转出账户';
	@override String get pleaseSelectTarget => '请选择转入账户';
	@override String get confirmLinks => '确认转账链路';
	@override String get linkLocked => '链路已锁定';
	@override String get clickToConfirm => '点击下方按钮确认执行';
	@override String get reselect => '重选';
	@override String get title => '转账';
	@override String get history => '历史记录';
	@override String get unknownAccount => '未知账户';
	@override String get confirmed => '已确认';
	@override String get executeAction => '按我的选择执行转账';
}

// Path: chat.genui.transactionCard
class Translations$chat$genui$transactionCard$zh implements Translations$chat$genui$transactionCard$en {
	Translations$chat$genui$transactionCard$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '交易成功';
	@override String get associatedAccount => '已关联账户';
	@override String get notCounted => '不计入资产';
	@override String get modify => '修改';
	@override String get associate => '关联账户';
	@override String get selectAccount => '选择关联账户';
	@override String get noAccount => '暂无可用账户，请先添加账户';
	@override String get missingId => '交易 ID 缺失，无法更新';
	@override String associatedTo({required Object name}) => '已关联到 ${name}';
	@override String updateFailed({required Object error}) => '更新失败: ${error}';
	@override String get sharedSpace => '共享空间';
	@override String get noSpace => '暂无可用共享空间';
	@override String get selectSpace => '选择共享空间';
	@override String get linkedToSpace => '已关联到共享空间';
}

// Path: chat.genui.transactionConfirmation
class Translations$chat$genui$transactionConfirmation$zh implements Translations$chat$genui$transactionConfirmation$en {
	Translations$chat$genui$transactionConfirmation$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get multipleAccounts => '检测到多个关联账户';
	@override String get confirmed => '已确认';
}

// Path: chat.genui.budgetAnalysis
class Translations$chat$genui$budgetAnalysis$zh implements Translations$chat$genui$budgetAnalysis$en {
	Translations$chat$genui$budgetAnalysis$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '预算分析报告';
	@override String periodDays({required Object days}) => '过去 ${days} 天';
	@override String get totalExpense => '总支出';
	@override String momChange({required Object change}) => '环比 ${change}%';
	@override String get categoryDistribution => '分类占比';
	@override String get topSpenders => '大额支出';
	@override String amountWan({required Object amount}) => '${amount}万';
}

// Path: chat.genui.cashFlowCard
class Translations$chat$genui$cashFlowCard$zh implements Translations$chat$genui$cashFlowCard$en {
	Translations$chat$genui$cashFlowCard$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '现金流分析';
	@override String savingsRate({required Object rate}) => '储蓄 ${rate}%';
	@override String get totalIncome => '总收入';
	@override String get totalExpense => '总支出';
	@override String get essentialExpense => '必要支出';
	@override String get discretionaryExpense => '可选消费';
	@override String get aiInsight => 'AI 分析';
}

// Path: chat.genui.budgetSimulator
class Translations$chat$genui$budgetSimulator$zh implements Translations$chat$genui$budgetSimulator$en {
	Translations$chat$genui$budgetSimulator$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

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

// Path: chat.welcome.morning
class Translations$chat$welcome$morning$zh implements Translations$chat$welcome$morning$en {
	Translations$chat$welcome$morning$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get subtitle => '新的一天，从记录开始';
	@override late final Translations$chat$welcome$morning$breakfast$zh breakfast = Translations$chat$welcome$morning$breakfast$zh.internal(_root);
	@override late final Translations$chat$welcome$morning$yesterdayReview$zh yesterdayReview = Translations$chat$welcome$morning$yesterdayReview$zh.internal(_root);
	@override late final Translations$chat$welcome$morning$todayBudget$zh todayBudget = Translations$chat$welcome$morning$todayBudget$zh.internal(_root);
}

// Path: chat.welcome.midday
class Translations$chat$welcome$midday$zh implements Translations$chat$welcome$midday$en {
	Translations$chat$welcome$midday$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get greeting => '中午好';
	@override String get subtitle => '午间时光，顺手记一笔';
	@override late final Translations$chat$welcome$midday$lunch$zh lunch = Translations$chat$welcome$midday$lunch$zh.internal(_root);
	@override late final Translations$chat$welcome$midday$weeklyExpense$zh weeklyExpense = Translations$chat$welcome$midday$weeklyExpense$zh.internal(_root);
	@override late final Translations$chat$welcome$midday$checkBalance$zh checkBalance = Translations$chat$welcome$midday$checkBalance$zh.internal(_root);
}

// Path: chat.welcome.afternoon
class Translations$chat$welcome$afternoon$zh implements Translations$chat$welcome$afternoon$en {
	Translations$chat$welcome$afternoon$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get subtitle => '下午茶时间，理理财';
	@override late final Translations$chat$welcome$afternoon$quickRecord$zh quickRecord = Translations$chat$welcome$afternoon$quickRecord$zh.internal(_root);
	@override late final Translations$chat$welcome$afternoon$analyzeSpending$zh analyzeSpending = Translations$chat$welcome$afternoon$analyzeSpending$zh.internal(_root);
	@override late final Translations$chat$welcome$afternoon$budgetProgress$zh budgetProgress = Translations$chat$welcome$afternoon$budgetProgress$zh.internal(_root);
}

// Path: chat.welcome.evening
class Translations$chat$welcome$evening$zh implements Translations$chat$welcome$evening$en {
	Translations$chat$welcome$evening$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get subtitle => '辛苦一天，来理理账';
	@override late final Translations$chat$welcome$evening$dinner$zh dinner = Translations$chat$welcome$evening$dinner$zh.internal(_root);
	@override late final Translations$chat$welcome$evening$todaySummary$zh todaySummary = Translations$chat$welcome$evening$todaySummary$zh.internal(_root);
	@override late final Translations$chat$welcome$evening$tomorrowPlan$zh tomorrowPlan = Translations$chat$welcome$evening$tomorrowPlan$zh.internal(_root);
}

// Path: chat.welcome.night
class Translations$chat$welcome$night$zh implements Translations$chat$welcome$night$en {
	Translations$chat$welcome$night$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get greeting => '夜深了';
	@override String get subtitle => '静心理财，规划未来';
	@override late final Translations$chat$welcome$night$makeupRecord$zh makeupRecord = Translations$chat$welcome$night$makeupRecord$zh.internal(_root);
	@override late final Translations$chat$welcome$night$monthlyReview$zh monthlyReview = Translations$chat$welcome$night$monthlyReview$zh.internal(_root);
	@override late final Translations$chat$welcome$night$financialThinking$zh financialThinking = Translations$chat$welcome$night$financialThinking$zh.internal(_root);
}

// Path: chat.genui.healthScore.status
class Translations$chat$genui$healthScore$status$zh implements Translations$chat$genui$healthScore$status$en {
	Translations$chat$genui$healthScore$status$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get excellent => '财务状况优秀';
	@override String get good => '财务状况良好';
	@override String get fair => '财务状况一般';
	@override String get needsImprovement => '财务状况需改善';
	@override String get poor => '财务状况较差';
}

// Path: chat.welcome.morning.breakfast
class Translations$chat$welcome$morning$breakfast$zh implements Translations$chat$welcome$morning$breakfast$en {
	Translations$chat$welcome$morning$breakfast$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '早餐记账';
	@override String get prompt => '记一笔早餐';
	@override String get description => '快速记录今天的第一笔消费';
}

// Path: chat.welcome.morning.yesterdayReview
class Translations$chat$welcome$morning$yesterdayReview$zh implements Translations$chat$welcome$morning$yesterdayReview$en {
	Translations$chat$welcome$morning$yesterdayReview$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '昨日回顾';
	@override String get prompt => '分析昨天的消费';
	@override String get description => '看看昨天花了多少钱';
}

// Path: chat.welcome.morning.todayBudget
class Translations$chat$welcome$morning$todayBudget$zh implements Translations$chat$welcome$morning$todayBudget$en {
	Translations$chat$welcome$morning$todayBudget$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '今日预算';
	@override String get prompt => '今天还剩多少预算';
	@override String get description => '规划一天的消费额度';
}

// Path: chat.welcome.midday.lunch
class Translations$chat$welcome$midday$lunch$zh implements Translations$chat$welcome$midday$lunch$en {
	Translations$chat$welcome$midday$lunch$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '午餐记账';
	@override String get prompt => '记一笔午餐';
	@override String get description => '记录午餐开销';
}

// Path: chat.welcome.midday.weeklyExpense
class Translations$chat$welcome$midday$weeklyExpense$zh implements Translations$chat$welcome$midday$weeklyExpense$en {
	Translations$chat$welcome$midday$weeklyExpense$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '本周消费';
	@override String get prompt => '分析本周消费';
	@override String get description => '了解本周花费情况';
}

// Path: chat.welcome.midday.checkBalance
class Translations$chat$welcome$midday$checkBalance$zh implements Translations$chat$welcome$midday$checkBalance$en {
	Translations$chat$welcome$midday$checkBalance$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '查看余额';
	@override String get prompt => '查看账户余额';
	@override String get description => '看看各账户还剩多少';
}

// Path: chat.welcome.afternoon.quickRecord
class Translations$chat$welcome$afternoon$quickRecord$zh implements Translations$chat$welcome$afternoon$quickRecord$en {
	Translations$chat$welcome$afternoon$quickRecord$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '随手记账';
	@override String get prompt => '帮我记一笔';
	@override String get description => '快速记录一笔消费';
}

// Path: chat.welcome.afternoon.analyzeSpending
class Translations$chat$welcome$afternoon$analyzeSpending$zh implements Translations$chat$welcome$afternoon$analyzeSpending$en {
	Translations$chat$welcome$afternoon$analyzeSpending$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '分析消费';
	@override String get prompt => '分析本月消费';
	@override String get description => '查看消费趋势和构成';
}

// Path: chat.welcome.afternoon.budgetProgress
class Translations$chat$welcome$afternoon$budgetProgress$zh implements Translations$chat$welcome$afternoon$budgetProgress$en {
	Translations$chat$welcome$afternoon$budgetProgress$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '财务健康';
	@override String get prompt => '评估我的财务健康';
	@override String get description => '收支平衡评分与建议';
}

// Path: chat.welcome.evening.dinner
class Translations$chat$welcome$evening$dinner$zh implements Translations$chat$welcome$evening$dinner$en {
	Translations$chat$welcome$evening$dinner$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '晚餐记账';
	@override String get prompt => '记一笔晚餐';
	@override String get description => '记录今天的晚餐消费';
}

// Path: chat.welcome.evening.todaySummary
class Translations$chat$welcome$evening$todaySummary$zh implements Translations$chat$welcome$evening$todaySummary$en {
	Translations$chat$welcome$evening$todaySummary$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '今日总结';
	@override String get prompt => '总结今天的消费';
	@override String get description => '看看今天花了多少';
}

// Path: chat.welcome.evening.tomorrowPlan
class Translations$chat$welcome$evening$tomorrowPlan$zh implements Translations$chat$welcome$evening$tomorrowPlan$en {
	Translations$chat$welcome$evening$tomorrowPlan$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '明日计划';
	@override String get prompt => '明天有什么固定支出';
	@override String get description => '提前规划明天的消费';
}

// Path: chat.welcome.night.makeupRecord
class Translations$chat$welcome$night$makeupRecord$zh implements Translations$chat$welcome$night$makeupRecord$en {
	Translations$chat$welcome$night$makeupRecord$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '补记今日';
	@override String get prompt => '帮我补记今天的消费';
	@override String get description => '把今天忘记的账补上';
}

// Path: chat.welcome.night.monthlyReview
class Translations$chat$welcome$night$monthlyReview$zh implements Translations$chat$welcome$night$monthlyReview$en {
	Translations$chat$welcome$night$monthlyReview$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '本月分析';
	@override String get prompt => '详细分析本月支出';
	@override String get description => '回顾这个月的钱花哪了';
}

// Path: chat.welcome.night.financialThinking
class Translations$chat$welcome$night$financialThinking$zh implements Translations$chat$welcome$night$financialThinking$en {
	Translations$chat$welcome$night$financialThinking$zh.internal(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '未来预测';
	@override String get prompt => '预测未来 30 天余额';
	@override String get description => '看清未来的财务趋势';
}

/// The flat map containing all translations for locale <zh>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsZh {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.loading' => '加载中...',
			'common.error' => '错误',
			'common.retry' => '重试',
			'common.cancel' => '取消',
			'common.confirm' => '确认',
			'common.save' => '保存',
			'common.delete' => '删除',
			'common.edit' => '编辑',
			'common.add' => '添加',
			'common.search' => '搜索',
			'common.filter' => '筛选',
			'common.sort' => '排序',
			'common.refresh' => '刷新',
			'common.more' => '更多',
			'common.less' => '收起',
			'common.all' => '全部',
			'common.none' => '无',
			'common.ok' => '确定',
			'common.unknown' => '未知',
			'common.noData' => '暂无数据',
			'common.loadMore' => '加载更多',
			'common.noMore' => '没有更多了',
			'common.loadFailed' => '加载失败',
			'common.history' => '交易记录',
			'common.reset' => '重置',
			'time.today' => '今天',
			'time.yesterday' => '昨天',
			'time.dayBeforeYesterday' => '前天',
			'time.thisWeek' => '本周',
			'time.thisMonth' => '本月',
			'time.thisYear' => '今年',
			'time.selectDate' => '选择日期',
			'time.selectTime' => '选择时间',
			'time.justNow' => '刚刚',
			'time.minutesAgo' => ({required Object count}) => '${count}分钟前',
			'time.hoursAgo' => ({required Object count}) => '${count}小时前',
			'time.daysAgo' => ({required Object count}) => '${count}天前',
			'time.weeksAgo' => ({required Object count}) => '${count}周前',
			'greeting.morning' => '上午好',
			'greeting.afternoon' => '下午好',
			'greeting.evening' => '晚上好',
			'navigation.home' => '首页',
			'navigation.forecast' => '预测',
			'navigation.footprint' => '足迹',
			'navigation.profile' => '我的',
			'auth.login' => '登录',
			'auth.loggingIn' => '登录中...',
			'auth.logout' => '退出',
			'auth.logoutSuccess' => '已成功退出登录',
			'auth.confirmLogoutTitle' => '确认退出登录',
			'auth.confirmLogoutContent' => '您确定要退出当前的登录状态吗？',
			'auth.register' => '注册',
			'auth.registering' => '注册中...',
			'auth.welcomeBack' => '欢迎回来',
			'auth.loginSuccess' => '欢迎回来!',
			'auth.loginFailed' => '登录失败',
			'auth.pleaseTryAgain' => '请稍后重试。',
			'auth.loginSubtitle' => '登录以继续使用 AI 记账助理',
			'auth.noAccount' => '还没有账户？注册',
			'auth.createAccount' => '创建您的账户',
			'auth.setPassword' => '设置密码',
			'auth.setAccountPassword' => '设置您的账户密码',
			'auth.completeRegistration' => '完成注册',
			'auth.registrationSuccess' => '注册成功!',
			'auth.registrationFailed' => '注册失败',
			'auth.email.label' => '邮箱',
			'auth.email.placeholder' => '请输入您的邮箱',
			'auth.email.required' => '邮箱不能为空',
			'auth.email.invalid' => '请输入有效的邮箱地址',
			'auth.password.label' => '密码',
			'auth.password.placeholder' => '请输入您的密码',
			'auth.password.required' => '密码不能为空',
			'auth.password.tooShort' => '密码长度不能少于6位',
			'auth.password.mustContainNumbersAndLetters' => '密码必须包含数字和字母',
			'auth.password.confirm' => '确认密码',
			'auth.password.confirmPlaceholder' => '请再次输入您的密码',
			'auth.password.mismatch' => '两次输入的密码不一致',
			'auth.verificationCode.label' => '验证码',
			'auth.verificationCode.get' => '获取验证码',
			'auth.verificationCode.sending' => '发送中...',
			'auth.verificationCode.sent' => '验证码已发送',
			'auth.verificationCode.sendFailed' => '发送失败',
			'auth.verificationCode.placeholder' => '暂不校验，随意输入',
			'auth.verificationCode.required' => '验证码不能为空',
			'transaction.expense' => '支出',
			'transaction.income' => '收入',
			'transaction.transfer' => '转账',
			'transaction.amount' => '金额',
			'transaction.category' => '分类',
			'transaction.description' => '描述',
			'transaction.tags' => '标签',
			'transaction.saveTransaction' => '保存记账',
			'transaction.pleaseEnterAmount' => '请输入金额',
			'transaction.pleaseSelectCategory' => '请选择分类',
			'transaction.saveFailed' => '保存失败',
			'transaction.descriptionHint' => '记录这笔交易的详细信息...',
			'transaction.addCustomTag' => '添加自定义标签',
			'transaction.commonTags' => '常用标签',
			'transaction.maxTagsHint' => ({required Object maxTags}) => '最多添加 ${maxTags} 个标签',
			'transaction.noTransactionsFound' => '没有找到交易记录',
			'transaction.tryAdjustingSearch' => '尝试调整搜索条件或创建新的交易记录',
			'transaction.noDescription' => '无描述',
			'transaction.payment' => '支付',
			'transaction.account' => '账户',
			'transaction.time' => '时间',
			'transaction.location' => '地点',
			'transaction.recorder' => '记录人',
			'transaction.transactionDetail' => '交易详情',
			'transaction.favorite' => '收藏',
			'transaction.confirmDelete' => '确认删除',
			'transaction.deleteTransactionConfirm' => '您确定要删除此条交易记录吗？此操作无法撤销。',
			'transaction.noActions' => '没有可用的操作',
			'transaction.deleted' => '已删除',
			'transaction.deleteFailed' => '删除失败，请稍后重试',
			'transaction.linkedAccount' => '关联账户',
			'transaction.linkedSpace' => '关联空间',
			'transaction.notLinked' => '未关联',
			'transaction.link' => '关联',
			'transaction.changeAccount' => '更换账户',
			'transaction.addSpace' => '添加空间',
			'transaction.nSpaces' => ({required Object count}) => '${count} 个空间',
			'transaction.selectLinkedAccount' => '选择关联账户',
			'transaction.selectLinkedSpace' => '选择关联空间',
			'transaction.noSpacesAvailable' => '暂无可用空间',
			'transaction.linkSuccess' => '关联成功',
			'transaction.linkFailed' => '关联失败',
			'transaction.rawInput' => '消息',
			'transaction.noRawInput' => '无消息',
			'transaction.attachments' => ({required Object count}) => '${count} 个附件',
			'transaction.viewInConversation' => '在对话中查看更多',
			'transaction.statusPending' => '待确认',
			'home.totalExpense' => '总消费金额',
			'home.todayExpense' => '今日支出',
			'home.monthExpense' => '本月支出',
			'home.yearProgress' => ({required Object year}) => '${year}年进度',
			'home.yearRemainingInfo' => ({required Object days, required Object percent}) => '余 ${days} 天 · ${percent}%',
			'home.amountHidden' => '••••••••',
			'home.loadFailed' => '加载失败',
			'home.noTransactions' => '暂无交易记录',
			'home.tryRefresh' => '刷新试试',
			'home.noMoreData' => '没有更多数据了',
			'home.userNotLoggedIn' => '用户未登录，无法加载数据',
			'comment.error' => '错误',
			'comment.commentFailed' => '评论失败',
			'comment.replyToPrefix' => ({required Object name}) => '回复 @${name}:',
			'comment.reply' => '回复',
			'comment.addNote' => '添加备注...',
			'comment.addNoteWithMention' => '评论或 @提及成员...',
			'comment.confirmDeleteTitle' => '确认删除',
			'comment.confirmDeleteContent' => '你确定要删除这条评论吗？此操作无法撤销。',
			'comment.success' => '成功',
			'comment.commentDeleted' => '评论已删除',
			'comment.deleteFailed' => '删除失败',
			'comment.deleteComment' => '删除评论',
			'comment.hint' => '提示',
			'comment.noActions' => '没有可用的操作',
			'comment.note' => '备注',
			'comment.noNote' => '暂无备注',
			'comment.loadFailed' => '加载备注失败',
			'calendar.title' => '消费日历',
			'calendar.weekdays.mon' => '一',
			'calendar.weekdays.tue' => '二',
			'calendar.weekdays.wed' => '三',
			'calendar.weekdays.thu' => '四',
			'calendar.weekdays.fri' => '五',
			'calendar.weekdays.sat' => '六',
			'calendar.weekdays.sun' => '日',
			'calendar.loadFailed' => '加载日历数据失败',
			'calendar.thisMonth' => ({required Object amount}) => '本月: ${amount}',
			'calendar.counting' => '统计中...',
			'calendar.unableToCount' => '无法统计',
			'calendar.trend' => '趋势: ',
			'calendar.noTransactionsTitle' => '当日无交易记录',
			'calendar.loadTransactionFailed' => '加载交易失败',
			'category.dailyConsumption' => '日常消费',
			'category.transportation' => '交通出行',
			'category.healthcare' => '医疗健康',
			'category.housing' => '住房物业',
			'category.education' => '教育培训',
			'category.incomeCategory' => '收入进账',
			'category.socialGifts' => '社交馈赠',
			'category.moneyTransfer' => '资金周转',
			'category.other' => '其他',
			'category.foodDining' => '餐饮美食',
			'category.shoppingRetail' => '购物消费',
			'category.housingUtilities' => '居住物业',
			'category.personalCare' => '个人护理',
			'category.entertainment' => '休闲娱乐',
			'category.medicalHealth' => '医疗健康',
			'category.insurance' => '保险',
			'category.socialGifting' => '人情往来',
			'category.financialTax' => '金融税务',
			'category.others' => '其他支出',
			'category.salaryWage' => '工资薪水',
			'category.businessTrade' => '经营交易',
			'category.investmentReturns' => '投资回报',
			'category.giftBonus' => '礼金红包',
			'category.refundRebate' => '退款返利',
			'category.generalTransfer' => '转账',
			'category.debtRepayment' => '债务还款',
			'settings.title' => '设置',
			'settings.language' => '语言',
			'settings.languageSettings' => '语言设置',
			'settings.selectLanguage' => '选择语言',
			'settings.languageChanged' => '语言已更改',
			'settings.restartToApply' => '重启应用以应用更改',
			'settings.theme' => '主题',
			'settings.darkMode' => '深色模式',
			'settings.lightMode' => '浅色模式',
			'settings.systemMode' => '跟随系统',
			'settings.developerOptions' => '开发者选项',
			'settings.authDebug' => '认证状态调试',
			'settings.authDebugSubtitle' => '查看认证状态和调试信息',
			'settings.fontTest' => '字体测试',
			'settings.fontTestSubtitle' => '测试应用字体显示效果',
			'settings.helpAndFeedback' => '帮助与反馈',
			'settings.helpAndFeedbackSubtitle' => '获取帮助或提供反馈',
			'settings.aboutApp' => '关于应用',
			'settings.aboutAppSubtitle' => '版本信息和检查更新',
			'settings.checkUpdate' => '检查更新',
			'settings.checkingUpdate' => '正在检查更新...',
			'settings.latestVersionToast' => '当前已是最新版本',
			'settings.newVersionTitle' => '发现新版本',
			'settings.updateNow' => '立即更新',
			'settings.updateLater' => '暂不更新',
			'settings.fetchUpdateFailed' => '检查更新失败，请稍后重试',
			'settings.currencyChangedRefreshHint' => ({required Object currency}) => '已切换为 ${currency}，新交易将以此货币记录',
			'settings.sharedSpace' => '共享空间',
			'settings.speechRecognition' => '语音识别',
			'settings.speechRecognitionSubtitle' => '配置语音输入参数',
			'settings.amountDisplayStyle' => '金额显示样式',
			'settings.currency' => '显示币种',
			'settings.appearance' => '外观设置',
			'settings.appearanceSubtitle' => '主题模式与配色方案',
			'settings.speechTest' => '语音测试',
			'settings.speechTestSubtitle' => '测试 WebSocket 语音连接',
			'settings.userTypeRegular' => '普通用户',
			'settings.selectAmountStyle' => '选择金额显示样式',
			'settings.amountStyleNotice' => '注意：金额样式主要应用于「交易流水」和「趋势分析」。为了保持视觉清晰，「账户余额」和「资产概览」等状态类数值将保持中性颜色。',
			'settings.currencyDescription' => '选择您的主要货币。未来的记账将默认使用此货币，统计和汇总也将以此货币显示。历史交易的原始金额不受影响。',
			'settings.editUsername' => '修改用户名',
			'settings.enterUsername' => '请输入用户名',
			'settings.usernameRequired' => '用户名不能为空',
			'settings.usernameUpdated' => '用户名已更新',
			'settings.avatarUpdated' => '头像已更新',
			'settings.appearanceUpdated' => '外观设置已更新',
			'appearance.title' => '外观设置',
			'appearance.themeMode' => '主题模式',
			'appearance.light' => '浅色',
			'appearance.dark' => '深色',
			'appearance.system' => '跟随系统',
			'appearance.colorScheme' => '配色方案',
			'appearance.palettes.zinc' => '锌灰',
			'appearance.palettes.slate' => '板岩',
			'appearance.palettes.red' => '绯红',
			'appearance.palettes.rose' => '玫瑰',
			'appearance.palettes.orange' => '橙色',
			'appearance.palettes.green' => '绿色',
			'appearance.palettes.blue' => '蓝色',
			'appearance.palettes.yellow' => '黄色',
			'appearance.palettes.violet' => '紫罗兰',
			'speech.title' => '语音识别设置',
			'speech.service' => '语音识别服务',
			'speech.systemVoice' => '系统语音',
			'speech.systemVoiceSubtitle' => '使用手机内置的语音识别服务（推荐）',
			'speech.selfHostedASR' => '自建 ASR 服务',
			'speech.selfHostedASRSubtitle' => '使用 WebSocket 连接到自建语音识别服务',
			'speech.serverConfig' => '服务器配置',
			'speech.serverAddress' => '服务器地址',
			'speech.port' => '端口',
			'speech.path' => '路径',
			'speech.saveConfig' => '保存配置',
			'speech.info' => '信息',
			'speech.infoContent' => '• 系统语音：使用设备内置服务，无需配置，响应更快\n• 自建 ASR：适用于自定义模型或离线场景\n\n更改将在下次使用语音输入时生效。',
			'speech.enterAddress' => '请输入服务器地址',
			'speech.enterValidPort' => '请输入有效的端口 (1-65535)',
			'speech.configSaved' => '配置已保存',
			'speech.systemVoiceRestrictedTitle' => '系统语音不可用',
			'speech.systemVoiceRestrictedContent' => '您的手机系统语音引擎不可用或服务未开启。建议在设置中开启语音服务或配置 WebSocket 自建语音服务。',
			'speech.dictationDisabledTitle' => '语音听写未开启',
			'speech.dictationDisabledContent' => '系统语音听写服务未开启。如果是 iOS 设备，请前往【设置 -> 通用 -> 键盘】开启【启用听写】。',
			'speech.permissionDeniedTitle' => '缺少语音权限',
			'speech.permissionDeniedContent' => '应用需要麦克风和语音识别权限才能使用此功能。请在系统设置中允许权限。',
			'speech.goToSettings' => '前往设置',
			'speech.systemVoiceStatusAvailable' => '系统语音服务支持正常',
			'speech.systemVoiceStatusRestricted' => '系统语音限制或不可用 (建议使用自建 ASR)',
			'speech.serviceNotConfigured' => '语音服务未配置，请在【设置 -> 语音识别】中配置服务器地址',
			'speech.connectionFailedTitle' => '语音服务连接失败',
			'speech.connectionFailed' => '无法连接到 WebSocket 语音识别服务，请检查服务器地址、端口或网络连通性。',
			'speech.noSpeechRecognized' => '未检测到语音输入，请重试',
			'amountTheme.chinaMarket' => '中国市场',
			'amountTheme.chinaMarketDesc' => '红涨绿跌/黑跌',
			'amountTheme.international' => '国际标准',
			'amountTheme.internationalDesc' => '绿涨红跌',
			'amountTheme.minimalist' => '极简模式',
			'amountTheme.minimalistDesc' => '仅通过符号区分',
			'amountTheme.colorBlind' => '色弱友好',
			'amountTheme.colorBlindDesc' => '蓝橙配色方案',
			'locale.chinese' => '中文（简体）',
			'locale.traditionalChinese' => '中文（繁体）',
			'locale.english' => 'English',
			'locale.japanese' => '日本語',
			'locale.korean' => '한국어',
			'budget.title' => '预算管理',
			'budget.detail' => '预算详情',
			'budget.info' => '预算信息',
			'budget.totalBudget' => '总预算',
			'budget.categoryBudget' => '分类预算',
			'budget.monthlySummary' => '本月预算汇总',
			'budget.used' => '已使用',
			'budget.remaining' => '剩余',
			'budget.overspent' => '超支',
			'budget.budget' => '预算',
			'budget.loadFailed' => '加载失败',
			'budget.noBudget' => '暂无预算',
			'budget.createHint' => '点击下方按钮设置您的预算',
			'budget.paused' => '已暂停',
			'budget.pause' => '暂停',
			'budget.resume' => '恢复',
			'budget.budgetPaused' => '预算已暂停',
			'budget.budgetResumed' => '预算已恢复',
			'budget.operationFailed' => '操作失败',
			'budget.deleteBudget' => '删除预算',
			'budget.deleteConfirm' => '确定要删除这个预算吗？此操作不可撤销。',
			'budget.type' => '类型',
			'budget.category' => '分类',
			'budget.period' => '周期',
			'budget.rollover' => '滚动预算',
			'budget.rolloverBalance' => '滚动余额',
			'budget.enabled' => '开启',
			'budget.disabled' => '关闭',
			'budget.statusNormal' => '预算正常',
			'budget.statusWarning' => '接近上限',
			'budget.statusOverspent' => '已超支',
			'budget.statusAchieved' => '目标达成',
			'budget.tipNormal' => ({required Object amount}) => '还剩 ${amount} 可用',
			'budget.tipWarning' => ({required Object amount}) => '仅剩 ${amount}，请注意控制',
			'budget.tipOverspent' => ({required Object amount}) => '已超支 ${amount}',
			'budget.tipAchieved' => '恭喜完成储蓄目标！',
			'budget.remainingAmount' => ({required Object amount}) => '剩余 ${amount}',
			'budget.overspentAmount' => ({required Object amount}) => '超支 ${amount}',
			'budget.budgetAmount' => ({required Object amount}) => '预算 ${amount}',
			'budget.active' => '活跃',
			'budget.all' => '全部',
			'budget.notFound' => '预算不存在或已被删除',
			'budget.setup' => '预算设置',
			'budget.settings' => '预算设置',
			'budget.setAmount' => '设置预算金额',
			'budget.setAmountDesc' => '为每个分类设置预算金额',
			'budget.monthly' => '月度预算',
			'budget.monthlyDesc' => '按月管理您的支出，适合大多数人',
			'budget.weekly' => '周预算',
			'budget.weeklyDesc' => '按周管理支出，更精细的控制',
			'budget.yearly' => '年度预算',
			'budget.yearlyDesc' => '长期财务规划，适合大额支出管理',
			'budget.editBudget' => '编辑预算',
			'budget.editBudgetDesc' => '修改预算金额和分类',
			'budget.reminderSettings' => '提醒设置',
			'budget.reminderSettingsDesc' => '设置预算提醒和通知',
			'budget.report' => '预算报告',
			'budget.reportDesc' => '查看详细的预算分析报告',
			'budget.welcome' => '欢迎使用预算功能！',
			'budget.createNewPlan' => '创建新的预算计划',
			'budget.welcomeDesc' => '通过设置预算，您可以更好地控制支出，实现财务目标。让我们开始设置您的第一个预算计划吧！',
			'budget.createDesc' => '为不同的支出类别设置预算限额，帮助您更好地管理财务。',
			'budget.newBudget' => '新建预算',
			'budget.budgetAmountLabel' => '预算金额',
			'budget.currency' => '货币',
			'budget.periodSettings' => '周期设置',
			'budget.autoGenerateTransactions' => '开启后按规则自动生成交易',
			'budget.cycle' => '周期',
			'budget.budgetCategory' => '预算分类',
			'budget.advancedOptions' => '高级选项',
			'budget.periodType' => '周期类型',
			'budget.anchorDay' => '起算日',
			'budget.selectPeriodType' => '选择周期类型',
			'budget.selectAnchorDay' => '选择起算日',
			'budget.rolloverDescription' => '未用完的预算结转到下期',
			'budget.createBudget' => '创建预算',
			'budget.save' => '保存',
			'budget.pleaseEnterAmount' => '请输入预算金额',
			'budget.invalidAmount' => '请输入有效的预算金额',
			'budget.updateSuccess' => '预算更新成功',
			'budget.createSuccess' => '预算创建成功',
			'budget.deleteSuccess' => '预算已删除',
			'budget.deleteFailed' => '删除失败',
			'budget.everyMonthDay' => ({required Object day}) => '每月 ${day} 号',
			'budget.periodWeekly' => '每周',
			'budget.periodBiweekly' => '双周',
			'budget.periodMonthly' => '每月',
			'budget.periodYearly' => '每年',
			'budget.statusActive' => '进行中',
			'budget.statusArchived' => '已归档',
			'budget.periodStatusOnTrack' => '正常',
			'budget.periodStatusWarning' => '预警',
			'budget.periodStatusExceeded' => '超支',
			'budget.periodStatusAchieved' => '达成',
			'budget.usedPercent' => ({required Object percent}) => '${percent}% 已使用',
			'budget.dayOfMonth' => ({required Object day}) => '${day} 号',
			'budget.tenThousandSuffix' => '万',
			'budget.settingsLoadFailed' => '加载设置失败',
			'budget.settingsSaveSuccess' => '设置已保存',
			'budget.settingsSaveFailed' => '保存失败',
			'budget.settingsSave' => '保存设置',
			'budget.settingsWarningThreshold' => '预警阈值',
			'budget.settingsWarningDesc' => '当使用率达到此百分比时显示预警状态',
			'budget.settingsAlertThreshold' => '超支阈值',
			'budget.settingsAlertDesc' => '当使用率达到此百分比时显示超支状态',
			'budget.settingsThresholdOrder' => '预警阈值不能大于超支阈值',
			'dateRange.custom' => '自定义',
			'dateRange.pickerTitle' => '选择时间范围',
			'dateRange.startDate' => '开始日期',
			'dateRange.endDate' => '结束日期',
			'dateRange.hint' => '请选择日期范围',
			'forecast.title' => '预测',
			'forecast.subtitle' => '基于您的财务数据智能预测未来现金流',
			'forecast.financialNavigator' => '你好，我是你的财务领航员',
			'forecast.financialMapSubtitle' => '只需3步，我们一起绘制你未来的财务地图',
			'forecast.predictCashFlow' => '预测未来现金流',
			'forecast.predictCashFlowDesc' => '看清每一天的财务状况',
			'forecast.aiSmartSuggestions' => 'AI智能建议',
			'forecast.aiSmartSuggestionsDesc' => '个性化的财务决策指导',
			'forecast.riskWarning' => '风险预警',
			'forecast.riskWarningDesc' => '提前发现潜在的财务风险',
			'forecast.analyzing' => '我正在分析你的财务数据，生成未来30天的现金流预测',
			'forecast.analyzePattern' => '分析收入支出模式',
			'forecast.calculateTrend' => '计算现金流趋势',
			'forecast.generateWarning' => '生成风险预警',
			'forecast.loadingForecast' => '正在加载财务预测...',
			'forecast.todayLabel' => '今日',
			'forecast.tomorrowLabel' => '明日',
			'forecast.balanceLabel' => '余额',
			'forecast.noSpecialEvents' => '无特殊事件',
			'forecast.financialSafetyLine' => '财务安全线',
			'forecast.currentSetting' => '当前设置',
			'forecast.dailySpendingEstimate' => '日常消费预估',
			'forecast.adjustDailySpendingAmount' => '调整每日消费预测金额',
			'forecast.tellMeYourSafetyLine' => '告诉我你的财务"安心线"是多少？',
			'forecast.safetyLineDescription' => '这是你希望账户保持的最低余额，当余额接近这个数值时，我会提醒你注意财务风险。',
			'forecast.dailySpendingQuestion' => '每天的"小日子"大概花多少？',
			'forecast.dailySpendingDescription' => '包括吃饭、交通、购物等日常开销\n这只是一个初始估算，我会通过你未来的真实记录，让预测越来越准',
			'forecast.perDay' => '每天',
			'forecast.referenceStandard' => '参考标准',
			'forecast.frugalType' => '节俭型',
			'forecast.comfortableType' => '舒适型',
			'forecast.relaxedType' => '宽松型',
			'forecast.frugalAmount' => '50-100元/天',
			'forecast.comfortableAmount' => '100-200元/天',
			'forecast.relaxedAmount' => '200-300元/天',
			'forecast.recurringTransaction.title' => '周期交易',
			'forecast.recurringTransaction.all' => '全部',
			'forecast.recurringTransaction.expense' => '支出',
			'forecast.recurringTransaction.income' => '收入',
			'forecast.recurringTransaction.transfer' => '转账',
			'forecast.recurringTransaction.noRecurring' => '暂无周期交易',
			'forecast.recurringTransaction.createHint' => '创建周期交易后，系统将自动为您生成交易记录',
			'forecast.recurringTransaction.create' => '创建周期交易',
			'forecast.recurringTransaction.edit' => '编辑周期交易',
			'forecast.recurringTransaction.newTransaction' => '新建周期交易',
			'forecast.recurringTransaction.deleteConfirm' => ({required Object name}) => '确定要删除周期交易「${name}」吗？此操作不可撤销。',
			'forecast.recurringTransaction.activateConfirm' => ({required Object name}) => '确定要启用周期交易「${name}」吗？启用后将按照设定的规则自动生成交易记录。',
			'forecast.recurringTransaction.pauseConfirm' => ({required Object name}) => '确定要暂停周期交易「${name}」吗？暂停后将不再自动生成交易记录。',
			'forecast.recurringTransaction.created' => '周期交易已创建',
			'forecast.recurringTransaction.updated' => '周期交易已更新',
			'forecast.recurringTransaction.activated' => '已启用',
			'forecast.recurringTransaction.paused' => '已暂停',
			'forecast.recurringTransaction.nextTime' => '下次',
			'forecast.recurringTransaction.sortByTime' => '按时间排序',
			'forecast.recurringTransaction.allPeriod' => '全部周期',
			'forecast.recurringTransaction.periodCount' => ({required Object type, required Object count}) => '${type}周期 (${count})',
			'forecast.recurringTransaction.confirmDelete' => '确认删除',
			'forecast.recurringTransaction.confirmActivate' => '确认启用',
			'forecast.recurringTransaction.confirmPause' => '确认暂停',
			'forecast.recurringTransaction.dynamicAmount' => '动态均值',
			'forecast.recurringTransaction.dynamicAmountTitle' => '金额需手动确认',
			'forecast.recurringTransaction.dynamicAmountDescription' => '系统将在账单日发送提醒，需要您手动确认具体金额后才会记账。',
			'forecast.recurringTransaction.confirmBeforeGeneration' => '生成前需确认',
			'forecast.recurringTransaction.confirmBeforeGenerationDesc' => '到期时生成待确认交易，需手动确认后记账',
			'forecast.recurringTransaction.pendingTitle' => '待确认交易',
			'forecast.recurringTransaction.pendingCount' => ({required Object count}) => '${count} 笔待确认',
			'forecast.recurringTransaction.confirm' => '确认',
			'forecast.recurringTransaction.skip' => '跳过',
			'forecast.recurringTransaction.noPending' => '无待确认交易',
			'forecast.recurringTransaction.confirmSuccess' => '已确认记账',
			'forecast.recurringTransaction.skipSuccess' => '已跳过',
			'forecast.recurringTransaction.interval' => '重复间隔',
			'forecast.recurringTransaction.selectDays' => '选择星期',
			'forecast.recurringTransaction.alwaysLastDay' => '固定在每月最后一天',
			'forecast.recurringTransaction.lastDayExecution' => '将在每月最后一天执行',
			'forecast.recurringTransaction.dayExecution' => ({required Object day, required Object suffix}) => '将在每月 ${day} 号${suffix}执行（短月份自动对齐月末）',
			'forecast.recurringTransaction.setEndDate' => '设置结束日期',
			'forecast.recurringTransaction.selectEndDate' => '选择结束日期',
			'forecast.recurringTransaction.preview' => '规则预览',
			'forecast.recurringTransaction.daily' => '每天',
			'forecast.recurringTransaction.weekly' => '每周',
			'forecast.recurringTransaction.monthly' => '每月',
			'forecast.recurringTransaction.yearly' => '每年',
			'forecast.recurringTransaction.custom' => '自定义',
			'forecast.recurringTransaction.cycle' => '周期',
			'forecast.recurringTransaction.dayUnit' => '天',
			'forecast.recurringTransaction.weekUnit' => '周',
			'forecast.recurringTransaction.monthUnit' => '个月',
			'forecast.recurringTransaction.yearUnit' => '年',
			'forecast.recurringTransaction.everyDays' => ({required Object count}) => '每 ${count} 天',
			'forecast.recurringTransaction.everyWeeks' => ({required Object count}) => '每 ${count} 周',
			'forecast.recurringTransaction.everyMonths' => ({required Object count}) => '每 ${count} 个月',
			'forecast.recurringTransaction.everyYears' => ({required Object count}) => '每 ${count} 年',
			'forecast.recurringTransaction.monthlyOnDay' => ({required Object day, required Object suffix}) => '每月 ${day} 号${suffix}',
			'forecast.recurringTransaction.everyMonthsOnDay' => ({required Object count, required Object day, required Object suffix}) => '每 ${count} 个月的 ${day} 号${suffix}',
			'forecast.recurringTransaction.monthlyLastDay' => '每月最后一天',
			'forecast.recurringTransaction.everyMonthsLastDay' => ({required Object count}) => '每 ${count} 个月的最后一天',
			'forecast.recurringTransaction.yearlyOn' => ({required Object month, required Object day}) => '每年 ${month}/${day}',
			_ => null,
		} ?? switch (path) {
			'forecast.recurringTransaction.everyYearsOn' => ({required Object count, required Object month, required Object day}) => '每 ${count} 年 ${month}/${day}',
			'forecast.recurringTransaction.weeklyOnDay' => ({required Object day}) => '每周的${day}',
			'forecast.recurringTransaction.weekdayMon' => '一',
			'forecast.recurringTransaction.weekdayTue' => '二',
			'forecast.recurringTransaction.weekdayWed' => '三',
			'forecast.recurringTransaction.weekdayThu' => '四',
			'forecast.recurringTransaction.weekdayFri' => '五',
			'forecast.recurringTransaction.weekdaySat' => '六',
			'forecast.recurringTransaction.weekdaySun' => '日',
			'forecast.recurringTransaction.weekdayOn' => '周',
			'forecast.recurringTransaction.weekdayJoiner' => '、',
			'forecast.recurringTransaction.weeklyDaysPrefix' => '的',
			'forecast.recurringTransaction.sourceAccount' => '转出账户',
			'forecast.recurringTransaction.targetAccount' => '转入账户',
			'forecast.recurringTransaction.expenseAccount' => '支出账户',
			'forecast.recurringTransaction.incomeAccount' => '收入账户',
			'forecast.recurringTransaction.selectSourceAccount' => '选择转出账户',
			'forecast.recurringTransaction.selectTargetAccount' => '选择转入账户',
			'forecast.recurringTransaction.selectExpenseAccount' => '选择支出账户',
			'forecast.recurringTransaction.selectIncomeAccount' => '选择收入账户',
			'forecast.recurringTransaction.amountNotFixed' => ({required Object type}) => '每次${type}金额不固定',
			'forecast.recurringTransaction.selectBothAccounts' => '请选择转出和转入账户',
			'forecast.recurringTransaction.selectAccountForType' => ({required Object type}) => '请选择${type}账户',
			'forecast.recurringTransaction.deleteConfirmGeneric' => '确定要删除这个周期交易吗？此操作不可撤销。',
			'forecast.recurringTransaction.selectDate' => ({required Object date}) => '选择 ${date}',
			'forecast.recurringTransaction.accountTypeCash' => '现金钱包',
			'forecast.recurringTransaction.accountTypeDeposit' => '银行存款',
			'forecast.recurringTransaction.accountTypeEMoney' => '电子钱包',
			'forecast.recurringTransaction.accountTypeInvestment' => '投资理财',
			'forecast.recurringTransaction.accountTypeReceivable' => '应收款项',
			'forecast.recurringTransaction.accountTypeCreditCard' => '信用卡',
			'forecast.recurringTransaction.accountTypeLoan' => '贷款账户',
			'forecast.recurringTransaction.accountTypePayable' => '应付款项',
			'forecast.recurringTransaction.assetAccount' => '资产账户',
			'forecast.recurringTransaction.liabilityAccount' => '负债账户',
			'forecast.recurringTransaction.noAssetAccounts' => '暂无资产账户',
			'forecast.recurringTransaction.goToFinanceToAddAccounts' => '请前往财务页面添加账户',
			'forecast.recurringTransaction.selectAccount' => '选择账户',
			'forecast.recurringTransaction.autoGenerateByRule' => '开启后按规则自动生成交易',
			'chat.newChat' => '新聊天',
			'chat.noMessages' => '没有消息可显示。',
			'chat.loadingFailed' => '加载失败',
			'chat.inputMessage' => '输入消息...',
			'chat.listening' => '正在聆听...',
			'chat.aiThinking' => '正在处理...',
			'chat.tools.processing' => '正在处理...',
			'chat.tools.read_file' => '正在查看文件...',
			'chat.tools.search_transactions' => '正在查询交易...',
			'chat.tools.query_budget_status' => '正在检查预算...',
			'chat.tools.create_budget' => '正在创建预算计划...',
			'chat.tools.get_cash_flow_analysis' => '正在分析现金流...',
			'chat.tools.get_financial_health_score' => '正在计算财务健康分...',
			'chat.tools.get_financial_summary' => '正在生成财务报告...',
			'chat.tools.evaluate_financial_health' => '正在评估财务健康...',
			'chat.tools.simulate_expense_impact' => '正在模拟购买影响...',
			'chat.tools.record_transactions' => '正在记账...',
			'chat.tools.create_transaction' => '正在记账...',
			'chat.tools.duckduckgo_search' => '正在搜索网络...',
			'chat.tools.execute_transfer' => '正在执行转账...',
			'chat.tools.list_dir' => '正在浏览目录...',
			'chat.tools.execute' => '正在执行脚本...',
			'chat.tools.analyze_spending' => '正在分析支出明细...',
			'chat.tools.analyze_cashflow' => '正在分析现金流...',
			'chat.tools.forecast_balance' => '正在预测未来余额...',
			'chat.tools.suggest_budget' => '正在推荐预算...',
			'chat.tools.list_spaces' => '正在获取共享空间...',
			'chat.tools.query_space_summary' => '正在查询空间摘要...',
			'chat.tools.prepare_transfer' => '正在准备转账...',
			'chat.tools.unknown' => '正在处理请求...',
			'chat.tools.done.read_file' => '已查看文件',
			'chat.tools.done.search_transactions' => '已查询交易',
			'chat.tools.done.query_budget_status' => '已检查预算',
			'chat.tools.done.create_budget' => '已创建预算',
			'chat.tools.done.get_cash_flow_analysis' => '已分析现金流',
			'chat.tools.done.get_financial_health_score' => '已计算健康分',
			'chat.tools.done.get_financial_summary' => '财务报告生成完成',
			'chat.tools.done.evaluate_financial_health' => '财务健康评估完成',
			'chat.tools.done.forecast_balance' => '余额预测完成',
			'chat.tools.done.simulate_expense_impact' => '购买影响模拟完成',
			'chat.tools.done.record_transactions' => '记账完成',
			'chat.tools.done.create_transaction' => '已完成记账',
			'chat.tools.done.duckduckgo_search' => '已搜索网络',
			'chat.tools.done.execute_transfer' => '转账完成',
			'chat.tools.done.list_dir' => '已浏览目录',
			'chat.tools.done.execute' => '脚本执行完成',
			'chat.tools.done.analyze_spending' => '支出分析完成',
			'chat.tools.done.analyze_cashflow' => '现金流分析完成',
			'chat.tools.done.suggest_budget' => '预算推荐完成',
			'chat.tools.done.list_spaces' => '共享空间获取完成',
			'chat.tools.done.query_space_summary' => '空间摘要查询完成',
			'chat.tools.done.prepare_transfer' => '转账准备完成',
			'chat.tools.done.unknown' => '处理完成',
			'chat.tools.done.analyze_finance' => '財務分析完成',
			'chat.tools.done.forecast_finance' => '財務預測完成',
			'chat.tools.done.analyze_budget' => '預算分析完成',
			'chat.tools.done.audit_analysis' => '審計分析完成',
			'chat.tools.done.budget_ops' => '預算處理完成',
			'chat.tools.done.create_shared_transaction' => '共享帳單創建完成',
			'chat.tools.done.prepareBudgetSimulation' => '预算模拟准备完成',
			'chat.tools.done.simulateBudget' => '预算模拟完成',
			'chat.tools.failed.unknown' => '操作失败',
			'chat.tools.cancelled' => '已取消',
			'chat.tools.analyze_finance' => '正在分析財務狀況...',
			'chat.tools.forecast_finance' => '正在預測財務趨勢...',
			'chat.tools.analyze_budget' => '正在分析預算...',
			'chat.tools.audit_analysis' => '正在審計分析...',
			'chat.tools.budget_ops' => '正在處理預算...',
			'chat.tools.create_shared_transaction' => '正在創建共享帳單...',
			'chat.tools.prepareBudgetSimulation' => '正在准备预算模拟',
			'chat.tools.simulateBudget' => '正在模拟预算',
			'chat.speechNotRecognized' => '未识别到语音，请重试',
			'chat.currentExpense' => '当前支出',
			'chat.loadingComponent' => '正在加载组件...',
			'chat.noHistory' => '暂无历史会话',
			'chat.startNewChat' => '开启一段新对话吧！',
			'chat.searchHint' => '搜索会话',
			'chat.library' => '库',
			'chat.viewProfile' => '查看个人资料',
			'chat.noRelatedFound' => '未找到相关会话',
			'chat.tryOtherKeywords' => '尝试搜索其他关键词',
			'chat.searchFailed' => '搜索失败',
			'chat.deleteConversation' => '删除会话',
			'chat.deleteConversationConfirm' => '确定要删除这个会话吗？此操作无法撤销。',
			'chat.conversationDeleted' => '会话已删除',
			'chat.deleteConversationFailed' => '删除会话失败',
			'chat.transferWizard.title' => '转账向导',
			'chat.transferWizard.amount' => '转账金额',
			'chat.transferWizard.amountHint' => '请输入金额',
			'chat.transferWizard.sourceAccount' => '转出账户',
			'chat.transferWizard.targetAccount' => '转入账户',
			'chat.transferWizard.selectAccount' => '请选择账户',
			'chat.transferWizard.selectReceiveAccount' => '选择收款账户',
			'chat.transferWizard.confirmTransfer' => '确认转账',
			'chat.transferWizard.confirmed' => '已确认',
			'chat.transferWizard.transferSuccess' => '转账成功',
			'chat.genui.expenseSummary.totalExpense' => '总支出',
			'chat.genui.expenseSummary.mainExpenses' => '主要支出',
			'chat.genui.expenseSummary.viewAll' => ({required Object count}) => '查看全部 ${count} 笔消费',
			'chat.genui.expenseSummary.details' => '消费明细',
			'chat.genui.transactionList.searchResults' => ({required Object count}) => '搜索结果 (${count})',
			'chat.genui.transactionList.loaded' => ({required Object count}) => '已加载 ${count}',
			'chat.genui.transactionList.noResults' => '未找到相关交易',
			'chat.genui.transactionList.loadMore' => '滚动加载更多',
			'chat.genui.transactionList.allLoaded' => '全部加载完成',
			'chat.genui.transactionGroupReceipt.title' => '交易成功',
			'chat.genui.transactionGroupReceipt.count' => ({required Object count}) => '${count}笔',
			'chat.genui.transactionGroupReceipt.total' => '共计',
			'chat.genui.transactionGroupReceipt.selectAccount' => '选择关联账户',
			'chat.genui.transactionGroupReceipt.selectAccountSubtitle' => '此账户将应用到以上所有笔交易',
			'chat.genui.transactionGroupReceipt.associatedAccount' => ({required Object name}) => '已关联账户：${name}',
			'chat.genui.transactionGroupReceipt.clickToAssociate' => '点击关联账户（支持批量操作）',
			'chat.genui.transactionGroupReceipt.associateSuccess' => '已成功为所有交易关联账户',
			'chat.genui.transactionGroupReceipt.associateFailed' => ({required Object error}) => '操作失败: ${error}',
			'chat.genui.transactionGroupReceipt.accountAssociation' => '账户关联',
			'chat.genui.transactionGroupReceipt.sharedSpace' => '共享空间',
			'chat.genui.transactionGroupReceipt.notAssociated' => '未关联',
			'chat.genui.transactionGroupReceipt.addSpace' => '添加',
			'chat.genui.transactionGroupReceipt.selectSpace' => '选择共享空间',
			'chat.genui.transactionGroupReceipt.spaceAssociateSuccess' => '已关联到共享空间',
			'chat.genui.transactionGroupReceipt.spaceAssociateFailed' => ({required Object error}) => '关联共享空间失败: ${error}',
			'chat.genui.transactionGroupReceipt.currencyMismatchTitle' => '币种不一致',
			'chat.genui.transactionGroupReceipt.currencyMismatchDesc' => '交易币种与账户币种不同，系统将按当时汇率换算后扣减账户余额。',
			'chat.genui.transactionGroupReceipt.transactionAmount' => '交易金额',
			'chat.genui.transactionGroupReceipt.accountCurrency' => '账户币种',
			'chat.genui.transactionGroupReceipt.targetAccount' => '目标账户',
			'chat.genui.transactionGroupReceipt.currencyMismatchNote' => '提示：账户余额将按当时汇率进行换算扣减',
			'chat.genui.transactionGroupReceipt.confirmAssociate' => '确认关联',
			'chat.genui.transactionGroupReceipt.spaceCount' => ({required Object count}) => '${count} 空间',
			'chat.genui.budgetReceipt.newBudget' => '新预算',
			'chat.genui.budgetReceipt.budgetCreated' => '预算已创建',
			'chat.genui.budgetReceipt.rolloverBudget' => '滚动预算',
			'chat.genui.budgetReceipt.createFailed' => '创建预算失败',
			'chat.genui.budgetReceipt.thisMonth' => '本月',
			'chat.genui.budgetReceipt.dateRange' => ({required Object start, required Object startDay, required Object end, required Object endDay}) => '${start}月${startDay}日 - ${end}月${endDay}日',
			'chat.genui.budgetStatusCard.budget' => '预算',
			'chat.genui.budgetStatusCard.overview' => '预算概览',
			'chat.genui.budgetStatusCard.totalBudget' => '总预算',
			'chat.genui.budgetStatusCard.spent' => ({required Object amount}) => '已用 ¥${amount}',
			'chat.genui.budgetStatusCard.remaining' => ({required Object amount}) => '剩余 ¥${amount}',
			'chat.genui.budgetStatusCard.exceeded' => '已超支',
			'chat.genui.budgetStatusCard.warning' => '预算紧张',
			'chat.genui.budgetStatusCard.plentiful' => '预算充裕',
			'chat.genui.budgetStatusCard.normal' => '正常',
			'chat.genui.cashFlowForecast.title' => '现金流预测',
			'chat.genui.cashFlowForecast.recurringTransaction' => '周期性交易',
			'chat.genui.cashFlowForecast.recurringIncome' => '周期性收入',
			'chat.genui.cashFlowForecast.recurringExpense' => '周期性支出',
			'chat.genui.cashFlowForecast.recurringTransfer' => '周期性转账',
			'chat.genui.cashFlowForecast.nextDays' => ({required Object days}) => '未来 ${days} 天',
			'chat.genui.cashFlowForecast.noData' => '暂无预测数据',
			'chat.genui.cashFlowForecast.summary' => '预测摘要',
			'chat.genui.cashFlowForecast.variableExpense' => '预测可变支出',
			'chat.genui.cashFlowForecast.netChange' => '预计净变化',
			'chat.genui.cashFlowForecast.keyEvents' => '关键事件',
			'chat.genui.cashFlowForecast.noSignificantEvents' => '预测期内无重大事件',
			'chat.genui.cashFlowForecast.dateFormat' => 'M月d日',
			'chat.genui.healthScore.title' => '财务健康',
			'chat.genui.healthScore.suggestions' => '改进建议',
			'chat.genui.healthScore.scorePoint' => ({required Object score}) => '${score}分',
			'chat.genui.healthScore.status.excellent' => '财务状况优秀',
			'chat.genui.healthScore.status.good' => '财务状况良好',
			'chat.genui.healthScore.status.fair' => '财务状况一般',
			'chat.genui.healthScore.status.needsImprovement' => '财务状况需改善',
			'chat.genui.healthScore.status.poor' => '财务状况较差',
			'chat.genui.spaceSelector.selected' => '已选择',
			'chat.genui.spaceSelector.unnamedSpace' => '未命名空间',
			'chat.genui.spaceSelector.linked' => '已关联',
			'chat.genui.spaceSelector.roleOwner' => '创建者',
			'chat.genui.spaceSelector.roleAdmin' => '管理员',
			'chat.genui.spaceSelector.roleMember' => '成员',
			'chat.genui.spaceSelector.associateAction' => '关联到所选空间',
			'chat.genui.transferPath.selectSource' => '选择转出账户',
			'chat.genui.transferPath.selectTarget' => '选择转入账户',
			'chat.genui.transferPath.from' => '转出 (FROM)',
			'chat.genui.transferPath.to' => '转入 (TO)',
			'chat.genui.transferPath.select' => '请选择',
			'chat.genui.transferPath.cancelled' => '操作已取消',
			'chat.genui.transferPath.loadError' => '无法加载账户数据',
			'chat.genui.transferPath.historyMissing' => '历史记录中缺少账户信息',
			'chat.genui.transferPath.amountUnconfirmed' => '金额待确认',
			'chat.genui.transferPath.confirmedWithArrow' => ({required Object source, required Object target}) => '已确认：${source} → ${target}',
			'chat.genui.transferPath.confirmAction' => ({required Object source, required Object target}) => '确认：${source} → ${target}',
			'chat.genui.transferPath.pleaseSelectSource' => '请先选择转出账户',
			'chat.genui.transferPath.pleaseSelectTarget' => '请选择转入账户',
			'chat.genui.transferPath.confirmLinks' => '确认转账链路',
			'chat.genui.transferPath.linkLocked' => '链路已锁定',
			'chat.genui.transferPath.clickToConfirm' => '点击下方按钮确认执行',
			'chat.genui.transferPath.reselect' => '重选',
			'chat.genui.transferPath.title' => '转账',
			'chat.genui.transferPath.history' => '历史记录',
			'chat.genui.transferPath.unknownAccount' => '未知账户',
			'chat.genui.transferPath.confirmed' => '已确认',
			'chat.genui.transferPath.executeAction' => '按我的选择执行转账',
			'chat.genui.transactionCard.title' => '交易成功',
			'chat.genui.transactionCard.associatedAccount' => '已关联账户',
			'chat.genui.transactionCard.notCounted' => '不计入资产',
			'chat.genui.transactionCard.modify' => '修改',
			'chat.genui.transactionCard.associate' => '关联账户',
			'chat.genui.transactionCard.selectAccount' => '选择关联账户',
			'chat.genui.transactionCard.noAccount' => '暂无可用账户，请先添加账户',
			'chat.genui.transactionCard.missingId' => '交易 ID 缺失，无法更新',
			'chat.genui.transactionCard.associatedTo' => ({required Object name}) => '已关联到 ${name}',
			'chat.genui.transactionCard.updateFailed' => ({required Object error}) => '更新失败: ${error}',
			'chat.genui.transactionCard.sharedSpace' => '共享空间',
			'chat.genui.transactionCard.noSpace' => '暂无可用共享空间',
			'chat.genui.transactionCard.selectSpace' => '选择共享空间',
			'chat.genui.transactionCard.linkedToSpace' => '已关联到共享空间',
			'chat.genui.transactionConfirmation.multipleAccounts' => '检测到多个关联账户',
			'chat.genui.transactionConfirmation.confirmed' => '已确认',
			'chat.genui.budgetAnalysis.title' => '预算分析报告',
			'chat.genui.budgetAnalysis.periodDays' => ({required Object days}) => '过去 ${days} 天',
			'chat.genui.budgetAnalysis.totalExpense' => '总支出',
			'chat.genui.budgetAnalysis.momChange' => ({required Object change}) => '环比 ${change}%',
			'chat.genui.budgetAnalysis.categoryDistribution' => '分类占比',
			'chat.genui.budgetAnalysis.topSpenders' => '大额支出',
			'chat.genui.budgetAnalysis.amountWan' => ({required Object amount}) => '${amount}万',
			'chat.genui.cashFlowCard.title' => '现金流分析',
			'chat.genui.cashFlowCard.savingsRate' => ({required Object rate}) => '储蓄 ${rate}%',
			'chat.genui.cashFlowCard.totalIncome' => '总收入',
			'chat.genui.cashFlowCard.totalExpense' => '总支出',
			'chat.genui.cashFlowCard.essentialExpense' => '必要支出',
			'chat.genui.cashFlowCard.discretionaryExpense' => '可选消费',
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
			'chat.welcome.morning.subtitle' => '新的一天，从记录开始',
			'chat.welcome.morning.breakfast.title' => '早餐记账',
			'chat.welcome.morning.breakfast.prompt' => '记一笔早餐',
			'chat.welcome.morning.breakfast.description' => '快速记录今天的第一笔消费',
			'chat.welcome.morning.yesterdayReview.title' => '昨日回顾',
			'chat.welcome.morning.yesterdayReview.prompt' => '分析昨天的消费',
			'chat.welcome.morning.yesterdayReview.description' => '看看昨天花了多少钱',
			'chat.welcome.morning.todayBudget.title' => '今日预算',
			'chat.welcome.morning.todayBudget.prompt' => '今天还剩多少预算',
			'chat.welcome.morning.todayBudget.description' => '规划一天的消费额度',
			'chat.welcome.midday.greeting' => '中午好',
			'chat.welcome.midday.subtitle' => '午间时光，顺手记一笔',
			'chat.welcome.midday.lunch.title' => '午餐记账',
			'chat.welcome.midday.lunch.prompt' => '记一笔午餐',
			'chat.welcome.midday.lunch.description' => '记录午餐开销',
			'chat.welcome.midday.weeklyExpense.title' => '本周消费',
			'chat.welcome.midday.weeklyExpense.prompt' => '分析本周消费',
			'chat.welcome.midday.weeklyExpense.description' => '了解本周花费情况',
			'chat.welcome.midday.checkBalance.title' => '查看余额',
			'chat.welcome.midday.checkBalance.prompt' => '查看账户余额',
			'chat.welcome.midday.checkBalance.description' => '看看各账户还剩多少',
			'chat.welcome.afternoon.subtitle' => '下午茶时间，理理财',
			'chat.welcome.afternoon.quickRecord.title' => '随手记账',
			'chat.welcome.afternoon.quickRecord.prompt' => '帮我记一笔',
			'chat.welcome.afternoon.quickRecord.description' => '快速记录一笔消费',
			'chat.welcome.afternoon.analyzeSpending.title' => '分析消费',
			'chat.welcome.afternoon.analyzeSpending.prompt' => '分析本月消费',
			'chat.welcome.afternoon.analyzeSpending.description' => '查看消费趋势和构成',
			'chat.welcome.afternoon.budgetProgress.title' => '财务健康',
			'chat.welcome.afternoon.budgetProgress.prompt' => '评估我的财务健康',
			'chat.welcome.afternoon.budgetProgress.description' => '收支平衡评分与建议',
			'chat.welcome.evening.subtitle' => '辛苦一天，来理理账',
			'chat.welcome.evening.dinner.title' => '晚餐记账',
			'chat.welcome.evening.dinner.prompt' => '记一笔晚餐',
			'chat.welcome.evening.dinner.description' => '记录今天的晚餐消费',
			'chat.welcome.evening.todaySummary.title' => '今日总结',
			'chat.welcome.evening.todaySummary.prompt' => '总结今天的消费',
			'chat.welcome.evening.todaySummary.description' => '看看今天花了多少',
			'chat.welcome.evening.tomorrowPlan.title' => '明日计划',
			'chat.welcome.evening.tomorrowPlan.prompt' => '明天有什么固定支出',
			'chat.welcome.evening.tomorrowPlan.description' => '提前规划明天的消费',
			'chat.welcome.night.greeting' => '夜深了',
			'chat.welcome.night.subtitle' => '静心理财，规划未来',
			'chat.welcome.night.makeupRecord.title' => '补记今日',
			'chat.welcome.night.makeupRecord.prompt' => '帮我补记今天的消费',
			'chat.welcome.night.makeupRecord.description' => '把今天忘记的账补上',
			'chat.welcome.night.monthlyReview.title' => '本月分析',
			'chat.welcome.night.monthlyReview.prompt' => '详细分析本月支出',
			'chat.welcome.night.monthlyReview.description' => '回顾这个月的钱花哪了',
			'chat.welcome.night.financialThinking.title' => '未来预测',
			'chat.welcome.night.financialThinking.prompt' => '预测未来 30 天余额',
			'chat.welcome.night.financialThinking.description' => '看清未来的财务趋势',
			'footprint.searchIn' => '搜索',
			'footprint.searchInAllRecords' => '在所有记录中搜索相关内容',
			'media.selectPhotos' => '选择照片',
			'media.addFiles' => '添加文件',
			'media.takePhoto' => '拍照',
			'media.camera' => '相机',
			'media.photos' => '照片',
			'media.files' => '文件',
			'media.showAll' => '显示全部',
			'media.allPhotos' => '所有照片',
			'media.takingPhoto' => '拍照中...',
			'media.photoTaken' => '照片已保存',
			'media.cameraPermissionRequired' => '需要相机权限',
			'media.fileSizeExceeded' => '文件大小超过10MB限制',
			'media.unsupportedFormat' => '不支持的文件格式',
			'media.permissionDenied' => '需要相册访问权限',
			'media.storageInsufficient' => '存储空间不足',
			'media.networkError' => '网络连接错误',
			'media.unknownUploadError' => '上传时发生未知错误',
			'error.permissionRequired' => '需要权限',
			'error.permissionInstructions' => '请在设置中开启相册和存储权限，以便选择和上传文件。',
			'error.openSettings' => '打开设置',
			'error.fileTooLarge' => '文件过大',
			'error.fileSizeHint' => '请选择小于10MB的文件，或者压缩后再上传。',
			'error.supportedFormatsHint' => '支持的格式包括：图片(jpg, png, gif等)、文档(pdf, doc, txt等)、音视频文件等。',
			'error.storageCleanupHint' => '请清理设备存储空间后重试，或选择较小的文件。',
			'error.networkErrorHint' => '请检查网络连接是否正常，然后重试。',
			'error.platformNotSupported' => '平台不支持',
			'error.fileReadError' => '文件读取失败',
			'error.fileReadErrorHint' => '文件可能已损坏或被其他程序占用，请重新选择文件。',
			'error.validationError' => '文件验证失败',
			'error.unknownError' => '未知错误',
			'error.unknownErrorHint' => '发生了意外错误，请重试或联系技术支持。',
			'error.registrationMissingInfo' => '注册流程错误，缺少必要信息。',
			'error.genui.loadingFailed' => '组件加载失败',
			'error.genui.schemaFailed' => '架构验证失败',
			'error.genui.schemaDescription' => '组件定义不符合 GenUI 规范，降级为纯文本显示',
			'error.genui.networkError' => '网络错误',
			'error.genui.retryStatus' => ({required Object retryCount, required Object maxRetries}) => '已重试 ${retryCount}/${maxRetries} 次',
			'error.genui.maxRetriesReached' => '已达最大重试次数',
			'fontTest.page' => '字体测试页面',
			'fontTest.displayTest' => '字体显示测试',
			'fontTest.chineseTextTest' => '中文文本测试',
			'fontTest.englishTextTest' => '英文文本测试',
			'fontTest.sample1' => '这是一段中文文本，用于测试字体显示效果。',
			'fontTest.sample2' => '支出分类汇总，购物最高',
			'fontTest.sample3' => '人工智能助手为您提供专业的财务分析服务',
			'fontTest.sample4' => '数据可视化图表展示您的消费趋势',
			'fontTest.sample5' => '微信支付、支付宝、银行卡等多种支付方式',
			'wizard.nextStep' => '下一步',
			'wizard.previousStep' => '上一步',
			'wizard.completeMapping' => '完成绘制',
			'user.username' => '用户名',
			'user.defaultEmail' => 'user@example.com',
			'account.editTitle' => '编辑账户',
			'account.addTitle' => '新建账户',
			'account.selectTypeTitle' => '选择账户类型',
			'account.nameLabel' => '账户名称',
			'account.amountLabel' => '当前余额',
			'account.currencyLabel' => '币种',
			'account.hiddenLabel' => '隐藏',
			'account.hiddenDesc' => '在账户列表中隐藏该账户',
			'account.includeInNetWorthLabel' => '计入资产',
			'account.includeInNetWorthDesc' => '用于净资产统计',
			'account.nameHint' => '例如：工资卡',
			'account.amountHint' => '0.00',
			'account.deleteAccount' => '删除账户',
			'account.deleteConfirm' => '确定要删除该账户吗？此操作无法撤销。',
			'account.save' => '保存修改',
			'account.assetsCategory' => '资产类',
			'account.liabilitiesCategory' => '负债/信用类',
			'account.cash' => '现金钱包',
			'account.deposit' => '银行存款',
			'account.creditCard' => '信用卡',
			'account.investment' => '投资理财',
			'account.eWallet' => '电子钱包',
			'account.loan' => '贷款账户',
			'account.receivable' => '应收款项',
			'account.payable' => '应付款项',
			'account.other' => '其他账户',
			'account.types.cashTitle' => '现金',
			'account.types.cashSubtitle' => '纸币、硬币等实体货币',
			'account.types.depositTitle' => '银行存款',
			'account.types.depositSubtitle' => '储蓄卡、活期/定期存款',
			'account.types.eMoneyTitle' => '电子钱包',
			'account.types.eMoneySubtitle' => '第三方支付平台余额',
			'account.types.investmentTitle' => '投资账户',
			'account.types.investmentSubtitle' => '股票、基金、债券等',
			'account.types.receivableTitle' => '应收款项',
			'account.types.receivableSubtitle' => '借出款项、待收账款',
			'account.types.receivableHelper' => '他人欠我',
			'account.types.creditCardTitle' => '信用卡',
			'account.types.creditCardSubtitle' => '信用卡账户欠款',
			'account.types.loanTitle' => '贷款',
			'account.types.loanSubtitle' => '房贷、车贷、消费贷等',
			'account.types.payableTitle' => '应付款项',
			'account.types.payableSubtitle' => '借入款项、待付账款',
			'account.types.payableHelper' => '我欠他人',
			'financial.title' => '财务',
			'financial.management' => '财务管理',
			'financial.netWorth' => '总净值',
			'financial.assets' => '总资产',
			'financial.liabilities' => '总负债',
			'financial.noAccounts' => '暂无账户',
			'financial.addFirstAccount' => '点击下方按钮添加您的第一个账户',
			'financial.assetAccounts' => '资产账户',
			'financial.liabilityAccounts' => '负债账户',
			'financial.selectCurrency' => '选择货币',
			'financial.cancel' => '取消',
			'financial.confirm' => '确定',
			'financial.settings' => '财务设置',
			'financial.budgetManagement' => '预算管理',
			'financial.recurringTransactions' => '周期交易',
			'financial.safetyThreshold' => '安全阈值',
			'financial.dailyBurnRate' => '每日消费',
			'financial.financialAssistant' => '财务助手',
			'financial.manageFinancialSettings' => '管理您的财务设置',
			'financial.safetyThresholdSettings' => '财务安全线设置',
			'financial.setSafetyThreshold' => '设置您的财务安全阈值',
			'financial.safetyThresholdSaved' => '财务安全线已保存',
			'financial.dailyBurnRateSettings' => '日常消费预估',
			'financial.setDailyBurnRate' => '设置您的日常消费预估金额',
			'financial.dailyBurnRateSaved' => '日常消费预估已保存',
			'financial.dayUnit' => '天',
			'financial.saveFailed' => '保存失败',
			'app.splashTitle' => '智见增长，格物致富。',
			'app.splashSubtitle' => '智能财务助手',
			'statistics.title' => '统计分析',
			'statistics.analyze' => '统计分析',
			'statistics.exportInProgress' => '导出功能开发中...',
			'statistics.ranking' => '大额消费排行',
			'statistics.noData' => '暂无数据',
			'statistics.overview.balance' => '总结余',
			'statistics.overview.income' => '总收入',
			'statistics.overview.expense' => '总支出',
			'statistics.trend.title' => '收支趋势',
			'statistics.trend.expense' => '支出',
			'statistics.trend.income' => '收入',
			'statistics.analysis.title' => '支出分析',
			'statistics.analysis.expenseTitle' => '支出分析',
			'statistics.analysis.incomeTitle' => '收入分析',
			'statistics.analysis.total' => '总计',
			'statistics.analysis.breakdown' => '支出分类明细',
			'statistics.analysis.radarNeedMoreData' => '雷达图需要至少3个分类数据',
			'statistics.filter.accountType' => '账户类型',
			'statistics.filter.allAccounts' => '全部账户',
			'statistics.filter.apply' => '确认应用',
			'statistics.sort.amount' => '按金额排序',
			'statistics.sort.date' => '按时间排序',
			'statistics.exportList' => '导出列表',
			'statistics.emptyState.title' => '开启财务洞察',
			'statistics.emptyState.description' => '您的财务报表目前是一张白纸。\n记录第一笔消费，让数据为您讲述财富故事。',
			'statistics.emptyState.action' => '记录首笔交易',
			'statistics.noMoreData' => '没有更多数据了',
			'currency.cny' => '人民币',
			'currency.usd' => '美元',
			'currency.eur' => '欧元',
			'currency.jpy' => '日元',
			'currency.gbp' => '英镑',
			'currency.aud' => '澳元',
			'currency.cad' => '加元',
			'currency.chf' => '瑞士法郎',
			'currency.rub' => '俄罗斯卢布',
			'currency.hkd' => '港币',
			'currency.twd' => '新台币',
			'currency.inr' => '印度卢比',
			'budgetSuggestion.highPercentage' => ({required Object category, required Object percentage}) => '${category} 占支出的 ${percentage}%，建议设置预算上限',
			'budgetSuggestion.monthlyIncrease' => ({required Object percentage}) => '本月支出增长了 ${percentage}%，需要关注',
			'budgetSuggestion.frequentSmall' => ({required Object category, required Object count}) => '${category} 有 ${count} 笔小额交易，可能是订阅消费',
			'budgetSuggestion.financialInsights' => '财务洞察',
			'server.title' => '连接服务器',
			'server.subtitle' => '输入您自部署的服务器地址，或扫描服务器启动时显示的二维码',
			'server.urlLabel' => '服务器地址',
			'server.urlPlaceholder' => '例如：https://api.example.com 或 192.168.1.100:8000',
			'server.scanQr' => '扫描二维码',
			'server.scanQrInstruction' => '对准服务器终端显示的二维码',
			'server.testConnection' => '测试连接',
			'server.connecting' => '正在连接...',
			'server.connected' => '已连接',
			'server.connectionFailed' => '连接失败',
			'server.continueToLogin' => '继续登录',
			'server.saveAndReturn' => '保存并返回',
			'server.saveAndReLogin' => '保存并重新登录',
			'server.serverUrlSavedRedirectLogin' => '服务器配置已更新，请重新登录',
			'server.serverSettings' => '服务器设置',
			'server.currentServer' => '当前服务器',
			_ => null,
		} ?? switch (path) {
			'server.version' => '版本',
			'server.environment' => '环境',
			'server.changeServer' => '更换服务器',
			'server.changeServerWarning' => '更换服务器将退出登录，是否继续？',
			'server.error.urlRequired' => '请输入服务器地址',
			'server.error.invalidUrl' => 'URL 格式无效',
			'server.error.connectionTimeout' => '连接超时',
			'server.error.connectionRefused' => '无法连接到服务器',
			'server.error.sslError' => 'SSL 证书错误',
			'server.error.serverError' => '服务器错误',
			'sharedSpace.dashboard.sectionTitle' => '财务概览',
			'sharedSpace.dashboard.cumulativeTotalExpense' => '累计总支出',
			'sharedSpace.dashboard.participatingMembers' => '参与成员',
			'sharedSpace.dashboard.membersCount' => ({required Object count}) => '${count} 人',
			'sharedSpace.dashboard.averagePerMember' => '成员人均',
			'sharedSpace.dashboard.spendingDistribution' => '成员消费分布',
			'sharedSpace.dashboard.realtimeUpdates' => '实时更新',
			'sharedSpace.dashboard.paid' => '已支付',
			'sharedSpace.roles.owner' => '主理人',
			'sharedSpace.roles.admin' => '管理员',
			'sharedSpace.roles.member' => '成员',
			'sharedSpace.title' => '共享空间',
			'sharedSpace.create.title' => '创建共享空间',
			'sharedSpace.create.subtitle' => '创建一个新的共享空间，与朋友一起记账',
			'sharedSpace.create.nameLabel' => '空间名称',
			'sharedSpace.create.nameHint' => '例如：毕业旅行',
			'sharedSpace.create.descLabel' => '描述（可选）',
			'sharedSpace.create.descHint' => '记录我们的共同旅行开销',
			'sharedSpace.create.cancel' => '取消',
			'sharedSpace.create.submit' => '创建',
			'sharedSpace.create.nameRequired' => '请输入空间名称',
			'sharedSpace.create.nameTooShort' => '空间名称至少需要 2 个字符',
			'sharedSpace.create.nameTooLong' => '空间名称不能超过 50 个字符',
			'sharedSpace.join.title' => '加入共享空间',
			'sharedSpace.join.subtitle' => '输入朋友分享的邀请码，开始协作记账',
			'sharedSpace.join.codeLabel' => '邀请码',
			'sharedSpace.join.codeHint' => '输入邀请码，例如：123456',
			'sharedSpace.join.cancel' => '取消',
			'sharedSpace.join.submit' => '加入',
			'sharedSpace.join.codeRequired' => '请输入邀请码',
			'sharedSpace.join.codeInvalid' => '邀请码格式无效',
			'sharedSpace.join.codeFormat' => '邀请码只能包含字母和数字',
			'sharedSpace.list.emptyTitle' => '开启多方协同的财务空间',
			'sharedSpace.list.emptySubtitle' => '创建或加入共享空间，与家人、伴侣或团队协同管理共享账目与资产',
			'sharedSpace.list.getStarted' => '开始使用',
			'sharedSpace.list.hasInviteCode' => '有邀请码？点击加入',
			'sharedSpace.list.joinedSuccess' => ({required Object name}) => '成功加入「${name}」！',
			'sharedSpace.detail.members' => '成员',
			'sharedSpace.detail.transactions' => '交易记录',
			'sharedSpace.detail.recordsCount' => ({required Object count}) => '${count} 笔',
			'sharedSpace.detail.settlement' => '结算',
			'sharedSpace.detail.inviteCode' => '邀请码',
			'sharedSpace.detail.copyCode' => '复制邀请码',
			'sharedSpace.detail.codeCopied' => ({required Object code}) => '邀请码已复制：${code}',
			'sharedSpace.detail.validFor24h' => '24 小时内有效',
			'sharedSpace.detail.leaveSpace' => '退出空间',
			'sharedSpace.detail.deleteSpace' => '删除空间',
			'sharedSpace.detail.removeMember' => '移除成员',
			'sharedSpace.detail.leaveConfirm' => '确定要退出此共享空间吗？退出后将无法查看空间内的交易记录。',
			'sharedSpace.detail.deleteConfirm' => '确定要删除此共享空间吗？此操作不可撤销，所有成员将被移出。',
			'sharedSpace.detail.removeConfirm' => '确定要将此成员移出共享空间吗？',
			'sharedSpace.detail.generatingCode' => '正在生成邀请码...',
			'sharedSpace.detail.loadFailed' => '加载失败',
			'sharedSpace.detail.retry' => '重试',
			'sharedSpace.detail.noTransactions' => '暂无交易记录',
			'sharedSpace.detail.noTransactionsHint' => '空间内的交易将显示在这里',
			'sharedSpace.detail.refreshCode' => '刷新生成新码',
			'sharedSpace.detail.joinOtherSpace' => '加入其他空间',
			'sharedSpace.notifications.title' => '通知',
			'sharedSpace.notifications.empty' => '暂无通知',
			'sharedSpace.notifications.emptyHint' => '当你收到新的邀请或动态时，\n通知将显示在这里',
			'sharedSpace.notifications.incompleteInfo' => '邀请信息不完整',
			'sharedSpace.notifications.inviteAccepted' => '已接受邀请！',
			'sharedSpace.notifications.inviteRejected' => '已拒绝邀请',
			'sharedSpace.notifications.allMarkedRead' => '全部标记为已读',
			'sharedSpace.inviteCard.title' => '邀请码',
			'sharedSpace.inviteCard.subtitle' => '分享给朋友以加入空间',
			'sharedSpace.inviteCard.copyCode' => '复制邀请码',
			'sharedSpace.inviteCard.shareLink' => '分享邀请链接',
			'sharedSpace.inviteCard.codeCopied' => '邀请码已复制',
			'sharedSpace.inviteCard.noExpiry' => '无有效期限制',
			'sharedSpace.inviteCard.expired' => '已过期',
			'sharedSpace.inviteCard.expiresInDays' => ({required Object days}) => '${days} 天后过期',
			'sharedSpace.inviteCard.expiresInHours' => ({required Object hours}) => '${hours} 小时后过期',
			'sharedSpace.inviteCard.expiresInMinutes' => ({required Object minutes}) => '${minutes} 分钟后过期',
			'sharedSpace.inviteCard.expiringSoon' => '即将过期',
			'sharedSpace.inviteCard.shareText' => ({required Object spaceName, required Object code, required Object link, required Object expiry}) => '邀请你加入共享空间「${spaceName}」\n\n邀请码：${code}\n或点击链接直接加入：${link}\n\n邀请码${expiry}',
			'sharedSpace.inviteSuccess.title' => '创建成功',
			'sharedSpace.inviteSuccess.subtitle' => '共享空间创建成功',
			'sharedSpace.inviteSuccess.inviteLater' => '稍后邀请',
			'sharedSpace.inviteSuccess.enterSpace' => '进入空间',
			'sharedSpace.inviteSuccess.generatingCode' => '正在生成邀请码...',
			'sharedSpace.inviteSuccess.generateFailed' => '邀请码生成失败',
			'sharedSpace.inviteSuccess.codeCopied' => '邀请码已复制',
			'sharedSpace.inviteSuccess.retry' => '重试',
			'sharedSpace.inviteSuccess.codeLabel' => '邀请码',
			'sharedSpace.inviteSuccess.validHint' => '24 小时内有效 · 点击复制',
			'sharedSpace.notificationCard.accept' => '接受',
			'sharedSpace.notificationCard.reject' => '拒绝',
			'sharedSpace.notificationCard.unknownTime' => '未知时间',
			'sharedSpace.notificationCard.justNow' => '刚刚',
			'sharedSpace.spaceCard.noDescription' => '暂无描述',
			'sharedSpace.spaceCard.creator' => '创建者',
			'sharedSpace.spaceCard.member' => '成员',
			'sharedSpace.spaceCard.membersCount' => ({required Object count}) => '${count} 位成员',
			'sharedSpace.spaceCard.transactionsCount' => ({required Object count}) => '${count} 笔账单',
			'sharedSpace.settings.title' => '空间设置',
			'sharedSpace.settings.spaceInfo' => '空间信息',
			'sharedSpace.settings.nameLabel' => '空间名称',
			'sharedSpace.settings.descLabel' => '空间描述',
			'sharedSpace.settings.save' => '保存',
			'sharedSpace.settings.saved' => '保存成功',
			'sharedSpace.settings.saveFailed' => '保存失败',
			'sharedSpace.settings.memberManagement' => '成员管理',
			'sharedSpace.settings.membersCount' => ({required Object count}) => '${count} 位成员',
			'sharedSpace.settings.removeMemberConfirm' => ({required Object name}) => '确定要将「${name}」移出空间吗？',
			'sharedSpace.settings.removed' => '已移除成员',
			'sharedSpace.settings.removeFailed' => '移除失败',
			'sharedSpace.settings.inviteManagement' => '邀请管理',
			'sharedSpace.settings.currentCode' => '当前邀请码',
			'sharedSpace.settings.generateNew' => '生成新邀请码',
			'sharedSpace.settings.noValidCode' => '暂无有效邀请码',
			'sharedSpace.settings.refreshCode' => '刷新生成新码',
			'sharedSpace.settings.refreshConfirm' => '生成新码将使旧邀请码失效，确定继续？',
			'sharedSpace.settings.codeRefreshed' => '邀请码已刷新',
			'sharedSpace.settings.dangerZone' => '危险操作',
			'sharedSpace.settings.editHint' => '仅管理员可编辑',
			'sharedSpace.settings.edit' => '编辑',
			'sharedSpace.settings.you' => '我',
			'sharedSpace.settings.pending' => '待接受',
			'sharedSpace.settings.declined' => '已拒绝',
			'sharedSpace.settings.setAsAdmin' => '设为管理员',
			'sharedSpace.settings.setAsMember' => '设为普通成员',
			'sharedSpace.settings.changeRole' => '变更角色',
			'sharedSpace.settings.changeRoleConfirm' => ({required Object name, required Object role}) => '确定要将「${name}」的角色变更为「${role}」吗？',
			'sharedSpace.settings.confirm' => '确认',
			'sharedSpace.settings.roleChanged' => '角色已变更',
			'sharedSpace.settings.roleChangeFailed' => '角色变更失败',
			'errorMapping.generic.badRequest' => '请求无效',
			'errorMapping.generic.authFailed' => '认证失败，请重新登录',
			'errorMapping.generic.permissionDenied' => '权限不足',
			'errorMapping.generic.notFound' => '资源未找到',
			'errorMapping.generic.serverError' => '服务器内部错误',
			'errorMapping.generic.systemError' => '系统错误',
			'errorMapping.generic.validationFailed' => '数据验证失败',
			'errorMapping.auth.failed' => '认证失败',
			'errorMapping.auth.emailWrong' => '邮箱错误',
			'errorMapping.auth.phoneWrong' => '手机号错误',
			'errorMapping.auth.phoneRegistered' => '该手机号已被注册',
			'errorMapping.auth.emailRegistered' => '该邮箱已被注册',
			'errorMapping.auth.sendFailed' => '验证码发送失败',
			'errorMapping.auth.expired' => '验证码已过期',
			'errorMapping.auth.tooFrequent' => '验证码发送太频繁',
			'errorMapping.auth.unsupportedType' => '不支持的验证码类型',
			'errorMapping.auth.wrongPassword' => '密码错误',
			'errorMapping.auth.userNotFound' => '用户不存在',
			'errorMapping.auth.prefsMissing' => '偏好设置参数缺失',
			'errorMapping.auth.invalidTimezone' => '无效的客户端时区',
			'errorMapping.transaction.commentEmpty' => '评论内容不能为空',
			'errorMapping.transaction.invalidParent' => '无效的父评论ID',
			'errorMapping.transaction.saveFailed' => '评论保存失败',
			'errorMapping.transaction.deleteFailed' => '评论删除失败',
			'errorMapping.transaction.notExists' => '交易记录不存在',
			'errorMapping.space.notFound' => '共享空间不存在或无权访问',
			'errorMapping.space.inviteDenied' => '无权邀请成员',
			'errorMapping.space.inviteSelf' => '不能邀请你自己',
			'errorMapping.space.inviteSent' => '邀请已发送',
			'errorMapping.space.alreadyMember' => '该用户已是成员或已被邀请',
			'errorMapping.space.invalidAction' => '无效操作',
			'errorMapping.space.invitationNotFound' => '邀请不存在',
			'errorMapping.space.onlyOwner' => '仅拥有者可执行此操作',
			'errorMapping.space.ownerNotRemovable' => '不能移除空间拥有者',
			'errorMapping.space.memberNotFound' => '成员不存在',
			'errorMapping.space.notMember' => '该用户不是此空间的成员',
			'errorMapping.space.ownerCantLeave' => '拥有者不能直接退出，请先转让所有权',
			'errorMapping.space.invalidCode' => '无效的邀请码',
			'errorMapping.space.codeExpired' => '邀请码已过期或达到上限',
			'errorMapping.space.transactionAlreadyInSpace' => '交易已在此共享空间中',
			'errorMapping.recurring.invalidRule' => '无效的重复规则',
			'errorMapping.recurring.ruleNotFound' => '未找到重复规则',
			'errorMapping.upload.noFile' => '未上传文件',
			'errorMapping.upload.tooLarge' => '文件过大',
			'errorMapping.upload.unsupportedType' => '不支持的文件类型',
			'errorMapping.upload.tooManyFiles' => '文件数量过多',
			'errorMapping.storage.configNotFound' => '存储配置不存在或无权访问',
			'errorMapping.storage.configInUse' => '无法删除：存储配置仍被附件使用',
			'errorMapping.storage.invalidProviderType' => '无效的存储提供商类型',
			'errorMapping.ai.contextLimit' => '上下文长度超出限制',
			'errorMapping.ai.tokenLimit' => 'Token配额不足',
			'errorMapping.ai.emptyMessage' => '用户消息为空',
			'notification.title' => '消息通知',
			'notification.markAllRead' => '全部已读',
			'notification.empty' => '暂无通知消息',
			'notification.loadFailed' => '加载失败',
			'notification.retry' => '重试',
			'notification.justNow' => '刚刚',
			'notification.minutesAgo' => ({required Object minutes}) => '${minutes}分钟前',
			'notification.hoursAgo' => ({required Object hours}) => '${hours}小时前',
			'notification.daysAgo' => ({required Object days}) => '${days}天前',
			'notification.deleted' => '已删除',
			'notification.types.system' => '系统通知',
			'notification.types.spaceInvite' => '空间邀请',
			'notification.types.spaceActivity' => '空间动态',
			'notification.types.billComment' => '账单评论',
			'notification.types.budgetAlert' => '预算提醒',
			'notification.types.transaction' => '交易通知',
			'notification.semantic.memberJoined' => ({required Object name}) => '${name} 加入了你的空间',
			'notification.semantic.memberJoinedDetail' => ({required Object space}) => '新成员加入了「${space}」',
			'notification.semantic.welcome' => ({required Object space}) => '欢迎加入「${space}」',
			'notification.semantic.newTransaction' => ({required Object name}) => '${name} 记录了一笔新账单',
			'notification.semantic.newTransactionDetail' => ({required Object amount, required Object space}) => '${amount}，来自「${space}」',
			'notification.semantic.memberLeft' => ({required Object name}) => '${name} 离开了空间',
			'notification.semantic.recurringPending' => '周期交易待确认',
			'notification.semantic.recurringPendingDetail' => ({required Object description, required Object amount}) => '${description} ${amount}，等待您确认记账',
			_ => null,
		};
	}
}
