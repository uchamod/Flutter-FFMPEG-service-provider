import 'package:ffmpeg_base_minitask_executer/routes/router_names.dart';
import 'package:ffmpeg_base_minitask_executer/services/audio_services/audio_services.dart';
import 'package:ffmpeg_base_minitask_executer/services/gif_generator_services/gif_generator_services.dart';
import 'package:ffmpeg_base_minitask_executer/util/colors.dart';
import 'package:ffmpeg_base_minitask_executer/util/constants.dart';
import 'package:ffmpeg_base_minitask_executer/util/font_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:go_router/go_router.dart';
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
      setState(() {
        _isProcessing = false;
        _extractedAudioPath = extractedAudiopath;
      });
    } catch (err) {
      setState(() {
        _isProcessing = false;
        _audioFilePath = null;
      });
      print("failed to extract audio $err");
    }
  }

  //save gif in deveice gallery
  Future<void> _saveGifInGallery() async {
    if (_extractedAudioPath == null) return;
    setState(() {
      _isDownloading = true;
    });
    final isSaved = await GallerySaver.saveVideo(_extractedAudioPath!);
    setState(() {
      _isDownloading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSaved! ? 'GIF saved in gallery!' : 'Failed to save GIF',
        ),
        backgroundColor: isSaved ? Colors.green : Colors.red,
      ),
    );
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
              SizedBox(height: 8),
              //select video file
              Text(
                "Select Audio File :",
                style: FontStyles().fontSubTitle.copyWith(fontSize: 16),
              ),
              SizedBox(height: 8),
              if (_audioFilePath != null) ...[
                Text(_audioFilePath!, style: FontStyles().fontBody),
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
                              color: colorFern,
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
                SizedBox(height: 8),
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
                          onChanged:
                              (value) =>
                                  _seekTo(Duration(seconds: value.toInt())),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(_formatDuration(position)),
                            Text(_formatDuration(duration)),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 12),
                IconButton(
                  iconSize: 64,
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: _playPause,
                ),
                //saved in gallery
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
                  icon:
                      _isDownloading
                          ? SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              color: colorFern,
                              strokeWidth: 2,
                            ),
                          )
                          : Icon(Icons.save, size: 28, color: colorMercury),
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
