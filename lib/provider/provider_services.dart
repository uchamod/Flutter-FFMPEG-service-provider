import 'package:ffmpeg_base_minitask_executer/services/auth/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProviderServices extends ChangeNotifier {
  User? _currentUser;

  User get getAppUser => _currentUser!;

  Future<void> refreshUser() async {
    User? user = AuthServices.getCurrentUser();
    _currentUser = user;
    notifyListeners();
  }
}
