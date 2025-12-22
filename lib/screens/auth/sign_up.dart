import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/config.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/auth/login_response.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/home_screen.dart';
import 'package:streamit_flutter/screens/pmp/screens/my_account_screen.dart';
import 'package:streamit_flutter/services/in_app_purchase_service.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/push_notification_service.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';

class SignUpScreen extends StatefulWidget {
  static String tag = '/SignUpScreen';
  final VoidCallback? redirectTo;

  SignUpScreen({this.redirectTo});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final FocusNode firstNameFocus = FocusNode();
  final FocusNode lastNameFocus = FocusNode();
  final FocusNode userNameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    setStatusBarColor(Colors.transparent, delayInMilliSeconds: 300);
  }

  @override
  void dispose() {
    setStatusBarColor(appBackground);
    firstNameController.dispose();
    lastNameController.dispose();
    userNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    firstNameFocus.dispose();
    lastNameFocus.dispose();
    userNameFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> doSignUp(BuildContext context) async {
    hideKeyboard(context);

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      Map req = {
        "first_name": firstNameController.text,
        "last_name": lastNameController.text,
        "user_email": emailController.text,
        "user_login": userNameController.text,
        "user_pass": passwordController.text,
      };

      appStore.setLoading(true);

      await register(req).then((value) async {
        toast("Account created successfully! Welcome!");

        // Process registration response to create LoginResponse (similar to socialLogin)
        Map<String, dynamic> responseData;
        if (value is Map<String, dynamic>) {
          responseData = (value['data'] ?? value['user'] ?? value) as Map<String, dynamic>;
          if (value['user_id'] != null) {
            responseData['user_id'] = value['user_id'];
          }
        } else {
          responseData = {'data': value};
        }

        // Create LoginResponse from registration data
        final loginResponse = LoginResponse.fromJson(responseData);

        // Fill in missing data from form inputs
        loginResponse.userEmail ??= emailController.text;
        loginResponse.firstName ??= firstNameController.text;
        loginResponse.lastName ??= lastNameController.text;
        loginResponse.username ??= userNameController.text;
        loginResponse.loginType ??= 'registration';

        // Initialize user session (same steps as token() function)
        PushNotificationService().registerFCMAndTopics();
        await clearGuestDownloads();
        await setUserData(logRes: loginResponse);
        await setValue(isLoggedIn, true);
        mIsLoggedIn = true;
        await manageFirebaseToken();
        PushNotificationService().registerFCMAndTopics();
        if (coreStore.isInAppPurchaseEnabled) await InAppPurchaseService.init();

        // Save credentials to store and preferences
        await setValue(SharePreferencesKey.LOGIN_EMAIL, emailController.text);
        await setValue(SharePreferencesKey.LOGIN_PASSWORD, passwordController.text);
        await setValue(PASSWORD, passwordController.text);
        await setValue(USER_EMAIL, emailController.text);

        // Update the MobX store
        userStore.loginEmail = emailController.text;
        userStore.password = passwordController.text;
        await userStore.setLoginEmail(emailController.text, isInitializing: false);
        await userStore.setPassword(passwordController.text, isInitializing: false);

        if (widget.redirectTo != null) {
          widget.redirectTo?.call();
          finish(context);
        } else if (coreStore.isMembershipEnabled) {
          MyAccountScreen(fromRegistration: true).launch(context, isNewTask: true);
        } else {
          HomeScreen().launch(context, isNewTask: true);
        }

        appStore.setLoading(false);
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });
    } else {
      authStore.setIsFirstTime(false);
    }
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

                /// App Logo
                CachedImageWidget(url: ic_logo, height: 46, width: 184),
                30.height,

                /// Welcome Title
                Text("${language.welcomeTo} ${app_name.capitalizeFirstLetter()}", style: boldTextStyle(size: 22)),

                8.height,

                /// Welcome Subtitle
                Text("${language.createYourAccountAnd} ${app_name.capitalizeFirstLetter()}", style: secondaryTextStyle(size: textSecondarySizeGlobal.toInt()), textAlign: TextAlign.center),

                30.height,

                /// Form
                Observer(
                  builder: (_) => Form(
                    key: formKey,
                    autovalidateMode: authStore.isFirstTime ? AutovalidateMode.disabled : AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// First Name Field
                        AppTextField(
                          controller: firstNameController,
                          textFieldType: TextFieldType.NAME,
                          focus: firstNameFocus,
                          nextFocus: lastNameFocus,
                          title: "${language.firstName}",
                          titleTextStyle: primaryTextStyle(
                            size: textSecondarySizeGlobal.toInt(),
                          ),
                          textStyle: primaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                          decoration: InputDecoration(
                            hintText: '${language.firstName}',
                            hintStyle: secondaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                            prefixIcon: Icon(Icons.person_outline, color: context.primaryColor),
                            filled: true,
                            fillColor: cardColor,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          validator: (value) {
                            return value!.isEmpty ? "${language.thisFieldIsRequired}" : null;
                          },
                        ),
                        16.height,

                        /// Last Name Field
                        AppTextField(
                          controller: lastNameController,
                          textFieldType: TextFieldType.NAME,
                          focus: lastNameFocus,
                          nextFocus: userNameFocus,
                          title: "${language.lastName}",
                          titleTextStyle: primaryTextStyle(
                            size: textSecondarySizeGlobal.toInt(),
                          ),
                          textStyle: primaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                          decoration: InputDecoration(
                            hintText: '${language.lastName}',
                            hintStyle: secondaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                            prefixIcon: Icon(Icons.person_outline, color: context.primaryColor),
                            filled: true,
                            fillColor: cardColor,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          validator: (value) {
                            return value!.isEmpty ? "${language.thisFieldIsRequired}" : null;
                          },
                        ),
                        16.height,

                        /// User Name Field
                        AppTextField(
                          controller: userNameController,
                          textFieldType: TextFieldType.USERNAME,
                          focus: userNameFocus,
                          nextFocus: emailFocus,
                          title: "${language.username}",
                          titleTextStyle: primaryTextStyle(
                            size: textSecondarySizeGlobal.toInt(),
                          ),
                          textStyle: primaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                          decoration: InputDecoration(
                            hintText: '${language.username}',
                            hintStyle: secondaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                            prefixIcon: Icon(Icons.person_outline, color: context.primaryColor),
                            filled: true,
                            fillColor: cardColor,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          validator: (value) {
                            return value!.isEmpty ? "${language.thisFieldIsRequired}" : null;
                          },
                        ),
                        16.height,

                        /// Email Field
                        AppTextField(
                          controller: emailController,
                          textFieldType: TextFieldType.EMAIL,
                          focus: emailFocus,
                          nextFocus: passwordFocus,
                          title: "${language.email}",
                          titleTextStyle: primaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                          textStyle: primaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                          decoration: InputDecoration(
                            hintText: language.egHintEmail,
                            hintStyle: secondaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                            prefixIcon: Icon(Icons.email_outlined, color: context.primaryColor),
                            filled: true,
                            fillColor: cardColor,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "${language.pleaseEnterYourEmail}";
                            } else if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                              return "${language.pleaseEnterAValid}";
                            }
                            return null;
                          },
                        ),
                        16.height,

                        /// Password Field
                        AppTextField(
                          controller: passwordController,
                          textFieldType: TextFieldType.PASSWORD,
                          isPassword: true,
                          focus: passwordFocus,
                          nextFocus: confirmPasswordFocus,
                          obscureText: true,
                          suffixIconColor: Color(0XFF999797),
                          title: "${language.password}",
                          titleTextStyle: primaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                          textStyle: primaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                          decoration: InputDecoration(
                            hintText: '${language.egPassword}',
                            hintStyle: secondaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                            prefixIcon: Icon(Icons.lock_outlined, color: context.primaryColor),
                            filled: true,
                            fillColor: cardColor,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "${language.thisFieldIsRequired}";
                            }
                            if (value.length < 8) {
                              return '${language.minimumPasswordLengthShould}';
                            }
                            return null;
                          },
                        ),
                        16.height,

                        /// Confirm Password Field
                        AppTextField(
                          controller: confirmPasswordController,
                          textFieldType: TextFieldType.PASSWORD,
                          isPassword: true,
                          focus: confirmPasswordFocus,
                          obscureText: true,
                          title: "${language.confirmPassword}",
                          titleTextStyle: primaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                          textStyle: primaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                          suffixIconColor: iconColor,
                          decoration: InputDecoration(
                            hintText: '${language.egPassword}',
                            hintStyle: secondaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                            prefixIcon: Icon(Icons.lock_outlined, color: context.primaryColor),
                            filled: true,
                            fillColor: cardColor,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) return "${language.thisFieldIsRequired}";
                            return passwordController.text == value ? null : "${language.passwordsDoNotMatch}";
                          },
                        ),
                        30.height,

                        /// Sign Up Button
                        AppButton(
                          text: language.signUp,
                          textStyle: boldTextStyle(size: textSecondarySizeGlobal.toInt()),
                          onTap: () => doSignUp(context),
                          height: 48,
                          width: context.width(),
                          elevation: 0,
                          color: context.primaryColor,
                          splashColor: context.primaryColor.withValues(alpha: 0.2),
                        ),

                        60.height,

                        /// Sign In Button
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              finish(context);
                            },
                            child: RichText(
                              text: TextSpan(
                                text: '${language.alreadyHaveAnAccount}  ',
                                style: secondaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                                children: [
                                  TextSpan(text: '${language.signIn}', style: boldTextStyle(color: context.primaryColor, size: textSecondarySizeGlobal.toInt(), decoration: TextDecoration.underline)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        30.height,
                      ],
                    ),
                  ),
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
