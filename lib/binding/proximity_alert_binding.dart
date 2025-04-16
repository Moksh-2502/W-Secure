import 'package:get/get.dart';
import 'package:security/controllers/proximity_alert_controller.dart';
import 'package:security/services/proximity_alert_service.dart';

class ProximityAlertBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize the service first
    Get.putAsync<ProximityAlertService>(() async {
      final service = ProximityAlertService();
      return await service.init();
    }, permanent: true);
    
    // Then initialize the controller that depends on the service
    Get.lazyPut<ProximityAlertController>(() => ProximityAlertController());
  }
}
