import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'upload_model_page.dart'; 

class PredictPage extends StatefulWidget {
  const PredictPage({super.key});

  @override
  State<PredictPage> createState() => _PredictPageState();
}

class _PredictPageState extends State<PredictPage> {
  File? imageFile;
  String? predictionResult;
  bool loading = false;

  // Backend endpoint on Render
  final String backendUrl = "https://cloud-model-runner-app.onrender.com/predict";

  Future pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
        predictionResult = null;
      });
    }
  }

  Future predictImage() async {
    if (imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select an image first.")),
      );
      return;
    }

    if (UploadModelPage.uploadedModelUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please upload a model first.")),
      );
      return;
    }

    setState(() {
      loading = true;
      predictionResult = null;
    });

    try {
      var request = http.MultipartRequest("POST", Uri.parse(backendUrl));

      // REQUIRED 
      request.fields["model_url"] = UploadModelPage.uploadedModelUrl;

      // OPTIONAL 
      if (UploadModelPage.uploadedLabelsUrl != null) {
        request.fields["labels_url"] = UploadModelPage.uploadedLabelsUrl!;
      }

      // IMAGE file
      request.files.add(await http.MultipartFile.fromPath(
        "image",
        imageFile!.path,
      ));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      var data = json.decode(responseBody);

      setState(() {
        predictionResult = jsonEncode(data, toEncodable: (object) => object.toString());
      });
    } catch (e) {
      setState(() {
        predictionResult = "Error: $e";
      });
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Predict Image"),
        backgroundColor: const Color.fromARGB(255, 219, 180, 193),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // IMAGE PICKER
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color.fromARGB(255, 230, 187, 201)),
                ),
                child: imageFile == null
                    ? Center(child: Text("Tap to select image"))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(imageFile!, fit: BoxFit.cover),
                      ),
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: predictImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 141, 121, 128),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Predict", style: TextStyle(fontSize: 16)),
            ),

            SizedBox(height: 20),

            if (loading) CircularProgressIndicator(),

            if (predictionResult != null)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Result:\n$predictionResult",
                  style: TextStyle(fontSize: 16),
                ),
              ),

            SizedBox(height: 20),

            // INFO
            Text(
              "If no labels file is uploaded, prediction shows class numbers (0,1,2...).",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}