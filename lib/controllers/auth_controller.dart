import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  var isSignedIn = false.obs;
  User? get user => _auth.currentUser;

  Future<void> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      isSignedIn.value = true;
      Get.snackbar("Login Success", "Welcome, ${user?.displayName}!",
          snackPosition: SnackPosition.BOTTOM);
    } catch (error) {
      Get.snackbar("Login Error", error.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    isSignedIn.value = false;
    Get.snackbar("Logout", "You have been logged out",
        snackPosition: SnackPosition.BOTTOM);
  }
}
