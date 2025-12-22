import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as custom_tab;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:streamit_flutter/config.dart';
import 'package:streamit_flutter/models/auth/check_user_session_response.dart';
import 'package:streamit_flutter/models/auth/login_response.dart';
import 'package:streamit_flutter/models/download_data.dart';
import 'package:streamit_flutter/models/settings/devices_model.dart';
import 'package:streamit_flutter/network/network_utils.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/auth/sign_in.dart';
import 'package:streamit_flutter/screens/settings/screens/manage_devices_screen.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:url_launcher/url_launcher_string.dart';

import '../main.dart';
import '../models/live_tv/live_channel_detail_model.dart';
import 'app_widgets.dart';

const MethodChannel _pipChannel = MethodChannel('pip_channel');
const String kPlaybackSessionValidationIntervalMinutes = '1';

DateTime? _lastPlaybackSessionValidatedAt;
CheckUserSessionResponse? _lastPlaybackSessionResponse;

Future<bool> get isIqonicProduct async => await getPackageName() == iqonicAppPackageName;

String get appNameTopic => app_name.toLowerCase().replaceAll(' ', '_');

SystemUiOverlayStyle defaultSystemUiOverlayStyle(BuildContext context, {Color? color, Brightness? statusBarIconBrightness}) {
  return SystemUiOverlayStyle(
      statusBarColor: color ?? context.scaffoldBackgroundColor,
      statusBarIconBrightness: statusBarIconBrightness ?? Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: context.scaffoldBackgroundColor);
}

String formatWatchedTime({required int totalSeconds, required int watchedSeconds}) {
  int remainingSeconds = totalSeconds - watchedSeconds;

  String text = Duration(seconds: remainingSeconds).toString().split('.').first;

  // Remove leading 0: if it's an hour format like 0:01:25
  if (text.startsWith('0:')) {
    text = text.substring(2);
  }

  return '$text';
}

String parseHtmlString(String? htmlString) {
  return parse(parse(htmlString).body!.text).documentElement!.text;
}

String buildLikeCountText(int like) {
  if (like > 1) {
    return '$like ${language.likes}';
  } else {
    return '$like ${language.like}';
  }
}

///Pluralizes an expiry period string based on the provided number
String pluralizeExpiryPeriod(String expirationNumber, String expirationPeriod) {
  int? number = int.tryParse(expirationNumber);
  if (number == null || number <= 1) {
    return expirationPeriod;
  }

  String period = expirationPeriod.trim();
  String periodLower = period.toLowerCase();
  bool isCapitalized = period.isNotEmpty && period[0] == period[0].toUpperCase();

  String plural;
  if (periodLower == "day") {
    plural = "days";
  } else if (periodLower == "month") {
    plural = "months";
  } else if (periodLower == "year") {
    plural = "years";
  } else if (periodLower == "week") {
    plural = "weeks";
  } else if (periodLower.endsWith("s")) {
    return period;
  } else {
    plural = "${periodLower}s";
  }

  return isCapitalized ? "${plural[0].toUpperCase()}${plural.substring(1)}" : plural;
}

/// Verify that user data is properly stored in shared preferences
Future<void> _verifyStoredUserData() async {
  final storedUserId = getIntAsync(USER_ID);
  final storedUsername = getStringAsync(USERNAME);
  final storedUserEmail = getStringAsync(USER_EMAIL);
  final storedFirstName = getStringAsync(NAME);
  final storedLastName = getStringAsync(LAST_NAME);
  final storedUserProfile = getStringAsync(USER_PROFILE);
  final isUserLoggedIn = getBoolAsync(isLoggedIn);

  log('=== VERIFYING STORED USER DATA ===');
  log('User ID: $storedUserId');
  log('Username: $storedUsername');
  log('User Email: $storedUserEmail');
  log('First Name: $storedFirstName');
  log('Last Name: $storedLastName');
  log('User Profile: $storedUserProfile');
  log('Is Logged In: $isUserLoggedIn');
  log('================================');

  if (storedUserId == 0 && storedUsername.isEmpty && storedUserEmail.isEmpty) {
    log('WARNING: User data appears to be empty in shared preferences!');
  } else {
    log('SUCCESS: User data is properly stored in shared preferences');
  }
}

