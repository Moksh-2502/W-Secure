import 'package:get/get.dart';
import 'package:security/controllers/register_controller.dart';
import 'package:security/controllers/police_stations_controller.dart';
import 'package:security/controllers/safespots_controller.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(RegisterController());
    Get.put(PoliceStationsController());
    Get.put(SafespotsController());
  }
}
