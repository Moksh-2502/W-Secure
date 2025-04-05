import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:camera/camera.dart';
import 'package:security/controllers/auth_controller.dart';
import 'package:security/controllers/home_controller.dart';
import 'package:security/controllers/login_controller.dart';
import 'package:security/controllers/navigation_controller.dart';
import 'package:security/controllers/profile_controller.dart';
import 'package:security/routes/app_routes.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(ProfileController());
  // Get the available cameras
  cameras = await availableCameras();

  // Register the cameras list with GetX
  Get.put<List<CameraDescription>>(cameras);

  // Register other controllers
  Get.put(NavigationController());
  Get.put(LoginController());
  Get.put(AuthController());
  Get.put(HomeController());
  Get.put(ProfileController());
  Get.put(CameraController(
    cameras.first,
    ResolutionPreset.high,
    enableAudio: true,
  ));

  // Listen for auth state changes
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      runApp(const MyApp(
        isSignedIn: false,
      ));
    } else {
      runApp(const MyApp(
        isSignedIn: true,
      )); // Navigate to home screen
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.isSignedIn});
  final bool isSignedIn;

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Security',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          initialRoute: isSignedIn ? AppRoutes.home : AppRoutes.login,
          getPages: AppRoutes.routes,
        );
      },
    );
  }
}
