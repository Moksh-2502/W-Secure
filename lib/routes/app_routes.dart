import 'package:get/get.dart';
import 'package:security/binding/initial_binding.dart';
import 'package:security/binding/login_binding.dart';
import 'package:security/binding/register_binding.dart';
import 'package:security/screens/connect_nearby_page.dart';
import 'package:security/screens/home.dart';
import 'package:security/screens/login_screen.dart';
import 'package:security/screens/map_screen.dart';
import 'package:security/screens/profile_screen.dart';
import 'package:security/screens/register.dart';
import 'package:security/screens/safespots_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';

  static const String home = '/home';
  static const String sos = '/sos';
  static const String book = '/book';
  static const String map = '/map';
  static const String profile = '/profile';
  static const String connectNearby = '/connectNearby';

  static List<GetPage> routes = [
    GetPage(
      name: login,
      page: () => LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: register,
      page: () => const RegisterScreen(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: home,
      page: () => const HomePage(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: profile,
      page: () => const ProfilePage(),
    ),
    GetPage(name: map, page: () => const MapScreen()),
    GetPage(
      name: '/safe-spots',
      page: () => SafeSpotsPage(),
    ),
    GetPage(
      name: connectNearby,
      page: () => ConnectNearbyPage(),
    ),
  ];
}
