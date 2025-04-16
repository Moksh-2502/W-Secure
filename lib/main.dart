import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:camera/camera.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:security/controllers/auth_controller.dart';
import 'package:security/controllers/home_controller.dart';
import 'package:security/controllers/login_controller.dart';
import 'package:security/controllers/navigation_controller.dart';
import 'package:security/controllers/profile_controller.dart';
import 'package:security/routes/app_routes.dart';
import 'package:security/screens/connect_nearby_page.dart';
import 'package:security/screens/police_screen.dart';
import 'package:security/screens/safespots_screen.dart';
import 'package:security/services/camera_controller_service.dart';
import 'package:security/services/notification_service.dart';
import 'package:security/services/audio_alert_service.dart';

late List<CameraDescription> cameras;

// Background message handler for Firebase Cloud Messaging
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize Firebase Cloud Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Initialize controllers
  Get.put(ProfileController());
  cameras = await availableCameras();
  Get.put<List<CameraDescription>>(cameras);
  Get.put(NavigationController());
  Get.put(LoginController());
  Get.put(AuthController());
  Get.put(HomeController());
  Get.put(ProfileController());

  // Initialize services
  final cameraService = CameraControllerService();
  await cameraService.initializeCamera(cameras);
  Get.put<CameraControllerService>(cameraService);
  
  // Initialize audio alert service
  final audioAlertService = AudioAlertService();
  await audioAlertService.init();
  Get.put<AudioAlertService>(audioAlertService, permanent: true);
  
  // Initialize notification service
  final notificationService = NotificationService(
    onNotificationTap: (data) {
      // Handle notification tap
      if (data['alertId'] != null) {
        Get.toNamed('/map', arguments: {
          'alertId': data['alertId'],
          'latitude': double.tryParse(data['latitude'] ?? '0.0'),
          'longitude': double.tryParse(data['longitude'] ?? '0.0'),
        });
      }
    },
  );
  await notificationService.init();
  Get.put<NotificationService>(notificationService, permanent: true);

  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      runApp(const MyApp(
        isSignedIn: false,
      ));
    } else {
      runApp(const MyApp(
        isSignedIn: true,
      ));
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
          getPages: [
            ...AppRoutes.routes,
            GetPage(
              name: '/police-stations',
              page: () => PoliceStationsPage(),
            ),
            GetPage(
              name: '/safe-spots',
              page: () => SafeSpotsPage(),
            ),
            GetPage(
              name: '/connectNearby',
              page: () => ConnectNearbyPage(),
            ),
          ],
        );
      },
    );
  }
}
