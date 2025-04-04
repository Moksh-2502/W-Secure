import 'package:get/get.dart';
import '../routes/app_routes.dart';

class NavigationController extends GetxController {
  static NavigationController get to => Get.find();

  final _selectedIndex = 0.obs;

  int get selectedIndex => _selectedIndex.value;

  @override
  void onInit() {
    super.onInit();
    final currentRoute = Get.currentRoute;
    _selectedIndex.value = _getIndexFromRoute(currentRoute);
  }

  void changeIndex(int index) {
    if (_selectedIndex.value == index) return; // Prevent unnecessary reload
    _selectedIndex.value = index;

    switch (index) {
      case 0:
        Get.offNamed(AppRoutes.home); // Navigate to HomePage
        break;
      case 3:
        Get.offNamed(AppRoutes.map); // Navigate to MapScreen
        break;
      case 4:
        Get.offNamed(AppRoutes.profile); // Navigate to ProfilePage
        break;
      default:
        // Handle other cases if needed
        break;
    }
  }

  int _getIndexFromRoute(String route) {
    switch (route) {
      case AppRoutes.home:
        return 0;
      case AppRoutes.map:
        return 3;
      case AppRoutes.profile:
        return 4;
      default:
        return 0;
    }
  }
}
