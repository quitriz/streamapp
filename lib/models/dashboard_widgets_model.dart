import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/fragments/genre_fragment.dart';
import 'package:streamit_flutter/fragments/home_fragment.dart';
import 'package:streamit_flutter/fragments/profile_fragment.dart';
import 'package:streamit_flutter/fragments/search_fragment.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';

import '../fragments/live_fragment.dart';

class DashboardWidgetsModel {
  String? fragment;
  Widget? widget;
  Widget? icon;
  Widget? selectedIcon;

  DashboardWidgetsModel({this.fragment, this.widget, this.icon, this.selectedIcon});
}

List<DashboardWidgetsModel> getFragments() {
  List<DashboardWidgetsModel> list = [];

  list.add(
    DashboardWidgetsModel(
      fragment: language.home,
      icon: CachedImageWidget(url: ic_home, height: 24, width: 24, fit: BoxFit.cover, color: rememberMeColor),
      selectedIcon: CachedImageWidget(url: ic_home_filled, height: 24, width: 24, fit: BoxFit.cover, color: colorPrimary),
      widget: HomeFragment(),
    ),
  );
  list.add(
    DashboardWidgetsModel(
      fragment: language.search,
      icon: CachedImageWidget(url: ic_search, height: 24, width: 24, fit: BoxFit.cover, color: rememberMeColor),
      selectedIcon: CachedImageWidget(url: ic_search_filled, height: 24, width: 24, fit: BoxFit.cover, color: colorPrimary),
      widget: SearchFragment(),
    ),
  );
  if (appStore.isLiveEnabled) {
    list.add(
      DashboardWidgetsModel(
        fragment: language.live.capitalizeFirstLetter(),
        icon: Icon(Icons.live_tv, size: 24, color: rememberMeColor),
        selectedIcon: Icon(Icons.live_tv_rounded, color: colorPrimary, size: 24),
        widget: LiveFragment(),
      ),
    );
  }
  list.add(
    DashboardWidgetsModel(
      fragment: language.genre,
      icon: CachedImageWidget(url: ic_genre, height: 24, width: 24, fit: BoxFit.cover, color: rememberMeColor),
      selectedIcon: CachedImageWidget(url: ic_genre_filled, height: 24, width: 24, fit: BoxFit.cover, color: colorPrimary),
      widget: GenreFragment(),
    ),
  );
  list.add(
    DashboardWidgetsModel(
      fragment: language.profile,
      icon: appStore.isLogging
          ? CachedImageWidget(url: appStore.userProfileImage.validate(), height: 24, width: 24, fit: BoxFit.cover, circle: true)
          : Icon(Icons.person_outlined, size: 24, color: rememberMeColor),
      selectedIcon: appStore.isLogging
          ? Container(
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: colorPrimary, width: 1)),
              child: CachedImageWidget(url: appStore.userProfileImage.validate(), height: 24, width: 24, fit: BoxFit.cover, circle: true))
          : Icon(Icons.person, color: colorPrimary, size: 24),
      widget: ProfileFragment(),
    ),
  );
  return list;
}
