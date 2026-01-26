import 'package:ffmpeg_base_minitask_executer/util/font_styles.dart';
import 'package:flutter/material.dart';

@immutable
class QulitySetting extends StatefulWidget {
  double startTime;
  double duration;
  int width;
  int fps;
  Map<String, dynamic>? videoInfo;
  String quality;
  QulitySetting({
    super.key,
    required this.startTime,
    required this.duration,
    required this.width,
    required this.fps,
    this.videoInfo,
    required this.quality,
  });

  @override
  State<QulitySetting> createState() => _QulitySettingState();
}

class _QulitySettingState extends State<QulitySetting> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text("GIF Setting", style: FontStyles().fontSubTitle),
        SizedBox(height: 8),
        //set start time
        Text(
          "Start Time:  ${widget.startTime.toStringAsFixed(1)}s",
          style: FontStyles().fontBody,
        ),
        Slider(
          value: widget.startTime,
          min: 0.0,
          max: (widget.videoInfo?['duration'] ?? 10.0) - widget.duration,
          onChanged:
              (value) => setState(() {
                widget.startTime = value;
              }),
        ),
        SizedBox(height: 8),

        //set duration
        Text('Duration: ${widget.duration.toStringAsFixed(1)}s'),
        Slider(
          value: widget.duration,
          min: 1.0,
          max: 5.0,
          divisions: 90,
          onChanged: (value) => setState(() => widget.duration = value),
        ),
        SizedBox(height: 8),

        // Width
        Text('Width: ${widget.width} px'),
        Slider(
          value: widget.width.toDouble(),
          min: 240,
          max: 720,
          divisions: 16,
          onChanged: (value) => setState(() => widget.width = value.round()),
        ),
        SizedBox(height: 8),

        // FPS
        Text('FPS: ${widget.fps}'),
        Slider(
          value: widget.fps.toDouble(),
          min: 5,
          max: 30,
          divisions: 25,
          onChanged: (value) => setState(() => widget.fps = value.round()),
        ),
        SizedBox(height: 8),

        // Quality
        Text('Quality:'),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(value: 'low', label: Text('Low')),
            ButtonSegment(value: 'medium', label: Text('Medium')),
            ButtonSegment(value: 'high', label: Text('High')),
          ],
          selected: {widget.quality},
          onSelectionChanged: (Set<String> selection) {
            setState(() => widget.quality = selection.first);
          },
        ),
      ],
    );
  }
}
