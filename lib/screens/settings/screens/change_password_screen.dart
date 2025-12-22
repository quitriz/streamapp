import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  static String tag = '/ChangePasswordScreen';

  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController oldPassCont = TextEditingController();
  TextEditingController newPassCont = TextEditingController();
  TextEditingController confNewPassCont = TextEditingController();

  FocusNode oldPassFocus = FocusNode();
  FocusNode newPassFocus = FocusNode();
  FocusNode confPassFocus = FocusNode();

  String? oldPassError;
  String? newPassError;
  String? confPassError;

  @override
  void initState() {
    super.initState();
    authStore.resetChangePasswordForm();
    oldPassCont.addListener(() {
      authStore.setOldPassword(oldPassCont.text);
      if (oldPassFocus.hasFocus) {
        setState(() {
          oldPassError = _validateOldPassword(oldPassCont.text);
        });
      }
    });

    newPassCont.addListener(() {
      authStore.setNewPassword(newPassCont.text);
      if (newPassFocus.hasFocus) {
        setState(() {
          newPassError = _validateNewPassword(newPassCont.text);
        });
      }
      // Also update confirm password error if it's focused, since it depends on new password
      if (confPassFocus.hasFocus) {
        setState(() {
          confPassError = _validateConfirmPassword(confNewPassCont.text);
        });
      }
    });

    confNewPassCont.addListener(() {
      authStore.setConfirmPassword(confNewPassCont.text);
      if (confPassFocus.hasFocus) {
        setState(() {
          confPassError = _validateConfirmPassword(confNewPassCont.text);
        });
      }
    });

    // Add focus listeners to validate on focus and clear errors on unfocus
    oldPassFocus.addListener(() {
      if (oldPassFocus.hasFocus) {
        setState(() {
          oldPassError = _validateOldPassword(oldPassCont.text);
          newPassError = null;
          confPassError = null;
        });
      }
    });

    newPassFocus.addListener(() {
      if (newPassFocus.hasFocus) {
        setState(() {
          newPassError = _validateNewPassword(newPassCont.text);
          oldPassError = null;
          confPassError = null;
        });
      }
    });

    confPassFocus.addListener(() {
      if (confPassFocus.hasFocus) {
        setState(() {
          confPassError = _validateConfirmPassword(confNewPassCont.text);
          oldPassError = null;
          newPassError = null;
        });
      }
    });
  }

  String? _validateOldPassword(String? value) {
    if (value == null || value.isEmpty) return language.pleaseEnterPassword;
    if (value.length < passwordLength) return language.passwordLengthShouldBeMoreThan6;
    
    // Get stored password from userStore or SharedPreferences
    String storedPassword = userStore.password;
    if (storedPassword.isEmpty) {
      // Fallback to SharedPreferences if userStore doesn't have it
      storedPassword = getStringAsync(SharePreferencesKey.LOGIN_PASSWORD);
      if (storedPassword.isEmpty) {
        storedPassword = getStringAsync(PASSWORD);
      }
    }
    
    // Validate that the entered old password matches the stored password
    if (storedPassword.isNotEmpty && value != storedPassword) {
      return 'Incorrect old password';
    }
    
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) return language.pleaseEnterNewPassword;
    if (value.length < passwordLength) return language.passwordLengthShouldBeMoreThan6;
    if (value == authStore.oldPassword) return language.cannotUseOldPassword;
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return language.pleaseEnterConfirmPassword;
    if (value.length < passwordLength) return language.passwordLengthShouldBeMoreThan6;
    if (value.trim() != authStore.newPassword.trim()) return language.bothPasswordShouldBeMatched;
    return null;
  }

  @override
  void dispose() {
    oldPassCont.dispose();
    newPassCont.dispose();
    confNewPassCont.dispose();
    oldPassFocus.dispose();
    newPassFocus.dispose();
    confPassFocus.dispose();
    super.dispose();
  }

  submit() async {
    hideKeyboard(context);

    // Validate all fields on submission
    setState(() {
      oldPassError = _validateOldPassword(oldPassCont.text);
      newPassError = _validateNewPassword(newPassCont.text);
      confPassError = _validateConfirmPassword(confNewPassCont.text);
    });

    if (formKey.currentState!.validate() && authStore.canSubmitChangePassword) {
      Map req = {'old_password': authStore.oldPassword, 'new_password': authStore.newPassword};

      authStore.setChangePasswordLoading(true);

      await changePassword(req).then((value) {
        authStore.setChangePasswordLoading(false);
        toast(value.message.validate());
        authStore.resetChangePasswordForm();
        finish(context);
      }).catchError((e) {
        authStore.setChangePasswordLoading(false);
        toast(e.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardColor,
      appBar: AppBar(
        backgroundColor: appBackground,
        surfaceTintColor: appBackground,
        title: Text(language.changePassword, style: boldTextStyle()),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    24.height,
                    Form(
                      key: formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Current Password Field
                          AppTextField(
                            controller: oldPassCont,
                            textFieldType: TextFieldType.PASSWORD,
                            isPassword: true,
                            focus: oldPassFocus,
                            nextFocus: newPassFocus,
                            obscureText: true,
                            suffixIconColor: iconColor,
                            title: language.oldPassword,
                            titleTextStyle: primaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                            textStyle: primaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                            decoration: InputDecoration(
                              hintText: language.egPassword,
                              hintStyle: secondaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                              prefixIcon: Icon(Icons.lock_outlined, color: context.primaryColor),
                              filled: true,
                              fillColor: appBackground,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              errorText: oldPassError,
                              errorMaxLines: 2,
                            ),
                            validator: (value) {
                              return _validateOldPassword(value);
                            },
                          ),
                          16.height,

                          /// New Password Field
                          AppTextField(
                            controller: newPassCont,
                            textFieldType: TextFieldType.PASSWORD,
                            isPassword: true,
                            focus: newPassFocus,
                            nextFocus: confPassFocus,
                            obscureText: true,
                            suffixIconColor: iconColor,
                            title: language.newPassword,
                            titleTextStyle: primaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                            textStyle: primaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                            decoration: InputDecoration(
                              hintText: language.egPassword,
                              hintStyle: secondaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                              prefixIcon: Icon(Icons.lock_outlined, color: context.primaryColor),
                              filled: true,
                              fillColor: appBackground,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              errorText: newPassError,
                              errorMaxLines: 2,
                            ),
                            validator: (value) {
                              return _validateNewPassword(value);
                            },
                          ),
                          16.height,

                          /// Confirm Password Field
                          AppTextField(
                            controller: confNewPassCont,
                            textFieldType: TextFieldType.PASSWORD,
                            isPassword: true,
                            focus: confPassFocus,
                            obscureText: true,
                            suffixIconColor: iconColor,
                            title: language.confirmPassword,
                            titleTextStyle: primaryTextStyle(
                              size: textSecondarySizeGlobal.toInt(),
                            ),
                            textStyle: primaryTextStyle(
                              size: textSecondarySizeGlobal.toInt(),
                            ),
                            decoration: InputDecoration(
                              hintText: language.egPassword,
                              hintStyle: secondaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                              prefixIcon: Icon(Icons.lock_outlined, color: context.primaryColor),
                              filled: true,
                              fillColor: appBackground,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              errorText: confPassError,
                              errorMaxLines: 2,
                            ),
                            validator: (value) {
                              return _validateConfirmPassword(value);
                            },
                            onFieldSubmitted: (s) {
                              submit();
                            },
                          ),
                          30.height,
                        ],
                      ),
                    ),
                  ],
                ),
              ).expand(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Observer(
                  builder: (context) {
                    return AppButton(
                      text: language.submit,
                      textStyle: boldTextStyle(size: textSecondarySizeGlobal.toInt()),
                      onTap: authStore.canSubmitChangePassword ? () => submit() : (){},
                      height: 48,
                      width: context.width(),
                      elevation: 0,
                      color: authStore.canSubmitChangePassword ? context.primaryColor : context.primaryColor.withValues(alpha: 0.5),
                      splashColor: context.primaryColor.withValues(alpha: 0.2),
                    );
                  },
                ),
              ),
            ],
          ),

          /// Loading Indicator
          Observer(
            builder: (_) => authStore.isChangePasswordLoading
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