Future<void> setUserData({required LoginResponse logRes}) async {
  log('Setting user data: ${logRes.toJson()}');

  appStore.setLogging(true);
  await appStore.setUserId(logRes.userId.validate());
  await appStore.setUserName(logRes.username.validate());
  await appStore.setUserEmail(logRes.userEmail.validate());
  await appStore.setFirstName(logRes.firstName.validate());
  await appStore.setLastName(logRes.lastName.validate());
  await appStore.setUserProfile(logRes.profileImage.validate().isEmpty ? userProfileImage() : logRes.profileImage.validate());

  log('User data set in AppStore - User ID: ${logRes.userId}, Username: ${logRes.username}, Email: ${logRes.userEmail}');

  await _verifyStoredUserData();

  if (logRes.plan != null) {
    appStore.setSubscriptionPlanStatus(logRes.plan!.status.validate());

    if (logRes.plan!.status == userPlanStatus) {
      appStore.setSubscriptionPlanId(logRes.plan!.subscriptionPlanId.validate());
      appStore.setSubscriptionPlanStartDate(logRes.plan!.startDate.validate());
      appStore.setSubscriptionPlanExpDate(logRes.plan!.expirationDate.validate());
      appStore.setSubscriptionPlanName(logRes.plan!.subscriptionPlanName.validate());
      appStore.setSubscriptionPlanAmount(logRes.plan!.billingAmount.validate());
      appStore.setSubscriptionTrialPlanStatus(logRes.plan!.trailStatus.validate());
      appStore.setSubscriptionTrialPlanEndDate(logRes.plan!.trialEnd.validate());
      if (coreStore.isInAppPurchaseEnabled) {
        appStore.setActiveSubscriptionIdentifier(isIOS ? logRes.plan!.playStorePlanIdentifier.validate() : logRes.plan!.playStorePlanIdentifier.validate());
        appStore.setActiveSubscriptionGoogleIdentifier(logRes.plan!.playStorePlanIdentifier.validate());
        appStore.setActiveSubscriptionAppleIdentifier(logRes.plan!.appStorePlanIdentifier.validate());
      }
    }
  }
}

class TabIndicator extends Decoration {
  final BoxPainter painter = TabPainter();

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => painter;
}

class TabPainter extends BoxPainter {
  Paint? _paint;

  TabPainter() {
    _paint = Paint()..color = colorPrimary;
  }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    Size size = Size(configuration.size!.width, 3);
    Offset _offset = Offset(offset.dx, offset.dy + 40);
    final Rect rect = _offset & size;
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          bottomRight: Radius.circular(0),
          bottomLeft: Radius.circular(0),
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        _paint!);
  }
}

Future<void> launchCustomTabURL({required String url}) async {
  String authURL = '${url}?HTTP_STREAMIT_WEBVIEW=true';
  try {
    await custom_tab.launchUrl(
      Uri.parse(authURL),
      customTabsOptions: custom_tab.CustomTabsOptions(
        colorSchemes: custom_tab.CustomTabsColorSchemes.defaults(toolbarColor: colorPrimary),
        animations: custom_tab.CustomTabsSystemAnimations.slideIn(),
        urlBarHidingEnabled: true,
        shareState: custom_tab.CustomTabsShareState.on,
        browser: custom_tab.CustomTabsBrowserConfiguration(
          fallbackCustomTabs: [
            'org.mozilla.firefox',
            'com.microsoft.emmx',
          ],
          headers: await buildTokenHeader(isWebView: true),
        ),
      ),
      safariVCOptions: custom_tab.SafariViewControllerOptions(
        barCollapsingEnabled: true,
        dismissButtonStyle: custom_tab.SafariViewControllerDismissButtonStyle.close,
        entersReaderIfAvailable: false,
        preferredControlTintColor: Colors.white,
        preferredBarTintColor: colorPrimary,
      ),
    );
  } catch (e) {
    // An exception is thrown if browser app is not installed on Android device.
    debugPrint(e.toString());
  }
}

