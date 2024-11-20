import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:security/main.dart';
import '../controllers/home_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<List<CameraDescription>>(cameras);
    Get.put(HomeController());
  }
}
