// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authenticated_image.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Authenticated network image provider
/// Used to cache loaded image data

@ProviderFor(authenticatedImage)
final authenticatedImageProvider = AuthenticatedImageFamily._();

/// Authenticated network image provider
/// Used to cache loaded image data

final class AuthenticatedImageProvider
    extends
        $FunctionalProvider<
          AsyncValue<Uint8List>,
          Uint8List,
          FutureOr<Uint8List>
        >
    with $FutureModifier<Uint8List>, $FutureProvider<Uint8List> {
  /// Authenticated network image provider
  /// Used to cache loaded image data
  AuthenticatedImageProvider._({
    required AuthenticatedImageFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'authenticatedImageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$authenticatedImageHash();

  @override
  String toString() {
    return r'authenticatedImageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Uint8List> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Uint8List> create(Ref ref) {
    final argument = this.argument as String;
    return authenticatedImage(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AuthenticatedImageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$authenticatedImageHash() =>
    r'a3de3336adfb9d6dd9d7ac9726c8c822c42b9e45';

/// Authenticated network image provider
/// Used to cache loaded image data

final class AuthenticatedImageFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Uint8List>, String> {
  AuthenticatedImageFamily._()
    : super(
        retry: null,
        name: r'authenticatedImageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Authenticated network image provider
  /// Used to cache loaded image data

  AuthenticatedImageProvider call(String attachmentId) =>
      AuthenticatedImageProvider._(argument: attachmentId, from: this);

  @override
  String toString() => r'authenticatedImageProvider';
}
