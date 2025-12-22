import 'dart:async';

typedef VideoPauseCallback = FutureOr<void> Function();
typedef VideoResumeCallback = FutureOr<void> Function();

/// Simple wrapper so parent widgets can pause/resume the
/// underlying video player without needing a direct reference
/// to the concrete controller implementation.
class VideoPlaybackHandle {
  VideoPlaybackHandle({
    required this.pause,
    this.resume,
  });

  final VideoPauseCallback pause;
  final VideoResumeCallback? resume;
}

