// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anilist.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$anilistHash() => r'4d54bf86bb2f1133e77609c94b22f4ad17837f20';

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

abstract class _$Anilist extends BuildlessAutoDisposeNotifier<void> {
  late final int syncId;
  late final bool? isManga;

  void build({
    required int syncId,
    bool? isManga,
  });
}

/// See also [Anilist].
@ProviderFor(Anilist)
const anilistProvider = AnilistFamily();

/// See also [Anilist].
class AnilistFamily extends Family<void> {
  /// See also [Anilist].
  const AnilistFamily();

  /// See also [Anilist].
  AnilistProvider call({
    required int syncId,
    bool? isManga,
  }) {
    return AnilistProvider(
      syncId: syncId,
      isManga: isManga,
    );
  }

  @override
  AnilistProvider getProviderOverride(
    covariant AnilistProvider provider,
  ) {
    return call(
      syncId: provider.syncId,
      isManga: provider.isManga,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'anilistProvider';
}

/// See also [Anilist].
class AnilistProvider extends AutoDisposeNotifierProviderImpl<Anilist, void> {
  /// See also [Anilist].
  AnilistProvider({
    required int syncId,
    bool? isManga,
  }) : this._internal(
          () => Anilist()
            ..syncId = syncId
            ..isManga = isManga,
          from: anilistProvider,
          name: r'anilistProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$anilistHash,
          dependencies: AnilistFamily._dependencies,
          allTransitiveDependencies: AnilistFamily._allTransitiveDependencies,
          syncId: syncId,
          isManga: isManga,
        );

  AnilistProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.syncId,
    required this.isManga,
  }) : super.internal();

  final int syncId;
  final bool? isManga;

  @override
  void runNotifierBuild(
    covariant Anilist notifier,
  ) {
    return notifier.build(
      syncId: syncId,
      isManga: isManga,
    );
  }

  @override
  Override overrideWith(Anilist Function() create) {
    return ProviderOverride(
      origin: this,
      override: AnilistProvider._internal(
        () => create()
          ..syncId = syncId
          ..isManga = isManga,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        syncId: syncId,
        isManga: isManga,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<Anilist, void> createElement() {
    return _AnilistProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AnilistProvider &&
        other.syncId == syncId &&
        other.isManga == isManga;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, syncId.hashCode);
    hash = _SystemHash.combine(hash, isManga.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AnilistRef on AutoDisposeNotifierProviderRef<void> {
  /// The parameter `syncId` of this provider.
  int get syncId;

  /// The parameter `isManga` of this provider.
  bool? get isManga;
}

class _AnilistProviderElement
    extends AutoDisposeNotifierProviderElement<Anilist, void> with AnilistRef {
  _AnilistProviderElement(super.provider);

  @override
  int get syncId => (origin as AnilistProvider).syncId;
  @override
  bool? get isManga => (origin as AnilistProvider).isManga;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
