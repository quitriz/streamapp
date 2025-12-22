import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/size.dart';

Widget itemTitle(BuildContext context, String titleText, {double fontSize = ts_normal, int? maxLine, TextAlign? textAlign}) {
  return Marquee(
    animationDuration: Duration(milliseconds: 500),
    child: Text(
      titleText,
      style: TextStyle(
        fontSize: fontSize,
        color: Colors.white,
        fontWeight: FontWeight.bold,
        shadows: <Shadow>[
          Shadow(blurRadius: 5.0, color: Colors.black),
        ],
      ),
      textAlign: textAlign ?? TextAlign.center,
      overflow: TextOverflow.ellipsis,
      maxLines: maxLine ?? 1,
    ),
  );
}

Widget headingWidViewAll(BuildContext context, var titleText, {VoidCallback? callback, bool showViewMore = true, EdgeInsets? padding}) {
  return Padding(
    padding: padding ?? EdgeInsets.only(left: 16, top: 16, bottom: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(titleText, style: primaryTextStyle(size: 18), maxLines: 1, overflow: TextOverflow.ellipsis).expand(),
        if (showViewMore)
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: callback,
            icon: Icon(Icons.arrow_forward_ios, size: 14, color: context.iconColor),
          ),
      ],
    ),
  );
}

InputDecoration inputDecoration({String? hint, IconData? suffixIcon}) {
  return InputDecoration(
    labelText: hint,
    labelStyle: primaryTextStyle(color: Colors.white),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
    errorBorder: OutlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
    border: OutlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade500)),
    disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade500)),
    suffixIcon: Icon(suffixIcon, color: colorPrimary),
  );
}

List<LanguageDataModel> languageList() {
  return [
    LanguageDataModel(id: 1, name: 'English', languageCode: 'en', fullLanguageCode: 'en-US', flag: 'assets/images/flag/ic_us.png'),
    LanguageDataModel(id: 2, name: 'Tiếng Việt', languageCode: 'vi', fullLanguageCode: 'vi-VN', flag: 'assets/images/flag/ic_vietnam.png'),
    LanguageDataModel(id: 3, name: 'Arabic', languageCode: 'ar', fullLanguageCode: 'ar-AR', flag: 'assets/images/flag/ic_ar.png'),
    LanguageDataModel(id: 4, name: 'French', languageCode: 'fr', fullLanguageCode: 'fr-FR', flag: 'assets/images/flag/ic_france.png'),
  ];
}

String userProfileImage() {
  Random random = Random();
  return 'assets/images/smile_${random.nextInt(4)}.png';
}

class SettingWidget extends StatelessWidget {
  final String title;
  final double? width;
  final String? subTitle;
  final Widget? leading;
  final Widget? trailing;
  final TextStyle? titleTextStyle;
  final TextStyle? subTitleTextStyle;
  final Function? onTap;
  final EdgeInsets? padding;
  final int paddingAfterLeading;
  final int paddingBeforeTrailing;
  final Color? titleTextColor;
  final Color? subTitleTextColor;
  final Color? hoverColor;
  final Color? splashColor;
  final Color? highlightColor;
  final Decoration? decoration;
  final double? borderRadius;
  final BorderRadius? radius;
  final CrossAxisAlignment crossAxisAlignment;

  SettingWidget(
      {required this.title,
      this.onTap,
      this.width,
      this.subTitle = '',
      this.leading,
      this.trailing,
      this.titleTextStyle,
      this.subTitleTextStyle,
      this.padding,
      this.paddingAfterLeading = 16,
      this.paddingBeforeTrailing = 16,
      this.titleTextColor,
      this.subTitleTextColor,
      this.decoration,
      this.borderRadius,
      this.hoverColor,
      this.splashColor,
      this.highlightColor,
      this.radius,
      Key? key,
      this.crossAxisAlignment = CrossAxisAlignment.center})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding ?? EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: decoration ?? BoxDecoration(),
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          leading ?? SizedBox(),
          if (leading != null) paddingAfterLeading.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                title.validate(),
                style: titleTextStyle ?? boldTextStyle(color: titleTextColor ?? textPrimaryColorGlobal),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
              ),
              4.height.visible(subTitle.validate().isNotEmpty),
              if (subTitle.validate().isNotEmpty)
                Text(
                  subTitle!,
                  style: subTitleTextStyle ??
                      secondaryTextStyle(
                        color: subTitleTextColor ?? textSecondaryColorGlobal,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ).expand(),
          if (trailing != null) paddingBeforeTrailing.width,
          trailing ?? SizedBox(),
        ],
      ),
    ).onTap(
      onTap,
      borderRadius: radius ?? (BorderRadius.circular(borderRadius.validate())),
      hoverColor: hoverColor ?? colorPrimary.withValues(alpha: 0.2),
      splashColor: splashColor ?? colorPrimary.withValues(alpha: 0.2),
      highlightColor: highlightColor ?? colorPrimary.withValues(alpha: 0.2),
    );
  }
}
