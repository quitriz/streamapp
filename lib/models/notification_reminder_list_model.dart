import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';

class NotificationReminderListModel {
  bool? status;
  String? message;
  List<ReminderList>? reminderList;

  NotificationReminderListModel({
    this.status,
    this.message,
    this.reminderList,
  });

  factory NotificationReminderListModel.fromJson(Map<String, dynamic> json) => NotificationReminderListModel(
        status: json["status"],
        message: json["message"],
        reminderList: json["data"] == null ? [] : List<ReminderList>.from(json["data"]!.map((x) => ReminderList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": reminderList == null ? [] : List<dynamic>.from(reminderList!.map((x) => x.toJson())),
      };
}

class ReminderList {
  int? id;
  String? title;
  PostType? postType;
  DateTime? addedDate;
  DateTime? releaseDate;
  String? image;
  String? url;

  ReminderList({
    this.id,
    this.title,
    this.postType,
    this.addedDate,
    this.releaseDate,
    this.image,
    this.url,
  });

  factory ReminderList.fromJson(Map<String, dynamic> json) => ReminderList(
        id: json["id"],
        title: json["title"],
        postType: (json['post_type'] != null)
            ? {
                  'movie': PostType.MOVIE,
                  'episode': PostType.EPISODE,
                  'tv_show': PostType.TV_SHOW,
                  'tvshow': PostType.TV_SHOW,
                  'video': PostType.VIDEO,
                  'live_tv': PostType.CHANNEL,
                }[json['post_type']] ??
                PostType.NONE
            : PostType.NONE,
        addedDate: _parseDateTime(json["added_date"]),
        releaseDate: parseReleaseDate((json["release_date"] ?? '').toString()),
        image: json["portrait_image"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "post_type": postType.toString(),
        "added_date": addedDate?.toIso8601String(),
        "release_date": releaseDate != null ? "${releaseDate!.year.toString().padLeft(4, '0')}-${releaseDate!.month.toString().padLeft(2, '0')}-${releaseDate!.day.toString().padLeft(2, '0')}" : null,
        "portrait_image": image,
        "url": url,
      };
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;

  final raw = value.toString().trim();
  if (raw.isEmpty) return null;

  try {
    return DateTime.parse(raw);
  } catch (e) {
    log("ReminderList: Unable to parse date `$raw` -> $e");
    return null;
  }
}
