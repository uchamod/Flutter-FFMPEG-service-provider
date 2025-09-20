import 'package:ffmpeg_base_minitask_executer/routes/router_names.dart';
import 'package:ffmpeg_base_minitask_executer/util/constants.dart';
import 'package:ffmpeg_base_minitask_executer/widgets/navigator.dart';
import 'package:flutter/material.dart';

class VoiceModelGenerate extends StatefulWidget {
  const VoiceModelGenerate({super.key});

  @override
  State<VoiceModelGenerate> createState() => _VoiceModelGenerateState();
}

class _VoiceModelGenerateState extends State<VoiceModelGenerate> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(constCommonPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              NavigatorWidget(pagename: RouterNames.homePage),
              
          ],
        ),
      ),
    ));
  }
}