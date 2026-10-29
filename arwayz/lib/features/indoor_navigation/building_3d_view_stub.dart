import 'package:flutter/material.dart';

class Building3DView extends StatelessWidget {
  final String assetPath;

  const Building3DView({
    super.key,
    this.assetPath = 'assets/index.html',
  });

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('3D building view is not supported here.'));
  }
}
