import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/models/movie_episode/movie_data.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/screens/auth/sign_in.dart';
import 'package:streamit_flutter/screens/movie_episode/components/animated_bell_widget.dart';
import 'package:streamit_flutter/screens/movie_episode/components/rent_bottom_sheet.dart';
import 'package:streamit_flutter/screens/pmp/screens/membership_plans_screen.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';

import '../../../utils/common.dart';

class SelectionButton extends StatelessWidget {
  final String? text;
  final Widget? rentPriceWidget;
  final Widget? leadingWidget;
  final Color color;
  final VoidCallback? onTap;
  final double height;
  final double? width;
  final TextStyle? textStyle;

  const SelectionButton({Key? key, this.text, this.rentPriceWidget, required this.color, this.onTap, this.height = 45, this.width, this.textStyle, this.leadingWidget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width ?? context.width(),
      decoration: BoxDecoration(color: color, borderRadius: radius(4)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leadingWidget != null) leadingWidget!,
          if (leadingWidget != null) 4.width,
          (rentPriceWidget ?? Text(text ?? '', style: textStyle ?? boldTextStyle(color: Colors.white))),
        ],
      ).center(),
    ).onTap(onTap);
  }
}

class SelectionButtonsWidget extends StatefulWidget {
  final MovieData movie;
  final String genre;
  final bool isTrailerPlaying;
  final bool isUpcoming;
  final VoidCallback? onStreamNow;
  final VoidCallback? onRent;
  final VoidCallback? onSubscribe;
  final VoidCallback? onUpgrade;
  final VoidCallback? onRemindMe;
  final VoidCallback? onResumeWatching;
  final VoidCallback? onStartFromBeginning;
  final bool hideResumeWatching;

  const SelectionButtonsWidget({
    Key? key,
    required this.movie,
    required this.genre,
    this.isTrailerPlaying = false,
    this.isUpcoming = false,
    this.onStreamNow,
    this.onRent,
    this.onSubscribe,
    this.onUpgrade,
    this.onRemindMe,
    this.onResumeWatching,
    this.onStartFromBeginning,
    this.hideResumeWatching = false,
  }) : super(key: key);

  @override
  State<SelectionButtonsWidget> createState() => _SelectionButtonsWidgetState();
}

