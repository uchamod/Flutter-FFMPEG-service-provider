import 'package:ffmpeg_base_minitask_executer/model/service_model.dart';
import 'package:ffmpeg_base_minitask_executer/provider/provider_services.dart';
import 'package:ffmpeg_base_minitask_executer/routes/router_names.dart';
import 'package:ffmpeg_base_minitask_executer/util/colors.dart';
import 'package:ffmpeg_base_minitask_executer/util/font_styles.dart';
import 'package:ffmpeg_base_minitask_executer/widgets/service_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final List<ServiceModel> _serviceList = [
    ServiceModel(
      title: "GIF Generator",
      description: "Convert videos to animated GIFs with custom settings",
      icon: Icons.gif,
      route: RouterNames.gifPage,
    ),
    ServiceModel(
      title: "Video downloder",
      description: "Download free YT,Tiktok & Insta video",
      icon: Icons.download,
      route: RouterNames.downloadPage,
    ),
    ServiceModel(
      title: "Image Generator",
      description: "Convert your ideas into visuals",
      icon: Icons.image,
      route: RouterNames.imagePage,
    ),
    ServiceModel(
      title: "Audio Extractor",
      description: "Convert Images Into meemes",
      icon: Icons.audio_file_outlined,
      route: RouterNames.audioPage,
    ),
    ServiceModel(
      title: "Music generater",
      description: "Generate Music tracks",
      icon: Icons.music_note,
      route: RouterNames.musicPage,
    ),
  ];
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
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      user.isAnonymous
                          ? Text(
                            "Welcome Back",
                            style: GoogleFonts.montserrat(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: colorMineShaft,
                            ),
                          )
                          : RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Welcome Back ",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: colorMineShaft,
                                  ),
                                ),
                                TextSpan(
                                  text: user.displayName,
                                  style: FontStyles().fontTitle.copyWith(
                                    color: colorFern,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),

                      SizedBox(height: 12),

                      //service list
                      ListView.builder(
                        itemCount: _serviceList.length,

                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          ServiceModel serviceModel = _serviceList[index];
                          //service
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ServiceCard(
                              title: serviceModel.title,
                              discription: serviceModel.description,
                              icon: serviceModel.icon,
                              routeName: serviceModel.route,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
