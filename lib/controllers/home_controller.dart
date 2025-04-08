import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart'
    as permissionHandler; // Aliased permission_handler package
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:location/location.dart'
    as locationPackage; // Aliased the location package
import 'package:telephony/telephony.dart';
import '../screens/emergency_lock_screen.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';

class HomeController extends GetxController {
  late CameraController cameraController;
  RxBool isRecording = false.obs;
  final Telephony telephony = Telephony.instance;
  Timer? _locationUpdateTimer;

  @override
  void onInit() {
    super.onInit();
    initializeCamera(); 
  }

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }

  Future<void> initializeCamera() async {
    try {
      final cameras = Get.find<List<CameraDescription>>();
      if (cameras.isNotEmpty) {
        cameraController = CameraController(
          cameras.first,
          ResolutionPreset.high,
          enableAudio: true,
        );
        await cameraController.initialize();
        update();
      } else {
        Get.snackbar('Error', 'No cameras available');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to initialize camera: $e');
    }
  }

  Future<void> makeEmergencyCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '1091');
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not make emergency call: $e');
    }
  }

  Future<void> shareLocation() async {
    final permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Get.snackbar('Permission Denied', 'Location permission is required');
      return;
    }

    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final String googleMapsUrl =
          'https://www.google.com/maps?q=${position.latitude},${position.longitude}';

      final whatsappUri =
          Uri.parse('whatsapp://send?text=My current location: $googleMapsUrl');

      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri);
      } else {
        await Share.share('My current location: $googleMapsUrl');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to share location: $e');
    }
  }

  Future<void> toggleVideoRecording() async {
    if (!cameraController.value.isInitialized) {
      await initializeCamera(); 
    }

    final cameraPermission =
        await permissionHandler.Permission.camera.request();
    final microphonePermission =
        await permissionHandler.Permission.microphone.request();

    if (cameraPermission.isGranted && microphonePermission.isGranted) {
      if (isRecording.value) {
        try {
          await cameraController.stopVideoRecording();
          isRecording.value = false;
          Get.snackbar('Success', 'Recording stopped');
        } catch (e) {
          Get.snackbar('Error', 'Failed to stop recording: $e');
        }
      } else {
        try {
          await cameraController.startVideoRecording();
          isRecording.value = true;
          Get.snackbar('Success', 'Recording started');
        } catch (e) {
          Get.snackbar('Error', 'Failed to start recording: $e');
        }
      }
    } else {
      Get.snackbar(
        'Permission Denied',
        'Camera and microphone permissions are required',
      );
    }
  }

  Future<String?> fetchEmergencyContact() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      return doc.data()?['emergencyContact'] as String?;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch emergency contact: $e');
      return null;
    }
  }

  Future<void> activateEmergencyMode() async {
    locationPackage.Location location = locationPackage.Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    var locationPermissionStatus =
        await locationPackage.Location().hasPermission();
    if (locationPermissionStatus == locationPackage.PermissionStatus.denied) {
      locationPermissionStatus =
          await locationPackage.Location().requestPermission();
      if (locationPermissionStatus != locationPackage.PermissionStatus.granted)
        return;
    }

    final emergencyContact = await fetchEmergencyContact();
    if (emergencyContact == null) {
      Get.snackbar('Error', 'No emergency contact found');
      return;
    }

    _locationUpdateTimer = Timer.periodic(Duration(seconds: 30), (timer) async {
      locationPackage.LocationData locationData = await location.getLocation();
      String message =
          "Emergency! My live location is: https://www.google.com/maps?q=${locationData.latitude},${locationData.longitude}";

      try {
        await telephony.sendSms(
          to: emergencyContact,
          message: message,
        );
        log('Location sent: $message');
      } catch (e) {
        log('Failed to send location: $e');
      }
    });

    Get.to(() => EmergencyLockScreen(onExit: stopEmergencyMode));
  }

  void stopEmergencyMode() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
    Get.back(); // Exit the lock screen
  }

  Future<void> setAppPin(String pin) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'app_pin': pin});

      Get.snackbar('Success', 'PIN updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update PIN: $e');
    }
  }
}
