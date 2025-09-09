import 'package:ffmpeg_base_minitask_executer/firebase_options.dart';
import 'package:ffmpeg_base_minitask_executer/routes/go_router.dart';
import 'package:ffmpeg_base_minitask_executer/util/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: "FFmpeg based service provider",
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: colorMercury,
      ),
      routerConfig: GoRouterClass().routes,
    );
  }
}
