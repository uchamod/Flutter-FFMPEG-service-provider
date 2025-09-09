import 'package:ffmpeg_base_minitask_executer/routes/router_names.dart';
import 'package:ffmpeg_base_minitask_executer/services/auth/auth_services.dart';
import 'package:ffmpeg_base_minitask_executer/util/colors.dart';
import 'package:ffmpeg_base_minitask_executer/util/font_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final AuthServices _authServices = AuthServices();
  //sign out
  Future<void> _userSignOut() async {
    try {
      _authServices.singOut();
      GoRouter.of(context).goNamed(RouterNames.loginPage);
    } catch (err) {
      print('Error signing in with Google: $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              await _userSignOut();
            },
            icon: Icon(Icons.logout, size: 28, color: colorMineShaft),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text("This is homepage", style: FontStyles().fontTitle)],
        ),
      ),
    );
  }
}
