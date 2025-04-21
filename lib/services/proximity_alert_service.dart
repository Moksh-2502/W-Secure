import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:security/services/audio_alert_service.dart';
import 'package:security/services/notification_service.dart';

class ProximityAlertService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final NotificationService _notificationService;
  late final AudioAlertService _audioAlertService;
  
  // Observable variables
  final RxBool isTracking = false.obs;
  final RxList<Map<String, dynamic>> nearbyAlerts = <Map<String, dynamic>>[].obs;
  final RxBool isProcessingAlert = false.obs;
  String lastAlertId = '';
  final Rx<Position?> lastKnownLocation = Rx<Position?>(null);
  
  // Private variables
  Timer? _locationUpdateTimer;
  StreamSubscription? _alertsSubscription;
  
  // Constants
  static const double EARTH_RADIUS_KM = 6371.0; // Earth radius in kilometers
  static const double DEFAULT_ALERT_RADIUS_METERS = 100.0;
  
  // Initialize the service
  Future<ProximityAlertService> init() async {
    // Initialize dependencies
    _notificationService = Get.find<NotificationService>();
    _audioAlertService = Get.find<AudioAlertService>();
    
    // Request location permissions when service initializes
    await _requestLocationPermission();
    return this;
  }
  
  // Start tracking location and listening for alerts
  void startTracking() {
    if (isTracking.value) return;
    
    _startLocationTracking();
    _setupAlertsListener();
    isTracking.value = true;
  }
  
  // Start periodic location updates
  void _startLocationTracking() {
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _updateUserLocation();
    });
  }
  
  // Setup listener for nearby alerts
  void _setupAlertsListener() {
    final user = _auth.currentUser;
    if (user == null) return;
    
    try {
      // Listen for active alerts within radius
      _alertsSubscription = _firestore
          .collection('alerts')
          .where('isActive', isEqualTo: true)
          .snapshots()
          .listen((snapshot) async {
        // Process alerts
        await _processNearbyAlerts(snapshot.docs);
      });
    } catch (e) {
      print('Error setting up alerts listener: $e');
    }
  }
  
  // Stop tracking location
  void stopTracking() {
    if (!isTracking.value) return;
    
    _locationUpdateTimer?.cancel();
    _alertsSubscription?.cancel();
    isTracking.value = false;
  }
  
  // Update user's location in Firestore
  Future<void> _updateUserLocation() async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    try {
      // Get current position with high accuracy
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      // Store in Firestore
      await _firestore.collection('user_locations').doc(user.uid).set({
        'userId': user.uid,
        'location': GeoPoint(position.latitude, position.longitude),
        'lastUpdated': FieldValue.serverTimestamp(),
        'isActive': true
      });
      
      // Update local tracking
      lastKnownLocation.value = position;
    } catch (e) {
      print('Error updating location: $e');
    }
  }
  
  // Process nearby alerts from Firestore
  Future<void> _processNearbyAlerts(List<DocumentSnapshot> alertDocs) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    try {
      Position? currentPosition = lastKnownLocation.value;
      if (currentPosition == null) {
        currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        lastKnownLocation.value = currentPosition;
      }
      
      // Process alerts and calculate distances
      final List<Map<String, dynamic>> processedAlerts = [];
      
      for (var doc in alertDocs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;
        
        // Skip user's own alerts
        if (data['userId'] == user.uid) continue;
        
        // Get alert location
        final GeoPoint? alertLocation = data['location'] as GeoPoint?;
        if (alertLocation == null) continue;
        
        // Calculate distance
        final double distanceInMeters = _calculateVincentyDistance(
          currentPosition.latitude, currentPosition.longitude,
          alertLocation.latitude, alertLocation.longitude
        );
        
        // Convert to kilometers with 1 decimal place
        final double distanceInKm = double.parse((distanceInMeters / 1000).toStringAsFixed(1));
        
        // Add to processed alerts
        processedAlerts.add({
          'id': doc.id,
          ...data,
          'distance': distanceInKm,
        });
      }
      
      // Sort by distance (closest first)
      processedAlerts.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
      
      // Update observable list
      nearbyAlerts.value = processedAlerts;
    } catch (e) {
      print('Error processing nearby alerts: $e');
    }
  }
  
  // Request location permission
  Future<bool> _requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Error', 'Location services are disabled.');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Error', 'Location permissions are denied.');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('Error', 'Location permissions are permanently denied.');
      return false;
    }
    
    return true;
  }
  
  // Start tracking user location
  Future<void> startLocationTracking() async {
    final user = _auth.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'You need to be logged in to use this feature.');
      return;
    }
    
    final hasPermission = await _requestLocationPermission();
    if (!hasPermission) return;
    
    // Start periodic location updates
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _updateUserLocation();
    });
    
    // Update location immediately
    await _updateUserLocation();
    
    // Listen for nearby alerts
    _listenForNearbyAlerts();
    
    isTracking.value = true;
  }
  
  // Stop tracking user location
  void stopLocationTracking() {
    _locationUpdateTimer?.cancel();
    _alertsSubscription?.cancel();
    isTracking.value = false;
  }
  
  // Listen for alerts from nearby users with enhanced distance calculation
  void _listenForNearbyAlerts() async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    try {
      // Get current user's location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      // Create a GeoPoint for the current user's location
      GeoPoint userLocation = GeoPoint(position.latitude, position.longitude);
      
      // Listen to the 'alerts' collection
      _alertsSubscription = _firestore.collection('alerts')
          .where('timestamp', isGreaterThan: Timestamp.fromDate(
              DateTime.now().subtract(const Duration(minutes: 30))))
          .where('isActive', isEqualTo: true)
          .snapshots()
          .listen((snapshot) async {
        List<Map<String, dynamic>> alerts = [];
        bool newAlertFound = false;
        Map<String, dynamic>? newAlert;
        
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final GeoPoint alertLocation = data['location'] as GeoPoint;
          
          // Enhanced distance calculation using Vincenty formula
          double distanceInMeters = _calculateVincentyDistance(
            userLocation.latitude, 
            userLocation.longitude,
            alertLocation.latitude, 
            alertLocation.longitude
          );
          
          // If alert is within radius and not from the current user
          if (distanceInMeters <= DEFAULT_ALERT_RADIUS_METERS && data['userId'] != user.uid) {
            final alertData = {
              'id': doc.id,
              'userId': data['userId'],
              'userName': data['userName'] ?? 'Anonymous',
              'message': data['message'] ?? 'Emergency alert',
              'location': alertLocation,
              'timestamp': data['timestamp'],
              'distance': (distanceInMeters / 1000).toStringAsFixed(2), // Convert to km
              'isEmergency': data['isEmergency'] ?? false,
              'photoUrl': data['photoUrl'],
            };
            
            alerts.add(alertData);
            
            // Check if this is a new alert
            bool isExistingAlert = nearbyAlerts.any((existingAlert) => existingAlert['id'] == doc.id);
            if (!isExistingAlert) {
              newAlertFound = true;
              newAlert = alertData;
            }
          }
        }
        
        // Update the nearbyAlerts list
        nearbyAlerts.value = alerts;
        
        // Show notification and play sound for new alerts
        if (newAlertFound && newAlert != null) {
          // Play appropriate sound based on alert type
          if (newAlert['isEmergency'] == true) {
            _audioAlertService.playEmergencySiren();
          } else {
            _audioAlertService.playAlertSound();
          }
          
          // Show in-app notification
          Get.snackbar(
            'Alert Nearby!', 
            '${newAlert['userName']} needs help ${newAlert['distance']} km away!',
            backgroundColor: const Color(0xFFFF4D79),
            colorText: const Color(0xFFFFFFFF),
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.TOP,
            borderRadius: 10,
            margin: const EdgeInsets.all(10),
            animationDuration: const Duration(milliseconds: 500),
          );
        }
      });
    } catch (e) {
      print('Error setting up alerts listener: $e');
    }
  }
  
  // Send an alert to nearby users with enhanced functionality
  Future<void> sendAlert(String message, {bool isEmergency = false}) async {
    // Prevent multiple simultaneous alert submissions
    if (isProcessingAlert.value) return;
    isProcessingAlert.value = true;
    
    final user = _auth.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'You need to be logged in to send alerts.');
      isProcessingAlert.value = false;
      return;
    }
    
    try {
      // Play sound based on alert type
      if (isEmergency) {
        _audioAlertService.playEmergencySiren();
      } else {
        _audioAlertService.playAlertSound();
      }
      
      // Get current position with high accuracy
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      // Get user profile data
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      String userName = 'Anonymous';
      String? photoUrl;
      
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>?;
        userName = userData?['displayName'] ?? 'Anonymous';
        photoUrl = userData?['photoURL'];
      }
      
      // Create alert document with enhanced data
      final alertRef = await _firestore.collection('alerts').add({
        'userId': user.uid,
        'userName': userName,
        'photoUrl': photoUrl,
        'message': message,
        'location': GeoPoint(position.latitude, position.longitude),
        'timestamp': FieldValue.serverTimestamp(),
        'isActive': true,
        'isEmergency': isEmergency,
        'accuracy': position.accuracy,
        'altitude': position.altitude,
        'speed': position.speed,
        'heading': position.heading,
        'deviceInfo': {
          'platform': 'mobile',
          'timestamp': DateTime.now().toIso8601String(),
        }
      });
      
      // Broadcast push notification to nearby users
      await _notificationService.broadcastEmergencyNotification(
        GeoPoint(position.latitude, position.longitude),
        DEFAULT_ALERT_RADIUS_METERS,
        isEmergency ? 'EMERGENCY ALERT!' : 'Alert Nearby',
        '$userName ${isEmergency ? 'needs immediate help' : 'needs assistance'} nearby!',
        {
          'alertId': alertRef.id,
          'userId': user.uid,
          'latitude': position.latitude.toString(),
          'longitude': position.longitude.toString(),
          'type': isEmergency ? 'emergency' : 'alert',
        },
        isEmergency: isEmergency,
      );
      
      // Show confirmation to user with animation
      Get.snackbar(
        'Alert Sent', 
        'Your alert has been sent to nearby users.',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: const Color(0xFFFFFFFF),
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        animationDuration: const Duration(milliseconds: 500),
        borderRadius: 10,
        margin: const EdgeInsets.all(10),
      );
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Failed to send alert: $e',
        backgroundColor: const Color(0xFFFF5252),
        colorText: const Color(0xFFFFFFFF),
      );
    } finally {
      isProcessingAlert.value = false;
    }
  }
  
  // Cancel an alert with enhanced feedback
  Future<void> cancelAlert(String alertId) async {
    try {
      await _firestore.collection('alerts').doc(alertId).update({
        'isActive': false,
        'cancelledAt': FieldValue.serverTimestamp(),
      });
      
      // Play notification sound for confirmation
      _audioAlertService.playNotificationSound();
      
      Get.snackbar(
        'Alert Cancelled', 
        'Your alert has been cancelled.',
        backgroundColor: const Color(0xFF9E9E9E),
        colorText: const Color(0xFFFFFFFF),
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
        animationDuration: const Duration(milliseconds: 300),
      );
    } catch (e) {
      print('Error cancelling alert: $e');
      Get.snackbar('Error', 'Failed to cancel alert');
    }
  }
  
  // Enhanced distance calculation using Vincenty formula
  double _calculateVincentyDistance(double lat1, double lon1, double lat2, double lon2) {
    // Convert degrees to radians
    lat1 = _degreesToRadians(lat1);
    lon1 = _degreesToRadians(lon1);
    lat2 = _degreesToRadians(lat2);
    lon2 = _degreesToRadians(lon2);
    
    // WGS-84 ellipsoid parameters
    const double a = 6378137.0; // semi-major axis in meters
    const double b = 6356752.314245; // semi-minor axis in meters
    const double f = 1/298.257223563; // flattening
    
    double L = lon2 - lon1; // difference in longitude
    double U1 = math.atan((1-f) * math.tan(lat1)); // reduced latitude
    double U2 = math.atan((1-f) * math.tan(lat2)); // reduced latitude
    double sinU1 = math.sin(U1);
    double cosU1 = math.cos(U1);
    double sinU2 = math.sin(U2);
    double cosU2 = math.cos(U2);
    
    double lambda = L;
    double lambdaP;
    double sinLambda, cosLambda;
    double sinSigma, cosSigma, sigma, sinAlpha, cosSqAlpha, cos2SigmaM;
    
    int iterations = 0;
    do {
      sinLambda = math.sin(lambda);
      cosLambda = math.cos(lambda);
      sinSigma = math.sqrt(math.pow(cosU2 * sinLambda, 2) + 
                           math.pow(cosU1 * sinU2 - sinU1 * cosU2 * cosLambda, 2));
      
      // Co-incident points
      if (sinSigma == 0) return 0;
      
      cosSigma = sinU1 * sinU2 + cosU1 * cosU2 * cosLambda;
      sigma = math.atan2(sinSigma, cosSigma);
      sinAlpha = cosU1 * cosU2 * sinLambda / sinSigma;
      cosSqAlpha = 1 - sinAlpha * sinAlpha;
      
      // Equatorial line
      cos2SigmaM = cosSqAlpha != 0 ? cosSigma - 2 * sinU1 * sinU2 / cosSqAlpha : 0;
      
      double C = f / 16 * cosSqAlpha * (4 + f * (4 - 3 * cosSqAlpha));
      lambdaP = lambda;
      lambda = L + (1 - C) * f * sinAlpha * 
               (sigma + C * sinSigma * (cos2SigmaM + C * cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM)));
      
      // Check for convergence
      if (++iterations > 100 || (lambda - lambdaP).abs() < 1e-12) break;
      
    } while ((lambda - lambdaP).abs() > 1e-12);
    
    // Check for solution not converging
    if (iterations >= 100) {
      print('Vincenty formula failed to converge, falling back to Haversine');
      return _calculateHaversineDistance(lat1, lon1, lat2, lon2);
    }
    
    double uSq = cosSqAlpha * (a * a - b * b) / (b * b);
    double A = 1 + uSq / 16384 * (4096 + uSq * (-768 + uSq * (320 - 175 * uSq)));
    double B = uSq / 1024 * (256 + uSq * (-128 + uSq * (74 - 47 * uSq)));
    double deltaSigma = B * sinSigma * (cos2SigmaM + B / 4 * (cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM) - 
                     B / 6 * cos2SigmaM * (-3 + 4 * sinSigma * sinSigma) * (-3 + 4 * cos2SigmaM * cos2SigmaM)));
    
    double distance = b * A * (sigma - deltaSigma);
    
    return distance; // in meters
  }
  
  // Haversine formula as fallback for distance calculation
  double _calculateHaversineDistance(double lat1, double lon1, double lat2, double lon2) {
    // Convert from degrees to radians if needed
    if (lat1 > math.pi || lon1 > math.pi || lat2 > math.pi || lon2 > math.pi) {
      lat1 = _degreesToRadians(lat1);
      lon1 = _degreesToRadians(lon1);
      lat2 = _degreesToRadians(lat2);
      lon2 = _degreesToRadians(lon2);
    }
    
    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;
    
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
               math.cos(lat1) * math.cos(lat2) * 
               math.sin(dLon / 2) * math.sin(dLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return EARTH_RADIUS_KM * 1000 * c; // Convert to meters
  }
  
  // Helper method to convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }
  
  @override
  void onClose() {
    stopLocationTracking();
    super.onClose();
  }
}
