import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/settings/devices_model.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';

class ManageDevicesScreen extends StatefulWidget {
  final VoidCallback? onDeviceRemoved;
  final bool isFromSettings;

  const ManageDevicesScreen({Key? key, this.onDeviceRemoved, this.isFromSettings = false}) : super(key: key);

  @override
  State<ManageDevicesScreen> createState() => _ManageDevicesScreenState();
}

class _ManageDevicesScreenState extends State<ManageDevicesScreen> {
  @override
  void initState() {
    super.initState();
    fragmentStore.resetDeviceState();
    // Add a small delay to ensure SharedPreferences are ready if credentials were just saved
    Future.delayed(Duration(milliseconds: 100), () {
      getDeviceList();
    });
  }

  Future<void> getDeviceList() async {
    appStore.setLoading(true);
    
    // Read password from SharedPreferences to get the most up-to-date value
    String currentPassword = getStringAsync(SharePreferencesKey.LOGIN_PASSWORD);
    String currentEmail = getStringAsync(SharePreferencesKey.LOGIN_EMAIL);
    
    // If SharedPreferences is empty, try reading from PASSWORD constant (alternative key)
    if (currentPassword.isEmpty) {
      currentPassword = getStringAsync(PASSWORD);
    }
    
    // Fallback to userStore if SharedPreferences doesn't have the value
    String username = currentEmail.isNotEmpty ? currentEmail : userStore.loginEmail;
    String password = currentPassword.isNotEmpty ? currentPassword : userStore.password;
    
    if (username.isEmpty) {
      appStore.setLoading(false);
      fragmentStore.setDeviceError(true);
      toast('Unable to fetch devices: Missing login credentials', print: true);
      return;
    }

    Map request = {"username": username};

    if (password.isNotEmpty) {
      request["password"] = password;
    } else {
      request["is_social_login"] = true;
      String loginToken = getStringAsync(COOKIE_HEADER);
      if (loginToken.isNotEmpty) request["login_token"] = loginToken;
    }

    await getDevices(request: request).then((res) {
      fragmentStore.setDeviceList(res.data);
      fragmentStore.setDeviceStats(res.stats);
      fragmentStore.setDeviceUserLevel(res.userLevel);
      appStore.setLoading(false);
    }).catchError((e) {
      toast(e.toString());
      fragmentStore.setDeviceError(true);
      appStore.setLoading(false);
    });
  }

  Future<void> removeDevice({String? id, bool isRemoveAll = false}) async {
    // Read password from SharedPreferences to get the most up-to-date value
    String currentPassword = getStringAsync(SharePreferencesKey.LOGIN_PASSWORD);
    String currentEmail = getStringAsync(SharePreferencesKey.LOGIN_EMAIL);
    
    // If SharedPreferences is empty, try reading from PASSWORD constant
    if (currentPassword.isEmpty) {
      currentPassword = getStringAsync(PASSWORD);
    }
    
    // Fallback to userStore if SharedPreferences doesn't have the value
    String username = currentEmail.isNotEmpty ? currentEmail : userStore.loginEmail;
    String password = currentPassword.isNotEmpty ? currentPassword : userStore.password;
    
    // Determine if this is a social login (no password available)
    bool isSocialLogin = password.isEmpty;
    
    Map request = {};
    if (isRemoveAll && id == null && appStore.isLogging) {
      request['remove_all'] = "true";
    } else if (id != null && !isRemoveAll && appStore.isLogging) {
      request['username'] = username;
      if (isSocialLogin) {
        request['is_social_login'] = true;
      } else {
        request['password'] = password;
      }
      request['device_id'] = id;
    } else {
      request['username'] = username;
      if (isSocialLogin) {
        request['is_social_login'] = true;
      } else {
        request['password'] = password;
      }
      request['remove_all'] = "true";
    }
    
    await deleteDevice(request).then((value) {
      fragmentStore.removeDeviceFromList(id.validate());
      if (isRemoveAll && widget.isFromSettings) {
        fragmentStore.deviceList.clear();
        logout(isNewTask: true);
      }
      getDeviceList();
      if (widget.onDeviceRemoved != null) {
        widget.onDeviceRemoved!();
      }
    }).catchError(onError);
  }

  @override
  void dispose() {
    super.dispose();
  }

