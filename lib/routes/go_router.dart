import 'package:ffmpeg_base_minitask_executer/pages/auth/login.dart';
import 'package:ffmpeg_base_minitask_executer/pages/error/error_page.dart';
import 'package:ffmpeg_base_minitask_executer/pages/gif_generator_page/gif_generatoe_page.dart';
import 'package:ffmpeg_base_minitask_executer/pages/home/homepage.dart';
import 'package:ffmpeg_base_minitask_executer/pages/image_generator/image_generator.dart';
import 'package:ffmpeg_base_minitask_executer/pages/profile/user_profile.dart';
import 'package:ffmpeg_base_minitask_executer/pages/video_download_page/video_download_page.dart';
import 'package:ffmpeg_base_minitask_executer/pages/wrapper/wrapper.dart';
import 'package:ffmpeg_base_minitask_executer/routes/router_names.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class GoRouterClass {
  final routes = GoRouter(
    initialLocation: "/",
    routes: [
      //homepage
      GoRoute(
        path: "/",
        name: RouterNames.wrapperPage,
        builder: (context, state) {
          return Wrapper();
        },
      ),
      //authpage
      GoRoute(
        path: "/login",
        name: RouterNames.loginPage,
        builder: (context, state) {
          return AuthenticationPage();
        },
      ),
      GoRoute(
        path: "/home",
        name: RouterNames.homePage,
        builder: (context, state) {
          return Homepage();
        },
      ),
      GoRoute(
        path: "/error",
        name: RouterNames.errorPage,
        builder: (context, state) {
          return ErrorPage();
        },
      ),
      GoRoute(
        path: "/profile",
        name: RouterNames.profilePage,
        builder: (context, state) {
          final user = state.extra as User;
          return UserProfile(userData: user);
        },
      ),
      GoRoute(
        path: "/gif",
        name: RouterNames.gifPage,
        builder: (context, state) {
          return GifGeneratoePage();
        },
      ),
      GoRoute(
        path: "/image",
        name: RouterNames.imagePage,
        builder: (context, state) {
          return ImageGenerator();
        },
      ),
      GoRoute(
        path: "/download",
        name: RouterNames.downloadPage,
        builder: (context, state) {
          return VideoDownloadPage();
        },
      ),
    ],
  );
}
