import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

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
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'arwayz-3d-view-${widget.assetPath.replaceAll(' ', '-').replaceAll('/', '-')}';
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (viewId) {
      return web.HTMLIFrameElement()
        ..src = widget.assetPath
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
