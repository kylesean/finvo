// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Theme mode state manager
///
/// Converts [AppThemeMode] to Flutter's [ThemeMode] and persists the user's
/// choice to SharedPreferences so it survives app restarts.

@ProviderFor(ThemeNotifier)
final themeProvider = ThemeNotifierProvider._();

/// Theme mode state manager
///
/// Converts [AppThemeMode] to Flutter's [ThemeMode] and persists the user's
/// choice to SharedPreferences so it survives app restarts.
final class ThemeNotifierProvider
    extends $NotifierProvider<ThemeNotifier, ThemeMode> {
  /// Theme mode state manager
  ///
  /// Converts [AppThemeMode] to Flutter's [ThemeMode] and persists the user's
  /// choice to SharedPreferences so it survives app restarts.
  ThemeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeNotifierHash();

  @$internal
  @override
  ThemeNotifier create() => ThemeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themeNotifierHash() => r'545bfa36b2d5a78ecb0d23da1019441ba60d0346';

/// Theme mode state manager
///
/// Converts [AppThemeMode] to Flutter's [ThemeMode] and persists the user's
/// choice to SharedPreferences so it survives app restarts.

abstract class _$ThemeNotifier extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeMode, ThemeMode>,
              ThemeMode,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
