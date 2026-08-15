import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/core/constants/error_codes.dart';

/// Utility class for translating backend error codes to localized messages.
///
/// Uses the generated i18n [t] object to provide localized strings based on
/// specific backend business error codes.
class ErrorTranslator {
  /// Lazily resolved lookup map from backend error code to localized message.
  ///
  /// Values are per-call *closures* so the current locale's strings are read
  /// at translation time. A `Map<int, String>` built once on first access
  /// would freeze every translation in the language active at that moment:
  /// after a runtime locale switch (LocaleService.saveLocale) business errors
  /// would keep the old language until app restart.
  static final Map<int, String Function()> _translations = _buildTranslators();

  static Map<int, String Function()> _buildTranslators() {
    return {
      // Generic Errors
      400: () => t.errorMapping.generic.badRequest,
      ErrorCodes.authFailed: () => t.errorMapping.generic.authFailed,
      ErrorCodes.permissionDenied: () =>
          t.errorMapping.generic.permissionDenied,
      ErrorCodes.notFound: () => t.errorMapping.generic.notFound,
      ErrorCodes.serverError: () => t.errorMapping.generic.serverError,
      ErrorCodes.systemInvalid: () => t.errorMapping.generic.systemError,
      ErrorCodes.validationError: () => t.errorMapping.generic.validationFailed,

      // Authentication (1000-1012)
      ErrorCodes.authenticateFailed: () => t.errorMapping.auth.failed,
      ErrorCodes.emailWrong: () => t.errorMapping.auth.emailWrong,
      ErrorCodes.phoneNumberWrong: () => t.errorMapping.auth.phoneWrong,
      ErrorCodes.phoneNumberRegistered: () =>
          t.errorMapping.auth.phoneRegistered,
      ErrorCodes.emailRegistered: () => t.errorMapping.auth.emailRegistered,
      ErrorCodes.sendCodeFailed: () => t.errorMapping.auth.sendFailed,
      ErrorCodes.codeExpired: () => t.errorMapping.auth.expired,
      ErrorCodes.codeSendTooFrequently: () => t.errorMapping.auth.tooFrequent,
      ErrorCodes.unsupportedCodeType: () => t.errorMapping.auth.unsupportedType,
      ErrorCodes.userNotMatchPassword: () => t.errorMapping.auth.wrongPassword,
      ErrorCodes.userNotExist: () => t.errorMapping.auth.userNotFound,
      ErrorCodes.noPreferencesParams: () => t.errorMapping.auth.prefsMissing,
      ErrorCodes.invalidClientTimezone: () =>
          t.errorMapping.auth.invalidTimezone,

      // Transaction (3000-3008)
      ErrorCodes.transactionCommentNull: () =>
          t.errorMapping.transaction.commentEmpty,
      ErrorCodes.invalidParentCommentId: () =>
          t.errorMapping.transaction.invalidParent,
      ErrorCodes.storeCommentFailed: () =>
          t.errorMapping.transaction.saveFailed,
      ErrorCodes.deleteCommentFailed: () =>
          t.errorMapping.transaction.deleteFailed,
      ErrorCodes.transactionNotExists: () =>
          t.errorMapping.transaction.notExists,
      ErrorCodes.invalidAccountId: () =>
          t.errorMapping.transaction.invalidAccountId,
      ErrorCodes.exchangeRateUnavailable: () =>
          t.errorMapping.transaction.exchangeRateUnavailable,
      ErrorCodes.transactionSystemReadonly: () =>
          t.errorMapping.transaction.systemReadonly,
      ErrorCodes.transactionAccountLinkClosed: () =>
          t.errorMapping.transaction.accountLinkClosed,

      // Shared Space (3100-3113)
      ErrorCodes.sharedSpaceNotExistsOrNoAccess: () =>
          t.errorMapping.space.notFound,
      ErrorCodes.noPermissionToInviteMembers: () =>
          t.errorMapping.space.inviteDenied,
      ErrorCodes.cannotInviteYourself: () => t.errorMapping.space.inviteSelf,
      ErrorCodes.invitationSent: () => t.errorMapping.space.inviteSent,
      ErrorCodes.alreadyMemberOrHasBeenInvited: () =>
          t.errorMapping.space.alreadyMember,
      ErrorCodes.invalidAction: () => t.errorMapping.space.invalidAction,
      ErrorCodes.invitationNotExists: () =>
          t.errorMapping.space.invitationNotFound,
      ErrorCodes.onlyOwnerCanDo: () => t.errorMapping.space.onlyOwner,
      ErrorCodes.ownerCannotBeRemoved: () =>
          t.errorMapping.space.ownerNotRemovable,
      ErrorCodes.memberNotExist: () => t.errorMapping.space.memberNotFound,
      ErrorCodes.notMemberInThisSpace: () => t.errorMapping.space.notMember,
      ErrorCodes.ownerCannotLeaveDirectly: () =>
          t.errorMapping.space.ownerCantLeave,
      ErrorCodes.invalidInvitationCode: () => t.errorMapping.space.invalidCode,
      ErrorCodes.invitationCodeExpiredOrLimited: () =>
          t.errorMapping.space.codeExpired,
      ErrorCodes.transactionAlreadyInSpace: () =>
          t.errorMapping.space.transactionAlreadyInSpace,

      // Recurring (3200-3201)
      ErrorCodes.invalidRecurrenceRule: () =>
          t.errorMapping.recurring.invalidRule,
      ErrorCodes.recurrenceRuleNotFound: () =>
          t.errorMapping.recurring.ruleNotFound,

      // Financial Account Lifecycle (3300-3311)
      ErrorCodes.accountNotFound: () => t.errorMapping.account.notFound,
      ErrorCodes.accountAlreadyClosed: () =>
          t.errorMapping.account.alreadyClosed,
      ErrorCodes.accountDeleteReferenced: () =>
          t.errorMapping.account.deleteReferenced,
      ErrorCodes.accountDeleteBalanceNotZero: () =>
          t.errorMapping.account.deleteBalanceNotZero,
      ErrorCodes.accountCloseRecurringActive: () =>
          t.errorMapping.account.closeRecurringActive,
      ErrorCodes.accountCloseTargetRequired: () =>
          t.errorMapping.account.closeTargetRequired,
      ErrorCodes.accountCloseTargetClosed: () =>
          t.errorMapping.account.closeTargetClosed,
      ErrorCodes.accountCloseTargetCurrencyMismatch: () =>
          t.errorMapping.account.closeTargetCurrencyMismatch,
      ErrorCodes.accountMergeSelf: () => t.errorMapping.account.mergeSelf,
      ErrorCodes.accountMergeCurrencyMismatch: () =>
          t.errorMapping.account.mergeCurrencyMismatch,
      ErrorCodes.accountMergeNatureMismatch: () =>
          t.errorMapping.account.mergeNatureMismatch,
      ErrorCodes.accountMergeClosedTarget: () =>
          t.errorMapping.account.mergeClosedTarget,
      ErrorCodes.accountDeleteClosedHasHistory: () =>
          t.errorMapping.account.deleteClosedHasHistory,

      // File Upload (4001-4022)
      ErrorCodes.noFileUploaded: () => t.errorMapping.upload.noFile,
      ErrorCodes.invalidFileUploaded: () => t.errorMapping.upload.invalidFile,
      ErrorCodes.fileTooLarge: () => t.errorMapping.upload.tooLarge,
      ErrorCodes.invalidFileType: () => t.errorMapping.upload.unsupportedType,
      ErrorCodes.invalidMimeType: () => t.errorMapping.upload.invalidMimeType,
      ErrorCodes.invalidImageContent: () =>
          t.errorMapping.upload.invalidImageContent,
      ErrorCodes.imageTooWide: () => t.errorMapping.upload.imageTooWide,
      ErrorCodes.imageTooHigh: () => t.errorMapping.upload.imageTooHigh,
      ErrorCodes.tooManyFiles: () => t.errorMapping.upload.tooManyFiles,
      ErrorCodes.totalSizeTooLarge: () =>
          t.errorMapping.upload.totalSizeTooLarge,
      ErrorCodes.fileReadError: () => t.errorMapping.upload.readError,
      ErrorCodes.filesystemError: () => t.errorMapping.upload.filesystemError,
      ErrorCodes.uploadVerificationFailed: () =>
          t.errorMapping.upload.verificationFailed,
      ErrorCodes.uploadAllFailed: () => t.errorMapping.upload.allFailed,
      ErrorCodes.invalidImageUrls: () => t.errorMapping.upload.invalidImageUrls,
      ErrorCodes.fileNotFound: () => t.errorMapping.upload.fileNotFound,
      ErrorCodes.imageCompressionFailed: () =>
          t.errorMapping.upload.imageCompressionFailed,
      ErrorCodes.fileAccessError: () => t.errorMapping.upload.accessError,
      ErrorCodes.fileDeleteError: () => t.errorMapping.upload.deleteError,
      ErrorCodes.noFiles: () => t.errorMapping.upload.noFiles,
      ErrorCodes.fileEmpty: () => t.errorMapping.upload.fileEmpty,
      ErrorCodes.invalidFilename: () => t.errorMapping.upload.invalidFilename,

      // Storage config (4500-4502)
      ErrorCodes.invalidProviderType: () =>
          t.errorMapping.storage.invalidProviderType,
      ErrorCodes.configNotFound: () => t.errorMapping.storage.configNotFound,
      ErrorCodes.configInUse: () => t.errorMapping.storage.configInUse,

      // AI/LLM (9000-9004)
      ErrorCodes.aiContextLimitExceeded: () => t.errorMapping.ai.contextLimit,
      ErrorCodes.conversationIdInvalid: () =>
          t.errorMapping.ai.conversationIdInvalid,
      ErrorCodes.conversationIdNotOwner: () =>
          t.errorMapping.ai.conversationIdNotOwner,
      ErrorCodes.tokensLimited: () => t.errorMapping.ai.tokenLimit,
      ErrorCodes.noUserMessage: () => t.errorMapping.ai.emptyMessage,
    };
  }

  /// Translates a numeric error code from the backend to a localized message.
  ///
  /// [code] The error code returned by the API.
  /// [defaultMessage] The fallback message (e.g., from the backend) if the code is not recognized.
  static String translate(int code, String defaultMessage) {
    return _translations[code]?.call() ?? defaultMessage;
  }
}
