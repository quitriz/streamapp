// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CoreStore on CoreStoreBase, Store {
  Computed<bool>? _$hasSettingsComputed;

  @override
  bool get hasSettings =>
      (_$hasSettingsComputed ??= Computed<bool>(() => super.hasSettings,
              name: 'CoreStoreBase.hasSettings'))
          .value;
  Computed<bool>? _$shouldShowCastComputed;

  @override
  bool get shouldShowCast =>
      (_$shouldShowCastComputed ??= Computed<bool>(() => super.shouldShowCast,
              name: 'CoreStoreBase.shouldShowCast'))
          .value;
  Computed<bool>? _$shouldShowCrewComputed;

  @override
  bool get shouldShowCrew =>
      (_$shouldShowCrewComputed ??= Computed<bool>(() => super.shouldShowCrew,
              name: 'CoreStoreBase.shouldShowCrew'))
          .value;
  Computed<bool>? _$shouldShowViewCounterComputed;

  @override
  bool get shouldShowViewCounter => (_$shouldShowViewCounterComputed ??=
          Computed<bool>(() => super.shouldShowViewCounter,
              name: 'CoreStoreBase.shouldShowViewCounter'))
      .value;
  Computed<bool>? _$shouldShowRecommendedComputed;

  @override
  bool get shouldShowRecommended => (_$shouldShowRecommendedComputed ??=
          Computed<bool>(() => super.shouldShowRecommended,
              name: 'CoreStoreBase.shouldShowRecommended'))
      .value;
  Computed<bool>? _$shouldShowRelatedMovieComputed;

  @override
  bool get shouldShowRelatedMovie => (_$shouldShowRelatedMovieComputed ??=
          Computed<bool>(() => super.shouldShowRelatedMovie,
              name: 'CoreStoreBase.shouldShowRelatedMovie'))
      .value;
  Computed<bool>? _$shouldShowRelatedVideoComputed;

  @override
  bool get shouldShowRelatedVideo => (_$shouldShowRelatedVideoComputed ??=
          Computed<bool>(() => super.shouldShowRelatedVideo,
              name: 'CoreStoreBase.shouldShowRelatedVideo'))
      .value;
  Computed<bool>? _$shouldShowPlaylistComputed;

  @override
  bool get shouldShowPlaylist => (_$shouldShowPlaylistComputed ??=
          Computed<bool>(() => super.shouldShowPlaylist,
              name: 'CoreStoreBase.shouldShowPlaylist'))
      .value;
  Computed<String>? _$pmProCurrencyComputed;

  @override
  String get pmProCurrency =>
      (_$pmProCurrencyComputed ??= Computed<String>(() => super.pmProCurrency,
              name: 'CoreStoreBase.pmProCurrency'))
          .value;
  Computed<String>? _$currencySymbolComputed;

  @override
  String get currencySymbol =>
      (_$currencySymbolComputed ??= Computed<String>(() => super.currencySymbol,
              name: 'CoreStoreBase.currencySymbol'))
          .value;
  Computed<List<PmProPayments>>? _$pmProPaymentsComputed;

  @override
  List<PmProPayments> get pmProPayments => (_$pmProPaymentsComputed ??=
          Computed<List<PmProPayments>>(() => super.pmProPayments,
              name: 'CoreStoreBase.pmProPayments'))
      .value;
  Computed<bool>? _$isMembershipEnabledComputed;

  @override
  bool get isMembershipEnabled => (_$isMembershipEnabledComputed ??=
          Computed<bool>(() => super.isMembershipEnabled,
              name: 'CoreStoreBase.isMembershipEnabled'))
      .value;
  Computed<bool>? _$isSocialLoginEnabledComputed;

  @override
  bool get isSocialLoginEnabled => (_$isSocialLoginEnabledComputed ??=
          Computed<bool>(() => super.isSocialLoginEnabled,
              name: 'CoreStoreBase.isSocialLoginEnabled'))
      .value;
  Computed<bool>? _$allowDownloadComputed;

  @override
  bool get allowDownload =>
      (_$allowDownloadComputed ??= Computed<bool>(() => super.allowDownload,
              name: 'CoreStoreBase.allowDownload'))
          .value;
  Computed<bool>? _$allowGuestDownloadComputed;

  @override
  bool get allowGuestDownload => (_$allowGuestDownloadComputed ??=
          Computed<bool>(() => super.allowGuestDownload,
              name: 'CoreStoreBase.allowGuestDownload'))
      .value;
  Computed<String>? _$wooConsumerKeyComputed;

  @override
  String get wooConsumerKey =>
      (_$wooConsumerKeyComputed ??= Computed<String>(() => super.wooConsumerKey,
              name: 'CoreStoreBase.wooConsumerKey'))
          .value;
  Computed<String>? _$wooConsumerSecretComputed;

  @override
  String get wooConsumerSecret => (_$wooConsumerSecretComputed ??=
          Computed<String>(() => super.wooConsumerSecret,
              name: 'CoreStoreBase.wooConsumerSecret'))
      .value;
  Computed<PmProPayments?>? _$primaryInAppPaymentComputed;

  @override
  PmProPayments? get primaryInAppPayment => (_$primaryInAppPaymentComputed ??=
          Computed<PmProPayments?>(() => super.primaryInAppPayment,
              name: 'CoreStoreBase.primaryInAppPayment'))
      .value;
  Computed<bool>? _$isInAppPurchaseEnabledComputed;

  @override
  bool get isInAppPurchaseEnabled => (_$isInAppPurchaseEnabledComputed ??=
          Computed<bool>(() => super.isInAppPurchaseEnabled,
              name: 'CoreStoreBase.isInAppPurchaseEnabled'))
      .value;
  Computed<String>? _$inAppEntitlementIdComputed;

  @override
  String get inAppEntitlementId => (_$inAppEntitlementIdComputed ??=
          Computed<String>(() => super.inAppEntitlementId,
              name: 'CoreStoreBase.inAppEntitlementId'))
      .value;
  Computed<String>? _$inAppGoogleApiKeyComputed;

  @override
  String get inAppGoogleApiKey => (_$inAppGoogleApiKeyComputed ??=
          Computed<String>(() => super.inAppGoogleApiKey,
              name: 'CoreStoreBase.inAppGoogleApiKey'))
      .value;
  Computed<String>? _$inAppAppleApiKeyComputed;

  @override
  String get inAppAppleApiKey => (_$inAppAppleApiKeyComputed ??=
          Computed<String>(() => super.inAppAppleApiKey,
              name: 'CoreStoreBase.inAppAppleApiKey'))
      .value;

  late final _$coreSettingsAtom =
      Atom(name: 'CoreStoreBase.coreSettings', context: context);

  @override
  CoreSettingsData? get coreSettings {
    _$coreSettingsAtom.reportRead();
    return super.coreSettings;
  }

  @override
  set coreSettings(CoreSettingsData? value) {
    _$coreSettingsAtom.reportWrite(value, super.coreSettings, () {
      super.coreSettings = value;
    });
  }

  late final _$isFetchingAtom =
      Atom(name: 'CoreStoreBase.isFetching', context: context);

  @override
  bool get isFetching {
    _$isFetchingAtom.reportRead();
    return super.isFetching;
  }

  @override
  set isFetching(bool value) {
    _$isFetchingAtom.reportWrite(value, super.isFetching, () {
      super.isFetching = value;
    });
  }

  late final _$hasErrorAtom =
      Atom(name: 'CoreStoreBase.hasError', context: context);

  @override
  bool get hasError {
    _$hasErrorAtom.reportRead();
    return super.hasError;
  }

  @override
  set hasError(bool value) {
    _$hasErrorAtom.reportWrite(value, super.hasError, () {
      super.hasError = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: 'CoreStoreBase.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$lastFetchedAtAtom =
      Atom(name: 'CoreStoreBase.lastFetchedAt', context: context);

  @override
  DateTime? get lastFetchedAt {
    _$lastFetchedAtAtom.reportRead();
    return super.lastFetchedAt;
  }

  @override
  set lastFetchedAt(DateTime? value) {
    _$lastFetchedAtAtom.reportWrite(value, super.lastFetchedAt, () {
      super.lastFetchedAt = value;
    });
  }

  late final _$ensureLoadedAsyncAction =
      AsyncAction('CoreStoreBase.ensureLoaded', context: context);

  @override
  Future<CoreSettingsData?> ensureLoaded({bool forceRefresh = false}) {
    return _$ensureLoadedAsyncAction
        .run(() => super.ensureLoaded(forceRefresh: forceRefresh));
  }

  late final _$CoreStoreBaseActionController =
      ActionController(name: 'CoreStoreBase', context: context);

  @override
  Future<CoreSettingsData?> refresh() {
    final _$actionInfo = _$CoreStoreBaseActionController.startAction(
        name: 'CoreStoreBase.refresh');
    try {
      return super.refresh();
    } finally {
      _$CoreStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clear() {
    final _$actionInfo = _$CoreStoreBaseActionController.startAction(
        name: 'CoreStoreBase.clear');
    try {
      return super.clear();
    } finally {
      _$CoreStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
coreSettings: ${coreSettings},
isFetching: ${isFetching},
hasError: ${hasError},
errorMessage: ${errorMessage},
lastFetchedAt: ${lastFetchedAt},
hasSettings: ${hasSettings},
shouldShowCast: ${shouldShowCast},
shouldShowCrew: ${shouldShowCrew},
shouldShowViewCounter: ${shouldShowViewCounter},
shouldShowRecommended: ${shouldShowRecommended},
shouldShowRelatedMovie: ${shouldShowRelatedMovie},
shouldShowRelatedVideo: ${shouldShowRelatedVideo},
shouldShowPlaylist: ${shouldShowPlaylist},
pmProCurrency: ${pmProCurrency},
currencySymbol: ${currencySymbol},
pmProPayments: ${pmProPayments},
isMembershipEnabled: ${isMembershipEnabled},
isSocialLoginEnabled: ${isSocialLoginEnabled},
allowDownload: ${allowDownload},
allowGuestDownload: ${allowGuestDownload},
wooConsumerKey: ${wooConsumerKey},
wooConsumerSecret: ${wooConsumerSecret},
primaryInAppPayment: ${primaryInAppPayment},
isInAppPurchaseEnabled: ${isInAppPurchaseEnabled},
inAppEntitlementId: ${inAppEntitlementId},
inAppGoogleApiKey: ${inAppGoogleApiKey},
inAppAppleApiKey: ${inAppAppleApiKey}
    ''';
  }
}