class _SelectionButtonsWidgetState extends State<SelectionButtonsWidget> with WidgetsBindingObserver {
  final GlobalKey<AnimatedBellWidgetState> _bellKey = GlobalKey<AnimatedBellWidgetState>();
  bool _isWaitingForPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isWaitingForPermission) {
      _checkPermissionAndSetReminder();
    }
  }

  bool get _shouldShowUpgrade {
    if (widget.movie.requiredPlan.validate().isEmpty || appStore.subscriptionPlanId.isEmpty) {
      return false;
    }

    try {
      final currentPlanId = int.tryParse(appStore.subscriptionPlanId) ?? 0;
      for (final requiredPlan in widget.movie.requiredPlan!) {
        final requiredPlanId = int.tryParse(requiredPlan.toString()) ?? 0;
        if (currentPlanId < requiredPlanId) {
          return true;
        }
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  void _navigateToMembershipPlans(BuildContext context) {
    if (!appStore.isLogging) {
      SignInScreen().launch(context);
      return;
    }
    MembershipPlansScreen(requiredPlanIds: widget.movie.requiredPlan).launch(context);
  }

  void _showRentBottomSheet(
    BuildContext context, {
    bool showSubscribeButton = false,
    bool showUpgradeButton = false,
  }) {
    RentBottomSheet.show(
      context,
      movie: widget.movie,
      genre: widget.genre,
      onRentTap: widget.onRent,
      onSubscribeTap: () => _navigateToMembershipPlans(context),
      onUpgradeTap: () => _navigateToMembershipPlans(context),
      showSubscribeButton: showSubscribeButton,
      showUpgradeButton: showUpgradeButton,
    );
  }

  void _handleRemindMe() async {
    if (widget.movie.isRemind.validate()) {
      _setReminder();
      return;
    }

    final status = await Permission.notification.status;

    if (!status.isGranted) {
      _showNotificationPermissionCard();
      return;
    }

    _setReminder();
  }

  void _setReminder() {
    widget.onRemindMe?.call();
    _bellKey.currentState?.playAnimation();
  }

  Future<void> _checkPermissionAndSetReminder() async {
    final status = await Permission.notification.status;

    if (mounted) {
      setState(() {
        _isWaitingForPermission = false;
      });
    }

    if (status.isGranted && !widget.movie.isRemind.validate()) {
      _setReminder();
    }
  }

  void _showNotificationPermissionCard() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bell Icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      size: 48,
                      color: context.primaryColor,
                    ),
                  ),
                  16.height,

                  // Title
                  Text(
                    language.allowNotifications,
                    style: boldTextStyle(size: 20),
                    textAlign: TextAlign.center,
                  ),
                  12.height,

                  // Description
                  Text(
                    language.notificationPermissionText,
                    style: secondaryTextStyle(size: 14),
                    textAlign: TextAlign.center,
                  ),
                  24.height,

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: BorderSide(color: white),
                          ),
                          child: Text(
                            language.notNow,
                            style: boldTextStyle(size: 14),
                          ),
                        ),
                      ),
                      12.width,
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            setState(() {
                              _isWaitingForPermission = true;
                            });
                            await openAppSettings();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            language.allow,
                            style: boldTextStyle(color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Get episode index for TV Shows
  Future<int?> _getEpisodeIndexForTvShow(int showId, int seasonId, int episodeId) async {
    try {
      final season = await tvShowSeasonDetail(showId: showId, seasonId: seasonId);
      if (season.episodes != null && season.episodes!.isNotEmpty) {
        for (int i = 0; i < season.episodes!.length; i++) {
          if (season.episodes![i].id == episodeId) {
            return i + 1; // Return 1-based index for display
          }
        }
      }
      return null;
    } catch (e) {
      log('Error getting episode index: $e');
      return null;
    }
  }

  /// Format resume watching text for TV Shows
  String _formatTvShowResumeText(int seasonId, int? episodeIndex) {
    if (episodeIndex != null) {
      return '${language.resumeWatching} S$seasonId E$episodeIndex';
    }
    return '${language.resumeWatching} S$seasonId';
  }

  Widget _buildResumeWatchingSection() {
    final watchedDuration = widget.movie.watchedDuration;
    if (watchedDuration == null || watchedDuration.watchedTime <= 0) {
      return SizedBox.shrink();
    }

    final progress = (watchedDuration.watchedTimePercentage / 100).clamp(0.0, 1.0);

    // Check if this is a TV Show (has seasonId and episodeId)
    final isTvShow = watchedDuration.seasonId != null && watchedDuration.episodeId != null;
    final showId = widget.movie.id.validate();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Resume Watching Button with Progress Track
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            isTvShow && showId > 0
                ? FutureBuilder<int?>(
                    future: _getEpisodeIndexForTvShow(showId, watchedDuration.seasonId!, watchedDuration.episodeId!),
                    builder: (context, snapshot) {
                      final episodeIndex = snapshot.data;
                      final resumeText = _formatTvShowResumeText(watchedDuration.seasonId!, episodeIndex);

                      return SelectionButton(
                        text: snapshot.connectionState == ConnectionState.waiting ? language.resumeWatching : resumeText,
                        color: context.primaryColor,
                        textStyle: boldTextStyle(color: Colors.white),
                        onTap: widget.onResumeWatching,
                      );
                    },
                  )
                : SelectionButton(
                    text: language.resumeWatching,
                    color: context.primaryColor,
                    textStyle: boldTextStyle(color: Colors.white),
                    onTap: widget.onResumeWatching,
                  ),

            /// Progress Track at bottom with 0 margin
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: context.scaffoldBackgroundColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4)),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        /// Start From Beginning Button
        8.height,
        SelectionButton(
          text: language.startFromBeginning,
          color: context.primaryColor,
          textStyle: boldTextStyle(color: Colors.white),
          onTap: widget.onStartFromBeginning,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = appStore.isLogging;
    final bool hasWatchedDuration = widget.movie.watchedDuration != null;
    final bool hasValidWatchedTime = hasWatchedDuration && widget.movie.watchedDuration!.watchedTime > 0;
    final bool isNotUpcoming = !widget.isUpcoming;
    final bool hasAccess = widget.movie.userHasAccess.validate();

    // Check if this is a TV Show (has seasonId and episodeId in watchedDuration)
    final bool isTvShow = hasWatchedDuration && widget.movie.watchedDuration!.seasonId != null && widget.movie.watchedDuration!.episodeId != null;

    // For TV Shows, show resume watching even if trailer is not playing
    // For Movies, require trailer to be playing
    // Hide if user has already taken action
    final bool showResumeWatching = !widget.hideResumeWatching && isLoggedIn && hasWatchedDuration && hasValidWatchedTime && isNotUpcoming && hasAccess && (isTvShow || widget.isTrailerPlaying);
    final bool showStreamNow = widget.isTrailerPlaying && !widget.isUpcoming && widget.movie.userHasAccess.validate() && !showResumeWatching;
    final bool showRentPpv = widget.movie.purchaseType == PurchaseType.ppv && widget.movie.isRent == true && widget.movie.userHasAccess == false && coreStore.isMembershipEnabled && !widget.isUpcoming;
    final bool showSubscribeOrUpgradePlan = widget.movie.purchaseType == PurchaseType.plan &&
        widget.movie.isRent.validate() &&
        widget.movie.requiredPlan.validate().isNotEmpty &&
        appStore.subscriptionPlanId != widget.movie.requiredPlan.toString() &&
        widget.movie.userHasAccess == false &&
        coreStore.isMembershipEnabled &&
        !widget.isUpcoming;
    final bool showRentOrSubscribeAnyone = widget.movie.purchaseType == PurchaseType.anyone &&
        widget.movie.isRent.validate() &&
        widget.movie.requiredPlan.validate().isNotEmpty &&
        appStore.subscriptionPlanId != widget.movie.requiredPlan.toString() &&
        widget.movie.userHasAccess == false &&
        coreStore.isMembershipEnabled &&
        !widget.isUpcoming;
    final bool showRemindMe = widget.isUpcoming;

    final bool hasAnyAction = showResumeWatching || showStreamNow || showRentPpv || showSubscribeOrUpgradePlan || showRentOrSubscribeAnyone || showRemindMe;

    return Column(
      children: [
        if (hasAnyAction) 16.height,

        if (showResumeWatching) _buildResumeWatchingSection(),

        if (showStreamNow) SelectionButton(text: language.streamNow, color: context.primaryColor, textStyle: boldTextStyle(color: Colors.white), onTap: widget.onStreamNow),

        /// Rent Button (PPV)
        if (showRentPpv)
          SelectionButton(
            rentPriceWidget: rentalPriceWidget(
              discountedPrice: widget.movie.discountedPrice.validate(),
              price: widget.movie.price.validate(),
            ),
            color: rentButtonColor,
            onTap: () => _showRentBottomSheet(context, showSubscribeButton: false),
          ),

        /// Subscribe/Upgrade Button (Plan only)
        if (showSubscribeOrUpgradePlan)
          SelectionButton(
            text: _shouldShowUpgrade ? language.upgradeToWatch : language.subscribeToWatch,
            color: context.primaryColor,
            onTap: _shouldShowUpgrade ? () => _navigateToMembershipPlans(context) : () => _navigateToMembershipPlans(context),
          ),

        /// Rent or Subscribe Button (Anyone)
        if (showRentOrSubscribeAnyone)
          SelectionButton(
            text: _shouldShowUpgrade ? language.rentOrUpgradeToWatch : language.rentOrSubscribeToWatch,
            color: context.primaryColor,
            onTap: () => _showRentBottomSheet(context, showSubscribeButton: !_shouldShowUpgrade, showUpgradeButton: _shouldShowUpgrade),
          ),

        /// Remind Me Button for Upcoming Content with Animated Bell
        if (showRemindMe)
          SelectionButton(
            leadingWidget: AnimatedBellWidget(
              key: _bellKey,
              size: 35,
              isRemind: widget.movie.isRemind.validate(),
              onAnimationComplete: () {},
            ),
            text: widget.movie.isRemind.validate() ? language.reminderSet : language.remindMe,
            color: context.primaryColor,
            textStyle: boldTextStyle(),
            onTap: _handleRemindMe,
          ),

        if (hasAnyAction) 16.height,
      ],
    );
  }
}
