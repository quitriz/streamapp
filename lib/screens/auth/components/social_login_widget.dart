import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/auth/login_response.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/home_screen.dart';
import 'package:streamit_flutter/services/social_login_service.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/login_error_handler.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';

class SocialLoginWidget extends StatelessWidget {
  /// Apple login function
  Future<void> appleLogin(BuildContext context) async {
    final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult.first == ConnectivityResult.none) {
      toast(language.yourInterNetNotWorking, print: true);
      return;
    }
    appStore.setLoading(true);
    Map<String, dynamic>? loginRequest;

    try {
      final result = await SocialAuthService().signInWithApple();
      loginRequest = {
        'email': result.userEmail.validate(),
        'first_name': result.firstName.validate(),
        'last_name': result.lastName.validate(),
        'avatar_url': result.profileImage.validate(),
        'login_type': LoginTypeConst.LOGIN_TYPE_APPLE,
      };

      log('Apple Login Request: $loginRequest');
      final loginResponse = await socialLogin(loginRequest);
      log('Apple Login Response: ${loginResponse.toJson()}');

      if (loginResponse.userId != null && loginResponse.userId! > 0) {
        log('User data stored successfully - User ID: ${loginResponse.userId}');

        await _completeSocialLoginFlow(context, loginResponse);
      } else {
        log('Warning: User data incomplete, but proceeding with login');

        await _completeSocialLoginFlow(context, loginResponse);
      }
    } catch (e) {
      appStore.setLoading(false);
      log('Apple Login Error: $e');

      if (e is Map<String, dynamic> &&
          loginRequest != null &&
          ((e.containsKey('error_code') && e['error_code'] == SessionErrorCode.loginLimitExceeded) || (e.containsKey('code') && e['code'] == SessionErrorCode.streamitLoginLimitExceeded))) {
        await LoginErrorHandler.handleLoginLimitExceeded(
          context: context,
          loginCredentials: loginRequest,
          onLoginSuccess: () {
            HomeScreen().launch(context, isNewTask: true);
          },
        );
      } else {
        toast('${language.loginFailed} ${e.toString()}', print: true);
      }
    }
  }

  /// Google login function
  Future<void> googleLogin(BuildContext context) async {
    final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult.first == ConnectivityResult.none) {
      toast(language.yourInterNetNotWorking, print: true);
      return;
    }
    appStore.setLoading(true);
    Map<String, dynamic>? loginRequest;

    try {
      final result = await SocialAuthService().signInWithGoogle();
      loginRequest = {
        'email': result?.userEmail.validate() ?? '',
        'first_name': result?.firstName.validate() ?? '',
        'last_name': result?.lastName.validate() ?? '',
        'avatar_url': result?.profileImage.validate() ?? '',
        'login_type': LoginTypeConst.LOGIN_TYPE_GOOGLE,
      };

      log('Google Login Request: $loginRequest');
      final loginResponse = await socialLogin(loginRequest);
      log('Google Login Response: ${loginResponse.toJson()}');

      if (loginResponse.userId != null && loginResponse.userId! > 0) {
        log('User data stored successfully - User ID: ${loginResponse.userId}');

        await _completeSocialLoginFlow(context, loginResponse);
      } else {
        log('Warning: User data incomplete, but proceeding with login');

        await _completeSocialLoginFlow(context, loginResponse);
      }
    } catch (e) {
      appStore.setLoading(false);
      log('Google Login Error: $e');

      if (e is Map<String, dynamic> &&
          loginRequest != null &&
          ((e.containsKey('error_code') && e['error_code'] == SessionErrorCode.loginLimitExceeded) || (e.containsKey('code') && e['code'] == SessionErrorCode.streamitLoginLimitExceeded))) {
        await LoginErrorHandler.handleLoginLimitExceeded(
          context: context,
          loginCredentials: loginRequest,
          onLoginSuccess: () {
            HomeScreen().launch(context, isNewTask: true);
          },
        );
      } else {
        toast('${language.loginFailed} ${e.toString()}', print: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /// Google Button - Show on all platforms (or hide on iOS if preferred)
        if (!isIOS) ...[
          SocialLoginButtons(icon: ic_google, onTap: () => googleLogin(context)),
          8.width,
        ],

        /// Apple Button - Show only on iOS
        if (isIOS) SocialLoginButtons(icon: ic_apple, onTap: () => appleLogin(context), color: white),
      ],
    );
  }

  Widget SocialLoginButtons({required String icon, required VoidCallback onTap, Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(color: cardColor, shape: BoxShape.circle),
        child: Center(child: Image.asset(icon, width: 20, height: 20, fit: BoxFit.contain, color: color)),
      ),
    );
  }

  Future<void> _completeSocialLoginFlow(BuildContext context, LoginResponse loginResponse) async {
    try {
      if (loginResponse.userEmail?.isNotEmpty == true) {
        userStore.setLoginEmail(loginResponse.userEmail!);
      }

      String username = loginResponse.userEmail.validate();
      if (username.isEmpty) {
        username = loginResponse.username.validate();
      }

      if (username.isNotEmpty) {
        await verifyAndAddDevice(username: username, password: null, isForSocialLogin: true);
      }

      appStore.setLoading(false);
      toast("${language.youAreLoggedInLetsGetStarted}");

      HomeScreen().launch(context, isNewTask: true);
    } catch (e) {
      appStore.setLoading(false);
      log('Error in social login flow: $e');
      toast('${language.loginSuccessful}');
      HomeScreen().launch(context, isNewTask: true);
    }
  }
}
