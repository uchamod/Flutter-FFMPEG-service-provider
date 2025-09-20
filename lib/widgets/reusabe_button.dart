import 'package:ffmpeg_base_minitask_executer/util/colors.dart'
    show colorFern, colorMercury;
import 'package:ffmpeg_base_minitask_executer/util/font_styles.dart';
import 'package:flutter/material.dart';

class ReusabeButton extends StatefulWidget {
  bool isDownloading;
  Future Function()? function;
  IconData icon;
  String text;
  ReusabeButton({super.key, required this.isDownloading, required this.icon, required this.text,required this.function});
  @override
  State<ReusabeButton> createState() => _ReusabeButtonState();
}

class _ReusabeButtonState extends State<ReusabeButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorFern,
          elevation: 2,
          padding: EdgeInsets.all(12),
        ),
        onPressed: () async {
          await widget.function;
        },
        label: Text(
         widget.text,
          style: FontStyles().fontSubTitle.copyWith(color: colorMercury),
        ),
        icon:
            widget.isDownloading
                ? SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    color: colorMercury,
                    strokeWidth: 2,
                  ),
                )
                : Icon(widget.icon, size: 28, color: colorMercury),
      ),
    );
  }
}
