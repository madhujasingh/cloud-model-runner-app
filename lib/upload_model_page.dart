import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UploadModelPage extends StatefulWidget {
  const UploadModelPage({super.key});

  @override
  State<UploadModelPage> createState() => _UploadModelPageState();
}

class _UploadModelPageState extends State<UploadModelPage> {
  String? fileName;

  Future<void> pickModelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['h5'],
    );

    if (result != null) {
      setState(() {
        fileName = result.files.single.name;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("File selected: ${result.files.single.name}")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No file selected.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // 🌈 Header Section
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 25),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFB6E2D3), Color(0xFFF9D8D6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "CNN Model Uploader",
                    style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                      letterSpacing: 0.2,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: pickModelFile,
                    icon: const Icon(Icons.upload_rounded, color: Colors.white),
                    label: const Text(
                      "Browse File",
                      style: TextStyle(
                        fontFamily: 'SF Pro Text',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C89B8),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            // 🧾 Info Card
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Card(
                    elevation: 7,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 35),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_upload_outlined,
                              size: 85, color: Color(0xFF9C89B8)),
                          const SizedBox(height: 18),
                          const Text(
                            "Upload Your Model",
                            style: TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Select your trained .h5 file to upload and prepare it for AI testing.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'SF Pro Text',
                              color: Colors.black54,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 25),
                          if (fileName != null)
                            Column(
                              children: [
                                const Text(
                                  "Selected File:",
                                  style: TextStyle(
                                    fontFamily: 'SF Pro Text',
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF333333),
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  fileName!,
                                  style: const TextStyle(
                                    fontFamily: 'SF Pro Text',
                                    color: Color(0xFF9C89B8),
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            )
                          else
                            const Text(
                              "No file selected yet.",
                              style: TextStyle(
                                fontFamily: 'SF Pro Text',
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ✨ Footer
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                "Supported format: .h5 (Keras Model)",
                style: TextStyle(
                  fontFamily: 'SF Pro Text',
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}