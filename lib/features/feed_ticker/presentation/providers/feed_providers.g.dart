// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$feedsNotifierHash() => r'8181741b5c9e956b5658aa36839c482c70085eb2';

/// See also [FeedsNotifier].
@ProviderFor(FeedsNotifier)
final feedsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<FeedsNotifier, List<Feed>>.internal(
      FeedsNotifier.new,
      name: r'feedsNotifierProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$feedsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FeedsNotifier = AutoDisposeAsyncNotifier<List<Feed>>;
String _$feedItemsNotifierHash() => r'71d355e08325194cd124e361c1584e38aae33967';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$FeedItemsNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<FeedItem>> {
  late final int limit;

  FutureOr<List<FeedItem>> build({int limit = 50});
}

/// See also [FeedItemsNotifier].
@ProviderFor(FeedItemsNotifier)
const feedItemsNotifierProvider = FeedItemsNotifierFamily();

/// See also [FeedItemsNotifier].
class FeedItemsNotifierFamily extends Family<AsyncValue<List<FeedItem>>> {
  /// See also [FeedItemsNotifier].
  const FeedItemsNotifierFamily();

  /// See also [FeedItemsNotifier].
  FeedItemsNotifierProvider call({int limit = 50}) {
    return FeedItemsNotifierProvider(limit: limit);
  }

  @override
  FeedItemsNotifierProvider getProviderOverride(
    covariant FeedItemsNotifierProvider provider,
  ) {
    return call(limit: provider.limit);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'feedItemsNotifierProvider';
}

/// See also [FeedItemsNotifier].
class FeedItemsNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          FeedItemsNotifier,
          List<FeedItem>
        > {
  /// See also [FeedItemsNotifier].
  FeedItemsNotifierProvider({int limit = 50})
    : this._internal(
        () => FeedItemsNotifier()..limit = limit,
        from: feedItemsNotifierProvider,
        name: r'feedItemsNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$feedItemsNotifierHash,
        dependencies: FeedItemsNotifierFamily._dependencies,
        allTransitiveDependencies:
            FeedItemsNotifierFamily._allTransitiveDependencies,
        limit: limit,
      );

  FeedItemsNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.limit,
  }) : super.internal();

  final int limit;

  @override
  FutureOr<List<FeedItem>> runNotifierBuild(
    covariant FeedItemsNotifier notifier,
  ) {
    return notifier.build(limit: limit);
  }

  @override
  Override overrideWith(FeedItemsNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: FeedItemsNotifierProvider._internal(
        () => create()..limit = limit,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<FeedItemsNotifier, List<FeedItem>>
  createElement() {
    return _FeedItemsNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeedItemsNotifierProvider && other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FeedItemsNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<FeedItem>> {
  /// The parameter `limit` of this provider.
  int get limit;
}

class _FeedItemsNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          FeedItemsNotifier,
          List<FeedItem>
        >
    with FeedItemsNotifierRef {
  _FeedItemsNotifierProviderElement(super.provider);

  @override
  int get limit => (origin as FeedItemsNotifierProvider).limit;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
