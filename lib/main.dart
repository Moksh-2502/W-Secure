import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:camera/camera.dart';
import 'package:security/controllers/auth_controller.dart';
import 'package:security/controllers/home_controller.dart';
import 'package:security/controllers/login_controller.dart';
import 'package:security/controllers/navigation_controller.dart';

import 'package:security/routes/app_routes.dart';

// Define cameras as late variable
late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize cameras
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error initializing cameras: $e');
    cameras = []; // Initialize with empty list in case of error
  }

  // Initialize all controllers and services
  Get.put(NavigationController());
  Get.put(LoginController());
  Get.put(AuthController());
  Get.put(HomeController());

  // Put cameras in GetX dependency injection
  Get.put<List<CameraDescription>>(cameras, permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
          initialRoute: AppRoutes.LOGIN,
          getPages: AppRoutes.routes,
        );
      },
    );
  }
}
