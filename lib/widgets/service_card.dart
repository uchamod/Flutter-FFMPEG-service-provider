import 'package:ffmpeg_base_minitask_executer/util/colors.dart';
import 'package:ffmpeg_base_minitask_executer/util/font_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ServiceCard extends StatelessWidget {
  final String title;
  final String discription;
  final IconData icon;
  final String routeName;

  const ServiceCard({
    super.key,
    required this.title,
    required this.discription,
    required this.icon,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    //represent service card
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorMineShaft, width: 2),
        color: colorMercury,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: InkWell(
          onTap: () {
            GoRouter.of(context).goNamed(routeName);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 28, color: colorFern),
                  Text(title, style: FontStyles().fontSubTitle),
                ],
              ),
              Text(discription, style: FontStyles().fontSubTitle),
            ],
          ),
        ),
      ),
    );
  }
}
