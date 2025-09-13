import 'dart:io';

import 'package:ffmpeg_base_minitask_executer/routes/router_names.dart';
import 'package:ffmpeg_base_minitask_executer/services/gif_generator_services/gif_generator_services.dart';
import 'package:ffmpeg_base_minitask_executer/util/colors.dart';
import 'package:ffmpeg_base_minitask_executer/util/constants.dart';
import 'package:ffmpeg_base_minitask_executer/util/font_styles.dart';
import 'package:ffmpeg_base_minitask_executer/widgets/gif/qulity_setting.dart';
import 'package:ffmpeg_base_minitask_executer/widgets/gif/video_seection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

class GifGeneratoePage extends StatefulWidget {
  const GifGeneratoePage({super.key});

  @override
  State<GifGeneratoePage> createState() => _GifGeneratoePageState();
}

class _GifGeneratoePageState extends State<GifGeneratoePage> {
  final GifGeneratorServices _gifGeneratorServices = GifGeneratorServices();
  VideoPlayerController? _videoPlayerController;
  final TextEditingController _urlController = TextEditingController();
  //resource paths
  String? _selectedVideoPath;
  String? _generatevideoPath;
  Map<String, dynamic>? _videoInfo;
  //status tracking
  bool _isProcessing = false;
  bool _isDownloading = false;
  double _progress = 0.0;

  // GIF Settings
  double _startTime = 0.0;
  double _duration = 5.0;
  int _width = 480;
  int _fps = 15;
  String _quality = 'medium';
  //select video from device
  Future<void> _selectVideoFromDevice() async {
    try {
      // await _gifGeneratorServices.requestStoragePermission();
      final videoPath = await _gifGeneratorServices.pickVideoFile();
      if (videoPath != null) {
        setState(() {
          _selectedVideoPath = videoPath;
          _generatevideoPath = null;
        });
        _videoPlayerController?.dispose();
        _videoPlayerController = VideoPlayerController.file(File(videoPath));
        await _videoPlayerController!.initialize();

        _videoInfo = await _gifGeneratorServices.getVideoInfo(videoPath);
        setState(() {
          if (_videoInfo != null) {
            _startTime = 0.0;
            _duration = (_videoInfo!['duration'] as double).clamp(1.0, 5.0);
          }
        });
      }
    } catch (err) {
      print("cannot fetch video from device $err");
    }
  }

  //video popup
  void _showUrlDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Enter Video URL'),
            content: TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: 'https://example.com/video.mp4',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _downloadVideoFromUrl,
                child: Text('Download'),
              ),
            ],
          ),
    );
  }

  //download video from Url
  Future<void> _downloadVideoFromUrl() async {
    Navigator.pop(context);
    if (_urlController.text.isEmpty) return;

    setState(() {
      _isDownloading = true;
    });

    final videoPath = await _gifGeneratorServices.downloadVideoFromUrl(
      _urlController.text.trim(),
    );

    setState(() {
      _isDownloading = false;
    });

    if (videoPath != null) {
      setState(() {
        _selectedVideoPath = videoPath;
        _generatevideoPath = null;
      });
      _videoPlayerController?.dispose();
      _videoPlayerController = VideoPlayerController.file(File(videoPath));
      await _videoPlayerController!.initialize();

      _urlController.clear();
      _videoInfo = await _gifGeneratorServices.getVideoInfo(videoPath);
      setState(() {
        if (_videoInfo != null) {
          _startTime = 0.0;
          _duration = (_videoInfo!['duration'] as double).clamp(1.0, 5.0);
        }
      });
    } else {
      print("cannot fetch video from url");
    }
  }

  //generete gif
  Future<void> _generateGif() async {
    if (_selectedVideoPath == null) return;

    setState(() {
      _isProcessing = true;
    });

    final gifPath = await _gifGeneratorServices.generateGifFromVideo(
      videoPath: _selectedVideoPath!,
      startTime: _startTime,
      duration: _duration,
      fps: _fps,
      quality: _quality,
      width: _width,
    );

    setState(() {
      _isProcessing = false;
      _generatevideoPath = gifPath;
    });

    if (gifPath == null) {
      print("Failed to generate GIF");
    }
  }

  //save gif in deveice gallery
  Future<void> _saveGifInGallery() async {
    if (_generatevideoPath == null) return;
    final isSaved = await _gifGeneratorServices.saveGitInGallery(
      _generatevideoPath!,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isSaved ? 'GIF saved in gallery!' : 'Failed to save GIF'),
        backgroundColor: isSaved ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(constCommonPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //back to homepage
              GestureDetector(
                onTap: () {
                  GoRouter.of(context).goNamed(RouterNames.homePage);
                },
                child: Container(
                  padding: EdgeInsets.all(4),
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    spacing: 4,
                    mainAxisAlignment: MainAxisAlignment.center,

                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, size: 28, color: colordustyGray),
                      Icon(
                        CupertinoIcons.home,
                        size: 28,
                        color: colordustyGray,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              //video selection section
              VideoSeection(
                isDownloading: _isDownloading,
                selectVideoFromDevice: _selectVideoFromDevice,
                showUrlDialog: _showUrlDialog,
              ),

              //end of video selection section
              SizedBox(height: 16),
              //if video selected
              if (_selectedVideoPath != null) ...[
                //video previwe section
                if (_videoPlayerController != null &&
                    _videoPlayerController!.value.isInitialized)
                  Container(
                    height: 250,
                    child: VideoPlayer(_videoPlayerController!),
                  )
                else
                  Container(
                    height: 250,
                    color: colordustyGray,
                    child: Center(
                      child: CircularProgressIndicator(color: colorMercury),
                    ),
                  ),
                //video controllers
                Row(),
                //end of video previwe section
                SizedBox(height: 12),

                //qulity setting adjustment
                QulitySetting(
                  startTime: _startTime,
                  duration: _duration,
                  width: _width,
                  fps: _fps,
                  quality: _quality,
                  videoInfo: _videoInfo,
                ),
                //end of qulity adjusting section
                SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // generate gif button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorFern,
                        elevation: 2,
                        padding: EdgeInsets.all(12),
                      ),
                      onPressed: () async {
                        await _generateGif();
                      },
                      label: Text(
                        "Generate GIF",
                        style: FontStyles().fontSubTitle,
                      ),
                      icon:
                          _isProcessing
                              ? LinearProgressIndicator(color: colorMercury)
                              : Icon(Icons.gif, size: 28, color: colorMercury),
                    ),
                    SizedBox(height: 12),
                  ],
                ),
                //previwe section
                if (_generatevideoPath != null) ...[
                  Text('Generated GIF', style: FontStyles().fontSubTitle),
                  Container(
                    height: 250,
                    child: Image.file(
                      File(_generatevideoPath!),
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 12),
                  //saved button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorFern,
                      elevation: 2,
                      padding: EdgeInsets.all(12),
                    ),
                    onPressed: () async {
                      await _saveGifInGallery();
                    },
                    label: Text(
                      "Saved to Gallery",
                      style: FontStyles().fontSubTitle,
                    ),
                    icon: Icon(Icons.save, size: 28, color: colorMercury),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