Future<void> clearGuestDownloads() async {
  final storedDownloads = getStringAsync(DOWNLOADED_DATA);

  if (storedDownloads.isEmpty) {
    appStore.downloadedItemList.clear();
    return;
  }

  try {
    final decoded = jsonDecode(storedDownloads);
    if (decoded is! List) {
      appStore.downloadedItemList.clear();
      await setValue(DOWNLOADED_DATA, jsonEncode([]));
      return;
    }

    final List<Map<String, dynamic>> retainedEntries = [];
    bool removedAny = false;

    for (final entry in decoded) {
      if (entry is Map<String, dynamic>) {
        final map = Map<String, dynamic>.from(entry);
        final dynamic userId = map['userId'];
        final int parsedUserId = userId is num
            ? userId.toInt()
            : userId is String
                ? int.tryParse(userId) ?? 0
                : 0;
        final bool isGuestEntry = parsedUserId == 0;

        if (isGuestEntry) {
          removedAny = true;
          final filePath = map['file_path'] as String? ?? '';
          if (filePath.isNotEmpty) {
            final file = File(filePath);
            if (await file.exists()) {
              try {
                await file.delete();
              } catch (e) {
                log('clearGuestDownloads: failed to delete $filePath -> $e');
              }
            }
          }
        } else {
          retainedEntries.add(map);
        }
      }
    }

    await setValue(DOWNLOADED_DATA, jsonEncode(retainedEntries));

    appStore.downloadedItemList
      ..clear()
      ..addAll(retainedEntries.map((map) => DownloadData.fromJson(map)).toList());

    if (removedAny) {
      log('clearGuestDownloads: Removed ${decoded.length - retainedEntries.length} guest download(s).');
    }
  } catch (e) {
    log('clearGuestDownloads: Unable to process downloads -> $e');
    appStore.downloadedItemList.clear();
    await setValue(DOWNLOADED_DATA, jsonEncode([]));
  }
}

Future<void> addOrRemoveFromLocalStorage(DownloadData data, {bool isDelete = false}) async {
  List<DownloadData> list = getStringAsync(DOWNLOADED_DATA).isNotEmpty ? (jsonDecode(getStringAsync(DOWNLOADED_DATA)) as List).map((e) => DownloadData.fromJson(e)).toList() : [];

  if (list.isNotEmpty) {
    if (isDelete) {
      for (var i in list) {
        if (i.id == data.id) {
          appStore.downloadedItemList.removeWhere((element) => element.id == data.id);

          final file = File(data.filePath.validate());
          if (await file.exists()) {
            await file.delete().then((value) {
              toast(language.movieDeletedSuccessfullyFromDownloads);
              log('File Deleted  ===============> ${value.toString()}');
            }).catchError((e) {
              log('Error ===============> ${e.toString()}');
            });
          }
          break;
        }
      }
    } else {
      appStore.downloadedItemList.add(data);
    }
  } else {
    appStore.downloadedItemList.add(data);
  }

  log("Downloaded Item : ${list.map((e) => e.id)}");
  await setValue(DOWNLOADED_DATA, jsonEncode(appStore.downloadedItemList));
  log("Decoded downloaded items : ${getStringAsync(DOWNLOADED_DATA)}");
}

Future<void> shareMovieOrEpisode(String videUrl) async {
  await SharePlus.instance.share(ShareParams(text: videUrl));
}

Duration? _playbackSessionValidationInterval() {
  final minutes = int.tryParse(kPlaybackSessionValidationIntervalMinutes);
  if (minutes == null || minutes <= 0) return null;
  return Duration(minutes: minutes);
}

Future<bool> ensureUserPlaybackAllowed(BuildContext context) async {
  if (!appStore.isLogging) {
    await SignInScreen(redirectTo: () {}).launch(context);
    return false;
  }

  final Duration? interval = _playbackSessionValidationInterval();
  final DateTime now = DateTime.now();

  if (interval != null && _lastPlaybackSessionValidatedAt != null) {
    final difference = now.difference(_lastPlaybackSessionValidatedAt!);
    if (difference < interval && _lastPlaybackSessionResponse != null) {
      if (_lastPlaybackSessionResponse!.isSuccess) {
        return true;
      } else {
        await _handlePlaybackSessionFailure(context, _lastPlaybackSessionResponse!);
        return false;
      }
    }
  }

  try {
    final CheckUserSessionResponse response = await checkUserSession();
    _lastPlaybackSessionValidatedAt = DateTime.now();
    _lastPlaybackSessionResponse = response;

    if (response.isSuccess) return true;

    await _handlePlaybackSessionFailure(context, response);
  } catch (error) {
    log('Playback validation failed: $error');
    _lastPlaybackSessionValidatedAt = null;
    _lastPlaybackSessionResponse = null;
    toast(error.toString());
  }

  return false;
}

// Flag to prevent multiple session dialogs from showing simultaneously
bool _isSessionDialogShowing = false;

/// Custom single-button dialog for session validation scenarios
Future<void> _showSingleButtonDialog({
  required BuildContext context,
  required String title,
  required String buttonText,
  required Color buttonColor,
  required VoidCallback onButtonTap,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: context.cardColor,
        title: Text(
          title,
          style: boldTextStyle(size: 20),
          textAlign: TextAlign.center,
        ),
        contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 24),
        actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          SizedBox(
            width: double.infinity,
            child: AppButton(
              color: buttonColor,
              textColor: Colors.white,
              text: buttonText,
              onTap: () {
                finish(dialogContext);
                onButtonTap();
              },
            ),
          ),
        ],
      );
    },
  );
}

