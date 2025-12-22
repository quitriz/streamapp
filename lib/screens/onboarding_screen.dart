import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/config.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/onboarding_list_model.dart';
import 'package:streamit_flutter/screens/home_screen.dart';
import 'package:streamit_flutter/utils/cached_data.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/images.dart';

class OnBoardingScreen extends StatelessWidget {
  static String tag = '/OnBoardingScreen';

  OnBoardingScreen({Key? key}) : super(key: key) {
    setStatusBarColor(Colors.transparent);
    appStore.setCurrentOnboardingPageIndex(0);
    _loadOnboardingData();
  }

  final PageController controller = PageController();

  void _loadOnboardingData() {
    try {
      OnBoardingListModel? cachedData = OnboardingCachedData.getData();

      if (cachedData != null && cachedData.status == true && cachedData.data != null && cachedData.data!.isNotEmpty) {
        _buildOnboardingWidgets(cachedData.data!);
        log('Using cached onboarding data');
      } else {
        _setFallbackData();
        log('Using fallback static onboarding data');
      }
    } catch (e) {
      log('Error loading onboarding data: ${e.toString()}');
      _setFallbackData();
    }
  }

  void _setFallbackData() {
    List<OnBoardingData> onboardingData = [
      OnBoardingData(title: walk_titles[0], description: walk_sub_titles[0], image: ic_walkthrough1),
      OnBoardingData(title: walk_titles[1], description: walk_sub_titles[1], image: ic_walkthrough2),
      OnBoardingData(title: walk_titles[2], description: walk_sub_titles[2], image: ic_walkthrough3),
    ];
    _buildOnboardingWidgets(onboardingData);
  }

  void _buildOnboardingWidgets(List<OnBoardingData> onboardingData) {
    List<Widget> widgets = [];
    for (OnBoardingData data in onboardingData) {
      widgets.add(
        WalkThrough(
          title: data.title.validate(),
          subtitle: data.description.validate(),
          walkthroughImage: data.image.validate(),
          isNetworkImage: data.image.validate().startsWith('http'),
        ),
      );
    }
    appStore.setOnboardingWidgets(widgets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      body: Container(
        height: context.height(),
        width: context.width(),
        child: Stack(
          children: [
            Observer(
              builder: (_) => PageView(
                controller: controller,
                children: appStore.onboardingWidgets,
                onPageChanged: (value) {
                  appStore.setCurrentOnboardingPageIndex(value);
                },
              ),
            ),
            Positioned(
              top: 15,
              right: 20,
              child: Observer(
                builder: (_) {
                  bool isLastPage = appStore.onboardingWidgets.isNotEmpty && appStore.currentOnboardingPageIndex == appStore.onboardingWidgets.length - 1;
                  if (isLastPage) return SizedBox.shrink();
                  return TextButton(
                    onPressed: () {
                      HomeScreen().launch(context, isNewTask: true);
                    },
                    child: Text(language.skip, style: primaryTextStyle(color: context.primaryColor)),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Observer(
                      builder: (_) => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: appStore.onboardingWidgets.asMap().entries.map((entry) {
                          int index = entry.key;
                          return AnimatedContainer(
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            duration: const Duration(milliseconds: 300),
                            height: 8,
                            width: index == appStore.currentOnboardingPageIndex ? 24 : 8,
                            decoration:
                                BoxDecoration(color: index == appStore.currentOnboardingPageIndex ? Colors.white : Colors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
                          );
                        }).toList(),
                      ),
                    ),
                    32.height,
                    // Next button
                    Observer(
                      builder: (_) => AppButton(
                        color: context.primaryColor,
                        elevation: 0,
                        shapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        splashColor: context.primaryColor.withValues(alpha: 0.2),
                        padding: EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                        onTap: () {
                          if (appStore.currentOnboardingPageIndex == appStore.onboardingWidgets.length - 1) {
                            HomeScreen().launch(context, isNewTask: true);
                          } else {
                            controller.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        text: appStore.currentOnboardingPageIndex == appStore.onboardingWidgets.length - 1 ? language.getStarted : language.next,
                        textStyle: boldTextStyle(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WalkThrough extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? walkthroughImage;
  final bool isNetworkImage;

  WalkThrough({Key? key, this.title, this.subtitle, this.walkthroughImage, this.isNetworkImage = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.height(),
      width: context.width(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withValues(alpha: 0.3), Colors.black.withValues(alpha: 0.7), Colors.black.withValues(alpha: 0.9)],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),
          Positioned(
            top: context.height() * 0.08,
            left: context.width() * 0.10,
            right: context.width() * 0.10,
            child: Container(
              height: context.height() * 0.50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: 0.14,
                    child: Container(
                      width: context.width() * 0.68,
                      height: context.height() * 0.45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Color(0xFF404A51), width: 2),
                        image: DecorationImage(
                          image: isNetworkImage ? NetworkImage(walkthroughImage.validate()) : AssetImage(walkthroughImage.validate()) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.8), blurRadius: 35, offset: Offset(10, 18), spreadRadius: -5),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: context.width() * 0.72,
                    height: context.height() * 0.45,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: Color(0xFF404A51), width: 2)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: isNetworkImage ? NetworkImage(walkthroughImage.validate()) : AssetImage(walkthroughImage.validate()) as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.1), Colors.black.withValues(alpha: 0.3)],
                              stops: [0.0, 0.7, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 130,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(title!, style: boldTextStyle(size: 22), textAlign: TextAlign.center),
                16.height,
                Text(subtitle!, style: secondaryTextStyle(size: textSecondarySizeGlobal.toInt()), textAlign: TextAlign.center, maxLines: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
