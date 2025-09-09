import 'package:ffmpeg_base_minitask_executer/pages/auth/login.dart';
import 'package:ffmpeg_base_minitask_executer/pages/error/error_page.dart';
import 'package:ffmpeg_base_minitask_executer/pages/home/homepage.dart';
import 'package:ffmpeg_base_minitask_executer/util/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: colordustyGray),
          );
        }
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return Homepage();
          } else if (snapshot.hasError) {
            return ErrorPage();
          }
        }
        return AuthenticationPage();
      },
    );
  }
}