/// Common handler for all session validation dialog scenarios
/// Handles cookiesNotValid, loginLimitExceeded, and other session errors
Future<void> _showSessionValidationDialog({
  required BuildContext context,
  required String? errorCode,
  required String message,
  bool useGlobalContext = false,
}) async {
  if (_isSessionDialogShowing) {
    return;
  }

  final dialogContext = useGlobalContext ? (navigatorKey.currentContext ?? context) : context;
  _isSessionDialogShowing = true;

  try {
    if (errorCode == SessionErrorCode.cookiesNotValid) {
      await _showSingleButtonDialog(
        context: dialogContext,
        title: message.isEmpty ? language.sessionExpired : message,
        buttonText: language.signIn,
        buttonColor: dialogContext.primaryColor,
        onButtonTap: () async {
          _isSessionDialogShowing = false;
          final navContext = navigatorKey.currentContext ?? dialogContext;
          await SignInScreen().launch(navContext, isNewTask: true);
        },
      );
    } else if (errorCode == SessionErrorCode.loginLimitExceeded) {
      await _showSingleButtonDialog(
        context: dialogContext,
        title: message,
        buttonText: language.manageDevices,
        buttonColor: dialogContext.primaryColor,
        onButtonTap: () async {
          _isSessionDialogShowing = false;
          final navContext = navigatorKey.currentContext ?? dialogContext;
          await ManageDevicesScreen(isFromSettings: true).launch(navContext);
        },
      );
    } else {
      await _showSingleButtonDialog(
        context: dialogContext,
        title: message,
        buttonText: language.ok,
        buttonColor: dialogContext.primaryColor,
        onButtonTap: () {
          _isSessionDialogShowing = false;
        },
      );
    }
  } catch (e) {
    _isSessionDialogShowing = false;
  }
}

Future<void> _handlePlaybackSessionFailure(BuildContext context, CheckUserSessionResponse response) async {
  final String message = response.message.validate(value: 'Something went wrong. Please try again.');
  await _showSessionValidationDialog(
    context: context,
    errorCode: response.errorCode,
    message: message,
  );
}

/// Public function to handle playback session failure
/// Can be called from video players for periodic validation
Future<void> handlePlaybackSessionFailure(BuildContext context, CheckUserSessionResponse response) async {
  await _handlePlaybackSessionFailure(context, response);
}

/// Shows session expired dialog globally using navigatorKey
/// This dialog appears when API returns 401 with "Authorization header not found." message
/// Only shows if user was previously logged in (to avoid showing on first app launch)
Future<void> showSessionExpiredDialog() async {
  // Only show session expired dialog if user was previously logged in
  // If user was never logged in, don't show the dialog (they're just not authenticated)
  // Check if user was logged in by checking store, preferences, or stored cookie
  final wasLoggedIn = appStore.isLogging || getBoolAsync(isLoggedIn) || getStringAsync(COOKIE_HEADER).isNotEmpty;

  if (!wasLoggedIn) {
    return;
  }

  final context = navigatorKey.currentContext;
  if (context == null) {
    return;
  }

  await _showSessionValidationDialog(
    context: context,
    errorCode: SessionErrorCode.cookiesNotValid,
    message: language.sessionExpired,
    useGlobalContext: true,
  );
}

Future<String> getQualitiesAsync({required String videoId, required String embedContent}) async {
  try {
    final videoUrl = 'https://player.vimeo.com/video/$videoId/config';
    final response = await http.get(Uri.parse(videoUrl));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body)['request']['files']['progressive'];
      if (jsonData is List && !jsonData.isEmpty) {
        final videoList = SplayTreeMap.fromIterable(jsonData, key: (item) => "${item['quality']}", value: (item) => item['url']);
        final maxQuality = videoList.keys.map((e) => int.parse(e)).reduce(max);
        return videoList[maxQuality.toString()] as String;
      }
    }
    return getVideoLink(embedContent.validate());
  } catch (error) {
    log('=====> REQUEST ERROR: $error <=====');
    return getVideoLink(embedContent.validate());
  }
}

Future<void> appLaunchUrl(String url, {bool forceWebView = false, LaunchMode mode = LaunchMode.inAppWebView}) async {
  await url_launcher.launchUrl(Uri.parse(url), mode: mode).catchError((e) {
    log(e);
    toast('Invalid URL: $url');
    return Future.value(false);
  });
}

