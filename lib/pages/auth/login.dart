import 'package:ffmpeg_base_minitask_executer/routes/router_names.dart';
import 'package:ffmpeg_base_minitask_executer/services/auth/auth_services.dart';
import 'package:ffmpeg_base_minitask_executer/util/colors.dart';
import 'package:ffmpeg_base_minitask_executer/util/constants.dart';
import 'package:ffmpeg_base_minitask_executer/util/font_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  final AuthServices _authServices = AuthServices();
  //google sing in
  Future<void> _userLogin() async {
    try {
      await _authServices.googleSignIn();

      GoRouter.of(context).goNamed(RouterNames.homePage);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 3),
            backgroundColor: colorFern,
            content: Text(
              "User Login Succsussfuly !",
              style: FontStyles().fontBody,
            ),
          ),
        );
      }
    } catch (err) {
      print('Error signing in with Google: $err');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 3),
            backgroundColor: Colors.redAccent,
            content: Text(
              "Error while logging !",
              style: FontStyles().fontBody,
            ),
          ),
        );
      }
    }
  }

  //anonmus sign in
  Future<void> _userLoginAnonmusly() async {
    try {
      await _authServices.singInAnonomusly();

      GoRouter.of(context).goNamed(RouterNames.homePage);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 3),
            backgroundColor: colorFern,
            content: Text(
              "User Login Succsussfuly !",
              style: FontStyles().fontBody,
            ),
          ),
        );
      }
    } catch (err) {
      print('Error signing in with Google: $err');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 3),
            backgroundColor: Colors.redAccent,
            content: Text(
              "Error while logging !",
              style: FontStyles().fontBody,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(constCommonPad),
        child: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //logo
              Image.asset("assets/logo.png", height: 128, width: 128),
              SizedBox(height: 16),
              Text("Sing In", style: FontStyles().fontTitle),
              SizedBox(height: constCommonPad),
              //google sing in
              GestureDetector(
                onTap: () async {
                  await _userLogin();
                },

                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 4),

                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(48),
                    border: Border.all(color: colorMineShaft, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/icons8-google.svg",
                        height: 42,
                        width: 42,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Continue with Google",
                        style: FontStyles().fontSubTitle,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              //sing in anonymosly
              GestureDetector(
                onTap: () async {
                  await _userLoginAnonmusly();
                },

                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 4),

                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(48),
                    border: Border.all(color: colorMineShaft, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/icons8-anonymous.svg",
                        height: 42,
                        width: 42,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "SingIn Anonymously",
                        style: FontStyles().fontSubTitle,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
