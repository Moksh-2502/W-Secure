import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:security/services/audio_alert_service.dart';
import 'package:security/services/notification_service.dart';
import 'package:security/services/proximity_alert_service.dart';

class ProximityAlertController extends GetxController with GetSingleTickerProviderStateMixin {
  final ProximityAlertService _proximityAlertService = Get.find<ProximityAlertService>();
  final AudioAlertService _audioAlertService = Get.find<AudioAlertService>();
  final NotificationService _notificationService = Get.find<NotificationService>();
  
  // Observable variables
  final RxBool isTracking = false.obs;
  final RxList<Map<String, dynamic>> nearbyAlerts = <Map<String, dynamic>>[].obs;
  final RxBool isAlertActive = false.obs;
  final RxString activeAlertId = ''.obs;
  final RxBool isSoundEnabled = true.obs;
  final RxBool isProcessing = false.obs;
  final RxDouble alertButtonScale = 1.0.obs;
  
  // Animation controllers
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;
  
  // Text controllers
  final TextEditingController alertMessageController = TextEditingController();
  
  @override
  void onInit() {
    super.onInit();
    
    // Initialize animation controller for pulsing effect
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Add listener to update the scale value
    _pulseAnimation.addListener(() {
      alertButtonScale.value = _pulseAnimation.value;
    });
    
    // Make the animation repeat
    _pulseAnimationController.repeat(reverse: true);
    
    // Bind service observables to controller observables
    ever(_proximityAlertService.isTracking, (value) {
      isTracking.value = value;
    });
    
    ever(_proximityAlertService.nearbyAlerts, (value) {
      nearbyAlerts.value = value;
    });
    
    ever(_proximityAlertService.isProcessingAlert, (value) {
      isProcessing.value = value;
    });
    
    ever(_audioAlertService.isSoundEnabled, (value) {
      isSoundEnabled.value = value;
    });
    
    // Start location tracking when controller initializes
    startTracking();
  }
  
  // Start tracking user location
  Future<void> startTracking() async {
    await _proximityAlertService.startLocationTracking();
  }
  
  // Stop tracking user location
  void stopTracking() {
    _proximityAlertService.stopLocationTracking();
  }
  
  // Send an alert to nearby users with animation feedback
  Future<void> sendAlert() async {
    if (isProcessing.value) return;
    
    String message = alertMessageController.text.trim();
    if (message.isEmpty) {
      message = "I need help! Please assist if you're nearby.";
    }
    
    // Start processing animation
    isProcessing.value = true;
    
    try {
      await _proximityAlertService.sendAlert(message, isEmergency: false);
      isAlertActive.value = true;
      
      // Clear the message field
      alertMessageController.clear();
    } finally {
      isProcessing.value = false;
    }
  }
  
  // Send an immediate SOS alert with emergency sound
  Future<void> sendSOSAlert() async {
    if (isProcessing.value) return;
    
    // Start processing animation
    isProcessing.value = true;
    
    try {
      await _proximityAlertService.sendAlert("EMERGENCY! I need immediate help!", isEmergency: true);
      isAlertActive.value = true;
    } finally {
      isProcessing.value = false;
    }
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
  }
  
  // Play test sound
  void playTestSound() {
    if (isSoundEnabled.value) {
      _audioAlertService.playNotificationSound();
    }
  }
  
  @override
  void onClose() {
    alertMessageController.dispose();
    _pulseAnimationController.dispose();
    super.onClose();
  }
}
