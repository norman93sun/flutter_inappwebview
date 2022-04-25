import 'dart:html';

import 'package:flutter/services.dart';
import 'web_platform_manager.dart';
import '../in_app_webview/in_app_webview_settings.dart';
import 'in_app_web_view_web_element.dart';
import 'headless_in_app_web_view_web_element.dart';

import '../types.dart';

class HeadlessInAppWebViewManager {
  static late MethodChannel _sharedChannel;

  late BinaryMessenger _messenger;

  HeadlessInAppWebViewManager({required BinaryMessenger messenger}) {
    this._messenger = messenger;
    HeadlessInAppWebViewManager._sharedChannel = MethodChannel(
      'com.pichillilorenzo/flutter_headless_inappwebview',
      const StandardMethodCodec(),
      _messenger,
    );
    HeadlessInAppWebViewManager._sharedChannel.setMethodCallHandler(handleMethod);
  }

  Future<dynamic> handleMethod(MethodCall call) async {
    switch (call.method) {
      case "run":
        String id = call.arguments["id"];
        Map<String, dynamic> params = call.arguments["params"].cast<String, dynamic>();
        run(id, params);
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
    return null;
  }

  void run(String id, Map<String, dynamic> params) {
    var webView = InAppWebViewWebElement(viewId: id, messenger: _messenger);
    var headlessWebView = HeadlessInAppWebViewWebElement(
        id: id,
        messenger: _messenger,
        webView: webView
    );
    WebPlatformManager.webViews.putIfAbsent(id, () => webView);
    webView.iframe.style.display = 'none';
    Map<String, dynamic> initialSettings = params["initialSettings"].cast<String, dynamic>();
    if (initialSettings.isEmpty) {
      webView.initialSettings = InAppWebViewSettings();
    } else {
      webView.initialSettings = InAppWebViewSettings.fromMap(initialSettings);
    }
    webView.initialUrlRequest = URLRequest.fromMap(params["initialUrlRequest"]?.cast<String, dynamic>());
    webView.initialFile = params["initialFile"];
    webView.initialData = InAppWebViewInitialData.fromMap(params["initialData"]?.cast<String, dynamic>());
    document.body?.append(webView.iframe);
    webView.prepare();
    headlessWebView.onWebViewCreated();
    webView.makeInitialLoad();
  }
}