import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ffmpeg_base_minitask_executer/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServices {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final FirebaseFirestore _firebaseFirestore =
      FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool isInitialize = false;

  // Get current user
  static User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Future<void> initSignIn() async {
    if (!isInitialize) {
      await _googleSignIn.initialize(
        serverClientId:
            "634918728641-r3kcbmf9m3f64glll85m800e57e8ofge.apps.googleusercontent.com",
      );
    }
    isInitialize = true;
  }

  //sign in with google
  Future<void> googleSignIn() async {
    try {
      initSignIn();
      //get user account
      final GoogleSignInAccount signInAccount =
          await _googleSignIn.authenticate();

      //get id token
      final idToken = signInAccount.authentication.idToken;
      final authorizationClient = signInAccount.authorizationClient;

      GoogleSignInClientAuthorization? clientAuthorization =
          await authorizationClient.authorizationForScopes([
            'email',
            'profile',
          ]);
      final accessToken = clientAuthorization?.accessToken;
      //if token not recived
      if (accessToken == null) {
        final authorization2 = await authorizationClient.authorizationForScopes(
          ['email', 'profile'],
        );
        if (authorization2?.accessToken == null) {
          throw FirebaseAuthException(code: "error", message: "error");
        }
        clientAuthorization = authorization2;
      }
      final credientials = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );

      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credientials);

      final userData = userCredential.user;

      if (userData != null) {
        final UserModel user = UserModel(
          userId: userData.uid,
          username: userData.displayName ?? "",
          email: userData.email ?? "",
          imageUrl: userData.photoURL ?? "",
          joinedData: DateTime.now(),
          updatedDate: DateTime.now(),
        );

        await _firebaseFirestore
            .collection("users")
            .doc(userData.uid)
            .set(user.toJson());
      }
    } on FirebaseAuthException catch (err) {
      print("firebase error ${err.toString()}");
    } catch (err) {
      print("google sing in error: ${err.toString()}");
    }
  }

  //sing in anonymously
  Future<void> singInAnonomusly() async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInAnonymously();
      print("anonymous user crediential $userCredential");
      User? user = userCredential.user;
      if (user != null) {
        print("succssussfuly sing in");
        print("anonymous user $user");
      }
    } on FirebaseAuthException catch (err) {
      throw Exception(err);
    } catch (err) {
      print("sing in error: ${err.toString()}");
    }
  }

  //sign out
  Future<void> singOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (err) {
      print("sing out error : ${err.toString()}");
      throw Exception(err);
    }
  }
}
