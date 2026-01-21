import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ModelViewPage extends StatelessWidget {
  const ModelViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('3D Campus Model')),
      body: const ModelViewer(
        src: 'assets/models/campus.glb', // your model file
        alt: 'Campus 3D Model',
        autoRotate: true,
        cameraControls: true,
        backgroundColor: Colors.white,
      ),
    );
  }
}
