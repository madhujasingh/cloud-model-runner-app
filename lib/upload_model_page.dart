import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UploadModelPage extends StatefulWidget {
  static String uploadedModelUrl = ""; // URL stored here

  const UploadModelPage({super.key});

  @override
  State<UploadModelPage> createState() => _UploadModelPageState();
}

class _UploadModelPageState extends State<UploadModelPage> {
  String? fileName;
  bool isUploading = false;

  Future<void> pickAndUploadModel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['h5'],
    );

    if (result == null) return;

    File file = File(result.files.single.path!);
    fileName = result.files.single.name;

    setState(() => isUploading = true);

    try {
      final ref = FirebaseStorage.instance.ref().child("models/$fileName");
      UploadTask task = ref.putFile(file);
      TaskSnapshot snap = await task;

      String downloadUrl = await snap.ref.getDownloadURL();
      UploadModelPage.uploadedModelUrl = downloadUrl;

      setState(() => isUploading = false);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Model uploaded successfully!")));

      setState(() {});
    } catch (e) {
      setState(() => isUploading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Upload failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Model to Firebase")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickAndUploadModel,
              child: Text("Select & Upload Model"),
            ),
            SizedBox(height: 20),
            if (isUploading) CircularProgressIndicator(),
            if (!isUploading && fileName != null)
              Column(
                children: [
                  Text("Uploaded Model: $fileName"),
                  SizedBox(height: 10),
                  Text("Model URL:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(UploadModelPage.uploadedModelUrl),
                ],
              ),
          ],
        ),
      ),
    );
  }
}