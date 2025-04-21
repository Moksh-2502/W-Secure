import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:security/services/proximity_alert_service.dart';
import 'package:security/services/notification_service.dart';
import 'package:security/services/audio_alert_service.dart';

class AlertsController extends GetxController {
  // Services
  final ProximityAlertService _proximityAlertService = Get.find<ProximityAlertService>();
  final NotificationService _notificationService = Get.find<NotificationService>();
  final AudioAlertService _audioAlertService = Get.find<AudioAlertService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Observable variables
  final RxList<Map<String, dynamic>> alerts = <Map<String, dynamic>>[].obs;
  final RxBool isTracking = false.obs;
  final RxBool isProcessing = false.obs;
  final RxBool isAlertActive = false.obs;
  final RxString activeAlertId = ''.obs;
  final RxBool isSoundEnabled = true.obs;
  
  // Controllers
  final TextEditingController alertMessageController = TextEditingController();
  
  // Animation controller for alert button
  late AnimationController _alertButtonController;
  late Animation<double> alertButtonScale;
  
  // Getters
  AnimationController get alertButtonController => _alertButtonController;
  
  @override
  void onInit() {
    super.onInit();
    startTracking();
    
    // Initialize sound setting
    isSoundEnabled.value = _audioAlertService.isSoundEnabled;
    
    // Listen for changes in proximity alert service
    ever(_proximityAlertService.isTracking, (isTracking) {
      this.isTracking.value = isTracking;
    });
    
    ever(_proximityAlertService.nearbyAlerts, (nearbyAlerts) {
      alerts.value = nearbyAlerts;
    });
    
    ever(_proximityAlertService.isProcessingAlert, (isProcessing) {
      this.isProcessing.value = isProcessing;
    });
  }
  
  @override
  void onClose() {
    alertMessageController.dispose();
    super.onClose();
  }
  
  // Set animation controller from outside
  void setAnimationController(AnimationController controller) {
    _alertButtonController = controller;
    alertButtonScale = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _alertButtonController,
        curve: Curves.easeInOut,
      ),
    );
  }
  
  // Start tracking location and listening for alerts
  void startTracking() {
    _proximityAlertService.startTracking();
  }
  
  // Stop tracking location
  void stopTracking() {
    _proximityAlertService.stopTracking();
  }
  
  // Send a regular alert
  Future<void> sendAlert() async {
    if (isProcessing.value || isAlertActive.value) return;
    
    final message = alertMessageController.text.trim();
    await _proximityAlertService.sendAlert(message);
    
    // Clear the text field
    alertMessageController.text = '';
    
    // Set active alert
    isAlertActive.value = true;
    activeAlertId.value = _proximityAlertService.lastAlertId;
  }
  
  // Send an emergency SOS alert
  Future<void> sendSOSAlert() async {
    if (isProcessing.value || isAlertActive.value) return;
    
    await _proximityAlertService.sendAlert('EMERGENCY: I need immediate help!', isEmergency: true);
    
    // Set active alert
    isAlertActive.value = true;
    activeAlertId.value = _proximityAlertService.lastAlertId;
  }
  
  // Cancel an active alert
  Future<void> cancelAlert() async {
    if (activeAlertId.isNotEmpty) {
      await _proximityAlertService.cancelAlert(activeAlertId.value);
      isAlertActive.value = false;
      activeAlertId.value = '';
    }
  }
  
  // Format timestamp to readable time
  String formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    
    DateTime dateTime;
    if (timestamp is DateTime) {
      dateTime = timestamp;
    } else {
      dateTime = timestamp.toDate();
    }
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
  
  // Toggle sound on/off
  void toggleSound() {
    _audioAlertService.toggleSound();
    isSoundEnabled.value = _audioAlertService.isSoundEnabled;
  }
  
  // Play test sound
  void playTestSound() {
    if (isSoundEnabled.value) {
      _audioAlertService.playNotificationSound();
    }
  }
}
