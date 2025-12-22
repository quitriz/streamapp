import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/ad_components/html_ad_helper_components.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

/// Overlay Ad Widget
class OverlayAd extends StatefulWidget {
  final String content;
  final bool isFullscreen;
  final int? skipDuration;
  final VoidCallback? onTimerComplete;

  const OverlayAd(
      {Key? key, required this.content, required this.isFullscreen, this.skipDuration, this.onTimerComplete})
      : super(key: key);

  @override
  State<OverlayAd> createState() => _OverlayAdState();
}

class _OverlayAdState extends State<OverlayAd> with CountdownTimerMixin {
  @override
  int get skipDuration => widget.skipDuration ?? 5;

  @override
  VoidCallback? get onTimerComplete => widget.onTimerComplete;

  @override
  Widget build(BuildContext context) {
    if (widget.content.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 10),
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 60),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(8)),
        child: Stack(
          children: [
            Row(
              children: [
                AdImage(imageUrl: AdContentParser.extractImageUrl(widget.content), width: 40, height: 15)
                    .paddingAll(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AdContentParser.extractTitle(widget.content),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: widget.isFullscreen ? 12 : 10,
                            fontWeight: FontWeight.bold,
                            height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.fade,
                      ).flexible(),
                      2.height,
                      Text(
                        AdContentParser.extractDescription(widget.content),
                        style:
                            TextStyle(color: textColorSecondary, fontSize: widget.isFullscreen ? 10 : 9, height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.fade,
                      ).flexible(),
                    ],
                  ).paddingSymmetric(vertical: 8, horizontal: 4),
                ),
                AdButton(
                        text: AdContentParser.extractButtonText(widget.content),
                        url: AdContentParser.extractButtonUrl(widget.content),
                        fontSize: 9)
                    .paddingOnly(left: 4, top: 8, right: 12, bottom: 8),
              ],
            ),
            Positioned(
              top: 4,
              right: 4,
              child: CountdownDisplay(countdown: currentCountdown),
            ),
          ],
        ),
      ),
    );
  }
}

/// Companion Ad Widget
class CompanionAd extends StatefulWidget {
  final String content;
  final bool isFullscreen;
  final int? skipDuration;
  final VoidCallback? onTimerComplete;

  const CompanionAd(
      {Key? key, required this.content, required this.isFullscreen, this.skipDuration, this.onTimerComplete})
      : super(key: key);

  @override
  State<CompanionAd> createState() => _CompanionAdState();
}

class _CompanionAdState extends State<CompanionAd> with CountdownTimerMixin {
  @override
  int get skipDuration => widget.skipDuration ?? 5;

  @override
  VoidCallback? get onTimerComplete => widget.onTimerComplete;

  double _calculateAdSize(double screenWidth) {
    if (screenWidth > 1200) return 180;
    if (screenWidth > 600) return 160;
    return (screenWidth * 0.35).clamp(120, 140);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.content.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final adSize = _calculateAdSize(MediaQuery.of(context).size.width);

    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: EdgeInsets.fromLTRB(4, widget.isFullscreen ? MediaQuery.of(context).padding.top + 4 : 8, 4, 0),
        child: Container(
          width: adSize,
          height: adSize,
          decoration:
              BoxDecoration(color: Colors.black.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(8)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: adSize * 0.15,
                child: Row(
                  children: [
                    AdImage(imageUrl: AdContentParser.extractImageUrl(widget.content), height: adSize * 0.12),
                    const Spacer(),
                    CountdownDisplay(countdown: currentCountdown, fontSize: 9),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AdContentParser.extractTitle(widget.content),
                      style: TextStyle(
                          color: Colors.white, fontSize: adSize * 0.085, fontWeight: FontWeight.bold, height: 1.1),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.fade,
                    ),
                    SizedBox(height: adSize * 0.04),
                    Text(
                      AdContentParser.extractDescription(widget.content),
                      style: TextStyle(color: Colors.grey[400], fontSize: adSize * 0.055, height: 1.2),
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.fade,
                    ),
                  ],
                ),
              ),
              AdButton(
                  text: AdContentParser.extractButtonText(widget.content),
                  url: AdContentParser.extractButtonUrl(widget.content),
                  fontSize: adSize * 0.065,
                  padding: EdgeInsets.symmetric(vertical: adSize * 0.04),
                  borderRadius: 4),
            ],
          ).paddingAll(adSize * 0.06),
        ),
      ),
    );
  }
}
