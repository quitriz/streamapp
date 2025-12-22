class RestrictSubscriptionPlan {
  String? planId;
  String? label;

  RestrictSubscriptionPlan({this.planId, this.label});

  factory RestrictSubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return RestrictSubscriptionPlan(planId: json['id'].toString(), label: json['label']);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.planId;
    data['label'] = this.label;
    return data;
  }
}

class CommonDataModel {
  int? count;
  List<CommonDataDetailsModel>? data;

  CommonDataModel({this.count, this.data});

  factory CommonDataModel.fromJson(Map<String, dynamic> json) {
    return CommonDataModel(
      count: json['count'],
      data: json['data'] != null ? (json['data'] as List).map((i) => CommonDataDetailsModel.fromJson(i)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CommonDataDetailsModel {
  String? id;
  String? name;
  String? releaseDate;
  String? image;
  bool? isUpcoming;
  bool? isRemind;

  CommonDataDetailsModel({this.id, this.name, this.releaseDate, this.image, this.isUpcoming, this.isRemind});

  factory CommonDataDetailsModel.fromJson(Map<String, dynamic> json) {
    // Handle is_upcoming as boolean, string, or null
    bool isUpcomingValue = false;
    if (json['is_upcoming'] != null) {
      if (json['is_upcoming'] is bool) {
        isUpcomingValue = json['is_upcoming'] as bool;
      } else if (json['is_upcoming'] is String) {
        isUpcomingValue = json['is_upcoming'].toString().toLowerCase() == 'true';
      } else if (json['is_upcoming'] is int) {
        isUpcomingValue = json['is_upcoming'] == 1;
      }
    }
    
    return CommonDataDetailsModel(
      id: json['id'].toString(),
      name: json['name'],
      releaseDate: json['release_date'],
      image: json['image'],
      isUpcoming: isUpcomingValue,
      isRemind: json['is_remind'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['release_date'] = this.releaseDate;
    data['image'] = this.image;
    data['is_upcoming'] = this.isUpcoming;
    data['is_remind'] = this.isRemind;

    return data;
  }
}
