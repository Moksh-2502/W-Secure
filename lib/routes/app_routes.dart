import 'package:get/get.dart';
import 'package:security/binding/initial_binding.dart';
import 'package:security/binding/login_binding.dart';
import 'package:security/binding/register_binding.dart';
import 'package:security/screens/home.dart';
import 'package:security/screens/login_screen.dart';
import 'package:security/screens/profile_screen.dart';
import 'package:security/screens/register.dart';

class AppRoutes {
  static const String LOGIN = '/login';
  static const String REGISTER = '/register';

  static const String HOME = '/home';
  static const String SOS = '/sos';
  static const String BOOK = '/book';
  static const String MAP = '/map';
  static const String PROFILE = '/profile';

  static List<GetPage> routes = [
    GetPage(
      name: LOGIN,
      page: () => LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: REGISTER,
      page: () => const RegisterScreen(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: HOME,
      page: () => const HomePage(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: PROFILE,
      page: () => ProfilePage(),
    ),
  ];
}
