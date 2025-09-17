import 'package:ffmpeg_base_minitask_executer/routes/router_names.dart';
import 'package:ffmpeg_base_minitask_executer/services/image_generation_service/image_generation_service.dart';
import 'package:ffmpeg_base_minitask_executer/util/colors.dart';
import 'package:ffmpeg_base_minitask_executer/util/constants.dart';
import 'package:ffmpeg_base_minitask_executer/util/font_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ImageGenerator extends StatefulWidget {
  const ImageGenerator({super.key});

  @override
  State<ImageGenerator> createState() => _ImageGeneratorState();
}

class _ImageGeneratorState extends State<ImageGenerator> {
  bool _isProcessing = false;
  double _downloadProgress = 0.0;
  bool _isDownloading = false;
  String _selectedRatio = "1:1";
  String _saveButtonText = "Saved in Gallery";
  final TextEditingController _controller = TextEditingController();
  final ImageGenerationService _imageGenerationService =
      ImageGenerationService();
  String? imageUrl;
  //fetch image
  Future<void> _generateImage() async {
    try {
      setState(() {
        _isProcessing = true;
      });
      String? url = await _imageGenerationService.getImageUrl(
        prompt: _controller.text.trim(),
        aspectRatio: _selectedRatio,
      );
      setState(() {
        imageUrl = url;
        _controller.clear();
        _isProcessing = false;
      });
    } catch (err) {
      print("image generate error $err");
    }
  }

  //download image
  Future<void> _savedImage(String url) async {
    try {
      setState(() {
        _isDownloading = true;
      });
      await _imageGenerationService.dowloadImage(url, (received, total) {
        if (total != -1) {
          setState(() {
            _downloadProgress = received / total;
            _saveButtonText =
                'Saving... ${(received / total * 100).toStringAsFixed(1)}%';
          });
        }
      });
      setState(() {
        _isDownloading = false;
        _saveButtonText = "Saved in Gallery";
      });
    } catch (err) {
      print("unable to saved image $err");
    }
  }

  void _setAspectRatio(String ratio) {
    setState(() {
      _selectedRatio = ratio;
    });
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
              //select aspect ratio
              Text(
                "Select Aspect ratio :",
                style: FontStyles().fontSubTitle.copyWith(fontSize: 16),
              ),
              SizedBox(height: 8),
              //aspect ratio section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //1:1
                  _AspectRationItem(
                    60,
                    60,
                    "1:1",
                    (String) => _setAspectRatio("1:1"),
                    _selectedRatio == "1:1",
                  ),
                  //1:1
                  _AspectRationItem(
                    70,
                    35,
                    "16:9",
                    (String) => _setAspectRatio("16:9"),
                    _selectedRatio == "16:9",
                  ),
                  //1:1
                  _AspectRationItem(
                    35,
                    70,
                    "9:16",
                    (String) => _setAspectRatio("9:16"),
                    _selectedRatio == "9:16",
                  ),
                  //1:1
                  _AspectRationItem(
                    40,
                    60,
                    "2:3",
                    (String) => _setAspectRatio("2:3"),
                    _selectedRatio == "2:3",
                  ),
                ],
              ),
              SizedBox(height: 16),
              //promt feiled
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
              //get image
              Container(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorFern,
                    elevation: 2,
                    padding: EdgeInsets.all(12),
                  ),
                  onPressed:
                      _isProcessing
                          ? null
                          : () async {
                            await _generateImage();
                          },
                  label: Text(
                    "Generate Image",
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
                            Icons.image_outlined,
                            size: 28,
                            color: colorMercury,
                          ),
                ),
              ),
              //genereted image
              SizedBox(height: 16),
              if (imageUrl != null) ...[
                Image.network(imageUrl!, fit: BoxFit.fill),
                SizedBox(height: 8),
                //downlod image
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorFern,
                      elevation: 2,
                      padding: EdgeInsets.all(12),
                    ),
                    onPressed:
                        _isDownloading
                            ? null
                            : () async {
                              await _savedImage(imageUrl!);
                            },
                    label: Text(
                      _saveButtonText,
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

  Widget _AspectRationItem(
    double width,
    double heigth,
    String ratio,
    void onRatioSelected(String),
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        onRatioSelected(ratio);
      },
      child: Container(
        width: width,
        height: heigth,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: isSelected ? colorFern : colorMineShaft,
            width: 3,
          ),
        ),
        child: Center(child: Text(ratio, style: FontStyles().fontBody)),
      ),
    );
  }
}
