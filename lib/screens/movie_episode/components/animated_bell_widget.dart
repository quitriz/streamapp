import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nb_utils/nb_utils.dart';

class AnimatedBellWidget extends StatefulWidget {
  final VoidCallback? onAnimationComplete;
  final double size;
  final bool isRemind;

  const AnimatedBellWidget({
    Key? key,
    this.onAnimationComplete,
    this.size = 24,
    this.isRemind = false,
  }) : super(key: key);

  @override
  AnimatedBellWidgetState createState() => AnimatedBellWidgetState();
}

class AnimatedBellWidgetState extends State<AnimatedBellWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;
  bool _isLottieLoaded = false;
  bool _isAnimating = false;
  bool _hasCompletedAnimation = false;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _hasCompletedAnimation = widget.isRemind;
  }

  @override
  void didUpdateWidget(AnimatedBellWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle reminder status changes
    if (oldWidget.isRemind != widget.isRemind) {
      if (widget.isRemind && !oldWidget.isRemind) {
        // Reminder was just set - trigger animation
        _triggerAnimation();
      } else if (!widget.isRemind && oldWidget.isRemind) {
        // Reminder was removed - reset to bell
        _lottieController.reset();
        _hasCompletedAnimation = false;
        _isAnimating = false;
      }
    }
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  Future<void> _triggerAnimation() async {
    if (_isAnimating || !_isLottieLoaded) return;

    _isAnimating = true;
    try {
      // Reset animation to start from beginning
      _lottieController.reset();
      // Play the animation
      await _lottieController.forward(from: 0);
      
      if (mounted) {
        setState(() {
          _hasCompletedAnimation = true;
          _isAnimating = false;
        });
        widget.onAnimationComplete?.call();
      }
    } catch (e) {
      log('Error playing bell animation: $e');
      if (mounted) {
        setState(() {
          _isAnimating = false;
        });
      }
    }
  }

  Future<void> playAnimation() async {
    await _triggerAnimation();
  }

  @override
  Widget build(BuildContext context) {
    // Show check icon only when reminder is set AND animation has completed (or was already set on init)
    // While animating, show the bell animation
    final bool showCheckIcon = widget.isRemind && _hasCompletedAnimation && !_isAnimating;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: showCheckIcon
          ? Icon(
              Icons.check_circle,
              color: white,
              size: 25,
              key: const ValueKey('check_icon'),
            )
          : ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcATop,
              ),
              ///TODO manage const
              child: Lottie.asset(
                'assets/lottie/bell_notification.json',
                controller: _lottieController,
                height: widget.size,
                width: widget.size,
                fit: BoxFit.contain,
                key: const ValueKey('bell_lottie'),
                onLoaded: (composition) {
                  if (mounted) {
                    setState(() {
                      _lottieController.duration = composition.duration;
                      _isLottieLoaded = true;
                    });
                    if (widget.isRemind && !_hasCompletedAnimation && !_isAnimating) {
                      _triggerAnimation();
                    }
                  }
                },
              ),
            ),
    );
  }
}
