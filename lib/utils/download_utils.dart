import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:streamit_flutter/models/download_data.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';

/// Polling Mechanism
Future<void> pollDownloadStatus({required String taskId, required Function(int progress) onProgress, required VoidCallback onComplete, required VoidCallback onFailed}) async {
  Timer.periodic(Duration(seconds: 2), (timer) async {
    final tasks = await FlutterDownloader.loadTasksWithRawQuery(query: "SELECT * FROM task WHERE task_id = '$taskId'");

    if (tasks != null && tasks.isNotEmpty) {
      final task = tasks.first;
      onProgress(task.progress);

      if (task.status == DownloadTaskStatus.complete) {
        timer.cancel();
        onComplete();
      } else if (task.status == DownloadTaskStatus.failed) {
        timer.cancel();
        onFailed();
      }
    }
  });
}

/// Helper method to check existing files for downloads
Future<bool> checkDownloadedFileExists(String fileName) async {
  try {
    final savedDir = await getDownloadDirectory();
    final file = File('$savedDir/$fileName.mp4');
    return await file.exists();
  } catch (e) {
    log('Error checking file existence: $e');
    return false;
  }
}

/// Download data model for local storage
DownloadData createDownloadData({
  required int postId,
  required String? title,
  required String? image,
  required String? description,
  required String? duration,
  required String filePath,
}) {
  final data = DownloadData(postType: null);
  data.id = postId;
  data.title = title;
  data.image = image;
  data.description = description;
  data.duration = duration;
  data.userId = getIntAsync(USER_ID);
  data.filePath = filePath;
  data.isDeleted = false;
  data.inProgress = false;
  return data;
}

/// Function for download video files
Future<String?> downloadVideo({
  required String url,
  required String fileName,
  String? directoryPath,
  bool showNotification = true,
  bool openFileFromNotification = true,
}) async {
  try {
    final hasPermission = await requestStoragePermissionForDownload();
    if (!hasPermission) {
      throw Exception('Storage permission denied');
    }

    final downloadDir = directoryPath ?? await getDownloadDirectory();
    final directory = Directory(downloadDir);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final taskId = await FlutterDownloader.enqueue(
      url: url,
      fileName: '$fileName.mp4',
      savedDir: downloadDir,
      showNotification: showNotification,
      openFileFromNotification: openFileFromNotification,
    );

    return taskId;
  } catch (e) {
    log('Video download error: $e');
    return null;
  }
}

///Download Manager Class with Isolation
class DownloadManager {
  static ReceivePort? _port;

  static Future<void> initializeDownloadManager() async {
    _port = ReceivePort();
    final isSuccess = IsolateNameServer.registerPortWithName(
      _port!.sendPort,
      'downloader_send_port',
    );

    if (!isSuccess) {
      IsolateNameServer.removePortNameMapping('downloader_send_port');
      await initializeDownloadManager();
      return;
    }

    await FlutterDownloader.registerCallback(downloadCallback);
  }

  @pragma('vm:entry-point')
  static downloadCallback(String id, int status, int percent) {
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, percent]);
  }

  static void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    _port?.close();
  }
}

/// Function to download a file using FlutterDownloader with options for notification and file opening
Future<bool> downloadFile({required String url, required String fileName, String? directoryPath, bool showNotification = true, bool openFileFromNotification = true}) async {
  try {
    // Step 1: Request storage permission (only for older Android versions)
    final hasPermission = await requestStoragePermissionForDownload();

    if (!hasPermission) {
      log('Storage permission denied. Cannot download file.');
      return false;
    }

    // Step 2: Get appropriate directory path
    final dirPath = directoryPath ?? await getDownloadDirectory();

    // Step 3: Ensure directory exists
    final directory = Directory(dirPath);
    if (!await directory.exists()) {
      try {
        await directory.create(recursive: true);
      } catch (e) {
        log('Failed to create directory: $e');
        return false;
      }
    }

    // Step 4: Download file using your existing code
    final taskId = await FlutterDownloader.enqueue(
      url: url,
      fileName: '${fileName}_invoice.pdf',
      savedDir: dirPath,
      showNotification: showNotification,
      openFileFromNotification: openFileFromNotification,
    );

    if (taskId != null) {
      log('Download started successfully');
      log('File: ${fileName}_invoice.pdf');
      log('Location: $dirPath');

      // For SDK 33+, show user where file is saved since it's in app directory
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          log('Note: File saved in app-specific directory. Use a file manager to access.');
        }
      }

      return true;
    } else {
      log('Failed to start download');
      return false;
    }
  } catch (e) {
    log('Download error: $e');
    return false;
  }
}

/// Function to check permission
Future<bool> checkPermission() async {
  if (isAndroid || isIOS) {
    if (await isAndroid12Above()) {
      return await checkDownloadPermissions();
    } else {
      Map<Permission, PermissionStatus> statuses = await [Permission.storage].request();

      bool isGranted = false;
      statuses.forEach((key, value) {
        isGranted = value.isGranted;
      });

      return isGranted;
    }
  } else {
    return false;
  }
}

///Function to check permission for downloads
Future<bool> checkDownloadPermissions() async {
  if (isIOS) {
    return true; // iOS doesn't need special permissions for app directories
  }

  try {
    // For Android 13+ (API 33+), no special permissions needed for app-specific directories
    // We can still download to app-specific external files directory
    if (await isAndroid13Above()) {
      return true; // App-specific directories don't require permissions
    }
    // For Android 11-12 (API 30-32), use app-specific directories
    else if (await isAndroid11Above()) {
      return true; // App-specific directories don't require permissions
    }
    // For Android 10 and below, request storage permission for public downloads folder
    else {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
  } catch (e) {
    log('Permission check error: $e');
    // If permission check fails, we can still use app-specific directory
    return true;
  }
}
///Helper method to check Android version
Future<bool> isAndroid11Above() async {
  if (isAndroid) {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt >= 30;
  }
  return false;
}

Future<bool> isAndroid13Above() async {
  if (isAndroid) {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt >= 33;
  }
  return false;
}
