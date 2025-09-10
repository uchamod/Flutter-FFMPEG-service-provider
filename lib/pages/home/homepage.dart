import 'package:ffmpeg_base_minitask_executer/provider/provider_services.dart';
import 'package:ffmpeg_base_minitask_executer/routes/router_names.dart';
import 'package:ffmpeg_base_minitask_executer/util/colors.dart';
import 'package:ffmpeg_base_minitask_executer/util/font_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          Provider.of<ProviderServices>(context, listen: false).refreshUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: colorFern),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text("Data Not \n Found", style: FontStyles().fontTitle),
          );
        }
        return Consumer<ProviderServices>(
          builder: (context, userData, child) {
            final user = userData.getAppUser;
            return Scaffold(
              appBar: AppBar(
                actions: [
                  GestureDetector(
                    onTap: () {
                      GoRouter.of(
                        context,
                      ).goNamed(RouterNames.profilePage, extra: user);
                    },
                    child: CircleAvatar(
                      backgroundColor: colorMercury,
                      radius: 24,
                      backgroundImage:
                          user.isAnonymous
                              ? null
                              : NetworkImage(user.photoURL!),
                      child:
                          user.isAnonymous
                              ? SvgPicture.asset(
                                "assets/icons8-anonymous.svg",
                                width: 24,
                                height: 24,
                              )
                              : null,
                    ),
                  ),
                  SizedBox(width: 12),
                ],
              ),
              body: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("This is homepage", style: FontStyles().fontTitle),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
