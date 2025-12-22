import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';

class VoiceSearchScreen extends StatefulWidget {
  const VoiceSearchScreen({Key? key}) : super(key: key);

  @override
  State<VoiceSearchScreen> createState() => _VoiceSearchScreenState();
}

class _VoiceSearchScreenState extends State<VoiceSearchScreen> {
  SpeechToText speech = SpeechToText();

  Future<void> listen() async {
    if (!appStore.isListening) {
      bool available = await speech.initialize();

      if (available) {
        appStore.setShowVoiceButton(false);
        appStore.setListening(true);

        speech.listen(onResult: (val) {
          appStore.setVoiceText(val.recognizedWords);
          appStore.setListening(false);
        });

        await 5.seconds.delay;

        if (appStore.voiceText == language.listening) {
          appStore.setShowVoiceButton(true);
        } else {
          finish(context, appStore.voiceText);
        }
      } else {
        appStore.setShowVoiceButton(true);
        appStore.setListening(false);
        speech.stop();
      }
    } else {
      appStore.setListening(false);
      speech.stop();
    }
  }

  @override
  void initState() {
    super.initState();
    appStore.resetVoiceSearch();
    appStore.setVoiceText(language.listening);
    listen();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Scaffold(
        backgroundColor: context.scaffoldBackgroundColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(appStore.voiceText, style: boldTextStyle(size: 24)).visible(!appStore.showVoiceButton),
            Icon(
              Icons.keyboard_voice,
              size: 50,
              color: colorPrimary,
            ).onTap(() {
              appStore.setListening(false);
              listen();
            }).visible(appStore.showVoiceButton),
            30.height.visible(appStore.showVoiceButton),
            Image.asset(
              ic_voice,
              height: 150,
              width: 150,
              color: colorPrimary,
            ).visible(!appStore.showVoiceButton),
            Text(
              language.tapToSpeak,
              style: boldTextStyle(size: 20),
              textAlign: TextAlign.center,
            ).paddingSymmetric(horizontal: 40).visible(appStore.showVoiceButton)
          ],
        ).center(),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text(language.searchMoviesTvShowsVideos, style: primaryTextStyle(), textAlign: TextAlign.center),
        ),
      );
    });
  }
}
