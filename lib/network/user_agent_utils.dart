import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/config.dart';

class UserAgentUtils {
  static String? _cachedUserAgent;

  static Future<String> generateUserAgent({String? appVersion}) async {
    if (_cachedUserAgent != null) {
      return _cachedUserAgent!;
    }

    try {
      String platform = '';
      String deviceName = '';
      String deviceModel = '';
      String osVersion = '';
      String version = appVersion ?? '1.0';

      if (appVersion == null) {
        try {
          final packageInfo = await getPackageInfo();
          version = packageInfo.versionName.validate();
        } catch (e) {
          version = '1.0';
        }
      }

      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        platform = 'Android';
        deviceName = androidInfo.name.validate();
        deviceModel = androidInfo.display.validate();
        osVersion = androidInfo.version.release.validate();
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        platform = 'iOS';
        deviceName = iosInfo.name.validate();
        deviceModel = iosInfo.model.validate();
        osVersion = iosInfo.systemVersion.validate();
      }

      String userAgent = '$app_name/$version ($platform $osVersion; $deviceName; $deviceModel)';
      
      _cachedUserAgent = userAgent;
      
      return userAgent;
    } catch (e) {
      String fallbackUserAgent = 'StreamIt-Flutter/1.0 (Unknown Device)';
      _cachedUserAgent = fallbackUserAgent;
      return fallbackUserAgent;
    }
  }

  static void clearCache() {
    _cachedUserAgent = null;
  }

  static Future<String> getDeviceName() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return androidInfo.device.validate();
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.name.validate();
      }
    } catch (e) {
      return 'Unknown Device';
    }
    return 'Unknown Device';
  }

  static Future<String> getDeviceModel() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return androidInfo.model.validate();
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.model.validate();
      }
    } catch (e) {
      return 'Unknown Model';
    }
    return 'Unknown Model';
  }
}
