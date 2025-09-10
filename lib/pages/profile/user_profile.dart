import 'package:ffmpeg_base_minitask_executer/routes/router_names.dart';
import 'package:ffmpeg_base_minitask_executer/services/auth/auth_services.dart';
import 'package:ffmpeg_base_minitask_executer/util/colors.dart';
import 'package:ffmpeg_base_minitask_executer/util/constants.dart';
import 'package:ffmpeg_base_minitask_executer/util/font_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class UserProfile extends StatefulWidget {
  final User userData;
  const UserProfile({super.key, required this.userData});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
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
        padding: EdgeInsets.all(constCommonPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: colorMercury,
              radius: 64,
              backgroundImage:
                  widget.userData.isAnonymous
                      ? null
                      : NetworkImage(widget.userData.photoURL!),
              child:
                  widget.userData.isAnonymous
                      ? SvgPicture.asset(
                        "assets/icons8-anonymous.svg",
                        width: 64,
                        height: 64,
                      )
                      : null,
            ),
            SizedBox(height: 12),
            widget.userData.isAnonymous
                ? Text("Anonomus User", style: FontStyles().fontSubTitle)
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        widget.userData.displayName!,
                        style: FontStyles().fontSubTitle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.userData.email!,
                        style: FontStyles().fontSubTitle,
                      ),
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
