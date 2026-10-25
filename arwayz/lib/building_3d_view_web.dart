import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class Building3DView extends StatefulWidget {
  const Building3DView({super.key});

  @override
  State<Building3DView> createState() => _Building3DViewState();
}

class _Building3DViewState extends State<Building3DView> {
  static const _viewType = 'arwayz-building-3d-view';
  static bool _viewFactoryRegistered = false;

  @override
  void initState() {
    super.initState();
    if (!_viewFactoryRegistered) {
      ui_web.platformViewRegistry.registerViewFactory(_viewType, (viewId) {
        return web.HTMLIFrameElement()
          ..src = 'assets/assets/index.html'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
      });
      _viewFactoryRegistered = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const HtmlElementView(viewType: _viewType);
  }
}