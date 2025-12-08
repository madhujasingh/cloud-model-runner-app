import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UploadModelPage extends StatefulWidget {
  // Global model URL (required)
  static String uploadedModelUrl = "";

  // Global labels URL (OPTIONAL)
  static String? uploadedLabelsUrl;

  // custom bucket
  static const String customBucketUrl =
      "gs://ml-cloud-runner-app.firebasestorage.app";

  @override
  State<UploadModelPage> createState() => _UploadModelPageState();
}

class _UploadModelPageState extends State<UploadModelPage> {
  String? modelFileName;
  String? labelsFileName;

  bool uploadingModel = false;
  bool uploadingLabels = false;

  // General upload function (used for model + labels)
  
  Future<void> uploadToFirebase({
    required bool isModel,
    required List<String> allowedExtensions,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    if (result == null) return;

    File file = File(result.files.single.path!);
    String fileName = result.files.single.name;

    // UI update
    if (isModel) {
      modelFileName = fileName;
      uploadingModel = true;
    } else {
      labelsFileName = fileName;
      uploadingLabels = true;
    }
    setState(() {});

    try {
      final storageRef = FirebaseStorage.instance
          .refFromURL(UploadModelPage.customBucketUrl)
          .child("models/$fileName");

      final metadata =
          SettableMetadata(contentType: 'application/octet-stream');

      UploadTask uploadTask = storageRef.putFile(file, metadata);
      TaskSnapshot snap = await uploadTask;

      String downloadUrl = await snap.ref.getDownloadURL();

      // Save global URLs
      if (isModel) {
        UploadModelPage.uploadedModelUrl = downloadUrl;
      } else {
        UploadModelPage.uploadedLabelsUrl = downloadUrl; // optional
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "${isModel ? 'Model' : 'Labels'} uploaded successfully!"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    }

    if (isModel) uploadingModel = false;
    if (!isModel) uploadingLabels = false;
    setState(() {});
  }

  // ------------------------------------------------
  // UI
  // ------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Model & Labels")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Upload ML MODEL (Required)
            ElevatedButton(
              onPressed: () => uploadToFirebase(
                isModel: true,
                allowedExtensions: ['h5'],
              ),
              child: Text("Upload Model (.h5)"),
            ),
            if (uploadingModel) CircularProgressIndicator(),
            if (modelFileName != null)
              Text("Model selected: $modelFileName"),
            if (UploadModelPage.uploadedModelUrl.isNotEmpty)
              Text(
                "Model URL Ready ",
                style: TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold),
              ),

            SizedBox(height: 40),

            // Upload LABELS (.txt) 
            ElevatedButton(
              onPressed: () => uploadToFirebase(
                isModel: false,
                allowedExtensions: ['txt'],
              ),
              child: Text("Upload Labels (.txt) — Optional"),
            ),
            if (uploadingLabels) CircularProgressIndicator(),
            if (labelsFileName != null)
              Text("Labels selected: $labelsFileName"),
            if (UploadModelPage.uploadedLabelsUrl != null)
              Text(
                "Labels URL Ready ",
                style: TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.bold),
              ),

            SizedBox(height: 30),

            Text(
              "Note:\n• Uploading model is required.\n• Uploading labels is optional.\n• Without labels, prediction shows class numbers.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}