String getVideoLink(String htmlData) {
  var document = parse(htmlData);
  dom.Element? link = document.querySelector('iframe');
  String? iframeLink = link != null ? link.attributes['src'].validate() : '';
  return iframeLink.validate();
}

InputDecoration inputDecorationFilled(BuildContext context, {String? label, EdgeInsetsGeometry? contentPadding, required Color fillColor, Widget? prefix}) {
  return InputDecoration(
    fillColor: fillColor,
    filled: true,
    contentPadding: contentPadding ?? EdgeInsets.all(16),
    labelText: label,
    labelStyle: secondaryTextStyle(color: Colors.white),
    errorStyle: primaryTextStyle(color: Colors.red, size: 12),
    enabledBorder: OutlineInputBorder(borderRadius: radius(defaultAppButtonRadius), borderSide: BorderSide(color: context.cardColor)),
    disabledBorder: OutlineInputBorder(borderRadius: radius(defaultAppButtonRadius), borderSide: BorderSide(color: context.cardColor)),
    focusedBorder: OutlineInputBorder(borderRadius: radius(defaultAppButtonRadius), borderSide: BorderSide(color: context.cardColor)),
    border: OutlineInputBorder(borderRadius: radius(defaultAppButtonRadius), borderSide: BorderSide(color: context.cardColor)),
    focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 1.0)),
    errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 1.0)),
    alignLabelWithHint: true,
    prefix: prefix,
  );
}

Widget noDataImage() {
  return Image.asset(no_data_gif, height: 160, width: 160, fit: BoxFit.cover).cornerRadiusWithClipRRect(80);
}

double getWidth(BuildContext context) {
  double width = 140;

  if (context.width() < 400) {
    width = context.width() / 2 - 20;
  } else {
    width = context.width() / 3 - 16;
  }

  return width;
}

double getViewAllWidth(BuildContext context) {
  double width = 140;

  if (context.width() < 300) {
    width = context.width() / 2 - 20;
  } else {
    width = context.width() / 3 - 16;
  }

  return width;
}

String formatDate(String date) {
  DateTime input = DateFormat('yyyy-MM-DDTHH:mm:ss').parse(date, true);

  return DateFormat.yMMMMd().format(input).toString();
}

String getYearFromDate(String dateString) {
  if (dateString.isEmpty) return '';
  try {
    DateTime dateTime = DateTime.parse(dateString);
    return dateTime.year.toString();
  } catch (e) {
    if (dateString.length >= 4) {
      return dateString.substring(0, 4);
    }
    return '';
  }
}

InputDecoration inputDecoration(
  BuildContext context, {
  String? hint,
  String? label,
  TextStyle? hintStyle,
  TextStyle? labelStyle,
  Widget? prefix,
  EdgeInsetsGeometry? contentPadding,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    contentPadding: contentPadding,
    labelText: label,
    hintText: hint,
    hintStyle: hintStyle ?? secondaryTextStyle(),
    labelStyle: labelStyle ?? secondaryTextStyle(),
    prefix: prefix,
    prefixIcon: prefixIcon,
    errorMaxLines: 2,
    errorStyle: primaryTextStyle(color: Colors.red, size: 12),
    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: textColorThird)),
    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.primaryColor)),
    border: UnderlineInputBorder(borderSide: BorderSide(color: context.primaryColor)),
    focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 1.0)),
    errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 1.0)),
    alignLabelWithHint: true,
    suffixIcon: suffixIcon,
  );
}

String convertToAgo(String dateTime) {
  if (dateTime.isNotEmpty) {
    DateTime? input;

    if (dateTime.contains('T')) {
      input = DateFormat(DATE_FORMAT_2).parse(dateTime, false);
    } else if (dateTime.contains('-') && dateTime.indexOf('-') == 2) {
      input = DateFormat(DATE_FORMAT_3).parse(dateTime, false);
    } else {
      input = DateFormat(DATE_FORMAT_1).parse(dateTime, false);
    }

    return streamitFormatTime(input.millisecondsSinceEpoch);
  } else {
    return '';
  }
}

String streamitFormatTime(int timestamp) {
  int difference = DateTime.now().millisecondsSinceEpoch - timestamp;
  String result;

  if (difference < 60000) {
    result = countSeconds(difference);
  } else if (difference < 3600000) {
    result = countMinutes(difference);
  } else if (difference < 86400000) {
    result = countHours(difference);
  } else if (difference < 604800000) {
    result = countDays(difference);
  } else if (difference / 1000 < 2419200) {
    result = countWeeks(difference);
  } else if (difference / 1000 < 31536000) {
    result = countMonths(difference);
  } else
    result = countYears(difference);

  return result != language.justNow.capitalizeFirstLetter() ? result + ' ${language.ago.toLowerCase()}' : result;
}

