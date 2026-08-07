import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/core/constants/error_codes.dart';

/// Utility class for translating backend error codes to localized messages.
///
/// Uses the generated i18n [t] object to provide localized strings based on
/// specific backend business error codes.
class ErrorTranslator {
  /// Lazy lookup map from backend error code to localized message. Built on
  /// first access so the generated i18n object is already initialized, and
  /// avoids the linear scan of a large switch on every translation.
  static final Map<int, String> _translations = _buildTranslations();

  static Map<int, String> _buildTranslations() {
    final e = t.errorMapping;
    return {
      // Generic Errors
      400: e.generic.badRequest,
      ErrorCodes.authFailed: e.generic.authFailed,
      ErrorCodes.permissionDenied: e.generic.permissionDenied,
      ErrorCodes.notFound: e.generic.notFound,
      ErrorCodes.serverError: e.generic.serverError,
      ErrorCodes.systemInvalid: e.generic.systemError,
      ErrorCodes.validationError: e.generic.validationFailed,

      // Authentication (1000-1012)
      ErrorCodes.authenticateFailed: e.auth.failed,
      ErrorCodes.emailWrong: e.auth.emailWrong,
      ErrorCodes.phoneNumberWrong: e.auth.phoneWrong,
      ErrorCodes.phoneNumberRegistered: e.auth.phoneRegistered,
      ErrorCodes.emailRegistered: e.auth.emailRegistered,
      ErrorCodes.sendCodeFailed: e.auth.sendFailed,
      ErrorCodes.codeExpired: e.auth.expired,
      ErrorCodes.codeSendTooFrequently: e.auth.tooFrequent,
      ErrorCodes.unsupportedCodeType: e.auth.unsupportedType,
      ErrorCodes.userNotMatchPassword: e.auth.wrongPassword,
      ErrorCodes.userNotExist: e.auth.userNotFound,
      ErrorCodes.noPreferencesParams: e.auth.prefsMissing,
      ErrorCodes.invalidClientTimezone: e.auth.invalidTimezone,

      // Transaction (3000-3006)
      ErrorCodes.transactionCommentNull: e.transaction.commentEmpty,
      ErrorCodes.invalidParentCommentId: e.transaction.invalidParent,
      ErrorCodes.storeCommentFailed: e.transaction.saveFailed,
      ErrorCodes.deleteCommentFailed: e.transaction.deleteFailed,
      ErrorCodes.transactionNotExists: e.transaction.notExists,
      ErrorCodes.invalidAccountId: e.transaction.invalidAccountId,
      ErrorCodes.exchangeRateUnavailable: e.transaction.exchangeRateUnavailable,

      // Shared Space (3100-3113)
      ErrorCodes.sharedSpaceNotExistsOrNoAccess: e.space.notFound,
      ErrorCodes.noPermissionToInviteMembers: e.space.inviteDenied,
      ErrorCodes.cannotInviteYourself: e.space.inviteSelf,
      ErrorCodes.invitationSent: e.space.inviteSent,
      ErrorCodes.alreadyMemberOrHasBeenInvited: e.space.alreadyMember,
      ErrorCodes.invalidAction: e.space.invalidAction,
      ErrorCodes.invitationNotExists: e.space.invitationNotFound,
      ErrorCodes.onlyOwnerCanDo: e.space.onlyOwner,
      ErrorCodes.ownerCannotBeRemoved: e.space.ownerNotRemovable,
      ErrorCodes.memberNotExist: e.space.memberNotFound,
      ErrorCodes.notMemberInThisSpace: e.space.notMember,
      ErrorCodes.ownerCannotLeaveDirectly: e.space.ownerCantLeave,
      ErrorCodes.invalidInvitationCode: e.space.invalidCode,
      ErrorCodes.invitationCodeExpiredOrLimited: e.space.codeExpired,
      ErrorCodes.transactionAlreadyInSpace: e.space.transactionAlreadyInSpace,

      // Recurring (3200-3201)
      ErrorCodes.invalidRecurrenceRule: e.recurring.invalidRule,
      ErrorCodes.recurrenceRuleNotFound: e.recurring.ruleNotFound,

      // File Upload (4001-4022)
      ErrorCodes.noFileUploaded: e.upload.noFile,
      ErrorCodes.invalidFileUploaded: e.upload.invalidFile,
      ErrorCodes.fileTooLarge: e.upload.tooLarge,
      ErrorCodes.invalidFileType: e.upload.unsupportedType,
      ErrorCodes.invalidMimeType: e.upload.invalidMimeType,
      ErrorCodes.invalidImageContent: e.upload.invalidImageContent,
      ErrorCodes.imageTooWide: e.upload.imageTooWide,
      ErrorCodes.imageTooHigh: e.upload.imageTooHigh,
      ErrorCodes.tooManyFiles: e.upload.tooManyFiles,
      ErrorCodes.totalSizeTooLarge: e.upload.totalSizeTooLarge,
      ErrorCodes.fileReadError: e.upload.readError,
      ErrorCodes.filesystemError: e.upload.filesystemError,
      ErrorCodes.uploadVerificationFailed: e.upload.verificationFailed,
      ErrorCodes.uploadAllFailed: e.upload.allFailed,
      ErrorCodes.invalidImageUrls: e.upload.invalidImageUrls,
      ErrorCodes.fileNotFound: e.upload.fileNotFound,
      ErrorCodes.imageCompressionFailed: e.upload.imageCompressionFailed,
      ErrorCodes.fileAccessError: e.upload.accessError,
      ErrorCodes.fileDeleteError: e.upload.deleteError,
      ErrorCodes.noFiles: e.upload.noFiles,
      ErrorCodes.fileEmpty: e.upload.fileEmpty,
      ErrorCodes.invalidFilename: e.upload.invalidFilename,

      // Storage config (4500-4502)
      ErrorCodes.invalidProviderType: e.storage.invalidProviderType,
      ErrorCodes.configNotFound: e.storage.configNotFound,
      ErrorCodes.configInUse: e.storage.configInUse,

      // AI/LLM (9000-9004)
      ErrorCodes.aiContextLimitExceeded: e.ai.contextLimit,
      ErrorCodes.conversationIdInvalid: e.ai.conversationIdInvalid,
      ErrorCodes.conversationIdNotOwner: e.ai.conversationIdNotOwner,
      ErrorCodes.tokensLimited: e.ai.tokenLimit,
      ErrorCodes.noUserMessage: e.ai.emptyMessage,
    };
  }

  /// Translates a numeric error code from the backend to a localized message.
  ///
  /// [code] The error code returned by the API.
  /// [defaultMessage] The fallback message (e.g., from the backend) if the code is not recognized.
  static String translate(int code, String defaultMessage) {
    return _translations[code] ?? defaultMessage;
  }
}
