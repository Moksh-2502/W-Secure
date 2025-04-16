import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
  // Observable variables
  final RxBool notificationsEnabled = true.obs;
  
  // Channel IDs
  static const String _emergencyChannelId = 'emergency_channel';
  static const String _alertChannelId = 'alert_channel';
  
  // For handling notification taps
  final Function(Map<String, dynamic>)? onNotificationTap;
  
  NotificationService({this.onNotificationTap});
  
  Future<NotificationService> init() async {
    // Request permission for notifications
    await _requestPermissions();
    
    // Initialize local notifications
    await _initializeLocalNotifications();
    
    // Handle FCM messages
    _setupFirebaseMessaging();
    
    // Update FCM token in Firestore
    await _updateFcmToken();
    
    return this;
  }
  
  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    notificationsEnabled.value = 
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    
    if (notificationsEnabled.value) {
      print('User granted permission for notifications');
    } else {
      print('User declined permission for notifications');
    }
  }
  
  Future<void> _initializeLocalNotifications() async {
    // Initialize settings for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Initialize settings for iOS
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        // Handle iOS foreground notification
      },
    );
    
    // Initialize settings for all platforms
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    // Initialize the plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          final Map<String, dynamic> data = json.decode(response.payload!);
          if (onNotificationTap != null) {
            onNotificationTap!(data);
          }
        }
      },
    );
    
    // Create notification channels for Android
    await _createNotificationChannels();
  }
  
  Future<void> _createNotificationChannels() async {
    if (Platform.isAndroid) {
      // Emergency high-priority channel
      const AndroidNotificationChannel emergencyChannel = AndroidNotificationChannel(
        _emergencyChannelId,
        'Emergency Alerts',
        description: 'This channel is used for emergency alerts',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        showBadge: true,
      );
      
      // Regular alerts channel
      const AndroidNotificationChannel alertChannel = AndroidNotificationChannel(
        _alertChannelId,
        'Proximity Alerts',
        description: 'This channel is used for proximity alerts',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );
      
      // Create the channels
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(emergencyChannel);
      
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(alertChannel);
    }
  }
  
  void _setupFirebaseMessaging() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        _showLocalNotification(
          message.notification?.title ?? 'New Alert',
          message.notification?.body ?? 'Someone nearby needs help!',
          message.data,
          isEmergency: message.data['isEmergency'] == 'true',
        );
      }
    });
    
    // Handle when user taps on notification from background state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      if (onNotificationTap != null) {
        onNotificationTap!(message.data);
      }
    });
    
    // Handle initial message if app was terminated
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('Initial message received');
        if (onNotificationTap != null) {
          onNotificationTap!(message.data);
        }
      }
    });
  }
  
  Future<void> _updateFcmToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
      print('FCM Token updated: $token');
    }
  }
  
  Future<void> _showLocalNotification(
    String title,
    String body,
    Map<String, dynamic> payload,
    {bool isEmergency = false}
  ) async {
    final String channelId = isEmergency ? _emergencyChannelId : _alertChannelId;
    
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId,
      isEmergency ? 'Emergency Alerts' : 'Proximity Alerts',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      sound: isEmergency 
          ? const RawResourceAndroidNotificationSound('emergency_siren')
          : null,
      icon: '@mipmap/ic_launcher',
      color: isEmergency ? Colors.red : const Color(0xFFFF4D79),
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );
    
    final DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: isEmergency ? 'emergency_siren.aiff' : null,
    );
    
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    
    await _flutterLocalNotificationsPlugin.show(
      isEmergency ? 911 : DateTime.now().millisecond,
      title,
      body,
      platformChannelSpecifics,
      payload: json.encode(payload),
    );
  }
  
  // Public method to send a notification to a specific user
  Future<void> sendNotificationToUser(
    String userId,
    String title,
    String body,
    Map<String, dynamic> data,
    {bool isEmergency = false}
  ) async {
    try {
      // Get user's FCM token
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final fcmToken = userDoc.data()?['fcmToken'];
      
      if (fcmToken == null) {
        print('No FCM token found for user $userId');
        return;
      }
      
      // Create message payload
      final message = {
        'notification': {
          'title': title,
          'body': body,
        },
        'data': {
          ...data,
          'isEmergency': isEmergency.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
        'token': fcmToken,
      };
      
      // Send to Firebase Cloud Functions to handle the actual sending
      // Note: This requires a Cloud Function to be set up
      await FirebaseFirestore.instance.collection('notifications').add(message);
      
      print('Notification request sent to Cloud Functions for user $userId');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
  
  // Public method to broadcast a notification to all users within a radius
  Future<void> broadcastEmergencyNotification(
    GeoPoint location,
    double radiusInMeters,
    String title,
    String body,
    Map<String, dynamic> data,
    {bool isEmergency = false}
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      // Get all users with FCM tokens
      final usersSnapshot = await FirebaseFirestore.instance.collection('users')
          .where('fcmToken', isNull: false)
          .get();
      
      // Get all user locations
      final locationsSnapshot = await FirebaseFirestore.instance.collection('user_locations').get();
      
      // Map of user IDs to their locations
      final Map<String, GeoPoint> userLocations = {};
      for (var doc in locationsSnapshot.docs) {
        final data = doc.data();
        if (data['location'] != null && data['isActive'] == true) {
          userLocations[doc.id] = data['location'] as GeoPoint;
        }
      }
      
      // List to store users within radius
      final List<String> usersToNotify = [];
      
      // Check each user's location
      for (var userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        
        // Skip the current user
        if (userId == user.uid) continue;
        
        // Check if we have location for this user
        if (userLocations.containsKey(userId)) {
          final userLocation = userLocations[userId]!;
          
          // Calculate distance
          final double distanceInMeters = _calculateHaversineDistance(
            location.latitude, location.longitude,
            userLocation.latitude, userLocation.longitude
          );
          
          // If within radius, add to notification list
          if (distanceInMeters <= radiusInMeters) {
            usersToNotify.add(userId);
          }
        }
      }
      
      // Send notifications to all users within radius
      for (var userId in usersToNotify) {
        await sendNotificationToUser(
          userId,
          title,
          body,
          data,
          isEmergency: isEmergency
        );
      }
      
      print('Emergency notification broadcast to ${usersToNotify.length} nearby users');
    } catch (e) {
      print('Error broadcasting emergency notification: $e');
    }
  }
  
  // Haversine formula to calculate distance between two coordinates
  double _calculateHaversineDistance(
    double lat1, double lon1,
    double lat2, double lon2
  ) {
    const double earthRadius = 6371000; // in meters
    
    // Convert latitude and longitude from degrees to radians
    final double latRad1 = _degreesToRadians(lat1);
    final double lonRad1 = _degreesToRadians(lon1);
    final double latRad2 = _degreesToRadians(lat2);
    final double lonRad2 = _degreesToRadians(lon2);
    
    // Differences
    final double dLat = latRad2 - latRad1;
    final double dLon = lonRad2 - lonRad1;
    
    // Haversine formula
    final double a = 
        (1 - _cos(dLat)) / 2 + 
        _cos(latRad1) * _cos(latRad2) * (1 - _cos(dLon)) / 2;
    final double c = 2 * _asin(_sqrt(a));
    
    return earthRadius * c;
  }
  
  // Helper methods for the Haversine formula
  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }
  
  double _cos(double radians) {
    return cos(radians);
  }
  
  double _asin(double value) {
    return asin(value);
  }
  
  double _sqrt(double value) {
    return sqrt(value);
  }
  
  // Trig functions implementation
  double cos(double radians) {
    return dart_cos(radians);
  }
  
  double asin(double value) {
    return dart_asin(value);
  }
  
  double sqrt(double value) {
    return dart_sqrt(value);
  }
  
  // Dart implementations of trig functions
  double dart_cos(double radians) {
    // Taylor series approximation for cosine
    double result = 1.0;
    double term = 1.0;
    double x2 = radians * radians;
    
    for (int i = 1; i <= 10; i++) {
      term *= -x2 / ((2 * i - 1) * (2 * i));
      result += term;
      if (term.abs() < 1e-10) break;
    }
    
    return result;
  }
  
  double dart_asin(double x) {
    // Approximation for asin using Taylor series
    if (x.abs() > 1) return double.nan;
    if (x.abs() == 1) return x * 3.14159265359 / 2;
    
    double result = x;
    double term = x;
    double x2 = x * x;
    
    for (int i = 1; i <= 10; i++) {
      term = term * x2 * (2 * i - 1) * (2 * i - 1) / ((2 * i) * (2 * i + 1));
      result += term;
      if (term.abs() < 1e-10) break;
    }
    
    return result;
  }
  
  double dart_sqrt(double x) {
    // Newton's method for square root
    if (x < 0) return double.nan;
    if (x == 0) return 0;
    
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    
    return guess;
  }
}
