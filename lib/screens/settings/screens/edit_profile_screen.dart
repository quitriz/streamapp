import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';
import 'package:streamit_flutter/utils/resources/size.dart';

class EditProfileScreen extends StatefulWidget {
  static String tag = '/ProfileScreen';

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  FocusNode lastNameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();

  XFile? image;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    firstNameController.text = getStringAsync(NAME);
    lastNameController.text = getStringAsync(LAST_NAME);
    emailController.text = getStringAsync(USER_EMAIL);
  }

  Future<void> getImage() async {
    await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100).then((value) {
      image = value;
    }).catchError((error) {
      toast(errorSomethingWentWrong);
      log(error);
    });
  }

  Future<void> save(BuildContext context) async {
    hideKeyboard(context);
    updateProfile(firstName: firstNameController.text.trim(), lastName: lastNameController.text.trim(), email: emailController.text.trim(), image: image).then((value) {
      finish(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardColor,
      appBar: AppBar(
        backgroundColor: appBackground,
        surfaceTintColor: appBackground,
        title: Text(language.editProfile, style: boldTextStyle()),
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Card(
                            semanticContainer: true,
                            color: colorPrimary,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            elevation: spacing_standard_new,
                            margin: EdgeInsets.all(0),
                            shape: CircleBorder(),
                            child: image != null
                                ? Image.file(File(image!.path), height: 120, width: 120, fit: BoxFit.cover)
                                : appStore.userProfileImage.validate().isNotEmpty
                                    ? CachedImageWidget(url: appStore.userProfileImage.validate(), height: 120, width: 120, fit: BoxFit.cover)
                                    : CachedImageWidget(url: appStore.userProfileImage.validate(), width: 120, height: 120, fit: BoxFit.cover),
                          ),
                          Positioned(
                            right: -4,
                            bottom: -4,
                            child: GestureDetector(
                              onTap: () {
                                getImage();
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: colorPrimary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: colorPrimary, width: 3),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Image.asset(ic_camera, color: white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).paddingOnly(top: 16),
                ).center(),
                Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AppTextField(
                        controller: firstNameController,
                        nextFocus: lastNameFocusNode,
                        textFieldType: TextFieldType.NAME,
                        title: language.firstName,
                        titleTextStyle: primaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                        textStyle: primaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                        decoration: InputDecoration(
                          hintText: language.firstName,
                          hintStyle: secondaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                          prefixIcon: Icon(Icons.person_outline, color: context.primaryColor),
                          filled: true,
                          fillColor: appBackground,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorPrimary, width: 1.5)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ).paddingBottom(spacing_standard_new),
                      AppTextField(
                        controller: lastNameController,
                        focus: lastNameFocusNode,
                        nextFocus: emailFocusNode,
                        textFieldType: TextFieldType.NAME,
                        errorThisFieldRequired: errorThisFieldRequired,
                        title: language.lastName,
                        titleTextStyle: primaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                        textStyle: primaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                        decoration: InputDecoration(
                          hintText: language.lastName,
                          hintStyle: secondaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                          prefixIcon: Icon(Icons.person_outline, color: context.primaryColor),
                          filled: true,
                          fillColor: appBackground,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorPrimary, width: 1.5)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ).paddingBottom(spacing_standard_new),
                      AppTextField(
                        controller: emailController,
                        textFieldType: TextFieldType.EMAIL,
                        focus: emailFocusNode,
                        title: language.email,
                        titleTextStyle: primaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                        textStyle: primaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                        decoration: InputDecoration(
                          hintText: language.email,
                          hintStyle: secondaryTextStyle(size: textSecondarySizeGlobal.toInt()),
                          prefixIcon: Icon(Icons.mail_outline, color: context.primaryColor),
                          filled: true,
                          fillColor: appBackground,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorPrimary, width: 1.5)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ).paddingBottom(spacing_standard_new),
                    ],
                  ),
                ).paddingOnly(left: 16, right: 16, top: 36),
                AppButton(
                  width: context.width(),
                  text: language.save,
                  color: colorPrimary,
                  onTap: () {
                    if (appStore.userEmail != DEFAULT_EMAIL) {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();

                        save(context);
                      }
                    } else {
                      toast(language.demoUserCanTPerformThisAction);
                    }
                  },
                ).paddingOnly(top: 30, left: 18, right: 18, bottom: 30)
              ],
            ),
          ),
          Observer(
            builder: (_) => LoaderWidget().visible(appStore.isLoading),
          ),
        ],
      ),
    );
  }
}
