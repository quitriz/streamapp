import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/dashboard_widgets_model.dart';
import 'package:streamit_flutter/models/download_data.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/settings/screens/settings_screen.dart';
import 'package:streamit_flutter/services/in_app_purchase_service.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class HomeScreen extends StatefulWidget {
  static String tag = '/HomeScreen';

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    if (appStore.isLogging) {
      callNonceApi();
    }

    try {
      await coreStore.ensureLoaded();
      if (coreStore.isInAppPurchaseEnabled) {
        await InAppPurchaseService.init();
      }
    } catch (e) {
      log('Failed to load core settings: $e');
    }

    if (getStringAsync(DOWNLOADED_DATA).isNotEmpty) {
      List<DownloadData> listData = (jsonDecode(getStringAsync(DOWNLOADED_DATA)) as List).map((e) => DownloadData.fromJson(e)).toList();
      for (DownloadData data in listData) {
        if (data.userId.validate() == getIntAsync(USER_ID)) {
          appStore.downloadedItemList.add(data);
        }
      }
    }
  }

  Future<void> callNonceApi() async {
    getNonce(type: NonceTypes.woo).then((value) {
      appStore.setWooNonce(value.nonce.validate());
    }).catchError((e) {
      log(' error: ${e.toString()}');
    });

    getNonce(type: NonceTypes.user).then((value) {
      appStore.setUserNonce(value.nonce.validate());
    }).catchError((e) {
      log('error: ${e.toString()}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return DoublePressBackWidget(
      onWillPop: () async {
        if (appStore.bottomNavigationCurrentIndex == 0) return Future.value(true);
        return Future.value(false);
      },
      child: Observer(
        builder: (context) {
          List<DashboardWidgetsModel> tabs = getFragments();
          return Scaffold(
            body: tabs[appStore.bottomNavigationCurrentIndex].widget,
            bottomNavigationBar: Observer(
              builder: (context) {
                if (appStore.hasInFullScreen)
                  return Offstage();
                else
                  return BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    currentIndex: appStore.bottomNavigationCurrentIndex,
                    selectedItemColor: colorPrimary,
                    unselectedItemColor: rememberMeColor,
                    backgroundColor: appBackground,
                    elevation: 0,
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    onTap: (i) {
                      if ((i == tabs.validate().length - 1) && !mIsLoggedIn) {
                        SettingsScreen().launch(context);
                      } else {
                        appStore.setBottomNavigationIndex(i);
                      }
                    },
                    items: List.generate(
                      tabs.length,
                      (index) {
                        return BottomNavigationBarItem(
                          tooltip: tabs[index].fragment.validate(),
                          icon: appStore.bottomNavigationCurrentIndex == index ? tabs[index].selectedIcon.validate() : tabs[index].icon.validate(),
                          label:tabs[index].fragment.validate(),
                        );
                      },
                    ),
                  );
              },
            ),
          );
        },
      ),
    );
  }
}
