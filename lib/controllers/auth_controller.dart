import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/set_pin_screen.dart';

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

      if (user != null) {
        isSignedIn.value = true;
        Get.snackbar("Login Success", "Welcome, ${user?.displayName}!",
            snackPosition: SnackPosition.BOTTOM);
        Get.offAllNamed('/home'); // Redirect to home page
      }
    } catch (error) {
      Get.snackbar("Login Error", error.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Get.offAllNamed('/home'); // Navigate to home page on successful login
    } catch (e) {
      Get.snackbar('Login Failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> registerUser(String email, String password) async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        // Add user to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': email,
          'emergencyContact': '', // Placeholder for emergency contact
          'app_pin': '', // Placeholder for app PIN
        });

        // Navigate to SetPinScreen
        Get.offAll(() => SetPinScreen());
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to register: $e');
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
