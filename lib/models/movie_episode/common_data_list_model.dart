import 'package:streamit_flutter/models/live_tv/live_channel_detail_model.dart';
import 'package:streamit_flutter/models/resume_video_model.dart';
import 'package:streamit_flutter/utils/constants.dart';

class CommonDataListModel {
  int? id;
  String? title;
  String? image;
  PostType postType;
  String? characterName;
  String? releaseYear;
  String? shareUrl;
  String? runTime;
  ContinueWatchModel? watchedDuration;
  String? trailerLink;
  String? file;
  String? episodeFile;
  String? attachment;
  String? releaseDate;
  String? category;
  String? description;
  String? trailerLinkType;
  String? channelStreamType;
  String? portraitImage;
  bool? isUpcoming;
  bool? userHasAccess;
  bool? isLiked;
  bool? isRent;
  bool? isRented;
  String? rentInfo;
  String? purchaseType;
  int? price;
  String? discount;
  int? discountedPrice;
  String? validity;
  List<String>? requiredPlan;
  AdConfiguration? adConfiguration;
  List<String>? genre;
  bool? isRemind;

  CommonDataListModel({
    this.id,
    this.title,
    this.image,
    required this.postType,
    this.characterName,
    this.releaseYear,
    this.shareUrl,
    this.runTime,
    this.watchedDuration,
    this.trailerLink,
    this.file,
    this.episodeFile,
    this.attachment,
    this.releaseDate,
    this.category,
    this.description,
    this.trailerLinkType,
    this.channelStreamType,
    this.portraitImage,
    this.isUpcoming,
    this.adConfiguration,
    this.userHasAccess = false,
    this.isLiked = false,
    this.isRent = false,
    this.isRented = false,
    this.rentInfo,
    this.purchaseType = '',
    this.price,
    this.discount,
    this.discountedPrice,
    this.validity,
    this.requiredPlan,
    this.genre,
    this.isRemind,
  });

  factory CommonDataListModel.fromJson(Map<String, dynamic> json) {
    bool? isUpcomingFlag = json['is_upcoming'];
    DateTime? _parseDate(String? value) {
      if (value == null || value.toString().trim().isEmpty) return null;
      if (value.length == 4 && int.tryParse(value) != null) {
        return DateTime.tryParse('$value-01-01');
      }
      return DateTime.tryParse(value);
    }

    if (isUpcomingFlag == null) {
      final DateTime now = DateTime.now();
      DateTime? releaseDate = _parseDate(json['release_date']);
      releaseDate ??= _parseDate(json['release_year']);

      if (releaseDate != null) {
        isUpcomingFlag = releaseDate.isAfter(now);
      } else {
        isUpcomingFlag = false;
      }
    }

    return CommonDataListModel(
      id: json['id'],
      title: json['title'],
      image: json['thumbnail_image'],
      postType: (json['post_type'] != null)
          ? {
                'movie': PostType.MOVIE,
                'episode': PostType.EPISODE,
                'tv_show': PostType.TV_SHOW,
                'video': PostType.VIDEO,
                'live_tv': PostType.CHANNEL,
              }[json['post_type']] ??
              PostType.NONE
          : PostType.NONE,
      characterName: json['character_name'],
      releaseYear: json['release_year'],
      shareUrl: json['share_url'],
      runTime: json['run_time'],
      watchedDuration: json['watched_duration'] != null
          ? ContinueWatchModel.fromJson(json['watched_duration'])
          : null,
      trailerLink: json['trailer_link'],
      file: json['post_type'] != null
          ? json['post_type'] == 'movie'
              ? json['movie_file']
              : json['post_type'] == 'video'
                  ? json['video_file']
                  : null
          : null,
      episodeFile: json['episode_file'],
      attachment: json['attachment'],
      releaseDate: json['release_date'],
      trailerLinkType: json["trailer_link_type"],
      channelStreamType: json['stream_type'],
      portraitImage: json['portrait_image'],
      isUpcoming: isUpcomingFlag,
      adConfiguration: json['ad_configuration'] != null
          ? AdConfiguration.fromJson(json['ad_configuration'])
          : null,
      userHasAccess: json['user_has_access'] ?? false,
      isLiked: json['is_liked'] ?? false,
      isRent: json['is_rent'] ?? false,
      isRented: json['is_rented'] ?? false,
      rentInfo: json['rent_info'],
      purchaseType: json['purchase_type'] ?? '',
      price: json['price'],
      discount: json['discount'],
      discountedPrice: json['discounted_price'],
      validity: json['validity'],
      requiredPlan: json['required_plan'],
      genre: json["genre"] == null ? [] : List<String>.from(json["genre"]!.map((x) => x)),
      isRemind: json['is_remind'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['thumbnail_image'] = this.image;
    data['postType'] = this.postType.toString();
    data['character_name'] = this.characterName;
    data['release_year'] = this.releaseYear;
    data['share_url'] = this.shareUrl;
    data['run_time'] = this.runTime;
    if (this.watchedDuration != null) {
      data['watched_duration'] = this.watchedDuration!.toJson();
    }
    data['trailer_link'] = this.trailerLink;
    data["trailer_link_type"] = this.trailerLinkType;
    if (this.postType == PostType.MOVIE) {
      data['movie_file'] = this.file;
    } else if (this.postType == PostType.VIDEO) {
      data['video_file'] = this.file;
    }
    data['episode_file'] = this.episodeFile;
    data['attachment'] = this.attachment;
    data['release_date'] = this.releaseDate;
    data['stream_type'] = this.channelStreamType;
    data['portrait_image'] = this.portraitImage;
    data['is_upcoming'] = this.isUpcoming;
    data['is_rent'] = this.isRent;
    data['user_has_access'] = this.userHasAccess;
    data['is_liked'] = this.isLiked;
    data['is_rented'] = this.isRented;
    data['rent_info'] = this.rentInfo;
    data['purchase_type'] = this.purchaseType;
    data['price'] = this.price;
    data['discount'] = this.discount;
    data['discounted_price'] = this.discountedPrice;
    data['validity'] = this.validity;
    data['required_plan'] = this.requiredPlan;
    if (this.adConfiguration != null) {
      data['ad_configuration'] = this.adConfiguration!.toJson();
    }
    data['genre'] = this.genre;
    data['is_remind'] = this.isRemind;
    return data;
  }
}

class RecentSearchListModel {
  int? id;
  String? term;
  String? timeStamp;

  RecentSearchListModel(
      {required this.id, required this.term, required this.timeStamp});
  factory RecentSearchListModel.fromJson(Map<String, dynamic> json) {
    return RecentSearchListModel(
      id: json['id'],
      term: json['term'],
      timeStamp: json['timestamp'],
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['term'] = this.term;
    data['timestamp'] = this.timeStamp;
    return data;
  }
}
