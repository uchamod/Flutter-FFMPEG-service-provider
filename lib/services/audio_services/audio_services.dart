import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';

class AudioServices {
  //extract audio fro video
  Future<String?> extractAudio({
    required String videoPath,
    String format = "mp3",
  }) async {
    try {
      // Get app documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String outputPath =
          '${appDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.$format';
      //get command by format
      String command;
      switch (format.toLowerCase()) {
        case 'mp3':
          command = '-i "$videoPath" -vn -acodec mp3 -ab 192k "$outputPath"';
          break;
        case 'aac':
          command = '-i "$videoPath" -vn -acodec aac -ab 192k "$outputPath"';
          break;
        case 'wav':
          command = '-i "$videoPath" -vn -acodec pcm_s16le "$outputPath"';
          break;
        case 'm4a':
          command = '-i "$videoPath" -vn -acodec aac -ab 192k "$outputPath"';
          break;
        default:
          command = '-i "$videoPath" -vn -acodec mp3 -ab 192k "$outputPath"';
      }
      //execute command on video
      print('FFmpeg command: $command');

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        print('audio generated successfully: $outputPath');
        return outputPath;
      } else {
        final logs = await session.getLogs();
        print(
          'FFmpeg error: ${logs.map((log) => log.getMessage()).join('\n')}',
        );
        return null;
      }
    } catch (err) {
        print('Error extracting audio: $err');
    }
  }
}
