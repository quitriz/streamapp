class DeviceModel {
  bool status;
  String message;
  String? userLevel;
  List<DeviceData> data;
  Stats stats;

  DeviceModel({
    this.status = false,
    this.message = "",
    this.userLevel = "",
    this.data = const <DeviceData>[],
    required this.stats,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      status: json['status'] is bool ? json['status'] : false,
      message: json['message'] is String ? json['message'] : "",
      userLevel: json['user_level'] is String ? json['user_level'] : "",
      data: json['data'] is List
          ? List<DeviceData>.from(json['data'].map((x) => DeviceData.fromJson(x)))
          : [],
      stats: json['stats'] is Map ? Stats.fromJson(json['stats']) : Stats(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'user_level': userLevel,
      'data': data.map((e) => e.toJson()).toList(),
      'stats': stats.toJson(),
    };
  }
}

class DeviceData {
  String deviceId;
  String deviceName;
  String type;
  dynamic version;
  String model;
  String loginTime;
  String sessionCreatedAt;
  String ipAddress;
  bool isCurrentDevice;

  DeviceData({
    this.deviceId = "",
    this.deviceName = "",
    this.type = "",
    this.version,
    this.model = "",
    this.loginTime = "",
    this.sessionCreatedAt = "",
    this.ipAddress = "",
    this.isCurrentDevice = false,
  });

  factory DeviceData.fromJson(Map<String, dynamic> json) {
    return DeviceData(
      deviceId: json['device_id'] is String ? json['device_id'] : "",
      deviceName: json['device_name'] is String ? json['device_name'] : "",
      type: json['type'] is String ? json['type'] : "",
      version: json['version'],
      model: json['model'],
      loginTime: json['login_time'] is String ? json['login_time'] : "",
      sessionCreatedAt: json['session_created_at'] is String
          ? json['session_created_at']
          : "",
      ipAddress: json['ip_address'] is String ? json['ip_address'] : "",
      isCurrentDevice:
          json['is_current_device'] is bool ? json['is_current_device'] : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'device_name': deviceName,
      'type': type,
      'version': version,
      'model': model,
      'login_time': loginTime,
      'session_created_at': sessionCreatedAt,
      'ip_address': ipAddress,
      'is_current_device': isCurrentDevice,
    };
  }
}

class Stats {
  String type;
  int totalDevices;
  int totalLimit;
  int remainingSlots;

  Stats({
    this.type = "",
    this.totalDevices = -1,
    this.totalLimit = -1,
    this.remainingSlots = -1,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      type: json['type'] is String ? json['type'] : "",
      totalDevices: json['total_devices'] is int ? json['total_devices'] : -1,
      totalLimit: json['total_limit'] is int ? json['total_limit'] : -1,
      remainingSlots:
          json['remaining_slots'] is int ? json['remaining_slots'] : -1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'total_devices': totalDevices,
      'total_limit': totalLimit,
      'remaining_slots': remainingSlots,
    };
  }
}
