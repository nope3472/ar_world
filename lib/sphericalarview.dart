import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ArSpherical extends StatefulWidget {
  const ArSpherical({super.key});

  @override
  _ArSphericalState createState() => _ArSphericalState();
}

class _ArSphericalState extends State<ArSpherical> {
  late ARKitController arkitController;

  @override
  void initState() {
    super.initState();
  }

  void onARViewCreated(ARKitController controller) {
    arkitController = controller;
    _addSphere();
  }

  void _addSphere() {
    final material = ARKitMaterial(
      diffuse: ARKitMaterialProperty.image('lib/images/image.webp'),
      doubleSided: true,
    );

    final sphere = ARKitSphere(
      materials: [material],
      radius: 1,
    );

    final node = ARKitNode(
      geometry: sphere,
      position: vector.Vector3(0, 0, -1), // Adjust the position as needed
    );

    arkitController.add(node);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Experience AR Scenarios"),
      ),
      body: ARKitSceneView(
        onARKitViewCreated: onARViewCreated,
      ),
    );
  }

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }
}
