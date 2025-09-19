import 'package:ffmpeg_base_minitask_executer/util/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigatorWidget extends StatelessWidget {
  final String pagename;
  const NavigatorWidget({super.key, required this.pagename});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        GoRouter.of(context).goNamed(pagename);
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
            Icon(CupertinoIcons.home, size: 28, color: colordustyGray),
          ],
        ),
      ),
    );
  }
}
