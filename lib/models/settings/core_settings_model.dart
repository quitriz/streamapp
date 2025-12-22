class CoreSettingsResponse {
  final bool status;
  final String message;
  final CoreSettingsData data;

  CoreSettingsResponse({
    this.status = false,
    this.message = '',
    CoreSettingsData? data,
  }) : data = data ?? CoreSettingsData();

  factory CoreSettingsResponse.fromJson(Map<String, dynamic> json) {
    return CoreSettingsResponse(
      status: json['status'] is bool ? json['status'] : false,
      message: json['message'].toString(),
      data: json['data'] is Map<String, dynamic>
          ? CoreSettingsData.fromJson(json['data'])
          : CoreSettingsData(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class CoreSettingsData {
  final String pmProCurrency;
  final String currencySymbol;
  final List<PmProPayments> pmProPayments;
  final String wooConsumerKey;
  final String wooConsumerSecret;
  final bool isMembershipEnabled;
  final bool isSocialLoginEnabled;
  final bool allowDownload;
  final bool allowGuestDownload;
  final bool displayCast;
  final bool displayCrew;
  final bool showViewCounter;
  final bool displayRecommended;
  final bool displayRelatedMovie;
  final bool displayRelatedVideo;
  final bool displayPlaylist;

  CoreSettingsData({
    this.pmProCurrency = '',
    this.currencySymbol = '',
    List<PmProPayments>? pmProPayments,
    this.wooConsumerKey = '',
    this.wooConsumerSecret = '',
    this.isMembershipEnabled = false,
    this.isSocialLoginEnabled = false,
    this.allowDownload = false,
    this.allowGuestDownload = false,
    this.displayCast = true,
    this.displayCrew = true,
    this.showViewCounter = true,
    this.displayRecommended = true,
    this.displayRelatedMovie = true,
    this.displayRelatedVideo = true,
    this.displayPlaylist = true,
  }) : pmProPayments = pmProPayments ?? const [];

  factory CoreSettingsData.fromJson(Map<String, dynamic> json) {
    return CoreSettingsData(
      pmProCurrency: _parseString(json['pm_pro_currency']),
      currencySymbol: _parseString(json['currency_symbol']),
      pmProPayments: _parsePayments(json['pm_pro_payments']),
      wooConsumerKey: _parseString(json['wc_consumer_key']),
      wooConsumerSecret: _parseString(json['wc_consumer_secret']),
      isMembershipEnabled: _parseBool(json['is_membership_enable'], fallback: false),
      isSocialLoginEnabled: _parseBool(json['is_social_login_enable'], fallback: false),
      allowDownload: _parseBool(json['allow_download'], fallback: false),
      allowGuestDownload: _parseBool(json['allow_guest_download'], fallback: false),
      displayCast: _parseBool(json['streamit_display_cast'], fallback: true),
      displayCrew: _parseBool(json['streamit_display_crew'], fallback: true),
      showViewCounter: _parseBool(json['streamit_show_viewcounter'], fallback: true),
      displayRecommended: _parseBool(json['streamit_display_recommended'], fallback: true),
      displayRelatedMovie: _parseBool(json['streamit_display_related_movie'], fallback: true),
      displayRelatedVideo: _parseBool(json['streamit_display_related_video'], fallback: true),
      displayPlaylist: _parseBool(json['streamit_display_playlist'], fallback: true),
    );
  }

  static bool _parseBool(dynamic value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim();
      if (normalized.isEmpty) return fallback;
      if (normalized == '1') return true;
      if (normalized == '0') return false;
      return normalized.toLowerCase() == 'true';
    }
    return fallback;
  }

  Map<String, dynamic> toJson() {
    return {
      'pm_pro_currency': pmProCurrency,
      'currency_symbol': currencySymbol,
      'pm_pro_payments': pmProPayments.map((e) => e.toJson()).toList(),
      'wc_consumer_key': wooConsumerKey,
      'wc_consumer_secret': wooConsumerSecret,
      'is_membership_enable': isMembershipEnabled,
      'is_social_login_enable': isSocialLoginEnabled,
      'allow_download': allowDownload,
      'allow_guest_download': allowGuestDownload,
      'streamit_display_cast': displayCast,
      'streamit_display_crew': displayCrew,
      'streamit_show_viewcounter': showViewCounter,
      'streamit_display_recommended': displayRecommended,
      'streamit_display_related_movie': displayRelatedMovie,
      'streamit_display_related_video': displayRelatedVideo,
      'streamit_display_playlist': displayPlaylist,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CoreSettingsData &&
        other.pmProCurrency == pmProCurrency &&
        other.currencySymbol == currencySymbol &&
        _listEquals(other.pmProPayments, pmProPayments) &&
        other.wooConsumerKey == wooConsumerKey &&
        other.wooConsumerSecret == wooConsumerSecret &&
        other.isMembershipEnabled == isMembershipEnabled &&
        other.isSocialLoginEnabled == isSocialLoginEnabled &&
        other.allowDownload == allowDownload &&
        other.allowGuestDownload == allowGuestDownload &&
        other.displayCast == displayCast &&
        other.displayCrew == displayCrew &&
        other.showViewCounter == showViewCounter &&
        other.displayRecommended == displayRecommended &&
        other.displayRelatedMovie == displayRelatedMovie &&
        other.displayRelatedVideo == displayRelatedVideo &&
        other.displayPlaylist == displayPlaylist;
  }

  @override
  int get hashCode {
    return pmProCurrency.hashCode ^
        currencySymbol.hashCode ^
        _hashPayments(pmProPayments) ^
        wooConsumerKey.hashCode ^
        wooConsumerSecret.hashCode ^
        isMembershipEnabled.hashCode ^
        isSocialLoginEnabled.hashCode ^
        allowDownload.hashCode ^
        allowGuestDownload.hashCode ^
        displayCast.hashCode ^
        displayCrew.hashCode ^
        showViewCounter.hashCode ^
        displayRecommended.hashCode ^
        displayRelatedMovie.hashCode ^
        displayRelatedVideo.hashCode ^
        displayPlaylist.hashCode;
  }

  static String _parseString(dynamic value) {
    if (value is String) return value;
    if (value == null) return '';
    return value.toString();
  }

  static List<PmProPayments> _parsePayments(dynamic value) {
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().map(PmProPayments.fromJson).toList();
    }
    if (value is Map<String, dynamic>) {
      return [PmProPayments.fromJson(value)];
    }
    return const [];
  }

  static bool _listEquals(List<PmProPayments> a, List<PmProPayments> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static int _hashPayments(List<PmProPayments> payments) {
    return payments.fold<int>(payments.length, (hash, payment) => hash ^ payment.hashCode);
  }
}

class PmProPayments {
  final String type;
  final String entitlementId;
  final String googleApiKey;
  final String appleApiKey;

  const PmProPayments({
    this.type = '',
    this.entitlementId = '',
    this.googleApiKey = '',
    this.appleApiKey = '',
  });

  factory PmProPayments.fromJson(Map<String, dynamic> json) {
    return PmProPayments(
      type: json['type'] is String ? json['type'] as String : '',
      entitlementId: json['entitlement_id'] is String ? json['entitlement_id'] as String : '',
      googleApiKey: json['google_api_key'] is String ? json['google_api_key'] as String : '',
      appleApiKey: json['apple_api_key'] is String ? json['apple_api_key'] as String : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'entitlement_id': entitlementId,
      'google_api_key': googleApiKey,
      'apple_api_key': appleApiKey,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PmProPayments &&
        other.type == type &&
        other.entitlementId == entitlementId &&
        other.googleApiKey == googleApiKey &&
        other.appleApiKey == appleApiKey;
  }

  @override
  int get hashCode {
    return type.hashCode ^ entitlementId.hashCode ^ googleApiKey.hashCode ^ appleApiKey.hashCode;
  }
}
