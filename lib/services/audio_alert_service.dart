import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

class AudioAlertService extends GetxService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final RxBool isSoundEnabled = true.obs;
  
  // Sound types
  static const String EMERGENCY = 'emergency';
  static const String ALERT = 'alert';
  static const String NOTIFICATION = 'notification';
  
  // Sound file paths
  final Map<String, String> _soundPaths = {
    EMERGENCY: 'assets/sounds/emergency_siren.mp3',
    ALERT: 'assets/sounds/alert_sound.mp3',
    NOTIFICATION: 'assets/sounds/notification.mp3',
  };
  
  Future<AudioAlertService> init() async {
    // Initialize audio player settings
    await _audioPlayer.setReleaseMode(ReleaseMode.release);
    return this;
  }
  
  /// Play a sound alert based on the specified type
  /// Returns true if sound was played successfully
  Future<bool> playSound(String soundType) async {
    if (!isSoundEnabled.value) return false;
    
    try {
      if (_soundPaths.containsKey(soundType)) {
        final path = _soundPaths[soundType]!;
        await _audioPlayer.play(AssetSource(path));
        return true;
      }
      return false;
    } catch (e) {
      print('Error playing sound: $e');
      return false;
    }
  }
  
  /// Play emergency siren sound
  Future<bool> playEmergencySiren() async {
    return await playSound(EMERGENCY);
  }
  
  /// Play alert sound
  Future<bool> playAlertSound() async {
    return await playSound(ALERT);
  }
  
  /// Play notification sound
  Future<bool> playNotificationSound() async {
    return await playSound(NOTIFICATION);
  }
  
  /// Stop any currently playing sound
  Future<void> stopSound() async {
    await _audioPlayer.stop();
  }
  
  /// Set sound enabled/disabled
  void setSoundEnabled(bool enabled) {
    isSoundEnabled.value = enabled;
    if (!enabled) {
      stopSound();
    }
  }
  
  /// Toggle sound enabled/disabled
  void toggleSound() {
    setSoundEnabled(!isSoundEnabled.value);
  }
  
  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}
