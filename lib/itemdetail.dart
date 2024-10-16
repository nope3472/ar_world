import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:camera/camera.dart';

class ItemDetailScreen extends StatelessWidget {
  final String itemId;
  const ItemDetailScreen({Key? key, required this.itemId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item Details'),
        backgroundColor: const Color(0xFFFFCC00),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('items').doc(itemId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Item not found'));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.network(
                    data['imageUrl'],
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  data['itemName'],
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text('Price: ${data['itemPrice']}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text('Description: ${data['itemDescription']}'),
                SizedBox(height: 20),
                Text('Seller Information:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Name: ${data['sellerName']}'),
                Text('Phone: ${data['sellerPhone']}'),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    child: Text('Try using AR'),
                    onPressed: () => _openCameraView(context, data['imageUrl']),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black, backgroundColor: const Color(0xFFFFCC00),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openCameraView(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CameraViewScreen(imageUrl: imageUrl),
      ),
    );
  }
}

class CameraViewScreen extends StatefulWidget {
  final String imageUrl;

  const CameraViewScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  _CameraViewScreenState createState() => _CameraViewScreenState();
}

class _CameraViewScreenState extends State<CameraViewScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  // Zoom and Rotation
  double _scale = 1.0;
  double _previousScale = 1.0;
  double _rotation = 0.0;
  Offset _position = Offset(0, 0); // Initial position for dragging

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller!.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AR View'),
        backgroundColor: const Color(0xFFFFCC00),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return GestureDetector(
              onScaleStart: (details) {
                _previousScale = _scale;
              },
              onScaleUpdate: (details) {
                setState(() {
                  _scale = (_previousScale * details.scale).clamp(0.5, 3.0);
                  // Update position based on translation
                  if (details.focalPoint != Offset.zero) {
                    _position = details.focalPoint - Offset(75, 75); // Adjust for the center of the image
                  }
                  _rotation = details.rotation; // Update rotation
                });
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(_controller!),
                  Positioned(
                    left: _position.dx,
                    top: _position.dy,
                    child: Transform(
                      transform: Matrix4.identity()
                        ..scale(_scale) // Apply zoom
                        ..rotateZ(_rotation), // Apply rotation
                      alignment: FractionalOffset.center, // Center the transformation
                      child: Image.network(
                        widget.imageUrl,
                        fit: BoxFit.cover,
                        height: 150, // Set a base height for the image
                        width: 150,  // Set a base width for the image
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
