import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';

class HomeController extends GetxController {
  late CameraController cameraController;
  RxBool isRecording = false.obs;

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
    final cameras = Get.find<List<CameraDescription>>();
    if (cameras.isNotEmpty) {
      cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: true,
      );
      try {
        await cameraController.initialize();
        update();
      } catch (e) {
        Get.snackbar('Error', 'Failed to initialize camera: $e');
      }
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
        locationSettings: const LocationSettings(
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
    final cameraPermission = await Permission.camera.request();
    final microphonePermission = await Permission.microphone.request();

    if (cameraPermission.isGranted && microphonePermission.isGranted) {
      if (isRecording.value) {
        try {
          final XFile video = await cameraController.stopVideoRecording();
          isRecording.value = false;
          Get.snackbar('Success', 'Video saved to: ${video.path}');
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
}
