class ContinueWatchModel {
  int watchedTime;
  int watchedTotalTime;
  int watchedTimePercentage;
  int? seasonId;
  int? episodeId;

  ContinueWatchModel({
    this.watchedTime = -1,
    this.watchedTotalTime = -1,
    this.watchedTimePercentage = -1,
    this.seasonId,
    this.episodeId,
  });

  factory ContinueWatchModel.fromJson(Map<String, dynamic> json) {
    return ContinueWatchModel(
      watchedTime: json['watched_time'] is int ? json['watched_time'] : -1,
      watchedTotalTime:
      json['watched_total_time'] is int ? json['watched_total_time'] : -1,
      watchedTimePercentage: json['watched_time_percentage'] is int
          ? json['watched_time_percentage']
          : -1,
      seasonId: json['season_id'] is int ? json['season_id'] : (json['season_id'] is String ? int.tryParse(json['season_id']) : null),
      episodeId: json['episode_id'] is int ? json['episode_id'] : (json['episode_id'] is String ? int.tryParse(json['episode_id']) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'watched_time': watchedTime,
      'watched_total_time': watchedTotalTime,
      'watched_time_percentage': watchedTimePercentage,
      if (seasonId != null) 'season_id': seasonId,
      if (episodeId != null) 'episode_id': episodeId,
    };
  }
}