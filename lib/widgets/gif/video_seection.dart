import 'package:ffmpeg_base_minitask_executer/util/colors.dart';
import 'package:ffmpeg_base_minitask_executer/util/font_styles.dart';
import 'package:flutter/material.dart';

class VideoSeection extends StatelessWidget {
  final bool isDownloading;
  final Future<void> Function() selectVideoFromDevice;
  final Function() showUrlDialog;
  const VideoSeection({
    super.key,
    required this.isDownloading,
    required this.selectVideoFromDevice,
    required this.showUrlDialog,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Select Video",
          style: FontStyles().fontTitle.copyWith(fontSize: 16),
        ),
        SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () async {
            await selectVideoFromDevice();
          },
          label: Text("From Device", style: FontStyles().fontBody),
          icon: Icon(Icons.upload, size: 28, color: colorMercury),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorFern,
            foregroundColor: colorMercury,
            elevation: 2,
            padding: EdgeInsets.all(12),
          ),
        ),
        SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {
            showUrlDialog();
          },
          label: Text("From URL", style: FontStyles().fontBody),
          icon:
              isDownloading
                  ? LinearProgressIndicator(color: colorMercury)
                  : Icon(Icons.link, size: 28, color: colorMercury),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorFern,
            foregroundColor: colorMercury,
            elevation: 2,
            padding: EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }
}
