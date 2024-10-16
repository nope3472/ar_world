import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Furniture_screen.dart';
// Make sure this import is correct

class ItemsUploadScreen extends StatefulWidget {
  @override
  State<ItemsUploadScreen> createState() => _ItemsUploadScreenState();
}

class _ItemsUploadScreenState extends State<ItemsUploadScreen> {
  Uint8List? imageFileUint8List;
  bool isUploading = false;

  TextEditingController sellerNameTextEditingController = TextEditingController();
  TextEditingController sellerPhoneTextEditingController = TextEditingController();
  TextEditingController itemNameTextEditingController = TextEditingController();
  TextEditingController itemDescriptionTextEditingController = TextEditingController();
  TextEditingController itemPriceTextEditingController = TextEditingController();
  Future<void> removeBackground(String imagePath) async {
    const String apiKey = 'G4hot7uwJAg4Zg1FTAUScuCx'; // Replace with your actual remove.bg API key
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.remove.bg/v1.0/removebg'),
    );
    request.headers['X-Api-Key'] = apiKey;
    request.files.add(await http.MultipartFile.fromPath('image_file', imagePath));
    request.fields['size'] = 'auto'; // Set image size as auto (adjustable)

    var response = await request.send();
    if (response.statusCode == 200) {
      final responseBytes = await response.stream.toBytes();
      setState(() {
        imageFileUint8List = responseBytes; // Set the background-removed image
      });
    } else {
      print('Error removing background: ${response.statusCode}');
    }
  }

  Future<void> uploadItem() async {
    if (imageFileUint8List != null) {
      setState(() {
        isUploading = true;
      });

      try {

        // Upload image to Firebase Storage
        FirebaseStorage storage = FirebaseStorage.instance;
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference ref = storage.ref().child('items/$fileName.jpg');

        UploadTask uploadTask = ref.putData(imageFileUint8List!);
        TaskSnapshot taskSnapshot = await uploadTask;
        String imageUrl = await taskSnapshot.ref.getDownloadURL();

        // Add item details to Firestore
        DocumentReference docRef = await FirebaseFirestore.instance.collection('items').add({
          'sellerName': sellerNameTextEditingController.text,
          'sellerPhone': sellerPhoneTextEditingController.text,
          'itemName': itemNameTextEditingController.text,
          'itemDescription': itemDescriptionTextEditingController.text,
          'itemPrice': itemPriceTextEditingController.text,
          'imageUrl': imageUrl,
          'uploadTime': FieldValue.serverTimestamp(),
        }
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => HomeScreen(),
          ),
        );

        setState(() {
          isUploading = false;
          imageFileUint8List = null;
        });


        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Item uploaded successfully!'),
        ));

        // Navigate to HomeScreen

      } catch (e) {
        print("Error during upload process: $e");
        setState(() {
          isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Upload failed: $e'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select an image before uploading'),
      ));
    }
  }

  Future<void> captureImage() async {
    Navigator.of(context).pop();
    try {
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedImage != null) {
        String imagePath = pickedImage.path;
        await removeBackground(imagePath);
      }
    } catch (errorMsg) {
      print(errorMsg.toString());
      setState(() {
        imageFileUint8List = null;
      });
    }
  }

  Future<void> chooseImage() async {
    Navigator.of(context).pop();
    try {
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        String imagePath = pickedImage.path;
        await removeBackground(imagePath);
      }
    } catch (errorMsg) {
      print(errorMsg.toString());
      setState(() {
        imageFileUint8List = null;
      });
    }
  }

  Widget uploadFromScreen() {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text(
          "ADD NEW ITEM",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              uploadItem();
            },
            icon: const Icon(
              Icons.cloud_upload,
              color: Colors.white,
            ),
          )
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          isUploading == true
              ? const LinearProgressIndicator(
            color: Colors.pinkAccent,
          )
              : Container(),
          SizedBox(
            height: 230,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: imageFileUint8List != null
                  ? Container(
                color: Colors.black,
                child: Image.memory(imageFileUint8List!),
              )
                  : const Icon(
                Icons.image_not_supported,
                color: Colors.grey,
                size: 40,
              ),
            ),
          ),
          const Divider(
            color: Colors.white70,
            thickness: 2,
          ),
          ListTile(
            leading: const Icon(
              Icons.person_pin_rounded,
              color: Colors.white,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                style: const TextStyle(color: Colors.grey),
                controller: sellerNameTextEditingController,
                decoration: const InputDecoration(
                  hintText: "Seller Name",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
          const Divider(color: Colors.white70, thickness: 1),
          ListTile(
            leading: const Icon(
              Icons.title,
              color: Colors.white,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                style: const TextStyle(color: Colors.grey),
                controller: itemNameTextEditingController,
                decoration: const InputDecoration(
                  hintText: "Item Name",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
          const Divider(color: Colors.white70, thickness: 1),
          ListTile(
            leading: const Icon(
              Icons.phone_iphone_rounded,
              color: Colors.white,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                style: const TextStyle(color: Colors.grey),
                controller: sellerPhoneTextEditingController,
                decoration: const InputDecoration(
                  hintText: "Seller Phone",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
          const Divider(color: Colors.white70, thickness: 1),
          ListTile(
            leading: const Icon(
              Icons.price_check,
              color: Colors.white,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                style: const TextStyle(color: Colors.grey),
                controller: itemPriceTextEditingController,
                decoration: const InputDecoration(
                  hintText: "Item Price",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
          const Divider(color: Colors.white70, thickness: 1),
          ListTile(
            leading: const Icon(
              Icons.description,
              color: Colors.white,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                style: const TextStyle(color: Colors.grey),
                controller: itemDescriptionTextEditingController,
                decoration: const InputDecoration(
                  hintText: "Item Description",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
          const Divider(color: Colors.white70, thickness: 1),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.camera),
                          title: const Text("Capture Image"),
                          onTap: captureImage,
                        ),
                        ListTile(
                          leading: const Icon(Icons.image),
                          title: const Text("Choose from Gallery"),
                          onTap: chooseImage,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: const Text("Select Image"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return uploadFromScreen();
  }
}