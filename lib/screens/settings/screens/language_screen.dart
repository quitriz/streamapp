import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

import '../../../main.dart';

class LanguageScreen extends StatefulWidget {
  static String tag = '/languageScreen';

  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final availableLanguages = appStore.availableLanguages;

        return Scaffold(
            backgroundColor: cardColor,
            appBar: AppBar(
              title: Observer(
                builder: (_) {
                  return Text(language.language, style: primaryTextStyle());
                },
              ),
              backgroundColor: appBackground,
            ),
            body: ListView.builder(
              itemCount: availableLanguages.length,
              itemBuilder: (context, index) {
                LanguageDataModel data = availableLanguages[index];
                Locale locale = Locale(data.languageCode.validate());

                return Observer(
                  builder: (_) {
                    bool isSelected = appStore.selectedLanguageCode ==
                        data.languageCode.validate();

                    return GestureDetector(
                      onTap: () async {
                        if (await isNetworkAvailable()) {
                          await appStore.setLanguage(locale.languageCode);
                          appStore.setSelectedLanguageDataModel(data);
                          Navigator.pop(context);
                          LanguageScreen().launch(context);
                        } else {
                          toast(errorInternetNotAvailable);
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        color: isSelected ? appBackground : Colors.transparent,
                        child: Row(
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: CachedImageWidget(
                                    url: data.flag.validate(),
                                    height: 17.14,
                                    width: 24,
                                    fit: BoxFit.cover)),
                            16.width,
                            Text(data.name.validate(),
                                    style: primaryTextStyle(
                                        size: textSecondarySizeGlobal.toInt()))
                                .expand(),
                            if (isSelected)
                              Icon(Icons.check_circle,
                                  color: context.primaryColor, size: 16)
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ));
      },
    );
  }
}
