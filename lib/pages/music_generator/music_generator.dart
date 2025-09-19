import 'dart:io';

import 'package:ffmpeg_base_minitask_executer/routes/router_names.dart';
import 'package:ffmpeg_base_minitask_executer/services/elevanlabs_services/ElevanLab_services.dart';
import 'package:ffmpeg_base_minitask_executer/util/colors.dart';
import 'package:ffmpeg_base_minitask_executer/util/constants.dart';
import 'package:ffmpeg_base_minitask_executer/util/font_styles.dart';
import 'package:ffmpeg_base_minitask_executer/widgets/navigator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MusicGeneratorPage extends StatefulWidget {
  const MusicGeneratorPage({super.key});

  @override
  State<MusicGeneratorPage> createState() => _MusicGeneratorPageState();
}

class _MusicGeneratorPageState extends State<MusicGeneratorPage> {
  String? _prompt;
  String? _musicFilePath;
  int _duration = 10000;
  bool _isDownloading = false;
  bool _isProcessing = false;
  AudioPlayer _audioPlayer = AudioPlayer();
  final List<int> _durations = [10000, 15000, 20000, 30000];
  final TextEditingController _controller = TextEditingController();
  final ElevanlabServices _elevanlabServices = ElevanlabServices();
  bool _isPlayer = false;
  Duration _playerDuration = Duration.zero;
  Duration _playerPosition = Duration.zero;
  //get music by prompt
  Future<void> _getMusicByPrompt() async {
    if (_controller.text.trim().isEmpty) return;

    try {
      setState(() {
        _prompt = _controller.text;
        _isProcessing = true;
      });
      String? musicFilePath = await _elevanlabServices.generateMusic(
        prompt: _prompt!,
        duration: _duration,
      );

      setState(() {
        _isProcessing = false;
        _musicFilePath = musicFilePath;
        _prompt = null;
      });
      await _audioPlayer.setFilePath(_musicFilePath!);
      if (musicFilePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('saved generated audio track'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (err) {
      print("faile to get music by prompt $err");
      setState(() {
        _isProcessing = false;
        _prompt = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed generate audio track'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  //save gif in deveice gallery
  Future<void> _saveAudioInDevice() async {
    if (_musicFilePath == null) return;

    setState(() {
      _isDownloading = true;
    });
    bool isSaved = false;
    try {
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: "Save Audio Fie",
        fileName:
            "audio_${DateTime.now().millisecondsSinceEpoch}.${_musicFilePath!.split('.').last}",
        type: FileType.audio,
        bytes: await File(_musicFilePath!).readAsBytes(),
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

  //initialize audio player
  void _initPlayer() {
    _audioPlayer.durationStream.listen((duration) {
      setState(() {
        _playerDuration = duration ?? Duration.zero;
      });
    });
    _audioPlayer.positionStream.listen((position) {
      setState(() {
        _playerPosition = position;
      });
    });
    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        _isPlayer = state.playing;
      });
    });
  }

  //play pause audio
  Future<void> _playPause() async {
    if (_isPlayer) {
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
  void initState() {
    // TODO: implement initState
    super.initState();
    _initPlayer();
  }

  @override
  void dispose() {
    _controller.dispose();
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
              //go to home page
              NavigatorWidget(pagename: RouterNames.homePage),
              //duration
              SizedBox(height: 24),

              Text(
                "Set duration:",
                style: FontStyles().fontSubTitle.copyWith(fontSize: 16),
              ),
              SizedBox(height: 6),
              Wrap(
                spacing: 6,
                children:
                    _durations.map((d) {
                      return ChoiceChip(
                        label: Text("${d / 1000} sec"),
                        selected: _duration == d,
                        checkmarkColor: colorFern,

                        onSelected: (value) {
                          if (value) {
                            setState(() {
                              _duration = d;
                            });
                          }
                        },
                      );
                    }).toList(),
              ),
              SizedBox(height: 8),
              //prompt
              TextField(
                controller: _controller,
                maxLines: null,
                minLines: 3,
                cursorColor: colordustyGray,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: colordustyGray, width: 2),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: colordustyGray, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  hintText: "Type your prompt here...",
                  hintStyle: FontStyles().fontBody,
                ),
              ),
              SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorFern,
                    elevation: 2,
                    padding: EdgeInsets.all(12),
                  ),
                  onPressed: () async {
                    await _getMusicByPrompt();
                  },
                  label: Text(
                    "Generate Music",
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
                            Icons.music_note,
                            size: 28,
                            color: colorMercury,
                          ),
                ),
              ),
              if (_musicFilePath != null) ...[
                SizedBox(height: 16),
                //audio player
                StreamBuilder<Duration>(
                  stream: _audioPlayer.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final duration = _playerDuration;
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
                                _isPlayer ? Icons.pause : Icons.play_arrow,
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
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorFern,
                      elevation: 2,
                      padding: EdgeInsets.all(12),
                    ),
                    onPressed: () async {
                      await _saveAudioInDevice();
                    },
                    label: Text(
                      "Saved to Gallery",
                      style: FontStyles().fontSubTitle.copyWith(
                        color: colorMercury,
                      ),
                    ),
                    icon:
                        _isDownloading
                            ? SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                color: colorMercury,
                                strokeWidth: 2,
                              ),
                            )
                            : Icon(Icons.save, size: 28, color: colorMercury),
                  ),
                ),
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
