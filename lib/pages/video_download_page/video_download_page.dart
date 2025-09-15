import 'package:ffmpeg_base_minitask_executer/services/downloader_services/video_downloader_services.dart';
import 'package:ffmpeg_base_minitask_executer/util/colors.dart';
import 'package:ffmpeg_base_minitask_executer/util/constants.dart';
import 'package:ffmpeg_base_minitask_executer/util/font_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:video_player/video_player.dart';

class VideoDownloadPage extends StatefulWidget {
  const VideoDownloadPage({super.key});

  @override
  State<VideoDownloadPage> createState() => _VideoDownloadPageState();
}

class _VideoDownloadPageState extends State<VideoDownloadPage> {
  //yt-1
  //tiktok-2
  //insta-3
  final TextEditingController _controller = TextEditingController();
  final VideoDownloaderServices _downloaderServices = VideoDownloaderServices();
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  bool _isTikSelectMedia = false;
  bool _isytSelected = false;
  bool _isInstSelected = false;
  String? _filePath;
  double mediaType = 1;
  VideoPlayerController? _videoPlayerController;
  String _statusMessage = '';
  Future<void> _downloadVideo() async {
    if (_controller.text.isEmpty) {
      setState(() {
        _statusMessage = 'Please enter a valid Instagram URL';
      });
      return;
    }
    try {
      setState(() {
        _isDownloading = true;
        _downloadProgress = 0.0;
        _statusMessage = 'Getting video information...';
      });
      _filePath = await _downloaderServices.completeDownloadSession(
        videoLink: _controller.text.trim(),
        media: mediaType,
        onProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
              _statusMessage =
                  'Downloading... ${(received / total * 100).toStringAsFixed(1)}%';
            });
          }
        },
      );
      setState(() {
        _isDownloading = false;
        if (_filePath != null) {
          _statusMessage =
              'Video downloaded successfully!\nSaved to: $_filePath';
        } else {
          _statusMessage = 'Download failed. Please try again.';
        }
      });
    } catch (err) {
      _statusMessage = 'Error while processing';
      print("video download error : $err");
    }
  }

  //Save video to gallery
  Future<void> saveGitInGallery(String video) async {
    try {
      final result = await GallerySaver.saveVideo(video);
      if (result!) {
        setState(() {
          _statusMessage = "Video saved in Gallery";
        });
        print('succsussfuly saving  to gallery:');
      }
    } catch (err) {
      setState(() {
        _statusMessage = "Unable to saved in Gallery";
      });

      print('Error saving GIF to gallery: $err');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _videoPlayerController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(constCommonPad),
            child: Column(
              children: [
                if (_statusMessage.isNotEmpty) ...[
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colorFern,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _statusMessage,
                      style: FontStyles().fontBody.copyWith(
                        color: colorMercury,
                      ),
                    ),
                  ),

                  SizedBox(height: 8),
                ],

                //select platform
                Text(
                  "Select Media Platform :",
                  style: FontStyles().fontBody.copyWith(fontSize: 16),
                ),
                SizedBox(height: 8),
                //medias
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //yt
                    _mediaIcon("assets/icons8-youtube.svg", _isytSelected, 1),
                    SizedBox(width: 6),
                    //tiktok
                    _mediaIcon(
                      "assets/icons8-tiktok.svg",
                      _isTikSelectMedia,
                      2,
                    ),
                    SizedBox(width: 6),
                    //insta
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isInstSelected = !_isInstSelected;
                          mediaType = 3;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(48),
                          border: Border.all(
                            color: _isInstSelected ? colorFern : colordustyGray,
                            width: 2,
                          ),
                        ),
                        child: SvgPicture.asset(
                          "assets/icons8-instagram.svg",
                          width: 44,
                          height: 44,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                //url
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colordustyGray, width: 1),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    hintText: "paste video link here",
                    hintStyle: FontStyles().fontBody,
                  ),
                ),
                SizedBox(height: 8),
                //fetch video
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _downloadVideo();
                    },
                    label: Text(
                      _isDownloading ? "Downloading..." : "Download",
                      style: FontStyles().fontBody,
                    ),
                    icon: Icon(Icons.download, size: 28, color: colorMercury),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorFern,
                      foregroundColor: colorMercury,
                      elevation: 2,
                      padding: EdgeInsets.all(12),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                //previwe & save section
                if (_filePath != null && _videoPlayerController != null) ...[
                  Container(child: VideoPlayer(_videoPlayerController!)),
                  SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await saveGitInGallery(_filePath!);
                    },
                    label: Text("Saved", style: FontStyles().fontBody),
                    icon: Icon(Icons.save, size: 28, color: colorMercury),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorFern,
                      foregroundColor: colorMercury,
                      elevation: 2,
                      padding: EdgeInsets.all(12),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _mediaIcon(String iconPath, bool isSelected, double media) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
          mediaType = media;
        });
      },
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(48),
          border: Border.all(
            color: isSelected ? colorFern : colordustyGray,
            width: 2,
          ),
        ),
        child: SvgPicture.asset(iconPath, width: 44, height: 44),
      ),
    );
  }
}
