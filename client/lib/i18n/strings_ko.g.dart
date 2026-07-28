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
class TranslationsKo extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsKo({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ko,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ko>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsKo _root = this; // ignore: unused_field

	@override
	TranslationsKo $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsKo(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$common$ko common = _Translations$common$ko._(_root);
	@override late final _Translations$time$ko time = _Translations$time$ko._(_root);
	@override late final _Translations$greeting$ko greeting = _Translations$greeting$ko._(_root);
	@override late final _Translations$navigation$ko navigation = _Translations$navigation$ko._(_root);
	@override late final _Translations$auth$ko auth = _Translations$auth$ko._(_root);
	@override late final _Translations$transaction$ko transaction = _Translations$transaction$ko._(_root);
	@override late final _Translations$home$ko home = _Translations$home$ko._(_root);
	@override late final _Translations$comment$ko comment = _Translations$comment$ko._(_root);
	@override late final _Translations$calendar$ko calendar = _Translations$calendar$ko._(_root);
	@override late final _Translations$category$ko category = _Translations$category$ko._(_root);
	@override late final _Translations$settings$ko settings = _Translations$settings$ko._(_root);
	@override late final _Translations$appearance$ko appearance = _Translations$appearance$ko._(_root);
	@override late final _Translations$speech$ko speech = _Translations$speech$ko._(_root);
	@override late final _Translations$amountTheme$ko amountTheme = _Translations$amountTheme$ko._(_root);
	@override late final _Translations$locale$ko locale = _Translations$locale$ko._(_root);
	@override late final _Translations$budget$ko budget = _Translations$budget$ko._(_root);
	@override late final _Translations$dateRange$ko dateRange = _Translations$dateRange$ko._(_root);
	@override late final _Translations$forecast$ko forecast = _Translations$forecast$ko._(_root);
	@override late final _Translations$chat$ko chat = _Translations$chat$ko._(_root);
	@override late final _Translations$footprint$ko footprint = _Translations$footprint$ko._(_root);
	@override late final _Translations$media$ko media = _Translations$media$ko._(_root);
	@override late final _Translations$error$ko error = _Translations$error$ko._(_root);
	@override late final _Translations$fontTest$ko fontTest = _Translations$fontTest$ko._(_root);
	@override late final _Translations$wizard$ko wizard = _Translations$wizard$ko._(_root);
	@override late final _Translations$user$ko user = _Translations$user$ko._(_root);
	@override late final _Translations$account$ko account = _Translations$account$ko._(_root);
	@override late final _Translations$financial$ko financial = _Translations$financial$ko._(_root);
	@override late final _Translations$app$ko app = _Translations$app$ko._(_root);
	@override late final _Translations$statistics$ko statistics = _Translations$statistics$ko._(_root);
	@override late final _Translations$currency$ko currency = _Translations$currency$ko._(_root);
	@override late final _Translations$sharedSpace$ko sharedSpace = _Translations$sharedSpace$ko._(_root);
	@override late final _Translations$budgetSuggestion$ko budgetSuggestion = _Translations$budgetSuggestion$ko._(_root);
	@override late final _Translations$server$ko server = _Translations$server$ko._(_root);
	@override late final _Translations$errorMapping$ko errorMapping = _Translations$errorMapping$ko._(_root);
	@override late final _Translations$notification$ko notification = _Translations$notification$ko._(_root);
}

// Path: common
class _Translations$common$ko extends Translations$common$zh {
	_Translations$common$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get loading => '로딩 중...';
	@override String get error => '오류';
	@override String get retry => '재시도';
	@override String get cancel => '취소';
	@override String get confirm => '확인';
	@override String get save => '저장';
	@override String get delete => '삭제';
	@override String get edit => '편집';
	@override String get add => '추가';
	@override String get search => '검색';
	@override String get filter => '필터';
	@override String get sort => '정렬';
	@override String get refresh => '새로고침';
	@override String get more => '더 보기';
	@override String get less => '접기';
	@override String get all => '전체';
	@override String get none => '없음';
	@override String get ok => '확인';
	@override String get unknown => '알 수 없음';
	@override String get noData => '데이터가 없습니다';
	@override String get loadMore => '더 불러오기';
	@override String get noMore => '더 이상 없습니다';
	@override String get loadFailed => '불러오기 실패';
	@override String get history => '거래 내역';
	@override String get reset => '초기화';
}

// Path: time
class _Translations$time$ko extends Translations$time$zh {
	_Translations$time$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get today => '오늘';
	@override String get yesterday => '어제';
	@override String get dayBeforeYesterday => '그저께';
	@override String get thisWeek => '이번 주';
	@override String get thisMonth => '이번 달';
	@override String get thisYear => '이번 해';
	@override String get selectDate => '날짜 선택';
	@override String get selectTime => '시간 선택';
	@override String get justNow => '방금';
	@override String minutesAgo({required Object count}) => '${count}분 전';
	@override String hoursAgo({required Object count}) => '${count}시간 전';
	@override String daysAgo({required Object count}) => '${count}일 전';
	@override String weeksAgo({required Object count}) => '${count}주 전';
}

// Path: greeting
class _Translations$greeting$ko extends Translations$greeting$zh {
	_Translations$greeting$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get morning => '좋은 아침입니다';
	@override String get afternoon => '좋은 오후입니다';
	@override String get evening => '좋은 저녁입니다';
}

// Path: navigation
class _Translations$navigation$ko extends Translations$navigation$zh {
	_Translations$navigation$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get home => '홈';
	@override String get forecast => '예측';
	@override String get footprint => '발자취';
	@override String get profile => '마이페이지';
}

// Path: auth
class _Translations$auth$ko extends Translations$auth$zh {
	_Translations$auth$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get login => '로그인';
	@override String get loggingIn => '로그인 중...';
	@override String get logout => '로그아웃';
	@override String get register => '회원가입';
	@override String get registering => '가입 중...';
	@override String get welcomeBack => '다시 오신 것을 환영합니다';
	@override String get loginSuccess => '반가워요!';
	@override String get loginFailed => '로그인 실패';
	@override String get pleaseTryAgain => '잠시 후 다시 시도해주세요.';
	@override @Deprecated('No longer used after BrandHeader refactor; will be removed in a future release.')
	String get loginSubtitle => 'AI 가계부 도우미를 계속 사용하려면 로그인하세요';
	@override String get noAccount => '계정이 없으신가요? 가입하기';
	@override String get createAccount => '계정 만들기';
	@override String get setPassword => '비밀번호 설정';
	@override String get setAccountPassword => '계정 비밀번호를 설정하세요';
	@override String get completeRegistration => '가입 완료';
	@override String get registrationSuccess => '가입 성공!';
	@override String get registrationFailed => '가입 실패';
	@override late final _Translations$auth$email$ko email = _Translations$auth$email$ko._(_root);
	@override late final _Translations$auth$password$ko password = _Translations$auth$password$ko._(_root);
	@override late final _Translations$auth$verificationCode$ko verificationCode = _Translations$auth$verificationCode$ko._(_root);
	@override String get logoutSuccess => 'Logged out successfully';
	@override String get confirmLogoutTitle => 'Confirm Logout';
	@override String get confirmLogoutContent => 'Are you sure you want to log out?';
}

// Path: transaction
class _Translations$transaction$ko extends Translations$transaction$zh {
	_Translations$transaction$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get expense => '지출';
	@override String get income => '수입';
	@override String get transfer => '이체';
	@override String get amount => '금액';
	@override String get category => '카테고리';
	@override String get description => '설명';
	@override String get tags => '태그';
	@override String get saveTransaction => '내역 저장';
	@override String get pleaseEnterAmount => '금액을 입력하세요';
	@override String get pleaseSelectCategory => '카테고리를 선택하세요';
	@override String get saveFailed => '저장 실패';
	@override String get descriptionHint => '거래 상세 내용을 기록하세요...';
	@override String get addCustomTag => '커스텀 태그 추가';
	@override String get commonTags => '자주 쓰는 태그';
	@override String maxTagsHint({required Object maxTags}) => '최대 ${maxTags}개의 태그를 추가할 수 있습니다';
	@override String get noTransactionsFound => '거래 내역을 찾을 수 없습니다';
	@override String get tryAdjustingSearch => '검색 조건을 변경하거나 새 내역을 작성해보세요';
	@override String get noDescription => '설명 없음';
	@override String get payment => '결제';
	@override String get account => '계좌';
	@override String get time => '시간';
	@override String get location => '장소';
	@override String get transactionDetail => '거래 상세';
	@override String get favorite => '즐겨찾기';
	@override String get confirmDelete => '삭제 확인';
	@override String get deleteTransactionConfirm => '이 거래 내역을 삭제하시겠습니까? 삭제 후에는 복구할 수 없습니다.';
	@override String get noActions => '사용 가능한 작업이 없습니다';
	@override String get deleted => '삭제됨';
	@override String get deleteFailed => '삭제 실패, 잠시 후 다시 시도해주세요';
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
class _Translations$home$ko extends Translations$home$zh {
	_Translations$home$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get totalExpense => '총 소비 금액';
	@override String get todayExpense => '오늘 지출';
	@override String get monthExpense => '이번 달 지출';
	@override String yearProgress({required Object year}) => '${year}년 진행률';
	@override String get amountHidden => '••••••••';
	@override String get loadFailed => '불러오기 실패';
	@override String get noTransactions => '거래 내역 없음';
	@override String get tryRefresh => '새로고침 해보세요';
	@override String get noMoreData => '더 이상 데이터가 없습니다';
	@override String get userNotLoggedIn => '로그인하지 않아 데이터를 불러올 수 없습니다';
}

// Path: comment
class _Translations$comment$ko extends Translations$comment$zh {
	_Translations$comment$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get error => '오류';
	@override String get commentFailed => '댓글 작성 실패';
	@override String replyToPrefix({required Object name}) => '@${name} 님에게 답글:';
	@override String get reply => '답글';
	@override String get addNote => '메모 추가...';
	@override String get confirmDeleteTitle => '삭제 확인';
	@override String get confirmDeleteContent => '댓글을 삭제하시겠습니까? 복구할 수 없습니다.';
	@override String get success => '성공';
	@override String get commentDeleted => '댓글이 삭제되었습니다';
	@override String get deleteFailed => '삭제 실패';
	@override String get deleteComment => '댓글 삭제';
	@override String get hint => '힌트';
	@override String get noActions => '사용 가능한 작업이 없습니다';
	@override String get note => '메모';
	@override String get noNote => '메모 없음';
	@override String get loadFailed => '메모 불러오기 실패';
}

// Path: calendar
class _Translations$calendar$ko extends Translations$calendar$zh {
	_Translations$calendar$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '소비 달력';
	@override late final _Translations$calendar$weekdays$ko weekdays = _Translations$calendar$weekdays$ko._(_root);
	@override String get loadFailed => '달력 데이터 로드 실패';
	@override String thisMonth({required Object amount}) => '이번 달: ${amount}';
	@override String get counting => '통계 중...';
	@override String get unableToCount => '통계 불가';
	@override String get trend => '추세: ';
	@override String get noTransactionsTitle => '해당 날짜에 거래 내역 없음';
	@override String get loadTransactionFailed => '거래 로드 실패';
}

// Path: category
class _Translations$category$ko extends Translations$category$zh {
	_Translations$category$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get dailyConsumption => '일상 소비';
	@override String get transportation => '교통';
	@override String get healthcare => '의료/건강';
	@override String get housing => '주거';
	@override String get education => '교육';
	@override String get incomeCategory => '수입';
	@override String get socialGifts => '선물/경조사';
	@override String get moneyTransfer => '자금 이체';
	@override String get other => '기타';
	@override String get foodDining => '식비/외식';
	@override String get shoppingRetail => '쇼핑';
	@override String get housingUtilities => '주거/공과금';
	@override String get personalCare => '미용/개인관리';
	@override String get entertainment => '여가/오락';
	@override String get medicalHealth => '의료/건강';
	@override String get insurance => '보험';
	@override String get socialGifting => '경조사';
	@override String get financialTax => '금융/세금';
	@override String get others => '기타 지출';
	@override String get salaryWage => '급여';
	@override String get businessTrade => '사업/거래';
	@override String get investmentReturns => '투자 수익';
	@override String get giftBonus => '보너스/용돈';
	@override String get refundRebate => '환급/리베이트';
	@override String get generalTransfer => '이체';
	@override String get debtRepayment => '부채 상환';
}

// Path: settings
class _Translations$settings$ko extends Translations$settings$zh {
	_Translations$settings$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '설정';
	@override String get language => '언어';
	@override String get languageSettings => '언어 설정';
	@override String get selectLanguage => '언어 선택';
	@override String get languageChanged => '언어가 변경되었습니다';
	@override String get restartToApply => '변경 사항을 적용하려면 앱을 재시작하세요';
	@override String get theme => '테마';
	@override String get darkMode => '다크 모드';
	@override String get lightMode => '라이트 모드';
	@override String get systemMode => '시스템 설정에 맞춤';
	@override String get developerOptions => '개발자 옵션';
	@override String get authDebug => '인증 상태 디버깅';
	@override String get authDebugSubtitle => '인증 상태 및 디버깅 정보 확인';
	@override String get fontTest => '글꼴 테스트';
	@override String get fontTestSubtitle => '앱 글꼴 표시 효과 테스트';
	@override String get helpAndFeedback => '도움말 및 피드백';
	@override String get helpAndFeedbackSubtitle => '도움 받기 또는 피드백 제공';
	@override String get aboutApp => '앱 정보';
	@override String get aboutAppSubtitle => '버전 정보 및 업데이트 확인';
	@override String get checkUpdate => '업데이트 확인';
	@override String get checkingUpdate => '업데이트 확인 중...';
	@override String get latestVersionToast => '최신 버전을 사용 중입니다';
	@override String get newVersionTitle => '새 버전 출시';
	@override String get updateNow => '지금 업데이트';
	@override String get updateLater => '나중에';
	@override String get fetchUpdateFailed => '업데이트 확인 실패';
	@override String currencyChangedRefreshHint({required Object currency}) => '${currency}로 변경되었습니다. 새 거래는 이 통화로 기록됩니다.';
	@override String get sharedSpace => '공유 공간';
	@override String get speechRecognition => '음성 인식';
	@override String get speechRecognitionSubtitle => '음성 입력 파라미터 구성';
	@override String get amountDisplayStyle => '금액 표시 스타일';
	@override String get currency => '표시 통화';
	@override String get appearance => '화면 설정';
	@override String get appearanceSubtitle => '테마 모드 및 색상 구성';
	@override String get speechTest => '음성 테스트';
	@override String get speechTestSubtitle => 'WebSocket 음성 연결 테스트';
	@override String get userTypeRegular => '일반 사용자';
	@override String get selectAmountStyle => '금액 표시 스타일 선택';
	@override String get currencyDescription => '선호하는 표시 통화를 선택하세요. 모든 금액이 이 통화로 표시됩니다.';
	@override String get amountStyleNotice => 'Note: Amount styles are primarily applied to \'Transactions\' and \'Trends\'. To maintain visual clarity, \'Account Balances\' and \'Asset Summaries\' will remain in neutral colors.';
	@override String get editUsername => 'Edit Username';
	@override String get enterUsername => 'Enter username';
	@override String get usernameRequired => 'Username is required';
	@override String get usernameUpdated => 'Username updated';
	@override String get avatarUpdated => 'Avatar updated';
	@override String get appearanceUpdated => '外观设置已更新';
}

// Path: appearance
class _Translations$appearance$ko extends Translations$appearance$zh {
	_Translations$appearance$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '화면 설정';
	@override String get themeMode => '테마 모드';
	@override String get light => '라이트';
	@override String get dark => '다크';
	@override String get system => '시스템 설정';
	@override String get colorScheme => '색상 구성';
	@override late final _Translations$appearance$palettes$ko palettes = _Translations$appearance$palettes$ko._(_root);
}

// Path: speech
class _Translations$speech$ko extends Translations$speech$zh {
	_Translations$speech$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '음성 인식 설정';
	@override String get service => '음성 인식 서비스';
	@override String get systemVoice => '시스템 음성';
	@override String get systemVoiceSubtitle => '휴대폰 내장 음성 인식 서비스(권장)';
	@override String get selfHostedASR => '자체 구축 ASR 서비스';
	@override String get selfHostedASRSubtitle => 'WebSocket을 통한 자체 서버 연결';
	@override String get serverConfig => '서버 구성';
	@override String get serverAddress => '서버 주소';
	@override String get port => '포트';
	@override String get path => '경로';
	@override String get saveConfig => '구성 저장';
	@override String get info => '정보';
	@override String get infoContent => '• 시스템 음성: 기기 내장 서비스 사용, 설정 불필요, 빠른 응답\n• 자체 ASR: 커스텀 모델이나 오프라인 환경에 적합\n\n변경 사항은 다음 음성 입력 시 적용됩니다.';
	@override String get enterAddress => '서버 주소를 입력하세요';
	@override String get enterValidPort => '유효한 포트 번호를 입력하세요 (1-65535)';
	@override String get configSaved => '구성이 저장되었습니다';
	@override String get systemVoiceRestrictedTitle => '시스템 음성을 사용할 수 없음';
	@override String get systemVoiceRestrictedContent => '기기 음성 인식 서비스를 사용할 수 없거나 비활성화되어 있습니다. 설정에서 활성화하거나 WebSocket 자체 ASR을 설정하세요.';
	@override String get dictationDisabledTitle => '음성 받아쓰기 비활성화됨';
	@override String get dictationDisabledContent => '시스템 음성 받아쓰기가 활성화되어 있지 않습니다. iOS 기기의 경우 [설정 -> 일반 -> 키보드]에서 [받아쓰기 활성화]를 켜주세요.';
	@override String get permissionDeniedTitle => '음성 권한 필요';
	@override String get permissionDeniedContent => '이 기능을 사용하려면 마이크 및 음성 인식 권한이 필요합니다. 시스템 설정에서 권한을 허용해 주세요.';
	@override String get goToSettings => '설정으로 이동';
	@override String get systemVoiceStatusAvailable => '시스템 음성 지원됨';
	@override String get systemVoiceStatusRestricted => '시스템 음성 제한됨 (자작 ASR 권장)';
}

// Path: amountTheme
class _Translations$amountTheme$ko extends Translations$amountTheme$zh {
	_Translations$amountTheme$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get chinaMarket => '중국 시장 관습';
	@override String get chinaMarketDesc => '빨강 상승/초록 하락 (권장)';
	@override String get international => '국제 표준';
	@override String get internationalDesc => '초록 상승/빨강 하락';
	@override String get minimalist => '미니멀리스트';
	@override String get minimalistDesc => '기호로만 구분';
	@override String get colorBlind => '색약 지원';
	@override String get colorBlindDesc => '파랑-주황 색상 구성';
}

// Path: locale
class _Translations$locale$ko extends Translations$locale$zh {
	_Translations$locale$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get chinese => '简体中文';
	@override String get traditionalChinese => '繁體中文';
	@override String get english => 'English';
	@override String get japanese => '日本語';
	@override String get korean => '한국어';
}

// Path: budget
class _Translations$budget$ko extends Translations$budget$zh {
	_Translations$budget$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '예산 관리';
	@override String get detail => '예산 상세';
	@override String get info => '예산 정보';
	@override String get totalBudget => '총 예산';
	@override String get categoryBudget => '카테고리 예산';
	@override String get monthlySummary => '이번 달 예산 요약';
	@override String get used => '사용함';
	@override String get remaining => '남음';
	@override String get overspent => '초과';
	@override String get budget => '예산';
	@override String get loadFailed => '불러오기 실패';
	@override String get noBudget => '예산 없음';
	@override String get createHint => '아래 버튼을 눌러 예산을 설정하세요';
	@override String get paused => '일시 정지됨';
	@override String get pause => '일시 정지';
	@override String get resume => '재개';
	@override String get budgetPaused => '예산 관리가 정지되었습니다';
	@override String get budgetResumed => '예산 관리가 재개되었습니다';
	@override String get operationFailed => '작업 실패';
	@override String get deleteBudget => '예산 삭제';
	@override String get deleteConfirm => '이 예산을 삭제하시겠습니까? 복구할 수 없습니다.';
	@override String get type => '유형';
	@override String get category => '카테고리';
	@override String get period => '주기';
	@override String get rollover => '이월 예산';
	@override String get rolloverBalance => '이월 잔액';
	@override String get enabled => '사용';
	@override String get disabled => '사용 안 함';
	@override String get statusNormal => '정상';
	@override String get statusWarning => '한도 임박';
	@override String get statusOverspent => '초과됨';
	@override String get statusAchieved => '목표 달성';
	@override String tipNormal({required Object amount}) => '${amount} 더 쓸 수 있어요';
	@override String tipWarning({required Object amount}) => '${amount} 남았습니다. 주의하세요';
	@override String tipOverspent({required Object amount}) => '${amount} 초과 사용했습니다';
	@override String get tipAchieved => '저축 목표 달성을 축하합니다!';
	@override String remainingAmount({required Object amount}) => '남은 금액 ${amount}';
	@override String overspentAmount({required Object amount}) => '초과 금액 ${amount}';
	@override String budgetAmount({required Object amount}) => '예산 금액 ${amount}';
	@override String get active => '활성';
	@override String get all => '전체';
	@override String get notFound => '예산이 없거나 삭제되었습니다';
	@override String get setup => '예산 설정';
	@override String get settings => '예산 설정';
	@override String get setAmount => '예산 금액 설정';
	@override String get setAmountDesc => '각 카테고리별 예산 설정';
	@override String get monthly => '월간 예산';
	@override String get monthlyDesc => '월별 지출 관리(대부분에게 권장)';
	@override String get weekly => '주간 예산';
	@override String get weeklyDesc => '주별로 정밀하게 관리';
	@override String get yearly => '연간 예산';
	@override String get yearlyDesc => '장기적인 재무 계획용';
	@override String get editBudget => '예산 편집';
	@override String get editBudgetDesc => '금액 및 카테고리 수정';
	@override String get reminderSettings => '알림 설정';
	@override String get reminderSettingsDesc => '예산 알림 및 통지 설정';
	@override String get report => '예산 보고서';
	@override String get reportDesc => '상세한 예산 분석 보고서 보기';
	@override String get welcome => '예산 관리에 오신 것을 환영합니다!';
	@override String get createNewPlan => '새 예산 계획 만들기';
	@override String get welcomeDesc => '예산을 설정하여 지출을 관리하고 재무 목표를 달성하세요.';
	@override String get createDesc => '카테고리별 예산 한도를 설정하여 재무 관리를 도와드립니다.';
	@override String get newBudget => '새 예산';
	@override String get budgetAmountLabel => '예산 금액';
	@override String get currency => '통화';
	@override String get periodSettings => '주기 설정';
	@override String get autoGenerateTransactions => '규칙에 따라 자동 거래 생성';
	@override String get cycle => '사이클';
	@override String get budgetCategory => '예산 카테고리';
	@override String get advancedOptions => '고급 옵션';
	@override String get periodType => '주기 유형';
	@override String get anchorDay => '시작일';
	@override String get selectPeriodType => '주기 유형 선택';
	@override String get selectAnchorDay => '시작일 선택';
	@override String get rolloverDescription => '남은 예산을 다음 주기로 이월';
	@override String get createBudget => '예산 생성';
	@override String get save => '저장';
	@override String get pleaseEnterAmount => '예산 금액을 입력하세요';
	@override String get invalidAmount => '유효한 금액을 입력하세요';
	@override String get updateSuccess => '예산이 업데이트되었습니다';
	@override String get createSuccess => '예산이 생성되었습니다';
	@override String get deleteSuccess => '예산이 삭제되었습니다';
	@override String get deleteFailed => '삭제 실패';
	@override String everyMonthDay({required Object day}) => '매월 ${day}일';
	@override String get periodWeekly => '매주';
	@override String get periodBiweekly => '2주마다';
	@override String get periodMonthly => '매월';
	@override String get periodYearly => '매년';
	@override String get statusActive => '진행 중';
	@override String get statusArchived => '보관됨';
	@override String get periodStatusOnTrack => '정상';
	@override String get periodStatusWarning => '경고';
	@override String get periodStatusExceeded => '초과';
	@override String get periodStatusAchieved => '달성';
	@override String usedPercent({required Object percent}) => '${percent}% 사용됨';
	@override String dayOfMonth({required Object day}) => '${day}일';
	@override String get tenThousandSuffix => '만';
	@override String get settingsLoadFailed => '설정을 불러오지 못했습니다';
	@override String get settingsSaveSuccess => '설정이 저장되었습니다';
	@override String get settingsSaveFailed => '저장 실패';
	@override String get settingsSave => '설정 저장';
	@override String get settingsWarningThreshold => '경고 임계값';
	@override String get settingsWarningDesc => '사용률이 이 비율에 도달하면 경고 상태 표시';
	@override String get settingsAlertThreshold => '초과 임계값';
	@override String get settingsAlertDesc => '사용률이 이 비율에 도달하면 초과 상태 표시';
	@override String get settingsThresholdOrder => '경고 임계값은 초과 임계값을 넘을 수 없습니다';
}

// Path: dateRange
class _Translations$dateRange$ko extends Translations$dateRange$zh {
	_Translations$dateRange$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get custom => '직접 선택';
	@override String get pickerTitle => '기간 선택';
	@override String get startDate => '시작일';
	@override String get endDate => '종료일';
	@override String get hint => '날짜 범위를 선택하세요';
}

// Path: forecast
class _Translations$forecast$ko extends Translations$forecast$zh {
	_Translations$forecast$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '예측';
	@override String get subtitle => '데이터 기반 스마트 현금 흐름 예측';
	@override String get financialNavigator => '안녕하세요, 재무 네비게이터입니다';
	@override String get financialMapSubtitle => '3단계만 거치면 미래 재무 지도를 그려드립니다';
	@override String get predictCashFlow => '미래 현금 흐름 예측';
	@override String get predictCashFlowDesc => '매일의 재무 상태를 확인하세요';
	@override String get aiSmartSuggestions => 'AI 스마트 제안';
	@override String get aiSmartSuggestionsDesc => '개인 맞춤형 재무 가이드';
	@override String get riskWarning => '리스크 경고';
	@override String get riskWarningDesc => '잠재적 재무 위험 조기 발견';
	@override String get analyzing => '재무 데이터를 분석하여 향후 30일간의 예측을 생성 중입니다';
	@override String get analyzePattern => '수입/지출 패턴 분석';
	@override String get calculateTrend => '현금 흐름 추세 계산';
	@override String get generateWarning => '위험 경고 생성';
	@override String get loadingForecast => '재무 예측 로딩 중...';
	@override String get todayLabel => '오늘';
	@override String get tomorrowLabel => '내일';
	@override String get balanceLabel => '잔액';
	@override String get noSpecialEvents => '특이 사항 없음';
	@override String get financialSafetyLine => '재무 안전선';
	@override String get currentSetting => '현재 설정';
	@override String get dailySpendingEstimate => '일일 소비 추정';
	@override String get adjustDailySpendingAmount => '일일 소비 예측 금액 조정';
	@override String get tellMeYourSafetyLine => '재무 "안전 기준선"이 얼마인가요?';
	@override String get safetyLineDescription => '통장에 유지하고 싶은 최소 잔액입니다. 이 금액에 가까워지면 알림을 드립니다.';
	@override String get dailySpendingQuestion => '하루 평균 소비액은 얼마인가요?';
	@override String get dailySpendingDescription => '식비, 교통비, 쇼핑 등을 포함합니다. 실제 기록을 통해 점점 더 정확해집니다.';
	@override String get perDay => '하루';
	@override String get referenceStandard => '참고 기준';
	@override String get frugalType => '절약형';
	@override String get comfortableType => '여유형';
	@override String get relaxedType => '넉넉형';
	@override String get frugalAmount => '1-2만원/일';
	@override String get comfortableAmount => '2-4만원/일';
	@override String get relaxedAmount => '4-6만원/일';
	@override late final _Translations$forecast$recurringTransaction$ko recurringTransaction = _Translations$forecast$recurringTransaction$ko._(_root);
}

// Path: chat
class _Translations$chat$ko extends Translations$chat$zh {
	_Translations$chat$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get newChat => '새 대화';
	@override String get noMessages => '표시할 메시지가 없습니다.';
	@override String get loadingFailed => '로딩 실패';
	@override String get inputMessage => '메시지 입력...';
	@override String get listening => '듣고 있어요...';
	@override String get aiThinking => '처리 중...';
	@override late final _Translations$chat$tools$ko tools = _Translations$chat$tools$ko._(_root);
	@override String get speechNotRecognized => '음성을 인식하지 못했습니다';
	@override String get currentExpense => '이번 지출';
	@override String get loadingComponent => '컴포넌트 로딩 중...';
	@override String get noHistory => '대화 내역 없음';
	@override String get startNewChat => '새로운 대화를 시작해보세요!';
	@override String get searchHint => '대화 검색';
	@override String get library => '라이브러리';
	@override String get viewProfile => '프로필 보기';
	@override String get noRelatedFound => '관련 대화를 찾을 수 없습니다';
	@override String get tryOtherKeywords => '다른 키워드로 검색해보세요';
	@override String get searchFailed => '검색 실패';
	@override String get deleteConversation => '대화 삭제';
	@override String get deleteConversationConfirm => '이 대화를 삭제하시겠습니까? 이 작업은 취소할 수 없습니다.';
	@override String get conversationDeleted => '대화가 삭제되었습니다';
	@override String get deleteConversationFailed => '대화 삭제 실패';
	@override late final _Translations$chat$transferWizard$ko transferWizard = _Translations$chat$transferWizard$ko._(_root);
	@override late final _Translations$chat$genui$ko genui = _Translations$chat$genui$ko._(_root);
	@override late final _Translations$chat$welcome$ko welcome = _Translations$chat$welcome$ko._(_root);
}

// Path: footprint
class _Translations$footprint$ko extends Translations$footprint$zh {
	_Translations$footprint$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get searchIn => '검색';
	@override String get searchInAllRecords => '모든 기록에서 검색';
}

// Path: media
class _Translations$media$ko extends Translations$media$zh {
	_Translations$media$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get selectPhotos => '사진 선택';
	@override String get addFiles => '파일 추가';
	@override String get takePhoto => '사진 찍기';
	@override String get camera => '카메라';
	@override String get photos => '사진';
	@override String get files => '파일';
	@override String get showAll => '모두 보기';
	@override String get allPhotos => '모든 사진';
	@override String get takingPhoto => '사진 찍는 중...';
	@override String get photoTaken => '사진이 저장되었습니다';
	@override String get cameraPermissionRequired => '카메라 권한이 필요합니다';
	@override String get fileSizeExceeded => '파일 용량이 10MB를 초과했습니다';
	@override String get unsupportedFormat => '지원하지 않는 파일 형식입니다';
	@override String get permissionDenied => '갤러리 접근 권한이 필요합니다';
	@override String get storageInsufficient => '저장 공간이 부족합니다';
	@override String get networkError => '네트워크 오류';
	@override String get unknownUploadError => '업로드 중 알 수 없는 오류 발생';
}

// Path: error
class _Translations$error$ko extends Translations$error$zh {
	_Translations$error$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get permissionRequired => '권한 필요';
	@override String get permissionInstructions => '파일 선택 및 업로드를 위해 설정에서 권한을 허용해주세요.';
	@override String get openSettings => '설정 열기';
	@override String get fileTooLarge => '파일이 너무 큽니다';
	@override String get fileSizeHint => '10MB 이하의 파일을 선택하거나 압축 후 업로드하세요.';
	@override String get supportedFormatsHint => '지원 형식: 이미지, PDF, 문서, 음성/영상 등';
	@override String get storageCleanupHint => '저장 공간을 확보하거나 더 작은 파일을 선택하세요.';
	@override String get networkErrorHint => '네트워크 연결 확인 후 다시 시도하세요.';
	@override String get platformNotSupported => '지원하지 않는 플랫폼';
	@override String get fileReadError => '파일 읽기 실패';
	@override String get fileReadErrorHint => '파일이 손상되었거나 다른 프로그램에서 사용 중일 수 있습니다.';
	@override String get validationError => '파일 검증 실패';
	@override String get unknownError => '알 수 없는 오류';
	@override String get unknownErrorHint => '예기치 않은 오류가 발생했습니다. 다시 시도하거나 고객 지원에 문의하세요.';
	@override late final _Translations$error$genui$ko genui = _Translations$error$genui$ko._(_root);
}

// Path: fontTest
class _Translations$fontTest$ko extends Translations$fontTest$zh {
	_Translations$fontTest$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get page => '글꼴 테스트 페이지';
	@override String get displayTest => '글꼴 표시 테스트';
	@override String get chineseTextTest => '중국어 텍스트 테스트';
	@override String get englishTextTest => '영어 텍스트 테스트';
	@override String get sample1 => '글꼴 표시 효과 테스트를 위한 한글 텍스트입니다.';
	@override String get sample2 => '지출 카테고리 요약, 쇼핑 비중 최고';
	@override String get sample3 => 'AI 비서가 전문적인 재무 분석 서비스를 제공합니다';
	@override String get sample4 => '데이터 시각화 차트로 소비 추세를 확인하세요';
	@override String get sample5 => '카카오페이, 네이버페이, 신용카드 등 다양한 결제 수단';
}

// Path: wizard
class _Translations$wizard$ko extends Translations$wizard$zh {
	_Translations$wizard$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get nextStep => '다음';
	@override String get previousStep => '이전';
	@override String get completeMapping => '매핑 완료';
}

// Path: user
class _Translations$user$ko extends Translations$user$zh {
	_Translations$user$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get username => '사용자 이름';
	@override String get defaultEmail => 'user@example.com';
}

// Path: account
class _Translations$account$ko extends Translations$account$zh {
	_Translations$account$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get editTitle => '계좌 편집';
	@override String get addTitle => '새 계좌';
	@override String get selectTypeTitle => '계좌 유형 선택';
	@override String get nameLabel => '계좌 이름';
	@override String get amountLabel => '현재 잔액';
	@override String get currencyLabel => '통화';
	@override String get hiddenLabel => '숨기기';
	@override String get hiddenDesc => '계좌 목록에서 숨김';
	@override String get includeInNetWorthLabel => '자산 포함';
	@override String get includeInNetWorthDesc => '순자산 통계에 반영';
	@override String get nameHint => '예: 급여 통장';
	@override String get amountHint => '0.00';
	@override String get deleteAccount => '계좌 삭제';
	@override String get deleteConfirm => '이 계좌를 삭제하시겠습니까? 복구할 수 없습니다.';
	@override String get save => '수정사항 저장';
	@override String get assetsCategory => '자산';
	@override String get liabilitiesCategory => '부채/신용';
	@override String get cash => '현금/지갑';
	@override String get deposit => '예금';
	@override String get creditCard => '신용카드';
	@override String get investment => '투자';
	@override String get eWallet => '전자지갑';
	@override String get loan => '대출';
	@override String get receivable => '받을 돈';
	@override String get payable => '갚을 돈';
	@override String get other => '기타 계좌';
	@override late final _Translations$account$types$ko types = _Translations$account$types$ko._(_root);
}

// Path: financial
class _Translations$financial$ko extends Translations$financial$zh {
	_Translations$financial$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '금융';
	@override String get management => '금융 관리';
	@override String get netWorth => '총 순자산';
	@override String get assets => '총 자산';
	@override String get liabilities => '총 부채';
	@override String get noAccounts => '계좌 없음';
	@override String get addFirstAccount => '첫 번째 계좌를 추가해보세요';
	@override String get assetAccounts => '자산 계좌';
	@override String get liabilityAccounts => '부채 계좌';
	@override String get selectCurrency => '통화 선택';
	@override String get cancel => '취소';
	@override String get confirm => '확인';
	@override String get settings => '금융 설정';
	@override String get budgetManagement => '예산 관리';
	@override String get recurringTransactions => '정기 거래';
	@override String get safetyThreshold => '안전선';
	@override String get dailyBurnRate => '일일 소비';
	@override String get financialAssistant => '금융 비서';
	@override String get manageFinancialSettings => '금융 설정 관리';
	@override String get safetyThresholdSettings => '재무 안전선 설정';
	@override String get setSafetyThreshold => '재무 안전 기준선 설정';
	@override String get safetyThresholdSaved => '재무 안전선 저장됨';
	@override String get dailyBurnRateSettings => '일일 소비 추정';
	@override String get setDailyBurnRate => '일일 예상 소비 금액 설정';
	@override String get dailyBurnRateSaved => '일일 소비 추정 금액 저장됨';
	@override String get dayUnit => '일';
	@override String get saveFailed => '저장 실패';
}

// Path: app
class _Translations$app$ko extends Translations$app$zh {
	_Translations$app$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get splashTitle => '지혜로운 성장, 가치 있는 부.';
	@override String get splashSubtitle => '스마트 금융 비서';
}

// Path: statistics
class _Translations$statistics$ko extends Translations$statistics$zh {
	_Translations$statistics$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '통계 분석';
	@override String get analyze => '통계 분석';
	@override String get exportInProgress => '내보내기 기능 개발 중...';
	@override String get ranking => '고액 소비 순위';
	@override String get noData => '데이터 없음';
	@override late final _Translations$statistics$overview$ko overview = _Translations$statistics$overview$ko._(_root);
	@override late final _Translations$statistics$trend$ko trend = _Translations$statistics$trend$ko._(_root);
	@override late final _Translations$statistics$analysis$ko analysis = _Translations$statistics$analysis$ko._(_root);
	@override late final _Translations$statistics$filter$ko filter = _Translations$statistics$filter$ko._(_root);
	@override late final _Translations$statistics$sort$ko sort = _Translations$statistics$sort$ko._(_root);
	@override String get exportList => '목록 내보내기';
	@override late final _Translations$statistics$emptyState$ko emptyState = _Translations$statistics$emptyState$ko._(_root);
	@override String get noMoreData => 'No more data';
}

// Path: currency
class _Translations$currency$ko extends Translations$currency$zh {
	_Translations$currency$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get cny => '위안';
	@override String get usd => '달러';
	@override String get eur => '유로';
	@override String get jpy => '엔';
	@override String get gbp => '파운드';
	@override String get aud => '호주 달러';
	@override String get cad => '캐나다 달러';
	@override String get chf => '스위스 프랑';
	@override String get rub => '러시아 루블';
	@override String get hkd => '홍콩 달러';
	@override String get twd => '대만 달러';
	@override String get inr => '인도 루피';
}

// Path: sharedSpace
class _Translations$sharedSpace$ko extends Translations$sharedSpace$zh {
	_Translations$sharedSpace$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override late final _Translations$sharedSpace$dashboard$ko dashboard = _Translations$sharedSpace$dashboard$ko._(_root);
	@override late final _Translations$sharedSpace$roles$ko roles = _Translations$sharedSpace$roles$ko._(_root);
	@override String get title => '공유 공간';
	@override late final _Translations$sharedSpace$create$ko create = _Translations$sharedSpace$create$ko._(_root);
	@override late final _Translations$sharedSpace$join$ko join = _Translations$sharedSpace$join$ko._(_root);
	@override late final _Translations$sharedSpace$list$ko list = _Translations$sharedSpace$list$ko._(_root);
	@override late final _Translations$sharedSpace$detail$ko detail = _Translations$sharedSpace$detail$ko._(_root);
	@override late final _Translations$sharedSpace$notifications$ko notifications = _Translations$sharedSpace$notifications$ko._(_root);
	@override late final _Translations$sharedSpace$inviteCard$ko inviteCard = _Translations$sharedSpace$inviteCard$ko._(_root);
	@override late final _Translations$sharedSpace$inviteSuccess$ko inviteSuccess = _Translations$sharedSpace$inviteSuccess$ko._(_root);
	@override late final _Translations$sharedSpace$notificationCard$ko notificationCard = _Translations$sharedSpace$notificationCard$ko._(_root);
	@override late final _Translations$sharedSpace$spaceCard$ko spaceCard = _Translations$sharedSpace$spaceCard$ko._(_root);
	@override late final _Translations$sharedSpace$settings$ko settings = _Translations$sharedSpace$settings$ko._(_root);
}

// Path: budgetSuggestion
class _Translations$budgetSuggestion$ko extends Translations$budgetSuggestion$zh {
	_Translations$budgetSuggestion$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String highPercentage({required Object category, required Object percentage}) => '${category} accounts for ${percentage}% of spending. Consider setting a budget limit.';
	@override String monthlyIncrease({required Object percentage}) => 'Spending increased by ${percentage}% this month. Needs attention.';
	@override String frequentSmall({required Object category, required Object count}) => '${category} has ${count} small transactions. These might be subscriptions.';
	@override String get financialInsights => 'Financial Insights';
}

// Path: server
class _Translations$server$ko extends Translations$server$zh {
	_Translations$server$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

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
	@override late final _Translations$server$error$ko error = _Translations$server$error$ko._(_root);
}

// Path: errorMapping
class _Translations$errorMapping$ko extends Translations$errorMapping$zh {
	_Translations$errorMapping$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override late final _Translations$errorMapping$generic$ko generic = _Translations$errorMapping$generic$ko._(_root);
	@override late final _Translations$errorMapping$auth$ko auth = _Translations$errorMapping$auth$ko._(_root);
	@override late final _Translations$errorMapping$transaction$ko transaction = _Translations$errorMapping$transaction$ko._(_root);
	@override late final _Translations$errorMapping$space$ko space = _Translations$errorMapping$space$ko._(_root);
	@override late final _Translations$errorMapping$recurring$ko recurring = _Translations$errorMapping$recurring$ko._(_root);
	@override late final _Translations$errorMapping$upload$ko upload = _Translations$errorMapping$upload$ko._(_root);
	@override late final _Translations$errorMapping$ai$ko ai = _Translations$errorMapping$ai$ko._(_root);
}

// Path: notification
class _Translations$notification$ko extends Translations$notification$zh {
	_Translations$notification$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '알림';
	@override String get markAllRead => '모두 읽음';
	@override String get empty => '알림이 없습니다';
	@override String get loadFailed => '로드 실패';
	@override String get retry => '재시도';
	@override String get justNow => '방금';
	@override String minutesAgo({required Object minutes}) => '${minutes}분 전';
	@override String hoursAgo({required Object hours}) => '${hours}시간 전';
	@override String daysAgo({required Object days}) => '${days}일 전';
	@override String get deleted => '삭제됨';
	@override late final _Translations$notification$types$ko types = _Translations$notification$types$ko._(_root);
	@override late final _Translations$notification$semantic$ko semantic = _Translations$notification$semantic$ko._(_root);
}

// Path: auth.email
class _Translations$auth$email$ko extends Translations$auth$email$zh {
	_Translations$auth$email$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get label => '이메일';
	@override String get placeholder => '이메일을 입력하세요';
	@override String get required => '이메일은 필수입니다';
	@override String get invalid => '유효한 이메일 주소를 입력하세요';
}

// Path: auth.password
class _Translations$auth$password$ko extends Translations$auth$password$zh {
	_Translations$auth$password$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get label => '비밀번호';
	@override String get placeholder => '비밀번호를 입력하세요';
	@override String get required => '비밀번호는 필수입니다';
	@override String get tooShort => '비밀번호는 6자 이상이어야 합니다';
	@override String get mustContainNumbersAndLetters => '비밀번호는 숫자와 영문자를 포함해야 합니다';
	@override String get confirm => '비밀번호 확인';
	@override String get confirmPlaceholder => '비밀번호를 다시 입력하세요';
	@override String get mismatch => '비밀번호가 일치하지 않습니다';
}

// Path: auth.verificationCode
class _Translations$auth$verificationCode$ko extends Translations$auth$verificationCode$zh {
	_Translations$auth$verificationCode$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get label => '인증번호';
	@override String get get => '번호 받기';
	@override String get sending => '전송 중...';
	@override String get sent => '인증번호가 전송되었습니다';
	@override String get sendFailed => '전송 실패';
	@override String get placeholder => '인증번호 입력';
	@override String get required => '인증번호는 필수입니다';
}

// Path: calendar.weekdays
class _Translations$calendar$weekdays$ko extends Translations$calendar$weekdays$zh {
	_Translations$calendar$weekdays$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get mon => '월';
	@override String get tue => '화';
	@override String get wed => '수';
	@override String get thu => '목';
	@override String get fri => '금';
	@override String get sat => '토';
	@override String get sun => '일';
}

// Path: appearance.palettes
class _Translations$appearance$palettes$ko extends Translations$appearance$palettes$zh {
	_Translations$appearance$palettes$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

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
class _Translations$forecast$recurringTransaction$ko extends Translations$forecast$recurringTransaction$zh {
	_Translations$forecast$recurringTransaction$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '정기 거래';
	@override String get all => '전체';
	@override String get expense => '지출';
	@override String get income => '수입';
	@override String get transfer => '이체';
	@override String get noRecurring => '정기 거래 없음';
	@override String get createHint => '정기 거래를 만들면 시스템이 자동으로 기록해줍니다';
	@override String get create => '정기 거래 생성';
	@override String get edit => '정기 거래 편집';
	@override String get newTransaction => '새 정기 거래';
	@override String deleteConfirm({required Object name}) => '정기 거래 「${name}」을 삭제하시겠습니까?';
	@override String activateConfirm({required Object name}) => '정기 거래 「${name}」을 활성화하시겠습니까?';
	@override String pauseConfirm({required Object name}) => '정기 거래 「${name}」을 일시 정지하시겠습니까?';
	@override String get created => '정기 거래가 생성되었습니다';
	@override String get updated => '정기 거래가 업데이트되었습니다';
	@override String get activated => '활성화됨';
	@override String get paused => '일시 정지됨';
	@override String get nextTime => '다음';
	@override String get sortByTime => '시간순 정렬';
	@override String get allPeriod => '모든 주기';
	@override String periodCount({required Object type, required Object count}) => '${type}주기 (${count})';
	@override String get confirmDelete => '삭제 확인';
	@override String get confirmActivate => '활성화 확인';
	@override String get confirmPause => '정지 확인';
	@override String get dynamicAmount => '동적 평균';
	@override String get dynamicAmountTitle => '금액 수동 확인 필요';
	@override String get dynamicAmountDescription => '알림이 오면 금액을 확인해야 기록이 완료됩니다.';
	@override String get confirmBeforeGeneration => '생성 전 확인';
	@override String get confirmBeforeGenerationDesc => '만기일에 대기 거래 생성, 수동 확인 후 기록';
	@override String get pendingTitle => '대기 거래';
	@override String pendingCount({required Object count}) => '${count} 건 대기';
	@override String get confirm => '확인';
	@override String get skip => '건너뛰기';
	@override String get noPending => '대기 거래 없음';
	@override String get confirmSuccess => '거래 확인됨';
	@override String get skipSuccess => '거래 건너뜀';
}

// Path: chat.tools
class _Translations$chat$tools$ko extends Translations$chat$tools$zh {
	_Translations$chat$tools$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get processing => '처리 중...';
	@override String get readFile => '파일 확인 중...';
	@override String get searchTransactions => '거래 조회 중...';
	@override String get queryBudgetStatus => '예산 확인 중...';
	@override String get createBudget => '예산 계획 생성 중...';
	@override String get getCashFlowAnalysis => '현금 흐름 분석 중...';
	@override String get getFinancialHealthScore => '재무 점수 계산 중...';
	@override String get getFinancialSummary => '재무 보고서 생성 중...';
	@override String get evaluateFinancialHealth => '재무 건강 평가 중...';
	@override String get forecastBalance => '잔액 예측 중...';
	@override String get simulateExpenseImpact => '구매 영향 시뮬레이션 중...';
	@override String get recordTransactions => '기록 중...';
	@override String get createTransaction => '기록 중...';
	@override String get duckduckgoSearch => '웹 검색 중...';
	@override String get executeTransfer => '이체 실행 중...';
	@override String get listDir => '디렉토리 탐색 중...';
	@override String get execute => '스크립트 실행 중...';
	@override String get analyzeFinance => '재무 분석 중...';
	@override String get forecastFinance => '재무 추세 예측 중...';
	@override String get analyzeBudget => '예산 분석 중...';
	@override String get auditAnalysis => '감사 분석 중...';
	@override String get budgetOps => '예산 처리 중...';
	@override String get createSharedTransaction => '공유 가계부 생성 중...';
	@override String get listSpaces => '공유 공간 목록 불러오는 중...';
	@override String get querySpaceSummary => '공간 요약 조회 중...';
	@override String get prepareTransfer => '이체 준비 중...';
	@override String get unknown => '요청 처리 중...';
	@override late final _Translations$chat$tools$done$ko done = _Translations$chat$tools$done$ko._(_root);
	@override late final _Translations$chat$tools$failed$ko failed = _Translations$chat$tools$failed$ko._(_root);
	@override String get analyzeSpending => 'Analyzing spendings...';
	@override String get analyzeCashflow => 'Analyzing cashflow...';
	@override String get suggestBudget => 'Suggesting budget...';
	@override String get cancelled => 'Cancelled';
	@override String get prepareBudgetSimulation => '예산 시뮬레이션 준비 중';
	@override String get simulateBudget => '예산 시뮬레이션 중';
}

// Path: chat.transferWizard
class _Translations$chat$transferWizard$ko extends Translations$chat$transferWizard$zh {
	_Translations$chat$transferWizard$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '이체 마법사';
	@override String get amount => '이체 금액';
	@override String get amountHint => '금액 입력';
	@override String get sourceAccount => '출금 계좌';
	@override String get targetAccount => '입금 계좌';
	@override String get selectAccount => '계좌 선택';
	@override String get confirmTransfer => '이체 확인';
	@override String get confirmed => '확인됨';
	@override String get transferSuccess => '이체 성공';
	@override String get selectReceiveAccount => '选择收款账户';
}

// Path: chat.genui
class _Translations$chat$genui$ko extends Translations$chat$genui$zh {
	_Translations$chat$genui$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override late final _Translations$chat$genui$expenseSummary$ko expenseSummary = _Translations$chat$genui$expenseSummary$ko._(_root);
	@override late final _Translations$chat$genui$transactionList$ko transactionList = _Translations$chat$genui$transactionList$ko._(_root);
	@override late final _Translations$chat$genui$transactionGroupReceipt$ko transactionGroupReceipt = _Translations$chat$genui$transactionGroupReceipt$ko._(_root);
	@override late final _Translations$chat$genui$transactionCard$ko transactionCard = _Translations$chat$genui$transactionCard$ko._(_root);
	@override late final _Translations$chat$genui$cashFlowCard$ko cashFlowCard = _Translations$chat$genui$cashFlowCard$ko._(_root);
	@override late final _Translations$chat$genui$budgetSimulator$ko budgetSimulator = _Translations$chat$genui$budgetSimulator$ko._(_root);
	@override late final _Translations$chat$genui$budgetReceipt$ko budgetReceipt = _Translations$chat$genui$budgetReceipt$ko._(_root);
	@override late final _Translations$chat$genui$budgetStatusCard$ko budgetStatusCard = _Translations$chat$genui$budgetStatusCard$ko._(_root);
	@override late final _Translations$chat$genui$cashFlowForecast$ko cashFlowForecast = _Translations$chat$genui$cashFlowForecast$ko._(_root);
	@override late final _Translations$chat$genui$healthScore$ko healthScore = _Translations$chat$genui$healthScore$ko._(_root);
	@override late final _Translations$chat$genui$spaceSelector$ko spaceSelector = _Translations$chat$genui$spaceSelector$ko._(_root);
	@override late final _Translations$chat$genui$transferPath$ko transferPath = _Translations$chat$genui$transferPath$ko._(_root);
	@override late final _Translations$chat$genui$transactionConfirmation$ko transactionConfirmation = _Translations$chat$genui$transactionConfirmation$ko._(_root);
	@override late final _Translations$chat$genui$budgetAnalysis$ko budgetAnalysis = _Translations$chat$genui$budgetAnalysis$ko._(_root);
}

// Path: chat.welcome
class _Translations$chat$welcome$ko extends Translations$chat$welcome$zh {
	_Translations$chat$welcome$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override late final _Translations$chat$welcome$morning$ko morning = _Translations$chat$welcome$morning$ko._(_root);
	@override late final _Translations$chat$welcome$midday$ko midday = _Translations$chat$welcome$midday$ko._(_root);
	@override late final _Translations$chat$welcome$afternoon$ko afternoon = _Translations$chat$welcome$afternoon$ko._(_root);
	@override late final _Translations$chat$welcome$evening$ko evening = _Translations$chat$welcome$evening$ko._(_root);
	@override late final _Translations$chat$welcome$night$ko night = _Translations$chat$welcome$night$ko._(_root);
}

// Path: error.genui
class _Translations$error$genui$ko extends Translations$error$genui$zh {
	_Translations$error$genui$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get loadingFailed => '컴포넌트 로드 실패';
	@override String get schemaFailed => '스키마 검증 실패';
	@override String get schemaDescription => '컴포넌트 정의가 GenUI 규격에 맞지 않아 텍스트로 표시합니다.';
	@override String get networkError => '네트워크 오류';
	@override String retryStatus({required Object retryCount, required Object maxRetries}) => '재시도 중 ${retryCount}/${maxRetries}';
	@override String get maxRetriesReached => '최대 재시도 횟수 도달';
}

// Path: account.types
class _Translations$account$types$ko extends Translations$account$types$zh {
	_Translations$account$types$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

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
class _Translations$statistics$overview$ko extends Translations$statistics$overview$zh {
	_Translations$statistics$overview$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get balance => '총 잔액';
	@override String get income => '총 수입';
	@override String get expense => '총 지출';
}

// Path: statistics.trend
class _Translations$statistics$trend$ko extends Translations$statistics$trend$zh {
	_Translations$statistics$trend$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '수지 추세';
	@override String get expense => '지출';
	@override String get income => '수입';
}

// Path: statistics.analysis
class _Translations$statistics$analysis$ko extends Translations$statistics$analysis$zh {
	_Translations$statistics$analysis$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '지출 분석';
	@override String get total => '합계';
	@override String get breakdown => '카테고리별 상세';
}

// Path: statistics.filter
class _Translations$statistics$filter$ko extends Translations$statistics$filter$zh {
	_Translations$statistics$filter$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get accountType => '계좌 유형';
	@override String get allAccounts => '모든 계좌';
	@override String get apply => '적용';
}

// Path: statistics.sort
class _Translations$statistics$sort$ko extends Translations$statistics$sort$zh {
	_Translations$statistics$sort$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get amount => '금액순';
	@override String get date => '날짜순';
}

// Path: statistics.emptyState
class _Translations$statistics$emptyState$ko extends Translations$statistics$emptyState$zh {
	_Translations$statistics$emptyState$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => 'Unlock Financial Insights';
	@override String get description => 'Your financial report is currently a blank canvas.\nRecord your first transaction and let the data tell your story.';
	@override String get action => 'Record First Transaction';
}

// Path: sharedSpace.dashboard
class _Translations$sharedSpace$dashboard$ko extends Translations$sharedSpace$dashboard$zh {
	_Translations$sharedSpace$dashboard$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get sectionTitle => '재무 개요';
	@override String get cumulativeTotalExpense => '누적 총 지출';
	@override String get participatingMembers => '참여 멤버';
	@override String membersCount({required Object count}) => '${count} 명';
	@override String get averagePerMember => '멤버별 평균';
	@override String get spendingDistribution => '멤버별 소비 분포';
	@override String get realtimeUpdates => '실시간 업데이트';
	@override String get paid => '결제 완료';
}

// Path: sharedSpace.roles
class _Translations$sharedSpace$roles$ko extends Translations$sharedSpace$roles$zh {
	_Translations$sharedSpace$roles$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get owner => '공간장';
	@override String get admin => '관리자';
	@override String get member => '멤버';
}

// Path: sharedSpace.create
class _Translations$sharedSpace$create$ko extends Translations$sharedSpace$create$zh {
	_Translations$sharedSpace$create$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '공유 공간 만들기';
	@override String get subtitle => '새로운 공유 공간을 만들어 친구와 함께 지출을 관리하세요';
	@override String get nameLabel => '공간 이름';
	@override String get nameHint => '예: 졸업 여행';
	@override String get descLabel => '설명 (선택)';
	@override String get descHint => '공동 여행 지출 기록';
	@override String get cancel => '취소';
	@override String get submit => '만들기';
	@override String get nameRequired => '공간 이름을 입력하세요';
	@override String get nameTooShort => '공간 이름은 2자 이상이어야 합니다';
	@override String get nameTooLong => '공간 이름은 50자를 초과할 수 없습니다';
}

// Path: sharedSpace.join
class _Translations$sharedSpace$join$ko extends Translations$sharedSpace$join$zh {
	_Translations$sharedSpace$join$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '공유 공간 참여';
	@override String get subtitle => '친구가 공유한 초대 코드를 입력하여 함께 가계를 관리하세요';
	@override String get codeLabel => '초대 코드';
	@override String get codeHint => '초대 코드 입력, 예: 123456';
	@override String get cancel => '취소';
	@override String get submit => '참여';
	@override String get codeRequired => '초대 코드를 입력하세요';
	@override String get codeInvalid => '초대 코드 형식이 잘못되었습니다';
	@override String get codeFormat => '초대 코드는 영문과 숫자만 사용할 수 있습니다';
}

// Path: sharedSpace.list
class _Translations$sharedSpace$list$ko extends Translations$sharedSpace$list$zh {
	_Translations$sharedSpace$list$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get emptyTitle => '협력 재무 공간 시작하기';
	@override String get emptySubtitle => '공유 공간을 생성하거나 참여하여 가족, 파트너, 팀과 함께 재무 및 자산을 관리하세요';
	@override String get getStarted => '시작하기';
	@override String get hasInviteCode => '초대 코드가 있으신가요? 탭하여 참여';
	@override String joinedSuccess({required Object name}) => '"${name}"에 참여했습니다!';
}

// Path: sharedSpace.detail
class _Translations$sharedSpace$detail$ko extends Translations$sharedSpace$detail$zh {
	_Translations$sharedSpace$detail$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get members => '멤버';
	@override String get transactions => '거래 내역';
	@override String recordsCount({required Object count}) => '${count}건';
	@override String get settlement => '정산';
	@override String get inviteCode => '초대 코드';
	@override String get copyCode => '초대 코드 복사';
	@override String codeCopied({required Object code}) => '초대 코드 복사됨: ${code}';
	@override String get validFor24h => '24시간 유효';
	@override String get leaveSpace => '공간 나가기';
	@override String get deleteSpace => '공간 삭제';
	@override String get removeMember => '멤버 제거';
	@override String get leaveConfirm => '이 공유 공간을 나가시겠습니까? 나간 후에는 거래 내역을 볼 수 없습니다.';
	@override String get deleteConfirm => '이 공유 공간을 삭제하시겠습니까? 이 작업은 되돌릴 수 없으며 모든 멤버가 제거됩니다.';
	@override String get removeConfirm => '이 멤버를 공유 공간에서 제거하시겠습니까?';
	@override String get generatingCode => '초대 코드 생성 중...';
	@override String get loadFailed => '로드 실패';
	@override String get retry => '재시도';
	@override String get noTransactions => '거래 내역이 없습니다';
	@override String get noTransactionsHint => '이 공간의 거래가 여기에 표시됩니다';
	@override String get refreshCode => '코드 새로고침';
	@override String get joinOtherSpace => '다른 공간 참여';
}

// Path: sharedSpace.notifications
class _Translations$sharedSpace$notifications$ko extends Translations$sharedSpace$notifications$zh {
	_Translations$sharedSpace$notifications$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '알림';
	@override String get empty => '알림이 없습니다';
	@override String get emptyHint => '새로운 초대나 활동이 있으면\n여기에 알림이 표시됩니다';
	@override String get incompleteInfo => '초대 정보가 불완전합니다';
	@override String get inviteAccepted => '초대를 수락했습니다!';
	@override String get inviteRejected => '초대를 거절했습니다';
	@override String get allMarkedRead => '모두 읽음으로 표시';
}

// Path: sharedSpace.inviteCard
class _Translations$sharedSpace$inviteCard$ko extends Translations$sharedSpace$inviteCard$zh {
	_Translations$sharedSpace$inviteCard$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '초대 코드';
	@override String get subtitle => '친구와 공유하여 공간에 참여';
	@override String get copyCode => '초대 코드 복사';
	@override String get shareLink => '초대 링크 공유';
	@override String get codeCopied => '초대 코드 복사됨';
	@override String get noExpiry => '무기한';
	@override String get expired => '만료됨';
	@override String expiresInDays({required Object days}) => '${days}일 후 만료';
	@override String expiresInHours({required Object hours}) => '${hours}시간 후 만료';
	@override String expiresInMinutes({required Object minutes}) => '${minutes}분 후 만료';
	@override String get expiringSoon => '곧 만료';
	@override String shareText({required Object spaceName, required Object code, required Object link, required Object expiry}) => '공유 공간 "${spaceName}"에 초대되었습니다\n\n초대 코드: ${code}\n또는 링크를 클릭하여 직접 참여: ${link}\n\n초대 코드 ${expiry}';
}

// Path: sharedSpace.inviteSuccess
class _Translations$sharedSpace$inviteSuccess$ko extends Translations$sharedSpace$inviteSuccess$zh {
	_Translations$sharedSpace$inviteSuccess$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '생성 완료';
	@override String get subtitle => '공유 공간이 생성되었습니다';
	@override String get inviteLater => '나중에 초대';
	@override String get enterSpace => '공간 입장';
	@override String get generatingCode => '초대 코드 생성 중...';
	@override String get generateFailed => '초대 코드 생성 실패';
	@override String get codeCopied => '초대 코드 복사됨';
	@override String get retry => '재시도';
	@override String get codeLabel => '초대 코드';
	@override String get validHint => '24시간 유효 · 탭하여 복사';
}

// Path: sharedSpace.notificationCard
class _Translations$sharedSpace$notificationCard$ko extends Translations$sharedSpace$notificationCard$zh {
	_Translations$sharedSpace$notificationCard$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get accept => '수락';
	@override String get reject => '거절';
	@override String get unknownTime => '알 수 없는 시간';
	@override String get justNow => '방금';
}

// Path: sharedSpace.spaceCard
class _Translations$sharedSpace$spaceCard$ko extends Translations$sharedSpace$spaceCard$zh {
	_Translations$sharedSpace$spaceCard$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get noDescription => '설명 없음';
	@override String get creator => '생성자';
	@override String get member => '멤버';
	@override String membersCount({required Object count}) => '${count}명의 멤버';
	@override String transactionsCount({required Object count}) => '${count}건의 거래';
}

// Path: sharedSpace.settings
class _Translations$sharedSpace$settings$ko extends Translations$sharedSpace$settings$zh {
	_Translations$sharedSpace$settings$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '공간 설정';
	@override String get spaceInfo => '공간 정보';
	@override String get nameLabel => '공간 이름';
	@override String get descLabel => '공간 설명';
	@override String get save => '저장';
	@override String get saved => '저장되었습니다';
	@override String get saveFailed => '저장에 실패했습니다';
	@override String get memberManagement => '멤버 관리';
	@override String membersCount({required Object count}) => '${count} 명의 멤버';
	@override String removeMemberConfirm({required Object name}) => '"${name}"님을 공간에서 제거하시겠습니까?';
	@override String get removed => '멤버가 제거되었습니다';
	@override String get removeFailed => '제거에 실패했습니다';
	@override String get inviteManagement => '초대 관리';
	@override String get currentCode => '현재 초대 코드';
	@override String get generateNew => '새 코드 생성';
	@override String get noValidCode => '유효한 초대 코드가 없습니다';
	@override String get refreshCode => '코드 새로고침';
	@override String get refreshConfirm => '새 코드를 생성하면 기존 코드가 무효화됩니다. 계속하시겠습니까?';
	@override String get codeRefreshed => '초대 코드가 새로고침되었습니다';
	@override String get dangerZone => '위험 작업';
	@override String get editHint => '관리자만 편집 가능';
	@override String get edit => '편집';
	@override String get you => '나';
	@override String get pending => '대기 중';
	@override String get declined => '거절됨';
	@override String get setAsAdmin => '관리자로 설정';
	@override String get setAsMember => '멤버로 설정';
	@override String get changeRole => '역할 변경';
	@override String changeRoleConfirm({required Object name, required Object role}) => '"${name}"님의 역할을 "${role}"(으)로 변경하시겠습니까?';
	@override String get confirm => '확인';
	@override String get roleChanged => '역할이 변경되었습니다';
	@override String get roleChangeFailed => '역할 변경에 실패했습니다';
}

// Path: server.error
class _Translations$server$error$ko extends Translations$server$error$zh {
	_Translations$server$error$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get urlRequired => 'Server address is required';
	@override String get invalidUrl => 'Invalid URL format';
	@override String get connectionTimeout => 'Connection timed out';
	@override String get connectionRefused => 'Could not connect to server';
	@override String get sslError => 'SSL certificate error';
	@override String get serverError => 'Server error';
}

// Path: errorMapping.generic
class _Translations$errorMapping$generic$ko extends Translations$errorMapping$generic$zh {
	_Translations$errorMapping$generic$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

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
class _Translations$errorMapping$auth$ko extends Translations$errorMapping$auth$zh {
	_Translations$errorMapping$auth$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

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
class _Translations$errorMapping$transaction$ko extends Translations$errorMapping$transaction$zh {
	_Translations$errorMapping$transaction$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get commentEmpty => 'Comment content cannot be empty';
	@override String get invalidParent => 'Invalid parent comment ID';
	@override String get saveFailed => 'Failed to save comment';
	@override String get deleteFailed => 'Failed to delete comment';
	@override String get notExists => 'Transaction does not exist';
}

// Path: errorMapping.space
class _Translations$errorMapping$space$ko extends Translations$errorMapping$space$zh {
	_Translations$errorMapping$space$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

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
class _Translations$errorMapping$recurring$ko extends Translations$errorMapping$recurring$zh {
	_Translations$errorMapping$recurring$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get invalidRule => 'Invalid recurrence rule';
	@override String get ruleNotFound => 'Recurrence rule not found';
}

// Path: errorMapping.upload
class _Translations$errorMapping$upload$ko extends Translations$errorMapping$upload$zh {
	_Translations$errorMapping$upload$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get noFile => 'No file uploaded';
	@override String get tooLarge => 'File too large';
	@override String get unsupportedType => 'Unsupported file type';
	@override String get tooManyFiles => 'Too many files';
}

// Path: errorMapping.ai
class _Translations$errorMapping$ai$ko extends Translations$errorMapping$ai$zh {
	_Translations$errorMapping$ai$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get contextLimit => 'Context limit exceeded';
	@override String get tokenLimit => 'Insufficient tokens';
	@override String get emptyMessage => 'Empty user message';
}

// Path: notification.types
class _Translations$notification$types$ko extends Translations$notification$types$zh {
	_Translations$notification$types$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get system => '시스템';
	@override String get spaceInvite => '공간 초대';
	@override String get spaceActivity => '공간 활동';
	@override String get billComment => '청구서 댓글';
	@override String get budgetAlert => '예산 경고';
	@override String get transaction => '거래 알림';
}

// Path: notification.semantic
class _Translations$notification$semantic$ko extends Translations$notification$semantic$zh {
	_Translations$notification$semantic$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String memberJoined({required Object name}) => '${name}님이 공간에 참여했습니다';
	@override String memberJoinedDetail({required Object space}) => '새 멤버가 "${space}"에 참여했습니다';
	@override String welcome({required Object space}) => '"${space}"에 오신 것을 환영합니다';
	@override String newTransaction({required Object name}) => '${name}님이 새 지출을 기록했습니다';
	@override String newTransactionDetail({required Object amount, required Object space}) => '${amount}, "${space}"에서';
	@override String memberLeft({required Object name}) => '${name}님이 공간에서 나갔습니다';
	@override String get recurringPending => '정기 거래 확인 대기';
	@override String recurringPendingDetail({required Object description, required Object amount}) => '${description} ${amount}, 확인을 기다리고 있습니다';
}

// Path: chat.tools.done
class _Translations$chat$tools$done$ko extends Translations$chat$tools$done$zh {
	_Translations$chat$tools$done$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get readFile => '파일 확인 완료';
	@override String get searchTransactions => '거래 조회 완료';
	@override String get queryBudgetStatus => '예산 확인 완료';
	@override String get createBudget => '예산 생성 완료';
	@override String get getCashFlowAnalysis => '현금 흐름 분석 완료';
	@override String get getFinancialHealthScore => '점수 계산 완료';
	@override String get getFinancialSummary => '보고서 생성 완료';
	@override String get evaluateFinancialHealth => '평가 완료';
	@override String get forecastBalance => '예측 완료';
	@override String get simulateExpenseImpact => '시뮬레이션 완료';
	@override String get recordTransactions => '기록 완료';
	@override String get createTransaction => '기록 완료';
	@override String get duckduckgoSearch => '검색 완료';
	@override String get executeTransfer => '이체 완료';
	@override String get listDir => '탐색 완료';
	@override String get execute => '실행 완료';
	@override String get analyzeFinance => '분석 완료';
	@override String get forecastFinance => '예측 완료';
	@override String get analyzeBudget => '예산 분석 완료';
	@override String get auditAnalysis => '감사 완료';
	@override String get budgetOps => '처리 완료';
	@override String get createSharedTransaction => '공유 가계부 생성 완료';
	@override String get listSpaces => '공유 공간 조회 완료';
	@override String get querySpaceSummary => '요약 조회 완료';
	@override String get prepareTransfer => '준비 완료';
	@override String get unknown => '처리 완료';
	@override String get analyzeSpending => 'Spending analysis complete';
	@override String get analyzeCashflow => 'Cashflow analysis complete';
	@override String get suggestBudget => 'Budget suggestion complete';
	@override String get prepareBudgetSimulation => '예산 시뮬레이션 준비 완료';
	@override String get simulateBudget => '예산 시뮬레이션 완료';
}

// Path: chat.tools.failed
class _Translations$chat$tools$failed$ko extends Translations$chat$tools$failed$zh {
	_Translations$chat$tools$failed$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get unknown => '작업 실패';
}

// Path: chat.genui.expenseSummary
class _Translations$chat$genui$expenseSummary$ko extends Translations$chat$genui$expenseSummary$zh {
	_Translations$chat$genui$expenseSummary$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get totalExpense => '총 지출';
	@override String get mainExpenses => '주요 지출';
	@override String viewAll({required Object count}) => '전체 ${count}건 보기';
	@override String get details => '소비 상세';
}

// Path: chat.genui.transactionList
class _Translations$chat$genui$transactionList$ko extends Translations$chat$genui$transactionList$zh {
	_Translations$chat$genui$transactionList$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String searchResults({required Object count}) => '검색 결과 (${count})';
	@override String loaded({required Object count}) => '${count}건 로드됨';
	@override String get noResults => '검색 결과 없음';
	@override String get loadMore => '더 보기';
	@override String get allLoaded => '모두 불러왔습니다';
}

// Path: chat.genui.transactionGroupReceipt
class _Translations$chat$genui$transactionGroupReceipt$ko extends Translations$chat$genui$transactionGroupReceipt$zh {
	_Translations$chat$genui$transactionGroupReceipt$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '기록 성공';
	@override String count({required Object count}) => '${count}건';
	@override String get selectAccount => '연결 계좌 선택';
	@override String get selectAccountSubtitle => '이 계좌가 위 모든 거래에 적용됩니다';
	@override String associatedAccount({required Object name}) => '연결된 계좌: ${name}';
	@override String get clickToAssociate => '계좌 연결(일괄 작업 지원)';
	@override String get associateSuccess => '모든 거래에 계좌 연결 성공';
	@override String associateFailed({required Object error}) => '작업 실패: ${error}';
	@override String get accountAssociation => '계좌 연결';
	@override String get sharedSpace => '공유 공간';
	@override String get notAssociated => '미연결';
	@override String get addSpace => '추가';
	@override String get selectSpace => '공유 공간 선택';
	@override String get spaceAssociateSuccess => '공유 공간 연결 성공';
	@override String spaceAssociateFailed({required Object error}) => '공유 공간 연결 실패: ${error}';
	@override String get currencyMismatchTitle => '통화 불일치';
	@override String get currencyMismatchDesc => '거래 통화와 계좌 통화가 다릅니다. 환율에 따라 계좌 잔액에서 차감됩니다.';
	@override String get transactionAmount => '거래 금액';
	@override String get accountCurrency => '계좌 통화';
	@override String get targetAccount => '대상 계좌';
	@override String get currencyMismatchNote => '참고: 현재 환율로 환산하여 잔액에서 차감합니다';
	@override String get confirmAssociate => '확인';
	@override String get total => 'Total';
	@override String spaceCount({required Object count}) => '${count} spaces';
}

// Path: chat.genui.transactionCard
class _Translations$chat$genui$transactionCard$ko extends Translations$chat$genui$transactionCard$zh {
	_Translations$chat$genui$transactionCard$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '거래 성공';
	@override String get associatedAccount => '연결된 계좌';
	@override String get notCounted => '자산 제외';
	@override String get modify => '수정';
	@override String get associate => '계좌 연결';
	@override String get selectAccount => '계좌 선택';
	@override String get noAccount => '계좌가 없습니다. 추가해주세요.';
	@override String get missingId => '거래 ID가 없습니다';
	@override String associatedTo({required Object name}) => '${name} 계좌 연결됨';
	@override String updateFailed({required Object error}) => '업데이트 실패: ${error}';
	@override String get sharedSpace => 'Shared Space';
	@override String get noSpace => 'No shared spaces available';
	@override String get selectSpace => 'Select Shared Space';
	@override String get linkedToSpace => 'Linked to shared space';
}

// Path: chat.genui.cashFlowCard
class _Translations$chat$genui$cashFlowCard$ko extends Translations$chat$genui$cashFlowCard$zh {
	_Translations$chat$genui$cashFlowCard$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '현금 흐름 분석';
	@override String savingsRate({required Object rate}) => '저축률 ${rate}%';
	@override String get totalIncome => '총수입';
	@override String get totalExpense => '총지출';
	@override String get essentialExpense => '필수 지출';
	@override String get discretionaryExpense => '선택적 소비';
	@override String get aiInsight => 'AI 분석';
}

// Path: chat.genui.budgetSimulator
class _Translations$chat$genui$budgetSimulator$ko extends Translations$chat$genui$budgetSimulator$zh {
	_Translations$chat$genui$budgetSimulator$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '예산 스트레스 시뮬레이터';
	@override String get targetAmount => '목표 예산 금액';
	@override String get overspendProbability => '초과 지출 확률';
	@override String get riskLow => '위험 매우 낮음';
	@override String get riskMedium => '위험 보통';
	@override String get riskHigh => '초과 위험 높음';
	@override String get evaluating => '소비 패턴 분석 중...';
	@override String get historyAverage => '역대 월 평균';
	@override String get dailyAllowance => '일일 한도';
	@override String get cancel => '취소';
	@override String get confirm => '이 예산 적용';
}

// Path: chat.genui.budgetReceipt
class _Translations$chat$genui$budgetReceipt$ko extends Translations$chat$genui$budgetReceipt$zh {
	_Translations$chat$genui$budgetReceipt$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get newBudget => 'New Budget';
	@override String get budgetCreated => 'Budget Created';
	@override String get rolloverBudget => 'Rollover Budget';
	@override String get createFailed => 'Failed to create budget';
	@override String get thisMonth => 'This Month';
	@override String dateRange({required Object start, required Object startDay, required Object end, required Object endDay}) => '${start}/${startDay} - ${end}/${endDay}';
}

// Path: chat.genui.budgetStatusCard
class _Translations$chat$genui$budgetStatusCard$ko extends Translations$chat$genui$budgetStatusCard$zh {
	_Translations$chat$genui$budgetStatusCard$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

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
class _Translations$chat$genui$cashFlowForecast$ko extends Translations$chat$genui$cashFlowForecast$zh {
	_Translations$chat$genui$cashFlowForecast$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

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
class _Translations$chat$genui$healthScore$ko extends Translations$chat$genui$healthScore$zh {
	_Translations$chat$genui$healthScore$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => 'Financial Health';
	@override String get suggestions => 'Suggestions';
	@override String scorePoint({required Object score}) => '${score} pts';
	@override late final _Translations$chat$genui$healthScore$status$ko status = _Translations$chat$genui$healthScore$status$ko._(_root);
}

// Path: chat.genui.spaceSelector
class _Translations$chat$genui$spaceSelector$ko extends Translations$chat$genui$spaceSelector$zh {
	_Translations$chat$genui$spaceSelector$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get selected => 'Selected';
	@override String get unnamedSpace => 'Unnamed Space';
	@override String get linked => 'Linked';
	@override String get roleOwner => 'Owner';
	@override String get roleAdmin => 'Admin';
	@override String get roleMember => 'Member';
}

// Path: chat.genui.transferPath
class _Translations$chat$genui$transferPath$ko extends Translations$chat$genui$transferPath$zh {
	_Translations$chat$genui$transferPath$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

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
class _Translations$chat$genui$transactionConfirmation$ko extends Translations$chat$genui$transactionConfirmation$zh {
	_Translations$chat$genui$transactionConfirmation$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get multipleAccounts => '检测到多个关联账户';
	@override String get confirmed => '已确认';
}

// Path: chat.genui.budgetAnalysis
class _Translations$chat$genui$budgetAnalysis$ko extends Translations$chat$genui$budgetAnalysis$zh {
	_Translations$chat$genui$budgetAnalysis$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

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
class _Translations$chat$welcome$morning$ko extends Translations$chat$welcome$morning$zh {
	_Translations$chat$welcome$morning$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get subtitle => 'Start your day by tracking';
	@override late final _Translations$chat$welcome$morning$breakfast$ko breakfast = _Translations$chat$welcome$morning$breakfast$ko._(_root);
	@override late final _Translations$chat$welcome$morning$yesterdayReview$ko yesterdayReview = _Translations$chat$welcome$morning$yesterdayReview$ko._(_root);
	@override late final _Translations$chat$welcome$morning$todayBudget$ko todayBudget = _Translations$chat$welcome$morning$todayBudget$ko._(_root);
}

// Path: chat.welcome.midday
class _Translations$chat$welcome$midday$ko extends Translations$chat$welcome$midday$zh {
	_Translations$chat$welcome$midday$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get greeting => 'Good Afternoon';
	@override String get subtitle => 'Quick record during lunch';
	@override late final _Translations$chat$welcome$midday$lunch$ko lunch = _Translations$chat$welcome$midday$lunch$ko._(_root);
	@override late final _Translations$chat$welcome$midday$weeklyExpense$ko weeklyExpense = _Translations$chat$welcome$midday$weeklyExpense$ko._(_root);
	@override late final _Translations$chat$welcome$midday$checkBalance$ko checkBalance = _Translations$chat$welcome$midday$checkBalance$ko._(_root);
}

// Path: chat.welcome.afternoon
class _Translations$chat$welcome$afternoon$ko extends Translations$chat$welcome$afternoon$zh {
	_Translations$chat$welcome$afternoon$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get subtitle => 'Tea time, let\'s review finances';
	@override late final _Translations$chat$welcome$afternoon$quickRecord$ko quickRecord = _Translations$chat$welcome$afternoon$quickRecord$ko._(_root);
	@override late final _Translations$chat$welcome$afternoon$analyzeSpending$ko analyzeSpending = _Translations$chat$welcome$afternoon$analyzeSpending$ko._(_root);
	@override late final _Translations$chat$welcome$afternoon$budgetProgress$ko budgetProgress = _Translations$chat$welcome$afternoon$budgetProgress$ko._(_root);
}

// Path: chat.welcome.evening
class _Translations$chat$welcome$evening$ko extends Translations$chat$welcome$evening$zh {
	_Translations$chat$welcome$evening$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get subtitle => 'End of day, time to balance the books';
	@override late final _Translations$chat$welcome$evening$dinner$ko dinner = _Translations$chat$welcome$evening$dinner$ko._(_root);
	@override late final _Translations$chat$welcome$evening$todaySummary$ko todaySummary = _Translations$chat$welcome$evening$todaySummary$ko._(_root);
	@override late final _Translations$chat$welcome$evening$tomorrowPlan$ko tomorrowPlan = _Translations$chat$welcome$evening$tomorrowPlan$ko._(_root);
}

// Path: chat.welcome.night
class _Translations$chat$welcome$night$ko extends Translations$chat$welcome$night$zh {
	_Translations$chat$welcome$night$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get greeting => 'Late Night';
	@override String get subtitle => 'Quiet time for financial planning';
	@override late final _Translations$chat$welcome$night$makeupRecord$ko makeupRecord = _Translations$chat$welcome$night$makeupRecord$ko._(_root);
	@override late final _Translations$chat$welcome$night$monthlyReview$ko monthlyReview = _Translations$chat$welcome$night$monthlyReview$ko._(_root);
	@override late final _Translations$chat$welcome$night$financialThinking$ko financialThinking = _Translations$chat$welcome$night$financialThinking$ko._(_root);
}

// Path: chat.genui.healthScore.status
class _Translations$chat$genui$healthScore$status$ko extends Translations$chat$genui$healthScore$status$zh {
	_Translations$chat$genui$healthScore$status$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get excellent => 'Excellent';
	@override String get good => 'Good';
	@override String get fair => 'Fair';
	@override String get needsImprovement => 'Needs Improvement';
	@override String get poor => 'Poor';
}

// Path: chat.welcome.morning.breakfast
class _Translations$chat$welcome$morning$breakfast$ko extends Translations$chat$welcome$morning$breakfast$zh {
	_Translations$chat$welcome$morning$breakfast$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => 'Breakfast';
	@override String get prompt => 'Record breakfast expense';
	@override String get description => 'Log today\'s first expense';
}

// Path: chat.welcome.morning.yesterdayReview
class _Translations$chat$welcome$morning$yesterdayReview$ko extends Translations$chat$welcome$morning$yesterdayReview$zh {
	_Translations$chat$welcome$morning$yesterdayReview$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => 'Yesterday Review';
	@override String get prompt => 'Analyze yesterday\'s spending';
	@override String get description => 'Check how much you spent yesterday';
}

// Path: chat.welcome.morning.todayBudget
class _Translations$chat$welcome$morning$todayBudget$ko extends Translations$chat$welcome$morning$todayBudget$zh {
	_Translations$chat$welcome$morning$todayBudget$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => 'Today\'s Budget';
	@override String get prompt => 'How much budget left for today';
	@override String get description => 'Plan your spending for today';
}

// Path: chat.welcome.midday.lunch
class _Translations$chat$welcome$midday$lunch$ko extends Translations$chat$welcome$midday$lunch$zh {
	_Translations$chat$welcome$midday$lunch$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => 'Lunch';
	@override String get prompt => 'Record lunch expense';
	@override String get description => 'Log your lunch spending';
}

// Path: chat.welcome.midday.weeklyExpense
class _Translations$chat$welcome$midday$weeklyExpense$ko extends Translations$chat$welcome$midday$weeklyExpense$zh {
	_Translations$chat$welcome$midday$weeklyExpense$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => 'Weekly Spending';
	@override String get prompt => 'Analyze this week\'s spending';
	@override String get description => 'See your weekly expenses';
}

// Path: chat.welcome.midday.checkBalance
class _Translations$chat$welcome$midday$checkBalance$ko extends Translations$chat$welcome$midday$checkBalance$zh {
	_Translations$chat$welcome$midday$checkBalance$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => 'Check Balance';
	@override String get prompt => 'Check my account balance';
	@override String get description => 'View your account balances';
}

// Path: chat.welcome.afternoon.quickRecord
class _Translations$chat$welcome$afternoon$quickRecord$ko extends Translations$chat$welcome$afternoon$quickRecord$zh {
	_Translations$chat$welcome$afternoon$quickRecord$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => 'Quick Record';
	@override String get prompt => 'Help me record an expense';
	@override String get description => 'Quickly log a transaction';
}

// Path: chat.welcome.afternoon.analyzeSpending
class _Translations$chat$welcome$afternoon$analyzeSpending$ko extends Translations$chat$welcome$afternoon$analyzeSpending$zh {
	_Translations$chat$welcome$afternoon$analyzeSpending$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => 'Analyze Spending';
	@override String get prompt => 'Analyze this month\'s spending';
	@override String get description => 'View spending trends and breakdown';
}

// Path: chat.welcome.afternoon.budgetProgress
class _Translations$chat$welcome$afternoon$budgetProgress$ko extends Translations$chat$welcome$afternoon$budgetProgress$zh {
	_Translations$chat$welcome$afternoon$budgetProgress$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => 'Budget Progress';
	@override String get prompt => 'Check budget status';
	@override String get description => 'See how your budget is doing';
}

// Path: chat.welcome.evening.dinner
class _Translations$chat$welcome$evening$dinner$ko extends Translations$chat$welcome$evening$dinner$zh {
	_Translations$chat$welcome$evening$dinner$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => 'Dinner';
	@override String get prompt => 'Record dinner expense';
	@override String get description => 'Log tonight\'s dinner spending';
}

// Path: chat.welcome.evening.todaySummary
class _Translations$chat$welcome$evening$todaySummary$ko extends Translations$chat$welcome$evening$todaySummary$zh {
	_Translations$chat$welcome$evening$todaySummary$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => 'Today\'s Summary';
	@override String get prompt => 'Summarize today\'s spending';
	@override String get description => 'See what you spent today';
}

// Path: chat.welcome.evening.tomorrowPlan
class _Translations$chat$welcome$evening$tomorrowPlan$ko extends Translations$chat$welcome$evening$tomorrowPlan$zh {
	_Translations$chat$welcome$evening$tomorrowPlan$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => 'Tomorrow\'s Plan';
	@override String get prompt => 'What fixed expenses tomorrow';
	@override String get description => 'Plan ahead for tomorrow';
}

// Path: chat.welcome.night.makeupRecord
class _Translations$chat$welcome$night$makeupRecord$ko extends Translations$chat$welcome$night$makeupRecord$zh {
	_Translations$chat$welcome$night$makeupRecord$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => 'Catch Up';
	@override String get prompt => 'Help me log any missed expenses';
	@override String get description => 'Record expenses you forgot today';
}

// Path: chat.welcome.night.monthlyReview
class _Translations$chat$welcome$night$monthlyReview$ko extends Translations$chat$welcome$night$monthlyReview$zh {
	_Translations$chat$welcome$night$monthlyReview$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => 'Monthly Review';
	@override String get prompt => 'Analyze this month\'s spending';
	@override String get description => 'Review your monthly expenses';
}

// Path: chat.welcome.night.financialThinking
class _Translations$chat$welcome$night$financialThinking$ko extends Translations$chat$welcome$night$financialThinking$zh {
	_Translations$chat$welcome$night$financialThinking$ko._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => 'Financial Tips';
	@override String get prompt => 'Give me some financial advice';
	@override String get description => 'Get AI-powered financial insights';
}

/// The flat map containing all translations for locale <ko>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsKo {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.loading' => '로딩 중...',
			'common.error' => '오류',
			'common.retry' => '재시도',
			'common.cancel' => '취소',
			'common.confirm' => '확인',
			'common.save' => '저장',
			'common.delete' => '삭제',
			'common.edit' => '편집',
			'common.add' => '추가',
			'common.search' => '검색',
			'common.filter' => '필터',
			'common.sort' => '정렬',
			'common.refresh' => '새로고침',
			'common.more' => '더 보기',
			'common.less' => '접기',
			'common.all' => '전체',
			'common.none' => '없음',
			'common.ok' => '확인',
			'common.unknown' => '알 수 없음',
			'common.noData' => '데이터가 없습니다',
			'common.loadMore' => '더 불러오기',
			'common.noMore' => '더 이상 없습니다',
			'common.loadFailed' => '불러오기 실패',
			'common.history' => '거래 내역',
			'common.reset' => '초기화',
			'time.today' => '오늘',
			'time.yesterday' => '어제',
			'time.dayBeforeYesterday' => '그저께',
			'time.thisWeek' => '이번 주',
			'time.thisMonth' => '이번 달',
			'time.thisYear' => '이번 해',
			'time.selectDate' => '날짜 선택',
			'time.selectTime' => '시간 선택',
			'time.justNow' => '방금',
			'time.minutesAgo' => ({required Object count}) => '${count}분 전',
			'time.hoursAgo' => ({required Object count}) => '${count}시간 전',
			'time.daysAgo' => ({required Object count}) => '${count}일 전',
			'time.weeksAgo' => ({required Object count}) => '${count}주 전',
			'greeting.morning' => '좋은 아침입니다',
			'greeting.afternoon' => '좋은 오후입니다',
			'greeting.evening' => '좋은 저녁입니다',
			'navigation.home' => '홈',
			'navigation.forecast' => '예측',
			'navigation.footprint' => '발자취',
			'navigation.profile' => '마이페이지',
			'auth.login' => '로그인',
			'auth.loggingIn' => '로그인 중...',
			'auth.logout' => '로그아웃',
			'auth.register' => '회원가입',
			'auth.registering' => '가입 중...',
			'auth.welcomeBack' => '다시 오신 것을 환영합니다',
			'auth.loginSuccess' => '반가워요!',
			'auth.loginFailed' => '로그인 실패',
			'auth.pleaseTryAgain' => '잠시 후 다시 시도해주세요.',
			'auth.loginSubtitle' => 'AI 가계부 도우미를 계속 사용하려면 로그인하세요',
			'auth.noAccount' => '계정이 없으신가요? 가입하기',
			'auth.createAccount' => '계정 만들기',
			'auth.setPassword' => '비밀번호 설정',
			'auth.setAccountPassword' => '계정 비밀번호를 설정하세요',
			'auth.completeRegistration' => '가입 완료',
			'auth.registrationSuccess' => '가입 성공!',
			'auth.registrationFailed' => '가입 실패',
			'auth.email.label' => '이메일',
			'auth.email.placeholder' => '이메일을 입력하세요',
			'auth.email.required' => '이메일은 필수입니다',
			'auth.email.invalid' => '유효한 이메일 주소를 입력하세요',
			'auth.password.label' => '비밀번호',
			'auth.password.placeholder' => '비밀번호를 입력하세요',
			'auth.password.required' => '비밀번호는 필수입니다',
			'auth.password.tooShort' => '비밀번호는 6자 이상이어야 합니다',
			'auth.password.mustContainNumbersAndLetters' => '비밀번호는 숫자와 영문자를 포함해야 합니다',
			'auth.password.confirm' => '비밀번호 확인',
			'auth.password.confirmPlaceholder' => '비밀번호를 다시 입력하세요',
			'auth.password.mismatch' => '비밀번호가 일치하지 않습니다',
			'auth.verificationCode.label' => '인증번호',
			'auth.verificationCode.get' => '번호 받기',
			'auth.verificationCode.sending' => '전송 중...',
			'auth.verificationCode.sent' => '인증번호가 전송되었습니다',
			'auth.verificationCode.sendFailed' => '전송 실패',
			'auth.verificationCode.placeholder' => '인증번호 입력',
			'auth.verificationCode.required' => '인증번호는 필수입니다',
			'auth.logoutSuccess' => 'Logged out successfully',
			'auth.confirmLogoutTitle' => 'Confirm Logout',
			'auth.confirmLogoutContent' => 'Are you sure you want to log out?',
			'transaction.expense' => '지출',
			'transaction.income' => '수입',
			'transaction.transfer' => '이체',
			'transaction.amount' => '금액',
			'transaction.category' => '카테고리',
			'transaction.description' => '설명',
			'transaction.tags' => '태그',
			'transaction.saveTransaction' => '내역 저장',
			'transaction.pleaseEnterAmount' => '금액을 입력하세요',
			'transaction.pleaseSelectCategory' => '카테고리를 선택하세요',
			'transaction.saveFailed' => '저장 실패',
			'transaction.descriptionHint' => '거래 상세 내용을 기록하세요...',
			'transaction.addCustomTag' => '커스텀 태그 추가',
			'transaction.commonTags' => '자주 쓰는 태그',
			'transaction.maxTagsHint' => ({required Object maxTags}) => '최대 ${maxTags}개의 태그를 추가할 수 있습니다',
			'transaction.noTransactionsFound' => '거래 내역을 찾을 수 없습니다',
			'transaction.tryAdjustingSearch' => '검색 조건을 변경하거나 새 내역을 작성해보세요',
			'transaction.noDescription' => '설명 없음',
			'transaction.payment' => '결제',
			'transaction.account' => '계좌',
			'transaction.time' => '시간',
			'transaction.location' => '장소',
			'transaction.transactionDetail' => '거래 상세',
			'transaction.favorite' => '즐겨찾기',
			'transaction.confirmDelete' => '삭제 확인',
			'transaction.deleteTransactionConfirm' => '이 거래 내역을 삭제하시겠습니까? 삭제 후에는 복구할 수 없습니다.',
			'transaction.noActions' => '사용 가능한 작업이 없습니다',
			'transaction.deleted' => '삭제됨',
			'transaction.deleteFailed' => '삭제 실패, 잠시 후 다시 시도해주세요',
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
			'home.totalExpense' => '총 소비 금액',
			'home.todayExpense' => '오늘 지출',
			'home.monthExpense' => '이번 달 지출',
			'home.yearProgress' => ({required Object year}) => '${year}년 진행률',
			'home.amountHidden' => '••••••••',
			'home.loadFailed' => '불러오기 실패',
			'home.noTransactions' => '거래 내역 없음',
			'home.tryRefresh' => '새로고침 해보세요',
			'home.noMoreData' => '더 이상 데이터가 없습니다',
			'home.userNotLoggedIn' => '로그인하지 않아 데이터를 불러올 수 없습니다',
			'comment.error' => '오류',
			'comment.commentFailed' => '댓글 작성 실패',
			'comment.replyToPrefix' => ({required Object name}) => '@${name} 님에게 답글:',
			'comment.reply' => '답글',
			'comment.addNote' => '메모 추가...',
			'comment.confirmDeleteTitle' => '삭제 확인',
			'comment.confirmDeleteContent' => '댓글을 삭제하시겠습니까? 복구할 수 없습니다.',
			'comment.success' => '성공',
			'comment.commentDeleted' => '댓글이 삭제되었습니다',
			'comment.deleteFailed' => '삭제 실패',
			'comment.deleteComment' => '댓글 삭제',
			'comment.hint' => '힌트',
			'comment.noActions' => '사용 가능한 작업이 없습니다',
			'comment.note' => '메모',
			'comment.noNote' => '메모 없음',
			'comment.loadFailed' => '메모 불러오기 실패',
			'calendar.title' => '소비 달력',
			'calendar.weekdays.mon' => '월',
			'calendar.weekdays.tue' => '화',
			'calendar.weekdays.wed' => '수',
			'calendar.weekdays.thu' => '목',
			'calendar.weekdays.fri' => '금',
			'calendar.weekdays.sat' => '토',
			'calendar.weekdays.sun' => '일',
			'calendar.loadFailed' => '달력 데이터 로드 실패',
			'calendar.thisMonth' => ({required Object amount}) => '이번 달: ${amount}',
			'calendar.counting' => '통계 중...',
			'calendar.unableToCount' => '통계 불가',
			'calendar.trend' => '추세: ',
			'calendar.noTransactionsTitle' => '해당 날짜에 거래 내역 없음',
			'calendar.loadTransactionFailed' => '거래 로드 실패',
			'category.dailyConsumption' => '일상 소비',
			'category.transportation' => '교통',
			'category.healthcare' => '의료/건강',
			'category.housing' => '주거',
			'category.education' => '교육',
			'category.incomeCategory' => '수입',
			'category.socialGifts' => '선물/경조사',
			'category.moneyTransfer' => '자금 이체',
			'category.other' => '기타',
			'category.foodDining' => '식비/외식',
			'category.shoppingRetail' => '쇼핑',
			'category.housingUtilities' => '주거/공과금',
			'category.personalCare' => '미용/개인관리',
			'category.entertainment' => '여가/오락',
			'category.medicalHealth' => '의료/건강',
			'category.insurance' => '보험',
			'category.socialGifting' => '경조사',
			'category.financialTax' => '금융/세금',
			'category.others' => '기타 지출',
			'category.salaryWage' => '급여',
			'category.businessTrade' => '사업/거래',
			'category.investmentReturns' => '투자 수익',
			'category.giftBonus' => '보너스/용돈',
			'category.refundRebate' => '환급/리베이트',
			'category.generalTransfer' => '이체',
			'category.debtRepayment' => '부채 상환',
			'settings.title' => '설정',
			'settings.language' => '언어',
			'settings.languageSettings' => '언어 설정',
			'settings.selectLanguage' => '언어 선택',
			'settings.languageChanged' => '언어가 변경되었습니다',
			'settings.restartToApply' => '변경 사항을 적용하려면 앱을 재시작하세요',
			'settings.theme' => '테마',
			'settings.darkMode' => '다크 모드',
			'settings.lightMode' => '라이트 모드',
			'settings.systemMode' => '시스템 설정에 맞춤',
			'settings.developerOptions' => '개발자 옵션',
			'settings.authDebug' => '인증 상태 디버깅',
			'settings.authDebugSubtitle' => '인증 상태 및 디버깅 정보 확인',
			'settings.fontTest' => '글꼴 테스트',
			'settings.fontTestSubtitle' => '앱 글꼴 표시 효과 테스트',
			'settings.helpAndFeedback' => '도움말 및 피드백',
			'settings.helpAndFeedbackSubtitle' => '도움 받기 또는 피드백 제공',
			'settings.aboutApp' => '앱 정보',
			'settings.aboutAppSubtitle' => '버전 정보 및 업데이트 확인',
			'settings.checkUpdate' => '업데이트 확인',
			'settings.checkingUpdate' => '업데이트 확인 중...',
			'settings.latestVersionToast' => '최신 버전을 사용 중입니다',
			'settings.newVersionTitle' => '새 버전 출시',
			'settings.updateNow' => '지금 업데이트',
			'settings.updateLater' => '나중에',
			'settings.fetchUpdateFailed' => '업데이트 확인 실패',
			'settings.currencyChangedRefreshHint' => ({required Object currency}) => '${currency}로 변경되었습니다. 새 거래는 이 통화로 기록됩니다.',
			'settings.sharedSpace' => '공유 공간',
			'settings.speechRecognition' => '음성 인식',
			'settings.speechRecognitionSubtitle' => '음성 입력 파라미터 구성',
			'settings.amountDisplayStyle' => '금액 표시 스타일',
			'settings.currency' => '표시 통화',
			'settings.appearance' => '화면 설정',
			'settings.appearanceSubtitle' => '테마 모드 및 색상 구성',
			'settings.speechTest' => '음성 테스트',
			'settings.speechTestSubtitle' => 'WebSocket 음성 연결 테스트',
			'settings.userTypeRegular' => '일반 사용자',
			'settings.selectAmountStyle' => '금액 표시 스타일 선택',
			'settings.currencyDescription' => '선호하는 표시 통화를 선택하세요. 모든 금액이 이 통화로 표시됩니다.',
			'settings.amountStyleNotice' => 'Note: Amount styles are primarily applied to \'Transactions\' and \'Trends\'. To maintain visual clarity, \'Account Balances\' and \'Asset Summaries\' will remain in neutral colors.',
			'settings.editUsername' => 'Edit Username',
			'settings.enterUsername' => 'Enter username',
			'settings.usernameRequired' => 'Username is required',
			'settings.usernameUpdated' => 'Username updated',
			'settings.avatarUpdated' => 'Avatar updated',
			'settings.appearanceUpdated' => '外观设置已更新',
			'appearance.title' => '화면 설정',
			'appearance.themeMode' => '테마 모드',
			'appearance.light' => '라이트',
			'appearance.dark' => '다크',
			'appearance.system' => '시스템 설정',
			'appearance.colorScheme' => '색상 구성',
			'appearance.palettes.zinc' => 'Zinc',
			'appearance.palettes.slate' => 'Slate',
			'appearance.palettes.red' => 'Red',
			'appearance.palettes.rose' => 'Rose',
			'appearance.palettes.orange' => 'Orange',
			'appearance.palettes.green' => 'Green',
			'appearance.palettes.blue' => 'Blue',
			'appearance.palettes.yellow' => 'Yellow',
			'appearance.palettes.violet' => 'Violet',
			'speech.title' => '음성 인식 설정',
			'speech.service' => '음성 인식 서비스',
			'speech.systemVoice' => '시스템 음성',
			'speech.systemVoiceSubtitle' => '휴대폰 내장 음성 인식 서비스(권장)',
			'speech.selfHostedASR' => '자체 구축 ASR 서비스',
			'speech.selfHostedASRSubtitle' => 'WebSocket을 통한 자체 서버 연결',
			'speech.serverConfig' => '서버 구성',
			'speech.serverAddress' => '서버 주소',
			'speech.port' => '포트',
			'speech.path' => '경로',
			'speech.saveConfig' => '구성 저장',
			'speech.info' => '정보',
			'speech.infoContent' => '• 시스템 음성: 기기 내장 서비스 사용, 설정 불필요, 빠른 응답\n• 자체 ASR: 커스텀 모델이나 오프라인 환경에 적합\n\n변경 사항은 다음 음성 입력 시 적용됩니다.',
			'speech.enterAddress' => '서버 주소를 입력하세요',
			'speech.enterValidPort' => '유효한 포트 번호를 입력하세요 (1-65535)',
			'speech.configSaved' => '구성이 저장되었습니다',
			'speech.systemVoiceRestrictedTitle' => '시스템 음성을 사용할 수 없음',
			'speech.systemVoiceRestrictedContent' => '기기 제조사 권한 제한으로 인해 시스템 음성을 사용할 수 없습니다. WebSocket 자작 ASR 설정을 권장합니다.',
			'speech.goToSettings' => '설정으로 이동',
			'speech.systemVoiceStatusAvailable' => '시스템 음성 지원됨',
			'speech.systemVoiceStatusRestricted' => '시스템 음성 제한됨 (자작 ASR 권장)',
			'amountTheme.chinaMarket' => '중국 시장 관습',
			'amountTheme.chinaMarketDesc' => '빨강 상승/초록 하락 (권장)',
			'amountTheme.international' => '국제 표준',
			'amountTheme.internationalDesc' => '초록 상승/빨강 하락',
			'amountTheme.minimalist' => '미니멀리스트',
			'amountTheme.minimalistDesc' => '기호로만 구분',
			'amountTheme.colorBlind' => '색약 지원',
			'amountTheme.colorBlindDesc' => '파랑-주황 색상 구성',
			'locale.chinese' => '简体中文',
			'locale.traditionalChinese' => '繁體中文',
			'locale.english' => 'English',
			'locale.japanese' => '日本語',
			'locale.korean' => '한국어',
			'budget.title' => '예산 관리',
			'budget.detail' => '예산 상세',
			'budget.info' => '예산 정보',
			'budget.totalBudget' => '총 예산',
			'budget.categoryBudget' => '카테고리 예산',
			'budget.monthlySummary' => '이번 달 예산 요약',
			'budget.used' => '사용함',
			'budget.remaining' => '남음',
			'budget.overspent' => '초과',
			'budget.budget' => '예산',
			'budget.loadFailed' => '불러오기 실패',
			'budget.noBudget' => '예산 없음',
			'budget.createHint' => '아래 버튼을 눌러 예산을 설정하세요',
			'budget.paused' => '일시 정지됨',
			'budget.pause' => '일시 정지',
			'budget.resume' => '재개',
			'budget.budgetPaused' => '예산 관리가 정지되었습니다',
			'budget.budgetResumed' => '예산 관리가 재개되었습니다',
			'budget.operationFailed' => '작업 실패',
			'budget.deleteBudget' => '예산 삭제',
			'budget.deleteConfirm' => '이 예산을 삭제하시겠습니까? 복구할 수 없습니다.',
			'budget.type' => '유형',
			'budget.category' => '카테고리',
			'budget.period' => '주기',
			'budget.rollover' => '이월 예산',
			'budget.rolloverBalance' => '이월 잔액',
			'budget.enabled' => '사용',
			'budget.disabled' => '사용 안 함',
			'budget.statusNormal' => '정상',
			'budget.statusWarning' => '한도 임박',
			'budget.statusOverspent' => '초과됨',
			'budget.statusAchieved' => '목표 달성',
			'budget.tipNormal' => ({required Object amount}) => '${amount} 더 쓸 수 있어요',
			'budget.tipWarning' => ({required Object amount}) => '${amount} 남았습니다. 주의하세요',
			'budget.tipOverspent' => ({required Object amount}) => '${amount} 초과 사용했습니다',
			'budget.tipAchieved' => '저축 목표 달성을 축하합니다!',
			'budget.remainingAmount' => ({required Object amount}) => '남은 금액 ${amount}',
			'budget.overspentAmount' => ({required Object amount}) => '초과 금액 ${amount}',
			'budget.budgetAmount' => ({required Object amount}) => '예산 금액 ${amount}',
			'budget.active' => '활성',
			'budget.all' => '전체',
			'budget.notFound' => '예산이 없거나 삭제되었습니다',
			'budget.setup' => '예산 설정',
			'budget.settings' => '예산 설정',
			'budget.setAmount' => '예산 금액 설정',
			'budget.setAmountDesc' => '각 카테고리별 예산 설정',
			'budget.monthly' => '월간 예산',
			'budget.monthlyDesc' => '월별 지출 관리(대부분에게 권장)',
			'budget.weekly' => '주간 예산',
			'budget.weeklyDesc' => '주별로 정밀하게 관리',
			'budget.yearly' => '연간 예산',
			'budget.yearlyDesc' => '장기적인 재무 계획용',
			'budget.editBudget' => '예산 편집',
			'budget.editBudgetDesc' => '금액 및 카테고리 수정',
			'budget.reminderSettings' => '알림 설정',
			'budget.reminderSettingsDesc' => '예산 알림 및 통지 설정',
			'budget.report' => '예산 보고서',
			'budget.reportDesc' => '상세한 예산 분석 보고서 보기',
			'budget.welcome' => '예산 관리에 오신 것을 환영합니다!',
			'budget.createNewPlan' => '새 예산 계획 만들기',
			'budget.welcomeDesc' => '예산을 설정하여 지출을 관리하고 재무 목표를 달성하세요.',
			'budget.createDesc' => '카테고리별 예산 한도를 설정하여 재무 관리를 도와드립니다.',
			'budget.newBudget' => '새 예산',
			'budget.budgetAmountLabel' => '예산 금액',
			'budget.currency' => '통화',
			'budget.periodSettings' => '주기 설정',
			'budget.autoGenerateTransactions' => '규칙에 따라 자동 거래 생성',
			'budget.cycle' => '사이클',
			'budget.budgetCategory' => '예산 카테고리',
			'budget.advancedOptions' => '고급 옵션',
			'budget.periodType' => '주기 유형',
			'budget.anchorDay' => '시작일',
			'budget.selectPeriodType' => '주기 유형 선택',
			'budget.selectAnchorDay' => '시작일 선택',
			'budget.rolloverDescription' => '남은 예산을 다음 주기로 이월',
			'budget.createBudget' => '예산 생성',
			'budget.save' => '저장',
			'budget.pleaseEnterAmount' => '예산 금액을 입력하세요',
			'budget.invalidAmount' => '유효한 금액을 입력하세요',
			'budget.updateSuccess' => '예산이 업데이트되었습니다',
			'budget.createSuccess' => '예산이 생성되었습니다',
			'budget.deleteSuccess' => '예산이 삭제되었습니다',
			'budget.deleteFailed' => '삭제 실패',
			'budget.everyMonthDay' => ({required Object day}) => '매월 ${day}일',
			'budget.periodWeekly' => '매주',
			'budget.periodBiweekly' => '2주마다',
			'budget.periodMonthly' => '매월',
			'budget.periodYearly' => '매년',
			'budget.statusActive' => '진행 중',
			'budget.statusArchived' => '보관됨',
			'budget.periodStatusOnTrack' => '정상',
			'budget.periodStatusWarning' => '경고',
			'budget.periodStatusExceeded' => '초과',
			'budget.periodStatusAchieved' => '달성',
			'budget.usedPercent' => ({required Object percent}) => '${percent}% 사용됨',
			'budget.dayOfMonth' => ({required Object day}) => '${day}일',
			'budget.tenThousandSuffix' => '만',
			'budget.settingsLoadFailed' => '설정을 불러오지 못했습니다',
			'budget.settingsSaveSuccess' => '설정이 저장되었습니다',
			'budget.settingsSaveFailed' => '저장 실패',
			'budget.settingsSave' => '설정 저장',
			'budget.settingsWarningThreshold' => '경고 임계값',
			'budget.settingsWarningDesc' => '사용률이 이 비율에 도달하면 경고 상태 표시',
			'budget.settingsAlertThreshold' => '초과 임계값',
			'budget.settingsAlertDesc' => '사용률이 이 비율에 도달하면 초과 상태 표시',
			'budget.settingsThresholdOrder' => '경고 임계값은 초과 임계값을 넘을 수 없습니다',
			'dateRange.custom' => '직접 선택',
			'dateRange.pickerTitle' => '기간 선택',
			'dateRange.startDate' => '시작일',
			'dateRange.endDate' => '종료일',
			'dateRange.hint' => '날짜 범위를 선택하세요',
			'forecast.title' => '예측',
			'forecast.subtitle' => '데이터 기반 스마트 현금 흐름 예측',
			'forecast.financialNavigator' => '안녕하세요, 재무 네비게이터입니다',
			'forecast.financialMapSubtitle' => '3단계만 거치면 미래 재무 지도를 그려드립니다',
			'forecast.predictCashFlow' => '미래 현금 흐름 예측',
			'forecast.predictCashFlowDesc' => '매일의 재무 상태를 확인하세요',
			'forecast.aiSmartSuggestions' => 'AI 스마트 제안',
			'forecast.aiSmartSuggestionsDesc' => '개인 맞춤형 재무 가이드',
			'forecast.riskWarning' => '리스크 경고',
			'forecast.riskWarningDesc' => '잠재적 재무 위험 조기 발견',
			'forecast.analyzing' => '재무 데이터를 분석하여 향후 30일간의 예측을 생성 중입니다',
			'forecast.analyzePattern' => '수입/지출 패턴 분석',
			'forecast.calculateTrend' => '현금 흐름 추세 계산',
			'forecast.generateWarning' => '위험 경고 생성',
			'forecast.loadingForecast' => '재무 예측 로딩 중...',
			'forecast.todayLabel' => '오늘',
			'forecast.tomorrowLabel' => '내일',
			'forecast.balanceLabel' => '잔액',
			'forecast.noSpecialEvents' => '특이 사항 없음',
			'forecast.financialSafetyLine' => '재무 안전선',
			'forecast.currentSetting' => '현재 설정',
			'forecast.dailySpendingEstimate' => '일일 소비 추정',
			'forecast.adjustDailySpendingAmount' => '일일 소비 예측 금액 조정',
			'forecast.tellMeYourSafetyLine' => '재무 "안전 기준선"이 얼마인가요?',
			'forecast.safetyLineDescription' => '통장에 유지하고 싶은 최소 잔액입니다. 이 금액에 가까워지면 알림을 드립니다.',
			'forecast.dailySpendingQuestion' => '하루 평균 소비액은 얼마인가요?',
			'forecast.dailySpendingDescription' => '식비, 교통비, 쇼핑 등을 포함합니다. 실제 기록을 통해 점점 더 정확해집니다.',
			'forecast.perDay' => '하루',
			'forecast.referenceStandard' => '참고 기준',
			'forecast.frugalType' => '절약형',
			'forecast.comfortableType' => '여유형',
			'forecast.relaxedType' => '넉넉형',
			'forecast.frugalAmount' => '1-2만원/일',
			'forecast.comfortableAmount' => '2-4만원/일',
			'forecast.relaxedAmount' => '4-6만원/일',
			'forecast.recurringTransaction.title' => '정기 거래',
			'forecast.recurringTransaction.all' => '전체',
			'forecast.recurringTransaction.expense' => '지출',
			'forecast.recurringTransaction.income' => '수입',
			'forecast.recurringTransaction.transfer' => '이체',
			'forecast.recurringTransaction.noRecurring' => '정기 거래 없음',
			'forecast.recurringTransaction.createHint' => '정기 거래를 만들면 시스템이 자동으로 기록해줍니다',
			'forecast.recurringTransaction.create' => '정기 거래 생성',
			'forecast.recurringTransaction.edit' => '정기 거래 편집',
			'forecast.recurringTransaction.newTransaction' => '새 정기 거래',
			'forecast.recurringTransaction.deleteConfirm' => ({required Object name}) => '정기 거래 「${name}」을 삭제하시겠습니까?',
			'forecast.recurringTransaction.activateConfirm' => ({required Object name}) => '정기 거래 「${name}」을 활성화하시겠습니까?',
			'forecast.recurringTransaction.pauseConfirm' => ({required Object name}) => '정기 거래 「${name}」을 일시 정지하시겠습니까?',
			'forecast.recurringTransaction.created' => '정기 거래가 생성되었습니다',
			'forecast.recurringTransaction.updated' => '정기 거래가 업데이트되었습니다',
			'forecast.recurringTransaction.activated' => '활성화됨',
			'forecast.recurringTransaction.paused' => '일시 정지됨',
			'forecast.recurringTransaction.nextTime' => '다음',
			'forecast.recurringTransaction.sortByTime' => '시간순 정렬',
			'forecast.recurringTransaction.allPeriod' => '모든 주기',
			'forecast.recurringTransaction.periodCount' => ({required Object type, required Object count}) => '${type}주기 (${count})',
			'forecast.recurringTransaction.confirmDelete' => '삭제 확인',
			'forecast.recurringTransaction.confirmActivate' => '활성화 확인',
			'forecast.recurringTransaction.confirmPause' => '정지 확인',
			'forecast.recurringTransaction.dynamicAmount' => '동적 평균',
			'forecast.recurringTransaction.dynamicAmountTitle' => '금액 수동 확인 필요',
			'forecast.recurringTransaction.dynamicAmountDescription' => '알림이 오면 금액을 확인해야 기록이 완료됩니다.',
			'forecast.recurringTransaction.confirmBeforeGeneration' => '생성 전 확인',
			'forecast.recurringTransaction.confirmBeforeGenerationDesc' => '만기일에 대기 거래 생성, 수동 확인 후 기록',
			'forecast.recurringTransaction.pendingTitle' => '대기 거래',
			'forecast.recurringTransaction.pendingCount' => ({required Object count}) => '${count} 건 대기',
			'forecast.recurringTransaction.confirm' => '확인',
			'forecast.recurringTransaction.skip' => '건너뛰기',
			'forecast.recurringTransaction.noPending' => '대기 거래 없음',
			'forecast.recurringTransaction.confirmSuccess' => '거래 확인됨',
			'forecast.recurringTransaction.skipSuccess' => '거래 건너뜀',
			'chat.newChat' => '새 대화',
			'chat.noMessages' => '표시할 메시지가 없습니다.',
			'chat.loadingFailed' => '로딩 실패',
			'chat.inputMessage' => '메시지 입력...',
			'chat.listening' => '듣고 있어요...',
			'chat.aiThinking' => '처리 중...',
			'chat.tools.processing' => '처리 중...',
			'chat.tools.readFile' => '파일 확인 중...',
			'chat.tools.searchTransactions' => '거래 조회 중...',
			'chat.tools.queryBudgetStatus' => '예산 확인 중...',
			'chat.tools.createBudget' => '예산 계획 생성 중...',
			'chat.tools.getCashFlowAnalysis' => '현금 흐름 분석 중...',
			'chat.tools.getFinancialHealthScore' => '재무 점수 계산 중...',
			'chat.tools.getFinancialSummary' => '재무 보고서 생성 중...',
			'chat.tools.evaluateFinancialHealth' => '재무 건강 평가 중...',
			'chat.tools.forecastBalance' => '잔액 예측 중...',
			'chat.tools.simulateExpenseImpact' => '구매 영향 시뮬레이션 중...',
			'chat.tools.recordTransactions' => '기록 중...',
			'chat.tools.createTransaction' => '기록 중...',
			'chat.tools.duckduckgoSearch' => '웹 검색 중...',
			'chat.tools.executeTransfer' => '이체 실행 중...',
			'chat.tools.listDir' => '디렉토리 탐색 중...',
			'chat.tools.execute' => '스크립트 실행 중...',
			'chat.tools.analyzeFinance' => '재무 분석 중...',
			'chat.tools.forecastFinance' => '재무 추세 예측 중...',
			'chat.tools.analyzeBudget' => '예산 분석 중...',
			'chat.tools.auditAnalysis' => '감사 분석 중...',
			'chat.tools.budgetOps' => '예산 처리 중...',
			'chat.tools.createSharedTransaction' => '공유 가계부 생성 중...',
			'chat.tools.listSpaces' => '공유 공간 목록 불러오는 중...',
			'chat.tools.querySpaceSummary' => '공간 요약 조회 중...',
			'chat.tools.prepareTransfer' => '이체 준비 중...',
			'chat.tools.unknown' => '요청 처리 중...',
			'chat.tools.done.readFile' => '파일 확인 완료',
			'chat.tools.done.searchTransactions' => '거래 조회 완료',
			'chat.tools.done.queryBudgetStatus' => '예산 확인 완료',
			'chat.tools.done.createBudget' => '예산 생성 완료',
			'chat.tools.done.getCashFlowAnalysis' => '현금 흐름 분석 완료',
			'chat.tools.done.getFinancialHealthScore' => '점수 계산 완료',
			'chat.tools.done.getFinancialSummary' => '보고서 생성 완료',
			'chat.tools.done.evaluateFinancialHealth' => '평가 완료',
			'chat.tools.done.forecastBalance' => '예측 완료',
			'chat.tools.done.simulateExpenseImpact' => '시뮬레이션 완료',
			'chat.tools.done.recordTransactions' => '기록 완료',
			'chat.tools.done.createTransaction' => '기록 완료',
			'chat.tools.done.duckduckgoSearch' => '검색 완료',
			'chat.tools.done.executeTransfer' => '이체 완료',
			'chat.tools.done.listDir' => '탐색 완료',
			'chat.tools.done.execute' => '실행 완료',
			'chat.tools.done.analyzeFinance' => '분석 완료',
			'chat.tools.done.forecastFinance' => '예측 완료',
			'chat.tools.done.analyzeBudget' => '예산 분석 완료',
			'chat.tools.done.auditAnalysis' => '감사 완료',
			_ => null,
		} ?? switch (path) {
			'chat.tools.done.budgetOps' => '처리 완료',
			'chat.tools.done.createSharedTransaction' => '공유 가계부 생성 완료',
			'chat.tools.done.listSpaces' => '공유 공간 조회 완료',
			'chat.tools.done.querySpaceSummary' => '요약 조회 완료',
			'chat.tools.done.prepareTransfer' => '준비 완료',
			'chat.tools.done.unknown' => '처리 완료',
			'chat.tools.done.analyzeSpending' => 'Spending analysis complete',
			'chat.tools.done.analyzeCashflow' => 'Cashflow analysis complete',
			'chat.tools.done.suggestBudget' => 'Budget suggestion complete',
			'chat.tools.done.prepareBudgetSimulation' => '예산 시뮬레이션 준비 완료',
			'chat.tools.done.simulateBudget' => '예산 시뮬레이션 완료',
			'chat.tools.failed.unknown' => '작업 실패',
			'chat.tools.analyzeSpending' => 'Analyzing spendings...',
			'chat.tools.analyzeCashflow' => 'Analyzing cashflow...',
			'chat.tools.suggestBudget' => 'Suggesting budget...',
			'chat.tools.cancelled' => 'Cancelled',
			'chat.tools.prepareBudgetSimulation' => '예산 시뮬레이션 준비 중',
			'chat.tools.simulateBudget' => '예산 시뮬레이션 중',
			'chat.speechNotRecognized' => '음성을 인식하지 못했습니다',
			'chat.currentExpense' => '이번 지출',
			'chat.loadingComponent' => '컴포넌트 로딩 중...',
			'chat.noHistory' => '대화 내역 없음',
			'chat.startNewChat' => '새로운 대화를 시작해보세요!',
			'chat.searchHint' => '대화 검색',
			'chat.library' => '라이브러리',
			'chat.viewProfile' => '프로필 보기',
			'chat.noRelatedFound' => '관련 대화를 찾을 수 없습니다',
			'chat.tryOtherKeywords' => '다른 키워드로 검색해보세요',
			'chat.searchFailed' => '검색 실패',
			'chat.deleteConversation' => '대화 삭제',
			'chat.deleteConversationConfirm' => '이 대화를 삭제하시겠습니까? 이 작업은 취소할 수 없습니다.',
			'chat.conversationDeleted' => '대화가 삭제되었습니다',
			'chat.deleteConversationFailed' => '대화 삭제 실패',
			'chat.transferWizard.title' => '이체 마법사',
			'chat.transferWizard.amount' => '이체 금액',
			'chat.transferWizard.amountHint' => '금액 입력',
			'chat.transferWizard.sourceAccount' => '출금 계좌',
			'chat.transferWizard.targetAccount' => '입금 계좌',
			'chat.transferWizard.selectAccount' => '계좌 선택',
			'chat.transferWizard.confirmTransfer' => '이체 확인',
			'chat.transferWizard.confirmed' => '확인됨',
			'chat.transferWizard.transferSuccess' => '이체 성공',
			'chat.transferWizard.selectReceiveAccount' => '选择收款账户',
			'chat.genui.expenseSummary.totalExpense' => '총 지출',
			'chat.genui.expenseSummary.mainExpenses' => '주요 지출',
			'chat.genui.expenseSummary.viewAll' => ({required Object count}) => '전체 ${count}건 보기',
			'chat.genui.expenseSummary.details' => '소비 상세',
			'chat.genui.transactionList.searchResults' => ({required Object count}) => '검색 결과 (${count})',
			'chat.genui.transactionList.loaded' => ({required Object count}) => '${count}건 로드됨',
			'chat.genui.transactionList.noResults' => '검색 결과 없음',
			'chat.genui.transactionList.loadMore' => '더 보기',
			'chat.genui.transactionList.allLoaded' => '모두 불러왔습니다',
			'chat.genui.transactionGroupReceipt.title' => '기록 성공',
			'chat.genui.transactionGroupReceipt.count' => ({required Object count}) => '${count}건',
			'chat.genui.transactionGroupReceipt.selectAccount' => '연결 계좌 선택',
			'chat.genui.transactionGroupReceipt.selectAccountSubtitle' => '이 계좌가 위 모든 거래에 적용됩니다',
			'chat.genui.transactionGroupReceipt.associatedAccount' => ({required Object name}) => '연결된 계좌: ${name}',
			'chat.genui.transactionGroupReceipt.clickToAssociate' => '계좌 연결(일괄 작업 지원)',
			'chat.genui.transactionGroupReceipt.associateSuccess' => '모든 거래에 계좌 연결 성공',
			'chat.genui.transactionGroupReceipt.associateFailed' => ({required Object error}) => '작업 실패: ${error}',
			'chat.genui.transactionGroupReceipt.accountAssociation' => '계좌 연결',
			'chat.genui.transactionGroupReceipt.sharedSpace' => '공유 공간',
			'chat.genui.transactionGroupReceipt.notAssociated' => '미연결',
			'chat.genui.transactionGroupReceipt.addSpace' => '추가',
			'chat.genui.transactionGroupReceipt.selectSpace' => '공유 공간 선택',
			'chat.genui.transactionGroupReceipt.spaceAssociateSuccess' => '공유 공간 연결 성공',
			'chat.genui.transactionGroupReceipt.spaceAssociateFailed' => ({required Object error}) => '공유 공간 연결 실패: ${error}',
			'chat.genui.transactionGroupReceipt.currencyMismatchTitle' => '통화 불일치',
			'chat.genui.transactionGroupReceipt.currencyMismatchDesc' => '거래 통화와 계좌 통화가 다릅니다. 환율에 따라 계좌 잔액에서 차감됩니다.',
			'chat.genui.transactionGroupReceipt.transactionAmount' => '거래 금액',
			'chat.genui.transactionGroupReceipt.accountCurrency' => '계좌 통화',
			'chat.genui.transactionGroupReceipt.targetAccount' => '대상 계좌',
			'chat.genui.transactionGroupReceipt.currencyMismatchNote' => '참고: 현재 환율로 환산하여 잔액에서 차감합니다',
			'chat.genui.transactionGroupReceipt.confirmAssociate' => '확인',
			'chat.genui.transactionGroupReceipt.total' => 'Total',
			'chat.genui.transactionGroupReceipt.spaceCount' => ({required Object count}) => '${count} spaces',
			'chat.genui.transactionCard.title' => '거래 성공',
			'chat.genui.transactionCard.associatedAccount' => '연결된 계좌',
			'chat.genui.transactionCard.notCounted' => '자산 제외',
			'chat.genui.transactionCard.modify' => '수정',
			'chat.genui.transactionCard.associate' => '계좌 연결',
			'chat.genui.transactionCard.selectAccount' => '계좌 선택',
			'chat.genui.transactionCard.noAccount' => '계좌가 없습니다. 추가해주세요.',
			'chat.genui.transactionCard.missingId' => '거래 ID가 없습니다',
			'chat.genui.transactionCard.associatedTo' => ({required Object name}) => '${name} 계좌 연결됨',
			'chat.genui.transactionCard.updateFailed' => ({required Object error}) => '업데이트 실패: ${error}',
			'chat.genui.transactionCard.sharedSpace' => 'Shared Space',
			'chat.genui.transactionCard.noSpace' => 'No shared spaces available',
			'chat.genui.transactionCard.selectSpace' => 'Select Shared Space',
			'chat.genui.transactionCard.linkedToSpace' => 'Linked to shared space',
			'chat.genui.cashFlowCard.title' => '현금 흐름 분석',
			'chat.genui.cashFlowCard.savingsRate' => ({required Object rate}) => '저축률 ${rate}%',
			'chat.genui.cashFlowCard.totalIncome' => '총수입',
			'chat.genui.cashFlowCard.totalExpense' => '총지출',
			'chat.genui.cashFlowCard.essentialExpense' => '필수 지출',
			'chat.genui.cashFlowCard.discretionaryExpense' => '선택적 소비',
			'chat.genui.cashFlowCard.aiInsight' => 'AI 분석',
			'chat.genui.budgetSimulator.title' => '예산 스트레스 시뮬레이터',
			'chat.genui.budgetSimulator.targetAmount' => '목표 예산 금액',
			'chat.genui.budgetSimulator.overspendProbability' => '초과 지출 확률',
			'chat.genui.budgetSimulator.riskLow' => '위험 매우 낮음',
			'chat.genui.budgetSimulator.riskMedium' => '위험 보통',
			'chat.genui.budgetSimulator.riskHigh' => '초과 위험 높음',
			'chat.genui.budgetSimulator.evaluating' => '소비 패턴 분석 중...',
			'chat.genui.budgetSimulator.historyAverage' => '역대 월 평균',
			'chat.genui.budgetSimulator.dailyAllowance' => '일일 한도',
			'chat.genui.budgetSimulator.cancel' => '취소',
			'chat.genui.budgetSimulator.confirm' => '이 예산 적용',
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
			'footprint.searchIn' => '검색',
			'footprint.searchInAllRecords' => '모든 기록에서 검색',
			'media.selectPhotos' => '사진 선택',
			'media.addFiles' => '파일 추가',
			'media.takePhoto' => '사진 찍기',
			'media.camera' => '카메라',
			'media.photos' => '사진',
			'media.files' => '파일',
			'media.showAll' => '모두 보기',
			'media.allPhotos' => '모든 사진',
			'media.takingPhoto' => '사진 찍는 중...',
			'media.photoTaken' => '사진이 저장되었습니다',
			'media.cameraPermissionRequired' => '카메라 권한이 필요합니다',
			'media.fileSizeExceeded' => '파일 용량이 10MB를 초과했습니다',
			'media.unsupportedFormat' => '지원하지 않는 파일 형식입니다',
			'media.permissionDenied' => '갤러리 접근 권한이 필요합니다',
			'media.storageInsufficient' => '저장 공간이 부족합니다',
			'media.networkError' => '네트워크 오류',
			'media.unknownUploadError' => '업로드 중 알 수 없는 오류 발생',
			'error.permissionRequired' => '권한 필요',
			'error.permissionInstructions' => '파일 선택 및 업로드를 위해 설정에서 권한을 허용해주세요.',
			'error.openSettings' => '설정 열기',
			'error.fileTooLarge' => '파일이 너무 큽니다',
			'error.fileSizeHint' => '10MB 이하의 파일을 선택하거나 압축 후 업로드하세요.',
			'error.supportedFormatsHint' => '지원 형식: 이미지, PDF, 문서, 음성/영상 등',
			'error.storageCleanupHint' => '저장 공간을 확보하거나 더 작은 파일을 선택하세요.',
			'error.networkErrorHint' => '네트워크 연결 확인 후 다시 시도하세요.',
			'error.platformNotSupported' => '지원하지 않는 플랫폼',
			'error.fileReadError' => '파일 읽기 실패',
			'error.fileReadErrorHint' => '파일이 손상되었거나 다른 프로그램에서 사용 중일 수 있습니다.',
			'error.validationError' => '파일 검증 실패',
			'error.unknownError' => '알 수 없는 오류',
			'error.unknownErrorHint' => '예기치 않은 오류가 발생했습니다. 다시 시도하거나 고객 지원에 문의하세요.',
			'error.genui.loadingFailed' => '컴포넌트 로드 실패',
			'error.genui.schemaFailed' => '스키마 검증 실패',
			'error.genui.schemaDescription' => '컴포넌트 정의가 GenUI 규격에 맞지 않아 텍스트로 표시합니다.',
			'error.genui.networkError' => '네트워크 오류',
			'error.genui.retryStatus' => ({required Object retryCount, required Object maxRetries}) => '재시도 중 ${retryCount}/${maxRetries}',
			'error.genui.maxRetriesReached' => '최대 재시도 횟수 도달',
			'fontTest.page' => '글꼴 테스트 페이지',
			'fontTest.displayTest' => '글꼴 표시 테스트',
			'fontTest.chineseTextTest' => '중국어 텍스트 테스트',
			'fontTest.englishTextTest' => '영어 텍스트 테스트',
			'fontTest.sample1' => '글꼴 표시 효과 테스트를 위한 한글 텍스트입니다.',
			'fontTest.sample2' => '지출 카테고리 요약, 쇼핑 비중 최고',
			'fontTest.sample3' => 'AI 비서가 전문적인 재무 분석 서비스를 제공합니다',
			'fontTest.sample4' => '데이터 시각화 차트로 소비 추세를 확인하세요',
			'fontTest.sample5' => '카카오페이, 네이버페이, 신용카드 등 다양한 결제 수단',
			'wizard.nextStep' => '다음',
			'wizard.previousStep' => '이전',
			'wizard.completeMapping' => '매핑 완료',
			'user.username' => '사용자 이름',
			'user.defaultEmail' => 'user@example.com',
			'account.editTitle' => '계좌 편집',
			'account.addTitle' => '새 계좌',
			'account.selectTypeTitle' => '계좌 유형 선택',
			'account.nameLabel' => '계좌 이름',
			'account.amountLabel' => '현재 잔액',
			'account.currencyLabel' => '통화',
			'account.hiddenLabel' => '숨기기',
			'account.hiddenDesc' => '계좌 목록에서 숨김',
			'account.includeInNetWorthLabel' => '자산 포함',
			'account.includeInNetWorthDesc' => '순자산 통계에 반영',
			'account.nameHint' => '예: 급여 통장',
			'account.amountHint' => '0.00',
			'account.deleteAccount' => '계좌 삭제',
			'account.deleteConfirm' => '이 계좌를 삭제하시겠습니까? 복구할 수 없습니다.',
			'account.save' => '수정사항 저장',
			'account.assetsCategory' => '자산',
			'account.liabilitiesCategory' => '부채/신용',
			'account.cash' => '현금/지갑',
			'account.deposit' => '예금',
			'account.creditCard' => '신용카드',
			'account.investment' => '투자',
			'account.eWallet' => '전자지갑',
			'account.loan' => '대출',
			'account.receivable' => '받을 돈',
			'account.payable' => '갚을 돈',
			'account.other' => '기타 계좌',
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
			'financial.title' => '금융',
			'financial.management' => '금융 관리',
			'financial.netWorth' => '총 순자산',
			'financial.assets' => '총 자산',
			'financial.liabilities' => '총 부채',
			'financial.noAccounts' => '계좌 없음',
			'financial.addFirstAccount' => '첫 번째 계좌를 추가해보세요',
			'financial.assetAccounts' => '자산 계좌',
			'financial.liabilityAccounts' => '부채 계좌',
			'financial.selectCurrency' => '통화 선택',
			'financial.cancel' => '취소',
			'financial.confirm' => '확인',
			'financial.settings' => '금융 설정',
			'financial.budgetManagement' => '예산 관리',
			'financial.recurringTransactions' => '정기 거래',
			'financial.safetyThreshold' => '안전선',
			'financial.dailyBurnRate' => '일일 소비',
			'financial.financialAssistant' => '금융 비서',
			'financial.manageFinancialSettings' => '금융 설정 관리',
			'financial.safetyThresholdSettings' => '재무 안전선 설정',
			'financial.setSafetyThreshold' => '재무 안전 기준선 설정',
			'financial.safetyThresholdSaved' => '재무 안전선 저장됨',
			'financial.dailyBurnRateSettings' => '일일 소비 추정',
			'financial.setDailyBurnRate' => '일일 예상 소비 금액 설정',
			'financial.dailyBurnRateSaved' => '일일 소비 추정 금액 저장됨',
			'financial.dayUnit' => '일',
			'financial.saveFailed' => '저장 실패',
			'app.splashTitle' => '지혜로운 성장, 가치 있는 부.',
			'app.splashSubtitle' => '스마트 금융 비서',
			'statistics.title' => '통계 분석',
			'statistics.analyze' => '통계 분석',
			'statistics.exportInProgress' => '내보내기 기능 개발 중...',
			'statistics.ranking' => '고액 소비 순위',
			'statistics.noData' => '데이터 없음',
			'statistics.overview.balance' => '총 잔액',
			'statistics.overview.income' => '총 수입',
			'statistics.overview.expense' => '총 지출',
			'statistics.trend.title' => '수지 추세',
			'statistics.trend.expense' => '지출',
			'statistics.trend.income' => '수입',
			'statistics.analysis.title' => '지출 분석',
			'statistics.analysis.total' => '합계',
			'statistics.analysis.breakdown' => '카테고리별 상세',
			'statistics.filter.accountType' => '계좌 유형',
			'statistics.filter.allAccounts' => '모든 계좌',
			'statistics.filter.apply' => '적용',
			'statistics.sort.amount' => '금액순',
			'statistics.sort.date' => '날짜순',
			'statistics.exportList' => '목록 내보내기',
			'statistics.emptyState.title' => 'Unlock Financial Insights',
			'statistics.emptyState.description' => 'Your financial report is currently a blank canvas.\nRecord your first transaction and let the data tell your story.',
			'statistics.emptyState.action' => 'Record First Transaction',
			'statistics.noMoreData' => 'No more data',
			'currency.cny' => '위안',
			'currency.usd' => '달러',
			'currency.eur' => '유로',
			'currency.jpy' => '엔',
			'currency.gbp' => '파운드',
			'currency.aud' => '호주 달러',
			'currency.cad' => '캐나다 달러',
			'currency.chf' => '스위스 프랑',
			'currency.rub' => '러시아 루블',
			'currency.hkd' => '홍콩 달러',
			'currency.twd' => '대만 달러',
			'currency.inr' => '인도 루피',
			'sharedSpace.dashboard.sectionTitle' => '재무 개요',
			'sharedSpace.dashboard.cumulativeTotalExpense' => '누적 총 지출',
			'sharedSpace.dashboard.participatingMembers' => '참여 멤버',
			'sharedSpace.dashboard.membersCount' => ({required Object count}) => '${count} 명',
			'sharedSpace.dashboard.averagePerMember' => '멤버별 평균',
			'sharedSpace.dashboard.spendingDistribution' => '멤버별 소비 분포',
			'sharedSpace.dashboard.realtimeUpdates' => '실시간 업데이트',
			'sharedSpace.dashboard.paid' => '결제 완료',
			'sharedSpace.roles.owner' => '공간장',
			'sharedSpace.roles.admin' => '관리자',
			'sharedSpace.roles.member' => '멤버',
			'sharedSpace.title' => '공유 공간',
			'sharedSpace.create.title' => '공유 공간 만들기',
			'sharedSpace.create.subtitle' => '새로운 공유 공간을 만들어 친구와 함께 지출을 관리하세요',
			'sharedSpace.create.nameLabel' => '공간 이름',
			'sharedSpace.create.nameHint' => '예: 졸업 여행',
			'sharedSpace.create.descLabel' => '설명 (선택)',
			'sharedSpace.create.descHint' => '공동 여행 지출 기록',
			'sharedSpace.create.cancel' => '취소',
			'sharedSpace.create.submit' => '만들기',
			'sharedSpace.create.nameRequired' => '공간 이름을 입력하세요',
			'sharedSpace.create.nameTooShort' => '공간 이름은 2자 이상이어야 합니다',
			'sharedSpace.create.nameTooLong' => '공간 이름은 50자를 초과할 수 없습니다',
			'sharedSpace.join.title' => '공유 공간 참여',
			'sharedSpace.join.subtitle' => '친구가 공유한 초대 코드를 입력하여 함께 가계를 관리하세요',
			'sharedSpace.join.codeLabel' => '초대 코드',
			'sharedSpace.join.codeHint' => '초대 코드 입력, 예: 123456',
			'sharedSpace.join.cancel' => '취소',
			'sharedSpace.join.submit' => '참여',
			'sharedSpace.join.codeRequired' => '초대 코드를 입력하세요',
			'sharedSpace.join.codeInvalid' => '초대 코드 형식이 잘못되었습니다',
			'sharedSpace.join.codeFormat' => '초대 코드는 영문과 숫자만 사용할 수 있습니다',
			'sharedSpace.list.emptyTitle' => '협력 재무 공간 시작하기',
			'sharedSpace.list.emptySubtitle' => '공유 공간을 생성하거나 참여하여 가족, 파트너, 팀과 함께 재무 및 자산을 관리하세요',
			'sharedSpace.list.getStarted' => '시작하기',
			'sharedSpace.list.hasInviteCode' => '초대 코드가 있으신가요? 탭하여 참여',
			'sharedSpace.list.joinedSuccess' => ({required Object name}) => '"${name}"에 참여했습니다!',
			'sharedSpace.detail.members' => '멤버',
			'sharedSpace.detail.transactions' => '거래 내역',
			'sharedSpace.detail.recordsCount' => ({required Object count}) => '${count}건',
			'sharedSpace.detail.settlement' => '정산',
			'sharedSpace.detail.inviteCode' => '초대 코드',
			'sharedSpace.detail.copyCode' => '초대 코드 복사',
			'sharedSpace.detail.codeCopied' => ({required Object code}) => '초대 코드 복사됨: ${code}',
			'sharedSpace.detail.validFor24h' => '24시간 유효',
			'sharedSpace.detail.leaveSpace' => '공간 나가기',
			'sharedSpace.detail.deleteSpace' => '공간 삭제',
			'sharedSpace.detail.removeMember' => '멤버 제거',
			'sharedSpace.detail.leaveConfirm' => '이 공유 공간을 나가시겠습니까? 나간 후에는 거래 내역을 볼 수 없습니다.',
			'sharedSpace.detail.deleteConfirm' => '이 공유 공간을 삭제하시겠습니까? 이 작업은 되돌릴 수 없으며 모든 멤버가 제거됩니다.',
			'sharedSpace.detail.removeConfirm' => '이 멤버를 공유 공간에서 제거하시겠습니까?',
			'sharedSpace.detail.generatingCode' => '초대 코드 생성 중...',
			'sharedSpace.detail.loadFailed' => '로드 실패',
			'sharedSpace.detail.retry' => '재시도',
			'sharedSpace.detail.noTransactions' => '거래 내역이 없습니다',
			'sharedSpace.detail.noTransactionsHint' => '이 공간의 거래가 여기에 표시됩니다',
			'sharedSpace.detail.refreshCode' => '코드 새로고침',
			'sharedSpace.detail.joinOtherSpace' => '다른 공간 참여',
			'sharedSpace.notifications.title' => '알림',
			'sharedSpace.notifications.empty' => '알림이 없습니다',
			'sharedSpace.notifications.emptyHint' => '새로운 초대나 활동이 있으면\n여기에 알림이 표시됩니다',
			'sharedSpace.notifications.incompleteInfo' => '초대 정보가 불완전합니다',
			'sharedSpace.notifications.inviteAccepted' => '초대를 수락했습니다!',
			'sharedSpace.notifications.inviteRejected' => '초대를 거절했습니다',
			'sharedSpace.notifications.allMarkedRead' => '모두 읽음으로 표시',
			'sharedSpace.inviteCard.title' => '초대 코드',
			'sharedSpace.inviteCard.subtitle' => '친구와 공유하여 공간에 참여',
			'sharedSpace.inviteCard.copyCode' => '초대 코드 복사',
			'sharedSpace.inviteCard.shareLink' => '초대 링크 공유',
			'sharedSpace.inviteCard.codeCopied' => '초대 코드 복사됨',
			'sharedSpace.inviteCard.noExpiry' => '무기한',
			'sharedSpace.inviteCard.expired' => '만료됨',
			'sharedSpace.inviteCard.expiresInDays' => ({required Object days}) => '${days}일 후 만료',
			'sharedSpace.inviteCard.expiresInHours' => ({required Object hours}) => '${hours}시간 후 만료',
			'sharedSpace.inviteCard.expiresInMinutes' => ({required Object minutes}) => '${minutes}분 후 만료',
			'sharedSpace.inviteCard.expiringSoon' => '곧 만료',
			'sharedSpace.inviteCard.shareText' => ({required Object spaceName, required Object code, required Object link, required Object expiry}) => '공유 공간 "${spaceName}"에 초대되었습니다\n\n초대 코드: ${code}\n또는 링크를 클릭하여 직접 참여: ${link}\n\n초대 코드 ${expiry}',
			'sharedSpace.inviteSuccess.title' => '생성 완료',
			'sharedSpace.inviteSuccess.subtitle' => '공유 공간이 생성되었습니다',
			'sharedSpace.inviteSuccess.inviteLater' => '나중에 초대',
			'sharedSpace.inviteSuccess.enterSpace' => '공간 입장',
			'sharedSpace.inviteSuccess.generatingCode' => '초대 코드 생성 중...',
			'sharedSpace.inviteSuccess.generateFailed' => '초대 코드 생성 실패',
			'sharedSpace.inviteSuccess.codeCopied' => '초대 코드 복사됨',
			'sharedSpace.inviteSuccess.retry' => '재시도',
			'sharedSpace.inviteSuccess.codeLabel' => '초대 코드',
			'sharedSpace.inviteSuccess.validHint' => '24시간 유효 · 탭하여 복사',
			'sharedSpace.notificationCard.accept' => '수락',
			'sharedSpace.notificationCard.reject' => '거절',
			'sharedSpace.notificationCard.unknownTime' => '알 수 없는 시간',
			'sharedSpace.notificationCard.justNow' => '방금',
			'sharedSpace.spaceCard.noDescription' => '설명 없음',
			'sharedSpace.spaceCard.creator' => '생성자',
			'sharedSpace.spaceCard.member' => '멤버',
			'sharedSpace.spaceCard.membersCount' => ({required Object count}) => '${count}명의 멤버',
			'sharedSpace.spaceCard.transactionsCount' => ({required Object count}) => '${count}건의 거래',
			'sharedSpace.settings.title' => '공간 설정',
			'sharedSpace.settings.spaceInfo' => '공간 정보',
			'sharedSpace.settings.nameLabel' => '공간 이름',
			'sharedSpace.settings.descLabel' => '공간 설명',
			'sharedSpace.settings.save' => '저장',
			'sharedSpace.settings.saved' => '저장되었습니다',
			'sharedSpace.settings.saveFailed' => '저장에 실패했습니다',
			'sharedSpace.settings.memberManagement' => '멤버 관리',
			'sharedSpace.settings.membersCount' => ({required Object count}) => '${count} 명의 멤버',
			'sharedSpace.settings.removeMemberConfirm' => ({required Object name}) => '"${name}"님을 공간에서 제거하시겠습니까?',
			'sharedSpace.settings.removed' => '멤버가 제거되었습니다',
			'sharedSpace.settings.removeFailed' => '제거에 실패했습니다',
			'sharedSpace.settings.inviteManagement' => '초대 관리',
			'sharedSpace.settings.currentCode' => '현재 초대 코드',
			'sharedSpace.settings.generateNew' => '새 코드 생성',
			'sharedSpace.settings.noValidCode' => '유효한 초대 코드가 없습니다',
			'sharedSpace.settings.refreshCode' => '코드 새로고침',
			'sharedSpace.settings.refreshConfirm' => '새 코드를 생성하면 기존 코드가 무효화됩니다. 계속하시겠습니까?',
			'sharedSpace.settings.codeRefreshed' => '초대 코드가 새로고침되었습니다',
			'sharedSpace.settings.dangerZone' => '위험 작업',
			'sharedSpace.settings.editHint' => '관리자만 편집 가능',
			'sharedSpace.settings.edit' => '편집',
			'sharedSpace.settings.you' => '나',
			_ => null,
		} ?? switch (path) {
			'sharedSpace.settings.pending' => '대기 중',
			'sharedSpace.settings.declined' => '거절됨',
			'sharedSpace.settings.setAsAdmin' => '관리자로 설정',
			'sharedSpace.settings.setAsMember' => '멤버로 설정',
			'sharedSpace.settings.changeRole' => '역할 변경',
			'sharedSpace.settings.changeRoleConfirm' => ({required Object name, required Object role}) => '"${name}"님의 역할을 "${role}"(으)로 변경하시겠습니까?',
			'sharedSpace.settings.confirm' => '확인',
			'sharedSpace.settings.roleChanged' => '역할이 변경되었습니다',
			'sharedSpace.settings.roleChangeFailed' => '역할 변경에 실패했습니다',
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
			'notification.title' => '알림',
			'notification.markAllRead' => '모두 읽음',
			'notification.empty' => '알림이 없습니다',
			'notification.loadFailed' => '로드 실패',
			'notification.retry' => '재시도',
			'notification.justNow' => '방금',
			'notification.minutesAgo' => ({required Object minutes}) => '${minutes}분 전',
			'notification.hoursAgo' => ({required Object hours}) => '${hours}시간 전',
			'notification.daysAgo' => ({required Object days}) => '${days}일 전',
			'notification.deleted' => '삭제됨',
			'notification.types.system' => '시스템',
			'notification.types.spaceInvite' => '공간 초대',
			'notification.types.spaceActivity' => '공간 활동',
			'notification.types.billComment' => '청구서 댓글',
			'notification.types.budgetAlert' => '예산 경고',
			'notification.types.transaction' => '거래 알림',
			'notification.semantic.memberJoined' => ({required Object name}) => '${name}님이 공간에 참여했습니다',
			'notification.semantic.memberJoinedDetail' => ({required Object space}) => '새 멤버가 "${space}"에 참여했습니다',
			'notification.semantic.welcome' => ({required Object space}) => '"${space}"에 오신 것을 환영합니다',
			'notification.semantic.newTransaction' => ({required Object name}) => '${name}님이 새 지출을 기록했습니다',
			'notification.semantic.newTransactionDetail' => ({required Object amount, required Object space}) => '${amount}, "${space}"에서',
			'notification.semantic.memberLeft' => ({required Object name}) => '${name}님이 공간에서 나갔습니다',
			'notification.semantic.recurringPending' => '정기 거래 확인 대기',
			'notification.semantic.recurringPendingDetail' => ({required Object description, required Object amount}) => '${description} ${amount}, 확인을 기다리고 있습니다',
			_ => null,
		};
	}
}
