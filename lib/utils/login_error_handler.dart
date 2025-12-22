import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/home_screen.dart';
import 'package:streamit_flutter/screens/settings/screens/manage_devices_screen.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';

class LoginErrorHandler {
  /// Handle login limit exceeded error by navigating to manage devices screen
  static Future<void> handleLoginLimitExceeded({
    required BuildContext context,
    required Map<String, dynamic> loginCredentials,
    VoidCallback? onLoginSuccess,
  }) async {
    final String username = ((loginCredentials['username'] ?? loginCredentials['email']) as String?).validate();
    final String password = (loginCredentials['password'] as String?).validate();

    if (!loginCredentials.containsKey('username') && username.isNotEmpty) {
      loginCredentials['username'] = username;
    }
    if (!loginCredentials.containsKey('password') && password.isNotEmpty) {
      loginCredentials['password'] = password;
    }

    if (username.isNotEmpty) {
      await setValue(SharePreferencesKey.LOGIN_EMAIL, username);
      await userStore.setLoginEmail(username);
      userStore.loginEmail = username;
    }

    if (password.isNotEmpty) {
      await setValue(SharePreferencesKey.LOGIN_PASSWORD, password);
      await setValue(PASSWORD, password);
      await userStore.setPassword(password);
      userStore.password = password;
    }

    // Call getDevices API to fetch device list before opening the screen
    fragmentStore.resetDeviceState();

    // Show manage devices screen with login retry callback
    await ManageDevicesScreen(
      onDeviceRemoved: () async {
        await _retryLogin(
          context: context,
          loginCredentials: loginCredentials,
          onLoginSuccess: onLoginSuccess,
        );
      },
    ).launch(context);
  }

  /// Retry login after device removal
  static Future<void> _retryLogin({
    required BuildContext context,
    required Map<String, dynamic> loginCredentials,
    VoidCallback? onLoginSuccess,
  }) async {
    try {
      appStore.setLoading(true);

      // Determine if it's regular login or social login based on credentials
      if (loginCredentials.containsKey('username') && loginCredentials.containsKey('password')) {
        // Regular login
        await token(loginCredentials).then((res) async {
          toast("You're logged in. Let's get started!");
          appStore.setLoading(false);
          userStore.setLoginEmail(loginCredentials['username']);
          userStore.setPassword(loginCredentials['password']);

          await setValue(PASSWORD, loginCredentials['password']);
          await setValue(SharePreferencesKey.LOGIN_PASSWORD, loginCredentials['password']);

          // Update userStore with correct credentials
          userStore.loginEmail = loginCredentials['username'];
          userStore.password = loginCredentials['password'];
          await userStore.setLoginEmail(loginCredentials['username']);
          await userStore.setPassword(loginCredentials['password']);

          // Verify and add device using common function
          await verifyAndAddDevice(
            username: loginCredentials['username'] as String,
            password: loginCredentials['password'] as String,
            isForSocialLogin: false,
          );

          // Use navigatorKey to get current context for navigation
          // This ensures navigation works even if the original context is invalid
          final navContext = navigatorKey.currentContext;
          if (navContext != null) {
            if (onLoginSuccess != null) {
              onLoginSuccess();
            } else {
              HomeScreen().launch(navContext, isNewTask: true);
            }
          } else {
            // Fallback to original context
            if (onLoginSuccess != null) {
              onLoginSuccess();
            } else {
              HomeScreen().launch(context, isNewTask: true);
            }
          }
        }).catchError((e) async {
          appStore.setLoading(false);
          if (e is Map<String, dynamic> && e['status_code'] == 401) {
            // Still limit exceeded, show manage devices screen again
            await handleLoginLimitExceeded(
              context: context,
              loginCredentials: loginCredentials,
              onLoginSuccess: onLoginSuccess,
            );
          } else {
            toast(e.toString());
            log(e.toString());
          }
        });
      } else {
        // Social login
        await socialLogin(loginCredentials).then((res) async {
          toast("Login successful");
          appStore.setLoading(false);

          // Extract username/email for device registration
          String username = ((loginCredentials['email'] ?? loginCredentials['username']) as String?).validate();
          if (username.isNotEmpty) {
            // Verify and add device using common function
            await verifyAndAddDevice(username: username, password: null, isForSocialLogin: true);
          }

          // Use navigatorKey to get current context for navigation
          // This ensures navigation works even if the original context is invalid
          final navContext = navigatorKey.currentContext;
          if (navContext != null) {
            if (onLoginSuccess != null) {
              onLoginSuccess();
            } else {
              HomeScreen().launch(navContext, isNewTask: true);
            }
          } else {
            // Fallback to original context
            if (onLoginSuccess != null) {
              onLoginSuccess();
            } else {
              HomeScreen().launch(context, isNewTask: true);
            }
          }
        }).catchError((e) async {
          appStore.setLoading(false);
          if (e is Map<String, dynamic> && e['status_code'] == 401) {
            // Still limit exceeded, show manage devices screen again
            await handleLoginLimitExceeded(
              context: context,
              loginCredentials: loginCredentials,
              onLoginSuccess: onLoginSuccess,
            );
          } else {
            toast('Login failed: ${e.toString()}');
            log('Social login retry error: $e');
          }
        });
      }
    } catch (e) {
      appStore.setLoading(false);
      toast('Login failed: ${e.toString()}');
      log('Login retry error: $e');
    }
  }
}