  IconData _getDeviceTypeIcon(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'mobile':
        return Icons.smartphone;
      case 'web':
        return Icons.web;
      default:
        return Icons.smartphone;
    }
  }

  Widget _buildDeviceCard(DeviceData device) {
    final dateString = device.loginTime.validate();
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat("MMM dd, yyyy, h:mm a").format(dateTime);

    return GestureDetector(
      onTap: () {
        if (!device.isCurrentDevice) {
          showConfirmDialogCustom(
            context,
            title: '${language.areYouSureYouWantToLogOutFromThisDevice}',
            primaryColor: colorPrimary,
            negativeText: language.no,
            positiveText: language.yes,
            onAccept: (context) async {
              removeDevice(id: device.deviceId.validate()).then((value) {
                toast(language.youHaveBeenLoggedOutFromThisDevice);
              });
            },
          );
        } else {
          toast(language.thisIsYourCurrentDevice, print: true);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appBackground,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Device type icon
            Icon(
              _getDeviceTypeIcon(device.type.validate()),
              color: context.primaryColor,
              size: 34,
            ),
            12.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          device.deviceName.validate().isNotEmpty ? device.deviceName.validate() : "${language.androidPhoneTablet}",
                          style: boldTextStyle(
                            size: textPrimarySizeGlobal.toInt(),
                            fontFamily: GoogleFonts.roboto().fontFamily,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      !device.isCurrentDevice
                          ? Text(
                              language.signOut.toUpperCase(),
                              style: boldTextStyle(color: context.primaryColor, size: textSecondarySizeGlobal.toInt(), fontFamily: GoogleFonts.roboto().fontFamily),
                            )
                          : Text(
                              language.yourDevice,
                              style: secondaryTextStyle(color: context.primaryColor, size: textSecondarySizeGlobal.toInt(), fontFamily: GoogleFonts.roboto().fontFamily),
                            ),
                    ],
                  ),
                  4.height,
                  Text(
                    '${language.lastUsed} $formattedDate',
                    style: secondaryTextStyle(
                      size: textSecondarySizeGlobal.toInt(),
                      fontFamily: GoogleFonts.roboto().fontFamily,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Scaffold(
        backgroundColor: cardColor,
        appBar: AppBar(
          backgroundColor: appBackground,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: iconColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(widget.onDeviceRemoved != null ? language.removeDeviceToContinue : language.manageDevices, style: boldTextStyle(fontFamily: GoogleFonts.roboto().fontFamily)),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // New header section (matches design in attachment)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: appBackground,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CachedImageWidget(url: ic_devices,height: 28,width: 28,color: colorPrimary),
                          8.width,
                          Text(language.deviceManagement, style: boldTextStyle(color: Colors.white, size: 22, fontFamily: GoogleFonts.roboto().fontFamily)),
                        ],
                      ),
                      12.height,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Show "No Plan" if user_level is empty, otherwise show user_level
                                Text(
                                  fragmentStore.deviceUserLevel.validate().isEmpty ? language.noPlan : fragmentStore.deviceUserLevel.validate(),
                                  style: boldTextStyle(color: Colors.white, size: 18, fontFamily: GoogleFonts.roboto().fontFamily),
                                ),
                                6.height,
                                // Show "No Limit" if type is "no_limit", otherwise show device count text
                                if (fragmentStore.deviceStats?.type == "no_limit")
                                  Text(
                                    language.noLimit,
                                    style: secondaryTextStyle(color: Colors.white70),
                                  )
                                else
                                  Text(
                                    '${fragmentStore.deviceStats?.totalDevices ?? 0} ${language.ofLabel} ${fragmentStore.deviceStats?.totalLimit ?? 0} ${language.devicesUsed}',
                                    style: secondaryTextStyle(color: Colors.white70),
                                  ),
                                // Progress bar - only show if type is not "no_limit"
                                if (fragmentStore.deviceStats?.type != "no_limit") ...[
                                  8.height,
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(language.usage, style: secondaryTextStyle(color: Colors.white70)),
                                              Text(
                                                  '${fragmentStore.deviceStats != null ? ((fragmentStore.deviceStats!.totalDevices / fragmentStore.deviceStats!.totalLimit).clamp(0.0, 1.0) * 100) : 0}%',
                                                  style: secondaryTextStyle(color: Colors.white70)),
                                            ],
                                          ),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: LinearProgressIndicator(
                                              value: fragmentStore.deviceStats != null && fragmentStore.deviceStats!.totalLimit > 0
                                                  ? (fragmentStore.deviceStats!.totalDevices / fragmentStore.deviceStats!.totalLimit).clamp(0.0, 1.0)
                                                  : 0.0,
                                              minHeight: 12,
                                              backgroundColor: Colors.white12,
                                              valueColor: AlwaysStoppedAnimation(context.primaryColor),
                                            ),
                                          ),
                                        ],
                                      ).expand(),
                                      if (fragmentStore.deviceStats?.totalLimit != 0)
                                        Container(
                                          margin: EdgeInsets.only(left: 12),
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(color: context.primaryColor, borderRadius: BorderRadius.circular(6)),
                                          child: Text('${fragmentStore.deviceStats?.totalDevices ?? 0}/${fragmentStore.deviceStats?.totalLimit ?? 0} ${language.devices}',
                                              style: boldTextStyle(color: Colors.white)),
                                        ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Device count badge - show "X/No Limit" when type is "no_limit"
                          if (fragmentStore.deviceStats?.type == "no_limit")
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(color: context.primaryColor, borderRadius: BorderRadius.circular(6)),
                              child: Text(
                                '${fragmentStore.deviceStats?.totalDevices ?? 0}/${language.noLimit}',
                                style: boldTextStyle(color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.onDeviceRemoved != null) ...[
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: context.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: context.primaryColor.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: context.primaryColor),
                                12.width,
                                Expanded(
                                  child: Text(
                                    language.youHaveReachedThe,
                                    style: secondaryTextStyle(
                                      color: context.primaryColor,
                                      fontFamily: GoogleFonts.roboto().fontFamily,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (fragmentStore.deviceList.isNotEmpty) ...[
                          // Current Device Section
                          if (fragmentStore.deviceList.any((device) => device.isCurrentDevice == true)) ...[
                            Text(
                              language.yourDevice,
                              style: boldTextStyle(fontFamily: GoogleFonts.roboto().fontFamily, size: textPrimarySizeGlobal.toInt()),
                            ),
                            8.height,
                            ...fragmentStore.deviceList.where((device) => device.isCurrentDevice == true).map((device) => _buildDeviceCard(device)).toList(),
                          ],
                          if (fragmentStore.deviceList.any((device) => device.isCurrentDevice == false)) ...[
                            Text(
                              language.otherDevice,
                              style: boldTextStyle(fontFamily: GoogleFonts.roboto().fontFamily, size: textPrimarySizeGlobal.toInt()),
                            ),
                            8.height,
                            ...fragmentStore.deviceList.where((device) => device.isCurrentDevice == false).map((device) => _buildDeviceCard(device)).toList(),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
                // Sign Out All Button
                if (fragmentStore.deviceList.any((device) => device.isCurrentDevice == false))
                  TextButton(
                      onPressed: () {
                        showConfirmDialogCustom(
                          context,
                          title: language.areYouSureYouWantToLogOutFromThisDevice,
                          primaryColor: Colors.red,
                          negativeText: language.no,
                          positiveText: language.yes,
                          onAccept: (context) async {
                            // Remove all devices except current device
                            List<DeviceData> devicesToRemove = fragmentStore.deviceList.where((device) => device.isCurrentDevice == false).toList();

                            for (DeviceData device in devicesToRemove) {
                              await removeDevice(id: device.deviceId.validate(), isRemoveAll: true);
                            }
                            fragmentStore.deviceList.clear();
                          },
                        );
                      },
                      child: Text(
                        language.signOutFromAllDevices.toUpperCase(),
                        style: boldTextStyle(color: context.primaryColor, fontFamily: GoogleFonts.roboto().fontFamily),
                      )).paddingSymmetric(horizontal: 16, vertical: 24),
              ],
            ),

            // Empty State
            if (fragmentStore.deviceList.isEmpty && !appStore.isLoading)
              NoDataWidget(
                imageWidget: noDataImage(),
                title: language.noData,
              ).center(),

            // Error State
            if (fragmentStore.deviceHasError && !appStore.isLoading)
              NoDataWidget(
                imageWidget: noDataImage(),
                title: language.somethingWentWrong,
              ).center(),

            // Loading State
            Observer(
              builder: (_) {
                return LoaderWidget().center().visible(appStore.isLoading);
              },
            ),
          ],
        ),
      );
    });
  }
}
