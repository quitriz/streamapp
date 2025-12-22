class SettingsModel {
  bool? showTitles;
  bool? isLiveEnabled;
  String? appLogo;
  String? bannerDefaultImage;
  String? personDefaultImage;
  String? sliderDefaultImage;

  SettingsModel({
    this.showTitles,
    this.isLiveEnabled = false,
    this.appLogo,
    this.bannerDefaultImage,
    this.personDefaultImage,
    this.sliderDefaultImage,
  });

  factory SettingsModel.fromJson(dynamic json) {
    return SettingsModel(
      showTitles: json['show_titles'],
      isLiveEnabled: json['is_live_streaming_enable'] is bool ? json['is_live_streaming_enable'] : false,
      appLogo: json['app_logo_url'] is String ? json['app_logo_url'] : null,
      bannerDefaultImage: json['banner_default_image_url'] is String ? json['banner_default_image_url'] : null,
      personDefaultImage: json['person_default_image_url'] is String ? json['person_default_image_url'] : null,
      sliderDefaultImage: json['slider_default_image_url'] is String ? json['slider_default_image_url'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['show_titles'] = showTitles;
    map['is_live_streaming_enable'] = isLiveEnabled;
    map['app_logo_url'] = appLogo;
    map['banner_default_image_url'] = bannerDefaultImage;
    map['person_default_image_url'] = personDefaultImage;
    map['slider_default_image_url'] = sliderDefaultImage;

    return map;
  }
}