String getPostContent(String? postContent) {
  String content = '';

  content = postContent
      .validate()
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('[embed]', '<embed>')
      .replaceAll('[/embed]', '</embed>')
      .replaceAll('[caption]', '<caption>')
      .replaceAll('[/caption]', '</caption>')
      .replaceAll('[blockquote]', '<blockquote>')
      .replaceAll('[/blockquote]', '</blockquote>')
      .replaceAll('\t', '')
      .replaceAll('\n', '');

  return content;
}

extension DurationExtensions on Duration {
  bool get isNearZero => inMilliseconds < 100;

  bool isNearTo(Duration other, {Duration threshold = const Duration(seconds: 1)}) {
    return (inMilliseconds - other.inMilliseconds).abs() <= threshold.inMilliseconds;
  }
}

extension AdUnitExtensions on AdUnit {
  bool get isVideoAd => type == AdTypeConst.video || type == AdTypeConst.vast;

  bool get isHtmlAd => type == AdTypeConst.html;

  bool get isOverlayAd => isHtmlAd && overlay == true;

  bool get isCompanionAd => isHtmlAd && overlay != true && adFormat?.toLowerCase() == AdTypeConst.companion;

  bool get canBeSkipped => skipEnabled.validate();

  Duration get skipDurationAsDuration => Duration(seconds: skipDuration ?? 5);

  int get skipDurationInSeconds => skipDurationAsDuration.inSeconds;
}

String getPostTypeString(PostType? contentType) {
  if (contentType == null) return '';

  switch (contentType) {
    case PostType.MOVIE:
      return ReviewConst.reviewTypeMovie;
    case PostType.TV_SHOW:
      return ReviewConst.reviewTypeTvShow1;
    case PostType.EPISODE:
      return ReviewConst.reviewTypeEpisode;
    case PostType.VIDEO:
      return ReviewConst.reviewTypeVideo;
    case PostType.NONE:
    default:
      return '';
  }
}

/// Rental Price Widget for Pay-Per-View or Rental Movies
Widget rentalPriceWidget({required num discountedPrice, required num price}) {
  final bool hasDiscount = price != discountedPrice;
  final String currency = parseHtmlString(coreStore.pmProCurrency);

  if (hasDiscount) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${language.rentFor} ', style: boldTextStyle(color: rentButtonTextColor)),
        Text(
          '$currency${price}',
          style: boldTextStyle(color: white, decoration: TextDecoration.lineThrough, decorationColor: white, textDecorationStyle: TextDecorationStyle.solid).copyWith(decorationThickness: 2.43),
        ),
        4.width,
        Text('$currency${discountedPrice}', style: boldTextStyle(color: rentButtonTextColor)),
      ],
    );
  } else {
    return Text(
      '${language.rentFor} $currency${discountedPrice}',
      style: boldTextStyle(color: rentButtonTextColor),
    );
  }
}

/// Function to check if the device is running Android 12 or above
Future<bool> requestStoragePermissionForDownload() async {
  try {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        // Android 13+ (API 33+) - No special permissions needed for app-specific directories
        // We'll use app-specific external storage which doesn't require permissions
        return true;
      } else {
        // Android 12 and below - Use legacy storage permission
        var status = await Permission.storage.status;

        if (status.isGranted) {
          return true;
        }

        status = await Permission.storage.request();

        if (status.isGranted) {
          return true;
        } else if (status.isPermanentlyDenied) {
          await openAppSettings();
          return false;
        } else {
          return false;
        }
      }
    }

    return true; // For iOS and other platforms
  } catch (e) {
    print('Permission request error: $e');
    return false;
  }
}

Future<String> getDownloadDirectory() async {
  if (Platform.isAndroid) {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 33) {
      // For Android 13+, use app-specific external directory
      // This doesn't require any special permissions
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        // Create a Downloads folder in app-specific directory
        final downloadDir = Directory('${directory.path}/Downloads');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        return downloadDir.path;
      } else {
        // Fallback to internal storage
        final directory = await getApplicationDocumentsDirectory();
        return directory.path;
      }
    } else {
      // For older versions, use the public Documents directory
      return '/storage/emulated/0/Documents';
    }
  }

  // For other platforms
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

