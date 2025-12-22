import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/onboarding_list_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/home_screen.dart';
import 'package:streamit_flutter/screens/onboarding_screen.dart';
import 'package:streamit_flutter/utils/cached_data.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';

class SplashScreen extends StatefulWidget {
  static String tag = '/SplashScreen';

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  String deviceId = '';

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() async {
      await precacheImage(AssetImage(app_logo_gif), context);
      getDeviceInfo();
      navigationToDashboard();
      getSettings();
      await getDashboardSettings();
    });
  }

  Future<void> getDashboardSettings() async {
    await getSettings().then((value) {
      appStore.setShowItemName(value.showTitles.validate());
      appStore.setEnableLiveStreaming(value.isLiveEnabled.validate());
      appStore.setAppLogo(value.appLogo.validate());
      appStore.setBannerDefaultImage(value.bannerDefaultImage.validate());
      appStore.setSliderDefaultImage(value.sliderDefaultImage.validate());
      appStore.setPersonDefaultImage(value.personDefaultImage.validate());
    }).catchError(onError);
  }

  Future<void> getDeviceInfo() async {
    if (Platform.isIOS) {
      final info = await DeviceInfoPlugin().iosInfo;
      deviceId = info.identifierForVendor.validate();
    }

    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      deviceId = info.id.validate();
    }
  }

  void navigationToDashboard() async {
    if (getBoolAsync(isLoggedIn) && getStringAsync(COOKIE_HEADER).isEmpty) {
      await 2.seconds.delay;

      if (appStore.isLogging) {
        logout();
      }
    } else {
      await 2.seconds.delay;
    }

    mIsLoggedIn = getBoolAsync(isLoggedIn) && getStringAsync(COOKIE_HEADER).isNotEmpty;

    if (getBoolAsync(isFirstTime, defaultValue: true)) {
      await setValue(isFirstTime, false);
      await fetchOnboardingDataOnFirstLaunch();
      OnBoardingScreen().launch(context, isNewTask: true);
    } else if (mIsLoggedIn) {
      HomeScreen().launch(context, isNewTask: true);
    } else {
      HomeScreen().launch(context, isNewTask: true);
    }
  }

  Future<void> fetchOnboardingDataOnFirstLaunch() async {
    try {
      if (!getBoolAsync(ONBOARDING_DATA_CACHED, defaultValue: false)) {
        OnBoardingListModel response = await getOnboardingList();

        if (response.data != null && response.data!.isNotEmpty) {
          OnboardingCachedData.storeData(data: response.toJson());
          await setValue(ONBOARDING_DATA_CACHED, true);

          if (response.status == true) {
          } else {
            log('Using fallback onboarding data due to API error: ${response.message}');
          }
        } else {
          log('No onboarding data available, app will proceed without onboarding');
          await setValue(ONBOARDING_DATA_CACHED, true);
        }
      } else {
        log('Onboarding data already cached, skipping API call');
      }
    } catch (e) {
      log('Critical error in onboarding data fetch: ${e.toString()}');
      await setValue(ONBOARDING_DATA_CACHED, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      body: Image.asset(app_logo_gif).center(),
    );
  }
}
