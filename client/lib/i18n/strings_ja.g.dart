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
class TranslationsJa extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsJa({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ja,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ja>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsJa _root = this; // ignore: unused_field

	@override
	TranslationsJa $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsJa(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$common$ja common = _Translations$common$ja._(_root);
	@override late final _Translations$genui$ja genui = _Translations$genui$ja._(_root);
	@override late final _Translations$time$ja time = _Translations$time$ja._(_root);
	@override late final _Translations$greeting$ja greeting = _Translations$greeting$ja._(_root);
	@override late final _Translations$navigation$ja navigation = _Translations$navigation$ja._(_root);
	@override late final _Translations$auth$ja auth = _Translations$auth$ja._(_root);
	@override late final _Translations$transaction$ja transaction = _Translations$transaction$ja._(_root);
	@override late final _Translations$home$ja home = _Translations$home$ja._(_root);
	@override late final _Translations$comment$ja comment = _Translations$comment$ja._(_root);
	@override late final _Translations$calendar$ja calendar = _Translations$calendar$ja._(_root);
	@override late final _Translations$category$ja category = _Translations$category$ja._(_root);
	@override late final _Translations$settings$ja settings = _Translations$settings$ja._(_root);
	@override late final _Translations$appearance$ja appearance = _Translations$appearance$ja._(_root);
	@override late final _Translations$speech$ja speech = _Translations$speech$ja._(_root);
	@override late final _Translations$amountTheme$ja amountTheme = _Translations$amountTheme$ja._(_root);
	@override late final _Translations$locale$ja locale = _Translations$locale$ja._(_root);
	@override late final _Translations$budget$ja budget = _Translations$budget$ja._(_root);
	@override late final _Translations$dateRange$ja dateRange = _Translations$dateRange$ja._(_root);
	@override late final _Translations$forecast$ja forecast = _Translations$forecast$ja._(_root);
	@override late final _Translations$chat$ja chat = _Translations$chat$ja._(_root);
	@override late final _Translations$image$ja image = _Translations$image$ja._(_root);
	@override late final _Translations$footprint$ja footprint = _Translations$footprint$ja._(_root);
	@override late final _Translations$media$ja media = _Translations$media$ja._(_root);
	@override late final _Translations$error$ja error = _Translations$error$ja._(_root);
	@override late final _Translations$fontTest$ja fontTest = _Translations$fontTest$ja._(_root);
	@override late final _Translations$wizard$ja wizard = _Translations$wizard$ja._(_root);
	@override late final _Translations$user$ja user = _Translations$user$ja._(_root);
	@override late final _Translations$account$ja account = _Translations$account$ja._(_root);
	@override late final _Translations$financial$ja financial = _Translations$financial$ja._(_root);
	@override late final _Translations$app$ja app = _Translations$app$ja._(_root);
	@override late final _Translations$statistics$ja statistics = _Translations$statistics$ja._(_root);
	@override late final _Translations$currency$ja currency = _Translations$currency$ja._(_root);
	@override late final _Translations$sharedSpace$ja sharedSpace = _Translations$sharedSpace$ja._(_root);
	@override late final _Translations$budgetSuggestion$ja budgetSuggestion = _Translations$budgetSuggestion$ja._(_root);
	@override late final _Translations$server$ja server = _Translations$server$ja._(_root);
	@override late final _Translations$errorMapping$ja errorMapping = _Translations$errorMapping$ja._(_root);
	@override late final _Translations$notification$ja notification = _Translations$notification$ja._(_root);
}

// Path: common
class _Translations$common$ja extends Translations$common$zh {
	_Translations$common$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get loading => '読み込み中...';
	@override String get error => 'エラー';
	@override String get retry => '再試行';
	@override String get cancel => 'キャンセル';
	@override String get confirm => '確認';
	@override String get save => '保存';
	@override String get delete => '削除';
	@override String get edit => '編集';
	@override String get add => '追加';
	@override String get search => '検索';
	@override String get filter => 'フィルター';
	@override String get sort => '並べ替え';
	@override String get refresh => '更新';
	@override String get more => 'もっと見る';
	@override String get less => 'たたむ';
	@override String get all => 'すべて';
	@override String get none => 'なし';
	@override String get ok => 'OK';
	@override String get unknown => '不明';
	@override String get noData => 'データなし';
	@override String get loadMore => 'さらに読み込む';
	@override String get noMore => 'これ以上ありません';
	@override String get loadFailed => '読み込み失敗';
	@override String get history => '履歴';
	@override String get reset => 'リセット';
	@override String get cancelled => 'キャンセル済み';
	@override String get saving => '保存中...';
	@override String get saveFailed => '保存に失敗しました';
}

// Path: genui
class _Translations$genui$ja extends Translations$genui$zh {
	_Translations$genui$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get errorBusy => '申し訳ございません。サービスが一時的に混雑しています。後ほどお試しください';
	@override String get errorTimeout => 'リクエストがタイムアウトしました。ネットワークを確認して再試行してください';
	@override String get errorNetwork => 'ネットワーク接続に問題があります。確認して再試行してください';
	@override String get errorSessionExpired => 'セッションが期限切れです。再度ログインしてください';
	@override String get errorGeneric => '問題が発生しました。後ほどお試しください';
}

// Path: time
class _Translations$time$ja extends Translations$time$zh {
	_Translations$time$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get today => '今日';
	@override String get yesterday => '昨日';
	@override String get dayBeforeYesterday => '一昨日';
	@override String get thisWeek => '今週';
	@override String get thisMonth => '今月';
	@override String get thisYear => '今年';
	@override String get selectDate => '日付を選択';
	@override String get selectTime => '時間を選択';
	@override String get justNow => 'たった今';
	@override String minutesAgo({required Object count}) => '${count}分前';
	@override String hoursAgo({required Object count}) => '${count}時間前';
	@override String daysAgo({required Object count}) => '${count}日前';
	@override String weeksAgo({required Object count}) => '${count}週間前';
	@override String monthsAgo({required Object count}) => '${count}ヶ月前';
	@override String yearsAgo({required Object count}) => '${count}年前';
}

// Path: greeting
class _Translations$greeting$ja extends Translations$greeting$zh {
	_Translations$greeting$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get morning => 'おはようございます';
	@override String get afternoon => 'こんにちは';
	@override String get evening => 'こんばんは';
}

// Path: navigation
class _Translations$navigation$ja extends Translations$navigation$zh {
	_Translations$navigation$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get home => 'ホーム';
	@override String get budget => '予算';
	@override String get chat => 'AI チャット';
	@override String get statistics => '統計';
	@override String get forecast => '予測';
	@override String get footprint => 'フットプリント';
	@override String get profile => 'マイページ';
}

// Path: auth
class _Translations$auth$ja extends Translations$auth$zh {
	_Translations$auth$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get login => 'ログイン';
	@override String get loggingIn => 'ログイン中...';
	@override String get logout => 'ログアウト';
	@override String get register => '新規登録';
	@override String get registering => '登録中...';
	@override String get welcomeBack => 'おかえりなさい';
	@override String get loginSuccess => 'おかえりなさい！';
	@override String get loginFailed => 'ログイン失敗';
	@override String get pleaseTryAgain => '後ほど再試行してください。';
	@override String get loginSubtitle => 'AI家計簿アシスタントを利用するにはログインしてください';
	@override String get noAccount => 'アカウントをお持ちでないですか？ 登録';
	@override String get createAccount => 'アカウントを作成';
	@override String get setPassword => 'パスワード設定';
	@override String get setAccountPassword => 'アカウントのパスワードを設定してください';
	@override String get completeRegistration => '登録完了';
	@override String get registrationSuccess => '登録が完了しました！';
	@override String get registrationFailed => '登録失敗';
	@override late final _Translations$auth$email$ja email = _Translations$auth$email$ja._(_root);
	@override late final _Translations$auth$password$ja password = _Translations$auth$password$ja._(_root);
	@override late final _Translations$auth$verificationCode$ja verificationCode = _Translations$auth$verificationCode$ja._(_root);
	@override String get logoutSuccess => 'Logged out successfully';
	@override String get confirmLogoutTitle => 'Confirm Logout';
	@override String get confirmLogoutContent => 'Are you sure you want to log out?';
	@override String get logoutFailedTitle => 'ログアウト失敗';
}

// Path: transaction
class _Translations$transaction$ja extends Translations$transaction$zh {
	_Translations$transaction$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get expense => '支出';
	@override String get income => '収入';
	@override String get transfer => '振替';
	@override String get amount => '金額';
	@override String get category => 'カテゴリー';
	@override String get description => 'メモ';
	@override String get tags => 'タグ';
	@override String get saveTransaction => '記録を保存';
	@override String get pleaseEnterAmount => '金額を入力してください';
	@override String get pleaseSelectCategory => 'カテゴリーを選択してください';
	@override String get saveFailed => '保存に失敗しました';
	@override String get descriptionHint => '取引の詳細を記録...';
	@override String get addCustomTag => 'カスタムタグを追加';
	@override String get commonTags => 'よく使うタグ';
	@override String maxTagsHint({required Object maxTags}) => 'タグは最大 ${maxTags} 個までです';
	@override String get noTransactionsFound => '取引履歴が見つかりません';
	@override String get tryAdjustingSearch => '検索条件を調整するか、新しい取引を作成してください';
	@override String get noDescription => 'メモなし';
	@override String get payment => '支払い';
	@override String get account => '口座';
	@override String get time => '時間';
	@override String get location => '場所';
	@override String get transactionDetail => '取引詳細';
	@override String get favorite => 'お気に入り';
	@override String get confirmDelete => '削除の確認';
	@override String get deleteTransactionConfirm => 'この取引記録を削除してもよろしいですか？この操作は取り消せません。';
	@override String get noActions => '利用可能なアクションはありません';
	@override String get deleted => '削除済み';
	@override String get deleteFailed => '削除に失敗しました。後ほど再試行してください。';
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
	@override String get notFoundTitle => '取引が削除されました';
	@override String get notFoundBody => 'この取引は作成者または管理者によって削除されたため、詳細を表示できません。';
	@override String get backToPrevious => '戻る';
}

// Path: home
class _Translations$home$ja extends Translations$home$zh {
	_Translations$home$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get totalExpense => '総支出額';
	@override String get todayExpense => '今日の支出';
	@override String get monthExpense => '今月の支出';
	@override String yearProgress({required Object year}) => '${year}年の進捗';
	@override String yearRemainingInfo({required Object days, required Object percent}) => '残り ${days} 日 · ${percent}%';
	@override String get amountHidden => '••••••••';
	@override String get loadFailed => '読み込み失敗';
	@override String get noTransactions => '取引履歴なし';
	@override String get tryRefresh => '更新してください';
	@override String get noMoreData => 'これ以上のデータはありません';
	@override String get userNotLoggedIn => 'ユーザーがログインしていないため、データを読み込めません';
}

// Path: comment
class _Translations$comment$ja extends Translations$comment$zh {
	_Translations$comment$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get error => 'エラー';
	@override String get commentFailed => 'コメントに失敗しました';
	@override String replyToPrefix({required Object name}) => '@${name} さんに返信:';
	@override String get reply => '返信';
	@override String get contentRequired => 'コメント内容を入力してください';
	@override String get copyContent => '内容をコピー';
	@override String get contentCopied => 'コメント内容をコピーしました';
	@override String get collapseReplies => '返信を折りたたむ';
	@override String expandMoreReplies({required Object count}) => 'さらに返信 ${count} 件を表示';
	@override String get recordedBy => '記録者';
	@override String get addNote => '備考を追加...';
	@override String get confirmDeleteTitle => '削除の確認';
	@override String get confirmDeleteContent => 'このコメントを削除してもよろしいですか？この操作は取り消せません。';
	@override String get success => '成功';
	@override String get commentDeleted => 'コメントを削除しました';
	@override String get deleteFailed => '削除失敗';
	@override String get deleteComment => 'コメント削除';
	@override String get hint => 'ヒント';
	@override String get noActions => '利用可能なアクションはありません';
	@override String get note => '備考';
	@override String get noNote => '備考なし';
	@override String get loadFailed => '備考の読み込みに失敗しました';
	@override String userToast({required Object username}) => 'ユーザー @${username}';
}

// Path: calendar
class _Translations$calendar$ja extends Translations$calendar$zh {
	_Translations$calendar$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '家計カレンダー';
	@override late final _Translations$calendar$weekdays$ja weekdays = _Translations$calendar$weekdays$ja._(_root);
	@override String get loadFailed => 'カレンダーデータの読み込みに失敗しました';
	@override String thisMonth({required Object amount}) => '今月: ${amount}';
	@override String get counting => '集計中...';
	@override String get unableToCount => '集計不可';
	@override String get trend => '傾向: ';
	@override String get noTransactionsTitle => 'この日の取引はありません';
	@override String get loadTransactionFailed => '取引の読み込みに失敗しました';
}

// Path: category
class _Translations$category$ja extends Translations$category$zh {
	_Translations$category$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get dailyConsumption => '生活費';
	@override String get transportation => '交通費';
	@override String get healthcare => '医療・健康';
	@override String get housing => '住居費';
	@override String get education => '教育・学習';
	@override String get incomeCategory => '収入';
	@override String get socialGifts => '交際・贈り物';
	@override String get moneyTransfer => '資金移動';
	@override String get other => 'その他';
	@override String get foodDining => '食費・外食';
	@override String get shoppingRetail => '買い物';
	@override String get housingUtilities => '住居・光熱費';
	@override String get personalCare => '美容・ケア';
	@override String get entertainment => '娯楽・レジャー';
	@override String get medicalHealth => '医療費';
	@override String get insurance => '保険';
	@override String get socialGifting => '冠婚葬祭';
	@override String get financialTax => '金融・税金';
	@override String get others => 'その他支出';
	@override String get salaryWage => '給与・報酬';
	@override String get businessTrade => '事業収入';
	@override String get investmentReturns => '投資収益';
	@override String get giftBonus => 'お祝い・ボーナス';
	@override String get refundRebate => '還付・ポイント';
	@override String get generalTransfer => '振替';
	@override String get debtRepayment => '債務返済';
}

// Path: settings
class _Translations$settings$ja extends Translations$settings$zh {
	_Translations$settings$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '設定';
	@override String get editProfile => 'プロフィールを編集';
	@override String get saveProfile => 'プロフィールを保存';
	@override String get profileHelpHint => 'プロフィールは共有スペースであなたを識別するのに役立ちます。';
	@override String get enterUsernameHint => 'ユーザー名を入力してください';
	@override String get groupPreferences => '環境設定と記録';
	@override String get groupServices => '共有とサービス';
	@override String get groupSystem => 'システムと外観';
	@override String get language => '言語';
	@override String get languageSettings => '言語設定';
	@override String get selectLanguage => '言語を選択';
	@override String get languageChanged => '言語を変更しました';
	@override String get restartToApply => '変更を適用するにはアプリを再起動してください';
	@override String get theme => 'テーマ';
	@override String get darkMode => 'ダークモード';
	@override String get lightMode => 'ライトモード';
	@override String get systemMode => 'システムに従う';
	@override String get developerOptions => '開発者オプション';
	@override String get authDebug => '認証デバッグ';
	@override String get authDebugSubtitle => '認証ステータスとデバッグ情報を確認';
	@override String get fontTest => 'フォントテスト';
	@override String get fontTestSubtitle => 'フォントの表示効果をテスト';
	@override String get helpAndFeedback => 'ヘルプとフィードバック';
	@override String get helpAndFeedbackSubtitle => 'ヘルプの参照またはフィードバック送信';
	@override String get aboutApp => 'アプリについて';
	@override String get aboutAppSubtitle => 'バージョン情報とアップデート確認';
	@override String get checkUpdate => 'アップデートを確認';
	@override String get checkingUpdate => 'アップデートを確認中...';
	@override String get latestVersionToast => '最新バージョンを使用中です';
	@override String get newVersionTitle => '新しいバージョンがあります';
	@override String currentVersion({required Object version}) => '現在のバージョン: v${version}';
	@override String get updateNow => '今すぐアップデート';
	@override String get updateLater => '後で';
	@override String get fetchUpdateFailed => 'アップデートの確認に失敗しました';
	@override String currencyChangedRefreshHint({required Object currency}) => '${currency} に切り替えました。主要通貨および既定の通貨として設定されました';
	@override String get sharedSpace => '共有スペース';
	@override String get speechRecognition => '音声認識';
	@override String get speechRecognitionSubtitle => '音声入力パラメータを設定';
	@override String get amountDisplayStyle => '金額表示スタイル';
	@override String get currency => '表示通貨';
	@override String get appearance => '外観設定';
	@override String get appearanceSubtitle => 'テーマモードと配色';
	@override String get speechTest => '音声テスト';
	@override String get speechTestSubtitle => 'WebSocket音声接続をテスト';
	@override String get userTypeRegular => '一般ユーザー';
	@override String get selectAmountStyle => '金額表示スタイルを選択';
	@override String get currencyDescription => '主要通貨を選択してください。今後の取引はデフォルトでこの通貨になり、統計や集計もこの通貨で表示されます。過去の取引の元金額には影響しません。';
	@override String get amountStyleNotice => 'Note: Amount styles are primarily applied to \'Transactions\' and \'Trends\'. To maintain visual clarity, \'Account Balances\' and \'Asset Summaries\' will remain in neutral colors.';
	@override String get editUsername => 'Edit Username';
	@override String get enterUsername => 'Enter username';
	@override String get usernameRequired => 'Username is required';
	@override String get usernameUpdated => 'Username updated';
	@override String get avatarUpdated => 'Avatar updated';
	@override String get appearanceUpdated => '外观设置已更新';
}

// Path: appearance
class _Translations$appearance$ja extends Translations$appearance$zh {
	_Translations$appearance$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '外観設定';
	@override String get themeMode => 'テーマモード';
	@override String get light => 'ライト';
	@override String get dark => 'ダーク';
	@override String get system => 'システム';
	@override String get colorScheme => '配色';
	@override late final _Translations$appearance$palettes$ja palettes = _Translations$appearance$palettes$ja._(_root);
}

// Path: speech
class _Translations$speech$ja extends Translations$speech$zh {
	_Translations$speech$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '音声認識設定';
	@override String get service => '音声認識サービス';
	@override String get systemVoice => 'システム音声';
	@override String get systemVoiceSubtitle => 'スマホ内蔵の音声認識サービス（推奨）';
	@override String get selfHostedASR => '自作 ASR サービス';
	@override String get selfHostedASRSubtitle => 'WebSocket経由で自作ASRサーバーに接続';
	@override String get serverConfig => 'サーバー設定';
	@override String get serverAddress => 'サーバーアドレス';
	@override String get port => 'ポート';
	@override String get path => 'パス';
	@override String get saveConfig => '設定を保存';
	@override String get info => '情報';
	@override String get infoContent => '• システム音声：内蔵サービスを使用。設定不要で高速です。\n• 自作 ASR：カスタムモデルやオフライン環境用。\n\n変更は次回の音声入力から有効になります。';
	@override String get enterAddress => 'サーバーアドレスを入力してください';
	@override String get enterValidPort => '有効なポート番号(1-65535)を入力してください';
	@override String get configSaved => '設定を保存しました';
	@override String get configSaveFailed => '設定の保存に失敗しました';
	@override String get systemVoiceRestrictedTitle => 'システム音声が利用できません';
	@override String get systemVoiceRestrictedContent => '端末の音声認識サービスが無効または利用できません。設定を確認するかWebSocket自作ASRを設定してください。';
	@override String get dictationDisabledTitle => '音声入力（音声入力/音声聞き取り）が無効です';
	@override String get dictationDisabledContent => 'システム音声入力サービスが有効になっていません。iOS端末の場合、【設定 -> 一般 -> キーボード】から【音声入力を有効にする】をオンにしてください。';
	@override String get permissionDeniedTitle => '音声権限が必要です';
	@override String get permissionDeniedContent => 'この機能を使用するにはマイクと音声認識の権限が必要です。システム設定で権限を許可してください。';
	@override String get goToSettings => '設定へ';
	@override String get systemVoiceStatusAvailable => 'システム音声認識利用可能';
	@override String get systemVoiceStatusRestricted => 'システム音声制限あり (自作 ASR 推奨)';
	@override String get serviceNotConfigured => '音声サービスが設定されていません。音声設定でサーバーアドレスを設定してください。';
	@override String get connectionFailedTitle => '音声サービス接続失敗';
	@override String get connectionFailed => 'WebSocket音声認識サービスに接続できません。サーバーアドレス、ポート、またはネットワーク接続を確認してください。';
	@override String get noSpeechRecognized => '音声入力が検出されませんでした。もう一度お試しください。';
}

// Path: amountTheme
class _Translations$amountTheme$ja extends Translations$amountTheme$zh {
	_Translations$amountTheme$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get chinaMarket => '中国市場慣習';
	@override String get chinaMarketDesc => '赤上昇/緑下落（推奨）';
	@override String get international => '国際標準';
	@override String get internationalDesc => '緑上昇/赤下落';
	@override String get minimalist => 'ミニマリスト';
	@override String get minimalistDesc => 'モノクロ表示、+/- 記号のみで区別';
	@override String get colorBlind => '色覚サポート';
	@override String get colorBlindDesc => '青・オレンジ配色';
}

// Path: locale
class _Translations$locale$ja extends Translations$locale$zh {
	_Translations$locale$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get chinese => '簡体字中国語';
	@override String get english => 'English';
	@override String get japanese => '日本語';
	@override String get korean => '한국어';
	@override String get traditionalChinese => '繁体字中国語';
}

// Path: budget
class _Translations$budget$ja extends Translations$budget$zh {
	_Translations$budget$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '予算管理';
	@override String get detail => '予算詳細';
	@override String get info => '予算情報';
	@override String get totalBudget => '総予算';
	@override String get categoryBudget => 'カテゴリー別予算';
	@override String get monthlySummary => '今月の予算サマリー';
	@override String get used => '使用済み';
	@override String get remaining => '残り';
	@override String get overspent => '予算超過';
	@override String get budget => '予算';
	@override String get loadFailed => '読み込み失敗';
	@override String get noBudget => '予算未設定';
	@override String get createHint => '下のボタンをタップして予算を設定しましょう';
	@override String get paused => '一時停止中';
	@override String get pause => '停止';
	@override String get resume => '再開';
	@override String get budgetPaused => '予算管理を停止しました';
	@override String get budgetResumed => '予算管理を再開しました';
	@override String get operationFailed => '操作に失敗しました';
	@override String get deleteBudget => '予算を削除';
	@override String get deleteConfirm => 'この予算を削除してもよろしいですか？取り消せません。';
	@override String get type => 'タイプ';
	@override String get category => 'カテゴリー';
	@override String get period => '周期';
	@override String get rollover => '予算繰越';
	@override String get rolloverBalance => '繰越残高';
	@override String get enabled => '有効';
	@override String get disabled => '無効';
	@override String get statusNormal => '予算内';
	@override String get statusWarning => '上限接近';
	@override String get statusOverspent => '超過';
	@override String get statusAchieved => '目標達成';
	@override String tipNormal({required Object amount}) => '残り ${amount} 利用可能';
	@override String tipWarning({required Object amount}) => '残り ${amount} です。ご注意ください';
	@override String tipOverspent({required Object amount}) => '${amount} 超過しています';
	@override String get tipAchieved => '貯金目標達成おめでとうございます！';
	@override String remainingAmount({required Object amount}) => '残り ${amount}';
	@override String overspentAmount({required Object amount}) => '超過 ${amount}';
	@override String budgetAmount({required Object amount}) => '予算 ${amount}';
	@override String get active => '有効';
	@override String get all => 'すべて';
	@override String get notFound => '予算が存在しないか削除されました';
	@override String get setup => '予算設定';
	@override String get settings => '予算設定';
	@override String get setAmount => '予算額を設定';
	@override String get setAmountDesc => '各カテゴリーの予算額を設定';
	@override String get monthly => '月次予算';
	@override String get monthlyDesc => '月単位で支出を管理します（推奨）';
	@override String get weekly => '週次予算';
	@override String get weeklyDesc => '週単位で細かく管理します';
	@override String get yearly => '年次予算';
	@override String get yearlyDesc => '長期的な計画や大きな支出用';
	@override String get editBudget => '予算を編集';
	@override String get editBudgetDesc => '予算額やカテゴリーを変更';
	@override String get reminderSettings => '通知設定';
	@override String get reminderSettingsDesc => '予算通知やリマインダーを設定';
	@override String get report => '予算レポート';
	@override String get reportDesc => '詳細な予算分析レポートを表示';
	@override String get welcome => '予算機能へようこそ！';
	@override String get createNewPlan => '新しい予算プランを作成';
	@override String get welcomeDesc => '予算を設定することで、支出をコントロールし財務目標を達成できます。';
	@override String get createDesc => 'カテゴリー別の予算上限を設定して、家計管理をサポートします。';
	@override String get newBudget => '新規予算';
	@override String get budgetAmountLabel => '予算額';
	@override String get currency => '通貨';
	@override String get periodSettings => '期間設定';
	@override String get autoGenerateTransactions => '有効にするとルールに従い自動記帳します';
	@override String get cycle => 'サイクル';
	@override String get budgetCategory => '予算カテゴリー';
	@override String get advancedOptions => '詳細オプション';
	@override String get periodType => '期間タイプ';
	@override String get anchorDay => '開始日';
	@override String get selectPeriodType => '期間タイプを選択';
	@override String get selectAnchorDay => '開始日を選択';
	@override String get rolloverDescription => '未使用分を翌期に繰り越す';
	@override String get createBudget => '予算を作成';
	@override String get save => '保存';
	@override String get pleaseEnterAmount => '予算額を入力してください';
	@override String get invalidAmount => '有効な金額を入力してください';
	@override String get updateSuccess => '予算を更新しました';
	@override String get createSuccess => '予算を作成しました';
	@override String get deleteSuccess => '予算を削除しました';
	@override String get deleteFailed => '削除に失敗しました';
	@override String everyMonthDay({required Object day}) => '毎月 ${day} 日';
	@override String get periodWeekly => '毎週';
	@override String get periodBiweekly => '2週間ごと';
	@override String get periodMonthly => '毎月';
	@override String get periodYearly => '毎年';
	@override String get statusActive => '進行中';
	@override String get statusArchived => 'アーカイブ済み';
	@override String get periodStatusOnTrack => '順調';
	@override String get periodStatusWarning => '警告';
	@override String get periodStatusExceeded => '超過';
	@override String get periodStatusAchieved => '達成';
	@override String usedPercent({required Object percent}) => '${percent}% 使用済み';
	@override String dayOfMonth({required Object day}) => '${day} 日';
	@override String get tenThousandSuffix => '万';
	@override String get settingsLoadFailed => '設定の読み込みに失敗しました';
	@override String get settingsSaveSuccess => '設定を保存しました';
	@override String get settingsSaveFailed => '保存に失敗しました';
	@override String get settingsSave => '設定を保存';
	@override String get settingsWarningThreshold => '警告閾値';
	@override String get settingsWarningDesc => '使用率がこの割合に達すると警告状態を表示';
	@override String get settingsAlertThreshold => '超過閾値';
	@override String get settingsAlertDesc => '使用率がこの割合に達すると超過状態を表示';
	@override String get settingsThresholdOrder => '警告閾値は超過閾値を超えられません';
}

// Path: dateRange
class _Translations$dateRange$ja extends Translations$dateRange$zh {
	_Translations$dateRange$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get custom => 'カスタム';
	@override String get pickerTitle => '期間を選択';
	@override String get startDate => '開始日';
	@override String get endDate => '終了日';
	@override String get hint => '日付範囲を選択してください';
}

// Path: forecast
class _Translations$forecast$ja extends Translations$forecast$zh {
	_Translations$forecast$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '予測';
	@override String get subtitle => 'データに基づき将来のキャッシュフローを予測します';
	@override String get financialNavigator => 'こんにちは、あなたの財務ナビゲーターです';
	@override String get financialMapSubtitle => '3ステップで、あなたの将来の財務マップを一緒に作成しましょう';
	@override String get predictCashFlow => '将来のキャッシュフローを予測';
	@override String get predictCashFlowDesc => '日々の財務状況を可視化';
	@override String get aiSmartSuggestions => 'AIスマートアドバイス';
	@override String get aiSmartSuggestionsDesc => 'パーソナライズされた財務ガイダンス';
	@override String get riskWarning => 'リスク警告';
	@override String get riskWarningDesc => '潜在的なリスクを事前に察知';
	@override String get analyzing => '財務データを分析し、今後30日間の予測を生成しています';
	@override String get analyzePattern => '収支パターンの分析';
	@override String get calculateTrend => 'トレンドの計算';
	@override String get generateWarning => 'リスク警告の生成';
	@override String get loadingForecast => '予測を読み込み中...';
	@override String get todayLabel => '今日';
	@override String get tomorrowLabel => '明日';
	@override String get balanceLabel => '残高';
	@override String get noSpecialEvents => '特別なイベントはありません';
	@override String get financialSafetyLine => 'セーフティライン';
	@override String get currentSetting => '現在の設定';
	@override String get dailySpendingEstimate => '1日の支出見積もり';
	@override String get adjustDailySpendingAmount => '予測金額を調整';
	@override String get tellMeYourSafetyLine => 'あなたの「安心できる最低残高」はいくらですか？';
	@override String get safetyLineDescription => '口座に維持したい最低額です。この額に近づくと警告します。';
	@override String get dailySpendingQuestion => '1日の生活費はいくらくらいですか？';
	@override String get dailySpendingDescription => '食費、交通費、買い物など。今後の記録から予測精度を向上させます。';
	@override String get perDay => '1日あたり';
	@override String get referenceStandard => '参考基準';
	@override String get frugalType => '節約型';
	@override String get comfortableType => '標準型';
	@override String get relaxedType => 'ゆとり型';
	@override String get frugalAmount => '1,000円-2,000円/日';
	@override String get comfortableAmount => '2,000円-4,000円/日';
	@override String get relaxedAmount => '4,000円-6,000円/日';
	@override late final _Translations$forecast$recurringTransaction$ja recurringTransaction = _Translations$forecast$recurringTransaction$ja._(_root);
}

// Path: chat
class _Translations$chat$ja extends Translations$chat$zh {
	_Translations$chat$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get newChat => '新しいチャット';
	@override String get noMessages => 'メッセージがありません。';
	@override String get loadingFailed => '読み込み失敗';
	@override String get inputMessage => 'メッセージを入力...';
	@override String get listening => '聞き取り中...';
	@override String get aiThinking => '処理中...';
	@override String get stoppedResponse => 'この返信を停止しました';
	@override String get errorRecover => '申し訳ありません、問題が発生しました。もう一度お試しください 🙏';
	@override String get contentCopied => '内容をコピーしました';
	@override String get jsonCopied => 'JSONデータをコピーしました';
	@override String get noContentToCopy => 'コピーする内容がありません';
	@override late final _Translations$chat$tools$ja tools = _Translations$chat$tools$ja._(_root);
	@override String get speechNotRecognized => '音声を認識できませんでした';
	@override String get currentExpense => '今回の支出';
	@override String get loadingComponent => 'コンポーネントを読み込み中...';
	@override String get noHistory => '履歴がありません';
	@override String get startNewChat => '新しい会話を始めましょう！';
	@override String get searchHint => 'チャットを検索';
	@override String get library => 'ライブラリ';
	@override String get viewProfile => 'プロフィールを表示';
	@override String get noRelatedFound => '関連する会話が見つかりません';
	@override String get tryOtherKeywords => '他のキーワードで検索してください';
	@override String get searchFailed => '検索失敗';
	@override String updatedAt({required Object time}) => '更新日時: ${time}';
	@override String createdAt({required Object time}) => '作成日時: ${time}';
	@override String get deleteConversation => 'チャットを削除';
	@override String get deleteConversationConfirm => 'このチャットを削除してもよろしいですか？この操作は取り消せません。';
	@override String get conversationDeleted => 'チャットを削除しました';
	@override String get deleteConversationFailed => 'チャットの削除に失敗しました';
	@override late final _Translations$chat$transferWizard$ja transferWizard = _Translations$chat$transferWizard$ja._(_root);
	@override late final _Translations$chat$genui$ja genui = _Translations$chat$genui$ja._(_root);
	@override late final _Translations$chat$welcome$ja welcome = _Translations$chat$welcome$ja._(_root);
	@override String get shareComingSoon => '共有機能は近日公開予定です...';
	@override String get invalidAttachmentLink => '無効な添付ファイルリンク';
	@override String get unableToOpenAttachmentLink => '添付ファイルリンクを開けません';
	@override String aiCommunicationError({required Object error}) => '申し訳ありません、AIアシスタントとの通信エラーが発生しました：${error}';
	@override String get uploadStillInProgress => '添付ファイルはまだアップロード中です。後でもう一度お試しください';
	@override String get sendFailed => 'メッセージの送信に失敗しました。後でもう一度お試しください';
	@override String attachmentUploadFailed({required Object files}) => '添付ファイルのアップロードに失敗しました: ${files}';
	@override String get fileUploadFailed => 'ファイルのアップロードに失敗しました。後でもう一度お試しください';
}

// Path: image
class _Translations$image$ja extends Translations$image$zh {
	_Translations$image$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get deleteTitle => '画像を削除';
	@override String get deleteConfirm => 'この画像を削除してもよろしいですか？この操作は元に戻せません。';
}

// Path: footprint
class _Translations$footprint$ja extends Translations$footprint$zh {
	_Translations$footprint$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get searchIn => '検索';
	@override String get searchInAllRecords => 'すべての記録から検索';
}

// Path: media
class _Translations$media$ja extends Translations$media$zh {
	_Translations$media$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get selectPhotos => '写真を選択';
	@override String get addFiles => 'ファイルを追加';
	@override String get takePhoto => '写真を撮る';
	@override String get camera => 'カメラ';
	@override String get photos => '写真';
	@override String get files => 'ファイル';
	@override String get showAll => 'すべて表示';
	@override String get allPhotos => 'すべての写真';
	@override String get takingPhoto => '撮影中...';
	@override String get photoTaken => '写真を保存しました';
	@override String get cameraPermissionRequired => 'カメラの権限が必要です';
	@override String get fileSizeExceeded => 'ファイルサイズが10MBを超えています';
	@override String get unsupportedFormat => 'サポートされていない形式です';
	@override String get permissionDenied => 'アルバムへのアクセス権限が必要です';
	@override String get storageInsufficient => 'ストレージ容量が不足しています';
	@override String get networkError => 'ネットワークエラー';
	@override String get unknownUploadError => '不明なアップロードエラー';
}

// Path: error
class _Translations$error$ja extends Translations$error$zh {
	_Translations$error$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get permissionRequired => '権限が必要です';
	@override String get permissionInstructions => '設定から権限を許可してください。';
	@override String get openSettings => '設定を開く';
	@override String get fileTooLarge => 'ファイルが大きすぎます';
	@override String get fileSizeHint => '10MB以下のファイルを選択してください。';
	@override String get supportedFormatsHint => '対応形式：画像、PDF、ドキュメント、音声など。';
	@override String get storageCleanupHint => '空き容量を確保して再試行してください。';
	@override String get networkErrorHint => '接続を確認して再試行してください。';
	@override String get platformNotSupported => 'サポートされていないプラットフォーム';
	@override String get fileReadError => '読み込み失敗';
	@override String get fileReadErrorHint => 'ファイルが破損している可能性があります。';
	@override String get validationError => '検証エラー';
	@override String get unknownError => '不明なエラー';
	@override String get unknownErrorHint => '予期せぬエラーが発生しました。';
	@override String get registrationMissingInfo => '登録フローエラー、必要な情報がありません。';
	@override String get accountInfoMissing => '口座情報がありません';
	@override String get sharedSpaceInfoMissing => '共有スペース情報がありません';
	@override String get settingsSteps => '設定手順：';
	@override String get suggestions => '提案：';
	@override String get fileNotFound => 'ファイルが見つかりません';
	@override String get fileNotFoundHint => 'ファイルの存在を確認するか、別のファイルを選択してください。';
	@override String get selectAgain => '再選択';
	@override String get thumbnailGenerationFailed => 'サムネイル生成に失敗しました';
	@override String get thumbnailGenerationHint => 'サムネイルの生成に失敗しましたが、ファイルは選択済みで引き続き使用できます。';
	@override String get help => 'ヘルプ：';
	@override late final _Translations$error$genui$ja genui = _Translations$error$genui$ja._(_root);
}

// Path: fontTest
class _Translations$fontTest$ja extends Translations$fontTest$zh {
	_Translations$fontTest$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get page => 'テストページ';
	@override String get displayTest => '表示テスト';
	@override String get chineseTextTest => '中国語テスト';
	@override String get englishTextTest => '英語テスト';
	@override String get sample1 => 'これはテスト用のテキストです。';
	@override String get sample2 => '支出分析：ショッピングが最多';
	@override String get sample3 => 'AIアシスタントによる財務分析';
	@override String get sample4 => 'グラフで消費トレンドを確認';
	@override String get sample5 => '各種決済サービスに対応';
}

// Path: wizard
class _Translations$wizard$ja extends Translations$wizard$zh {
	_Translations$wizard$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get nextStep => '次へ';
	@override String get previousStep => '前へ';
	@override String get completeMapping => 'マップ作成完了';
}

// Path: user
class _Translations$user$ja extends Translations$user$zh {
	_Translations$user$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get username => 'ユーザー名';
	@override String get defaultEmail => 'user@example.com';
}

// Path: account
class _Translations$account$ja extends Translations$account$zh {
	_Translations$account$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get editTitle => '口座を編集';
	@override String get addTitle => '新しい口座';
	@override String get selectTypeTitle => '口座タイプを選択';
	@override String get nameLabel => '口座名';
	@override String get amountLabel => '現在の残高';
	@override String get currencyLabel => '通貨';
	@override String get hiddenLabel => '非表示';
	@override String get hiddenDesc => 'リストに表示しない';
	@override String get includeInNetWorthLabel => '資産に含める';
	@override String get includeInNetWorthDesc => '純資産の統計に使用';
	@override String get nameHint => '例：給与振込口座';
	@override String get nameRequired => '口座名を入力してください';
	@override String get nameTooShort => '口座名は2文字以上で入力してください';
	@override String get amountRequired => '現在の残高を入力してください';
	@override String get invalidAmount => '有効な金額を入力してください';
	@override String get negativeBalance => '残高はマイナスにできません';
	@override String get amountTooLarge => '残高は 999,999,999.99 を超えられません';
	@override String get amountHint => '0.00';
	@override String get deleteAccount => '口座を削除';
	@override String get deleteConfirm => 'この口座を削除しますか？取り消せません。';
	@override String get save => '変更を保存';
	@override String get assetsCategory => '資産';
	@override String get liabilitiesCategory => '負債/クレジット';
	@override String get cash => '現金・財布';
	@override String get deposit => '銀行預金';
	@override String get creditCard => 'クレジットカード';
	@override String get investment => '投資・資産運用';
	@override String get eWallet => '電子マネー';
	@override String get loan => 'ローン';
	@override String get receivable => '売掛金・貸付';
	@override String get payable => '買掛金・借入';
	@override String get other => 'その他';
	@override late final _Translations$account$types$ja types = _Translations$account$types$ja._(_root);
}

// Path: financial
class _Translations$financial$ja extends Translations$financial$zh {
	_Translations$financial$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '財務';
	@override String get management => '財務管理';
	@override String get netWorth => '純資産';
	@override String get assets => '総資産';
	@override String get liabilities => '総負債';
	@override String get noAccounts => '口座なし';
	@override String get addFirstAccount => 'ボタンを押して口座を追加してください';
	@override String get assetAccounts => '資産口座';
	@override String get liabilityAccounts => '負債口座';
	@override String get selectCurrency => '通貨を選択';
	@override String get cancel => 'キャンセル';
	@override String get confirm => '確定';
	@override String get settings => '財務設定';
	@override String get budgetManagement => '予算管理';
	@override String get recurringTransactions => '繰り返し取引';
	@override String get safetyThreshold => 'セーフティライン';
	@override String get dailyBurnRate => '1日の支出';
	@override String get financialAssistant => '財務アシスタント';
	@override String get manageFinancialSettings => '財務設定を管理';
	@override String get safetyThresholdSettings => 'セーフティライン設定';
	@override String get setSafetyThreshold => 'セーフティラインの閾値を設定';
	@override String get safetyThresholdSaved => 'セーフティラインを保存しました';
	@override String get dailyBurnRateSettings => '支出見積もり';
	@override String get setDailyBurnRate => '1日の支出見積もりを設定';
	@override String get dailyBurnRateSaved => '支出見積もりを保存しました';
	@override String get dayUnit => '日';
	@override String get saveFailed => '保存に失敗しました';
	@override String get deleteFailed => '削除に失敗しました。しばらくしてから再試行してください';
	@override String missingExchangeRates({required Object currencies}) => '一部の通貨の為替レートが取得できないため、該当口座は合計に含まれていません：${currencies}';
	@override String get cashPocketTitle => 'マイ現金口座';
	@override String sourcesCount({required Object count}) => '${count} 口座';
	@override String lastUpdatedAt({required Object time}) => '最終更新：${time}';
	@override String get neverUpdated => '未更新';
	@override String get updateNow => '今すぐ更新';
}

// Path: app
class _Translations$app$ja extends Translations$app$zh {
	_Translations$app$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get splashTitle => 'スマートに、豊かに。';
	@override String get splashSubtitle => 'インテリジェント財務アシスタント';
	@override String get fatalInitTitle => 'Finvo の起動に失敗しました';
	@override String fatalInitMessage({required Object error}) => '初期化エラー：${error}';
}

// Path: statistics
class _Translations$statistics$ja extends Translations$statistics$zh {
	_Translations$statistics$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '統計分析';
	@override String get analyze => '分析';
	@override String get exportInProgress => 'エクスポート機能は開発中です...';
	@override String get ranking => '高額支出ランキング';
	@override String get noData => 'データなし';
	@override late final _Translations$statistics$overview$ja overview = _Translations$statistics$overview$ja._(_root);
	@override late final _Translations$statistics$trend$ja trend = _Translations$statistics$trend$ja._(_root);
	@override late final _Translations$statistics$analysis$ja analysis = _Translations$statistics$analysis$ja._(_root);
	@override late final _Translations$statistics$filter$ja filter = _Translations$statistics$filter$ja._(_root);
	@override late final _Translations$statistics$sort$ja sort = _Translations$statistics$sort$ja._(_root);
	@override String get exportList => 'リストを書き出す';
	@override late final _Translations$statistics$emptyState$ja emptyState = _Translations$statistics$emptyState$ja._(_root);
	@override String get noMoreData => 'No more data';
}

// Path: currency
class _Translations$currency$ja extends Translations$currency$zh {
	_Translations$currency$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get cny => '人民元';
	@override String get usd => 'USドル';
	@override String get eur => 'ユーロ';
	@override String get jpy => '日本円';
	@override String get gbp => '英ポンド';
	@override String get aud => '豪ドル';
	@override String get cad => 'カナダドル';
	@override String get chf => 'スイスフラン';
	@override String get rub => 'ロシアルーブル';
	@override String get hkd => '香港ドル';
	@override String get twd => '新台湾ドル';
	@override String get inr => 'インドルピー';
}

// Path: sharedSpace
class _Translations$sharedSpace$ja extends Translations$sharedSpace$zh {
	_Translations$sharedSpace$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override late final _Translations$sharedSpace$dashboard$ja dashboard = _Translations$sharedSpace$dashboard$ja._(_root);
	@override late final _Translations$sharedSpace$roles$ja roles = _Translations$sharedSpace$roles$ja._(_root);
	@override String get title => '共有スペース';
	@override late final _Translations$sharedSpace$create$ja create = _Translations$sharedSpace$create$ja._(_root);
	@override late final _Translations$sharedSpace$join$ja join = _Translations$sharedSpace$join$ja._(_root);
	@override late final _Translations$sharedSpace$list$ja list = _Translations$sharedSpace$list$ja._(_root);
	@override late final _Translations$sharedSpace$detail$ja detail = _Translations$sharedSpace$detail$ja._(_root);
	@override late final _Translations$sharedSpace$notifications$ja notifications = _Translations$sharedSpace$notifications$ja._(_root);
	@override late final _Translations$sharedSpace$inviteCard$ja inviteCard = _Translations$sharedSpace$inviteCard$ja._(_root);
	@override late final _Translations$sharedSpace$inviteSuccess$ja inviteSuccess = _Translations$sharedSpace$inviteSuccess$ja._(_root);
	@override late final _Translations$sharedSpace$notificationCard$ja notificationCard = _Translations$sharedSpace$notificationCard$ja._(_root);
	@override late final _Translations$sharedSpace$spaceCard$ja spaceCard = _Translations$sharedSpace$spaceCard$ja._(_root);
	@override late final _Translations$sharedSpace$settings$ja settings = _Translations$sharedSpace$settings$ja._(_root);
}

// Path: budgetSuggestion
class _Translations$budgetSuggestion$ja extends Translations$budgetSuggestion$zh {
	_Translations$budgetSuggestion$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String highPercentage({required Object category, required Object percentage}) => '${category} accounts for ${percentage}% of spending. Consider setting a budget limit.';
	@override String monthlyIncrease({required Object percentage}) => 'Spending increased by ${percentage}% this month. Needs attention.';
	@override String frequentSmall({required Object category, required Object count}) => '${category} has ${count} small transactions. These might be subscriptions.';
	@override String get financialInsights => 'Financial Insights';
}

// Path: server
class _Translations$server$ja extends Translations$server$zh {
	_Translations$server$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

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
	@override String get saveAndReLogin => '保存して再ログイン';
	@override String get serverUrlSavedRedirectLogin => 'サーバー設定が更新されました。再度ログインしてください';
	@override String get serverSettings => 'Server Settings';
	@override String get currentServer => 'Current Server';
	@override String get version => 'Version';
	@override String get environment => 'Environment';
	@override String get changeServer => 'Change Server';
	@override String get changeServerWarning => 'Changing server will log you out. Continue?';
	@override late final _Translations$server$error$ja error = _Translations$server$error$ja._(_root);
}

// Path: errorMapping
class _Translations$errorMapping$ja extends Translations$errorMapping$zh {
	_Translations$errorMapping$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override late final _Translations$errorMapping$generic$ja generic = _Translations$errorMapping$generic$ja._(_root);
	@override late final _Translations$errorMapping$auth$ja auth = _Translations$errorMapping$auth$ja._(_root);
	@override late final _Translations$errorMapping$transaction$ja transaction = _Translations$errorMapping$transaction$ja._(_root);
	@override late final _Translations$errorMapping$space$ja space = _Translations$errorMapping$space$ja._(_root);
	@override late final _Translations$errorMapping$recurring$ja recurring = _Translations$errorMapping$recurring$ja._(_root);
	@override late final _Translations$errorMapping$upload$ja upload = _Translations$errorMapping$upload$ja._(_root);
	@override late final _Translations$errorMapping$storage$ja storage = _Translations$errorMapping$storage$ja._(_root);
	@override late final _Translations$errorMapping$ai$ja ai = _Translations$errorMapping$ai$ja._(_root);
}

// Path: notification
class _Translations$notification$ja extends Translations$notification$zh {
	_Translations$notification$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'お知らせ';
	@override String get markAllRead => 'すべて既読';
	@override String get empty => 'お知らせはありません';
	@override String get loadFailed => '読み込みに失敗しました';
	@override String get retry => '再試行';
	@override String get justNow => 'たった今';
	@override String minutesAgo({required Object minutes}) => '${minutes}分前';
	@override String hoursAgo({required Object hours}) => '${hours}時間前';
	@override String daysAgo({required Object days}) => '${days}日前';
	@override String get deleted => '削除しました';
	@override late final _Translations$notification$types$ja types = _Translations$notification$types$ja._(_root);
	@override late final _Translations$notification$semantic$ja semantic = _Translations$notification$semantic$ja._(_root);
}

// Path: auth.email
class _Translations$auth$email$ja extends Translations$auth$email$zh {
	_Translations$auth$email$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get label => 'メールアドレス';
	@override String get placeholder => 'メールアドレスを入力してください';
	@override String get required => 'メールアドレスは必須です';
	@override String get invalid => '有効なメールアドレスを入力してください';
}

// Path: auth.password
class _Translations$auth$password$ja extends Translations$auth$password$zh {
	_Translations$auth$password$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get label => 'パスワード';
	@override String get placeholder => 'パスワードを入力してください';
	@override String get required => 'パスワードは必須です';
	@override String get tooShort => 'パスワードは6文字以上で入力してください';
	@override String get mustContainNumbersAndLetters => 'パスワードは英数字を含める必要があります';
	@override String get confirm => 'パスワード確認';
	@override String get confirmPlaceholder => 'もう一度パスワードを入力してください';
	@override String get mismatch => 'パスワードが一致しません';
}

// Path: auth.verificationCode
class _Translations$auth$verificationCode$ja extends Translations$auth$verificationCode$zh {
	_Translations$auth$verificationCode$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get label => '認証コード';
	@override String get get => 'コードを取得';
	@override String get sending => '送信中...';
	@override String get sent => '認証コードを送信しました';
	@override String get sendFailed => '送信失敗';
	@override String get placeholder => '認証コードを入力';
	@override String get required => '認証コードは必須です';
}

// Path: calendar.weekdays
class _Translations$calendar$weekdays$ja extends Translations$calendar$weekdays$zh {
	_Translations$calendar$weekdays$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get mon => '月';
	@override String get tue => '火';
	@override String get wed => '水';
	@override String get thu => '木';
	@override String get fri => '金';
	@override String get sat => '土';
	@override String get sun => '日';
}

// Path: appearance.palettes
class _Translations$appearance$palettes$ja extends Translations$appearance$palettes$zh {
	_Translations$appearance$palettes$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

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
class _Translations$forecast$recurringTransaction$ja extends Translations$forecast$recurringTransaction$zh {
	_Translations$forecast$recurringTransaction$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '繰り返し取引';
	@override String get all => 'すべて';
	@override String get expense => '支出';
	@override String get income => '収入';
	@override String get transfer => '振替';
	@override String get noRecurring => '繰り返し取引なし';
	@override String get createHint => '設定すると、システムが自動で取引を記録します';
	@override String get create => '繰り返し取引を作成';
	@override String get edit => '繰り返し取引を編集';
	@override String get newTransaction => '新規繰り返し取引';
	@override String deleteConfirm({required Object name}) => '繰り返し取引「${name}」を削除しますか？';
	@override String activateConfirm({required Object name}) => '「${name}」を有効にしますか？自動記帳が始まります。';
	@override String pauseConfirm({required Object name}) => '「${name}」を一時停止しますか？';
	@override String get created => '作成しました';
	@override String get updated => '更新しました';
	@override String get activated => '有効化';
	@override String get paused => '停止中';
	@override String get nextTime => '次回';
	@override String get sortByTime => '時間順';
	@override String get allPeriod => 'すべての周期';
	@override String periodCount({required Object type, required Object count}) => '${type} (${count} 件)';
	@override String get confirmDelete => '削除確認';
	@override String get confirmActivate => '有効化確認';
	@override String get confirmPause => '停止確認';
	@override String get dynamicAmount => '動態平均';
	@override String get dynamicAmountTitle => '金額の確認が必要';
	@override String get dynamicAmountDescription => '通知が届いたら金額を確認して記帳を完了させてください。';
	@override String get confirmBeforeGeneration => '生成前に確認';
	@override String get confirmBeforeGenerationDesc => '期限日に確認待ち取引を生成、手動確認後に記帳';
	@override String get pendingTitle => '確認待ち取引';
	@override String pendingCount({required Object count}) => '${count} 件確認待ち';
	@override String get confirm => '確認';
	@override String get skip => 'スキップ';
	@override String get noPending => '確認待ち取引なし';
	@override String get confirmSuccess => '取引を確認しました';
	@override String get skipSuccess => '取引をスキップしました';
	@override String get interval => '繰り返し間隔';
	@override String get selectDays => '曜日を選択';
	@override String get alwaysLastDay => '毎月末日に実行';
	@override String get lastDayExecution => '毎月の最終日に実行されます';
	@override String dayExecution({required Object day, required Object suffix}) => '毎月 ${day} 日${suffix}に実行（短い月は月末に合わせます）';
	@override String get setEndDate => '終了日を設定';
	@override String get selectEndDate => '終了日を選択';
	@override String get preview => 'ルールプレビュー';
	@override String get daily => '毎日';
	@override String get weekly => '毎週';
	@override String get monthly => '毎月';
	@override String get yearly => '毎年';
	@override String get custom => 'カスタム';
	@override String get cycle => 'サイクル';
	@override String everyDays({required Object count}) => '${count} 日ごと';
	@override String everyWeeks({required Object count}) => '${count} 週ごと';
	@override String everyMonths({required Object count}) => '${count} か月ごと';
	@override String everyYears({required Object count}) => '${count} 年ごと';
	@override String monthlyOnDay({required Object day, required Object suffix}) => '毎月 ${day} 日${suffix}';
	@override String everyMonthsOnDay({required Object count, required Object day, required Object suffix}) => '${count} か月ごとの ${day} 日${suffix}';
	@override String get monthlyLastDay => '毎月最終日';
	@override String everyMonthsLastDay({required Object count}) => '${count} か月ごとの最終日';
	@override String yearlyOn({required Object month, required Object day}) => '毎年 ${month}/${day}';
	@override String everyYearsOn({required Object count, required Object month, required Object day}) => '${count} 年ごとの ${month}/${day}';
	@override String weeklyOnDay({required Object day}) => '毎週${day}';
	@override String get weekdayMon => '月';
	@override String get weekdayTue => '火';
	@override String get weekdayWed => '水';
	@override String get weekdayThu => '木';
	@override String get weekdayFri => '金';
	@override String get weekdaySat => '土';
	@override String get weekdaySun => '日';
	@override String get weekdayOn => '曜日';
	@override String get weekdayJoiner => '、';
	@override String get weeklyDaysPrefix => 'の';
	@override String get sourceAccount => '振替元口座';
	@override String get targetAccount => '振替先口座';
	@override String get expenseAccount => '支出口座';
	@override String get incomeAccount => '収入口座';
	@override String get selectSourceAccount => '振替元口座を選択';
	@override String get selectTargetAccount => '振替先口座を選択';
	@override String get selectExpenseAccount => '支出口座を選択';
	@override String get selectIncomeAccount => '収入口座を選択';
	@override String amountNotFixed({required Object type}) => '${type}ごとの金額は固定されません';
	@override String get selectBothAccounts => '振替元と振替先の口座を選択してください';
	@override String get sameAccount => '振替元と振替先の口座は同じにできません';
	@override String get endBeforeStart => '終了日は開始日より前には設定できません';
	@override String selectAccountForType({required Object type}) => '${type}口座を選択してください';
	@override String get deleteConfirmGeneric => 'この定期取引を削除してもよろしいですか？この操作は取り消せません。';
	@override String selectDate({required Object date}) => '${date} を選択';
	@override String get accountTypeCash => '現金';
	@override String get accountTypeDeposit => '銀行預金';
	@override String get accountTypeEMoney => '電子マネー';
	@override String get accountTypeInvestment => '投資';
	@override String get accountTypeReceivable => '売掛金';
	@override String get accountTypeCreditCard => 'クレジットカード';
	@override String get accountTypeLoan => 'ローン口座';
	@override String get accountTypePayable => '買掛金';
	@override String get assetAccount => '資産口座';
	@override String get liabilityAccount => '負債口座';
	@override String get noAssetAccounts => '資産口座がありません';
	@override String get goToFinanceToAddAccounts => '財務ページで口座を追加してください';
	@override String get selectAccount => '口座を選択';
	@override String get autoGenerateByRule => '有効にするとルールに従って取引を自動生成';
	@override String dayUnit({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ja'))(count,
		one: '日',
		other: '日',
	);
	@override String weekUnit({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ja'))(count,
		one: '週間',
		other: '週間',
	);
	@override String monthUnit({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ja'))(count,
		one: 'か月',
		other: 'か月',
	);
	@override String yearUnit({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ja'))(count,
		one: '年',
		other: '年',
	);
}

// Path: chat.tools
class _Translations$chat$tools$ja extends Translations$chat$tools$zh {
	_Translations$chat$tools$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get processing => '処理中...';
	@override String get readFile => 'ファイルを確認中...';
	@override String get searchTransactions => '取引を検索中...';
	@override String get queryBudgetStatus => '予算を確認中...';
	@override String get createBudget => '予算プランを作成中...';
	@override String get getCashFlowAnalysis => 'キャッシュフローを分析中...';
	@override String get getFinancialHealthScore => '財務スコアを計算中...';
	@override String get getFinancialSummary => 'レポートを生成中...';
	@override String get evaluateFinancialHealth => '財務状況を評価中...';
	@override String get forecastBalance => '残高を予測中...';
	@override String get simulateExpenseImpact => '影響をシミュレーション中...';
	@override String get recordTransactions => '記帳中...';
	@override String get createTransaction => '記帳中...';
	@override String get duckduckgoSearch => 'ウェブを検索中...';
	@override String get executeTransfer => '振替を実行中...';
	@override String get listDir => 'ディレクトリを表示中...';
	@override String get execute => 'スクリプトを実行中...';
	@override String get analyzeFinance => '財務分析中...';
	@override String get forecastFinance => 'トレンド予測中...';
	@override String get analyzeBudget => '予算分析中...';
	@override String get auditAnalysis => '監査分析中...';
	@override String get budgetOps => '予算を処理中...';
	@override String get createSharedTransaction => '共有帳簿を作成中...';
	@override String get listSpaces => '共有スペースを取得中...';
	@override String get querySpaceSummary => 'スペース概要を確認中...';
	@override String get prepareTransfer => '振替を準備中...';
	@override String get unknown => 'リクエストを処理中...';
	@override late final _Translations$chat$tools$done$ja done = _Translations$chat$tools$done$ja._(_root);
	@override late final _Translations$chat$tools$failed$ja failed = _Translations$chat$tools$failed$ja._(_root);
	@override String get analyzeSpending => 'Analyzing spendings...';
	@override String get analyzeCashflow => 'Analyzing cashflow...';
	@override String get suggestBudget => 'Suggesting budget...';
	@override String get cancelled => 'Cancelled';
	@override String get prepareBudgetSimulation => '予算シミュレーションを準備中';
	@override String get simulateBudget => '予算をシミュレーション中';
}

// Path: chat.transferWizard
class _Translations$chat$transferWizard$ja extends Translations$chat$transferWizard$zh {
	_Translations$chat$transferWizard$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '振替ウィザード';
	@override String get amount => '振替金額';
	@override String get amountHint => '金額を入力';
	@override String get sourceAccount => '振替元口座';
	@override String get targetAccount => '振替先口座';
	@override String get selectAccount => '口座を選択してください';
	@override String get confirmTransfer => '振替を確認';
	@override String get confirmed => '確認済み';
	@override String get transferSuccess => '振替が完了しました';
	@override String get selectReceiveAccount => '选择收款账户';
	@override String get noAssetAccounts => '資産口座がありません';
	@override String get goToFinanceToAddAccounts => '財務ページで口座を追加してください';
	@override String get needTwoAssetAccounts => '振替には資産口座が2つ以上必要です';
}

// Path: chat.genui
class _Translations$chat$genui$ja extends Translations$chat$genui$zh {
	_Translations$chat$genui$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override late final _Translations$chat$genui$expenseSummary$ja expenseSummary = _Translations$chat$genui$expenseSummary$ja._(_root);
	@override late final _Translations$chat$genui$transactionList$ja transactionList = _Translations$chat$genui$transactionList$ja._(_root);
	@override late final _Translations$chat$genui$transactionGroupReceipt$ja transactionGroupReceipt = _Translations$chat$genui$transactionGroupReceipt$ja._(_root);
	@override late final _Translations$chat$genui$transactionCard$ja transactionCard = _Translations$chat$genui$transactionCard$ja._(_root);
	@override late final _Translations$chat$genui$cashFlowCard$ja cashFlowCard = _Translations$chat$genui$cashFlowCard$ja._(_root);
	@override late final _Translations$chat$genui$budgetSimulator$ja budgetSimulator = _Translations$chat$genui$budgetSimulator$ja._(_root);
	@override late final _Translations$chat$genui$budgetReceipt$ja budgetReceipt = _Translations$chat$genui$budgetReceipt$ja._(_root);
	@override late final _Translations$chat$genui$budgetStatusCard$ja budgetStatusCard = _Translations$chat$genui$budgetStatusCard$ja._(_root);
	@override late final _Translations$chat$genui$emptyStateAlert$ja emptyStateAlert = _Translations$chat$genui$emptyStateAlert$ja._(_root);
	@override late final _Translations$chat$genui$cashFlowForecast$ja cashFlowForecast = _Translations$chat$genui$cashFlowForecast$ja._(_root);
	@override late final _Translations$chat$genui$healthScore$ja healthScore = _Translations$chat$genui$healthScore$ja._(_root);
	@override late final _Translations$chat$genui$spaceSelector$ja spaceSelector = _Translations$chat$genui$spaceSelector$ja._(_root);
	@override late final _Translations$chat$genui$transferPath$ja transferPath = _Translations$chat$genui$transferPath$ja._(_root);
	@override late final _Translations$chat$genui$transactionConfirmation$ja transactionConfirmation = _Translations$chat$genui$transactionConfirmation$ja._(_root);
	@override late final _Translations$chat$genui$budgetAnalysis$ja budgetAnalysis = _Translations$chat$genui$budgetAnalysis$ja._(_root);
	@override late final _Translations$chat$genui$error$ja error = _Translations$chat$genui$error$ja._(_root);
}

// Path: chat.welcome
class _Translations$chat$welcome$ja extends Translations$chat$welcome$zh {
	_Translations$chat$welcome$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override late final _Translations$chat$welcome$morning$ja morning = _Translations$chat$welcome$morning$ja._(_root);
	@override late final _Translations$chat$welcome$midday$ja midday = _Translations$chat$welcome$midday$ja._(_root);
	@override late final _Translations$chat$welcome$afternoon$ja afternoon = _Translations$chat$welcome$afternoon$ja._(_root);
	@override late final _Translations$chat$welcome$evening$ja evening = _Translations$chat$welcome$evening$ja._(_root);
	@override late final _Translations$chat$welcome$night$ja night = _Translations$chat$welcome$night$ja._(_root);
}

// Path: error.genui
class _Translations$error$genui$ja extends Translations$error$genui$zh {
	_Translations$error$genui$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get loadingFailed => '読み込み失敗';
	@override String get schemaFailed => '検証失敗';
	@override String get schemaDescription => '定義が仕様に適合していません';
	@override String get networkError => 'ネットワークエラー';
	@override String retryStatus({required Object retryCount, required Object maxRetries}) => '再試行中 ${retryCount}/${maxRetries}';
	@override String get maxRetriesReached => '最大試行回数に達しました';
}

// Path: account.types
class _Translations$account$types$ja extends Translations$account$types$zh {
	_Translations$account$types$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

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
class _Translations$statistics$overview$ja extends Translations$statistics$overview$zh {
	_Translations$statistics$overview$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get balance => '残高';
	@override String get income => '総収入';
	@override String get expense => '総支出';
}

// Path: statistics.trend
class _Translations$statistics$trend$ja extends Translations$statistics$trend$zh {
	_Translations$statistics$trend$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '収支推移';
	@override String get expense => '支出';
	@override String get income => '収入';
}

// Path: statistics.analysis
class _Translations$statistics$analysis$ja extends Translations$statistics$analysis$zh {
	_Translations$statistics$analysis$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '支出分析';
	@override String get expenseTitle => '支出分析';
	@override String get incomeTitle => '収入分析';
	@override String get total => '合計';
	@override String get breakdown => '支出カテゴリ内訳';
	@override String get radarNeedMoreData => 'レーダーチャートには3つ以上のカテゴリデータが必要です';
}

// Path: statistics.filter
class _Translations$statistics$filter$ja extends Translations$statistics$filter$zh {
	_Translations$statistics$filter$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get accountType => '口座タイプ';
	@override String get allAccounts => 'すべての口座';
	@override String get apply => '適用';
}

// Path: statistics.sort
class _Translations$statistics$sort$ja extends Translations$statistics$sort$zh {
	_Translations$statistics$sort$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get amount => '金額順';
	@override String get date => '日付順';
}

// Path: statistics.emptyState
class _Translations$statistics$emptyState$ja extends Translations$statistics$emptyState$zh {
	_Translations$statistics$emptyState$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'Unlock Financial Insights';
	@override String get description => 'Your financial report is currently a blank canvas.\nRecord your first transaction and let the data tell your story.';
	@override String get action => 'Record First Transaction';
}

// Path: sharedSpace.dashboard
class _Translations$sharedSpace$dashboard$ja extends Translations$sharedSpace$dashboard$zh {
	_Translations$sharedSpace$dashboard$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get sectionTitle => '財務概要';
	@override String get cumulativeTotalExpense => '累計総支出';
	@override String get participatingMembers => '参加メンバー';
	@override String membersCount({required Object count}) => '${count} 人';
	@override String get averagePerMember => 'メンバー平均';
	@override String get spendingDistribution => 'メンバー別支出割合';
	@override String get realtimeUpdates => 'リアルタイム更新';
	@override String get paid => '支払い済み';
}

// Path: sharedSpace.roles
class _Translations$sharedSpace$roles$ja extends Translations$sharedSpace$roles$zh {
	_Translations$sharedSpace$roles$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get owner => 'オーナー';
	@override String get admin => '管理者';
	@override String get member => 'メンバー';
}

// Path: sharedSpace.create
class _Translations$sharedSpace$create$ja extends Translations$sharedSpace$create$zh {
	_Translations$sharedSpace$create$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '共有スペースを作成';
	@override String get subtitle => '共有スペースを作成して、共有の財務を閲覧・分析';
	@override String get nameLabel => 'スペース名';
	@override String get nameHint => '例：卒業旅行';
	@override String get descLabel => '説明（任意）';
	@override String get descHint => '共同旅行の支出を記録';
	@override String get cancel => 'キャンセル';
	@override String get submit => '作成';
	@override String get nameRequired => 'スペース名を入力してください';
	@override String get nameTooShort => 'スペース名は2文字以上必要です';
	@override String get nameTooLong => 'スペース名は50文字以内にしてください';
}

// Path: sharedSpace.join
class _Translations$sharedSpace$join$ja extends Translations$sharedSpace$join$zh {
	_Translations$sharedSpace$join$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '共有スペースに参加';
	@override String get subtitle => '招待コードを入力して、共有の財務を閲覧・分析';
	@override String get codeHint => '6桁の数字招待コードを入力';
	@override String get cancel => 'キャンセル';
	@override String get submit => '参加';
	@override String get codeRequired => '招待コードを入力してください';
	@override String get codeInvalid => '6桁の数字招待コードを入力してください';
}

// Path: sharedSpace.list
class _Translations$sharedSpace$list$ja extends Translations$sharedSpace$list$zh {
	_Translations$sharedSpace$list$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get emptyTitle => '共有の財務をみんなで俯瞰';
	@override String get emptySubtitle => '共有スペースを作成・参加して、家族や友達と財務の閲覧・分析・集計を共有';
	@override String get getStarted => '始める';
	@override String get hasInviteCode => '招待コードをお持ちですか？タップして参加';
	@override String joinedSuccess({required Object name}) => '「${name}」に参加しました！';
}

// Path: sharedSpace.detail
class _Translations$sharedSpace$detail$ja extends Translations$sharedSpace$detail$zh {
	_Translations$sharedSpace$detail$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get members => 'メンバー';
	@override String get transactions => '取引履歴';
	@override String recordsCount({required Object count}) => '${count} 件';
	@override String get settlement => '精算';
	@override String get inviteCode => '招待コード';
	@override String get copyCode => '招待コードをコピー';
	@override String codeCopied({required Object code}) => '招待コードをコピーしました：${code}';
	@override String get validFor24h => '24時間有効';
	@override String get leaveSpace => 'スペースを退出';
	@override String get deleteSpace => 'スペースを削除';
	@override String get removeMember => 'メンバーを削除';
	@override String get leaveConfirm => 'この共有スペースを退出しますか？退出後は取引履歴を閲覧できなくなります。';
	@override String get deleteConfirm => 'この共有スペースを削除しますか？この操作は取り消せず、すべてのメンバーが削除されます。';
	@override String get removeConfirm => 'このメンバーを共有スペースから削除しますか？';
	@override String get generatingCode => '招待コードを生成中...';
	@override String get loadFailed => '読み込みに失敗しました';
	@override String get retry => '再試行';
	@override String get noTransactions => '取引はまだありません';
	@override String get noTransactionsHint => 'このスペースの取引がここに表示されます';
	@override String get refreshCode => 'コードを更新';
	@override String get noMoreTransactions => 'これ以上の取引はありません';
}

// Path: sharedSpace.notifications
class _Translations$sharedSpace$notifications$ja extends Translations$sharedSpace$notifications$zh {
	_Translations$sharedSpace$notifications$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'お知らせ';
	@override String get empty => 'お知らせはありません';
	@override String get emptyHint => '新しい招待やアクティビティがあると、\nここにお知らせが表示されます';
	@override String get incompleteInfo => '招待情報が不完全です';
	@override String get inviteAccepted => '招待を承認しました！';
	@override String get inviteRejected => '招待を拒否しました';
	@override String get allMarkedRead => 'すべて既読にしました';
}

// Path: sharedSpace.inviteCard
class _Translations$sharedSpace$inviteCard$ja extends Translations$sharedSpace$inviteCard$zh {
	_Translations$sharedSpace$inviteCard$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '招待コード';
	@override String get copyCode => '招待コードをコピー';
	@override String get shareLink => '招待リンクを共有';
	@override String get codeCopied => '招待コードをコピーしました';
	@override String get noExpiry => '無期限';
	@override String get expired => '期限切れ';
	@override String expiresInDays({required Object days}) => '${days}日後に期限切れ';
	@override String expiresInHours({required Object hours}) => '${hours}時間後に期限切れ';
	@override String expiresInMinutes({required Object minutes}) => '${minutes}分後に期限切れ';
	@override String get expiringSoon => 'まもなく期限切れ';
	@override String shareText({required Object spaceName, required Object code, required Object link, required Object expiry}) => '共有スペース「${spaceName}」に招待されました\n\n招待コード：${code}\nまたはリンクをクリックして直接参加：${link}\n\n招待コード${expiry}';
}

// Path: sharedSpace.inviteSuccess
class _Translations$sharedSpace$inviteSuccess$ja extends Translations$sharedSpace$inviteSuccess$zh {
	_Translations$sharedSpace$inviteSuccess$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '作成完了';
	@override String get subtitle => '共有スペースが作成されました';
	@override String get inviteLater => '後で招待';
	@override String get enterSpace => 'スペースに入る';
	@override String get generatingCode => '招待コードを生成中...';
	@override String get generateFailed => '招待コードの生成に失敗しました';
	@override String get codeCopied => '招待コードをコピーしました';
	@override String get retry => '再試行';
	@override String get codeLabel => '招待コード';
	@override String get validHint => '24時間有効 · タップしてコピー';
}

// Path: sharedSpace.notificationCard
class _Translations$sharedSpace$notificationCard$ja extends Translations$sharedSpace$notificationCard$zh {
	_Translations$sharedSpace$notificationCard$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get accept => '承認';
	@override String get reject => '拒否';
	@override String get unknownTime => '不明な時間';
	@override String get justNow => 'たった今';
}

// Path: sharedSpace.spaceCard
class _Translations$sharedSpace$spaceCard$ja extends Translations$sharedSpace$spaceCard$zh {
	_Translations$sharedSpace$spaceCard$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get noDescription => '説明なし';
	@override String get creator => '作成者';
	@override String get member => 'メンバー';
	@override String membersCount({required Object count}) => '${count} 人のメンバー';
	@override String transactionsCount({required Object count}) => '${count} 件の取引';
}

// Path: sharedSpace.settings
class _Translations$sharedSpace$settings$ja extends Translations$sharedSpace$settings$zh {
	_Translations$sharedSpace$settings$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'スペース設定';
	@override String get spaceInfo => 'スペース情報';
	@override String get nameLabel => 'スペース名';
	@override String get descLabel => 'スペースの説明';
	@override String get save => '保存';
	@override String get saved => '保存しました';
	@override String get saveFailed => '保存に失敗しました';
	@override String get memberManagement => 'メンバー管理';
	@override String membersCount({required Object count}) => '${count} 人のメンバー';
	@override String removeMemberConfirm({required Object name}) => '「${name}」をスペースから削除しますか？';
	@override String get removed => 'メンバーを削除しました';
	@override String get removeFailed => '削除に失敗しました';
	@override String get inviteManagement => '招待管理';
	@override String get currentCode => '現在の招待コード';
	@override String get generateNew => '新しいコードを生成';
	@override String get noValidCode => '有効な招待コードがありません';
	@override String get refreshCode => 'コードを更新';
	@override String get refreshConfirm => '新しいコードを生成すると古いコードは無効になります。続行しますか？';
	@override String get codeRefreshed => '招待コードを更新しました';
	@override String get dangerZone => '危険な操作';
	@override String get editHint => '管理者のみ編集可能';
	@override String get edit => '編集';
	@override String get you => '自分';
	@override String get pending => '承認待ち';
	@override String get declined => '拒否済み';
	@override String get setAsAdmin => '管理者に設定';
	@override String get setAsMember => 'メンバーに設定';
	@override String get changeRole => '役割を変更';
	@override String changeRoleConfirm({required Object name, required Object role}) => '「${name}」の役割を「${role}」に変更しますか？';
	@override String get confirm => '確認';
	@override String get roleChanged => '役割を変更しました';
	@override String get roleChangeFailed => '役割の変更に失敗しました';
}

// Path: server.error
class _Translations$server$error$ja extends Translations$server$error$zh {
	_Translations$server$error$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get urlRequired => 'Server address is required';
	@override String get invalidUrl => 'Invalid URL format';
	@override String get connectionTimeout => 'Connection timed out';
	@override String get connectionRefused => 'Could not connect to server';
	@override String get sslError => 'SSL certificate error';
	@override String get serverError => 'Server error';
	@override String get plainHttpWarning => '平文 HTTP:ログイントークンとデータが暗号化されず送信されます。信頼できるローカルネットワークでのみ使用してください。';
}

// Path: errorMapping.generic
class _Translations$errorMapping$generic$ja extends Translations$errorMapping$generic$zh {
	_Translations$errorMapping$generic$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

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
class _Translations$errorMapping$auth$ja extends Translations$errorMapping$auth$zh {
	_Translations$errorMapping$auth$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

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
class _Translations$errorMapping$transaction$ja extends Translations$errorMapping$transaction$zh {
	_Translations$errorMapping$transaction$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get commentEmpty => 'Comment content cannot be empty';
	@override String get invalidParent => 'Invalid parent comment ID';
	@override String get saveFailed => 'Failed to save comment';
	@override String get deleteFailed => 'Failed to delete comment';
	@override String get notExists => 'Transaction does not exist';
	@override String get invalidAccountId => 'アカウントIDが無効です';
	@override String get exchangeRateUnavailable => 'この通貨の為替レートは利用できません';
}

// Path: errorMapping.space
class _Translations$errorMapping$space$ja extends Translations$errorMapping$space$zh {
	_Translations$errorMapping$space$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

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
	@override String get transactionAlreadyInSpace => '取引は既にこのスペースにあります';
}

// Path: errorMapping.recurring
class _Translations$errorMapping$recurring$ja extends Translations$errorMapping$recurring$zh {
	_Translations$errorMapping$recurring$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get invalidRule => 'Invalid recurrence rule';
	@override String get ruleNotFound => 'Recurrence rule not found';
}

// Path: errorMapping.upload
class _Translations$errorMapping$upload$ja extends Translations$errorMapping$upload$zh {
	_Translations$errorMapping$upload$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get noFile => 'No file uploaded';
	@override String get tooLarge => 'File too large';
	@override String get unsupportedType => 'Unsupported file type';
	@override String get tooManyFiles => 'Too many files';
	@override String get invalidFile => 'アップロードされたファイルが無効です';
	@override String get invalidMimeType => 'ファイルのMIMEタイプが無効です';
	@override String get invalidImageContent => '画像の内容が無効です';
	@override String get imageTooWide => '画像が幅広すぎます';
	@override String get imageTooHigh => '画像が高すぎます';
	@override String get totalSizeTooLarge => 'ファイルの合計サイズが大きすぎます';
	@override String get readError => 'ファイルの読み取りに失敗しました';
	@override String get filesystemError => 'ファイルシステムエラー';
	@override String get verificationFailed => 'アップロードの検証に失敗しました';
	@override String get allFailed => 'すべてのファイルのアップロードに失敗しました';
	@override String get invalidImageUrls => '画像URLが無効です';
	@override String get fileNotFound => 'ファイルが見つかりません';
	@override String get imageCompressionFailed => '画像の圧縮に失敗しました';
	@override String get accessError => 'ファイルアクセスエラー';
	@override String get deleteError => 'ファイルの削除に失敗しました';
	@override String get noFiles => 'ファイルが指定されていません';
	@override String get fileEmpty => 'ファイルが空です';
	@override String get invalidFilename => 'ファイル名が無効です';
}

// Path: errorMapping.storage
class _Translations$errorMapping$storage$ja extends Translations$errorMapping$storage$zh {
	_Translations$errorMapping$storage$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get configNotFound => 'ストレージ設定が見つからないかアクセス権限がありません';
	@override String get configInUse => '削除できません：ストレージ設定は添付ファイルで使用中です';
	@override String get invalidProviderType => '無効なストレージプロバイダータイプ';
}

// Path: errorMapping.ai
class _Translations$errorMapping$ai$ja extends Translations$errorMapping$ai$zh {
	_Translations$errorMapping$ai$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get contextLimit => 'Context limit exceeded';
	@override String get tokenLimit => 'Insufficient tokens';
	@override String get emptyMessage => 'Empty user message';
	@override String get conversationIdInvalid => '会話が無効です';
	@override String get conversationIdNotOwner => 'この会話へのアクセス権がありません';
}

// Path: notification.types
class _Translations$notification$types$ja extends Translations$notification$types$zh {
	_Translations$notification$types$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get system => 'システム';
	@override String get spaceInvite => 'スペース招待';
	@override String get spaceActivity => 'スペース活動';
	@override String get billComment => '請求コメント';
	@override String get budgetAlert => '予算アラート';
	@override String get transaction => '取引通知';
}

// Path: notification.semantic
class _Translations$notification$semantic$ja extends Translations$notification$semantic$zh {
	_Translations$notification$semantic$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String memberJoined({required Object name}) => '${name} さんがスペースに参加しました';
	@override String memberJoinedDetail({required Object space}) => '新しいメンバーが「${space}」に参加しました';
	@override String welcome({required Object space}) => '「${space}」へようこそ';
	@override String newTransaction({required Object name}) => '${name} さんが新しい支出を記録しました';
	@override String newTransactionDetail({required Object amount, required Object space}) => '${amount}、「${space}」より';
	@override String memberLeft({required Object name}) => '${name} さんがスペースを退出しました';
	@override String get recurringPending => '定期取引の確認待ち';
	@override String recurringPendingDetail({required Object description, required Object amount}) => '${description} ${amount}、確認待ちです';
	@override String commentReplied({required Object name}) => '${name} さんがあなたのコメントに返信しました';
	@override String commentOnTransaction({required Object name}) => '${name} さんがあなたの取引にコメントしました';
	@override String commentMentioned({required Object name}) => '${name} さんがあなたをメンションしました';
	@override String commentInSpace({required Object name}) => '${name} さんがあなたのスペースにコメントしました';
}

// Path: chat.tools.done
class _Translations$chat$tools$done$ja extends Translations$chat$tools$done$zh {
	_Translations$chat$tools$done$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get readFile => 'ファイルを確認しました';
	@override String get searchTransactions => '取引を検索しました';
	@override String get queryBudgetStatus => '予算を確認しました';
	@override String get createBudget => '予算を作成しました';
	@override String get getCashFlowAnalysis => 'キャッシュフローを分析しました';
	@override String get getFinancialHealthScore => 'スコアを計算しました';
	@override String get getFinancialSummary => 'レポート生成完了';
	@override String get evaluateFinancialHealth => '財務評価完了';
	@override String get forecastBalance => '残高予測完了';
	@override String get simulateExpenseImpact => 'シミュレーション完了';
	@override String get recordTransactions => '記帳完了';
	@override String get createTransaction => '記帳しました';
	@override String get duckduckgoSearch => '検索完了';
	@override String get executeTransfer => '振替完了';
	@override String get listDir => 'ディレクトリ表示完了';
	@override String get execute => '実行完了';
	@override String get analyzeFinance => '分析完了';
	@override String get forecastFinance => '予測完了';
	@override String get analyzeBudget => '予算分析完了';
	@override String get auditAnalysis => '監査完了';
	@override String get budgetOps => '予算処理完了';
	@override String get createSharedTransaction => '共有帳簿作成完了';
	@override String get listSpaces => '共有スペース取得完了';
	@override String get querySpaceSummary => '概要確認完了';
	@override String get prepareTransfer => '準備完了';
	@override String get unknown => '完了しました';
	@override String get analyzeSpending => 'Spending analysis complete';
	@override String get analyzeCashflow => 'Cashflow analysis complete';
	@override String get suggestBudget => 'Budget suggestion complete';
	@override String get prepareBudgetSimulation => '予算シミュレーション準備完了';
	@override String get simulateBudget => '予算シミュレーション完了';
}

// Path: chat.tools.failed
class _Translations$chat$tools$failed$ja extends Translations$chat$tools$failed$zh {
	_Translations$chat$tools$failed$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get unknown => '操作に失敗しました';
}

// Path: chat.genui.expenseSummary
class _Translations$chat$genui$expenseSummary$ja extends Translations$chat$genui$expenseSummary$zh {
	_Translations$chat$genui$expenseSummary$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get totalExpense => '総支出';
	@override String get mainExpenses => '主な支出';
	@override String viewAll({required Object count}) => '全 ${count} 件を表示';
	@override String get details => '詳細';
}

// Path: chat.genui.transactionList
class _Translations$chat$genui$transactionList$ja extends Translations$chat$genui$transactionList$zh {
	_Translations$chat$genui$transactionList$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String searchResults({required Object count}) => '検索結果 (${count})';
	@override String loaded({required Object count}) => '${count} 件読み込み済み';
	@override String get noResults => '結果が見つかりません';
	@override String get loadMore => 'さらに表示';
	@override String get allLoaded => 'すべて読み込みました';
}

// Path: chat.genui.transactionGroupReceipt
class _Translations$chat$genui$transactionGroupReceipt$ja extends Translations$chat$genui$transactionGroupReceipt$zh {
	_Translations$chat$genui$transactionGroupReceipt$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '記帳成功';
	@override String count({required Object count}) => '${count}件';
	@override String get selectAccount => '口座を関連付け';
	@override String get selectAccountSubtitle => 'この口座をすべての取引に適用します';
	@override String associatedAccount({required Object name}) => '関連付け口座：${name}';
	@override String get clickToAssociate => '口座を関連付ける（一括可）';
	@override String get associateSuccess => '関連付けに成功しました';
	@override String associateFailed({required Object error}) => 'エラー: ${error}';
	@override String get accountAssociation => '口座関連付け';
	@override String get sharedSpace => '共有スペース';
	@override String get notAssociated => '未設定';
	@override String get addSpace => '追加';
	@override String get selectSpace => 'スペースを選択';
	@override String get spaceAssociateSuccess => 'スペースに関連付けました';
	@override String spaceAssociateFailed({required Object error}) => 'スペース関連付け失敗: ${error}';
	@override String get currencyMismatchTitle => '通貨が異なります';
	@override String get currencyMismatchDesc => '取引の通貨と口座の通貨が異なります。口座残高は為替レートで換算されます。';
	@override String get transactionAmount => '取引金額';
	@override String get accountCurrency => '口座通貨';
	@override String get targetAccount => '対象口座';
	@override String get currencyMismatchNote => '注意：為替レートで換算して残高から差し引きます';
	@override String get confirmAssociate => '確認';
	@override String get total => 'Total';
	@override String spaceCount({required Object count}) => '${count} spaces';
}

// Path: chat.genui.transactionCard
class _Translations$chat$genui$transactionCard$ja extends Translations$chat$genui$transactionCard$zh {
	_Translations$chat$genui$transactionCard$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '取引成功';
	@override String get associatedAccount => '関連口座';
	@override String get notCounted => '資産に含めない';
	@override String get modify => '修正';
	@override String get associate => '口座を関連付け';
	@override String get selectAccount => '口座を選択';
	@override String get autoGenerateByRule => '有効にするとルールに従って取引を自動生成';
	@override String get noAccount => '口座がありません。追加してください';
	@override String get missingId => 'IDがありません';
	@override String associatedTo({required Object name}) => '${name} に関連付け済み';
	@override String updateFailed({required Object error}) => '更新失敗: ${error}';
	@override String get sharedSpace => 'Shared Space';
	@override String get noSpace => 'No shared spaces available';
	@override String get selectSpace => 'Select Shared Space';
	@override String get linkedToSpace => 'Linked to shared space';
}

// Path: chat.genui.cashFlowCard
class _Translations$chat$genui$cashFlowCard$ja extends Translations$chat$genui$cashFlowCard$zh {
	_Translations$chat$genui$cashFlowCard$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'キャッシュフロー＆健康レポート';
	@override String savingsRate({required Object rate}) => '貯蓄率 ${rate}%';
	@override String get totalIncome => '総収入';
	@override String get totalExpense => '総支出';
	@override String get essentialExpense => '必須支出';
	@override String get discretionaryExpense => '自由裁量支出';
	@override String get aiInsight => 'AI分析';
}

// Path: chat.genui.budgetSimulator
class _Translations$chat$genui$budgetSimulator$ja extends Translations$chat$genui$budgetSimulator$zh {
	_Translations$chat$genui$budgetSimulator$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '予算ストレステスト';
	@override String get targetAmount => '目標予算額';
	@override String get overspendProbability => '超過確率';
	@override String get riskLow => 'リスク極低';
	@override String get riskMedium => 'リスク中程度';
	@override String get riskHigh => '超過リスク高';
	@override String get evaluating => '消費パターンを分析中...';
	@override String get historyAverage => '過去の月平均';
	@override String get dailyAllowance => '1日あたりの上限';
	@override String get cancel => 'キャンセル';
	@override String get confirm => 'この予算を適用';
}

// Path: chat.genui.budgetReceipt
class _Translations$chat$genui$budgetReceipt$ja extends Translations$chat$genui$budgetReceipt$zh {
	_Translations$chat$genui$budgetReceipt$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get newBudget => 'New Budget';
	@override String get budgetCreated => 'Budget Created';
	@override String get rolloverBudget => 'Rollover Budget';
	@override String get createFailed => 'Failed to create budget';
	@override String get thisMonth => 'This Month';
	@override String dateRange({required Object start, required Object startDay, required Object end, required Object endDay}) => '${start}/${startDay} - ${end}/${endDay}';
}

// Path: chat.genui.budgetStatusCard
class _Translations$chat$genui$budgetStatusCard$ja extends Translations$chat$genui$budgetStatusCard$zh {
	_Translations$chat$genui$budgetStatusCard$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

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

// Path: chat.genui.emptyStateAlert
class _Translations$chat$genui$emptyStateAlert$ja extends Translations$chat$genui$emptyStateAlert$zh {
	_Translations$chat$genui$emptyStateAlert$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get noBudgetsYet => '予算がありません';
	@override String get noTransactionsYet => '取引がありません';
	@override String get noAccountsYet => '口座がありません';
}

// Path: chat.genui.cashFlowForecast
class _Translations$chat$genui$cashFlowForecast$ja extends Translations$chat$genui$cashFlowForecast$zh {
	_Translations$chat$genui$cashFlowForecast$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

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
class _Translations$chat$genui$healthScore$ja extends Translations$chat$genui$healthScore$zh {
	_Translations$chat$genui$healthScore$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'Financial Health';
	@override String get suggestions => 'Suggestions';
	@override String scorePoint({required Object score}) => '${score} pts';
	@override late final _Translations$chat$genui$healthScore$status$ja status = _Translations$chat$genui$healthScore$status$ja._(_root);
}

// Path: chat.genui.spaceSelector
class _Translations$chat$genui$spaceSelector$ja extends Translations$chat$genui$spaceSelector$zh {
	_Translations$chat$genui$spaceSelector$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get selected => 'Selected';
	@override String get unnamedSpace => 'Unnamed Space';
	@override String get linked => 'Linked';
	@override String get roleOwner => 'Owner';
	@override String get roleAdmin => 'Admin';
	@override String get roleMember => 'Member';
	@override String get associateAction => '選択したスペースに関連付け';
}

// Path: chat.genui.transferPath
class _Translations$chat$genui$transferPath$ja extends Translations$chat$genui$transferPath$zh {
	_Translations$chat$genui$transferPath$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

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
	@override String get executeAction => '選択に従って振替を実行';
}

// Path: chat.genui.transactionConfirmation
class _Translations$chat$genui$transactionConfirmation$ja extends Translations$chat$genui$transactionConfirmation$zh {
	_Translations$chat$genui$transactionConfirmation$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get multipleAccounts => '检测到多个关联账户';
	@override String get confirmed => '已确认';
}

// Path: chat.genui.budgetAnalysis
class _Translations$chat$genui$budgetAnalysis$ja extends Translations$chat$genui$budgetAnalysis$zh {
	_Translations$chat$genui$budgetAnalysis$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '预算分析报告';
	@override String periodDays({required Object days}) => '过去 ${days} 天';
	@override String get totalExpense => '总支出';
	@override String momChange({required Object change}) => '环比 ${change}%';
	@override String get categoryDistribution => '分类占比';
	@override String get topSpenders => '大额支出';
	@override String amountWan({required Object amount}) => '${amount}万';
}

// Path: chat.genui.error
class _Translations$chat$genui$error$ja extends Translations$chat$genui$error$zh {
	_Translations$chat$genui$error$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'レンダリングに失敗しました';
	@override String get fetchFailed => '読み込みに失敗しました。後でもう一度お試しください。';
	@override String get dataIncomplete => 'データが不完全です';
}

// Path: chat.welcome.morning
class _Translations$chat$welcome$morning$ja extends Translations$chat$welcome$morning$zh {
	_Translations$chat$welcome$morning$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get subtitle => '新しい一日を、記録から始めましょう';
	@override late final _Translations$chat$welcome$morning$breakfast$ja breakfast = _Translations$chat$welcome$morning$breakfast$ja._(_root);
	@override late final _Translations$chat$welcome$morning$yesterdayReview$ja yesterdayReview = _Translations$chat$welcome$morning$yesterdayReview$ja._(_root);
	@override late final _Translations$chat$welcome$morning$todayBudget$ja todayBudget = _Translations$chat$welcome$morning$todayBudget$ja._(_root);
}

// Path: chat.welcome.midday
class _Translations$chat$welcome$midday$ja extends Translations$chat$welcome$midday$zh {
	_Translations$chat$welcome$midday$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get greeting => 'こんにちは';
	@override String get subtitle => 'ランチタイムにサクッと記録';
	@override late final _Translations$chat$welcome$midday$lunch$ja lunch = _Translations$chat$welcome$midday$lunch$ja._(_root);
	@override late final _Translations$chat$welcome$midday$weeklyExpense$ja weeklyExpense = _Translations$chat$welcome$midday$weeklyExpense$ja._(_root);
	@override late final _Translations$chat$welcome$midday$checkBalance$ja checkBalance = _Translations$chat$welcome$midday$checkBalance$ja._(_root);
}

// Path: chat.welcome.afternoon
class _Translations$chat$welcome$afternoon$ja extends Translations$chat$welcome$afternoon$zh {
	_Translations$chat$welcome$afternoon$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get subtitle => 'ティータイムに家計を整理';
	@override late final _Translations$chat$welcome$afternoon$quickRecord$ja quickRecord = _Translations$chat$welcome$afternoon$quickRecord$ja._(_root);
	@override late final _Translations$chat$welcome$afternoon$analyzeSpending$ja analyzeSpending = _Translations$chat$welcome$afternoon$analyzeSpending$ja._(_root);
	@override late final _Translations$chat$welcome$afternoon$budgetProgress$ja budgetProgress = _Translations$chat$welcome$afternoon$budgetProgress$ja._(_root);
}

// Path: chat.welcome.evening
class _Translations$chat$welcome$evening$ja extends Translations$chat$welcome$evening$zh {
	_Translations$chat$welcome$evening$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get subtitle => '今日もお疲れ様でした、家計の点検をしましょう';
	@override late final _Translations$chat$welcome$evening$dinner$ja dinner = _Translations$chat$welcome$evening$dinner$ja._(_root);
	@override late final _Translations$chat$welcome$evening$todaySummary$ja todaySummary = _Translations$chat$welcome$evening$todaySummary$ja._(_root);
	@override late final _Translations$chat$welcome$evening$tomorrowPlan$ja tomorrowPlan = _Translations$chat$welcome$evening$tomorrowPlan$ja._(_root);
}

// Path: chat.welcome.night
class _Translations$chat$welcome$night$ja extends Translations$chat$welcome$night$zh {
	_Translations$chat$welcome$night$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get greeting => '夜深まりました';
	@override String get subtitle => '静かに見つめ直す、これからの資産';
	@override late final _Translations$chat$welcome$night$makeupRecord$ja makeupRecord = _Translations$chat$welcome$night$makeupRecord$ja._(_root);
	@override late final _Translations$chat$welcome$night$monthlyReview$ja monthlyReview = _Translations$chat$welcome$night$monthlyReview$ja._(_root);
	@override late final _Translations$chat$welcome$night$financialThinking$ja financialThinking = _Translations$chat$welcome$night$financialThinking$ja._(_root);
}

// Path: chat.genui.healthScore.status
class _Translations$chat$genui$healthScore$status$ja extends Translations$chat$genui$healthScore$status$zh {
	_Translations$chat$genui$healthScore$status$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get excellent => 'Excellent';
	@override String get good => 'Good';
	@override String get fair => 'Fair';
	@override String get needsImprovement => 'Needs Improvement';
	@override String get poor => 'Poor';
}

// Path: chat.welcome.morning.breakfast
class _Translations$chat$welcome$morning$breakfast$ja extends Translations$chat$welcome$morning$breakfast$zh {
	_Translations$chat$welcome$morning$breakfast$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '朝食記録';
	@override String get prompt => '朝食の支出を記録';
	@override String get description => '今日最初の支出をすばやく記録';
}

// Path: chat.welcome.morning.yesterdayReview
class _Translations$chat$welcome$morning$yesterdayReview$ja extends Translations$chat$welcome$morning$yesterdayReview$zh {
	_Translations$chat$welcome$morning$yesterdayReview$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '昨日の振り返り';
	@override String get prompt => '昨日の支出を分析';
	@override String get description => '昨日いくら使ったか確認';
}

// Path: chat.welcome.morning.todayBudget
class _Translations$chat$welcome$morning$todayBudget$ja extends Translations$chat$welcome$morning$todayBudget$zh {
	_Translations$chat$welcome$morning$todayBudget$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '今日の予算';
	@override String get prompt => '今日の残予算を確認';
	@override String get description => '一日の支出限度を計画';
}

// Path: chat.welcome.midday.lunch
class _Translations$chat$welcome$midday$lunch$ja extends Translations$chat$welcome$midday$lunch$zh {
	_Translations$chat$welcome$midday$lunch$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'ランチ記録';
	@override String get prompt => 'ランチ代を記録';
	@override String get description => '昼食の支出を記録';
}

// Path: chat.welcome.midday.weeklyExpense
class _Translations$chat$welcome$midday$weeklyExpense$ja extends Translations$chat$welcome$midday$weeklyExpense$zh {
	_Translations$chat$welcome$midday$weeklyExpense$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '今週の支出';
	@override String get prompt => '今週の支出を分析';
	@override String get description => '今週使った金額を確認';
}

// Path: chat.welcome.midday.checkBalance
class _Translations$chat$welcome$midday$checkBalance$ja extends Translations$chat$welcome$midday$checkBalance$zh {
	_Translations$chat$welcome$midday$checkBalance$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '残高確認';
	@override String get prompt => '口座残高を確認';
	@override String get description => '各口座の残高を確認';
}

// Path: chat.welcome.afternoon.quickRecord
class _Translations$chat$welcome$afternoon$quickRecord$ja extends Translations$chat$welcome$afternoon$quickRecord$zh {
	_Translations$chat$welcome$afternoon$quickRecord$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'クイック記録';
	@override String get prompt => '支出の記録を手伝って';
	@override String get description => '支出をすばやく記録';
}

// Path: chat.welcome.afternoon.analyzeSpending
class _Translations$chat$welcome$afternoon$analyzeSpending$ja extends Translations$chat$welcome$afternoon$analyzeSpending$zh {
	_Translations$chat$welcome$afternoon$analyzeSpending$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '支出分析';
	@override String get prompt => '今月の支出を分析';
	@override String get description => '支出の傾向と内訳を確認';
}

// Path: chat.welcome.afternoon.budgetProgress
class _Translations$chat$welcome$afternoon$budgetProgress$ja extends Translations$chat$welcome$afternoon$budgetProgress$zh {
	_Translations$chat$welcome$afternoon$budgetProgress$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '家計の健康度';
	@override String get prompt => '財務状況を診断して';
	@override String get description => '収支バランスとアドバイス';
}

// Path: chat.welcome.evening.dinner
class _Translations$chat$welcome$evening$dinner$ja extends Translations$chat$welcome$evening$dinner$zh {
	_Translations$chat$welcome$evening$dinner$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '夕食記録';
	@override String get prompt => '夕食代を記録';
	@override String get description => '今夜の夕食代を記録';
}

// Path: chat.welcome.evening.todaySummary
class _Translations$chat$welcome$evening$todaySummary$ja extends Translations$chat$welcome$evening$todaySummary$zh {
	_Translations$chat$welcome$evening$todaySummary$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '今日のまとめ';
	@override String get prompt => '今日の支出をまとめて';
	@override String get description => '今日いくら使ったか確認';
}

// Path: chat.welcome.evening.tomorrowPlan
class _Translations$chat$welcome$evening$tomorrowPlan$ja extends Translations$chat$welcome$evening$tomorrowPlan$zh {
	_Translations$chat$welcome$evening$tomorrowPlan$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '明日の予定';
	@override String get prompt => '明日の固定出費を確認';
	@override String get description => '明日の支出を事前に計画';
}

// Path: chat.welcome.night.makeupRecord
class _Translations$chat$welcome$night$makeupRecord$ja extends Translations$chat$welcome$night$makeupRecord$zh {
	_Translations$chat$welcome$night$makeupRecord$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '今日の記入漏れ';
	@override String get prompt => '今日の記入漏れを記録';
	@override String get description => 'つけ忘れた支出を補完';
}

// Path: chat.welcome.night.monthlyReview
class _Translations$chat$welcome$night$monthlyReview$ja extends Translations$chat$welcome$night$monthlyReview$zh {
	_Translations$chat$welcome$night$monthlyReview$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '今月の振り返り';
	@override String get prompt => '今月の支出を詳しく分析';
	@override String get description => '今月何にお金を使ったか確認';
}

// Path: chat.welcome.night.financialThinking
class _Translations$chat$welcome$night$financialThinking$ja extends Translations$chat$welcome$night$financialThinking$zh {
	_Translations$chat$welcome$night$financialThinking$ja._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '将来の予測';
	@override String get prompt => '今後30日間の残高を予測';
	@override String get description => '将来の財務トレンドを予測';
}

/// The flat map containing all translations for locale <ja>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsJa {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.loading' => '読み込み中...',
			'common.error' => 'エラー',
			'common.retry' => '再試行',
			'common.cancel' => 'キャンセル',
			'common.confirm' => '確認',
			'common.save' => '保存',
			'common.delete' => '削除',
			'common.edit' => '編集',
			'common.add' => '追加',
			'common.search' => '検索',
			'common.filter' => 'フィルター',
			'common.sort' => '並べ替え',
			'common.refresh' => '更新',
			'common.more' => 'もっと見る',
			'common.less' => 'たたむ',
			'common.all' => 'すべて',
			'common.none' => 'なし',
			'common.ok' => 'OK',
			'common.unknown' => '不明',
			'common.noData' => 'データなし',
			'common.loadMore' => 'さらに読み込む',
			'common.noMore' => 'これ以上ありません',
			'common.loadFailed' => '読み込み失敗',
			'common.history' => '履歴',
			'common.reset' => 'リセット',
			'common.cancelled' => 'キャンセル済み',
			'common.saving' => '保存中...',
			'common.saveFailed' => '保存に失敗しました',
			'genui.errorBusy' => '申し訳ございません。サービスが一時的に混雑しています。後ほどお試しください',
			'genui.errorTimeout' => 'リクエストがタイムアウトしました。ネットワークを確認して再試行してください',
			'genui.errorNetwork' => 'ネットワーク接続に問題があります。確認して再試行してください',
			'genui.errorSessionExpired' => 'セッションが期限切れです。再度ログインしてください',
			'genui.errorGeneric' => '問題が発生しました。後ほどお試しください',
			'time.today' => '今日',
			'time.yesterday' => '昨日',
			'time.dayBeforeYesterday' => '一昨日',
			'time.thisWeek' => '今週',
			'time.thisMonth' => '今月',
			'time.thisYear' => '今年',
			'time.selectDate' => '日付を選択',
			'time.selectTime' => '時間を選択',
			'time.justNow' => 'たった今',
			'time.minutesAgo' => ({required Object count}) => '${count}分前',
			'time.hoursAgo' => ({required Object count}) => '${count}時間前',
			'time.daysAgo' => ({required Object count}) => '${count}日前',
			'time.weeksAgo' => ({required Object count}) => '${count}週間前',
			'time.monthsAgo' => ({required Object count}) => '${count}ヶ月前',
			'time.yearsAgo' => ({required Object count}) => '${count}年前',
			'greeting.morning' => 'おはようございます',
			'greeting.afternoon' => 'こんにちは',
			'greeting.evening' => 'こんばんは',
			'navigation.home' => 'ホーム',
			'navigation.budget' => '予算',
			'navigation.chat' => 'AI チャット',
			'navigation.statistics' => '統計',
			'navigation.forecast' => '予測',
			'navigation.footprint' => 'フットプリント',
			'navigation.profile' => 'マイページ',
			'auth.login' => 'ログイン',
			'auth.loggingIn' => 'ログイン中...',
			'auth.logout' => 'ログアウト',
			'auth.register' => '新規登録',
			'auth.registering' => '登録中...',
			'auth.welcomeBack' => 'おかえりなさい',
			'auth.loginSuccess' => 'おかえりなさい！',
			'auth.loginFailed' => 'ログイン失敗',
			'auth.pleaseTryAgain' => '後ほど再試行してください。',
			'auth.loginSubtitle' => 'AI家計簿アシスタントを利用するにはログインしてください',
			'auth.noAccount' => 'アカウントをお持ちでないですか？ 登録',
			'auth.createAccount' => 'アカウントを作成',
			'auth.setPassword' => 'パスワード設定',
			'auth.setAccountPassword' => 'アカウントのパスワードを設定してください',
			'auth.completeRegistration' => '登録完了',
			'auth.registrationSuccess' => '登録が完了しました！',
			'auth.registrationFailed' => '登録失敗',
			'auth.email.label' => 'メールアドレス',
			'auth.email.placeholder' => 'メールアドレスを入力してください',
			'auth.email.required' => 'メールアドレスは必須です',
			'auth.email.invalid' => '有効なメールアドレスを入力してください',
			'auth.password.label' => 'パスワード',
			'auth.password.placeholder' => 'パスワードを入力してください',
			'auth.password.required' => 'パスワードは必須です',
			'auth.password.tooShort' => 'パスワードは6文字以上で入力してください',
			'auth.password.mustContainNumbersAndLetters' => 'パスワードは英数字を含める必要があります',
			'auth.password.confirm' => 'パスワード確認',
			'auth.password.confirmPlaceholder' => 'もう一度パスワードを入力してください',
			'auth.password.mismatch' => 'パスワードが一致しません',
			'auth.verificationCode.label' => '認証コード',
			'auth.verificationCode.get' => 'コードを取得',
			'auth.verificationCode.sending' => '送信中...',
			'auth.verificationCode.sent' => '認証コードを送信しました',
			'auth.verificationCode.sendFailed' => '送信失敗',
			'auth.verificationCode.placeholder' => '認証コードを入力',
			'auth.verificationCode.required' => '認証コードは必須です',
			'auth.logoutSuccess' => 'Logged out successfully',
			'auth.confirmLogoutTitle' => 'Confirm Logout',
			'auth.confirmLogoutContent' => 'Are you sure you want to log out?',
			'auth.logoutFailedTitle' => 'ログアウト失敗',
			'transaction.expense' => '支出',
			'transaction.income' => '収入',
			'transaction.transfer' => '振替',
			'transaction.amount' => '金額',
			'transaction.category' => 'カテゴリー',
			'transaction.description' => 'メモ',
			'transaction.tags' => 'タグ',
			'transaction.saveTransaction' => '記録を保存',
			'transaction.pleaseEnterAmount' => '金額を入力してください',
			'transaction.pleaseSelectCategory' => 'カテゴリーを選択してください',
			'transaction.saveFailed' => '保存に失敗しました',
			'transaction.descriptionHint' => '取引の詳細を記録...',
			'transaction.addCustomTag' => 'カスタムタグを追加',
			'transaction.commonTags' => 'よく使うタグ',
			'transaction.maxTagsHint' => ({required Object maxTags}) => 'タグは最大 ${maxTags} 個までです',
			'transaction.noTransactionsFound' => '取引履歴が見つかりません',
			'transaction.tryAdjustingSearch' => '検索条件を調整するか、新しい取引を作成してください',
			'transaction.noDescription' => 'メモなし',
			'transaction.payment' => '支払い',
			'transaction.account' => '口座',
			'transaction.time' => '時間',
			'transaction.location' => '場所',
			'transaction.transactionDetail' => '取引詳細',
			'transaction.favorite' => 'お気に入り',
			'transaction.confirmDelete' => '削除の確認',
			'transaction.deleteTransactionConfirm' => 'この取引記録を削除してもよろしいですか？この操作は取り消せません。',
			'transaction.noActions' => '利用可能なアクションはありません',
			'transaction.deleted' => '削除済み',
			'transaction.deleteFailed' => '削除に失敗しました。後ほど再試行してください。',
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
			'transaction.notFoundTitle' => '取引が削除されました',
			'transaction.notFoundBody' => 'この取引は作成者または管理者によって削除されたため、詳細を表示できません。',
			'transaction.backToPrevious' => '戻る',
			'home.totalExpense' => '総支出額',
			'home.todayExpense' => '今日の支出',
			'home.monthExpense' => '今月の支出',
			'home.yearProgress' => ({required Object year}) => '${year}年の進捗',
			'home.yearRemainingInfo' => ({required Object days, required Object percent}) => '残り ${days} 日 · ${percent}%',
			'home.amountHidden' => '••••••••',
			'home.loadFailed' => '読み込み失敗',
			'home.noTransactions' => '取引履歴なし',
			'home.tryRefresh' => '更新してください',
			'home.noMoreData' => 'これ以上のデータはありません',
			'home.userNotLoggedIn' => 'ユーザーがログインしていないため、データを読み込めません',
			'comment.error' => 'エラー',
			'comment.commentFailed' => 'コメントに失敗しました',
			'comment.replyToPrefix' => ({required Object name}) => '@${name} さんに返信:',
			'comment.reply' => '返信',
			'comment.contentRequired' => 'コメント内容を入力してください',
			'comment.copyContent' => '内容をコピー',
			'comment.contentCopied' => 'コメント内容をコピーしました',
			'comment.collapseReplies' => '返信を折りたたむ',
			'comment.expandMoreReplies' => ({required Object count}) => 'さらに返信 ${count} 件を表示',
			'comment.recordedBy' => '記録者',
			'comment.addNote' => '備考を追加...',
			'comment.confirmDeleteTitle' => '削除の確認',
			'comment.confirmDeleteContent' => 'このコメントを削除してもよろしいですか？この操作は取り消せません。',
			'comment.success' => '成功',
			'comment.commentDeleted' => 'コメントを削除しました',
			'comment.deleteFailed' => '削除失敗',
			'comment.deleteComment' => 'コメント削除',
			'comment.hint' => 'ヒント',
			'comment.noActions' => '利用可能なアクションはありません',
			'comment.note' => '備考',
			'comment.noNote' => '備考なし',
			'comment.loadFailed' => '備考の読み込みに失敗しました',
			'comment.userToast' => ({required Object username}) => 'ユーザー @${username}',
			'calendar.title' => '家計カレンダー',
			'calendar.weekdays.mon' => '月',
			'calendar.weekdays.tue' => '火',
			'calendar.weekdays.wed' => '水',
			'calendar.weekdays.thu' => '木',
			'calendar.weekdays.fri' => '金',
			'calendar.weekdays.sat' => '土',
			'calendar.weekdays.sun' => '日',
			'calendar.loadFailed' => 'カレンダーデータの読み込みに失敗しました',
			'calendar.thisMonth' => ({required Object amount}) => '今月: ${amount}',
			'calendar.counting' => '集計中...',
			'calendar.unableToCount' => '集計不可',
			'calendar.trend' => '傾向: ',
			'calendar.noTransactionsTitle' => 'この日の取引はありません',
			'calendar.loadTransactionFailed' => '取引の読み込みに失敗しました',
			'category.dailyConsumption' => '生活費',
			'category.transportation' => '交通費',
			'category.healthcare' => '医療・健康',
			'category.housing' => '住居費',
			'category.education' => '教育・学習',
			'category.incomeCategory' => '収入',
			'category.socialGifts' => '交際・贈り物',
			'category.moneyTransfer' => '資金移動',
			'category.other' => 'その他',
			'category.foodDining' => '食費・外食',
			'category.shoppingRetail' => '買い物',
			'category.housingUtilities' => '住居・光熱費',
			'category.personalCare' => '美容・ケア',
			'category.entertainment' => '娯楽・レジャー',
			'category.medicalHealth' => '医療費',
			'category.insurance' => '保険',
			'category.socialGifting' => '冠婚葬祭',
			'category.financialTax' => '金融・税金',
			'category.others' => 'その他支出',
			'category.salaryWage' => '給与・報酬',
			'category.businessTrade' => '事業収入',
			'category.investmentReturns' => '投資収益',
			'category.giftBonus' => 'お祝い・ボーナス',
			'category.refundRebate' => '還付・ポイント',
			'category.generalTransfer' => '振替',
			'category.debtRepayment' => '債務返済',
			'settings.title' => '設定',
			'settings.editProfile' => 'プロフィールを編集',
			'settings.saveProfile' => 'プロフィールを保存',
			'settings.profileHelpHint' => 'プロフィールは共有スペースであなたを識別するのに役立ちます。',
			'settings.enterUsernameHint' => 'ユーザー名を入力してください',
			'settings.groupPreferences' => '環境設定と記録',
			'settings.groupServices' => '共有とサービス',
			'settings.groupSystem' => 'システムと外観',
			'settings.language' => '言語',
			'settings.languageSettings' => '言語設定',
			'settings.selectLanguage' => '言語を選択',
			'settings.languageChanged' => '言語を変更しました',
			'settings.restartToApply' => '変更を適用するにはアプリを再起動してください',
			'settings.theme' => 'テーマ',
			'settings.darkMode' => 'ダークモード',
			'settings.lightMode' => 'ライトモード',
			'settings.systemMode' => 'システムに従う',
			'settings.developerOptions' => '開発者オプション',
			'settings.authDebug' => '認証デバッグ',
			'settings.authDebugSubtitle' => '認証ステータスとデバッグ情報を確認',
			'settings.fontTest' => 'フォントテスト',
			'settings.fontTestSubtitle' => 'フォントの表示効果をテスト',
			'settings.helpAndFeedback' => 'ヘルプとフィードバック',
			'settings.helpAndFeedbackSubtitle' => 'ヘルプの参照またはフィードバック送信',
			'settings.aboutApp' => 'アプリについて',
			'settings.aboutAppSubtitle' => 'バージョン情報とアップデート確認',
			'settings.checkUpdate' => 'アップデートを確認',
			'settings.checkingUpdate' => 'アップデートを確認中...',
			'settings.latestVersionToast' => '最新バージョンを使用中です',
			'settings.newVersionTitle' => '新しいバージョンがあります',
			'settings.currentVersion' => ({required Object version}) => '現在のバージョン: v${version}',
			'settings.updateNow' => '今すぐアップデート',
			'settings.updateLater' => '後で',
			'settings.fetchUpdateFailed' => 'アップデートの確認に失敗しました',
			'settings.currencyChangedRefreshHint' => ({required Object currency}) => '${currency} に切り替えました。主要通貨および既定の通貨として設定されました',
			'settings.sharedSpace' => '共有スペース',
			'settings.speechRecognition' => '音声認識',
			'settings.speechRecognitionSubtitle' => '音声入力パラメータを設定',
			'settings.amountDisplayStyle' => '金額表示スタイル',
			'settings.currency' => '表示通貨',
			'settings.appearance' => '外観設定',
			'settings.appearanceSubtitle' => 'テーマモードと配色',
			'settings.speechTest' => '音声テスト',
			'settings.speechTestSubtitle' => 'WebSocket音声接続をテスト',
			'settings.userTypeRegular' => '一般ユーザー',
			'settings.selectAmountStyle' => '金額表示スタイルを選択',
			'settings.currencyDescription' => '主要通貨を選択してください。今後の取引はデフォルトでこの通貨になり、統計や集計もこの通貨で表示されます。過去の取引の元金額には影響しません。',
			'settings.amountStyleNotice' => 'Note: Amount styles are primarily applied to \'Transactions\' and \'Trends\'. To maintain visual clarity, \'Account Balances\' and \'Asset Summaries\' will remain in neutral colors.',
			'settings.editUsername' => 'Edit Username',
			'settings.enterUsername' => 'Enter username',
			'settings.usernameRequired' => 'Username is required',
			'settings.usernameUpdated' => 'Username updated',
			'settings.avatarUpdated' => 'Avatar updated',
			'settings.appearanceUpdated' => '外观设置已更新',
			'appearance.title' => '外観設定',
			'appearance.themeMode' => 'テーマモード',
			'appearance.light' => 'ライト',
			'appearance.dark' => 'ダーク',
			'appearance.system' => 'システム',
			'appearance.colorScheme' => '配色',
			'appearance.palettes.zinc' => 'Zinc',
			'appearance.palettes.slate' => 'Slate',
			'appearance.palettes.red' => 'Red',
			'appearance.palettes.rose' => 'Rose',
			'appearance.palettes.orange' => 'Orange',
			'appearance.palettes.green' => 'Green',
			'appearance.palettes.blue' => 'Blue',
			'appearance.palettes.yellow' => 'Yellow',
			'appearance.palettes.violet' => 'Violet',
			'speech.title' => '音声認識設定',
			'speech.service' => '音声認識サービス',
			'speech.systemVoice' => 'システム音声',
			'speech.systemVoiceSubtitle' => 'スマホ内蔵の音声認識サービス（推奨）',
			'speech.selfHostedASR' => '自作 ASR サービス',
			'speech.selfHostedASRSubtitle' => 'WebSocket経由で自作ASRサーバーに接続',
			'speech.serverConfig' => 'サーバー設定',
			'speech.serverAddress' => 'サーバーアドレス',
			'speech.port' => 'ポート',
			'speech.path' => 'パス',
			'speech.saveConfig' => '設定を保存',
			'speech.info' => '情報',
			'speech.infoContent' => '• システム音声：内蔵サービスを使用。設定不要で高速です。\n• 自作 ASR：カスタムモデルやオフライン環境用。\n\n変更は次回の音声入力から有効になります。',
			'speech.enterAddress' => 'サーバーアドレスを入力してください',
			'speech.enterValidPort' => '有効なポート番号(1-65535)を入力してください',
			'speech.configSaved' => '設定を保存しました',
			'speech.configSaveFailed' => '設定の保存に失敗しました',
			'speech.systemVoiceRestrictedTitle' => 'システム音声が利用できません',
			'speech.systemVoiceRestrictedContent' => '端末の音声認識サービスが無効または利用できません。設定を確認するかWebSocket自作ASRを設定してください。',
			'speech.dictationDisabledTitle' => '音声入力（音声入力/音声聞き取り）が無効です',
			'speech.dictationDisabledContent' => 'システム音声入力サービスが有効になっていません。iOS端末の場合、【設定 -> 一般 -> キーボード】から【音声入力を有効にする】をオンにしてください。',
			'speech.permissionDeniedTitle' => '音声権限が必要です',
			'speech.permissionDeniedContent' => 'この機能を使用するにはマイクと音声認識の権限が必要です。システム設定で権限を許可してください。',
			'speech.goToSettings' => '設定へ',
			'speech.systemVoiceStatusAvailable' => 'システム音声認識利用可能',
			'speech.systemVoiceStatusRestricted' => 'システム音声制限あり (自作 ASR 推奨)',
			'speech.serviceNotConfigured' => '音声サービスが設定されていません。音声設定でサーバーアドレスを設定してください。',
			'speech.connectionFailedTitle' => '音声サービス接続失敗',
			'speech.connectionFailed' => 'WebSocket音声認識サービスに接続できません。サーバーアドレス、ポート、またはネットワーク接続を確認してください。',
			'speech.noSpeechRecognized' => '音声入力が検出されませんでした。もう一度お試しください。',
			'amountTheme.chinaMarket' => '中国市場慣習',
			'amountTheme.chinaMarketDesc' => '赤上昇/緑下落（推奨）',
			'amountTheme.international' => '国際標準',
			'amountTheme.internationalDesc' => '緑上昇/赤下落',
			'amountTheme.minimalist' => 'ミニマリスト',
			'amountTheme.minimalistDesc' => 'モノクロ表示、+/- 記号のみで区別',
			'amountTheme.colorBlind' => '色覚サポート',
			'amountTheme.colorBlindDesc' => '青・オレンジ配色',
			'locale.chinese' => '簡体字中国語',
			'locale.english' => 'English',
			'locale.japanese' => '日本語',
			'locale.korean' => '한국어',
			'locale.traditionalChinese' => '繁体字中国語',
			'budget.title' => '予算管理',
			'budget.detail' => '予算詳細',
			'budget.info' => '予算情報',
			'budget.totalBudget' => '総予算',
			'budget.categoryBudget' => 'カテゴリー別予算',
			'budget.monthlySummary' => '今月の予算サマリー',
			'budget.used' => '使用済み',
			'budget.remaining' => '残り',
			'budget.overspent' => '予算超過',
			'budget.budget' => '予算',
			'budget.loadFailed' => '読み込み失敗',
			'budget.noBudget' => '予算未設定',
			'budget.createHint' => '下のボタンをタップして予算を設定しましょう',
			'budget.paused' => '一時停止中',
			'budget.pause' => '停止',
			'budget.resume' => '再開',
			'budget.budgetPaused' => '予算管理を停止しました',
			'budget.budgetResumed' => '予算管理を再開しました',
			'budget.operationFailed' => '操作に失敗しました',
			'budget.deleteBudget' => '予算を削除',
			'budget.deleteConfirm' => 'この予算を削除してもよろしいですか？取り消せません。',
			'budget.type' => 'タイプ',
			'budget.category' => 'カテゴリー',
			'budget.period' => '周期',
			'budget.rollover' => '予算繰越',
			'budget.rolloverBalance' => '繰越残高',
			'budget.enabled' => '有効',
			'budget.disabled' => '無効',
			'budget.statusNormal' => '予算内',
			'budget.statusWarning' => '上限接近',
			'budget.statusOverspent' => '超過',
			'budget.statusAchieved' => '目標達成',
			'budget.tipNormal' => ({required Object amount}) => '残り ${amount} 利用可能',
			'budget.tipWarning' => ({required Object amount}) => '残り ${amount} です。ご注意ください',
			'budget.tipOverspent' => ({required Object amount}) => '${amount} 超過しています',
			'budget.tipAchieved' => '貯金目標達成おめでとうございます！',
			'budget.remainingAmount' => ({required Object amount}) => '残り ${amount}',
			'budget.overspentAmount' => ({required Object amount}) => '超過 ${amount}',
			'budget.budgetAmount' => ({required Object amount}) => '予算 ${amount}',
			'budget.active' => '有効',
			'budget.all' => 'すべて',
			'budget.notFound' => '予算が存在しないか削除されました',
			'budget.setup' => '予算設定',
			'budget.settings' => '予算設定',
			'budget.setAmount' => '予算額を設定',
			'budget.setAmountDesc' => '各カテゴリーの予算額を設定',
			'budget.monthly' => '月次予算',
			'budget.monthlyDesc' => '月単位で支出を管理します（推奨）',
			'budget.weekly' => '週次予算',
			'budget.weeklyDesc' => '週単位で細かく管理します',
			'budget.yearly' => '年次予算',
			'budget.yearlyDesc' => '長期的な計画や大きな支出用',
			'budget.editBudget' => '予算を編集',
			'budget.editBudgetDesc' => '予算額やカテゴリーを変更',
			'budget.reminderSettings' => '通知設定',
			'budget.reminderSettingsDesc' => '予算通知やリマインダーを設定',
			'budget.report' => '予算レポート',
			'budget.reportDesc' => '詳細な予算分析レポートを表示',
			'budget.welcome' => '予算機能へようこそ！',
			'budget.createNewPlan' => '新しい予算プランを作成',
			'budget.welcomeDesc' => '予算を設定することで、支出をコントロールし財務目標を達成できます。',
			'budget.createDesc' => 'カテゴリー別の予算上限を設定して、家計管理をサポートします。',
			'budget.newBudget' => '新規予算',
			'budget.budgetAmountLabel' => '予算額',
			'budget.currency' => '通貨',
			'budget.periodSettings' => '期間設定',
			'budget.autoGenerateTransactions' => '有効にするとルールに従い自動記帳します',
			'budget.cycle' => 'サイクル',
			'budget.budgetCategory' => '予算カテゴリー',
			'budget.advancedOptions' => '詳細オプション',
			'budget.periodType' => '期間タイプ',
			'budget.anchorDay' => '開始日',
			'budget.selectPeriodType' => '期間タイプを選択',
			'budget.selectAnchorDay' => '開始日を選択',
			'budget.rolloverDescription' => '未使用分を翌期に繰り越す',
			'budget.createBudget' => '予算を作成',
			'budget.save' => '保存',
			'budget.pleaseEnterAmount' => '予算額を入力してください',
			'budget.invalidAmount' => '有効な金額を入力してください',
			'budget.updateSuccess' => '予算を更新しました',
			'budget.createSuccess' => '予算を作成しました',
			'budget.deleteSuccess' => '予算を削除しました',
			'budget.deleteFailed' => '削除に失敗しました',
			'budget.everyMonthDay' => ({required Object day}) => '毎月 ${day} 日',
			'budget.periodWeekly' => '毎週',
			'budget.periodBiweekly' => '2週間ごと',
			'budget.periodMonthly' => '毎月',
			'budget.periodYearly' => '毎年',
			'budget.statusActive' => '進行中',
			'budget.statusArchived' => 'アーカイブ済み',
			'budget.periodStatusOnTrack' => '順調',
			'budget.periodStatusWarning' => '警告',
			'budget.periodStatusExceeded' => '超過',
			'budget.periodStatusAchieved' => '達成',
			'budget.usedPercent' => ({required Object percent}) => '${percent}% 使用済み',
			'budget.dayOfMonth' => ({required Object day}) => '${day} 日',
			'budget.tenThousandSuffix' => '万',
			'budget.settingsLoadFailed' => '設定の読み込みに失敗しました',
			'budget.settingsSaveSuccess' => '設定を保存しました',
			'budget.settingsSaveFailed' => '保存に失敗しました',
			'budget.settingsSave' => '設定を保存',
			'budget.settingsWarningThreshold' => '警告閾値',
			'budget.settingsWarningDesc' => '使用率がこの割合に達すると警告状態を表示',
			'budget.settingsAlertThreshold' => '超過閾値',
			'budget.settingsAlertDesc' => '使用率がこの割合に達すると超過状態を表示',
			'budget.settingsThresholdOrder' => '警告閾値は超過閾値を超えられません',
			'dateRange.custom' => 'カスタム',
			'dateRange.pickerTitle' => '期間を選択',
			'dateRange.startDate' => '開始日',
			'dateRange.endDate' => '終了日',
			'dateRange.hint' => '日付範囲を選択してください',
			'forecast.title' => '予測',
			'forecast.subtitle' => 'データに基づき将来のキャッシュフローを予測します',
			'forecast.financialNavigator' => 'こんにちは、あなたの財務ナビゲーターです',
			'forecast.financialMapSubtitle' => '3ステップで、あなたの将来の財務マップを一緒に作成しましょう',
			'forecast.predictCashFlow' => '将来のキャッシュフローを予測',
			'forecast.predictCashFlowDesc' => '日々の財務状況を可視化',
			'forecast.aiSmartSuggestions' => 'AIスマートアドバイス',
			'forecast.aiSmartSuggestionsDesc' => 'パーソナライズされた財務ガイダンス',
			'forecast.riskWarning' => 'リスク警告',
			'forecast.riskWarningDesc' => '潜在的なリスクを事前に察知',
			'forecast.analyzing' => '財務データを分析し、今後30日間の予測を生成しています',
			'forecast.analyzePattern' => '収支パターンの分析',
			'forecast.calculateTrend' => 'トレンドの計算',
			'forecast.generateWarning' => 'リスク警告の生成',
			'forecast.loadingForecast' => '予測を読み込み中...',
			'forecast.todayLabel' => '今日',
			'forecast.tomorrowLabel' => '明日',
			'forecast.balanceLabel' => '残高',
			'forecast.noSpecialEvents' => '特別なイベントはありません',
			'forecast.financialSafetyLine' => 'セーフティライン',
			'forecast.currentSetting' => '現在の設定',
			'forecast.dailySpendingEstimate' => '1日の支出見積もり',
			'forecast.adjustDailySpendingAmount' => '予測金額を調整',
			'forecast.tellMeYourSafetyLine' => 'あなたの「安心できる最低残高」はいくらですか？',
			'forecast.safetyLineDescription' => '口座に維持したい最低額です。この額に近づくと警告します。',
			'forecast.dailySpendingQuestion' => '1日の生活費はいくらくらいですか？',
			'forecast.dailySpendingDescription' => '食費、交通費、買い物など。今後の記録から予測精度を向上させます。',
			'forecast.perDay' => '1日あたり',
			'forecast.referenceStandard' => '参考基準',
			'forecast.frugalType' => '節約型',
			'forecast.comfortableType' => '標準型',
			'forecast.relaxedType' => 'ゆとり型',
			'forecast.frugalAmount' => '1,000円-2,000円/日',
			'forecast.comfortableAmount' => '2,000円-4,000円/日',
			'forecast.relaxedAmount' => '4,000円-6,000円/日',
			'forecast.recurringTransaction.title' => '繰り返し取引',
			'forecast.recurringTransaction.all' => 'すべて',
			'forecast.recurringTransaction.expense' => '支出',
			'forecast.recurringTransaction.income' => '収入',
			'forecast.recurringTransaction.transfer' => '振替',
			'forecast.recurringTransaction.noRecurring' => '繰り返し取引なし',
			'forecast.recurringTransaction.createHint' => '設定すると、システムが自動で取引を記録します',
			'forecast.recurringTransaction.create' => '繰り返し取引を作成',
			'forecast.recurringTransaction.edit' => '繰り返し取引を編集',
			'forecast.recurringTransaction.newTransaction' => '新規繰り返し取引',
			'forecast.recurringTransaction.deleteConfirm' => ({required Object name}) => '繰り返し取引「${name}」を削除しますか？',
			'forecast.recurringTransaction.activateConfirm' => ({required Object name}) => '「${name}」を有効にしますか？自動記帳が始まります。',
			'forecast.recurringTransaction.pauseConfirm' => ({required Object name}) => '「${name}」を一時停止しますか？',
			'forecast.recurringTransaction.created' => '作成しました',
			'forecast.recurringTransaction.updated' => '更新しました',
			'forecast.recurringTransaction.activated' => '有効化',
			'forecast.recurringTransaction.paused' => '停止中',
			'forecast.recurringTransaction.nextTime' => '次回',
			'forecast.recurringTransaction.sortByTime' => '時間順',
			'forecast.recurringTransaction.allPeriod' => 'すべての周期',
			'forecast.recurringTransaction.periodCount' => ({required Object type, required Object count}) => '${type} (${count} 件)',
			'forecast.recurringTransaction.confirmDelete' => '削除確認',
			'forecast.recurringTransaction.confirmActivate' => '有効化確認',
			'forecast.recurringTransaction.confirmPause' => '停止確認',
			'forecast.recurringTransaction.dynamicAmount' => '動態平均',
			'forecast.recurringTransaction.dynamicAmountTitle' => '金額の確認が必要',
			'forecast.recurringTransaction.dynamicAmountDescription' => '通知が届いたら金額を確認して記帳を完了させてください。',
			'forecast.recurringTransaction.confirmBeforeGeneration' => '生成前に確認',
			'forecast.recurringTransaction.confirmBeforeGenerationDesc' => '期限日に確認待ち取引を生成、手動確認後に記帳',
			'forecast.recurringTransaction.pendingTitle' => '確認待ち取引',
			'forecast.recurringTransaction.pendingCount' => ({required Object count}) => '${count} 件確認待ち',
			'forecast.recurringTransaction.confirm' => '確認',
			'forecast.recurringTransaction.skip' => 'スキップ',
			'forecast.recurringTransaction.noPending' => '確認待ち取引なし',
			'forecast.recurringTransaction.confirmSuccess' => '取引を確認しました',
			_ => null,
		} ?? switch (path) {
			'forecast.recurringTransaction.skipSuccess' => '取引をスキップしました',
			'forecast.recurringTransaction.interval' => '繰り返し間隔',
			'forecast.recurringTransaction.selectDays' => '曜日を選択',
			'forecast.recurringTransaction.alwaysLastDay' => '毎月末日に実行',
			'forecast.recurringTransaction.lastDayExecution' => '毎月の最終日に実行されます',
			'forecast.recurringTransaction.dayExecution' => ({required Object day, required Object suffix}) => '毎月 ${day} 日${suffix}に実行（短い月は月末に合わせます）',
			'forecast.recurringTransaction.setEndDate' => '終了日を設定',
			'forecast.recurringTransaction.selectEndDate' => '終了日を選択',
			'forecast.recurringTransaction.preview' => 'ルールプレビュー',
			'forecast.recurringTransaction.daily' => '毎日',
			'forecast.recurringTransaction.weekly' => '毎週',
			'forecast.recurringTransaction.monthly' => '毎月',
			'forecast.recurringTransaction.yearly' => '毎年',
			'forecast.recurringTransaction.custom' => 'カスタム',
			'forecast.recurringTransaction.cycle' => 'サイクル',
			'forecast.recurringTransaction.everyDays' => ({required Object count}) => '${count} 日ごと',
			'forecast.recurringTransaction.everyWeeks' => ({required Object count}) => '${count} 週ごと',
			'forecast.recurringTransaction.everyMonths' => ({required Object count}) => '${count} か月ごと',
			'forecast.recurringTransaction.everyYears' => ({required Object count}) => '${count} 年ごと',
			'forecast.recurringTransaction.monthlyOnDay' => ({required Object day, required Object suffix}) => '毎月 ${day} 日${suffix}',
			'forecast.recurringTransaction.everyMonthsOnDay' => ({required Object count, required Object day, required Object suffix}) => '${count} か月ごとの ${day} 日${suffix}',
			'forecast.recurringTransaction.monthlyLastDay' => '毎月最終日',
			'forecast.recurringTransaction.everyMonthsLastDay' => ({required Object count}) => '${count} か月ごとの最終日',
			'forecast.recurringTransaction.yearlyOn' => ({required Object month, required Object day}) => '毎年 ${month}/${day}',
			'forecast.recurringTransaction.everyYearsOn' => ({required Object count, required Object month, required Object day}) => '${count} 年ごとの ${month}/${day}',
			'forecast.recurringTransaction.weeklyOnDay' => ({required Object day}) => '毎週${day}',
			'forecast.recurringTransaction.weekdayMon' => '月',
			'forecast.recurringTransaction.weekdayTue' => '火',
			'forecast.recurringTransaction.weekdayWed' => '水',
			'forecast.recurringTransaction.weekdayThu' => '木',
			'forecast.recurringTransaction.weekdayFri' => '金',
			'forecast.recurringTransaction.weekdaySat' => '土',
			'forecast.recurringTransaction.weekdaySun' => '日',
			'forecast.recurringTransaction.weekdayOn' => '曜日',
			'forecast.recurringTransaction.weekdayJoiner' => '、',
			'forecast.recurringTransaction.weeklyDaysPrefix' => 'の',
			'forecast.recurringTransaction.sourceAccount' => '振替元口座',
			'forecast.recurringTransaction.targetAccount' => '振替先口座',
			'forecast.recurringTransaction.expenseAccount' => '支出口座',
			'forecast.recurringTransaction.incomeAccount' => '収入口座',
			'forecast.recurringTransaction.selectSourceAccount' => '振替元口座を選択',
			'forecast.recurringTransaction.selectTargetAccount' => '振替先口座を選択',
			'forecast.recurringTransaction.selectExpenseAccount' => '支出口座を選択',
			'forecast.recurringTransaction.selectIncomeAccount' => '収入口座を選択',
			'forecast.recurringTransaction.amountNotFixed' => ({required Object type}) => '${type}ごとの金額は固定されません',
			'forecast.recurringTransaction.selectBothAccounts' => '振替元と振替先の口座を選択してください',
			'forecast.recurringTransaction.sameAccount' => '振替元と振替先の口座は同じにできません',
			'forecast.recurringTransaction.endBeforeStart' => '終了日は開始日より前には設定できません',
			'forecast.recurringTransaction.selectAccountForType' => ({required Object type}) => '${type}口座を選択してください',
			'forecast.recurringTransaction.deleteConfirmGeneric' => 'この定期取引を削除してもよろしいですか？この操作は取り消せません。',
			'forecast.recurringTransaction.selectDate' => ({required Object date}) => '${date} を選択',
			'forecast.recurringTransaction.accountTypeCash' => '現金',
			'forecast.recurringTransaction.accountTypeDeposit' => '銀行預金',
			'forecast.recurringTransaction.accountTypeEMoney' => '電子マネー',
			'forecast.recurringTransaction.accountTypeInvestment' => '投資',
			'forecast.recurringTransaction.accountTypeReceivable' => '売掛金',
			'forecast.recurringTransaction.accountTypeCreditCard' => 'クレジットカード',
			'forecast.recurringTransaction.accountTypeLoan' => 'ローン口座',
			'forecast.recurringTransaction.accountTypePayable' => '買掛金',
			'forecast.recurringTransaction.assetAccount' => '資産口座',
			'forecast.recurringTransaction.liabilityAccount' => '負債口座',
			'forecast.recurringTransaction.noAssetAccounts' => '資産口座がありません',
			'forecast.recurringTransaction.goToFinanceToAddAccounts' => '財務ページで口座を追加してください',
			'forecast.recurringTransaction.selectAccount' => '口座を選択',
			'forecast.recurringTransaction.autoGenerateByRule' => '有効にするとルールに従って取引を自動生成',
			'forecast.recurringTransaction.dayUnit' => ({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ja'))(count, one: '日', other: '日', ),
			'forecast.recurringTransaction.weekUnit' => ({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ja'))(count, one: '週間', other: '週間', ),
			'forecast.recurringTransaction.monthUnit' => ({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ja'))(count, one: 'か月', other: 'か月', ),
			'forecast.recurringTransaction.yearUnit' => ({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ja'))(count, one: '年', other: '年', ),
			'chat.newChat' => '新しいチャット',
			'chat.noMessages' => 'メッセージがありません。',
			'chat.loadingFailed' => '読み込み失敗',
			'chat.inputMessage' => 'メッセージを入力...',
			'chat.listening' => '聞き取り中...',
			'chat.aiThinking' => '処理中...',
			'chat.stoppedResponse' => 'この返信を停止しました',
			'chat.errorRecover' => '申し訳ありません、問題が発生しました。もう一度お試しください 🙏',
			'chat.contentCopied' => '内容をコピーしました',
			'chat.jsonCopied' => 'JSONデータをコピーしました',
			'chat.noContentToCopy' => 'コピーする内容がありません',
			'chat.tools.processing' => '処理中...',
			'chat.tools.readFile' => 'ファイルを確認中...',
			'chat.tools.searchTransactions' => '取引を検索中...',
			'chat.tools.queryBudgetStatus' => '予算を確認中...',
			'chat.tools.createBudget' => '予算プランを作成中...',
			'chat.tools.getCashFlowAnalysis' => 'キャッシュフローを分析中...',
			'chat.tools.getFinancialHealthScore' => '財務スコアを計算中...',
			'chat.tools.getFinancialSummary' => 'レポートを生成中...',
			'chat.tools.evaluateFinancialHealth' => '財務状況を評価中...',
			'chat.tools.forecastBalance' => '残高を予測中...',
			'chat.tools.simulateExpenseImpact' => '影響をシミュレーション中...',
			'chat.tools.recordTransactions' => '記帳中...',
			'chat.tools.createTransaction' => '記帳中...',
			'chat.tools.duckduckgoSearch' => 'ウェブを検索中...',
			'chat.tools.executeTransfer' => '振替を実行中...',
			'chat.tools.listDir' => 'ディレクトリを表示中...',
			'chat.tools.execute' => 'スクリプトを実行中...',
			'chat.tools.analyzeFinance' => '財務分析中...',
			'chat.tools.forecastFinance' => 'トレンド予測中...',
			'chat.tools.analyzeBudget' => '予算分析中...',
			'chat.tools.auditAnalysis' => '監査分析中...',
			'chat.tools.budgetOps' => '予算を処理中...',
			'chat.tools.createSharedTransaction' => '共有帳簿を作成中...',
			'chat.tools.listSpaces' => '共有スペースを取得中...',
			'chat.tools.querySpaceSummary' => 'スペース概要を確認中...',
			'chat.tools.prepareTransfer' => '振替を準備中...',
			'chat.tools.unknown' => 'リクエストを処理中...',
			'chat.tools.done.readFile' => 'ファイルを確認しました',
			'chat.tools.done.searchTransactions' => '取引を検索しました',
			'chat.tools.done.queryBudgetStatus' => '予算を確認しました',
			'chat.tools.done.createBudget' => '予算を作成しました',
			'chat.tools.done.getCashFlowAnalysis' => 'キャッシュフローを分析しました',
			'chat.tools.done.getFinancialHealthScore' => 'スコアを計算しました',
			'chat.tools.done.getFinancialSummary' => 'レポート生成完了',
			'chat.tools.done.evaluateFinancialHealth' => '財務評価完了',
			'chat.tools.done.forecastBalance' => '残高予測完了',
			'chat.tools.done.simulateExpenseImpact' => 'シミュレーション完了',
			'chat.tools.done.recordTransactions' => '記帳完了',
			'chat.tools.done.createTransaction' => '記帳しました',
			'chat.tools.done.duckduckgoSearch' => '検索完了',
			'chat.tools.done.executeTransfer' => '振替完了',
			'chat.tools.done.listDir' => 'ディレクトリ表示完了',
			'chat.tools.done.execute' => '実行完了',
			'chat.tools.done.analyzeFinance' => '分析完了',
			'chat.tools.done.forecastFinance' => '予測完了',
			'chat.tools.done.analyzeBudget' => '予算分析完了',
			'chat.tools.done.auditAnalysis' => '監査完了',
			'chat.tools.done.budgetOps' => '予算処理完了',
			'chat.tools.done.createSharedTransaction' => '共有帳簿作成完了',
			'chat.tools.done.listSpaces' => '共有スペース取得完了',
			'chat.tools.done.querySpaceSummary' => '概要確認完了',
			'chat.tools.done.prepareTransfer' => '準備完了',
			'chat.tools.done.unknown' => '完了しました',
			'chat.tools.done.analyzeSpending' => 'Spending analysis complete',
			'chat.tools.done.analyzeCashflow' => 'Cashflow analysis complete',
			'chat.tools.done.suggestBudget' => 'Budget suggestion complete',
			'chat.tools.done.prepareBudgetSimulation' => '予算シミュレーション準備完了',
			'chat.tools.done.simulateBudget' => '予算シミュレーション完了',
			'chat.tools.failed.unknown' => '操作に失敗しました',
			'chat.tools.analyzeSpending' => 'Analyzing spendings...',
			'chat.tools.analyzeCashflow' => 'Analyzing cashflow...',
			'chat.tools.suggestBudget' => 'Suggesting budget...',
			'chat.tools.cancelled' => 'Cancelled',
			'chat.tools.prepareBudgetSimulation' => '予算シミュレーションを準備中',
			'chat.tools.simulateBudget' => '予算をシミュレーション中',
			'chat.speechNotRecognized' => '音声を認識できませんでした',
			'chat.currentExpense' => '今回の支出',
			'chat.loadingComponent' => 'コンポーネントを読み込み中...',
			'chat.noHistory' => '履歴がありません',
			'chat.startNewChat' => '新しい会話を始めましょう！',
			'chat.searchHint' => 'チャットを検索',
			'chat.library' => 'ライブラリ',
			'chat.viewProfile' => 'プロフィールを表示',
			'chat.noRelatedFound' => '関連する会話が見つかりません',
			'chat.tryOtherKeywords' => '他のキーワードで検索してください',
			'chat.searchFailed' => '検索失敗',
			'chat.updatedAt' => ({required Object time}) => '更新日時: ${time}',
			'chat.createdAt' => ({required Object time}) => '作成日時: ${time}',
			'chat.deleteConversation' => 'チャットを削除',
			'chat.deleteConversationConfirm' => 'このチャットを削除してもよろしいですか？この操作は取り消せません。',
			'chat.conversationDeleted' => 'チャットを削除しました',
			'chat.deleteConversationFailed' => 'チャットの削除に失敗しました',
			'chat.transferWizard.title' => '振替ウィザード',
			'chat.transferWizard.amount' => '振替金額',
			'chat.transferWizard.amountHint' => '金額を入力',
			'chat.transferWizard.sourceAccount' => '振替元口座',
			'chat.transferWizard.targetAccount' => '振替先口座',
			'chat.transferWizard.selectAccount' => '口座を選択してください',
			'chat.transferWizard.confirmTransfer' => '振替を確認',
			'chat.transferWizard.confirmed' => '確認済み',
			'chat.transferWizard.transferSuccess' => '振替が完了しました',
			'chat.transferWizard.selectReceiveAccount' => '选择收款账户',
			'chat.transferWizard.noAssetAccounts' => '資産口座がありません',
			'chat.transferWizard.goToFinanceToAddAccounts' => '財務ページで口座を追加してください',
			'chat.transferWizard.needTwoAssetAccounts' => '振替には資産口座が2つ以上必要です',
			'chat.genui.expenseSummary.totalExpense' => '総支出',
			'chat.genui.expenseSummary.mainExpenses' => '主な支出',
			'chat.genui.expenseSummary.viewAll' => ({required Object count}) => '全 ${count} 件を表示',
			'chat.genui.expenseSummary.details' => '詳細',
			'chat.genui.transactionList.searchResults' => ({required Object count}) => '検索結果 (${count})',
			'chat.genui.transactionList.loaded' => ({required Object count}) => '${count} 件読み込み済み',
			'chat.genui.transactionList.noResults' => '結果が見つかりません',
			'chat.genui.transactionList.loadMore' => 'さらに表示',
			'chat.genui.transactionList.allLoaded' => 'すべて読み込みました',
			'chat.genui.transactionGroupReceipt.title' => '記帳成功',
			'chat.genui.transactionGroupReceipt.count' => ({required Object count}) => '${count}件',
			'chat.genui.transactionGroupReceipt.selectAccount' => '口座を関連付け',
			'chat.genui.transactionGroupReceipt.selectAccountSubtitle' => 'この口座をすべての取引に適用します',
			'chat.genui.transactionGroupReceipt.associatedAccount' => ({required Object name}) => '関連付け口座：${name}',
			'chat.genui.transactionGroupReceipt.clickToAssociate' => '口座を関連付ける（一括可）',
			'chat.genui.transactionGroupReceipt.associateSuccess' => '関連付けに成功しました',
			'chat.genui.transactionGroupReceipt.associateFailed' => ({required Object error}) => 'エラー: ${error}',
			'chat.genui.transactionGroupReceipt.accountAssociation' => '口座関連付け',
			'chat.genui.transactionGroupReceipt.sharedSpace' => '共有スペース',
			'chat.genui.transactionGroupReceipt.notAssociated' => '未設定',
			'chat.genui.transactionGroupReceipt.addSpace' => '追加',
			'chat.genui.transactionGroupReceipt.selectSpace' => 'スペースを選択',
			'chat.genui.transactionGroupReceipt.spaceAssociateSuccess' => 'スペースに関連付けました',
			'chat.genui.transactionGroupReceipt.spaceAssociateFailed' => ({required Object error}) => 'スペース関連付け失敗: ${error}',
			'chat.genui.transactionGroupReceipt.currencyMismatchTitle' => '通貨が異なります',
			'chat.genui.transactionGroupReceipt.currencyMismatchDesc' => '取引の通貨と口座の通貨が異なります。口座残高は為替レートで換算されます。',
			'chat.genui.transactionGroupReceipt.transactionAmount' => '取引金額',
			'chat.genui.transactionGroupReceipt.accountCurrency' => '口座通貨',
			'chat.genui.transactionGroupReceipt.targetAccount' => '対象口座',
			'chat.genui.transactionGroupReceipt.currencyMismatchNote' => '注意：為替レートで換算して残高から差し引きます',
			'chat.genui.transactionGroupReceipt.confirmAssociate' => '確認',
			'chat.genui.transactionGroupReceipt.total' => 'Total',
			'chat.genui.transactionGroupReceipt.spaceCount' => ({required Object count}) => '${count} spaces',
			'chat.genui.transactionCard.title' => '取引成功',
			'chat.genui.transactionCard.associatedAccount' => '関連口座',
			'chat.genui.transactionCard.notCounted' => '資産に含めない',
			'chat.genui.transactionCard.modify' => '修正',
			'chat.genui.transactionCard.associate' => '口座を関連付け',
			'chat.genui.transactionCard.selectAccount' => '口座を選択',
			'chat.genui.transactionCard.autoGenerateByRule' => '有効にするとルールに従って取引を自動生成',
			'chat.genui.transactionCard.noAccount' => '口座がありません。追加してください',
			'chat.genui.transactionCard.missingId' => 'IDがありません',
			'chat.genui.transactionCard.associatedTo' => ({required Object name}) => '${name} に関連付け済み',
			'chat.genui.transactionCard.updateFailed' => ({required Object error}) => '更新失敗: ${error}',
			'chat.genui.transactionCard.sharedSpace' => 'Shared Space',
			'chat.genui.transactionCard.noSpace' => 'No shared spaces available',
			'chat.genui.transactionCard.selectSpace' => 'Select Shared Space',
			'chat.genui.transactionCard.linkedToSpace' => 'Linked to shared space',
			'chat.genui.cashFlowCard.title' => 'キャッシュフロー＆健康レポート',
			'chat.genui.cashFlowCard.savingsRate' => ({required Object rate}) => '貯蓄率 ${rate}%',
			'chat.genui.cashFlowCard.totalIncome' => '総収入',
			'chat.genui.cashFlowCard.totalExpense' => '総支出',
			'chat.genui.cashFlowCard.essentialExpense' => '必須支出',
			'chat.genui.cashFlowCard.discretionaryExpense' => '自由裁量支出',
			'chat.genui.cashFlowCard.aiInsight' => 'AI分析',
			'chat.genui.budgetSimulator.title' => '予算ストレステスト',
			'chat.genui.budgetSimulator.targetAmount' => '目標予算額',
			'chat.genui.budgetSimulator.overspendProbability' => '超過確率',
			'chat.genui.budgetSimulator.riskLow' => 'リスク極低',
			'chat.genui.budgetSimulator.riskMedium' => 'リスク中程度',
			'chat.genui.budgetSimulator.riskHigh' => '超過リスク高',
			'chat.genui.budgetSimulator.evaluating' => '消費パターンを分析中...',
			'chat.genui.budgetSimulator.historyAverage' => '過去の月平均',
			'chat.genui.budgetSimulator.dailyAllowance' => '1日あたりの上限',
			'chat.genui.budgetSimulator.cancel' => 'キャンセル',
			'chat.genui.budgetSimulator.confirm' => 'この予算を適用',
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
			'chat.genui.emptyStateAlert.noBudgetsYet' => '予算がありません',
			'chat.genui.emptyStateAlert.noTransactionsYet' => '取引がありません',
			'chat.genui.emptyStateAlert.noAccountsYet' => '口座がありません',
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
			'chat.genui.spaceSelector.associateAction' => '選択したスペースに関連付け',
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
			'chat.genui.transferPath.executeAction' => '選択に従って振替を実行',
			'chat.genui.transactionConfirmation.multipleAccounts' => '检测到多个关联账户',
			'chat.genui.transactionConfirmation.confirmed' => '已确认',
			'chat.genui.budgetAnalysis.title' => '预算分析报告',
			'chat.genui.budgetAnalysis.periodDays' => ({required Object days}) => '过去 ${days} 天',
			'chat.genui.budgetAnalysis.totalExpense' => '总支出',
			'chat.genui.budgetAnalysis.momChange' => ({required Object change}) => '环比 ${change}%',
			'chat.genui.budgetAnalysis.categoryDistribution' => '分类占比',
			'chat.genui.budgetAnalysis.topSpenders' => '大额支出',
			'chat.genui.budgetAnalysis.amountWan' => ({required Object amount}) => '${amount}万',
			'chat.genui.error.title' => 'レンダリングに失敗しました',
			'chat.genui.error.fetchFailed' => '読み込みに失敗しました。後でもう一度お試しください。',
			'chat.genui.error.dataIncomplete' => 'データが不完全です',
			'chat.welcome.morning.subtitle' => '新しい一日を、記録から始めましょう',
			'chat.welcome.morning.breakfast.title' => '朝食記録',
			'chat.welcome.morning.breakfast.prompt' => '朝食の支出を記録',
			'chat.welcome.morning.breakfast.description' => '今日最初の支出をすばやく記録',
			'chat.welcome.morning.yesterdayReview.title' => '昨日の振り返り',
			'chat.welcome.morning.yesterdayReview.prompt' => '昨日の支出を分析',
			'chat.welcome.morning.yesterdayReview.description' => '昨日いくら使ったか確認',
			'chat.welcome.morning.todayBudget.title' => '今日の予算',
			'chat.welcome.morning.todayBudget.prompt' => '今日の残予算を確認',
			'chat.welcome.morning.todayBudget.description' => '一日の支出限度を計画',
			'chat.welcome.midday.greeting' => 'こんにちは',
			'chat.welcome.midday.subtitle' => 'ランチタイムにサクッと記録',
			'chat.welcome.midday.lunch.title' => 'ランチ記録',
			'chat.welcome.midday.lunch.prompt' => 'ランチ代を記録',
			'chat.welcome.midday.lunch.description' => '昼食の支出を記録',
			'chat.welcome.midday.weeklyExpense.title' => '今週の支出',
			'chat.welcome.midday.weeklyExpense.prompt' => '今週の支出を分析',
			'chat.welcome.midday.weeklyExpense.description' => '今週使った金額を確認',
			'chat.welcome.midday.checkBalance.title' => '残高確認',
			'chat.welcome.midday.checkBalance.prompt' => '口座残高を確認',
			'chat.welcome.midday.checkBalance.description' => '各口座の残高を確認',
			'chat.welcome.afternoon.subtitle' => 'ティータイムに家計を整理',
			'chat.welcome.afternoon.quickRecord.title' => 'クイック記録',
			'chat.welcome.afternoon.quickRecord.prompt' => '支出の記録を手伝って',
			'chat.welcome.afternoon.quickRecord.description' => '支出をすばやく記録',
			'chat.welcome.afternoon.analyzeSpending.title' => '支出分析',
			'chat.welcome.afternoon.analyzeSpending.prompt' => '今月の支出を分析',
			'chat.welcome.afternoon.analyzeSpending.description' => '支出の傾向と内訳を確認',
			'chat.welcome.afternoon.budgetProgress.title' => '家計の健康度',
			'chat.welcome.afternoon.budgetProgress.prompt' => '財務状況を診断して',
			'chat.welcome.afternoon.budgetProgress.description' => '収支バランスとアドバイス',
			'chat.welcome.evening.subtitle' => '今日もお疲れ様でした、家計の点検をしましょう',
			'chat.welcome.evening.dinner.title' => '夕食記録',
			'chat.welcome.evening.dinner.prompt' => '夕食代を記録',
			'chat.welcome.evening.dinner.description' => '今夜の夕食代を記録',
			'chat.welcome.evening.todaySummary.title' => '今日のまとめ',
			'chat.welcome.evening.todaySummary.prompt' => '今日の支出をまとめて',
			'chat.welcome.evening.todaySummary.description' => '今日いくら使ったか確認',
			'chat.welcome.evening.tomorrowPlan.title' => '明日の予定',
			'chat.welcome.evening.tomorrowPlan.prompt' => '明日の固定出費を確認',
			'chat.welcome.evening.tomorrowPlan.description' => '明日の支出を事前に計画',
			'chat.welcome.night.greeting' => '夜深まりました',
			'chat.welcome.night.subtitle' => '静かに見つめ直す、これからの資産',
			'chat.welcome.night.makeupRecord.title' => '今日の記入漏れ',
			'chat.welcome.night.makeupRecord.prompt' => '今日の記入漏れを記録',
			'chat.welcome.night.makeupRecord.description' => 'つけ忘れた支出を補完',
			'chat.welcome.night.monthlyReview.title' => '今月の振り返り',
			'chat.welcome.night.monthlyReview.prompt' => '今月の支出を詳しく分析',
			'chat.welcome.night.monthlyReview.description' => '今月何にお金を使ったか確認',
			'chat.welcome.night.financialThinking.title' => '将来の予測',
			'chat.welcome.night.financialThinking.prompt' => '今後30日間の残高を予測',
			'chat.welcome.night.financialThinking.description' => '将来の財務トレンドを予測',
			'chat.shareComingSoon' => '共有機能は近日公開予定です...',
			'chat.invalidAttachmentLink' => '無効な添付ファイルリンク',
			'chat.unableToOpenAttachmentLink' => '添付ファイルリンクを開けません',
			'chat.aiCommunicationError' => ({required Object error}) => '申し訳ありません、AIアシスタントとの通信エラーが発生しました：${error}',
			'chat.uploadStillInProgress' => '添付ファイルはまだアップロード中です。後でもう一度お試しください',
			'chat.sendFailed' => 'メッセージの送信に失敗しました。後でもう一度お試しください',
			'chat.attachmentUploadFailed' => ({required Object files}) => '添付ファイルのアップロードに失敗しました: ${files}',
			'chat.fileUploadFailed' => 'ファイルのアップロードに失敗しました。後でもう一度お試しください',
			'image.deleteTitle' => '画像を削除',
			'image.deleteConfirm' => 'この画像を削除してもよろしいですか？この操作は元に戻せません。',
			'footprint.searchIn' => '検索',
			'footprint.searchInAllRecords' => 'すべての記録から検索',
			'media.selectPhotos' => '写真を選択',
			'media.addFiles' => 'ファイルを追加',
			'media.takePhoto' => '写真を撮る',
			'media.camera' => 'カメラ',
			'media.photos' => '写真',
			'media.files' => 'ファイル',
			'media.showAll' => 'すべて表示',
			'media.allPhotos' => 'すべての写真',
			'media.takingPhoto' => '撮影中...',
			'media.photoTaken' => '写真を保存しました',
			'media.cameraPermissionRequired' => 'カメラの権限が必要です',
			'media.fileSizeExceeded' => 'ファイルサイズが10MBを超えています',
			'media.unsupportedFormat' => 'サポートされていない形式です',
			'media.permissionDenied' => 'アルバムへのアクセス権限が必要です',
			'media.storageInsufficient' => 'ストレージ容量が不足しています',
			'media.networkError' => 'ネットワークエラー',
			'media.unknownUploadError' => '不明なアップロードエラー',
			'error.permissionRequired' => '権限が必要です',
			'error.permissionInstructions' => '設定から権限を許可してください。',
			'error.openSettings' => '設定を開く',
			'error.fileTooLarge' => 'ファイルが大きすぎます',
			'error.fileSizeHint' => '10MB以下のファイルを選択してください。',
			'error.supportedFormatsHint' => '対応形式：画像、PDF、ドキュメント、音声など。',
			'error.storageCleanupHint' => '空き容量を確保して再試行してください。',
			'error.networkErrorHint' => '接続を確認して再試行してください。',
			'error.platformNotSupported' => 'サポートされていないプラットフォーム',
			'error.fileReadError' => '読み込み失敗',
			'error.fileReadErrorHint' => 'ファイルが破損している可能性があります。',
			'error.validationError' => '検証エラー',
			'error.unknownError' => '不明なエラー',
			'error.unknownErrorHint' => '予期せぬエラーが発生しました。',
			'error.registrationMissingInfo' => '登録フローエラー、必要な情報がありません。',
			'error.accountInfoMissing' => '口座情報がありません',
			'error.sharedSpaceInfoMissing' => '共有スペース情報がありません',
			'error.settingsSteps' => '設定手順：',
			'error.suggestions' => '提案：',
			'error.fileNotFound' => 'ファイルが見つかりません',
			'error.fileNotFoundHint' => 'ファイルの存在を確認するか、別のファイルを選択してください。',
			'error.selectAgain' => '再選択',
			'error.thumbnailGenerationFailed' => 'サムネイル生成に失敗しました',
			'error.thumbnailGenerationHint' => 'サムネイルの生成に失敗しましたが、ファイルは選択済みで引き続き使用できます。',
			'error.help' => 'ヘルプ：',
			'error.genui.loadingFailed' => '読み込み失敗',
			'error.genui.schemaFailed' => '検証失敗',
			'error.genui.schemaDescription' => '定義が仕様に適合していません',
			'error.genui.networkError' => 'ネットワークエラー',
			'error.genui.retryStatus' => ({required Object retryCount, required Object maxRetries}) => '再試行中 ${retryCount}/${maxRetries}',
			'error.genui.maxRetriesReached' => '最大試行回数に達しました',
			'fontTest.page' => 'テストページ',
			'fontTest.displayTest' => '表示テスト',
			'fontTest.chineseTextTest' => '中国語テスト',
			'fontTest.englishTextTest' => '英語テスト',
			'fontTest.sample1' => 'これはテスト用のテキストです。',
			'fontTest.sample2' => '支出分析：ショッピングが最多',
			'fontTest.sample3' => 'AIアシスタントによる財務分析',
			'fontTest.sample4' => 'グラフで消費トレンドを確認',
			'fontTest.sample5' => '各種決済サービスに対応',
			'wizard.nextStep' => '次へ',
			'wizard.previousStep' => '前へ',
			'wizard.completeMapping' => 'マップ作成完了',
			'user.username' => 'ユーザー名',
			'user.defaultEmail' => 'user@example.com',
			'account.editTitle' => '口座を編集',
			'account.addTitle' => '新しい口座',
			'account.selectTypeTitle' => '口座タイプを選択',
			'account.nameLabel' => '口座名',
			'account.amountLabel' => '現在の残高',
			'account.currencyLabel' => '通貨',
			'account.hiddenLabel' => '非表示',
			'account.hiddenDesc' => 'リストに表示しない',
			'account.includeInNetWorthLabel' => '資産に含める',
			'account.includeInNetWorthDesc' => '純資産の統計に使用',
			'account.nameHint' => '例：給与振込口座',
			'account.nameRequired' => '口座名を入力してください',
			'account.nameTooShort' => '口座名は2文字以上で入力してください',
			'account.amountRequired' => '現在の残高を入力してください',
			'account.invalidAmount' => '有効な金額を入力してください',
			'account.negativeBalance' => '残高はマイナスにできません',
			'account.amountTooLarge' => '残高は 999,999,999.99 を超えられません',
			'account.amountHint' => '0.00',
			'account.deleteAccount' => '口座を削除',
			'account.deleteConfirm' => 'この口座を削除しますか？取り消せません。',
			'account.save' => '変更を保存',
			'account.assetsCategory' => '資産',
			'account.liabilitiesCategory' => '負債/クレジット',
			'account.cash' => '現金・財布',
			'account.deposit' => '銀行預金',
			'account.creditCard' => 'クレジットカード',
			'account.investment' => '投資・資産運用',
			'account.eWallet' => '電子マネー',
			'account.loan' => 'ローン',
			'account.receivable' => '売掛金・貸付',
			'account.payable' => '買掛金・借入',
			'account.other' => 'その他',
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
			'financial.netWorth' => '純資産',
			'financial.assets' => '総資産',
			'financial.liabilities' => '総負債',
			'financial.noAccounts' => '口座なし',
			'financial.addFirstAccount' => 'ボタンを押して口座を追加してください',
			'financial.assetAccounts' => '資産口座',
			'financial.liabilityAccounts' => '負債口座',
			'financial.selectCurrency' => '通貨を選択',
			'financial.cancel' => 'キャンセル',
			'financial.confirm' => '確定',
			'financial.settings' => '財務設定',
			'financial.budgetManagement' => '予算管理',
			'financial.recurringTransactions' => '繰り返し取引',
			_ => null,
		} ?? switch (path) {
			'financial.safetyThreshold' => 'セーフティライン',
			'financial.dailyBurnRate' => '1日の支出',
			'financial.financialAssistant' => '財務アシスタント',
			'financial.manageFinancialSettings' => '財務設定を管理',
			'financial.safetyThresholdSettings' => 'セーフティライン設定',
			'financial.setSafetyThreshold' => 'セーフティラインの閾値を設定',
			'financial.safetyThresholdSaved' => 'セーフティラインを保存しました',
			'financial.dailyBurnRateSettings' => '支出見積もり',
			'financial.setDailyBurnRate' => '1日の支出見積もりを設定',
			'financial.dailyBurnRateSaved' => '支出見積もりを保存しました',
			'financial.dayUnit' => '日',
			'financial.saveFailed' => '保存に失敗しました',
			'financial.deleteFailed' => '削除に失敗しました。しばらくしてから再試行してください',
			'financial.missingExchangeRates' => ({required Object currencies}) => '一部の通貨の為替レートが取得できないため、該当口座は合計に含まれていません：${currencies}',
			'financial.cashPocketTitle' => 'マイ現金口座',
			'financial.sourcesCount' => ({required Object count}) => '${count} 口座',
			'financial.lastUpdatedAt' => ({required Object time}) => '最終更新：${time}',
			'financial.neverUpdated' => '未更新',
			'financial.updateNow' => '今すぐ更新',
			'app.splashTitle' => 'スマートに、豊かに。',
			'app.splashSubtitle' => 'インテリジェント財務アシスタント',
			'app.fatalInitTitle' => 'Finvo の起動に失敗しました',
			'app.fatalInitMessage' => ({required Object error}) => '初期化エラー：${error}',
			'statistics.title' => '統計分析',
			'statistics.analyze' => '分析',
			'statistics.exportInProgress' => 'エクスポート機能は開発中です...',
			'statistics.ranking' => '高額支出ランキング',
			'statistics.noData' => 'データなし',
			'statistics.overview.balance' => '残高',
			'statistics.overview.income' => '総収入',
			'statistics.overview.expense' => '総支出',
			'statistics.trend.title' => '収支推移',
			'statistics.trend.expense' => '支出',
			'statistics.trend.income' => '収入',
			'statistics.analysis.title' => '支出分析',
			'statistics.analysis.expenseTitle' => '支出分析',
			'statistics.analysis.incomeTitle' => '収入分析',
			'statistics.analysis.total' => '合計',
			'statistics.analysis.breakdown' => '支出カテゴリ内訳',
			'statistics.analysis.radarNeedMoreData' => 'レーダーチャートには3つ以上のカテゴリデータが必要です',
			'statistics.filter.accountType' => '口座タイプ',
			'statistics.filter.allAccounts' => 'すべての口座',
			'statistics.filter.apply' => '適用',
			'statistics.sort.amount' => '金額順',
			'statistics.sort.date' => '日付順',
			'statistics.exportList' => 'リストを書き出す',
			'statistics.emptyState.title' => 'Unlock Financial Insights',
			'statistics.emptyState.description' => 'Your financial report is currently a blank canvas.\nRecord your first transaction and let the data tell your story.',
			'statistics.emptyState.action' => 'Record First Transaction',
			'statistics.noMoreData' => 'No more data',
			'currency.cny' => '人民元',
			'currency.usd' => 'USドル',
			'currency.eur' => 'ユーロ',
			'currency.jpy' => '日本円',
			'currency.gbp' => '英ポンド',
			'currency.aud' => '豪ドル',
			'currency.cad' => 'カナダドル',
			'currency.chf' => 'スイスフラン',
			'currency.rub' => 'ロシアルーブル',
			'currency.hkd' => '香港ドル',
			'currency.twd' => '新台湾ドル',
			'currency.inr' => 'インドルピー',
			'sharedSpace.dashboard.sectionTitle' => '財務概要',
			'sharedSpace.dashboard.cumulativeTotalExpense' => '累計総支出',
			'sharedSpace.dashboard.participatingMembers' => '参加メンバー',
			'sharedSpace.dashboard.membersCount' => ({required Object count}) => '${count} 人',
			'sharedSpace.dashboard.averagePerMember' => 'メンバー平均',
			'sharedSpace.dashboard.spendingDistribution' => 'メンバー別支出割合',
			'sharedSpace.dashboard.realtimeUpdates' => 'リアルタイム更新',
			'sharedSpace.dashboard.paid' => '支払い済み',
			'sharedSpace.roles.owner' => 'オーナー',
			'sharedSpace.roles.admin' => '管理者',
			'sharedSpace.roles.member' => 'メンバー',
			'sharedSpace.title' => '共有スペース',
			'sharedSpace.create.title' => '共有スペースを作成',
			'sharedSpace.create.subtitle' => '共有スペースを作成して、共有の財務を閲覧・分析',
			'sharedSpace.create.nameLabel' => 'スペース名',
			'sharedSpace.create.nameHint' => '例：卒業旅行',
			'sharedSpace.create.descLabel' => '説明（任意）',
			'sharedSpace.create.descHint' => '共同旅行の支出を記録',
			'sharedSpace.create.cancel' => 'キャンセル',
			'sharedSpace.create.submit' => '作成',
			'sharedSpace.create.nameRequired' => 'スペース名を入力してください',
			'sharedSpace.create.nameTooShort' => 'スペース名は2文字以上必要です',
			'sharedSpace.create.nameTooLong' => 'スペース名は50文字以内にしてください',
			'sharedSpace.join.title' => '共有スペースに参加',
			'sharedSpace.join.subtitle' => '招待コードを入力して、共有の財務を閲覧・分析',
			'sharedSpace.join.codeHint' => '6桁の数字招待コードを入力',
			'sharedSpace.join.cancel' => 'キャンセル',
			'sharedSpace.join.submit' => '参加',
			'sharedSpace.join.codeRequired' => '招待コードを入力してください',
			'sharedSpace.join.codeInvalid' => '6桁の数字招待コードを入力してください',
			'sharedSpace.list.emptyTitle' => '共有の財務をみんなで俯瞰',
			'sharedSpace.list.emptySubtitle' => '共有スペースを作成・参加して、家族や友達と財務の閲覧・分析・集計を共有',
			'sharedSpace.list.getStarted' => '始める',
			'sharedSpace.list.hasInviteCode' => '招待コードをお持ちですか？タップして参加',
			'sharedSpace.list.joinedSuccess' => ({required Object name}) => '「${name}」に参加しました！',
			'sharedSpace.detail.members' => 'メンバー',
			'sharedSpace.detail.transactions' => '取引履歴',
			'sharedSpace.detail.recordsCount' => ({required Object count}) => '${count} 件',
			'sharedSpace.detail.settlement' => '精算',
			'sharedSpace.detail.inviteCode' => '招待コード',
			'sharedSpace.detail.copyCode' => '招待コードをコピー',
			'sharedSpace.detail.codeCopied' => ({required Object code}) => '招待コードをコピーしました：${code}',
			'sharedSpace.detail.validFor24h' => '24時間有効',
			'sharedSpace.detail.leaveSpace' => 'スペースを退出',
			'sharedSpace.detail.deleteSpace' => 'スペースを削除',
			'sharedSpace.detail.removeMember' => 'メンバーを削除',
			'sharedSpace.detail.leaveConfirm' => 'この共有スペースを退出しますか？退出後は取引履歴を閲覧できなくなります。',
			'sharedSpace.detail.deleteConfirm' => 'この共有スペースを削除しますか？この操作は取り消せず、すべてのメンバーが削除されます。',
			'sharedSpace.detail.removeConfirm' => 'このメンバーを共有スペースから削除しますか？',
			'sharedSpace.detail.generatingCode' => '招待コードを生成中...',
			'sharedSpace.detail.loadFailed' => '読み込みに失敗しました',
			'sharedSpace.detail.retry' => '再試行',
			'sharedSpace.detail.noTransactions' => '取引はまだありません',
			'sharedSpace.detail.noTransactionsHint' => 'このスペースの取引がここに表示されます',
			'sharedSpace.detail.refreshCode' => 'コードを更新',
			'sharedSpace.detail.noMoreTransactions' => 'これ以上の取引はありません',
			'sharedSpace.notifications.title' => 'お知らせ',
			'sharedSpace.notifications.empty' => 'お知らせはありません',
			'sharedSpace.notifications.emptyHint' => '新しい招待やアクティビティがあると、\nここにお知らせが表示されます',
			'sharedSpace.notifications.incompleteInfo' => '招待情報が不完全です',
			'sharedSpace.notifications.inviteAccepted' => '招待を承認しました！',
			'sharedSpace.notifications.inviteRejected' => '招待を拒否しました',
			'sharedSpace.notifications.allMarkedRead' => 'すべて既読にしました',
			'sharedSpace.inviteCard.title' => '招待コード',
			'sharedSpace.inviteCard.copyCode' => '招待コードをコピー',
			'sharedSpace.inviteCard.shareLink' => '招待リンクを共有',
			'sharedSpace.inviteCard.codeCopied' => '招待コードをコピーしました',
			'sharedSpace.inviteCard.noExpiry' => '無期限',
			'sharedSpace.inviteCard.expired' => '期限切れ',
			'sharedSpace.inviteCard.expiresInDays' => ({required Object days}) => '${days}日後に期限切れ',
			'sharedSpace.inviteCard.expiresInHours' => ({required Object hours}) => '${hours}時間後に期限切れ',
			'sharedSpace.inviteCard.expiresInMinutes' => ({required Object minutes}) => '${minutes}分後に期限切れ',
			'sharedSpace.inviteCard.expiringSoon' => 'まもなく期限切れ',
			'sharedSpace.inviteCard.shareText' => ({required Object spaceName, required Object code, required Object link, required Object expiry}) => '共有スペース「${spaceName}」に招待されました\n\n招待コード：${code}\nまたはリンクをクリックして直接参加：${link}\n\n招待コード${expiry}',
			'sharedSpace.inviteSuccess.title' => '作成完了',
			'sharedSpace.inviteSuccess.subtitle' => '共有スペースが作成されました',
			'sharedSpace.inviteSuccess.inviteLater' => '後で招待',
			'sharedSpace.inviteSuccess.enterSpace' => 'スペースに入る',
			'sharedSpace.inviteSuccess.generatingCode' => '招待コードを生成中...',
			'sharedSpace.inviteSuccess.generateFailed' => '招待コードの生成に失敗しました',
			'sharedSpace.inviteSuccess.codeCopied' => '招待コードをコピーしました',
			'sharedSpace.inviteSuccess.retry' => '再試行',
			'sharedSpace.inviteSuccess.codeLabel' => '招待コード',
			'sharedSpace.inviteSuccess.validHint' => '24時間有効 · タップしてコピー',
			'sharedSpace.notificationCard.accept' => '承認',
			'sharedSpace.notificationCard.reject' => '拒否',
			'sharedSpace.notificationCard.unknownTime' => '不明な時間',
			'sharedSpace.notificationCard.justNow' => 'たった今',
			'sharedSpace.spaceCard.noDescription' => '説明なし',
			'sharedSpace.spaceCard.creator' => '作成者',
			'sharedSpace.spaceCard.member' => 'メンバー',
			'sharedSpace.spaceCard.membersCount' => ({required Object count}) => '${count} 人のメンバー',
			'sharedSpace.spaceCard.transactionsCount' => ({required Object count}) => '${count} 件の取引',
			'sharedSpace.settings.title' => 'スペース設定',
			'sharedSpace.settings.spaceInfo' => 'スペース情報',
			'sharedSpace.settings.nameLabel' => 'スペース名',
			'sharedSpace.settings.descLabel' => 'スペースの説明',
			'sharedSpace.settings.save' => '保存',
			'sharedSpace.settings.saved' => '保存しました',
			'sharedSpace.settings.saveFailed' => '保存に失敗しました',
			'sharedSpace.settings.memberManagement' => 'メンバー管理',
			'sharedSpace.settings.membersCount' => ({required Object count}) => '${count} 人のメンバー',
			'sharedSpace.settings.removeMemberConfirm' => ({required Object name}) => '「${name}」をスペースから削除しますか？',
			'sharedSpace.settings.removed' => 'メンバーを削除しました',
			'sharedSpace.settings.removeFailed' => '削除に失敗しました',
			'sharedSpace.settings.inviteManagement' => '招待管理',
			'sharedSpace.settings.currentCode' => '現在の招待コード',
			'sharedSpace.settings.generateNew' => '新しいコードを生成',
			'sharedSpace.settings.noValidCode' => '有効な招待コードがありません',
			'sharedSpace.settings.refreshCode' => 'コードを更新',
			'sharedSpace.settings.refreshConfirm' => '新しいコードを生成すると古いコードは無効になります。続行しますか？',
			'sharedSpace.settings.codeRefreshed' => '招待コードを更新しました',
			'sharedSpace.settings.dangerZone' => '危険な操作',
			'sharedSpace.settings.editHint' => '管理者のみ編集可能',
			'sharedSpace.settings.edit' => '編集',
			'sharedSpace.settings.you' => '自分',
			'sharedSpace.settings.pending' => '承認待ち',
			'sharedSpace.settings.declined' => '拒否済み',
			'sharedSpace.settings.setAsAdmin' => '管理者に設定',
			'sharedSpace.settings.setAsMember' => 'メンバーに設定',
			'sharedSpace.settings.changeRole' => '役割を変更',
			'sharedSpace.settings.changeRoleConfirm' => ({required Object name, required Object role}) => '「${name}」の役割を「${role}」に変更しますか？',
			'sharedSpace.settings.confirm' => '確認',
			'sharedSpace.settings.roleChanged' => '役割を変更しました',
			'sharedSpace.settings.roleChangeFailed' => '役割の変更に失敗しました',
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
			'server.saveAndReLogin' => '保存して再ログイン',
			'server.serverUrlSavedRedirectLogin' => 'サーバー設定が更新されました。再度ログインしてください',
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
			'server.error.plainHttpWarning' => '平文 HTTP:ログイントークンとデータが暗号化されず送信されます。信頼できるローカルネットワークでのみ使用してください。',
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
			'errorMapping.transaction.invalidAccountId' => 'アカウントIDが無効です',
			'errorMapping.transaction.exchangeRateUnavailable' => 'この通貨の為替レートは利用できません',
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
			'errorMapping.space.transactionAlreadyInSpace' => '取引は既にこのスペースにあります',
			'errorMapping.recurring.invalidRule' => 'Invalid recurrence rule',
			'errorMapping.recurring.ruleNotFound' => 'Recurrence rule not found',
			'errorMapping.upload.noFile' => 'No file uploaded',
			'errorMapping.upload.tooLarge' => 'File too large',
			'errorMapping.upload.unsupportedType' => 'Unsupported file type',
			'errorMapping.upload.tooManyFiles' => 'Too many files',
			'errorMapping.upload.invalidFile' => 'アップロードされたファイルが無効です',
			'errorMapping.upload.invalidMimeType' => 'ファイルのMIMEタイプが無効です',
			'errorMapping.upload.invalidImageContent' => '画像の内容が無効です',
			'errorMapping.upload.imageTooWide' => '画像が幅広すぎます',
			'errorMapping.upload.imageTooHigh' => '画像が高すぎます',
			'errorMapping.upload.totalSizeTooLarge' => 'ファイルの合計サイズが大きすぎます',
			'errorMapping.upload.readError' => 'ファイルの読み取りに失敗しました',
			'errorMapping.upload.filesystemError' => 'ファイルシステムエラー',
			'errorMapping.upload.verificationFailed' => 'アップロードの検証に失敗しました',
			'errorMapping.upload.allFailed' => 'すべてのファイルのアップロードに失敗しました',
			'errorMapping.upload.invalidImageUrls' => '画像URLが無効です',
			'errorMapping.upload.fileNotFound' => 'ファイルが見つかりません',
			'errorMapping.upload.imageCompressionFailed' => '画像の圧縮に失敗しました',
			'errorMapping.upload.accessError' => 'ファイルアクセスエラー',
			'errorMapping.upload.deleteError' => 'ファイルの削除に失敗しました',
			'errorMapping.upload.noFiles' => 'ファイルが指定されていません',
			'errorMapping.upload.fileEmpty' => 'ファイルが空です',
			'errorMapping.upload.invalidFilename' => 'ファイル名が無効です',
			'errorMapping.storage.configNotFound' => 'ストレージ設定が見つからないかアクセス権限がありません',
			'errorMapping.storage.configInUse' => '削除できません：ストレージ設定は添付ファイルで使用中です',
			'errorMapping.storage.invalidProviderType' => '無効なストレージプロバイダータイプ',
			'errorMapping.ai.contextLimit' => 'Context limit exceeded',
			'errorMapping.ai.tokenLimit' => 'Insufficient tokens',
			'errorMapping.ai.emptyMessage' => 'Empty user message',
			'errorMapping.ai.conversationIdInvalid' => '会話が無効です',
			'errorMapping.ai.conversationIdNotOwner' => 'この会話へのアクセス権がありません',
			'notification.title' => 'お知らせ',
			'notification.markAllRead' => 'すべて既読',
			'notification.empty' => 'お知らせはありません',
			'notification.loadFailed' => '読み込みに失敗しました',
			'notification.retry' => '再試行',
			'notification.justNow' => 'たった今',
			'notification.minutesAgo' => ({required Object minutes}) => '${minutes}分前',
			'notification.hoursAgo' => ({required Object hours}) => '${hours}時間前',
			'notification.daysAgo' => ({required Object days}) => '${days}日前',
			'notification.deleted' => '削除しました',
			'notification.types.system' => 'システム',
			'notification.types.spaceInvite' => 'スペース招待',
			'notification.types.spaceActivity' => 'スペース活動',
			'notification.types.billComment' => '請求コメント',
			'notification.types.budgetAlert' => '予算アラート',
			'notification.types.transaction' => '取引通知',
			'notification.semantic.memberJoined' => ({required Object name}) => '${name} さんがスペースに参加しました',
			'notification.semantic.memberJoinedDetail' => ({required Object space}) => '新しいメンバーが「${space}」に参加しました',
			'notification.semantic.welcome' => ({required Object space}) => '「${space}」へようこそ',
			'notification.semantic.newTransaction' => ({required Object name}) => '${name} さんが新しい支出を記録しました',
			'notification.semantic.newTransactionDetail' => ({required Object amount, required Object space}) => '${amount}、「${space}」より',
			'notification.semantic.memberLeft' => ({required Object name}) => '${name} さんがスペースを退出しました',
			'notification.semantic.recurringPending' => '定期取引の確認待ち',
			'notification.semantic.recurringPendingDetail' => ({required Object description, required Object amount}) => '${description} ${amount}、確認待ちです',
			'notification.semantic.commentReplied' => ({required Object name}) => '${name} さんがあなたのコメントに返信しました',
			'notification.semantic.commentOnTransaction' => ({required Object name}) => '${name} さんがあなたの取引にコメントしました',
			'notification.semantic.commentMentioned' => ({required Object name}) => '${name} さんがあなたをメンションしました',
			'notification.semantic.commentInSpace' => ({required Object name}) => '${name} さんがあなたのスペースにコメントしました',
			_ => null,
		};
	}
}
