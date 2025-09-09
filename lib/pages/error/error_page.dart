import 'package:ffmpeg_base_minitask_executer/util/constants.dart';
import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(constCommonPad),
        child: Column(
          children: [
            Center(
              child: Text(
                "Error \n Page",
                style: TextStyle(fontSize: 32, color: Colors.redAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
