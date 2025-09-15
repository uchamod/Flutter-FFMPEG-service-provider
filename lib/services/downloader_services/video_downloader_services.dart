import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoDownloaderServices {
  final Dio _dio = Dio();
  Future<Map<String, dynamic>?> getDownloadLink({
    required String videoLink,
    required double mediaType,
  }) async {
    String? videoUrl;
    String? tubnail;
    try {
      String baseUrl = _endUrlByMediaType(mediaType);
      //yt
      if (mediaType == 1) {
        final response = await http.post(
          Uri.parse(baseUrl),
          body: {"url": videoLink},
        );
        if (response.statusCode == 200) {
          final videoData = jsonDecode(response.body);
          videoUrl = videoData["medias"][3]["url"];
          tubnail = videoData["thumbnail"];
        }
        //tiktok
      } else if (mediaType == 2) {
        final response = await http.get(
          Uri.parse(baseUrl).replace(queryParameters: {"url": videoLink}),
        );
        if (response.statusCode == 200) {
          final videoData = jsonDecode(response.body);
          videoUrl = videoData["resp"] ?? "";
          tubnail = "";
        }
        //insta
      } else {
        final response = await http.post(
          Uri.parse(baseUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "url": videoLink,
            "platform": "instagram",
            "type": "video",
          }),
        );
        if (response.statusCode == 200) {
          final videoData = jsonDecode(response.body);
          videoUrl = videoData["url"] ?? "";
          tubnail = videoData["data"]["thumb"] ?? "";
        }
      }
      if (videoUrl == null) {
        print("cannot found video url");
        return {};
      }
      return {"videoUrl": videoUrl, "thumb": tubnail};
    } catch (err) {
      print("fail to download video from resource $err");
      return {};
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

  Future<String?> downloadVideo({
    required String videoUrl,
    required String fileName,
    Function(int received, int total)? onProgress,
  }) async {
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

      final filePath = '${downloadDir.path}/$fileName';

      //download the video
      await _dio.download(
        videoUrl,
        filePath,
        onReceiveProgress: onProgress,
        options: Options(
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          },
        ),
      );
      return filePath;
    } catch (err) {
      print('Error downloading video: $err');
      return null;
    }
  }

  //complete download progrss
  Future<String?> completeDownloadSession({
    required String videoLink,
    required double media,
    Function(int received, int total)? onProgress,
  }) async {
    try {
      //get downlloadable url
      final videoInfo = await getDownloadLink(
        videoLink: videoLink,
        mediaType: media,
      );
      if (videoInfo == null) {
        throw Exception('Failed to get video information');
      }
      //get file name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'snap_video_$timestamp.mp4';

      //download video
      final file = await downloadVideo(
        videoUrl: videoInfo["videoUrl"],
        fileName: fileName,
        onProgress: onProgress,
      );

      return file;
    } catch (err) {
      print('Error in complete download process: $err');
      return null;
    }
  }

  //select base url
  String _endUrlByMediaType(double type) {
    switch (type) {
      case 1:
        return "https://www.clipto.com/api/youtube";
      case 2:
        return "https://lucicodes.x10.mx/api/tiktokDL/";
      case 3:
        return "https://bff.listnr.tech/backend/user/getInfoYT";
      default:
        return "https://www.clipto.com/api/youtube";
    }
  }
}
