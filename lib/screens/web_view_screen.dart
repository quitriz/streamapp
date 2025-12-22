import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/components/loader_widget.dart';
import 'package:streamit_flutter/main.dart';
import 'package:streamit_flutter/network/network_utils.dart';
import 'package:streamit_flutter/screens/home_screen.dart';
import 'package:webview_flutter/webview_flutter.dart' as web_view;
import 'package:webview_flutter/webview_flutter.dart';

import '../utils/resources/colors.dart' show appBackground, colorPrimary;
import 'pmp/screens/my_rentals_screen.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;
  final String? paymentType;

  WebViewScreen({required this.url, required this.title, this.paymentType});

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  Completer<web_view.WebViewController> webCont = Completer<web_view.WebViewController>();

  late final WebViewController _webViewController;

  bool fetchingFile = true;
  bool? orderDone;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  String _sanitizeUrl(String url) {
    String sanitized = url;

    try {
      sanitized = Uri.decodeFull(sanitized);
    } catch (e) {
      log('Failed to decode url: $e');
    }

    sanitized = sanitized.replaceAll('&amp;', '&');
    sanitized = sanitized.replaceAll('&#038;', '&');
    sanitized = sanitized.replaceAll('#038;', '&');
    sanitized = sanitized.replaceAll('&%23038;', '&');

    return sanitized;
  }

  Future<void> init() async {
    final sanitizedUrl = _sanitizeUrl(widget.url);
    final separator = sanitizedUrl.contains('?') && !sanitizedUrl.trim().endsWith('?') ? '&' : '?';
    final String newURL = '$sanitizedUrl${separator}HTTP_STREAMIT_WEBVIEW=true';
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true)
      ..setUserAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (msg) {},
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {},
          onPageFinished: (url) async {
            if (url.contains("membership-confirmation")) {
              setState(() {
                _isDialogShowing = true;
              });
            }
          },
          onProgress: (progress) {
            if (progress == 100) appStore.setLoading(false);
          },
          onWebResourceError: (error) {},
          onNavigationRequest: (request) async {
            return NavigationDecision.navigate;
          },
        ),
      );
      final headers = await buildTokenHeader(isWebView: true);
      log('[WEBVIEW LOAD] url: $newURL');
      log('[WEBVIEW LOAD] headers: $headers');
      _webViewController.loadRequest(
        Uri.parse(newURL),
        headers: headers,
      );
    setState(() {});
  }

  void _hideDialog() {
    setState(() {
      _isDialogShowing = false;
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _webViewController.clearLocalStorage();
    super.dispose();
  }

  Widget _buildDialog(BuildContext context) {
    return Center(
      child: AlertDialog(
        backgroundColor: appBackground,
        title: Text(language.paymentSuccessful, style: boldTextStyle(size: 20)),
        content: Text(language.yourPaymentHasBeen, style: secondaryTextStyle(size: 16)),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () async {
              _hideDialog();

              if (widget.paymentType == 'rent') {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeScreen()), (route) => false);
                await Future.delayed(Duration(milliseconds: 100));
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyRentalsScreen()),
                );
              } else {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeScreen()), (route) => false);
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: colorPrimary),
              child: Text(language.ok, style: boldTextStyle(size: 20)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        centerTitle: true,
        title: Text(widget.title.validate(), style: boldTextStyle()),
      ),
      body: Stack(
        children: [
          web_view.WebViewWidget(controller: _webViewController),
          Observer(builder: (_) => LoaderWidget().center().visible(appStore.isLoading)),
          if (_isDialogShowing) ...[
            IgnorePointer(
              ignoring: false,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: Container(color: Colors.black.withValues(alpha: 0.2), width: double.infinity, height: double.infinity),
              ),
            ),
            _buildDialog(context),
          ],
        ],
      ),
    );
  }
}