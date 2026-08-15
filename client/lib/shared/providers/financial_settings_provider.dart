// Moved out of `features/profile/providers/financial_settings_provider.dart`
// so that shared widgets (amount text/input) can read the current currency
// without importing a feature module. It talks directly to the `core` network
// client instead of a feature-level service.
import 'package:decimal/decimal.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logging/logging.dart';
import 'package:finvo/core/network/network_client.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/shared/models/financial_settings.dart';

part 'financial_settings_provider.g.dart';

final _logger = Logger('FinancialSettingsNotifier');

/// Parse the `{code, message, data}` envelope and return the settings payload.
FinancialSettingsResponse _parseSettingsResponse(Object? json, String context) {
  if (json is Map<String, dynamic>) {
    final data = json['data'];
    if (data == null) {
      throw DataParsingException('$context: data field is null');
    }
    if (data is Map<String, dynamic>) {
      return FinancialSettingsResponse.fromJson(data);
    }
    throw DataParsingException('$context: data field is not an object');
  }
  throw DataParsingException(
    '$context expects an object, but received ${json.runtimeType}',
  );
}

/// Financial settings state notifier
///
/// [keepAlive] so the primary currency is loaded once on login and reused
/// across every currency-dependent screen (home/budget/report/shared widgets)
/// without being torn down when those screens leave the tree.
@Riverpod(keepAlive: true)
class FinancialSettingsNotifier extends _$FinancialSettingsNotifier {
  FinancialSettingsResponse? _originalSettings;

  /// Monotonic epoch guarding loadFinancialSettings against cross-account
  /// in-flight writes (AUTH-P1): this provider is keepAlive, so a slow
  /// response for account A can settle AFTER A logged out and B logged in —
  /// without a generation check it would write A's currency/thresholds into
  /// the shared state B is now reading. Mirrors financial_account_provider.
  int _loadGeneration = 0;

  @override
  FinancialSettingsState build() {
    // Pure build: this provider is kept free of network side-effects. The
    // app triggers [loadFinancialSettings] explicitly when the user
    // authenticates (see app.dart), so the primary currency is warmed before
    // any currency-dependent screen reads it.
    // Reset session-scoped state on rebuild (keepAlive re-creation).
    _originalSettings = null;
    return const FinancialSettingsState();
  }

  /// Load financial settings
  Future<void> loadFinancialSettings() async {
    // Bump the generation: any in-flight request from a previous session is
    // now stale and will be discarded when it settles.
    final generation = ++_loadGeneration;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final networkClient = ref.read(networkClientProvider);
      final response = await networkClient.request<FinancialSettingsResponse>(
        '/financial-settings',
        method: HttpMethod.get,
        fromJsonT: (json) =>
            _parseSettingsResponse(json, 'API /financial-settings'),
      );
      if (!ref.mounted || generation != _loadGeneration) return;
      _originalSettings = response;

      _logger.info('Loaded primaryCurrency: ${response.primaryCurrency}');

      state = state.copyWith(
        safetyThreshold: response.safetyThreshold,
        dailyBurnRate: response.dailyBurnRate,
        burnRateMode: response.burnRateMode,
        primaryCurrency: response.primaryCurrency,
        monthStartDay: response.monthStartDay,
        lastUpdatedAt: response.updatedAt,
        isLoading: false,
        hasChanges: false,
        error: null,
      );
    } catch (e) {
      if (!ref.mounted || generation != _loadGeneration) return;
      String errorMessage = 'Failed to load financial settings';
      if (e is AppException) {
        errorMessage = e.message;
      }

      _logger.severe('Failed to load financial settings', e);

      state = state.copyWith(
        isLoading: false,
        hasChanges: false,
        error: errorMessage,
      );
    }
  }

  /// Update safety threshold
  void updateSafetyThreshold(Decimal newThreshold) {
    final hasChanges = _originalSettings?.safetyThreshold != newThreshold;
    state = state.copyWith(
      safetyThreshold: newThreshold,
      hasChanges: hasChanges,
      error: null,
    );
  }

  /// Update daily burn rate
  void updateDailyBurnRate(Decimal newRate) {
    final hasChanges = _originalSettings?.dailyBurnRate != newRate;
    state = state.copyWith(
      dailyBurnRate: newRate,
      hasChanges: hasChanges,
      error: null,
    );
  }

  /// Update burn rate mode
  void updateBurnRateMode(String mode) {
    state = state.copyWith(burnRateMode: mode, hasChanges: true, error: null);
  }

  /// Update primary currency
  void updatePrimaryCurrency(String currency) {
    final hasChanges = _originalSettings?.primaryCurrency != currency;
    state = state.copyWith(
      primaryCurrency: currency,
      hasChanges: hasChanges,
      error: null,
    );
  }

  /// Save financial settings
  Future<bool> saveFinancialSettings() async {
    if (!state.hasChanges) return true;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final networkClient = ref.read(networkClientProvider);
      final request = FinancialSettingsRequest(
        safetyThreshold: state.safetyThreshold,
        dailyBurnRate: state.dailyBurnRate,
        burnRateMode: state.burnRateMode,
        primaryCurrency: state.primaryCurrency,
        monthStartDay: state.monthStartDay,
      );

      final response = await networkClient.request<FinancialSettingsResponse>(
        '/financial-settings',
        method: HttpMethod.patch,
        data: request.toJson(),
        fromJsonT: (json) =>
            _parseSettingsResponse(json, 'API /financial-settings'),
      );
      _originalSettings = response;

      state = state.copyWith(
        safetyThreshold: response.safetyThreshold,
        dailyBurnRate: response.dailyBurnRate,
        burnRateMode: response.burnRateMode,
        primaryCurrency: response.primaryCurrency,
        monthStartDay: response.monthStartDay,
        lastUpdatedAt: response.updatedAt,
        isLoading: false,
        hasChanges: false,
        error: null,
      );

      return true;
    } catch (e) {
      String errorMessage = 'Failed to save financial settings';
      if (e is AppException) {
        errorMessage = e.message;
      }

      state = state.copyWith(isLoading: false, error: errorMessage);

      return false;
    }
  }

  /// Reset to original values
  void resetToOriginal() {
    if (_originalSettings != null) {
      state = state.copyWith(
        safetyThreshold: _originalSettings!.safetyThreshold,
        dailyBurnRate: _originalSettings!.dailyBurnRate,
        burnRateMode: _originalSettings!.burnRateMode,
        primaryCurrency: _originalSettings!.primaryCurrency,
        monthStartDay: _originalSettings!.monthStartDay,
        hasChanges: false,
        error: null,
      );
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}
