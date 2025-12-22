class PlaylistResp {
  bool status;
  String message;
  List<PlaylistModel> data;

  PlaylistResp({
    this.status = false,
    this.message = "",
    this.data = const <PlaylistModel>[],
  });

  factory PlaylistResp.fromJson(Map<String, dynamic> json) {
    return PlaylistResp(
      status: json['status'] is bool ? json['status'] : false,
      message: json['message'] is String ? json['message'] : "",
      data: json['data'] is List
          ? List<PlaylistModel>.from(json['data'].map((x) => PlaylistModel.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class PlaylistModel {
  int playlistId;
  String playlistName;
  String playlistSlug;
  String image;
  String dataCount;
  String postType;
  bool isInPlaylist;
  String label;

  PlaylistModel({
    this.playlistId = -1,
    this.playlistName = "",
    this.playlistSlug = "",
    this.image = "",
    this.dataCount = "",
    this.postType = "",
    this.isInPlaylist = false,
    this.label = "",
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      playlistId: json['playlist_id'] is int ? json['playlist_id'] : -1,
      playlistName:
          json['playlist_name'] is String ? json['playlist_name'] : "",
      playlistSlug:
          json['playlist_slug'] is String ? json['playlist_slug'] : "",
      image: json['image'] is String ? json['image'] : "",
      dataCount: json['data_count'] is String ? json['data_count'] : "",
      postType: json['post_type'] is String ? json['post_type'] : "",
      isInPlaylist: json['is_in_playlist'] is bool ? json['is_in_playlist'] : false,
      label: json['label'] is String ? json['label'] : "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playlist_id': playlistId,
      'playlist_name': playlistName,
      'playlist_slug': playlistSlug,
      'image': image,
      'data_count': dataCount,
      'post_type': postType,
      'is_in_playlist': isInPlaylist,
      'label': label,
    };
  }
}
