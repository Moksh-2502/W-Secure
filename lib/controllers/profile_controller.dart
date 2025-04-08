import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final ImagePicker _picker = ImagePicker();

  RxString name = ''.obs;
  RxString email = ''.obs;
  RxString phoneNumber = ''.obs;
  RxString profilePictureUrl = ''.obs;
  RxString originalName = ''.obs;
  RxString originalPhoneNumber = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
    email.value =
        _auth.currentUser?.email ?? ''; // Ensure email is fetched correctly
    originalName.value = name.value;
    originalPhoneNumber.value = phoneNumber.value;
  }

  Future<void> fetchUserProfile() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      email.value = user.email ?? ''; // Fetch email from FirebaseAuth
      final DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(user.uid).get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        name.value = data['name'] ?? ''; // Fetch name from Firestore
        phoneNumber.value =
            data['emergencyContact'] ?? ''; // Fetch emergency contact
        profilePictureUrl.value = data['profilePicture'] ?? '';
      }
    }
  }

  // Update the name on Firestore and in the UI
  Future<void> updateName(String newName) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'name': newName,
      });
      name.value = newName; // Update the observable variable
    }
  }

  Future<void> updatePhoneNumber(String newPhoneNumber) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'phone': newPhoneNumber,
      });
      phoneNumber.value = newPhoneNumber;
    }
  }

  Future<void> pickProfilePicture() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        final String downloadUrl = await uploadProfilePicture(imageFile);
        await updateProfilePicture(downloadUrl);
        profilePictureUrl.value = downloadUrl;
      } else {
        Get.snackbar('No image selected', 'Please select an image.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  Future<String> uploadProfilePicture(File imageFile) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final String filePath = 'profilePictures/${user.uid}.jpg';
      final UploadTask uploadTask = _storage.ref(filePath).putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    }
    throw Exception('User not logged in');
  }

  Future<void> updateProfilePicture(String downloadUrl) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'profilePicture': downloadUrl,
      });
    }
  }

  Future<void> updateProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'name': name.value,
        'emergencyContact': phoneNumber.value,
      });

      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    }
  }
}
