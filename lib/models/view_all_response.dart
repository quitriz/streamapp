import 'package:streamit_flutter/models/movie_episode/common_data_list_model.dart';

class ViewAllResponse {
  List<CommonDataListModel>? data;
  bool? status;

  ViewAllResponse({this.data, this.status});

  factory ViewAllResponse.fromJson(Map<String, dynamic> json) {
    return ViewAllResponse(
      data: json['data'] != null ? (json['data'] as List).map((i) => CommonDataListModel.fromJson(i)).toList() : null,
      status: json['status'] != null ? json['status'] : false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
