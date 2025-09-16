import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageGenerationService {
  final Dio _dio = Dio();
  Future<String?> getImageUrl({
    required String prompt,
    required String aspectRatio,
  }) async {
    try {
      String? imageUrl;
      // URL encode the prompt to handle special characters and spaces
      final encodedPrompt = Uri.encodeComponent(prompt);
      final url =
          "https://www.ai4chat.co/api/image/generate?prompt=$encodedPrompt&aspect_ratio=$aspectRatio";
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final imageData = jsonDecode(response.body);
        imageUrl = imageData["image_link"];
      } else {
        print("internl server error");
      }
      return imageUrl;
    } catch (err) {
      print("failed to generate image $err");
    }
  }

  // Request storage permission
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      return status.isGranted;
    }
    return true; // iOS doesn't need explicit storage permission for app documents
  }

  Future<void> dowloadImage(
    String url,
    Function(int received, int total)? onProgress,
  ) async {
    try {
      //final hasPermission = await requestStoragePermission();
      if (await requestStoragePermission()) {
        throw Exception('Storage permission denied');
      }
      //get download directory
      Directory? downloadDir;
      if (Platform.isAndroid) {
        downloadDir = Directory("/storage/emulated/0/Download");
        if (!await downloadDir.exists()) {
          downloadDir = await getExternalStorageDirectory();
        }
      } else {
        downloadDir = await getApplicationDocumentsDirectory();
      }

      if (downloadDir == null) {
        throw Exception('Could not access download directory');
      }
      //get file name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'snap_video_$timestamp.jpeg';

      final filePath = '${downloadDir.path}/$fileName';

      // download the video
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: onProgress,
        options: Options(
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          },
        ),
      );
    } catch (err) {
      print("failed to download image $err");
    }
  }

  // {
  //   "image_link": "https://dbuzz-assets.s3.amazonaws.com/ai_image/public/fl/image-1758036404908.jpeg",
  //   "base64_output": null,
  //   "status": "success",
  //   "attempt": "second"
  // }
}
