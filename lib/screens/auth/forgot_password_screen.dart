import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static String tag = '/ForgotPasswordScreen';

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final FocusNode emailFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    setStatusBarColor(Colors.transparent, delayInMilliSeconds: 300);
  }

  @override
  void dispose() {
    setStatusBarColor(appBackground);
    emailController.dispose();
    emailFocus.dispose();
    super.dispose();
  }

  Future<void> sendResetLink() async {
    hideKeyboard(context);

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      if (emailController.text.trim().isEmpty) {
        toast(language.thisFieldIsRequired);
        return;
      }
      if (!emailController.text.trim().validateEmail()) {
        toast(language.enterValidEmail);
        return;
      }

      appStore.setLoading(true);

      await forgotPassword({'email': emailController.text.trim()}).then((value) {
        toast(value.message.validate());
        appStore.setLoading(false);
        finish(context);
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });
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
                60.height,

                /// Title
                Text(language.forgotPasswordData, style: boldTextStyle(size: 22)),

                16.height,

                /// Subtitle
                Text(language.enterYourRegisteredEmail,
                    style: secondaryTextStyle(size: textSecondarySizeGlobal.toInt()), textAlign: TextAlign.center),

                40.height,

                /// Form
                Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Email Label
                      Text(language.email, style: primaryTextStyle(size: textSecondarySizeGlobal.toInt())),
                      8.height,

                      /// Email Field
                      AppTextField(
                        controller: emailController,
                        textFieldType: TextFieldType.EMAIL,
                        focus: emailFocus,
                        textStyle: primaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                        decoration: InputDecoration(
                          hintText: '${language.egHintEmail}',
                          hintStyle: secondaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                          prefixIcon: Icon(Icons.email_outlined, color: context.primaryColor),
                          filled: true,
                          fillColor: cardColor,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return language.thisFieldIsRequired;
                          }
                          if (!value.validateEmail()) {
                            return language.enterValidEmail;
                          }
                          return null;
                        },
                      ),

                      40.height,

                      /// Continue Button
                      AppButton(
                        text: '${language.continueLabel}',
                        textStyle: boldTextStyle(size: textSecondarySizeGlobal.toInt()),
                        onTap: () => sendResetLink(),
                        height: 48,
                        width: context.width(),
                        elevation: 0,
                        color: context.primaryColor,
                        splashColor: context.primaryColor.withValues(alpha: 0.2),
                      ),

                      24.height,

                      /// Back to Login
                      Center(
                        child: GestureDetector(
                          onTap: () => finish(context),
                          child: Text(
                            '${language.backToLogin}',
                            style: secondaryTextStyle(size: textSecondarySizeGlobal.toInt(), decoration: TextDecoration.underline),
                          ),
                        ),
                      ),
                      60.height,
                    ],
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