/// Converts runtime from "HH:MM" format to human-readable format
/// Examples: "2:04" -> "2h04m", "00:40" -> "40m", "02:00" -> "2h"
String convertRuntimeToReadableFormat(String runtime) {
  if (runtime.isEmpty) return runtime;

  final parts = runtime.split(':');
  if (parts.length != 2) return runtime;

  final hours = int.tryParse(parts[0]);
  final minutes = int.tryParse(parts[1]);

  if (hours == null || minutes == null) return runtime;

  if (hours == 0 && minutes == 0) return runtime;

  final buffer = StringBuffer();
  if (hours > 0) buffer.write('${hours}h');
  if (minutes > 0) {
    buffer.write(hours > 0 ? minutes.toString().padLeft(2, '0') : minutes);
    buffer.write('m');
  }

  return buffer.toString();
}

/// Helper function to parse release date string to DateTime
/// Handles date parsing with multiple fallback formats
DateTime? parseReleaseDate(String dateString) {
  if (dateString.isEmpty) return null;

  try {
    final trimmed = dateString.trim().split(' ').first;
    var parsed = DateTime.tryParse(trimmed);
    if (parsed != null) return parsed;

    final formats = <String>[
      DATE_FORMAT_4,
      if (dateString.contains('AM') || dateString.contains('PM')) ...[
        'yyyy-MM-dd h:mm a',
        'yyyy-MM-dd hh:mm a',
      ],
      DATE_FORMAT_5,
    ];

    // Try each format
    for (final format in formats) {
      try {
        return DateFormat(format).parse(dateString);
      } catch (_) {
        continue;
      }
    }

    log('Failed to parse date with all formats: $dateString');
    return null;
  } catch (e) {
    log('Error parsing release date: $dateString, error: $e');
    return null;
  }
}

///Manage PiP functionality

Future<void> enterPiPMode() async {
  try {
    final bool result = await _pipChannel.invokeMethod('enterPiP');
    log(result);
    if (result) {
      log("PiP mode started!");
      appStore.showPIP = true; // <- important
      appStore.hasInFullScreen = false; // <- exit fullscreen
    } else {
      log("PiP not supported on this device");
    }
  } on PlatformException catch (e) {
    log("Failed to enter PiP: ${e.message}");
  }
}

///Remind Me Handler with Optimistic UI Updates
Future<bool> handleRemindMeWithOptimisticUI({
  required BuildContext context,
  required int contentId,
  required String postType,
  int? seasonId,
  VoidCallback? onOptimisticUpdate,
  VoidCallback? onRollback,
  VoidCallback? onAnimationTrigger,
}) async {
  try {
    /// Step 1: Authentication Check
    if (!appStore.isLogging) {
      log('RemindMe: User not authenticated, redirecting to sign-in');
      SignInScreen(redirectTo: () {}).launch(context);
      return false;
    }

    /// Step 2: Input Validation
    if (contentId <= 0) {
      log('RemindMe: Invalid contentId provided: $contentId');
      toast(language.somethingWentWrong, print: true);
      return false;
    }

    final allowedPostTypes = ['movie', 'video', 'tvshow', 'episode'];
    if (!allowedPostTypes.contains(postType.toLowerCase())) {
      log('RemindMe: Invalid postType provided: $postType. Allowed types: $allowedPostTypes');
      toast(language.somethingWentWrong, print: true);
      return false;
    }

    /// Step 3: Optimistic UI Update
    if (onOptimisticUpdate != null) {
      log('RemindMe: Executing optimistic UI update');
      try {
        onOptimisticUpdate();
      } catch (e) {
        log('RemindMe: Error in optimistic update callback: $e');
      }
    }

    /// Step 4: Trigger Animation
    if (onAnimationTrigger != null) {
      log('RemindMe: Triggering animation callback');
      try {
        onAnimationTrigger();
      } catch (e) {
        log('RemindMe: Error in animation trigger callback: $e');
      }
    }

    /// Step 5: Build API Request
    Map<String, dynamic> request = {"id": contentId, "post_type": postType.toLowerCase()};

    if (seasonId != null && seasonId > 0 && postType.toLowerCase() == 'tvshow') {
      request["season_id"] = seasonId;
      log('RemindMe: Added seasonId to request: $seasonId');
    }

    log('RemindMe: API request payload: $request');

    /// Step 6: Execute API Call
    final response = await remindMeNotification(request);

    /// Step 7: Handle Success
    if (response.message?.isNotEmpty == true) {
      log('RemindMe: API call successful. Message: ${response.message}');
      toast(response.message!, print: true);
    } else {
      log('RemindMe: API call successful but no message provided');
      toast('Reminder set successfully', print: true);
    }

    return true;
  } catch (e) {
    /// Step 8: Error Handling & Rollback
    log('RemindMe: API call failed with error: $e');
    if (onRollback != null) {
      log('RemindMe: Executing rollback callback to revert optimistic changes');
      try {
        onRollback();
      } catch (rollbackError) {
        log('RemindMe: Error in rollback callback: $rollbackError');
      }
    }
    final errorMessage = e.toString();
    if (errorMessage.contains('network') || errorMessage.contains('timeout')) {
      toast('Please check your internet connection', print: true);
    } else if (errorMessage.contains('unauthorized') || errorMessage.contains('401')) {
      toast('Your session has expired. Please sign in again.', print: true);
    } else {
      toast(errorMessage, print: true);
    }

    return false;
  }
}

