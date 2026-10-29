import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Building3DView extends StatefulWidget {
  final String assetPath;

  const Building3DView({
    super.key,
    this.assetPath = 'assets/index.html',
  });

  @override
  State<Building3DView> createState() => _Building3DViewState();
}

class _Building3DViewState extends State<Building3DView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    _loadAsset();
  }

  Future<void> _loadAsset() async {
    try {
      var html = await rootBundle.loadString(widget.assetPath);
      if (widget.assetPath == 'assets/civil 3d view.html') {
        html = _addCivilMobileLayout(html);
      }
      await _controller.loadHtmlString(html);
    } catch (error) {
      if (!mounted) {
        return;
      }
      await _controller.loadHtmlString(
        '<html><body><p>Unable to load the 3D building view.</p></body></html>',
      );
      debugPrint('Failed to load 3D building asset ${widget.assetPath}: $error');
    }
  }

  String _addCivilMobileLayout(String html) {
    const mobileStyle = '''
<style id="arwayz-mobile-civil-layout">
@media (max-width: 600px) {
  body > .relative.z-10 {
    padding: 8px !important;
  }

  body > .relative.z-10 > header {
    align-items: flex-start !important;
  }

  body > .relative.z-10 > header > div:first-child {
    max-width: calc(100vw - 112px) !important;
    padding: 10px !important;
    border-left-width: 3px !important;
  }

  body > .relative.z-10 > header h1 {
    font-size: 15px !important;
    line-height: 1.2 !important;
  }

  body > .relative.z-10 > header p,
  body > .relative.z-10 > header .text-xs {
    display: none !important;
  }

  body > .relative.z-10 > header > div:last-child {
    gap: 4px !important;
  }

  body > .relative.z-10 > header button {
    padding: 9px !important;
  }

  #interaction-hint {
    display: none !important;
  }

  body > .relative.z-10 > div.flex.flex-col {
    position: absolute !important;
    right: 8px !important;
    bottom: 8px !important;
    left: 8px !important;
    gap: 6px !important;
    align-items: stretch !important;
  }

  body > .relative.z-10 > div.flex.flex-col > div:first-child {
    width: 100% !important;
    max-height: 188px !important;
    overflow: hidden !important;
    padding: 8px !important;
  }

  body > .relative.z-10 > div.flex.flex-col > div:first-child > div.flex.flex-row {
    display: flex !important;
    height: 74px !important;
    overflow-x: auto !important;
    overflow-y: hidden !important;
    flex-wrap: nowrap !important;
    align-items: stretch !important;
  }

  body > .relative.z-10 > div.flex.flex-col > div:first-child .floor-btn {
    min-width: 118px !important;
    min-height: 62px !important;
    display: flex !important;
    white-space: nowrap !important;
  }

  body > .relative.z-10 > div.flex.flex-col > div:nth-child(2) {
    align-self: center !important;
    max-width: 100% !important;
    overflow-x: auto !important;
    transform: scale(0.9) !important;
    transform-origin: center bottom !important;
  }

  body > .relative.z-10 > div.flex.flex-col > div:nth-child(3) {
    display: none !important;
  }
}
</style>
''';
    final headEnd = html.indexOf('</head>');
    if (headEnd == -1) {
      return '$mobileStyle$html';
    }
    return '${html.substring(0, headEnd)}$mobileStyle${html.substring(headEnd)}';
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
