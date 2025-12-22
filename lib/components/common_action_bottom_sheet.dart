import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

Future<T?> showCommonActionBottomSheet<T>({
  required BuildContext context,
  required String title,
  required String subtitle,
  required String icon,
  required String positiveText,
  required String negativeText,
  required VoidCallback positiveOnTap,
  final bool applyIconColor =true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CommonActionBottomSheetContent(
      title: title,
      subtitle: subtitle,
      icon: icon,
      positiveText: positiveText,
      negativeText: negativeText,
      positiveOnTap: positiveOnTap,
      applyIconColor:applyIconColor
    ),
  );
}

class CommonActionBottomSheetContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final String positiveText;
  final String negativeText;
  final VoidCallback positiveOnTap;
  final bool applyIconColor;

  const CommonActionBottomSheetContent({required this.title, required this.subtitle, required this.icon, required this.positiveText, required this.negativeText, required this.positiveOnTap,required this.applyIconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CachedImageWidget(url: icon, height: 62, width: 58, color: applyIconColor ? context.primaryColor : null),
              24.height,
              Text(title, style: boldTextStyle(size: 20), textAlign: TextAlign.center),
              8.height,
              Text(subtitle, style: secondaryTextStyle(size: textPrimarySizeGlobal.toInt()), textAlign: TextAlign.center),
              42.height,
              Row(
                children: [
                  AppButton(
                    text: negativeText,
                    textStyle: boldTextStyle(size: textSecondarySizeGlobal.toInt()),
                    onTap: () => finish(context),
                    color: appBackground,
                    elevation: 0,
                    width: context.width(),
                  ).expand(),
                  16.width,
                  AppButton(
                    text: positiveText,
                    textStyle: boldTextStyle(size: textSecondarySizeGlobal.toInt()),
                    onTap: positiveOnTap,
                    color: context.primaryColor,
                    elevation: 0,
                    width: context.width(),
                  ).expand(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