/// Verify devices and add device info if needed
/// Returns true if should navigate to home screen, false if already navigated to ManageDevicesScreen
///
/// [username] - email/username for the user
/// [password] - password (optional, null for social login)
/// [isForSocialLogin] - flag to handle social login vs email/password login
Future<bool> verifyAndAddDevice({
  required String username,
  String? password,
  bool isForSocialLogin = false,
}) async {
  try {
    // First, get the current device info
    String currentDeviceId = '';
    if (Platform.isIOS) {
      final info = await DeviceInfoPlugin().iosInfo;
      currentDeviceId = info.identifierForVendor.validate();
    } else if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      currentDeviceId = info.id.validate();
    }

    // For email/password login, verify device status first
    if (!isForSocialLogin && password != null) {
      try {
        // Call getDevices API to verify device status
        Map request = {"username": username, "password": password};
        DeviceModel deviceResponse = await getDevices(request: request);

        // Check if current device is already registered
        bool isDeviceRegistered = deviceResponse.data.any((device) => device.deviceId == currentDeviceId);

        // Silently auto-register the current device if not already registered
        if (!isDeviceRegistered) {
          await addDeviceInfo(username: username, password: password, isForSocialLogin: isForSocialLogin);
        } else {
          // Device is already registered, just update the stored device ID
          appStore.setLoginDevice(currentDeviceId);
        }

        return true; // Proceed with navigation to home screen
      } catch (e) {
        // If getDevices fails, try to add device anyway (fallback)
        log('Error verifying devices: $e');
        await addDeviceInfo(username: username, password: password, isForSocialLogin: isForSocialLogin);
        return true; // Proceed with navigation to home screen
      }
    } else {
      // For social login, directly add device info without verification
      await addDeviceInfo(username: username, password: password, isForSocialLogin: isForSocialLogin);
      return true; // Proceed with navigation to home screen
    }
  } catch (e) {
    log('Error in verifyAndAddDevice: $e');
    // Try to add device anyway as fallback
    await addDeviceInfo(username: username, password: password, isForSocialLogin: isForSocialLogin);
    return true; // Proceed with navigation to home screen
  }
}

/// Add device info to the server
/// [username] - email/username for the user
/// [password] - password (optional, null for social login)
/// [isForSocialLogin] - flag to handle social login vs email/password login
Future<void> addDeviceInfo({required String username, String? password, bool isForSocialLogin = false}) async {
  String id = '';
  String model = '';
  String name = '';

  if (Platform.isIOS) {
    final info = await DeviceInfoPlugin().iosInfo;
    id = info.identifierForVendor.validate();
    model = info.model.validate();
    name = info.name.validate();
  } else if (Platform.isAndroid) {
    final info = await DeviceInfoPlugin().androidInfo;
    id = info.id.validate();
    model = info.model.validate();
    name = info.name.validate();
  }

  if (id.isEmpty) {
    log('Device ID is empty, cannot add device info');
    return;
  }

  DateTime currentPhoneDate = DateTime.now();
  int timeStamp = currentPhoneDate.millisecondsSinceEpoch;
  final String loginToken = getStringAsync(COOKIE_HEADER);

  Map<String, dynamic> request = {
    "username": username,
    "device_id": id,
    "device_model": model,
    "device_name": name,
    "last_login_time": timeStamp.toString(),
    "login_token": loginToken,
  };

  // Add password for email/password login
  if (!isForSocialLogin && password != null) {
    request["password"] = password;
  }

  // Add social login flag for social login
  if (isForSocialLogin) {
    request["is_social_login"] = true;
  }

  addDevices(request).then((value) {
    appStore.setLoginDevice(id);
  }).catchError((error) {
    log('Error adding device info: $error');
  });
}
