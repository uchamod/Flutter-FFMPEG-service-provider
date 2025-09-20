import 'dart:io';

import 'package:ffmpeg_base_minitask_executer/routes/router_names.dart';
import 'package:ffmpeg_base_minitask_executer/services/audio_services/audio_services.dart';
import 'package:ffmpeg_base_minitask_executer/services/gif_generator_services/gif_generator_services.dart';
import 'package:ffmpeg_base_minitask_executer/util/colors.dart';
import 'package:ffmpeg_base_minitask_executer/util/constants.dart';
import 'package:ffmpeg_base_minitask_executer/util/font_styles.dart';
import 'package:ffmpeg_base_minitask_executer/widgets/navigator.dart';
import 'package:ffmpeg_base_minitask_executer/widgets/reusabe_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioExtractorPage extends StatefulWidget {
  const AudioExtractorPage({super.key});

  @override
  State<AudioExtractorPage> createState() => _AudioExtractorPageState();
}

class _AudioExtractorPageState extends State<AudioExtractorPage> {
  String? _audioFilePath;
  String? _extractedAudioPath;
  bool _isProcessing = false;
  bool _isDownloading = false;
  String _selectedFormat = 'mp3';
  final AudioServices _audioServices = AudioServices();
  final List<String> _audioFormats = ['mp3', 'aac', 'wav', 'm4a'];
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  //select video
  Future<void> _selectVideo() async {
    try {
      final videoPath = await GifGeneratorServices.pickVideoFile();
      if (videoPath != null) {
        setState(() {
          _audioFilePath = videoPath;
        });
      }
    } catch (err) {
      print("faild to select audio $err");
    }
  }

  //extract audio
  Future<void> _extreactAudio() async {
    if (_audioFilePath == null) return;
    setState(() {
      _isProcessing = true;
    });
    try {
      final extractedAudiopath = await _audioServices.extractAudio(
        videoPath: _audioFilePath!,
        format: _selectedFormat,
      );
      // await _audioPlayer.setAudioSource(
      //   AudioSource.asset(_extractedAudioPath!),
      // );

      setState(() {
        _isProcessing = false;
        _extractedAudioPath = extractedAudiopath;
      });
      await _audioPlayer.setFilePath(_extractedAudioPath!);
    } catch (err) {
      setState(() {
        _isProcessing = false;
        _audioFilePath = null;
      });
      print("failed to extract audio $err");
    }
  }

  //save gif in deveice gallery
  Future<void> _saveAudioInDevice() async {
    if (_extractedAudioPath == null) return;

    setState(() {
      _isDownloading = true;
    });
    bool isSaved = false;
    try {
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: "Save Audio Fie",
        fileName:
            "audio_${DateTime.now().millisecondsSinceEpoch}.${_extractedAudioPath!.split('.').last}",
        type: FileType.audio,
        bytes: await File(_extractedAudioPath!).readAsBytes(),
      );
      if (outputPath != null) {
        // File originalFile = File(_extractedAudioPath!);
        // await originalFile.copy(outputPath);
        print('Audio saved to chosen location: $outputPath');
        setState(() {
          isSaved = true;
        });
      }
    } catch (err) {
      print("failed to save audio fille $err");
    } finally {
      setState(() {
        _isDownloading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isSaved ? 'Audio file saved' : 'Failed to save audio'),
          backgroundColor: isSaved ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  //initialize audio player
  void _initPlayer() {
    _audioPlayer.durationStream.listen((duration) {
      setState(() {
        _duration = duration ?? Duration.zero;
      });
    });
    _audioPlayer.positionStream.listen((position) {
      setState(() {
        _position = position;
      });
    });
    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });
  }

  //play pause audio
  Future<void> _playPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  //seek audio
  void _seekTo(Duration position) {
    _audioPlayer.seek(position);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
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
              NavigatorWidget(pagename: RouterNames.homePage),
              SizedBox(height: 28),
              //select video file
              Text(
                "Select Audio File :",
                style: FontStyles().fontSubTitle.copyWith(fontSize: 16),
              ),
              SizedBox(height: 16),
              if (_audioFilePath != null) ...[
                Text(_audioFilePath!, style: FontStyles().fontBody),
                SizedBox(height: 16),
                //select audio format
                Text(
                  "Select Audio Format :",
                  style: FontStyles().fontSubTitle.copyWith(fontSize: 16),
                ),
                SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children:
                      _audioFormats.map((format) {
                        return ChoiceChip(
                          label: Text(format.toUpperCase()),
                          selected: _selectedFormat == format,
                          checkmarkColor: colorFern,

                          onSelected: (value) {
                            if (value) {
                              setState(() {
                                _selectedFormat = format;
                              });
                            }
                          },
                        );
                      }).toList(),
                ),
                SizedBox(height: 8),
              ],
              //select / extract audio
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorFern,
                    elevation: 2,
                    padding: EdgeInsets.all(12),
                  ),
                  onPressed:
                      _audioFilePath != null
                          ? () async {
                            _extreactAudio();
                          }
                          : () async {
                            _selectVideo();
                          },
                  label: Text(
                    _audioFilePath != null ? "Extract Audio" : "Select video",
                    style: FontStyles().fontSubTitle.copyWith(
                      color: colorMercury,
                    ),
                  ),
                  icon:
                      _isProcessing
                          ? SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              color: colorMercury,
                              strokeWidth: 2,
                            ),
                          )
                          : Icon(
                            Icons.video_library,
                            size: 28,
                            color: colorMercury,
                          ),
                ),
              ),
              if (_extractedAudioPath != null) ...[
                SizedBox(height: 16),
                //audio player
                StreamBuilder<Duration>(
                  stream: _audioPlayer.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final duration = _duration;
                    return Column(
                      children: [
                        Slider(
                          min: 0.0,
                          max: duration.inSeconds.toDouble(),
                          value: position.inSeconds.toDouble(),
                          activeColor: colorFern,
                          inactiveColor: colordustyGray,
                          thumbColor: colorMercury,
                          onChanged:
                              (value) =>
                                  _seekTo(Duration(seconds: value.toInt())),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDuration(position)),
                            IconButton(
                              iconSize: 42,
                              color: colordustyGray,
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                              ),
                              onPressed: _playPause,
                            ),
                            Text(_formatDuration(duration)),
                          ],
                        ),
                      ],
                    );
                  },
                ),

                //saved in gallery
                SizedBox(height: 16),
                //saved button
                ReusabeButton(
                  isDownloading: _isDownloading,
                  icon: Icons.save,
                  text: "Saved to Gallery",
                  function: _saveAudioInDevice,
                ),
                // SizedBox(
                //   width: double.infinity,
                //   child: ElevatedButton.icon(
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: colorFern,
                //       elevation: 2,
                //       padding: EdgeInsets.all(12),
                //     ),
                //     onPressed: () async {
                //       await _saveAudioInDevice();
                //     },
                //     label: Text(
                //       "Saved to Gallery",
                //       style: FontStyles().fontSubTitle.copyWith(
                //         color: colorMercury,
                //       ),
                //     ),
                //     icon:
                //         _isDownloading
                //             ? SizedBox(
                //               width: 28,
                //               height: 28,
                //               child: CircularProgressIndicator(
                //                 color: colorMercury,
                //                 strokeWidth: 2,
                //               ),
                //             )
                //             : Icon(Icons.save, size: 28, color: colorMercury),
                //   ),
                // ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
