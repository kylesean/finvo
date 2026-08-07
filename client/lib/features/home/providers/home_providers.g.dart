// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CurrentTransactionFeedType)
final currentTransactionFeedTypeProvider =
    CurrentTransactionFeedTypeProvider._();

final class CurrentTransactionFeedTypeProvider
    extends $NotifierProvider<CurrentTransactionFeedType, TransactionFeedType> {
  CurrentTransactionFeedTypeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentTransactionFeedTypeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentTransactionFeedTypeHash();

  @$internal
  @override
  CurrentTransactionFeedType create() => CurrentTransactionFeedType();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionFeedType value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionFeedType>(value),
    );
  }
}

String _$currentTransactionFeedTypeHash() =>
    r'32e384260e29d1e2f3ecf4871720e92d80f4f2e3';

abstract class _$CurrentTransactionFeedType
    extends $Notifier<TransactionFeedType> {
  TransactionFeedType build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TransactionFeedType, TransactionFeedType>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TransactionFeedType, TransactionFeedType>,
              TransactionFeedType,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(CurrentDisplayMonth)
final currentDisplayMonthProvider = CurrentDisplayMonthProvider._();

final class CurrentDisplayMonthProvider
    extends $NotifierProvider<CurrentDisplayMonth, DateTime> {
  CurrentDisplayMonthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentDisplayMonthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentDisplayMonthHash();

  @$internal
  @override
  CurrentDisplayMonth create() => CurrentDisplayMonth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$currentDisplayMonthHash() =>
    r'841b72f2429c66886a2cddd9128c620b18d736cb';

abstract class _$CurrentDisplayMonth extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SelectedDate)
final selectedDateProvider = SelectedDateProvider._();

final class SelectedDateProvider
    extends $NotifierProvider<SelectedDate, DateTime?> {
  SelectedDateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedDateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedDateHash();

  @$internal
  @override
  SelectedDate create() => SelectedDate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime?>(value),
    );
  }
}

String _$selectedDateHash() => r'2924a8d0ca7f3568bf857536dfc19912050d24f5';

abstract class _$SelectedDate extends $Notifier<DateTime?> {
  DateTime? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DateTime?, DateTime?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime?, DateTime?>,
              DateTime?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Subscribes the home feature to cross-feature transaction events and
/// invalidates the affected home providers.
///
/// This keeps the dependency direction feature -> core: producers (e.g. the
/// chat feature) only publish [TransactionCreatedEvent]s on the shared bus
/// and never touch home providers directly.

@ProviderFor(transactionEventSubscriber)
final transactionEventSubscriberProvider =
    TransactionEventSubscriberProvider._();

/// Subscribes the home feature to cross-feature transaction events and
/// invalidates the affected home providers.
///
/// This keeps the dependency direction feature -> core: producers (e.g. the
/// chat feature) only publish [TransactionCreatedEvent]s on the shared bus
/// and never touch home providers directly.

final class TransactionEventSubscriberProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Subscribes the home feature to cross-feature transaction events and
  /// invalidates the affected home providers.
  ///
  /// This keeps the dependency direction feature -> core: producers (e.g. the
  /// chat feature) only publish [TransactionCreatedEvent]s on the shared bus
  /// and never touch home providers directly.
  TransactionEventSubscriberProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionEventSubscriberProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionEventSubscriberHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return transactionEventSubscriber(ref);
  }
}

String _$transactionEventSubscriberHash() =>
    r'0df6b793a7b7bbf116307171315e7f68acff79b5';

@ProviderFor(totalExpense)
final totalExpenseProvider = TotalExpenseProvider._();

final class TotalExpenseProvider
    extends
        $FunctionalProvider<
          AsyncValue<TotalExpenseData>,
          TotalExpenseData,
          FutureOr<TotalExpenseData>
        >
    with $FutureModifier<TotalExpenseData>, $FutureProvider<TotalExpenseData> {
  TotalExpenseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalExpenseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalExpenseHash();

  @$internal
  @override
  $FutureProviderElement<TotalExpenseData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TotalExpenseData> create(Ref ref) {
    return totalExpense(ref);
  }
}

String _$totalExpenseHash() => r'af8b50253584f808a258a6cbd72cbc7c73ff1248';

@ProviderFor(calendarMonthData)
final calendarMonthDataProvider = CalendarMonthDataFamily._();

final class CalendarMonthDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<CalendarMonthData>,
          CalendarMonthData,
          FutureOr<CalendarMonthData>
        >
    with
        $FutureModifier<CalendarMonthData>,
        $FutureProvider<CalendarMonthData> {
  CalendarMonthDataProvider._({
    required CalendarMonthDataFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'calendarMonthDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$calendarMonthDataHash();

  @override
  String toString() {
    return r'calendarMonthDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CalendarMonthData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CalendarMonthData> create(Ref ref) {
    final argument = this.argument as DateTime;
    return calendarMonthData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarMonthDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$calendarMonthDataHash() => r'01681cb4d69db9fb067138fd2a0038f2a8b385d0';

final class CalendarMonthDataFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CalendarMonthData>, DateTime> {
  CalendarMonthDataFamily._()
    : super(
        retry: null,
        name: r'calendarMonthDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CalendarMonthDataProvider call(DateTime monthYear) =>
      CalendarMonthDataProvider._(argument: monthYear, from: this);

  @override
  String toString() => r'calendarMonthDataProvider';
}

@ProviderFor(TransactionFeed)
final transactionFeedProvider = TransactionFeedProvider._();

final class TransactionFeedProvider
    extends $NotifierProvider<TransactionFeed, TransactionFeedState> {
  TransactionFeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionFeedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionFeedHash();

  @$internal
  @override
  TransactionFeed create() => TransactionFeed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionFeedState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionFeedState>(value),
    );
  }
}

String _$transactionFeedHash() => r'226d3182ceaa0442cdda7fb10a42e83250fdf1bf';

abstract class _$TransactionFeed extends $Notifier<TransactionFeedState> {
  TransactionFeedState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TransactionFeedState, TransactionFeedState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TransactionFeedState, TransactionFeedState>,
              TransactionFeedState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
