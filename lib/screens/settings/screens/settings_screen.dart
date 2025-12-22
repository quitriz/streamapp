// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/common_action_bottom_sheet.dart';
import 'package:streamit_flutter/config.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/auth/sign_in.dart';
import 'package:streamit_flutter/screens/downloads/guest_downloads_screen.dart';
import 'package:streamit_flutter/screens/liked_content/liked_content_list.dart';
import 'package:streamit_flutter/screens/playlist/screens/playlist_screen.dart';
import 'package:streamit_flutter/screens/pmp/screens/my_account_screen.dart';
import 'package:streamit_flutter/screens/pmp/screens/my_rentals_screen.dart';
import 'package:streamit_flutter/screens/settings/screens/change_password_screen.dart';
import 'package:streamit_flutter/screens/settings/screens/language_screen.dart';
import 'package:streamit_flutter/screens/settings/screens/manage_devices_screen.dart';
import 'package:streamit_flutter/utils/app_widgets.dart';
import 'package:streamit_flutter/utils/common.dart';
// import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';
import 'package:streamit_flutter/utils/resources/size.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Pause dashboard video when navigating to settings
    appStore.setDashboardShowVideo(false);
    appStore.resetDashboardVideoState();
  }

  void showSignOutBottomSheet(BuildContext context) {
    showCommonActionBottomSheet(
      context: context,
      title: "${language.doYouReallyWant}",
      subtitle: "${language.areYouSureYouWantToSignOut}",
      icon: ic_signOut,
      positiveText: language.signOut,
      negativeText: language.cancel,
      positiveOnTap: () async {
        finish(context);
        await logout(isNewTask: true, context: context).then((_) {
          toast(language.youHaveBeenLoggedOutSuccessfully);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardColor,
      appBar: AppBar(
        title: Text(language.settings, style: primaryTextStyle(size: ts_large.toInt())),
        elevation: 0,
        centerTitle: true,
        backgroundColor: appBackground,
        surfaceTintColor: appBackground,
        systemOverlayStyle: defaultSystemUiOverlayStyle(context),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 60),
        child: Column(
          children: [
            if (!appStore.isLogging && coreStore.allowGuestDownload)
              SettingWidget(
                title: language.guestDownloads,
                titleTextStyle: primaryTextStyle(),
                leading: CachedImageWidget(
                  url: ic_download,
                  height: 18,
                  width: 18,
                  color: context.iconColor,
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                onTap: () {
                  const GuestDownloadsScreen().launch(context);
                },
              ),
            if (coreStore.isMembershipEnabled && appStore.isLogging)
              SettingWidget(
                title: language.myRentals,
                titleTextStyle: primaryTextStyle(),
                leading: CachedImageWidget(
                  url: ic_rentals,
                  height: 18,
                  width: 18,
                  color: context.iconColor,
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                onTap: () {
                  MyRentalsScreen().launch(context);
                },
              ),
            if (appStore.isLogging && coreStore.shouldShowPlaylist)
              SettingWidget(
                title: language.playlists,
                titleTextStyle: primaryTextStyle(),
                leading: CachedImageWidget(url: ic_add_playlist, height: 18, width: 18, color: context.iconColor),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                onTap: () {
                  if (appStore.isLogging) {
                    PlayListScreen().launch(context);
                  } else {
                    SignInScreen(
                      redirectTo: () {
                        PlayListScreen().launch(context);
                      },
                    ).launch(context);
                  }
                },
              ),
            if (appStore.isLogging)
              SettingWidget(
                title: language.likedByYou,
                titleTextStyle: primaryTextStyle(),
                leading: CachedImageWidget(url: ic_like, height: 18, width: 18, color: context.iconColor),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                onTap: () {
                  if (appStore.isLogging) {
                    LikedContentListScreen().launch(context);
                  } else {
                    SignInScreen(
                      redirectTo: () {
                        LikedContentListScreen().launch(context);
                      },
                    ).launch(context);
                  }
                },
              ),
            if (coreStore.isMembershipEnabled && appStore.isLogging)
              SettingWidget(
                title: "${language.subscriptionHistory}",
                titleTextStyle: primaryTextStyle(),
                leading: CachedImageWidget(url: ic_premium, height: 18, width: 18, color: context.iconColor.withAlpha(128)),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                onTap: () {
                  MyAccountScreen().launch(context);
                },
              ),
            if (appStore.isLogging)
              SettingWidget(
                title: language.manageDevices,
                titleTextStyle: primaryTextStyle(),
                leading: CachedImageWidget(url: ic_devices, height: 20, width: 20, color: context.iconColor.withAlpha(136)),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                onTap: () {
                  if (appStore.isLogging) {
                    ManageDevicesScreen(isFromSettings: true).launch(context);
                  } else {
                    SignInScreen(
                      redirectTo: () {
                        ManageDevicesScreen().launch(context);
                      },
                    ).launch(context);
                  }
                },
              ),
            if (appStore.isLogging)
              SettingWidget(
                title: language.changePassword,
                titleTextStyle: primaryTextStyle(),
                leading: Image.asset(ic_lock, color: iconColor, height: 18),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                onTap: () {
                  ChangePasswordScreen().launch(context);
                },
              ),
            SettingWidget(
              leading: Image.asset(ic_language, color: iconColor, height: 18),
              title: language.language,
              titleTextStyle: primaryTextStyle(),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
              onTap: () {
                LanguageScreen().launch(context);
              },
            ),
            SettingWidget(
              leading: Image.asset(ic_privacy, color: iconColor, height: 18),
              title: language.privacyPolicy,
              titleTextStyle: primaryTextStyle(),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
              onTap: () {
                launchCustomTabURL(url: privacyPolicyURL);
              },
            ),
            SettingWidget(
              leading: Image.asset(ic_document, color: iconColor, height: 18),
              title: language.termsConditions,
              titleTextStyle: primaryTextStyle(),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
              onTap: () {
                launchCustomTabURL(url: termsConditionURL);
              },
            ),
            SnapHelperWidget<PackageInfoData>(
              future: getPackageInfo(),
              onSuccess: (d) => SettingWidget(
                leading: Image.asset(ic_rating, color: iconColor, height: 18),
                title: language.rateUs,
                titleTextStyle: primaryTextStyle(),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                onTap: () {
                  log('$playStoreBaseURL${d.packageName}');
                  if (isAndroid)
                    launchUrl(Uri.parse('$playStoreBaseURL${d.packageName}'), mode: LaunchMode.externalApplication);
                  else if (isIOS) launchUrl(Uri.parse('$IOS_APP_LINK'), mode: LaunchMode.externalApplication);
                },
              ),
            ),
            SettingWidget(
              leading: Image.asset(ic_share, color: iconColor, height: 18),
              title: language.shareApp,
              titleTextStyle: primaryTextStyle(),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
              onTap: () async {
                if (isIOS)
                  SharePlus.instance.share(ShareParams(text: '${language.share} $app_name ${language.app} $IOS_APP_LINK'));
                else
                  SharePlus.instance.share(ShareParams(text: '${language.share} $app_name ${language.app} $playStoreBaseURL${await getPackageName()}'));
              },
            ),
            SnapHelperWidget<PackageInfoData>(
              future: getPackageInfo(),
              onSuccess: (d) => SettingWidget(
                leading: Image.asset(ic_about, color: iconColor, height: 18),
                title: language.aboutUs,
                subTitle: d.versionName.validate(),
                titleTextStyle: primaryTextStyle(),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                onTap: () {
                  launchCustomTabURL(url: aboutUsURL);
                },
              ),
            ),
            /*if (appStore.isLogging)
              SettingWidget(
                leading: Icon(Icons.delete_outline, size: 20, color: Theme.of(context).textTheme.bodySmall?.color),
                title: language.deleteAccount,
                titleTextStyle: primaryTextStyle(),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                onTap: () async {
                  if (appStore.userEmail != DEFAULT_EMAIL) {
                    await showConfirmDialogCustom(
                      context,
                      title: language.areYouSureYou,
                      primaryColor: context.primaryColor,
                      negativeText: language.no,
                      positiveText: language.yes,
                      onAccept: (context) async {
                        await deleteUserAccount().then((value) async {
                          toast(language.accountDeletedSuccessfully);
                          appStore.setLoading(false);
                          await FirebaseMessaging.instance.unsubscribeFromTopic('${appNameTopic}').then((v) {
                            log("${FirebaseMsgConst.topicUnSubscribed}$appNameTopic");
                          });
                          logout(isNewTask: true);
                        });
                      },
                    );
                  } else {
                    toast(language.demoUserCanTPerformThisAction);
                  }
                },
              ),*/
          ],
        ),
      ),
      bottomNavigationBar: TextButton(
        onPressed: () async {
          if (appStore.isLogging) {
            showSignOutBottomSheet(context);
          } else {
            await showModalBottomSheet<void>(
              isScrollControlled: true,
              useSafeArea: true,
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.95,
                  child: SignInScreen(),
                );
              },
            );
          }
        },
        child: Text(
          appStore.isLogging ? "${language.signOut}" : "${language.signIn}",
          style: primaryTextStyle(color: context.primaryColor),
        ),
      ).paddingSymmetric(horizontal: 16, vertical: 20),
    );
  }
}
