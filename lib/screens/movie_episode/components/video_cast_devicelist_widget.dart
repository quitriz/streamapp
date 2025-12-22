import 'package:cast/cast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/cached_image_widget.dart';
import 'package:streamit_flutter/main.dart';

/// Helper function to show the cast device list as a bottom sheet
void showCastDeviceBottomSheet({
  required BuildContext context,
  required String videoURL,
  required String videoTitle,
  required String videoImage,
}) {
  showModalBottomSheet(
    context: context,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.5,
      minHeight: MediaQuery.of(context).size.height * 0.3,
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => VideoCastDeviceListScreen(
      videoURL: videoURL,
      videoTitle: videoTitle,
      videoImage: videoImage,
    ),
  );
}

class VideoCastDeviceListScreen extends StatefulWidget {
  final String videoURL;
  final String videoTitle;
  final String videoImage;

  const VideoCastDeviceListScreen({
    Key? key,
    required this.videoURL,
    required this.videoTitle,
    required this.videoImage,
  }) : super(key: key);

  @override
  State<VideoCastDeviceListScreen> createState() =>
      _VideoCastDeviceListScreenState();
}

class _VideoCastDeviceListScreenState extends State<VideoCastDeviceListScreen> {
  @override
  void initState() {
    super.initState();
    _searchCastDevices();
  }

  Future<void> _searchCastDevices() async {
    appStore.setSearchingCastDevices(true);
    appStore.setCastSearchError(null);

    try {
      final devices = await CastDiscoveryService().search();
      appStore.setAvailableCastDevices(devices);
    } catch (e) {
      appStore.setCastSearchError(e.toString());
    } finally {
      appStore.setSearchingCastDevices(false);
    }
  }

  Future<void> _connectAndPlayMedia(
      BuildContext context, CastDevice object) async {
    appStore.setCastConnecting(true);
    appStore.setCastConnectionError(null);

    try {
      final session = await CastSessionManager().startSession(object);
      appStore.setCastSession(session);
      appStore.setCastDevice(object);

      session.stateStream.listen((state) {
        if (state == CastSessionState.connected) {
          final snackBar = SnackBar(
              content: Text(language.deviceConnectedSuccessfully,
                  style: primaryTextStyle()));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          appStore.setCastConnected(true);
          appStore.setCastConnecting(false);
        } else if (state == CastSessionState.closed) {
          _closeConnection();
        }
      });

      var index = 0;

      session.messageStream.listen((message) {
        index += 1;

        log('index: $index');
        log('receive message: $message');

        if (index == 2) {
          Future.delayed(const Duration(seconds: 5)).then((x) {
            _sendMessagePlayVideo(session);
          });
        }
      });

      session.sendMessage(CastSession.kNamespaceReceiver, {
        'type': 'LAUNCH',
        'appId': 'CC1AD845',
      });
    } catch (e) {
      appStore.setCastConnectionError(e.toString());
      appStore.setCastConnecting(false);
    }
  }

  void _sendMessagePlayVideo(CastSession session) {
    log('_sendMessagePlayVideo');

    var message = {
      'contentId': widget.videoURL,
      'contentType': 'video/mp4',
      'streamType': 'BUFFERED',
      'metadata': {
        'type': 0,
        'metadataType': 0,
        'title': widget.videoTitle,
        'images': [
          {'url': widget.videoImage}
        ]
      }
    };

    session.sendMessage(CastSession.kNamespaceMedia, {
      'type': 'LOAD',
      'autoPlay': true,
      'currentTime': 0,
      'media': message,
    });
  }

  Future<void> _closeConnection() async {
    if (appStore.castSession != null) {
      appStore.castSession!.close();
    }
    appStore.resetCastState();
  }

  Future<void> closeConnection(BuildContext context) async {
    appStore.setCastDisconnecting(true);

    try {
      await _closeConnection();
      final snackBar =
          SnackBar(content: Text(language.deviceDisconnectedSuccessfully));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } finally {
      appStore.setCastDisconnecting(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.cast, color: context.primaryColor),
                  8.width,
                  Text(
                    "${language.cast} ${widget.videoTitle}",
                    style: boldTextStyle(size: 18),
                  ).expand(),
                  if (appStore.hasCastDevice)
                    IconButton(
                      onPressed: () => closeConnection(context),
                      icon: Icon(Icons.close, color: Colors.red),
                    ),
                ],
              ),
            ),
            Divider(height: 1),
            // Content
            Expanded(
              child: Column(
                children: [
                  if (appStore.hasCastDevice)
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          CachedImageWidget(
                            url: widget.videoImage,
                            width: context.width() - 32,
                            height: 200,
                          ),
                          16.height,
                          AppButton(
                            text: language.closeConnection,
                            textStyle: boldTextStyle(),
                            color: context.primaryColor,
                            onTap: () {
                              closeConnection(context);
                            },
                          )
                        ],
                      ),
                    )
                  else
                    Expanded(
                      child: _buildCastDeviceList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCastDeviceList() {
    if (appStore.isSearchingCastDevices) {
      return Center(
        child: CircularProgressIndicator(color: context.primaryColor),
      );
    }

    if (appStore.hasCastError) {
      return Center(child: ErrorWidget(appStore.castErrorMessage.toString()));
    }

    if (!appStore.hasAvailableCastDevices) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(language.noCastingDeviceFounded,
                style: boldTextStyle(color: context.primaryColor)),
            16.height,
            AppButton(
              onTap: () => _searchCastDevices(),
              text: language.refresh,
              textStyle: boldTextStyle(color: Colors.white),
              color: context.primaryColor,
            )
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(language.castDeviceList, style: boldTextStyle()),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: appStore.availableCastDevices.length,
            itemBuilder: (ctx, index) {
              final device = appStore.availableCastDevices[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: context.primaryColor,
                  child: Text("${index + 1}",
                      style: boldTextStyle(color: Colors.white)),
                ),
                title: Text(device.name, style: primaryTextStyle()),
                onTap: () async {
                  _connectAndPlayMedia(context, device);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
