import 'package:camera/camera.dart';

class CameraControllerService {
  CameraController? cameraController;

  Future<void> initializeCamera(List<CameraDescription> cameras) async {
    if (cameras.isEmpty) {
      throw Exception('No cameras available');
    }
    cameraController = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: true,
    );
    await cameraController!.initialize();
  }

  bool isInitialized() {
    return cameraController?.value.isInitialized ?? false;
  }

  Future<void> startVideoRecording(String filePath) async {
    if (!isInitialized()) {
      throw Exception('Camera is not initialized');
    }
    await cameraController!.startVideoRecording();
  }

  Future<XFile> stopVideoRecording() async {
    if (!isInitialized()) {
      throw Exception('Camera is not initialized');
    }
    return await cameraController!.stopVideoRecording();
  }

  void disposeCamera() {
    cameraController?.dispose();
  }
}
