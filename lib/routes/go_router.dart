import 'package:ffmpeg_base_minitask_executer/pages/auth/login.dart';
import 'package:ffmpeg_base_minitask_executer/pages/error/error_page.dart';
import 'package:ffmpeg_base_minitask_executer/pages/home/homepage.dart';
import 'package:ffmpeg_base_minitask_executer/pages/wrapper/wrapper.dart';
import 'package:ffmpeg_base_minitask_executer/routes/router_names.dart';
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
    ],
  );
}
