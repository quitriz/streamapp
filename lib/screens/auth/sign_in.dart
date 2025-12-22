import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/auth/components/social_login_widget.dart';
import 'package:streamit_flutter/screens/auth/forgot_password_screen.dart';
import 'package:streamit_flutter/screens/auth/sign_up.dart';
import 'package:streamit_flutter/screens/home_screen.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/login_error_handler.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';

class SignInScreen extends StatefulWidget {
  static String tag = '/SignInScreen';
  final VoidCallback? redirectTo;

  SignInScreen({this.redirectTo});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FocusNode passwordFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Pause dashboard video when navigating to sign in
    appStore.setDashboardShowVideo(false);
    appStore.resetDashboardVideoState();
    // Pause any playing video content (movie detail, tv show detail, etc.)
    appStore.setTrailerVideoPlayer(false);
    setStatusBarColor(Colors.transparent, delayInMilliSeconds: 300);
    init();
  }

  @override
  void dispose() {
    setStatusBarColor(appBackground);
    emailController.dispose();
    passwordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  Future<void> init() async {
    if (authStore.doRemember) {
      final email = getStringAsync(SharePreferencesKey.LOGIN_EMAIL);
      final password = getStringAsync(SharePreferencesKey.LOGIN_PASSWORD);
      emailController.text = email;
      passwordController.text = password;
      authStore.setSignInEmail(email);
      authStore.setSignInPassword(password);
    } else if (await isIqonicProduct) {
      emailController.text = DEFAULT_EMAIL;
      passwordController.text = DEFAULT_PASS;
      authStore.setSignInEmail(DEFAULT_EMAIL);
      authStore.setSignInPassword(DEFAULT_PASS);
    }
  }

  Future<void> doSignIn(BuildContext context) async {
    hideKeyboard(context);

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      // Store credentials in local variables to ensure they don't change
      final String loginUsername = emailController.text.trim();
      final String loginPassword = passwordController.text;

      Map req = {
        "username": loginUsername,
        "password": loginPassword,
      };

      hideKeyboard(context);
      appStore.setLoading(true);

      await token(req).then((res) async {
        toast("${language.youReLoggedInLetS}");
        appStore.setLoading(false);
        
        // Save credentials to store and preferences
        await setValue(SharePreferencesKey.LOGIN_EMAIL, loginUsername);
        await setValue(SharePreferencesKey.LOGIN_PASSWORD, loginPassword);
        await setValue(PASSWORD, loginPassword);
        await setValue(USER_EMAIL, loginUsername);
        
        // Update the MobX store
        userStore.loginEmail = loginUsername;
        userStore.password = loginPassword;
        await userStore.setLoginEmail(loginUsername, isInitializing: false);
        await userStore.setPassword(loginPassword, isInitializing: false);
        
        // Verify devices first before proceeding
        bool shouldNavigate = await verifyAndAddDevice(
          username: loginUsername,
          password: loginPassword,
          isForSocialLogin: false,
        );
        
        // Only navigate if device verification didn't redirect to ManageDevicesScreen
        if (shouldNavigate) {
          if (widget.redirectTo != null) {
            widget.redirectTo?.call();
            finish(context);
          } else {
            HomeScreen().launch(context, isNewTask: true);
          }
        }
      }).catchError((e) async {
        appStore.setLoading(false);

        // Strictly detect explicit device limit errors from API response
        bool isDeviceLimitError = false;
        if (e is Map<String, dynamic>) {
          if ((e.containsKey('error_code') && e['error_code'] == SessionErrorCode.loginLimitExceeded) || (e.containsKey('code') && e['code'] == 'streamit_login_limit_exceeded')) {
            isDeviceLimitError = true;
          }
        }

        if (isDeviceLimitError) {
          // Only navigate to ManageDevicesScreen for device limit errors
          await LoginErrorHandler.handleLoginLimitExceeded(
            context: context,
            loginCredentials: Map<String, dynamic>.from(req),
            onLoginSuccess: () {
              // Use navigatorKey to ensure navigation works after managing devices
              final navContext = navigatorKey.currentContext;
              if (navContext != null) {
                if (widget.redirectTo != null) {
                  widget.redirectTo?.call();
                  finish(navContext);
                } else {
                  HomeScreen().launch(navContext, isNewTask: true);
                }
              } else {
                // Fallback to original context
                if (widget.redirectTo != null) {
                  widget.redirectTo?.call();
                  finish(context);
                } else {
                  HomeScreen().launch(context, isNewTask: true);
                }
              }
            },
          );
        } else {
          // For invalid password or other errors, stay on sign in screen
          toast(e.toString());
          await Future.delayed(Duration(seconds: 1));
          FocusScope.of(context).requestFocus(passwordFocus);
        }
      });
    } else {
      authStore.setIsFirstTime(false);
    }
  }


  void onForgotPasswordClicked(BuildContext context) {
    ForgotPasswordScreen().launch(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                30.height,

                ///App Logo
                CachedImageWidget(url: ic_logo, height: 46, width: 184),
                30.height,

                /// Welcome Title
                Text("${language.youReBack}", style: boldTextStyle(size: 22)),

                8.height,

                /// Welcome Subtitle
                Text("${language.itSGreatToSee}", style: secondaryTextStyle(size: textSecondarySizeGlobal.toInt()), textAlign: TextAlign.center),

                30.height,

                /// Form
                Observer(
                  builder: (_) => Form(
                      key: formKey,
                      autovalidateMode: authStore.isFirstTime ? AutovalidateMode.disabled : AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ///Email Field
                          AppTextField(
                            controller: emailController,
                            textFieldType: TextFieldType.EMAIL,
                            focus: emailFocus,
                            nextFocus: passwordFocus,
                            title: language.email,
                            titleTextStyle: primaryTextStyle(
                              size: textSecondarySizeGlobal.toInt(),
                            ),
                            textStyle: primaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                            onChanged: (value) => authStore.setSignInEmail(value),
                            decoration: InputDecoration(
                              hintText: '${language.egHintEmail}',
                              hintStyle: secondaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                              prefixIcon: Icon(Icons.email_outlined, color: context.primaryColor),
                              filled: true,
                              fillColor: cardColor,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                          ),
                          16.height,

                          ///Password Field
                          AppTextField(
                            controller: passwordController,
                            textFieldType: TextFieldType.PASSWORD,
                            isPassword: true,
                            errorMinimumPasswordLength: '${language.minimumPasswordLengthShould}',
                            suffixIconColor: Color(0XFF999797),
                            obscureText: true,
                            title: language.password,
                            titleTextStyle: primaryTextStyle(
                              size: textSecondarySizeGlobal.toInt(),
                            ),
                            textStyle: primaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                            onChanged: (value) => authStore.setSignInPassword(value),
                            decoration: InputDecoration(
                              hintText: '••••••••••',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              prefixIcon: Icon(Icons.lock_outlined, color: context.primaryColor),
                              filled: true,
                              fillColor: cardColor,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                          ),
                          8.height,

                          /// Remember Me and Forgot Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Observer(
                                builder: (_) => Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        authStore.setRemember(!authStore.doRemember);
                                      },
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: authStore.doRemember ? colorPrimary : Colors.transparent,
                                          border: Border.all(color: authStore.doRemember ? colorPrimary : Colors.grey[400]!, width: 2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: authStore.doRemember ? Icon(Icons.check, size: textSecondarySizeGlobal.toInt().toDouble(), color: Colors.white) : null,
                                      ),
                                    ),
                                    8.width,
                                    Text(language.rememberMe, style: primaryTextStyle(size: textSecondarySizeGlobal.toInt(), color: rememberMeColor)),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => onForgotPasswordClicked(context),
                                child: Text(language.forgotPasswordData, style: primaryTextStyle(color: context.primaryColor, fontStyle: FontStyle.italic, size: textSecondarySizeGlobal.toInt())),
                              ),
                            ],
                          ),
                          30.height,

                          /// Sign In Button
                          AppButton(
                            text: language.signIn,
                            textStyle: boldTextStyle(size: textSecondarySizeGlobal.toInt()),
                            onTap: () => doSignIn(context),
                            height: 48,
                            width: context.width(),
                            elevation: 0,
                            color: context.primaryColor,
                            splashColor: context.primaryColor.withValues(alpha: 0.2),
                          ),

                          16.height,

                          Offstage(offstage: !coreStore.isSocialLoginEnabled, child: Text('${language.orContinueWith}', style: secondaryTextStyle(size: textSecondarySizeGlobal.toInt())).center()),
                          16.height,
                          Offstage(offstage: !coreStore.isSocialLoginEnabled, child: SocialLoginWidget()),
                          24.height,

                          /// Sign Up Button
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                SignUpScreen().launch(context);
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: '${language.dontHaveAnAccount}  ',
                                  style: secondaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                                  children: [
                                    TextSpan(
                                      text: language.signUp,
                                      style: boldTextStyle(color: context.primaryColor, size: textSecondarySizeGlobal.toInt(), decoration: TextDecoration.underline),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          30.height,
                        ],
                      )),
                ),
              ],
            ),
          ),

          /// Loading Indicator
          Observer(
            builder: (_) => appStore.isLoading
                ? Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Center(child: LoaderWidget()),
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
