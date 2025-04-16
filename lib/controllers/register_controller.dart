import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:security/screens/home.dart';

class RegisterController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final emergencyContactController = TextEditingController();

  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;
  var agreesToTerms = false.obs;

  final termsRecognizer = TapGestureRecognizer()
    ..onTap = () {
      Get.snackbar("Terms", "Navigate to Terms and Conditions page.");
    };

  final privacyRecognizer = TapGestureRecognizer()
    ..onTap = () {
      Get.snackbar("Privacy", "Navigate to Privacy Policy page.");
    };

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final emergencyContact = emergencyContactController.text.trim();

    if (!agreesToTerms.value) {
      Get.snackbar("Error", "You must agree to the Terms and Privacy Policy.");
      return;
    }

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        emergencyContact.isEmpty) {
      Get.snackbar("Error", "All fields are required.");
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar("Error", "Passwords do not match.");
      return;
    }

    if (password.length < 6) {
      Get.snackbar("Error", "Password must be at least 6 characters long.");
      return;
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(name);

      final userDocRef =
          _firestore.collection('users').doc(userCredential.user?.uid);
      await userDocRef.set({
        'name': name,
        'email': email,
        'emergencyContact': emergencyContact,
        'phone': '',
        'profilePicture': '',
      });

      Get.offAll(() => const HomePage());
      Get.snackbar("Success", "Account created successfully!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    emergencyContactController.dispose();
    super.onClose();
  }
}
