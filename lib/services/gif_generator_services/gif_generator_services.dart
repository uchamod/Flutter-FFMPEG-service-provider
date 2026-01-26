import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class GifGeneratorServices {
  //video supported formats
  static const List<String> supportedFormats = [
    'mp4',
    'avi',
    'mov',
    'mkv',
    'wmv',
    'flv',
    'webm',
    'm4v',
  ];

  //generate Gif from video file
  Future<String?> generateGifFromVideo({
    required String videoPath,
    double startTime = 0.0,
    double duration = 5.0,
    int width = 480,
    int fps = 15,
    String quality = 'medium',
  }) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String outputPath = path.join(
        tempDir.path,
        'generated_gif_${DateTime.now().millisecondsSinceEpoch}.gif',
      );
      // Quality settings
      String qualityFilter = _getQualityFilter(quality, width, fps);
      // FFmpeg command to convert video to GIF
      String command =
          '-i "$videoPath" -ss $startTime -t $duration $qualityFilter "$outputPath"';

      print('FFmpeg command: $command');

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        print('GIF generated successfully: $outputPath');
        return outputPath;
      } else {
        final logs = await session.getLogs();
        print(
          'FFmpeg error: ${logs.map((log) => log.getMessage()).join('\n')}',
        );
        return null;
      }
    } catch (err) {
      print('Error generating GIF: $err');
      return null;
    }
  }

  // Get quality filter based on settings
  String _getQualityFilter(String quality, int width, int fps) {
    switch (quality.toLowerCase()) {
      case 'high':
        return '-vf "fps=$fps,scale=$width:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0';
      case 'medium':
        return '-vf "fps=$fps,scale=$width:-1:flags=lanczos" -loop 0';
      case 'low':
        return '-vf "fps=${fps ~/ 2},scale=${width ~/ 2}:-1:flags=lanczos" -loop 0';
      default:
        return '-vf "fps=$fps,scale=$width:-1:flags=lanczos" -loop 0';
    }
  }

  // Request storage permission
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      return status.isGranted;
    }
    return true; // iOS doesn't need explicit storage permission for app documents
  }

  //pick video fie from device
  static Future<String?> pickVideoFile() async {
    try {
      if (await requestStoragePermission()) {
        throw Exception('Storage permission denied');
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: supportedFormats,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        return result.files.single.path!;
      }
      return null;
    } catch (err) {
      print('Error picking file: $err');
      return null;
    }
  }

  // Download video from URL
  Future<String?> downloadVideoFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Directory tempDir = await getTemporaryDirectory();
        final String fileName =
            'downloaded_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
        final String filePath = path.join(tempDir.path, fileName);

        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        return filePath;
      } else {
        throw Exception('Failed to download video: ${response.statusCode}');
      }
    } catch (err) {
      print('Error downloading video: $err');
      return null;
    }
  }

  //Save GIF to gallery
  static Future<bool> saveGitInGallery(String gifPath) async {
    try {
      final result = await GallerySaver.saveImage(gifPath);
      return result ?? false;
    } catch (err) {
      print('Error saving GIF to gallery: $err');
      return false;
    }
  }

  // Validate video format
  bool isValidVideoFormat(String filePath) {
    String extension = path.extension(filePath).toLowerCase().substring(1);
    return supportedFormats.contains(extension);
  }

  //get video infomation
  Future<Map<String, dynamic>?> getVideoInfo(String videoPath) async {
    try {
      final command = '-i "$videoPath" -f null -';
      final session = await FFmpegKit.execute(command);
      final logs = await session.getAllLogs();

      String logString = logs.map((log) => log.getMessage()).join('\n');

      // Parse duration, resolution, etc. from logs
      RegExp durationRegex = RegExp(
        r'Duration: (\d{2}):(\d{2}):(\d{2}\.\d{2})',
      );
      RegExp resolutionRegex = RegExp(r'(\d{3,4})x(\d{3,4})');

      Match? durationMatch = durationRegex.firstMatch(logString);
      Match? resolutionMatch = resolutionRegex.firstMatch(logString);

      if (durationMatch != null) {
        int hours = int.parse(durationMatch.group(1)!);
        int minutes = int.parse(durationMatch.group(2)!);
        double seconds = double.parse(durationMatch.group(3)!);
        double totalSeconds = hours * 3600 + minutes * 60 + seconds;

        return {
          'duration': totalSeconds,
          'width':
              resolutionMatch != null
                  ? int.parse(resolutionMatch.group(1)!)
                  : null,
          'height':
              resolutionMatch != null
                  ? int.parse(resolutionMatch.group(2)!)
                  : null,
        };
      }

      return null;
    } catch (e) {
      print('Error getting video info: $e');
      return null;
    }
  }
}
