// app/bindings/initial_binding.dart
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:security/main.dart';
import '../controllers/home_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Put the cameras list into GetX dependency injection
    Get.put<List<CameraDescription>>(cameras);

    // Initialize HomeController
    Get.put(HomeController());
  }
}
