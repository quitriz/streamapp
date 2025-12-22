import 'package:collection/collection.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/models/settings/core_settings_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/utils/constants.dart';

part 'core_store.g.dart';

class CoreStore = CoreStoreBase with _$CoreStore;

abstract class CoreStoreBase with Store {
  Future<CoreSettingsData?>? _inFlightFetch;

  @observable
  CoreSettingsData? coreSettings;

  @observable
  bool isFetching = false;

  @observable
  bool hasError = false;

  @observable
  String? errorMessage;

  @observable
  DateTime? lastFetchedAt;

  @computed
  bool get hasSettings => coreSettings != null;

  @computed
  bool get shouldShowCast => coreSettings?.displayCast ?? true;

  @computed
  bool get shouldShowCrew => coreSettings?.displayCrew ?? true;

  @computed
  bool get shouldShowViewCounter => coreSettings?.showViewCounter ?? true;

  @computed
  bool get shouldShowRecommended => coreSettings?.displayRecommended ?? true;

  @computed
  bool get shouldShowRelatedMovie => coreSettings?.displayRelatedMovie ?? true;

  @computed
  bool get shouldShowRelatedVideo => coreSettings?.displayRelatedVideo ?? true;

  @computed
  bool get shouldShowPlaylist => coreSettings?.displayPlaylist ?? true;

  @computed
  String get pmProCurrency => coreSettings?.pmProCurrency ?? '';

  @computed
  String get currencySymbol => coreSettings?.currencySymbol ?? '';

  @computed
  List<PmProPayments> get pmProPayments => coreSettings?.pmProPayments ?? const [];

  @computed
  bool get isMembershipEnabled => coreSettings?.isMembershipEnabled ?? false;

  @computed
  bool get isSocialLoginEnabled => coreSettings?.isSocialLoginEnabled ?? false;

  @computed
  bool get allowDownload => coreSettings?.allowDownload ?? false;

  @computed
  bool get allowGuestDownload => coreSettings?.allowGuestDownload ?? false;

  @computed
  String get wooConsumerKey => coreSettings?.wooConsumerKey ?? '';

  @computed
  String get wooConsumerSecret => coreSettings?.wooConsumerSecret ?? '';

  @computed
  PmProPayments? get primaryInAppPayment => pmProPayments.firstWhereOrNull((element) => element.type == PMProPayments.inAppPayment);

  @computed
  bool get isInAppPurchaseEnabled => primaryInAppPayment != null;

  @computed
  String get inAppEntitlementId => primaryInAppPayment?.entitlementId ?? '';

  @computed
  String get inAppGoogleApiKey => primaryInAppPayment?.googleApiKey ?? '';

  @computed
  String get inAppAppleApiKey => primaryInAppPayment?.appleApiKey ?? '';

  @action
  Future<CoreSettingsData?> ensureLoaded({bool forceRefresh = false}) async {
    if (!forceRefresh && coreSettings != null) {
      log('CoreStore: returning cached core settings (fetched at: $lastFetchedAt)');
      return coreSettings;
    }

    if (!forceRefresh && _inFlightFetch != null) {
      log('CoreStore: awaiting existing in-flight core settings request');
      return await _inFlightFetch!;
    }

    log('CoreStore: triggering core settings fetch (forceRefresh: $forceRefresh)');
    _inFlightFetch = _fetchCoreSettings();
    try {
      return await _inFlightFetch;
    } finally {
      _inFlightFetch = null;
    }
  }

  @action
  Future<CoreSettingsData?> refresh() {
    return ensureLoaded(forceRefresh: true);
  }

  @action
  void clear() {
    log('CoreStore: clearing cached core settings');
    coreSettings = null;
    lastFetchedAt = null;
    hasError = false;
    errorMessage = null;
    _inFlightFetch = null;
  }

  Future<CoreSettingsData?> _fetchCoreSettings() async {
    isFetching = true;
    hasError = false;
    errorMessage = null;

    try {
      log('CoreStore: calling core-settings API');
      final response = await getCoreSettings();

      if (!response.status) {
        log('CoreStore: API returned unsuccessful status with message: ${response.message}');
        throw response.message.validate(value: 'Something went wrong');
      }

      final incoming = response.data;

      if (incoming != coreSettings) {
        coreSettings = incoming;
        lastFetchedAt = DateTime.now();
        log('CoreStore: core settings updated -> ${incoming.toJson()}');
        await _persistCoreSettings(incoming);
      } else {
        log('Core settings unchanged; skipping state update.');
      }

      return coreSettings;
    } catch (e, st) {
      log('Failed to fetch core settings: $e');
      log('$st');
      hasError = true;
      errorMessage = e.toString();
      rethrow;
    } finally {
      isFetching = false;
    }
  }

  Future<void> _persistCoreSettings(CoreSettingsData settings) async {
    final inAppPayment = settings.pmProPayments.firstWhereOrNull((element) => element.type == PMProPayments.inAppPayment);

    await setValue(PMP_CURRENCY, settings.pmProCurrency);
    await setValue(CURRENCY_SYMBOL, settings.currencySymbol);
    await setValue(IS_MEMBERSHIP_ENABLED, settings.isMembershipEnabled);
    await setValue(IS_SOCIAL_LOGIN_ENABLE, settings.isSocialLoginEnabled);
    await setValue(HAS_IN_APP_PURCHASE_ENABLE, inAppPayment != null);
    await setValue(SUBSCRIPTION_ENTITLEMENT_ID, inAppPayment?.entitlementId ?? '');
    await setValue(SUBSCRIPTION_GOOGLE_API_KEY, inAppPayment?.googleApiKey ?? '');
    await setValue(SUBSCRIPTION_APPLE_API_KEY, inAppPayment?.appleApiKey ?? '');
    await setValue(SharePreferencesKey.WOO_CONSUMER_KEY, settings.wooConsumerKey, print: true);
    await setValue(SharePreferencesKey.WOO_CONSUMER_SECRET, settings.wooConsumerSecret, print: true);
  }
}
