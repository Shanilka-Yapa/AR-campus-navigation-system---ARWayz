import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Building3DView extends StatefulWidget {
  const Building3DView({super.key});

  @override
  State<Building3DView> createState() => _Building3DViewState();
}

class _Building3DViewState extends State<Building3DView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFlutterAsset('assets/index.html');
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}